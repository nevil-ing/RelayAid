import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import 'incident_labels.dart';

class IncidentTimeline extends StatelessWidget {
  const IncidentTimeline({required this.events, super.key});
  final List<IncidentEvent> events;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final event in events.reversed)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activityLabel(event),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                eventTime(event.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (event.note?.isNotEmpty ?? false) Text(event.note!),
              Text(
                event.eventType == IncidentEventType.escalated
                    ? 'By RelayAid scheduler'
                    : event.actorId == null
                    ? 'Actor unavailable'
                    : 'By ${event.actorId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
    ],
  );
}
