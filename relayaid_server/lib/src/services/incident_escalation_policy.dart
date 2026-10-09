import 'dart:io';

import '../generated/protocol.dart';

/// Server-controlled timing; an offline report's clock starts on server receipt.
class IncidentEscalationPolicy {
  const IncidentEscalationPolicy({this.delay = defaultDelay});

  static const defaultDelay = Duration(minutes: 10);
  static const checkInterval = Duration(seconds: 5);
  static const delayEnvironmentKey = 'RELAYAID_ESCALATION_DELAY_SECONDS';
  final Duration delay;

  factory IncidentEscalationPolicy.fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final value = (environment ?? Platform.environment)[delayEnvironmentKey];
    if (value == null) return const IncidentEscalationPolicy();
    final seconds = int.tryParse(value);
    if (seconds == null || seconds < 1 || seconds > 86400) {
      throw FormatException(
        '$delayEnvironmentKey must be an integer from 1 to 86400.',
      );
    }
    return IncidentEscalationPolicy(delay: Duration(seconds: seconds));
  }

  DateTime? deadline(IncidentSeverity severity, DateTime receivedAt) =>
      severity == IncidentSeverity.critical
      ? receivedAt.toUtc().add(delay)
      : null;

  static bool isDue(Incident incident, DateTime now) =>
      incident.severity == IncidentSeverity.critical &&
      incident.status == IncidentStatus.reported &&
      incident.escalatedAt == null &&
      incident.escalationDueAt != null &&
      !now.toUtc().isBefore(incident.escalationDueAt!);
}
