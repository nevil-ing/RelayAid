import 'dart:convert';

import 'package:relayaid_client/relayaid_client.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/storage/relayaid_local_database.dart';
import '../domain/access_context_cache.dart';

class SqliteAccessContextCache implements AccessContextCache {
  const SqliteAccessContextCache(this.database);

  final RelayAidLocalDatabase database;

  SqliteConnection get _connection => database.connection;

  @override
  Future<OrganizationContext?> read(UuidValue userId) async {
    final row = await _connection.getOptional(
      'SELECT payload FROM cached_organization_contexts WHERE user_id = ?',
      [userId.toString()],
    );
    if (row == null) return null;
    return OrganizationContext.fromJson(
      jsonDecode(row['payload']! as String) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> write(OrganizationContext context) async {
    final userId = context.membership.authUserId;
    await _connection.execute(
      'INSERT INTO cached_organization_contexts (user_id, payload) '
      'VALUES (?, ?) ON CONFLICT(user_id) DO UPDATE SET '
      'payload = excluded.payload',
      [userId.toString(), jsonEncode(context.toJson())],
    );
  }

  @override
  Future<void> remove(UuidValue userId) async {
    await _connection.execute(
      'DELETE FROM cached_organization_contexts WHERE user_id = ?',
      [userId.toString()],
    );
  }
}

class MemoryAccessContextCache implements AccessContextCache {
  final Map<UuidValue, OrganizationContext> _contexts = {};

  @override
  Future<OrganizationContext?> read(UuidValue userId) async =>
      _contexts[userId];

  @override
  Future<void> write(OrganizationContext context) async {
    _contexts[context.membership.authUserId] = context;
  }

  @override
  Future<void> remove(UuidValue userId) async {
    _contexts.remove(userId);
  }
}
