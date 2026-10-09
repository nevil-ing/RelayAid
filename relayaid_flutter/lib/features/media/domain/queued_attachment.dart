import 'package:relayaid_client/relayaid_client.dart';

enum AttachmentUploadState { draft, pending, uploading, uploaded, failed }

/// Local state is deliberately independent from the incident's sync state.
class QueuedAttachment {
  const QueuedAttachment({
    required this.id,
    required this.incidentId,
    required this.organizationId,
    required this.userId,
    required this.contentType,
    required this.byteLength,
    required this.state,
    this.localPath,
    this.attempts = 0,
    this.nextAttemptAt,
    this.error,
  });

  final UuidValue id;
  final UuidValue incidentId;
  final UuidValue organizationId;
  final UuidValue userId;
  final String contentType;
  final int byteLength;
  final String? localPath;
  final AttachmentUploadState state;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? error;

  QueuedAttachment withState(
    AttachmentUploadState state, {
    int? attempts,
    DateTime? nextAttemptAt,
    String? error,
  }) => QueuedAttachment(
    id: id,
    incidentId: incidentId,
    organizationId: organizationId,
    userId: userId,
    contentType: contentType,
    byteLength: byteLength,
    localPath: localPath,
    state: state,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt,
    error: error,
  );

  Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'incidentId': incidentId.toString(),
    'organizationId': organizationId.toString(),
    'userId': userId.toString(),
    'contentType': contentType,
    'byteLength': byteLength,
    'localPath': localPath,
    'state': state.name,
    'attempts': attempts,
    'nextAttemptAt': nextAttemptAt?.toIso8601String(),
    'error': error,
  };

  factory QueuedAttachment.fromJson(Map<String, dynamic> json) =>
      QueuedAttachment(
        id: UuidValue.fromString(json['id'] as String),
        incidentId: UuidValue.fromString(json['incidentId'] as String),
        organizationId: UuidValue.fromString(json['organizationId'] as String),
        userId: UuidValue.fromString(json['userId'] as String),
        contentType: json['contentType'] as String,
        byteLength: json['byteLength'] as int,
        localPath: json['localPath'] as String?,
        state: AttachmentUploadState.values.byName(json['state'] as String),
        attempts: json['attempts'] as int? ?? 0,
        nextAttemptAt: json['nextAttemptAt'] == null
            ? null
            : DateTime.parse(json['nextAttemptAt'] as String),
        error: json['error'] as String?,
      );
}
