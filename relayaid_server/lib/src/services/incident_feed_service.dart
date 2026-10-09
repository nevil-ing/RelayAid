import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../authorization/organization_access.dart';
import '../generated/protocol.dart';
import 'organization_change_service.dart';
import 'team_roster_service.dart';

/// Pushes bounded, authoritative snapshots. Reopening catches up missed events.
abstract final class IncidentFeedService {
  static const maxIncidents = 500;
  static const maxActivity = 40;
  static const _roles = {MemberRole.coordinator, MemberRole.administrator};

  static Stream<IncidentFeed> watch(Session session) async* {
    final membership = await OrganizationAccess.currentMember(
      session,
      roles: _roles,
    );
    final organizationId = membership.organizationId;
    // Register before querying, so writes during initial loading are buffered.
    final changes = StreamIterator<SerializableModel>(
      OrganizationChangeService.watch(session, organizationId),
    );
    try {
      yield await _snapshot(session, organizationId);
      while (await changes.moveNext()) {
        // A long-lived connection is not a permanent authorization grant.
        await OrganizationAccess.member(session, organizationId, roles: _roles);
        yield await _snapshot(session, organizationId);
      }
    } finally {
      await changes.cancel();
    }
  }

  static Future<IncidentFeed> _snapshot(
    Session session,
    UuidValue organizationId,
  ) => session.db.transaction(
    (transaction) async {
      await OrganizationAccess.member(
        session,
        organizationId,
        roles: _roles,
        transaction: transaction,
      );
      return _readSnapshot(session, organizationId, transaction);
    },
    settings: const TransactionSettings(
      isolationLevel: IsolationLevel.repeatableRead,
    ),
  );

  static Future<IncidentFeed> _readSnapshot(
    Session session,
    UuidValue organizationId,
    Transaction transaction,
  ) async {
    final escalated = await Incident.db.find(
      session,
      where: (t) =>
          t.organizationId.equals(organizationId) &
          t.severity.equals(IncidentSeverity.critical) &
          t.status.equals(IncidentStatus.reported) &
          t.escalatedAt.notEquals(null),
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: maxIncidents + 1,
      transaction: transaction,
    );
    // Prioritize outstanding escalations before bounding the snapshot. Sorting
    // only after the limit could hide an older critical report from operators.
    final remaining = escalated.length > maxIncidents
        ? <Incident>[]
        : await Incident.db.find(
            session,
            where: (t) =>
                t.organizationId.equals(organizationId) &
                ~(t.severity.equals(IncidentSeverity.critical) &
                    t.status.equals(IncidentStatus.reported) &
                    t.escalatedAt.notEquals(null)),
            orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
            limit: maxIncidents + 1 - escalated.length,
            transaction: transaction,
          );
    final incidents = [...escalated, ...remaining];
    final events = await IncidentEvent.db.find(
      session,
      where: (t) => t.organizationId.equals(organizationId),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: maxActivity,
      transaction: transaction,
    );
    final eventIncidentIds = events.map((event) => event.incidentId).toSet();
    final eventIncidents = eventIncidentIds.isEmpty
        ? <Incident>[]
        : await Incident.db.find(
            session,
            where: (t) =>
                t.organizationId.equals(organizationId) &
                t.id.inSet(eventIncidentIds),
            transaction: transaction,
          );
    final titles = {
      for (final incident in eventIncidents) incident.id: incident.title,
    };
    return IncidentFeed(
      organizationId: organizationId,
      incidents: incidents.take(maxIncidents).toList(),
      activity: [
        for (final event in events)
          if (titles[event.incidentId] case final String title)
            IncidentActivity(event: event, incidentTitle: title),
      ],
      generatedAt: DateTime.now().toUtc(),
      hasMoreIncidents: incidents.length > maxIncidents,
      teams: await TeamRosterService.read(
        session,
        organizationId,
        transaction: transaction,
      ),
    );
  }

  /// Call only after the incident/event transaction commits. The write remains
  /// successful if live delivery is unavailable; the next snapshot recovers it.
  static Future<void> publish(Session session, IncidentEvent event) =>
      OrganizationChangeService.publish(session, event.organizationId, event);
}
