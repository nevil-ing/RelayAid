import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:relayaid_server/src/services/incident_escalation_policy.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  final received = DateTime.utc(2026, 10, 7, 9);
  Incident report() => Incident(
    organizationId: Uuid().v4obj(),
    reportedBy: Uuid().v4obj(),
    type: IncidentType.flooding,
    severity: IncidentSeverity.critical,
    status: IncidentStatus.reported,
    title: 'Flooded bridge',
    description: 'People are stranded.',
    peopleAffected: 12,
    reportedAt: received,
    escalationDueAt: received.add(IncidentEscalationPolicy.defaultDelay),
  );

  test('default policy grants ten minutes from server receipt', () {
    final policy = IncidentEscalationPolicy.fromEnvironment({});
    expect(policy.delay, const Duration(minutes: 10));
    expect(
      policy.deadline(IncidentSeverity.critical, received),
      received.add(const Duration(minutes: 10)),
    );
    for (final severity in IncidentSeverity.values) {
      if (severity == IncidentSeverity.critical) continue;
      expect(policy.deadline(severity, received), isNull);
    }
  });

  test('demo timing is server configured and uses UTC', () {
    final policy = IncidentEscalationPolicy.fromEnvironment({
      IncidentEscalationPolicy.delayEnvironmentKey: '10',
    });
    expect(policy.delay, const Duration(seconds: 10));
    expect(
      policy.deadline(IncidentSeverity.critical, received.toLocal()),
      received.add(const Duration(seconds: 10)),
    );
    expect(
      policy.deadline(IncidentSeverity.critical, received.toLocal())!.isUtc,
      isTrue,
    );
  });

  test('invalid timing fails instead of silently disabling escalation', () {
    for (final value in ['', 'later', '0', '-1', '1.5', '86401']) {
      expect(
        () => IncidentEscalationPolicy.fromEnvironment({
          IncidentEscalationPolicy.delayEnvironmentKey: value,
        }),
        throwsFormatException,
      );
    }
  });

  test('escalation starts at the deadline, never before it', () {
    final incident = report();
    final due = incident.escalationDueAt!;
    expect(
      IncidentEscalationPolicy.isDue(
        incident,
        due.subtract(const Duration(microseconds: 1)),
      ),
      isFalse,
    );
    expect(IncidentEscalationPolicy.isDue(incident, due), isTrue);
    expect(
      IncidentEscalationPolicy.isDue(
        incident,
        due.add(const Duration(days: 1)),
      ),
      isTrue,
    );
  });

  test('non-critical and every handled lifecycle state are excluded', () {
    final incident = report();
    final now = received.add(const Duration(days: 1));
    for (final status in IncidentStatus.values) {
      if (status == IncidentStatus.reported) continue;
      expect(
        IncidentEscalationPolicy.isDue(incident.copyWith(status: status), now),
        isFalse,
        reason: status.name,
      );
    }
    for (final severity in IncidentSeverity.values) {
      if (severity == IncidentSeverity.critical) continue;
      expect(
        IncidentEscalationPolicy.isDue(
          incident.copyWith(severity: severity),
          now,
        ),
        isFalse,
        reason: severity.name,
      );
    }
  });

  test('already escalated or not yet initialized deadlines are not due', () {
    final incident = report();
    final now = received.add(const Duration(days: 1));
    expect(
      IncidentEscalationPolicy.isDue(incident.copyWith(escalatedAt: now), now),
      isFalse,
    );
    expect(
      IncidentEscalationPolicy.isDue(
        incident.copyWith(escalationDueAt: null),
        now,
      ),
      isFalse,
    );
  });
}
