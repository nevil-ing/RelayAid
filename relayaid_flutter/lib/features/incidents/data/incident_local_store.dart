import 'dart:convert';

import 'package:relayaid_client/relayaid_client.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/storage/relayaid_local_database.dart';
import '../domain/incident_sync_state.dart';

class LocalIncidentRecord {
  const LocalIncidentRecord({
    required this.detail,
    required this.syncState,
    this.syncError,
  });

  final IncidentDetail detail;
  final IncidentSyncState syncState;
  final String? syncError;

  UuidValue get incidentId => detail.incident.id!;
  UuidValue get organizationId => detail.incident.organizationId;
}

abstract interface class IncidentLocalStore {
  Future<List<LocalIncidentRecord>> list(
    UuidValue organizationId, {
    int limit = 100,
  });

  Future<LocalIncidentRecord?> get(UuidValue incidentId);

  Future<List<LocalIncidentRecord>> pending(UuidValue organizationId);

  Future<void> save(LocalIncidentRecord record);

  Future<void> close();
}

class SqliteIncidentLocalStore implements IncidentLocalStore {
  const SqliteIncidentLocalStore(this.database);

  final RelayAidLocalDatabase database;

  SqliteConnection get _connection => database.connection;

  @override
  Future<List<LocalIncidentRecord>> list(
    UuidValue organizationId, {
    int limit = 100,
  }) async {
    final rows = await _connection.getAll(
      'SELECT payload, sync_state, sync_error FROM incident_records '
      'WHERE organization_id = ? ORDER BY updated_at DESC LIMIT ?',
      [organizationId.toString(), limit],
    );
    return rows.map(_recordFromRow).toList(growable: false);
  }

  @override
  Future<LocalIncidentRecord?> get(UuidValue incidentId) async {
    final row = await _connection.getOptional(
      'SELECT payload, sync_state, sync_error FROM incident_records '
      'WHERE id = ?',
      [incidentId.toString()],
    );
    return row == null ? null : _recordFromRow(row);
  }

  @override
  Future<List<LocalIncidentRecord>> pending(UuidValue organizationId) async {
    final rows = await _connection.getAll(
      'SELECT payload, sync_state, sync_error FROM incident_records '
      'WHERE organization_id = ? AND sync_state IN (?, ?, ?, ?) '
      'ORDER BY updated_at ASC',
      [
        organizationId.toString(),
        IncidentSyncState.offline.name,
        IncidentSyncState.pending.name,
        IncidentSyncState.failed.name,
        IncidentSyncState.syncing.name,
      ],
    );
    return rows.map(_recordFromRow).toList(growable: false);
  }

  @override
  Future<void> save(LocalIncidentRecord record) async {
    final detail = record.detail;
    await _connection.execute(
      'INSERT INTO incident_records '
      '(id, organization_id, payload, sync_state, sync_error, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET '
      'organization_id = excluded.organization_id, '
      'payload = excluded.payload, '
      'sync_state = excluded.sync_state, '
      'sync_error = excluded.sync_error, '
      'updated_at = excluded.updated_at',
      [
        detail.incident.id.toString(),
        detail.incident.organizationId.toString(),
        jsonEncode(detail.toJson()),
        record.syncState.name,
        record.syncError,
        detail.incident.updatedAt.millisecondsSinceEpoch,
      ],
    );
  }

  @override
  Future<void> close() => database.close();

  LocalIncidentRecord _recordFromRow(Map<String, Object?> row) {
    final payload = jsonDecode(row['payload']! as String);
    return LocalIncidentRecord(
      detail: IncidentDetail.fromJson(payload as Map<String, dynamic>),
      syncState: IncidentSyncState.values.byName(row['sync_state']! as String),
      syncError: row['sync_error'] as String?,
    );
  }
}

/// In-memory storage is used by widget tests and the web shell.
/// Native mobile builds use SQLite for restart-safe reports.
class MemoryIncidentLocalStore implements IncidentLocalStore {
  final Map<UuidValue, LocalIncidentRecord> _records = {};

  @override
  Future<List<LocalIncidentRecord>> list(
    UuidValue organizationId, {
    int limit = 100,
  }) async {
    final records =
        _records.values
            .where((record) => record.organizationId == organizationId)
            .toList()
          ..sort(
            (a, b) => b.detail.incident.updatedAt.compareTo(
              a.detail.incident.updatedAt,
            ),
          );
    return records.take(limit).toList(growable: false);
  }

  @override
  Future<LocalIncidentRecord?> get(UuidValue incidentId) async =>
      _records[incidentId];

  @override
  Future<List<LocalIncidentRecord>> pending(UuidValue organizationId) async =>
      _records.values
          .where(
            (record) =>
                record.organizationId == organizationId &&
                record.syncState != IncidentSyncState.synced,
          )
          .toList(growable: false);

  @override
  Future<void> save(LocalIncidentRecord record) async {
    _records[record.incidentId] = record;
  }

  @override
  Future<void> close() async {}
}
