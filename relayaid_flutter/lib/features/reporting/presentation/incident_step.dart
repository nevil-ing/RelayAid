import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/presentation/incident_labels.dart';
import '../domain/report_validation.dart';

class IncidentStep extends StatelessWidget {
  const IncidentStep({
    required this.title,
    required this.description,
    required this.peopleAffected,
    required this.type,
    required this.severity,
    required this.onTypeChanged,
    required this.onSeverityChanged,
    super.key,
  });

  final TextEditingController title;
  final TextEditingController description;
  final TextEditingController peopleAffected;
  final IncidentType type;
  final IncidentSeverity severity;
  final ValueChanged<IncidentType> onTypeChanged;
  final ValueChanged<IncidentSeverity> onSeverityChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: title,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'e.g. Flooded bridge near the market',
          ),
          validator: ReportValidation.title,
        ),
        const SizedBox(height: AppSpacing.space16),
        DropdownButtonFormField<IncidentType>(
          initialValue: type,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Incident type'),
          items: [
            for (final value in IncidentType.values)
              DropdownMenuItem(
                value: value,
                child: Text(incidentTypeLabel(value)),
              ),
          ],
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
        ),
        const SizedBox(height: AppSpacing.space16),
        DropdownButtonFormField<IncidentSeverity>(
          initialValue: severity,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Severity'),
          items: [
            for (final value in IncidentSeverity.values)
              DropdownMenuItem(
                value: value,
                child: Text(incidentSeverityLabel(value)),
              ),
          ],
          onChanged: (value) {
            if (value != null) onSeverityChanged(value);
          },
        ),
        const SizedBox(height: AppSpacing.space16),
        TextFormField(
          controller: description,
          minLines: 3,
          maxLines: 6,
          maxLength: 5000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'What happened?',
            hintText: 'Describe the situation and immediate risks.',
          ),
          validator: ReportValidation.description,
        ),
        const SizedBox(height: AppSpacing.space16),
        TextFormField(
          controller: peopleAffected,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'People affected'),
          validator: ReportValidation.peopleAffected,
        ),
      ],
    );
  }
}
