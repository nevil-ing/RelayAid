import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/live_feed_status.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../shared/presentation/live_feed_status_view.dart';
import '../../incidents/presentation/incident_labels.dart';
import '../application/assignment_providers.dart';
import '../domain/assignment_labels.dart';
import 'responder_assignment_detail.dart';

class AssignmentInboxPage extends ConsumerWidget {
  const AssignmentInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(assignmentControllerProvider);
    return ListView(
      key: ValueKey(controller.selectedId ?? 'assignment-inbox'),
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Your assignments',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        LiveFeedStatusView(
          status: controller.status,
          onReconnect: controller.reconnect,
        ),
        const SizedBox(height: AppSpacing.space24),
        if (controller.selectedId != null)
          ResponderAssignmentDetail(controller: controller)
        else if (controller.feed == null)
          controller.status == LiveFeedStatus.connecting
              ? const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Loading assignments',
                  ),
                )
              : const Text(
                  'Connect with your responder account to load assignments. An administrator must add you to the organization and team first.',
                )
        else if (controller.assignments.isEmpty)
          const Text(
            'No assignments yet. Reports assigned to your teams will appear here automatically.',
          )
        else ...[
          for (final active in [true, false])
            if (controller.assignments.any(
              (item) => assignmentIsActive(item.assignment.status) == active,
            )) ...[
              Text(
                active ? 'Active response' : 'Recent history',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.space8),
              for (final item in controller.assignments.where(
                (item) => assignmentIsActive(item.assignment.status) == active,
              )) ...[
                ListTile(
                  key: ValueKey('assignment-${item.assignment.id}'),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space8,
                  ),
                  title: Text(item.incident.title),
                  subtitle: Text(
                    '${item.teamName} · ${incidentSeverityLabel(item.incident.severity)} severity\n${assignmentStatusLabel(item.assignment.status)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => controller.select(item.assignment.id),
                ),
                const Divider(),
              ],
              const SizedBox(height: AppSpacing.space24),
            ],
        ],
        if (controller.feed?.hasMoreAssignments ?? false)
          const Text(
            'Showing up to 200 active assignments and 50 recent completed or cancelled responses.',
          ),
      ],
    );
  }
}
