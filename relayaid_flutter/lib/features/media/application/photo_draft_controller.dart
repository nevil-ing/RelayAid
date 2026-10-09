import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:relayaid_client/relayaid_client.dart';
import '../domain/attachment_repository.dart';
import '../domain/queued_attachment.dart';

class PhotoDraftController extends ChangeNotifier {
  PhotoDraftController(this.repository) {
    unawaited(_initialize());
  }
  final AttachmentRepository repository;
  UuidValue? incidentId;
  List<QueuedAttachment> photos = const [];
  String? error;
  bool busy = true;
  bool _disposed = false;

  Future<void> _initialize() async {
    try {
      incidentId = await repository.draftIncidentId();
      photos = await repository.list(incidentId!);
    } catch (_) {
      // Photos are optional; local incident creation must remain available.
      incidentId = Uuid().v7obj();
      error = 'Photos are unavailable. You can still save the report.';
    }
    busy = false;
    _notify();
  }

  Future<void> pick(PhotoSource source) async {
    if (busy || incidentId == null) return;
    busy = true;
    error = null;
    _notify();
    try {
      await repository.capture(incidentId!, source);
      photos = await repository.list(incidentId!);
    } catch (failure) {
      error = failure is PhotoFailure
          ? failure.message
          : 'Photo could not be added. Check photo access and try again.';
    }
    busy = false;
    _notify();
  }

  Future<void> remove(UuidValue id) async {
    try {
      await repository.removeDraft(id);
      photos = await repository.list(incidentId!);
    } catch (_) {
      error = 'Photo could not be removed. Try again.';
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
