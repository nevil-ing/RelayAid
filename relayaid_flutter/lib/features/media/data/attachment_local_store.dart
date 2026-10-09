import 'dart:convert';
import 'package:relayaid_client/relayaid_client.dart';
import '../../../core/storage/relayaid_local_database.dart';
import '../domain/queued_attachment.dart';

abstract interface class AttachmentLocalStore {
  Future<List<QueuedAttachment>> list(UuidValue organizationId);
  Future<void> save(QueuedAttachment record);
  Future<void> remove(UuidValue id);
  Future<Map<String, dynamic>?> captureRequest(UuidValue userId);
  Future<void> setCaptureRequest(
    UuidValue userId,
    Map<String, dynamic>? request,
  );
}

class SqliteAttachmentLocalStore implements AttachmentLocalStore {
  const SqliteAttachmentLocalStore(this.database);
  final RelayAidLocalDatabase database;

  @override
  Future<List<QueuedAttachment>> list(UuidValue organizationId) async {
    final rows = await database.connection.getAll(
      'SELECT payload FROM attachment_records WHERE organization_id = ? ORDER BY rowid',
      [organizationId.toString()],
    );
    return rows
        .map(
          (row) => QueuedAttachment.fromJson(
            jsonDecode(row['payload']! as String) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> save(QueuedAttachment record) => database.connection.execute(
    'INSERT INTO attachment_records (id, organization_id, incident_id, payload) '
    'VALUES (?, ?, ?, ?) ON CONFLICT(id) DO UPDATE SET payload = excluded.payload',
    [
      record.id.toString(),
      record.organizationId.toString(),
      record.incidentId.toString(),
      jsonEncode(record.toJson()),
    ],
  );

  @override
  Future<void> remove(UuidValue id) => database.connection.execute(
    'DELETE FROM attachment_records WHERE id = ?',
    [id.toString()],
  );

  @override
  Future<Map<String, dynamic>?> captureRequest(UuidValue userId) async {
    final row = await database.connection.getOptional(
      'SELECT payload FROM photo_capture_requests WHERE user_id = ?',
      [userId.toString()],
    );
    return row == null
        ? null
        : jsonDecode(row['payload']! as String) as Map<String, dynamic>;
  }

  @override
  Future<void> setCaptureRequest(
    UuidValue userId,
    Map<String, dynamic>? request,
  ) async {
    if (request == null) {
      await database.connection.execute(
        'DELETE FROM photo_capture_requests WHERE user_id = ?',
        [userId.toString()],
      );
    } else {
      await database.connection.execute(
        'INSERT INTO photo_capture_requests (user_id, payload) VALUES (?, ?) '
        'ON CONFLICT(user_id) DO UPDATE SET payload = excluded.payload',
        [userId.toString(), jsonEncode(request)],
      );
    }
  }
}

class MemoryAttachmentLocalStore implements AttachmentLocalStore {
  final _records = <UuidValue, QueuedAttachment>{};
  final _captures = <UuidValue, Map<String, dynamic>>{};
  @override
  Future<List<QueuedAttachment>> list(UuidValue organizationId) async =>
      _records.values.where((r) => r.organizationId == organizationId).toList();
  @override
  Future<void> save(QueuedAttachment record) async {
    _records[record.id] = record;
  }

  @override
  Future<void> remove(UuidValue id) async {
    _records.remove(id);
  }

  @override
  Future<Map<String, dynamic>?> captureRequest(UuidValue userId) async =>
      _captures[userId];
  @override
  Future<void> setCaptureRequest(
    UuidValue userId,
    Map<String, dynamic>? request,
  ) async {
    if (request == null) {
      _captures.remove(userId);
    } else {
      _captures[userId] = request;
    }
  }
}
