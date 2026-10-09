import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:serverpod/serverpod.dart';

import '../authorization/organization_access.dart';
import '../generated/protocol.dart';
import 'incident_feed_service.dart';

/// Separates expiring upload objects from immutable, validated evidence.
abstract final class AttachmentService {
  static const maxBytes = 5 * 1024 * 1024;
  static const maxPhotos = 5;
  static const _maxPixels = 12 * 1000 * 1000;
  static const _storage = 'private';

  static Future<String?> beginUpload(
    Session session,
    UuidValue incidentId,
    UuidValue attachmentId, {
    required String contentType,
    required int byteLength,
  }) async {
    final incident = await _incident(session, incidentId);
    final existing = await _existing(session, incidentId, attachmentId);
    if (existing != null) return null;
    if (!{'image/jpeg', 'image/png'}.contains(contentType) ||
        byteLength < 1 ||
        byteLength > maxBytes) {
      throw AttachmentValidationException(
        message: 'Choose a JPEG or PNG photo up to 5 MB.',
      );
    }
    await _checkCapacity(session, incidentId);
    return session.storage.createUploadDescription(
      storageId: _storage,
      path: _uploadPath(session, incident, attachmentId),
      options: UploadOptions(
        maxFileSize: maxBytes,
        contentLength: byteLength,
        metadata: FileMetadata(contentType: contentType),
      ),
    );
  }

  static Future<IncidentAttachment> completeUpload(
    Session session,
    UuidValue incidentId,
    UuidValue attachmentId,
  ) async {
    final incident = await _incident(session, incidentId);
    final existing = await _existing(session, incidentId, attachmentId);
    if (existing != null) return existing;
    final uploadPath = _uploadPath(session, incident, attachmentId);
    if (!await session.storage.verifyUpload(
      storageId: _storage,
      path: uploadPath,
    )) {
      throw AttachmentValidationException(
        message: 'Photo has not uploaded yet.',
      );
    }
    final stat = await session.storage.statFile(
      storageId: _storage,
      path: uploadPath,
    );
    if (stat.size < 1 || stat.size > maxBytes) {
      throw AttachmentValidationException(message: 'Photo exceeds 5 MB.');
    }
    final bytes = await session.storage.retrieveFile(
      storageId: _storage,
      path: uploadPath,
    );
    final String contentType;
    try {
      contentType = _validateImage(bytes);
    } catch (_) {
      await session.storage.deleteFile(storageId: _storage, path: uploadPath);
      rethrow;
    }
    final storagePath =
        'incidents/${incident.organizationId}/$incidentId/${OrganizationAccess.userId(session)}/$attachmentId';
    IncidentEvent? addedEvent;
    final result = await session.db.transaction((transaction) async {
      // Serializes finalization, duplicate retries, and the per-incident quota.
      await Incident.db.findById(
        session,
        incidentId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final replay = await _existing(
        session,
        incidentId,
        attachmentId,
        transaction: transaction,
      );
      if (replay != null) return replay;
      await _checkCapacity(session, incidentId, transaction: transaction);
      // Only this copy is exposed by the read endpoint. Upload tokens can never
      // mutate published evidence; retries can reuse an orphaned canonical copy.
      if (await session.storage.fileExists(
        storageId: _storage,
        path: storagePath,
      )) {
        final canonical = Uint8List.sublistView(
          await session.storage.retrieveFile(
            storageId: _storage,
            path: storagePath,
          ),
        );
        final candidate = Uint8List.sublistView(bytes);
        if (canonical.length != candidate.length ||
            Iterable<int>.generate(
              canonical.length,
            ).any((i) => canonical[i] != candidate[i])) {
          throw AttachmentValidationException(
            message:
                'This photo ID contains different evidence. Select the photo again.',
          );
        }
      } else {
        await session.storage.storeFile(
          storageId: _storage,
          path: storagePath,
          byteData: bytes,
          options: StoreFileOptions(
            preventOverwrite: true,
            metadata: FileMetadata(contentType: contentType),
          ),
        );
      }
      final now = DateTime.now().toUtc();
      final attachment = await IncidentAttachment.db.insertRow(
        session,
        IncidentAttachment(
          id: attachmentId,
          incidentId: incidentId,
          organizationId: incident.organizationId,
          uploadedBy: OrganizationAccess.userId(session),
          contentType: contentType,
          byteLength: bytes.lengthInBytes,
          storagePath: storagePath,
          uploadedAt: now,
        ),
        transaction: transaction,
      );
      addedEvent = await IncidentEvent.db.insertRow(
        session,
        IncidentEvent(
          incidentId: incidentId,
          organizationId: incident.organizationId,
          eventType: IncidentEventType.attachmentAdded,
          actorId: attachment.uploadedBy,
          note: 'Photo uploaded',
          createdAt: now,
        ),
        transaction: transaction,
      );
      return attachment;
    });
    if (addedEvent case final IncidentEvent event) {
      await IncidentFeedService.publish(session, event);
    }
    // Cleanup failure must not turn a committed upload into a client failure.
    try {
      await session.storage.deleteFile(storageId: _storage, path: uploadPath);
    } catch (_) {
      session.log(
        'Could not remove a finalized temporary photo.',
        level: LogLevel.warning,
      );
    }
    return result;
  }

  static Future<List<IncidentAttachment>> list(
    Session session,
    UuidValue incidentId,
  ) async {
    await _incident(session, incidentId);
    return IncidentAttachment.db.find(
      session,
      where: (t) => t.incidentId.equals(incidentId),
      orderBy: (t) => t.uploadedAt,
    );
  }

  static Future<ByteData> read(Session session, UuidValue attachmentId) async {
    final attachment = await IncidentAttachment.db.findById(
      session,
      attachmentId,
    );
    if (attachment == null) {
      throw AuthorizationException(message: 'Photo access denied.');
    }
    await _incident(session, attachment.incidentId);
    return session.storage.retrieveFile(
      storageId: _storage,
      path: attachment.storagePath!,
    );
  }

  static Future<Incident> _incident(
    Session session,
    UuidValue incidentId,
  ) async {
    final incident = await Incident.db.findById(session, incidentId);
    if (incident == null) {
      throw AuthorizationException(message: 'Incident access denied.');
    }
    await OrganizationAccess.member(session, incident.organizationId);
    return incident;
  }

  static Future<IncidentAttachment?> _existing(
    Session session,
    UuidValue incidentId,
    UuidValue attachmentId, {
    Transaction? transaction,
  }) async {
    final row = await IncidentAttachment.db.findById(
      session,
      attachmentId,
      transaction: transaction,
    );
    if (row != null &&
        (row.incidentId != incidentId ||
            row.uploadedBy != OrganizationAccess.userId(session))) {
      throw AuthorizationException(message: 'Photo upload access denied.');
    }
    return row;
  }

  static Future<void> _checkCapacity(
    Session session,
    UuidValue incidentId, {
    Transaction? transaction,
  }) async {
    final count = await IncidentAttachment.db.count(
      session,
      where: (t) => t.incidentId.equals(incidentId),
      transaction: transaction,
    );
    if (count >= maxPhotos) {
      throw AttachmentValidationException(
        message: 'An incident supports up to 5 photos.',
      );
    }
  }

  static String _uploadPath(
    Session session,
    Incident incident,
    UuidValue attachmentId,
  ) =>
      'uploads/${incident.organizationId}/${incident.id}/${OrganizationAccess.userId(session)}/$attachmentId';

  static String _validateImage(ByteData data) {
    final bytes = Uint8List.sublistView(data);
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw AttachmentValidationException(message: 'Photo exceeds 5 MB.');
    }
    try {
      final image.Decoder decoder;
      final String contentType;
      if (image.JpegDecoder().isValidFile(bytes)) {
        decoder = image.JpegDecoder();
        contentType = 'image/jpeg';
      } else if (image.PngDecoder().isValidFile(bytes)) {
        decoder = image.PngDecoder();
        contentType = 'image/png';
      } else {
        throw const FormatException();
      }
      final info = decoder.startDecode(bytes);
      if (info == null ||
          info.width < 1 ||
          info.height < 1 ||
          info.width * info.height > _maxPixels ||
          decoder.numFrames() != 1 ||
          decoder.decodeFrame(0) == null) {
        throw const FormatException();
      }
      return contentType;
    } catch (_) {
      throw AttachmentValidationException(
        message:
            'Choose a valid, non-animated JPEG or PNG photo up to 12 megapixels.',
      );
    }
  }
}
