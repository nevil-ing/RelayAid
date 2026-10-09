import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/connectivity/connectivity_provider.dart';
import '../../../core/connectivity/connectivity_status.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_state_view.dart';
import '../../../design_system/components/app_surface_card.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/application/incident_controller.dart';
import '../../incidents/domain/incident_sync_state.dart';
import '../../incidents/presentation/incident_badges.dart';
import '../../media/presentation/attachment_queue_section.dart';

class SyncCenterPage extends ConsumerStatefulWidget {
  const SyncCenterPage({super.key});

  @override
  ConsumerState<SyncCenterPage> createState() => _SyncCenterPageState();
}

class _SyncCenterPageState extends ConsumerState<SyncCenterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(incidentControllerProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityControllerProvider).status;
    final controller = ref.watch(incidentControllerProvider);
    final needsSync = controller.incidents
        .where((incident) {
          final state = controller.syncStateFor(incident.id);
          return state != IncidentSyncState.synced;
        })
        .toList(growable: false);
    final isOffline = connectivity == ConnectivityStatus.offline;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Text('Sync center', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'Reports stay on this device until the connection is available.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(switch (connectivity) {
                ConnectivityStatus.unavailable => 'Checking connection',
                ConnectivityStatus.connected => 'Connected',
                ConnectivityStatus.offline => 'Offline',
                ConnectivityStatus.syncing => 'Synchronizing reports',
              }, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.space8),
              Text(
                isOffline
                    ? 'New reports are saved locally and will retry when service returns.'
                    : '${needsSync.length} report${needsSync.length == 1 ? '' : 's'} waiting to synchronize.',
              ),
              const SizedBox(height: AppSpacing.space16),
              AppButton(
                label: isOffline ? 'Waiting for connection' : 'Sync now',
                icon: Icons.sync,
                onPressed: isOffline || needsSync.isEmpty
                    ? null
                    : () => ref.read(incidentControllerProvider).syncNow(),
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
        Text(
          'Reports on this device',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.space12),
        if (controller.status == IncidentViewStatus.loading &&
            controller.incidents.isEmpty)
          const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading local reports',
            ),
          )
        else if (needsSync.isEmpty)
          const AppStateView(
            state: AppViewState.empty,
            title: 'No reports waiting to sync',
            description: 'Saved reports remain available in Incidents.',
          )
        else
          for (final incident in controller.incidents)
            if (controller.syncStateFor(incident.id) !=
                IncidentSyncState.synced)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(incident.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.space4),
                  child: IncidentSyncBadge(
                    state: controller.syncStateFor(incident.id),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.go('${AppRoutes.incidentDetail}?id=${incident.id}'),
              ),
        const SizedBox(height: AppSpacing.space24),
        const AttachmentQueueSection(),
      ],
    );
  }
}
