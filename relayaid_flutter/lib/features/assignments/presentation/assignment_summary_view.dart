import 'package:flutter/material.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../domain/assignment_labels.dart';

class AssignmentSummaryView extends StatelessWidget {
  const AssignmentSummaryView({
    required this.assignment,
    required this.teamName,
    super.key,
  });
  final Assignment assignment;
  final String teamName;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(teamName, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.space4),
      Text(assignmentStatusLabel(assignment.status)),
      if (assignment.designatedResponderId != null) ...[
        const SizedBox(height: AppSpacing.space8),
        const Text('Designated responder'),
        SelectableText(assignment.designatedResponderId.toString()),
      ],
      if (assignment.acceptedBy != null) ...[
        const SizedBox(height: AppSpacing.space8),
        const Text('Accepted by'),
        SelectableText(assignment.acceptedBy.toString()),
      ],
    ],
  );
}
