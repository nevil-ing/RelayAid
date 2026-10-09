import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/presentation/incident_labels.dart';

export '../../incidents/presentation/incident_labels.dart'
    show activityLabel, eventTime;

class IncidentActivityList extends StatelessWidget {
  const IncidentActivityList({
    required this.activity,
    required this.onSelect,
    super.key,
  });
  final List<IncidentActivity> activity;
  final ValueChanged<UuidValue?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.space16),
        child: Text(
          'No activity yet. Reports, status changes and photo uploads will appear here.',
        ),
      );
    }
    return ListView.separated(
      itemCount: activity.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = activity[index];
        return ListTile(
          key: ValueKey('activity-${item.event.id}'),
          contentPadding: const EdgeInsets.all(AppSpacing.space16),
          title: Text(item.incidentTitle),
          subtitle: Text(
            '${activityLabel(item.event)}\n${eventTime(item.event.createdAt)}',
          ),
          isThreeLine: true,
          onTap: () => onSelect(item.event.incidentId),
        );
      },
    );
  }
}
