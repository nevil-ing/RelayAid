import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../domain/incident_sync_state.dart';
import 'incident_badges.dart';
import 'incident_labels.dart';

class IncidentListTile extends StatelessWidget {
  const IncidentListTile({
    required this.incident,
    required this.syncState,
    required this.onTap,
    super.key,
  });

  final Incident incident;
  final IncidentSyncState syncState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = incident.reportedAt.toLocal();
    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space8,
            ),
            title: Text(incident.title, style: theme.textTheme.titleMedium),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${incidentTypeLabel(incident.type)} · ${time.day}/${time.month}/${time.year}',
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Wrap(
                    spacing: AppSpacing.space8,
                    runSpacing: AppSpacing.space8,
                    children: [
                      IncidentSyncBadge(state: syncState),
                      IncidentStatusBadge(status: incident.status),
                      IncidentSeverityBadge(severity: incident.severity),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
