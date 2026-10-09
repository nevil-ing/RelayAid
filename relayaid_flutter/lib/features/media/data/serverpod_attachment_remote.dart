import 'dart:typed_data';
import 'package:relayaid_client/relayaid_client.dart';
import '../domain/attachment_repository.dart';
import '../domain/queued_attachment.dart';

class ServerpodAttachmentRemote implements AttachmentRemote {
  const ServerpodAttachmentRemote(this.client);
  final Client client;

  @override
  Future<IncidentAttachment> upload(
    QueuedAttachment attachment,
    Uint8List bytes,
  ) async {
    final description = await client.media.beginUpload(
      attachment.incidentId,
      attachment.id,
      contentType: attachment.contentType,
      byteLength: bytes.length,
    );
    if (description != null) {
      final uploaded = await FileUploader(description)
          .uploadByteData(ByteData.sublistView(bytes))
          .timeout(const Duration(seconds: 45));
      if (!uploaded) throw const PhotoFailure('Photo upload could not finish.');
    }
    return client.media.completeUpload(attachment.incidentId, attachment.id);
  }

  @override
  Future<List<IncidentAttachment>> list(UuidValue incidentId) =>
      client.media.list(incidentId);
  @override
  Future<Uint8List> read(UuidValue attachmentId) async =>
      Uint8List.sublistView(await client.media.read(attachmentId));
}
