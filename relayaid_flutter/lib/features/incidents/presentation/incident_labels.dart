import 'package:relayaid_client/relayaid_client.dart';

String activityLabel(IncidentEvent event) => switch (event.eventType) {
  IncidentEventType.created => 'Incident reported',
  IncidentEventType.attachmentAdded => 'Photo uploaded',
  IncidentEventType.statusChanged =>
    'Status changed to ${incidentStatusLabel(event.toStatus!)}',
  IncidentEventType.assignmentCreated => 'Team assigned',
  IncidentEventType.assignmentAccepted => 'Assignment accepted',
  IncidentEventType.responseStarted => 'Response started',
  IncidentEventType.assignmentResolved => 'Incident resolved',
  IncidentEventType.assignmentCancelled => 'Assignment cancelled',
  IncidentEventType.escalated => 'Escalated automatically',
};

String eventTime(DateTime time) {
  final local = time.toLocal();
  return '${local.day}/${local.month} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String incidentTypeLabel(IncidentType type) => switch (type) {
  IncidentType.flooding => 'Flooding',
  IncidentType.fire => 'Fire',
  IncidentType.medical => 'Medical',
  IncidentType.infrastructure => 'Infrastructure',
  IncidentType.supplyShortage => 'Supply shortage',
  IncidentType.displacement => 'Displacement',
  IncidentType.security => 'Security',
  IncidentType.other => 'Other',
};

String incidentSeverityLabel(IncidentSeverity severity) => switch (severity) {
  IncidentSeverity.low => 'Low',
  IncidentSeverity.moderate => 'Moderate',
  IncidentSeverity.high => 'High',
  IncidentSeverity.critical => 'Critical',
};

String incidentStatusLabel(IncidentStatus status) => switch (status) {
  IncidentStatus.reported => 'Reported',
  IncidentStatus.acknowledged => 'Acknowledged',
  IncidentStatus.assigned => 'Assigned',
  IncidentStatus.responding => 'Responding',
  IncidentStatus.resolved => 'Resolved',
  IncidentStatus.cancelled => 'Cancelled',
};
