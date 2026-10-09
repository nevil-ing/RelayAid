import 'package:serverpod/serverpod.dart';

import '../authorization/organization_access.dart';
import '../generated/protocol.dart';
import 'incident_detail_reader.dart';
import 'incident_feed_service.dart';
import 'team_roster_service.dart';

/// Serializes each workflow on the incident row, then its assignment row.
/// Incident, assignment and audit event are committed in the same transaction.
abstract final class AssignmentService {
  static Future<IncidentDetail> assign(
    Session session,
    UuidValue incidentId,
    UuidValue teamId, {
    UuidValue? responderId,
  }) async {
    final actor = await OrganizationAccess.currentMember(
      session,
      roles: TeamRosterService.coordinatorRoles,
    );
    IncidentEvent? event;
    final detail = await session.db.transaction((transaction) async {
      final incident = await Incident.db.findById(
        session,
        incidentId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (incident == null || incident.organizationId != actor.organizationId) {
        throw AuthorizationException(message: 'Incident access denied.');
      }
      await OrganizationAccess.member(
        session,
        actor.organizationId,
        roles: TeamRosterService.coordinatorRoles,
        transaction: transaction,
      );
      final existing = await Assignment.db.findFirstRow(
        session,
        where: (t) => t.incidentId.equals(incidentId),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (existing != null) {
        if (existing.teamId == teamId &&
            existing.designatedResponderId == responderId) {
          // Lost HTTP responses/replayed taps must not create duplicate events.
          return IncidentDetailReader.read(
            session,
            incident,
            transaction: transaction,
          );
        }
        throw IncidentValidationException(
          message: 'This incident already has an assignment.',
        );
      }
      if (incident.status != IncidentStatus.reported &&
          incident.status != IncidentStatus.acknowledged) {
        throw IncidentValidationException(
          message: 'Only open, unassigned reports can be assigned.',
        );
      }
      final team = await Team.db.findById(
        session,
        teamId,
        transaction: transaction,
      );
      if (team == null || team.organizationId != actor.organizationId) {
        throw AuthorizationException(message: 'Team access denied.');
      }
      final roster = await TeamMember.db.find(
        session,
        where: (t) => t.teamId.equals(teamId),
        transaction: transaction,
      );
      final responders = roster.isEmpty
          ? <OrganizationMember>[]
          : await OrganizationMember.db.find(
              session,
              where: (t) =>
                  t.organizationId.equals(actor.organizationId) &
                  t.role.equals(MemberRole.responder) &
                  t.authUserId.inSet(
                    roster.map((entry) => entry.authUserId).toSet(),
                  ),
              transaction: transaction,
            );
      if (responders.isEmpty ||
          (responderId != null &&
              !responders.any((m) => m.authUserId == responderId))) {
        throw IncidentValidationException(
          message:
              'Assign a team with responders; any selected responder must be on its roster.',
        );
      }
      final now = DateTime.now().toUtc();
      final assignment = await Assignment.db.insertRow(
        session,
        Assignment(
          organizationId: actor.organizationId,
          incidentId: incidentId,
          teamId: teamId,
          designatedResponderId: responderId,
          assignedBy: actor.authUserId,
          status: AssignmentStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      final updated = await Incident.db.updateRow(
        session,
        incident.copyWith(status: IncidentStatus.assigned, updatedAt: now),
        transaction: transaction,
      );
      event = await IncidentEvent.db.insertRow(
        session,
        IncidentEvent(
          organizationId: actor.organizationId,
          incidentId: incidentId,
          assignmentId: assignment.id,
          actorId: actor.authUserId,
          eventType: IncidentEventType.assignmentCreated,
          fromStatus: incident.status,
          toStatus: updated.status,
          note: responderId == null
              ? 'Assigned to ${team.name}'
              : 'Assigned to ${team.name} · Responder $responderId',
          createdAt: now,
        ),
        transaction: transaction,
      );
      return IncidentDetailReader.read(
        session,
        updated,
        transaction: transaction,
      );
    });
    if (event != null) await IncidentFeedService.publish(session, event!);
    return detail;
  }

  static Future<IncidentDetail> accept(
    Session session,
    UuidValue assignmentId,
  ) => _advance(session, assignmentId, AssignmentStatus.accepted);

  static Future<IncidentDetail> respond(
    Session session,
    UuidValue assignmentId,
  ) => _advance(session, assignmentId, AssignmentStatus.responding);

  static Future<IncidentDetail> resolve(
    Session session,
    UuidValue assignmentId,
    String note,
  ) {
    if (note.trim().length < 3 || note.trim().length > 500) {
      throw IncidentValidationException(
        message: 'A resolution note must be 3–500 characters.',
      );
    }
    return _advance(
      session,
      assignmentId,
      AssignmentStatus.resolved,
      note: note.trim(),
    );
  }

  static Future<void> authorizeResponder(
    Session session,
    Assignment assignment, {
    Transaction? transaction,
  }) async {
    final membership = await OrganizationAccess.member(
      session,
      assignment.organizationId,
      roles: {MemberRole.responder},
      transaction: transaction,
    );
    final team = await Team.db.findById(
      session,
      assignment.teamId,
      transaction: transaction,
    );
    final rosterEntry = await TeamMember.db.findFirstRow(
      session,
      where: (t) =>
          t.teamId.equals(assignment.teamId) &
          t.authUserId.equals(membership.authUserId),
      transaction: transaction,
    );
    if (team?.organizationId != membership.organizationId ||
        rosterEntry == null ||
        (assignment.designatedResponderId != null &&
            assignment.designatedResponderId != membership.authUserId)) {
      throw AuthorizationException(message: 'Assignment access denied.');
    }
  }

  static Future<IncidentDetail> detail(
    Session session,
    UuidValue assignmentId,
  ) => session.db.transaction(
    (transaction) async {
      final assignment = await Assignment.db.findById(
        session,
        assignmentId,
        transaction: transaction,
      );
      if (assignment == null) {
        throw AuthorizationException(message: 'Assignment access denied.');
      }
      await authorizeResponder(session, assignment, transaction: transaction);
      final incident = await Incident.db.findById(
        session,
        assignment.incidentId,
        transaction: transaction,
      );
      if (incident == null ||
          incident.organizationId != assignment.organizationId) {
        throw AuthorizationException(message: 'Incident access denied.');
      }
      return IncidentDetailReader.read(
        session,
        incident,
        transaction: transaction,
      );
    },
    settings: const TransactionSettings(
      isolationLevel: IsolationLevel.repeatableRead,
    ),
  );

  static Future<IncidentDetail> _advance(
    Session session,
    UuidValue assignmentId,
    AssignmentStatus next, {
    String? note,
  }) async {
    final assignment = await Assignment.db.findById(session, assignmentId);
    if (assignment == null) {
      throw AuthorizationException(message: 'Assignment access denied.');
    }
    await authorizeResponder(session, assignment);
    final userId = OrganizationAccess.userId(session);
    IncidentEvent? event;
    final detail = await session.db.transaction((transaction) async {
      final incident = await Incident.db.findById(
        session,
        assignment.incidentId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final locked = await Assignment.db.findById(
        session,
        assignmentId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (incident == null ||
          locked == null ||
          incident.organizationId != locked.organizationId) {
        throw AuthorizationException(message: 'Assignment access denied.');
      }
      await authorizeResponder(session, locked, transaction: transaction);
      if (locked.acceptedBy != null && locked.acceptedBy != userId) {
        throw AuthorizationException(
          message: 'Another responder has accepted this assignment.',
        );
      }
      if (locked.status == AssignmentStatus.cancelled ||
          incident.status == IncidentStatus.cancelled) {
        throw IncidentValidationException(
          message: 'This assignment has been cancelled.',
        );
      }
      if (locked.acceptedBy == userId && locked.status.index >= next.index) {
        return IncidentDetailReader.read(
          session,
          incident,
          transaction: transaction,
        );
      }
      final previous = switch (next) {
        AssignmentStatus.accepted => AssignmentStatus.pending,
        AssignmentStatus.responding => AssignmentStatus.accepted,
        AssignmentStatus.resolved => AssignmentStatus.responding,
        _ => throw StateError('Unsupported responder action.'),
      };
      final expectedIncident = previous == AssignmentStatus.responding
          ? IncidentStatus.responding
          : IncidentStatus.assigned;
      if (locked.status != previous || incident.status != expectedIncident) {
        throw IncidentValidationException(
          message: 'Accept, start responding, then resolve in order.',
        );
      }
      final now = DateTime.now().toUtc();
      final updatedAssignment = locked.copyWith(status: next, updatedAt: now);
      if (next == AssignmentStatus.accepted) {
        updatedAssignment.acceptedBy = userId;
        updatedAssignment.acceptedAt = now;
      } else if (next == AssignmentStatus.responding) {
        updatedAssignment.respondingAt = now;
      } else {
        updatedAssignment.resolvedAt = now;
      }
      await Assignment.db.updateRow(
        session,
        updatedAssignment,
        transaction: transaction,
      );
      final nextIncidentStatus = switch (next) {
        AssignmentStatus.accepted => IncidentStatus.assigned,
        AssignmentStatus.responding => IncidentStatus.responding,
        _ => IncidentStatus.resolved,
      };
      final updated = await Incident.db.updateRow(
        session,
        incident.copyWith(status: nextIncidentStatus, updatedAt: now),
        transaction: transaction,
      );
      final team = await Team.db.findById(
        session,
        locked.teamId,
        transaction: transaction,
      );
      event = await IncidentEvent.db.insertRow(
        session,
        IncidentEvent(
          incidentId: incident.id!,
          organizationId: incident.organizationId,
          assignmentId: locked.id,
          actorId: userId,
          eventType: switch (next) {
            AssignmentStatus.accepted => IncidentEventType.assignmentAccepted,
            AssignmentStatus.responding => IncidentEventType.responseStarted,
            _ => IncidentEventType.assignmentResolved,
          },
          fromStatus: incident.status,
          toStatus: nextIncidentStatus,
          note:
              note ??
              '${team!.name} · ${next == AssignmentStatus.accepted ? 'Assignment accepted' : 'Response started'}',
          createdAt: now,
        ),
        transaction: transaction,
      );
      return IncidentDetailReader.read(
        session,
        updated,
        transaction: transaction,
      );
    });
    if (event != null) await IncidentFeedService.publish(session, event!);
    return detail;
  }
}
