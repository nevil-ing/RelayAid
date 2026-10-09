import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/presentation/incident_labels.dart';
import '../../incidents/presentation/incident_timeline.dart';
import '../../media/presentation/incident_photos_section.dart';
import '../../media/application/media_providers.dart';
import '../application/assignment_controller.dart';
import 'assignment_summary_view.dart';

class ResponderAssignmentDetail extends ConsumerStatefulWidget {
  const ResponderAssignmentDetail({required this.controller, super.key});
  final AssignmentController controller;
  @override
  ConsumerState<ResponderAssignmentDetail> createState() =>
      _ResponderAssignmentDetailState();
}

class _ResponderAssignmentDetailState
    extends ConsumerState<ResponderAssignmentDetail> {
  final _note = TextEditingController();
  UuidValue? _incidentId;
  UuidValue? _photoEventId;
  @override
  void didUpdateWidget(ResponderAssignmentDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    final detail = widget.controller.selected;
    final incidentId = detail?.incident.id;
    final eventId = detail?.timeline
        .where((e) => e.eventType == IncidentEventType.attachmentAdded)
        .lastOrNull
        ?.id;
    final refresh =
        incidentId != null &&
        incidentId == _incidentId &&
        eventId != _photoEventId;
    _incidentId = incidentId;
    _photoEventId = eventId;
    if (refresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.selected?.incident.id == incidentId) {
          unawaited(
            ref.read(incidentPhotosProvider(incidentId)).load(refresh: true),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final detail = controller.selected;
    final assignment = detail?.assignment;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => controller.select(null),
          icon: const Icon(Icons.arrow_back),
          label: const Text('All assignments'),
        ),
        const SizedBox(height: AppSpacing.space16),
        if (controller.loading && detail == null)
          const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading assignment detail',
            ),
          ),
        if (detail != null && assignment != null) ...[
          Semantics(
            header: true,
            child: Text(
              detail.incident.title,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            '${incidentSeverityLabel(detail.incident.severity)} severity · ${incidentStatusLabel(detail.incident.status)}',
          ),
          const SizedBox(height: AppSpacing.space24),
          AssignmentSummaryView(
            assignment: assignment,
            teamName: detail.assignmentTeamName ?? 'Your team',
          ),
          const SizedBox(height: AppSpacing.space24),
          if (assignment.acceptedBy != null &&
              assignment.acceptedBy != controller.access.userId)
            const Text(
              'Another responder is leading this response. Only that responder can update it.',
            )
          else if (assignment.status == AssignmentStatus.pending)
            FilledButton.icon(
              key: const ValueKey('accept-assignment'),
              onPressed: controller.canAct ? controller.accept : null,
              icon: const Icon(Icons.check),
              label: Text(controller.busy ? 'Accepting…' : 'Accept assignment'),
            )
          else if (assignment.status == AssignmentStatus.accepted)
            FilledButton.icon(
              key: const ValueKey('start-response'),
              onPressed: controller.canAct ? controller.respond : null,
              icon: const Icon(Icons.near_me_outlined),
              label: Text(controller.busy ? 'Updating…' : 'Start responding'),
            )
          else if (assignment.status == AssignmentStatus.responding) ...[
            TextField(
              key: const ValueKey('resolution-note'),
              controller: _note,
              enabled: controller.canAct,
              minLines: 2,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Resolution note',
                hintText: 'What was done and what is the outcome?',
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            FilledButton.icon(
              key: const ValueKey('resolve-assignment'),
              onPressed: controller.canAct
                  ? () => controller.resolve(_note.text)
                  : null,
              icon: const Icon(Icons.task_alt),
              label: Text(controller.busy ? 'Resolving…' : 'Resolve incident'),
            ),
          ],
          if (!controller.canAct &&
              !controller.busy &&
              assignment.status != AssignmentStatus.resolved &&
              assignment.status != AssignmentStatus.cancelled &&
              (assignment.acceptedBy == null ||
                  assignment.acceptedBy == controller.access.userId)) ...[
            const SizedBox(height: AppSpacing.space8),
            const Text(
              'Reconnect before updating this response. Offline changes are not queued.',
            ),
          ],
          const SizedBox(height: AppSpacing.space24),
          const Divider(),
          const SizedBox(height: AppSpacing.space16),
          Text('Report', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.space8),
          Text(detail.incident.description),
          const SizedBox(height: AppSpacing.space12),
          Text('${detail.incident.peopleAffected} people affected'),
          if (detail.incident.latitude != null &&
              detail.incident.longitude != null)
            Text(
              'Location: ${detail.incident.latitude!.toStringAsFixed(5)}, ${detail.incident.longitude!.toStringAsFixed(5)}',
            ),
          const SizedBox(height: AppSpacing.space24),
          IncidentPhotosSection(incidentId: detail.incident.id!),
          const SizedBox(height: AppSpacing.space24),
          Text('Timeline', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.space12),
          IncidentTimeline(events: detail.timeline),
        ],
        if (controller.error != null) ...[
          const SizedBox(height: AppSpacing.space16),
          Text(
            controller.error!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          TextButton(
            onPressed: controller.reconnect,
            child: const Text('Reconnect and retry'),
          ),
        ],
      ],
    );
  }
}
