import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/attachment_service.dart';

/// Evidence is private and authorized against its incident's organization.
class MediaEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String?> beginUpload(
    Session session,
    UuidValue incidentId,
    UuidValue attachmentId, {
    required String contentType,
    required int byteLength,
  }) => AttachmentService.beginUpload(
    session,
    incidentId,
    attachmentId,
    contentType: contentType,
    byteLength: byteLength,
  );

  Future<IncidentAttachment> completeUpload(
    Session session,
    UuidValue incidentId,
    UuidValue attachmentId,
  ) => AttachmentService.completeUpload(session, incidentId, attachmentId);

  Future<List<IncidentAttachment>> list(
    Session session,
    UuidValue incidentId,
  ) => AttachmentService.list(session, incidentId);

  Future<ByteData> read(Session session, UuidValue attachmentId) =>
      AttachmentService.read(session, attachmentId);
}
