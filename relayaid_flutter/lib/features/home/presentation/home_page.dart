import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/connectivity/connectivity_provider.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_state_view.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../auth/application/access_controller.dart';
import '../../incidents/application/incident_controller.dart';
import '../../incidents/presentation/incident_list_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(incidentControllerProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(incidentControllerProvider);
    final access = ref.watch(accessControllerProvider);
    final online = ref.watch(connectivityControllerProvider).isOnline;
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space24,
          AppSpacing.space24,
          AppSpacing.space24,
          AppSpacing.space40,
        ),
        children: [
          Text(
            access.context?.organization.name ?? 'Field workspace',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.space16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Text(
                  online
                      ? 'Connected. Saved reports synchronize automatically.'
                      : 'Offline. Reports and photos can still be saved on this device.',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),
          AppButton(
            label: 'Report incident',
            icon: Icons.add,
            onPressed: () => context.go(AppRoutes.report),
          ),
          const SizedBox(height: AppSpacing.space8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go(AppRoutes.syncCenter),
              icon: const Icon(Icons.sync),
              label: const Text('View synchronization and photo queue'),
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          Text('Recent incidents', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.space12),
          if (controller.status == IncidentViewStatus.loading &&
              controller.incidents.isEmpty)
            const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading recent incidents',
              ),
            )
          else if (controller.incidents.isEmpty)
            AppStateView(
              state: controller.error == null
                  ? AppViewState.empty
                  : AppViewState.error,
              title: controller.error == null
                  ? 'No reports yet'
                  : 'Could not load reports',
              description:
                  controller.error ??
                  'Report what you see. Your saved incidents will appear here.',
            )
          else
            for (final incident in controller.incidents.take(5))
              IncidentListTile(
                incident: incident,
                syncState: controller.syncStateFor(incident.id),
                onTap: () =>
                    context.go('${AppRoutes.incidentDetail}?id=${incident.id}'),
              ),
          const SizedBox(height: AppSpacing.space12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.go(AppRoutes.incidents),
              child: const Text('View all incidents'),
            ),
          ),
        ],
      ),
    );
  }
}
