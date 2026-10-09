import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../app/router/app_router.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../assignments/domain/assignment_labels.dart';
import '../../assignments/presentation/assignment_summary_view.dart';
import '../application/command_center_controller.dart';

class AssignTeamSection extends StatefulWidget {
  const AssignTeamSection({required this.controller, super.key});
  final CommandCenterController controller;
  @override
  State<AssignTeamSection> createState() => _AssignTeamSectionState();
}

class _AssignTeamSectionState extends State<AssignTeamSection> {
  UuidValue? _teamId;
  UuidValue? _responderId;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final detail = controller.selected!;
    final assignment = detail.assignment;
    final enabled =
        controller.status == LiveFeedStatus.live && !controller.updating;
    if (assignment != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssignmentSummaryView(
            assignment: assignment,
            teamName: detail.assignmentTeamName ?? 'Assigned team',
          ),
          if (assignmentIsActive(assignment.status)) ...[
            const SizedBox(height: AppSpacing.space8),
            TextButton(
              onPressed: enabled ? _confirmCancel : null,
              child: const Text('Cancel incident and assignment'),
            ),
          ],
        ],
      );
    }
    if (detail.incident.status != IncidentStatus.reported &&
        detail.incident.status != IncidentStatus.acknowledged) {
      if (detail.incident.status == IncidentStatus.assigned ||
          detail.incident.status == IncidentStatus.responding) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This older status has no linked assignment. Create a new report to use the response workflow.',
            ),
            TextButton(
              onPressed: enabled ? _confirmCancel : null,
              child: const Text('Cancel legacy incident'),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }
    final teams = controller.teams
        .where((roster) => roster.responders.isNotEmpty)
        .toList();
    final selected = teams
        .where((roster) => roster.team.id == _teamId)
        .firstOrNull;
    final responderId =
        selected?.responders.any((m) => m.authUserId == _responderId) == true
        ? _responderId
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign a response',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.space12),
        if (teams.isEmpty) ...[
          const Text('Add a responder to a team before assigning this report.'),
          TextButton(
            onPressed: () => context.go(AppRoutes.teams),
            child: const Text('Manage teams'),
          ),
        ] else ...[
          DropdownButtonFormField<UuidValue>(
            key: ValueKey(
              selected == null && _teamId != null
                  ? 'assignment-team-cleared'
                  : 'assignment-team',
            ),
            initialValue: selected?.team.id,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Response team'),
            items: [
              for (final roster in teams)
                DropdownMenuItem(
                  value: roster.team.id,
                  child: Text(
                    '${roster.team.name} · ${roster.activeAssignments} active',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: !enabled
                ? null
                : (id) => setState(() {
                    _teamId = id;
                    _responderId = null;
                  }),
          ),
          if (selected != null) ...[
            const SizedBox(height: AppSpacing.space12),
            DropdownButtonFormField<UuidValue>(
              key: ValueKey(
                'assignment-responder-${selected.team.id}-${_responderId != null && responderId == null ? 'cleared' : 'current'}',
              ),
              initialValue: responderId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Responder (optional)',
              ),
              hint: const Text('Any responder on this team'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Any responder on this team'),
                ),
                for (final responder in selected.responders)
                  DropdownMenuItem(
                    value: responder.authUserId,
                    child: Text(responderLabel(responder.authUserId)),
                  ),
              ],
              onChanged: !enabled
                  ? null
                  : (id) => setState(() => _responderId = id),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              responderId == null
                  ? 'The first team responder to accept will lead this response.'
                  : 'Only the selected team responder can accept this assignment.',
            ),
          ],
          const SizedBox(height: AppSpacing.space16),
          FilledButton.icon(
            key: const ValueKey('assign-team-submit'),
            onPressed: enabled && selected != null
                ? () => controller.assign(
                    selected.team.id!,
                    responderId: responderId,
                  )
                : null,
            icon: const Icon(Icons.group_add_outlined),
            label: Text(controller.updating ? 'Assigning…' : 'Assign team'),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this incident?'),
        content: const Text(
          'The team will see a cancelled assignment. Its history will remain in the timeline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep incident'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel incident'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.controller.cancelAssignment();
    }
  }
}
