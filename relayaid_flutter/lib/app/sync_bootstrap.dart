import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/incidents/application/incident_controller.dart';
import '../features/media/application/media_providers.dart';
import 'relayaid_app.dart';

/// Background queues start on app launch, not only when a detail page opens.
class SyncBootstrap extends ConsumerWidget {
  const SyncBootstrap({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(incidentSyncCoordinatorProvider);
    ref.watch(uploadCoordinatorProvider);
    return const RelayAidApp();
  }
}
