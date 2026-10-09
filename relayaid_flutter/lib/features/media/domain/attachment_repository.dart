import 'dart:typed_data';
import 'package:relayaid_client/relayaid_client.dart';
import 'queued_attachment.dart';

enum PhotoSource { camera, library }

abstract interface class PhotoPicker {
  bool get supportsCamera;
  Future<Uint8List?> pick(PhotoSource source);
  Future<Uint8List?> recover();
}

abstract interface class PhotoFileStore {
  Future<String> save(UuidValue id, Uint8List bytes);
  Future<Uint8List> read(String path);
  Future<void> remove(String path);
}

abstract interface class AttachmentRepository {
  Stream<void> get changes;
  Future<List<QueuedAttachment>> list(
    UuidValue incidentId, {
    bool refresh = false,
  });
  Future<List<QueuedAttachment>> queue();
  Future<UuidValue> draftIncidentId();
  Future<void> recoverPhoto();
  Future<void> capture(UuidValue incidentId, PhotoSource source);
  Future<void> removeDraft(UuidValue attachmentId);
  Future<Uint8List> read(QueuedAttachment attachment);
  Future<void> process({bool forceRetry = false});
}

abstract interface class AttachmentRemote {
  Future<IncidentAttachment> upload(
    QueuedAttachment attachment,
    Uint8List bytes,
  );
  Future<List<IncidentAttachment>> list(UuidValue incidentId);
  Future<Uint8List> read(UuidValue attachmentId);
}

class PhotoFailure implements Exception {
  const PhotoFailure(this.message);
  final String message;
}
