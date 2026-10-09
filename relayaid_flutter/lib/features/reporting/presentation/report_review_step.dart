import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/presentation/incident_labels.dart';

class ReportReviewStep extends StatelessWidget {
  const ReportReviewStep({
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.peopleAffected,
    required this.latitude,
    required this.longitude,
    required this.photoCount,
    super.key,
  });

  final String title;
  final String description;
  final IncidentType type;
  final IncidentSeverity severity;
  final String peopleAffected;
  final String latitude;
  final String longitude;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review your report', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space16),
        Text(title.trim(), style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space8),
        Text('${incidentTypeLabel(type)} · ${incidentSeverityLabel(severity)}'),
        const SizedBox(height: AppSpacing.space16),
        Text(description.trim()),
        const SizedBox(height: AppSpacing.space16),
        Text('People affected: ${peopleAffected.trim()}'),
        const SizedBox(height: AppSpacing.space16),
        Text('Location', style: theme.textTheme.labelLarge),
        Text(
          latitude.trim().isEmpty
              ? 'Not provided'
              : '${latitude.trim()}, ${longitude.trim()}',
        ),
        const SizedBox(height: AppSpacing.space16),
        Text('Photos: $photoCount'),
        const SizedBox(height: AppSpacing.space24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.save_outlined),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                kIsWeb
                    ? 'Keep this tab open until the report and photos synchronize. Unsent web data does not survive a reload.'
                    : 'Save now, even offline. Your report and photos stay on this device and synchronize when you reconnect.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
