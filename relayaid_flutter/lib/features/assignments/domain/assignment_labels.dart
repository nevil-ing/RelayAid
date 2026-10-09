import 'package:relayaid_client/relayaid_client.dart';

String assignmentStatusLabel(AssignmentStatus status) => switch (status) {
  AssignmentStatus.pending => 'Awaiting acceptance',
  AssignmentStatus.accepted => 'Accepted',
  AssignmentStatus.responding => 'Responding',
  AssignmentStatus.resolved => 'Resolved',
  AssignmentStatus.cancelled => 'Cancelled',
};

bool assignmentIsActive(AssignmentStatus status) =>
    status != AssignmentStatus.resolved && status != AssignmentStatus.cancelled;

String responderLabel(UuidValue id) =>
    'Responder ${id.toString().substring(24)}';
