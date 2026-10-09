import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/components/app_status_badge.dart';
import '../domain/incident_sync_state.dart';
import 'incident_labels.dart';

class IncidentStatusBadge extends StatelessWidget {
  const IncidentStatusBadge({required this.status, super.key});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      IncidentStatus.reported => AppStatusTone.info,
      IncidentStatus.acknowledged => AppStatusTone.info,
      IncidentStatus.assigned => AppStatusTone.warning,
      IncidentStatus.responding => AppStatusTone.warning,
      IncidentStatus.resolved => AppStatusTone.success,
      IncidentStatus.cancelled => AppStatusTone.neutral,
    };
    return AppStatusBadge(label: incidentStatusLabel(status), tone: tone);
  }
}

class IncidentSeverityBadge extends StatelessWidget {
  const IncidentSeverityBadge({required this.severity, super.key});

  final IncidentSeverity severity;

  @override
  Widget build(BuildContext context) {
    final tone = switch (severity) {
      IncidentSeverity.low => AppStatusTone.neutral,
      IncidentSeverity.moderate => AppStatusTone.info,
      IncidentSeverity.high => AppStatusTone.warning,
      IncidentSeverity.critical => AppStatusTone.danger,
    };
    return AppStatusBadge(label: incidentSeverityLabel(severity), tone: tone);
  }
}

class IncidentSyncBadge extends StatelessWidget {
  const IncidentSyncBadge({required this.state, super.key});

  final IncidentSyncState state;

  @override
  Widget build(BuildContext context) {
    final presentation = switch (state) {
      IncidentSyncState.offline => (
        label: 'Saved on device',
        tone: AppStatusTone.warning,
        icon: Icons.cloud_off_outlined,
      ),
      IncidentSyncState.pending => (
        label: 'Waiting to sync',
        tone: AppStatusTone.info,
        icon: Icons.schedule,
      ),
      IncidentSyncState.syncing => (
        label: 'Syncing',
        tone: AppStatusTone.info,
        icon: Icons.sync,
      ),
      IncidentSyncState.synced => (
        label: 'Synchronized',
        tone: AppStatusTone.success,
        icon: Icons.cloud_done_outlined,
      ),
      IncidentSyncState.failed => (
        label: 'Sync failed · retry available',
        tone: AppStatusTone.danger,
        icon: Icons.sync_problem_outlined,
      ),
    };
    return AppStatusBadge(
      label: presentation.label,
      tone: presentation.tone,
      icon: presentation.icon,
    );
  }
}
