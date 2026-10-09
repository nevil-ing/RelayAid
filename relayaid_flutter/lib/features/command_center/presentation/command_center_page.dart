import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_workspace.dart';
import '../application/command_center_controller.dart';
import '../application/command_center_providers.dart';
import 'command_incident_detail.dart';
import 'command_incident_list.dart';
import 'incident_activity_list.dart';
import 'incident_filters.dart';
import 'incident_map.dart';
import '../../../shared/presentation/live_feed_status_view.dart';

enum CommandCenterView { overview, incidents, map, activity }

class CommandCenterPage extends ConsumerWidget {
  const CommandCenterPage({this.view = CommandCenterView.overview, super.key});
  final CommandCenterView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(commandCenterControllerProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= AppWorkspace.splitWidth &&
            constraints.maxHeight >= AppWorkspace.minimumWorkspaceHeight;
        final header = _header(context, controller);
        if (!wide) {
          return ListView(
            key: ValueKey(controller.selectedId ?? 'command-workspace'),
            children: [
              header,
              const Divider(height: 1),
              if (controller.selectedId != null)
                CommandIncidentDetail(controller: controller, scrollable: false)
              else ...[
                if (view == CommandCenterView.overview ||
                    view == CommandCenterView.map)
                  SizedBox(
                    height: AppWorkspace.compactMapHeight,
                    child: _map(controller),
                  ),
                if (view == CommandCenterView.overview ||
                    view == CommandCenterView.incidents)
                  SizedBox(
                    height: AppWorkspace.compactListHeight,
                    child: _incidents(context, controller),
                  ),
                if (view == CommandCenterView.overview ||
                    view == CommandCenterView.activity)
                  SizedBox(
                    height: AppWorkspace.compactListHeight,
                    child: _activity(context, controller),
                  ),
              ],
            ],
          );
        }
        return Column(
          children: [
            header,
            const Divider(height: 1),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: switch (view) {
                      CommandCenterView.overview => Column(
                        children: [
                          Expanded(flex: 3, child: _map(controller)),
                          const Divider(height: 1),
                          Expanded(
                            flex: 2,
                            child: _incidents(context, controller),
                          ),
                        ],
                      ),
                      CommandCenterView.incidents => _incidents(
                        context,
                        controller,
                      ),
                      CommandCenterView.map => _map(controller),
                      CommandCenterView.activity => _activity(
                        context,
                        controller,
                      ),
                    },
                  ),
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: AppWorkspace.inspectorWidth,
                    child: controller.selectedId != null
                        ? CommandIncidentDetail(controller: controller)
                        : view == CommandCenterView.activity
                        ? const Padding(
                            padding: EdgeInsets.all(AppSpacing.space24),
                            child: Text(
                              'Select an activity entry to inspect its incident and timeline.',
                            ),
                          )
                        : _activity(context, controller),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context, CommandCenterController controller) {
    final title = switch (view) {
      CommandCenterView.overview => 'Command center',
      CommandCenterView.incidents => 'Incidents',
      CommandCenterView.map => 'Incident map',
      CommandCenterView.activity => 'Activity',
    };
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          LiveFeedStatusView(
            status: controller.status,
            onReconnect: controller.reconnect,
          ),
          if (view != CommandCenterView.activity) ...[
            const SizedBox(height: AppSpacing.space16),
            IncidentFilters(controller: controller),
          ],
          if (controller.feed?.hasMoreIncidents ?? false) ...[
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Showing ${controller.feed!.incidents.length} reports, prioritizing outstanding escalations. Filters apply to these reports.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _map(CommandCenterController controller) => IncidentMap(
    incidents: controller.visibleIncidents,
    selectedId: controller.selectedId,
    onSelect: controller.select,
  );

  Widget _incidents(BuildContext context, CommandCenterController controller) =>
      _Section(
        title: 'Reports · ${controller.visibleIncidents.length}',
        child: controller.feed == null
            ? _waiting(controller)
            : CommandIncidentList(
                incidents: controller.visibleIncidents,
                selectedId: controller.selectedId,
                onSelect: controller.select,
              ),
      );

  Widget _activity(BuildContext context, CommandCenterController controller) =>
      _Section(
        title: 'Recent activity',
        child: controller.feed == null
            ? _waiting(controller)
            : IncidentActivityList(
                activity: controller.activity,
                onSelect: controller.select,
              ),
      );

  Widget _waiting(CommandCenterController controller) => Padding(
    padding: const EdgeInsets.all(AppSpacing.space24),
    child: controller.status == LiveFeedStatus.connecting
        ? const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Connecting to incident feed',
            ),
          )
        : Text(
            controller.status == LiveFeedStatus.accessDenied
                ? 'Your account needs coordinator access to this organization.'
                : 'Waiting for a connection. Reports will appear when the live feed reconnects.',
          ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      const Divider(height: 1),
      Expanded(child: child),
    ],
  );
}
