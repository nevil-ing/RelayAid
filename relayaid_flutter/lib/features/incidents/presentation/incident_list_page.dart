import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/app_state_view.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../app/router/app_router.dart';
import '../application/incident_controller.dart';
import 'incident_list_tile.dart';

class IncidentListPage extends ConsumerStatefulWidget {
  const IncidentListPage({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  ConsumerState<IncidentListPage> createState() => _IncidentListPageState();
}

class _IncidentListPageState extends ConsumerState<IncidentListPage> {
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
    final incidents = controller.incidents;
    final isLoading = controller.status == IncidentViewStatus.loading;
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.space24),
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            if (isLoading && incidents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.space32),
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Loading incidents',
                  ),
                ),
              )
            else if (controller.status == IncidentViewStatus.error &&
                incidents.isEmpty)
              AppStateView(
                state: AppViewState.error,
                title: 'Unable to load incidents',
                description: controller.error ?? 'Try again when connected.',
              )
            else if (incidents.isEmpty)
              const AppStateView(
                state: AppViewState.empty,
                title: 'No incidents yet',
                description:
                    'Reports created by this organization will appear here.',
              )
            else ...[
              for (final incident in incidents)
                IncidentListTile(
                  incident: incident,
                  syncState: controller.syncStateFor(incident.id),
                  onTap: () => context.go(
                    '${AppRoutes.incidentDetail}?id=${incident.id}',
                  ),
                ),
            ],
            if (controller.status == IncidentViewStatus.error &&
                incidents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space16),
                child: Text(
                  controller.error ?? 'Some updates could not be loaded.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
