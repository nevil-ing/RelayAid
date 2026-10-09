import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/components/app_state_view.dart';
import '../../../design_system/tokens/app_motion.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/domain/incident_attention.dart';
import '../../incidents/presentation/incident_labels.dart';
import '../domain/incident_filter.dart';

class CommandIncidentList extends StatelessWidget {
  const CommandIncidentList({
    required this.incidents,
    required this.selectedId,
    required this.onSelect,
    super.key,
  });
  final List<Incident> incidents;
  final UuidValue? selectedId;
  final ValueChanged<UuidValue?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return const AppStateView(
        state: AppViewState.empty,
        title: 'No incidents in this view',
        description:
            'New reports appear here automatically. Check the filters if reports are hidden.',
      );
    }
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: incidents.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final incident = incidents[index];
        final selected = incident.id == selectedId;
        return Semantics(
          selected: selected,
          child: Material(
            animationDuration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppMotion.feedback,
            color: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
            child: ListTile(
              key: ValueKey('incident-row-${incident.id}'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space8,
              ),
              title: Text(incident.title, style: theme.textTheme.titleSmall),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    '${incidentTypeLabel(incident.type)} · ${incidentSeverityLabel(incident.severity)} · ${incidentStatusLabel(incident.status)}',
                  ),
                  if (!hasMapLocation(incident)) const Text('No map location'),
                  if (incident.needsCoordinatorAttention)
                    Text(
                      'Escalated · Needs coordinator attention',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelect(incident.id),
            ),
          ),
        );
      },
    );
  }
}
