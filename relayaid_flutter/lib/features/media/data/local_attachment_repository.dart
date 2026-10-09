import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:relayaid_client/relayaid_client.dart';
import '../../../core/connectivity/connectivity_controller.dart';
import '../../incidents/data/incident_local_store.dart';
import '../../incidents/domain/incident_repository.dart';
import '../../incidents/domain/incident_sync_state.dart';
import '../domain/attachment_repository.dart';
import '../domain/queued_attachment.dart';
import 'attachment_local_store.dart';

class LocalAttachmentRepository implements AttachmentRepository {
  LocalAttachmentRepository({
    required this.store,
    required this.files,
    required this.picker,
    required this.remote,
    required this.incidents,
    required this.incidentSync,
    required this.connectivity,
    required this.readContext,
    DateTime Function()? now,
  }) : now = now ?? (() => DateTime.now().toUtc());

  final AttachmentLocalStore store;
  final PhotoFileStore files;
  final PhotoPicker picker;
  final AttachmentRemote remote;
  final IncidentLocalStore incidents;
  final IncidentSyncRepository incidentSync;
  final ConnectivityController connectivity;
  final OrganizationContext? Function() readContext;
  final DateTime Function() now;
  final _changes = StreamController<void>.broadcast();
  Future<void>? _processing;
  Future<void>? _recovery;
  UuidValue? _recoveryUser;

  @override
  Stream<void> get changes => _changes.stream;
  void _changed() {
    if (!_changes.isClosed) _changes.add(null);
  }

  OrganizationContext _context() =>
      readContext() ??
      (throw const PhotoFailure('Sign in to your organization to add photos.'));

  @override
  Future<List<QueuedAttachment>> list(
    UuidValue incidentId, {
    bool refresh = false,
  }) async {
    final context = _context();
    var records = await store.list(context.organization.id!);
    final incident = await incidents.get(incidentId);
    if (refresh &&
        connectivity.isOnline &&
        (incident == null || incident.syncState == IncidentSyncState.synced)) {
      final uploaded = await remote.list(incidentId);
      for (final photo in uploaded) {
        final local = records.where((r) => r.id == photo.id).firstOrNull;
        await store.save(
          QueuedAttachment(
            id: photo.id!,
            incidentId: incidentId,
            organizationId: photo.organizationId,
            userId: photo.uploadedBy,
            contentType: photo.contentType,
            byteLength: photo.byteLength,
            localPath: local?.localPath,
            state: AttachmentUploadState.uploaded,
          ),
        );
      }
      records = await store.list(context.organization.id!);
    }
    return records.where((r) => r.incidentId == incidentId).toList();
  }

  @override
  Future<List<QueuedAttachment>> queue() async {
    final context = _context();
    final records = await store.list(context.organization.id!);
    final result = <QueuedAttachment>[];
    for (final record in records) {
      if (record.userId != context.membership.authUserId ||
          record.state == AttachmentUploadState.uploaded) {
        continue;
      }
      if (await incidents.get(record.incidentId) != null) {
        result.add(record);
      }
    }
    return result;
  }

  @override
  Future<UuidValue> draftIncidentId() async {
    await recoverPhoto();
    final context = _context();
    for (final photo in await store.list(context.organization.id!)) {
      if (photo.userId == context.membership.authUserId &&
          photo.state == AttachmentUploadState.draft &&
          await incidents.get(photo.incidentId) == null) {
        return photo.incidentId;
      }
    }
    return Uuid().v7obj();
  }

  @override
  Future<void> recoverPhoto() {
    final userId = readContext()?.membership.authUserId;
    if (userId == null) return Future.value();
    if (userId != _recoveryUser) {
      _recoveryUser = userId;
      _recovery = _recoverPhoto();
    }
    return _recovery!;
  }

  Future<void> _recoverPhoto() async {
    final context = readContext();
    if (context == null) return;
    final request = await store.captureRequest(context.membership.authUserId);
    final bytes = await picker.recover();
    if (request == null) return;
    // Never import evidence into a different signed-in organization.
    if (request['organizationId'] == context.organization.id.toString() &&
        bytes != null) {
      final incidentId = UuidValue.fromString(request['incidentId'] as String);
      final id = UuidValue.fromString(request['id'] as String);
      final existing = (await store.list(
        context.organization.id!,
      )).any((r) => r.id == id);
      if (!existing) await _savePhoto(context, incidentId, id, bytes);
    }
    await store.setCaptureRequest(context.membership.authUserId, null);
  }

  @override
  Future<void> capture(UuidValue incidentId, PhotoSource source) async {
    final context = _context();
    final records = await list(incidentId);
    if (records.length >= 5) {
      throw const PhotoFailure('You can add up to 5 photos.');
    }
    final id = Uuid().v7obj();
    await store.setCaptureRequest(context.membership.authUserId, {
      'id': id.toString(),
      'incidentId': incidentId.toString(),
      'organizationId': context.organization.id.toString(),
    });
    try {
      final bytes = await picker.pick(source);
      if (bytes != null) {
        if (readContext()?.membership.authUserId !=
            context.membership.authUserId) {
          throw const PhotoFailure(
            'Your session changed. Select the photo again.',
          );
        }
        await _savePhoto(context, incidentId, id, bytes);
      }
    } finally {
      await store.setCaptureRequest(context.membership.authUserId, null);
    }
  }

  Future<void> _savePhoto(
    OrganizationContext context,
    UuidValue incidentId,
    UuidValue id,
    Uint8List bytes,
  ) async {
    final isJpeg =
        bytes.length > 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff;
    final isPng =
        bytes.length > 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71;
    if ((!isJpeg && !isPng) || bytes.length > 5 * 1024 * 1024) {
      throw const PhotoFailure('Choose a JPEG or PNG photo smaller than 5 MB.');
    }
    final localPath = await files.save(id, bytes);
    try {
      await store.save(
        QueuedAttachment(
          id: id,
          incidentId: incidentId,
          organizationId: context.organization.id!,
          userId: context.membership.authUserId,
          contentType: isJpeg ? 'image/jpeg' : 'image/png',
          byteLength: bytes.length,
          localPath: localPath,
          state: await incidents.get(incidentId) == null
              ? AttachmentUploadState.draft
              : AttachmentUploadState.pending,
        ),
      );
    } catch (_) {
      await files.remove(localPath);
      rethrow;
    }
    _changed();
  }

  @override
  Future<void> removeDraft(UuidValue attachmentId) async {
    final context = _context();
    final record = (await store.list(
      context.organization.id!,
    )).where((r) => r.id == attachmentId).firstOrNull;
    if (record == null ||
        record.userId != context.membership.authUserId ||
        await incidents.get(record.incidentId) != null) {
      return;
    }
    await store.remove(record.id);
    if (record.localPath != null) {
      await files.remove(record.localPath!);
    }
    _changed();
  }

  @override
  Future<Uint8List> read(QueuedAttachment attachment) async {
    if (attachment.organizationId != _context().organization.id) {
      throw const PhotoFailure('Photo access is unavailable.');
    }
    if (attachment.localPath != null) {
      try {
        return await files.read(attachment.localPath!);
      } catch (_) {
        if (attachment.state != AttachmentUploadState.uploaded) rethrow;
      }
    }
    return remote.read(attachment.id);
  }

  @override
  Future<void> process({bool forceRetry = false}) {
    if (_processing case final Future<void> active) return active;
    final operation = _process(forceRetry);
    _processing = operation;
    return operation.whenComplete(() => _processing = null);
  }

  Future<void> _process(bool forceRetry) async {
    if (!connectivity.isOnline || readContext() == null) return;
    final context = _context();
    await incidentSync.syncPending();
    for (final photo in await queue()) {
      if (!connectivity.isOnline ||
          readContext()?.membership.authUserId !=
              context.membership.authUserId) {
        break;
      }
      if (!forceRetry && photo.nextAttemptAt?.isAfter(now()) == true) continue;
      if (!forceRetry &&
          photo.state == AttachmentUploadState.failed &&
          photo.nextAttemptAt == null) {
        continue;
      }
      final incident = await incidents.get(photo.incidentId);
      if (incident?.syncState != IncidentSyncState.synced) continue;
      await store.save(photo.withState(AttachmentUploadState.uploading));
      _changed();
      try {
        final bytes = await files.read(photo.localPath!);
        await remote.upload(photo, bytes);
        await store.save(photo.withState(AttachmentUploadState.uploaded));
      } catch (error) {
        final attempts = photo.attempts + 1;
        final delay = Duration(
          seconds: min(300, 5 * pow(2, min(attempts - 1, 6)).toInt()),
        );
        await store.save(
          photo.withState(
            AttachmentUploadState.failed,
            attempts: attempts,
            nextAttemptAt: error is AttachmentValidationException
                ? null
                : now().add(delay),
            error: error is AttachmentValidationException
                ? error.message
                : 'Photo remains on this device. Check your connection and retry.',
          ),
        );
      }
      _changed();
    }
  }

  Future<void> dispose() => _changes.close();
}
