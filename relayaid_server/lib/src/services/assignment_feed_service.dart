import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../authorization/organization_access.dart';
import '../generated/protocol.dart';
import 'organization_change_service.dart';

/// A responder sees only their current teams and any designated assignments.
abstract final class AssignmentFeedService {
  static const maxActive = 200;
  static const maxCompleted = 50;

  static Stream<AssignmentFeed> watch(Session session) async* {
    final member = await OrganizationAccess.currentMember(
      session,
      roles: {MemberRole.responder},
    );
    final changes = StreamIterator<SerializableModel>(
      OrganizationChangeService.watch(session, member.organizationId),
    );
    try {
      yield await _snapshot(session, member);
      while (await changes.moveNext()) {
        final current = await OrganizationAccess.member(
          session,
          member.organizationId,
          roles: {MemberRole.responder},
        );
        yield await _snapshot(session, current);
      }
    } finally {
      await changes.cancel();
    }
  }

  static Future<AssignmentFeed> _snapshot(
    Session session,
    OrganizationMember member,
  ) => session.db.transaction(
    (transaction) async {
      final current = await OrganizationAccess.member(
        session,
        member.organizationId,
        roles: {MemberRole.responder},
        transaction: transaction,
      );
      return _readSnapshot(session, current, transaction);
    },
    settings: const TransactionSettings(
      isolationLevel: IsolationLevel.repeatableRead,
    ),
  );

  static Future<AssignmentFeed> _readSnapshot(
    Session session,
    OrganizationMember member,
    Transaction transaction,
  ) async {
    final roster = await TeamMember.db.find(
      session,
      where: (t) => t.authUserId.equals(member.authUserId),
      transaction: transaction,
    );
    final teams = roster.isEmpty
        ? <Team>[]
        : await Team.db.find(
            session,
            where: (t) =>
                t.organizationId.equals(member.organizationId) &
                t.id.inSet(roster.map((entry) => entry.teamId).toSet()),
            transaction: transaction,
          );
    final teamIds = teams.map((team) => team.id!).toSet();
    final active = teamIds.isEmpty
        ? <Assignment>[]
        : await Assignment.db.find(
            session,
            where: (t) =>
                t.organizationId.equals(member.organizationId) &
                t.teamId.inSet(teamIds) &
                (t.designatedResponderId.equals(null) |
                    t.designatedResponderId.equals(member.authUserId)) &
                t.status.inSet({
                  AssignmentStatus.pending,
                  AssignmentStatus.accepted,
                  AssignmentStatus.responding,
                }),
            orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
            limit: maxActive + 1,
            transaction: transaction,
          );
    final completed = teamIds.isEmpty
        ? <Assignment>[]
        : await Assignment.db.find(
            session,
            where: (t) =>
                t.organizationId.equals(member.organizationId) &
                t.teamId.inSet(teamIds) &
                (t.designatedResponderId.equals(null) |
                    t.designatedResponderId.equals(member.authUserId)) &
                t.status.inSet({
                  AssignmentStatus.resolved,
                  AssignmentStatus.cancelled,
                }),
            orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
            limit: maxCompleted + 1,
            transaction: transaction,
          );
    final assignments = [
      ...active.take(maxActive),
      ...completed.take(maxCompleted),
    ];
    final incidents = assignments.isEmpty
        ? <Incident>[]
        : await Incident.db.find(
            session,
            where: (t) =>
                t.organizationId.equals(member.organizationId) &
                t.id.inSet(assignments.map((a) => a.incidentId).toSet()),
            transaction: transaction,
          );
    final byIncident = {
      for (final incident in incidents) incident.id: incident,
    };
    final byTeam = {for (final team in teams) team.id: team.name};
    return AssignmentFeed(
      organizationId: member.organizationId,
      authUserId: member.authUserId,
      assignments: [
        for (final assignment in assignments)
          if (byIncident[assignment.incidentId] != null)
            AssignmentSummary(
              assignment: assignment,
              incident: byIncident[assignment.incidentId]!,
              teamName: byTeam[assignment.teamId]!,
            ),
      ],
      generatedAt: DateTime.now().toUtc(),
      hasMoreAssignments:
          active.length > maxActive || completed.length > maxCompleted,
    );
  }
}
