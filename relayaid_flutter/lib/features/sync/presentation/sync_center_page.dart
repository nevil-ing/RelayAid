import 'package:flutter/foundation.dart';
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
import '../../../shared/presentation/connection_help.dart';
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
    final connection = ref.watch(connectivityControllerProvider);
    final connectivity = connection.status;
    final controller = ref.watch(incidentControllerProvider);
    final needsSync = controller.incidents
        .where((incident) {
          final state = controller.syncStateFor(incident.id);
          return state != IncidentSyncState.synced;
        })
        .toList(growable: false);
    final isOffline = !connection.isOnline;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Text('Sync center', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.space8),
        Text(
          kIsWeb
              ? 'Keep this tab open until reports and photos synchronize. Unsent reports do not survive a reload.'
              : 'Reports and photos remain on this device after you close the app. They synchronize when a connection is available.',
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
                ConnectivityStatus.unavailable => 'Connection unavailable',
                ConnectivityStatus.connected => 'Connected',
                ConnectivityStatus.offline => 'Offline',
                ConnectivityStatus.syncing => 'Synchronizing reports',
              }, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.space8),
              Text(
                '${needsSync.length} report${needsSync.length == 1 ? '' : 's'} waiting to synchronize.',
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
        if (isOffline) ...[
          const SizedBox(height: AppSpacing.space16),
          const ConnectionHelp(),
        ],
        const SizedBox(height: AppSpacing.space24),
        Text(
          kIsWeb ? 'Reports in this tab' : 'Reports on this device',
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
        else if (controller.incidents.isEmpty)
          const AppStateView(
            state: AppViewState.empty,
            title: 'No saved reports yet',
            description:
                'Use Report incident to create your first report, even without a connection.',
          )
        else
          for (final incident in controller.incidents)
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
