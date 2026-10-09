import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../domain/incident_attention.dart';
import 'incident_labels.dart';

class IncidentEscalationNotice extends StatelessWidget {
  const IncidentEscalationNotice({required this.incident, super.key});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final time = incident.escalatedAt;
    if (time == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final needsAttention = incident.needsCoordinatorAttention;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            needsAttention ? Icons.priority_high : Icons.history,
            color: needsAttention
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  needsAttention
                      ? 'Needs coordinator attention'
                      : 'Previous escalation',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Escalated automatically · ${eventTime(time)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
