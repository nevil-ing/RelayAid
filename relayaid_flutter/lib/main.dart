import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'app/sync_bootstrap.dart';
import 'app/startup_page.dart';
import 'core/network/backend_configuration.dart';
import 'core/storage/relayaid_local_database.dart';
import 'features/auth/application/access_controller.dart';
import 'features/auth/application/client_provider.dart';
import 'features/auth/data/local_access_context_cache.dart';
import 'features/auth/data/serverpod_auth_gateway.dart';
import 'features/incidents/application/incident_controller.dart';
import 'features/incidents/data/incident_local_store.dart';
import 'features/media/application/media_providers.dart';
import 'features/media/data/attachment_local_store.dart';
import 'features/media/data/photo_file_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RelayAidStartup(initialize: initializeApplication));
}

Future<Widget> initializeApplication() async {
  final address = BackendConfiguration.validate(
    await getServerUrl(),
    release: kReleaseMode,
  );
  final client = Client(address)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager()
    ..cookieAuth = kIsWeb;
  RelayAidLocalDatabase? localDatabase;
  AccessController? access;
  final gateway = ServerpodAuthGateway(client);
  try {
    localDatabase = kIsWeb ? null : await RelayAidLocalDatabase.open();
    final contextCache = localDatabase == null
        ? MemoryAccessContextCache()
        : SqliteAccessContextCache(localDatabase);
    final localStore = localDatabase == null
        ? MemoryIncidentLocalStore()
        : SqliteIncidentLocalStore(localDatabase);
    final attachmentStore = localDatabase == null
        ? MemoryAttachmentLocalStore()
        : SqliteAttachmentLocalStore(localDatabase);
    final photoFiles = await createPhotoFileStore();
    access = AccessController(gateway, contextCache: contextCache);
    await access.initialize();
    return ProviderScope(
      overrides: [
        serverpodClientProvider.overrideWithValue(client),
        accessControllerProvider.overrideWithValue(access),
        incidentLocalStoreProvider.overrideWithValue(localStore),
        attachmentLocalStoreProvider.overrideWithValue(attachmentStore),
        photoFileStoreProvider.overrideWithValue(photoFiles),
      ],
      child: const SyncBootstrap(),
    );
  } catch (_) {
    access?.dispose();
    gateway.dispose();
    client.close();
    await localDatabase?.close();
    rethrow;
  }
}
