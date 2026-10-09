import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

/// Opens RelayAid's on-device SQLite database and applies its schema changes.
class RelayAidLocalDatabase {
  RelayAidLocalDatabase._(this.connection);

  final SqliteDatabase connection;

  static Future<RelayAidLocalDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    return openAt(path.join(directory.path, 'relayaid.sqlite'));
  }

  static Future<RelayAidLocalDatabase> openAt(String filePath) async {
    final database = SqliteDatabase(path: filePath);
    try {
      await database.initialize();
      await _migrations.migrate(database);
      return RelayAidLocalDatabase._(database);
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  Future<void> close() => connection.close();

  static final _migrations = SqliteMigrations()
    ..add(
      SqliteMigration(1, (transaction) async {
        await transaction.execute('''
          CREATE TABLE incident_records (
            id TEXT PRIMARY KEY NOT NULL,
            organization_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            sync_state TEXT NOT NULL,
            sync_error TEXT,
            updated_at INTEGER NOT NULL
          )
        ''');
        await transaction.execute(
          'CREATE INDEX incident_records_org_updated '
          'ON incident_records (organization_id, updated_at DESC)',
        );
        await transaction.execute(
          'CREATE INDEX incident_records_sync_state '
          'ON incident_records (organization_id, sync_state)',
        );
      }),
    )
    ..add(
      SqliteMigration(2, (transaction) async {
        await transaction.execute('''
          CREATE TABLE cached_organization_contexts (
            user_id TEXT PRIMARY KEY NOT NULL,
            payload TEXT NOT NULL
          )
        ''');
      }),
    )
    ..add(
      SqliteMigration(3, (transaction) async {
        await transaction.execute('''
          CREATE TABLE attachment_records (
            id TEXT PRIMARY KEY NOT NULL,
            organization_id TEXT NOT NULL,
            incident_id TEXT NOT NULL,
            payload TEXT NOT NULL
          )
        ''');
        await transaction.execute(
          'CREATE INDEX attachment_records_org_incident '
          'ON attachment_records (organization_id, incident_id)',
        );
        await transaction.execute('''
          CREATE TABLE photo_capture_requests (
            user_id TEXT PRIMARY KEY NOT NULL,
            payload TEXT NOT NULL
          )
        ''');
      }),
    );
}
