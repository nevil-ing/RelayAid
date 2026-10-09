import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/presentation/incident_labels.dart';
import '../../incidents/presentation/incident_escalation_notice.dart';
import '../../incidents/presentation/incident_timeline.dart';
import '../../media/application/media_providers.dart';
import '../../media/presentation/incident_photos_section.dart';
import '../application/command_center_controller.dart';
import 'assign_team_section.dart';

class CommandIncidentDetail extends ConsumerStatefulWidget {
  const CommandIncidentDetail({
    required this.controller,
    this.scrollable = true,
    super.key,
  });

  final CommandCenterController controller;
  final bool scrollable;

  @override
  ConsumerState<CommandIncidentDetail> createState() =>
      _CommandIncidentDetailState();
}

class _CommandIncidentDetailState extends ConsumerState<CommandIncidentDetail> {
  UuidValue? _photoEventId;
  UuidValue? _incidentId;

  @override
  void initState() {
    super.initState();
    _refreshPhotosIfChanged();
  }

  @override
  void didUpdateWidget(CommandIncidentDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshPhotosIfChanged();
  }

  void _refreshPhotosIfChanged() {
    final detail = widget.controller.selected;
    final id = detail?.incident.id;
    final photos = detail?.timeline.where(
      (event) => event.eventType == IncidentEventType.attachmentAdded,
    );
    final eventId = photos?.lastOrNull?.id;
    final needsRefresh = id == _incidentId && eventId != _photoEventId;
    _incidentId = id;
    _photoEventId = eventId;
    if (!needsRefresh || id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.selectedId == id) {
        unawaited(ref.read(incidentPhotosProvider(id)).load(refresh: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final detail = controller.selected;
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Incident detail',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Close incident detail',
                onPressed: () => controller.select(null),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (controller.loadingDetail && detail == null)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.space24),
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading incident detail',
                ),
              ),
            ),
          if (detail != null) ...[
            Semantics(
              header: true,
              child: Text(
                detail.incident.title,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              '${incidentSeverityLabel(detail.incident.severity)} severity · ${incidentStatusLabel(detail.incident.status)}',
              style: theme.textTheme.titleSmall,
            ),
            IncidentEscalationNotice(incident: detail.incident),
            const SizedBox(height: AppSpacing.space24),
            Text(detail.incident.description),
            const SizedBox(height: AppSpacing.space24),
            _Fact(
              label: 'Type',
              value: incidentTypeLabel(detail.incident.type),
            ),
            _Fact(
              label: 'People affected',
              value: '${detail.incident.peopleAffected}',
            ),
            _Fact(
              label: 'Reported',
              value: eventTime(detail.incident.reportedAt),
            ),
            _Fact(
              label: 'Coordinates',
              value:
                  detail.incident.latitude == null ||
                      detail.incident.longitude == null
                  ? 'Not provided'
                  : '${detail.incident.latitude!.toStringAsFixed(5)}, ${detail.incident.longitude!.toStringAsFixed(5)}',
            ),
            if (detail.incident.status == IncidentStatus.reported) ...[
              const SizedBox(height: AppSpacing.space16),
              FilledButton.icon(
                key: const ValueKey('acknowledge-incident'),
                onPressed:
                    controller.status != LiveFeedStatus.live ||
                        controller.updating
                    ? null
                    : controller.acknowledge,
                icon: const Icon(Icons.check),
                label: Text(
                  controller.updating ? 'Acknowledging…' : 'Acknowledge report',
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space24),
            AssignTeamSection(
              key: ValueKey(detail.incident.id),
              controller: controller,
            ),
            const SizedBox(height: AppSpacing.space24),
            const Divider(),
            const SizedBox(height: AppSpacing.space16),
            IncidentPhotosSection(incidentId: detail.incident.id!),
            const SizedBox(height: AppSpacing.space24),
            Text('Timeline', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space12),
            IncidentTimeline(events: detail.timeline),
          ],
          if (controller.detailError != null) ...[
            const SizedBox(height: AppSpacing.space16),
            Text(
              controller.detailError!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            TextButton(
              onPressed: controller.reconnect,
              child: const Text('Reconnect and retry'),
            ),
          ],
        ],
      ),
    );
    return widget.scrollable ? SingleChildScrollView(child: content) : content;
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(value),
      ],
    ),
  );
}
