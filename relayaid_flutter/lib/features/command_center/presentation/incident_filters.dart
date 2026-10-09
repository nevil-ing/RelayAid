import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_workspace.dart';
import '../../incidents/presentation/incident_labels.dart';
import '../application/command_center_controller.dart';

class IncidentFilters extends StatelessWidget {
  const IncidentFilters({required this.controller, super.key});
  final CommandCenterController controller;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scaledFilterWidth =
          AppWorkspace.filterWidth * MediaQuery.textScalerOf(context).scale(1);
      final stackFields =
          constraints.maxWidth < scaledFilterWidth * 2 + AppSpacing.space12;
      final searchWidth =
          stackFields || constraints.maxWidth < AppWorkspace.searchWidth
          ? constraints.maxWidth
          : AppWorkspace.searchWidth;
      final filterWidth =
          stackFields || constraints.maxWidth < scaledFilterWidth
          ? constraints.maxWidth
          : scaledFilterWidth;
      return Wrap(
        spacing: AppSpacing.space12,
        runSpacing: AppSpacing.space12,
        children: [
          SizedBox(
            width: searchWidth,
            child: TextFormField(
              key: const ValueKey('incident-search'),
              initialValue: controller.filter.query,
              decoration: const InputDecoration(
                labelText: 'Search reports',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.search,
            ),
          ),
          SizedBox(
            width: filterWidth,
            child: DropdownButtonFormField<String>(
              key: ValueKey('severity-${controller.filter.severity?.name}'),
              initialValue: controller.filter.severity?.name ?? 'all',
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Severity'),
              items: [
                const DropdownMenuItem(
                  value: 'all',
                  child: Text('All severities'),
                ),
                for (final severity in IncidentSeverity.values)
                  DropdownMenuItem(
                    value: severity.name,
                    child: Text(incidentSeverityLabel(severity)),
                  ),
              ],
              onChanged: (value) => controller.filterSeverity(
                value == 'all' || value == null
                    ? null
                    : IncidentSeverity.values.byName(value),
              ),
            ),
          ),
          SizedBox(
            width: filterWidth,
            child: DropdownButtonFormField<String>(
              key: ValueKey('status-${controller.filter.status?.name}'),
              initialValue: controller.filter.status?.name ?? 'all',
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(
                  value: 'all',
                  child: Text('All statuses'),
                ),
                for (final status in IncidentStatus.values)
                  DropdownMenuItem(
                    value: status.name,
                    child: Text(incidentStatusLabel(status)),
                  ),
              ],
              onChanged: (value) => controller.filterStatus(
                value == 'all' || value == null
                    ? null
                    : IncidentStatus.values.byName(value),
              ),
            ),
          ),
        ],
      );
    },
  );
}
