import 'package:serverpod/protocol.dart' show FutureCallEntry;
import 'package:serverpod/serverpod.dart';

import '../generated/future_calls.dart';
import '../generated/protocol.dart';
import 'incident_escalation_policy.dart';
import 'incident_feed_service.dart';

/// Automatic escalation never assigns a team or changes lifecycle status.
abstract final class IncidentEscalationService {
  static const scheduleIdentifier = 'relayaid.critical-escalation.v1';
  static const batchSize = 100;

  /// Reuses the persisted recurring job across restarts. The database advisory
  /// lock serializes concurrent server boots; it contains no client input.
  static Future<void> ensureScheduled(Session session) =>
      session.db.transaction((transaction) async {
        await session.db.unsafeQuery(
          'SELECT pg_advisory_xact_lock(726514208);',
          transaction: transaction,
        );
        final existing = await FutureCallEntry.db.findFirstRow(
          session,
          where: (t) => t.identifier.equals(scheduleIdentifier),
          transaction: transaction,
        );
        if (existing != null) return;
        await session.server.serverpod.futureCalls
            .callRecurring(identifier: scheduleIdentifier)
            .every(
              IncidentEscalationPolicy.checkInterval,
              start: DateTime.now().toUtc(),
            )
            .incidentEscalation
            .checkOverdue();
      });

  static Future<void> checkOverdue(Session session) async {
    final now = DateTime.now().toUtc();
    final due = await Incident.db.find(
      session,
      where: (t) =>
          t.severity.equals(IncidentSeverity.critical) &
          t.status.equals(IncidentStatus.reported) &
          t.escalatedAt.equals(null) &
          (t.escalationDueAt.equals(null) | (t.escalationDueAt <= now)),
      orderByList: (t) => [t.escalationDueAt, t.id],
      limit: batchSize,
    );
    for (final incident in due) {
      try {
        await _escalate(session, incident.id!);
      } catch (error, stackTrace) {
        // The deadline stays pending, so the next recurring run retries it.
        // One failed report must not prevent other reports being checked.
        session.log(
          'Automatic escalation failed for incident ${incident.id}.',
          level: LogLevel.error,
          exception: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  static Future<void> _escalate(Session session, UuidValue incidentId) async {
    final event = await session.db.transaction((transaction) async {
      // Assignment and coordinator transitions take this same lock first.
      var incident = await Incident.db.findById(
        session,
        incidentId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final now = DateTime.now().toUtc();
      if (incident == null ||
          incident.severity != IncidentSeverity.critical ||
          incident.status != IncidentStatus.reported ||
          incident.escalatedAt != null) {
        return null;
      }
      // Pre-Phase-8 reports have no deadline. Derive it once from their actual
      // server receipt time, not the startup time, without inventing an event.
      if (incident.escalationDueAt == null) {
        incident = await Incident.db.updateRow(
          session,
          incident.copyWith(
            escalationDueAt: IncidentEscalationPolicy.fromEnvironment()
                .deadline(
                  incident.severity,
                  incident.reportedAt,
                ),
          ),
          transaction: transaction,
        );
      }
      if (!IncidentEscalationPolicy.isDue(incident, now)) return null;
      final assignment = await Assignment.db.findFirstRow(
        session,
        where: (t) => t.incidentId.equals(incidentId),
        transaction: transaction,
      );
      if (assignment != null) return null;
      await Incident.db.updateRow(
        session,
        incident.copyWith(escalatedAt: now, updatedAt: now),
        transaction: transaction,
      );
      return IncidentEvent.db.insertRow(
        session,
        IncidentEvent(
          incidentId: incidentId,
          organizationId: incident.organizationId,
          eventType: IncidentEventType.escalated,
          actorId: null,
          fromStatus: incident.status,
          toStatus: incident.status,
          note:
              'Critical report was not acknowledged or assigned before its escalation deadline. Coordinator attention required.',
          createdAt: now,
        ),
        transaction: transaction,
      );
    });
    if (event != null) await IncidentFeedService.publish(session, event);
  }
}
