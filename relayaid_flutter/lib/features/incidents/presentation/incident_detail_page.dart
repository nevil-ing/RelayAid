import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_state_view.dart';
import '../../../design_system/components/app_surface_card.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../auth/application/access_controller.dart';
import '../application/incident_controller.dart';
import '../../media/application/media_providers.dart';
import '../../media/presentation/incident_photos_section.dart';
import 'incident_badges.dart';
import 'incident_labels.dart';
import 'incident_escalation_notice.dart';
import 'incident_timeline.dart';
import '../../assignments/presentation/assignment_summary_view.dart';

class IncidentDetailPage extends ConsumerStatefulWidget {
  const IncidentDetailPage({required this.incidentId, super.key});

  final UuidValue incidentId;

  @override
  ConsumerState<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends ConsumerState<IncidentDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(incidentControllerProvider).loadDetail(widget.incidentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(incidentControllerProvider);
    final detail = controller.selected;
    if (detail == null) {
      if (controller.status == IncidentViewStatus.error) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.space24),
          children: [
            AppStateView(
              state: AppViewState.error,
              title: 'Unable to load incident',
              description: controller.error ?? 'Try again when connected.',
            ),
            const SizedBox(height: AppSpacing.space16),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: () => ref
                    .read(incidentControllerProvider)
                    .loadDetail(widget.incidentId),
              ),
            ),
          ],
        );
      }
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading incident'),
      );
    }

    final incident = detail.incident;
    final access = ref.watch(accessControllerProvider);
    final canTransition = access.isCoordinator;
    final nextStatuses = _nextStatuses(incident.status);
    final isSubmitting = controller.status == IncidentViewStatus.submitting;
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(incidentControllerProvider)
            .loadDetail(widget.incidentId);
        await ref
            .read(incidentPhotosProvider(widget.incidentId))
            .load(refresh: true);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.space24),
        children: [
          Text(
            incident.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.space12),
          Wrap(
            spacing: AppSpacing.space8,
            runSpacing: AppSpacing.space8,
            children: [
              IncidentStatusBadge(status: incident.status),
              IncidentSeverityBadge(severity: incident.severity),
              IncidentSyncBadge(state: controller.syncStateFor(incident.id)),
            ],
          ),
          IncidentEscalationNotice(incident: incident),
          const SizedBox(height: AppSpacing.space24),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.space12),
                _DetailRow(
                  label: 'Type',
                  value: incidentTypeLabel(incident.type),
                ),
                _DetailRow(
                  label: 'People affected',
                  value: '${incident.peopleAffected}',
                ),
                _DetailRow(
                  label: 'Reported',
                  value: _formatDateTime(incident.reportedAt),
                ),
                if (incident.latitude != null && incident.longitude != null)
                  _DetailRow(
                    label: 'Location',
                    value:
                        '${incident.latitude!.toStringAsFixed(5)}, ${incident.longitude!.toStringAsFixed(5)}',
                  )
                else
                  const _DetailRow(
                    label: 'Location',
                    value: 'No coordinates provided',
                  ),
                const SizedBox(height: AppSpacing.space12),
                Text(incident.description),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          if (detail.assignment != null) ...[
            AssignmentSummaryView(
              assignment: detail.assignment!,
              teamName: detail.assignmentTeamName ?? 'Assigned team',
            ),
            const SizedBox(height: AppSpacing.space24),
          ],
          IncidentPhotosSection(incidentId: incident.id!),
          if (canTransition && nextStatuses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space24),
            Text(
              'Update status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.space12),
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                for (final nextStatus in nextStatuses)
                  AppButton(
                    label: incidentStatusLabel(nextStatus),
                    onPressed: isSubmitting
                        ? null
                        : () => _transition(nextStatus),
                    variant: nextStatus == IncidentStatus.cancelled
                        ? AppButtonVariant.secondary
                        : AppButtonVariant.primary,
                  ),
              ],
            ),
          ],
          if (controller.status == IncidentViewStatus.error &&
              controller.error != null) ...[
            const SizedBox(height: AppSpacing.space16),
            Text(
              controller.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.space32),
          Text('Timeline', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.space12),
          AppSurfaceCard(child: IncidentTimeline(events: detail.timeline)),
        ],
      ),
    );
  }

  Future<void> _transition(IncidentStatus nextStatus) async {
    await ref
        .read(incidentControllerProvider)
        .transition(widget.incidentId, nextStatus);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

List<IncidentStatus> _nextStatuses(IncidentStatus status) => switch (status) {
  IncidentStatus.reported => [
    IncidentStatus.acknowledged,
    IncidentStatus.cancelled,
  ],
  IncidentStatus.acknowledged ||
  IncidentStatus.assigned ||
  IncidentStatus.responding => [IncidentStatus.cancelled],
  IncidentStatus.resolved || IncidentStatus.cancelled => const [],
};

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} ${local.hour}:$minute';
}
