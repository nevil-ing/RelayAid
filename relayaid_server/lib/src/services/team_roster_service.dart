import 'package:serverpod/serverpod.dart';

import '../authorization/organization_access.dart';
import '../generated/protocol.dart';
import 'organization_change_service.dart';

abstract final class TeamRosterService {
  static const coordinatorRoles = {
    MemberRole.coordinator,
    MemberRole.administrator,
  };

  static Future<TeamMember> addResponder(
    Session session,
    UuidValue teamId,
    UuidValue responderId,
  ) async {
    final result = await session.db.transaction((transaction) async {
      final team = await Team.db.findById(
        session,
        teamId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (team == null) {
        throw AuthorizationException(message: 'Team access denied.');
      }
      await OrganizationAccess.member(
        session,
        team.organizationId,
        roles: coordinatorRoles,
        transaction: transaction,
      );
      final responder = await OrganizationMember.db.findFirstRow(
        session,
        where: (t) =>
            t.organizationId.equals(team.organizationId) &
            t.authUserId.equals(responderId) &
            t.role.equals(MemberRole.responder),
        transaction: transaction,
      );
      if (responder == null) {
        throw IncidentValidationException(
          message: 'Choose a responder in this organization.',
        );
      }
      final existing = await TeamMember.db.findFirstRow(
        session,
        where: (t) =>
            t.teamId.equals(teamId) & t.authUserId.equals(responderId),
        transaction: transaction,
      );
      return existing ??
          await TeamMember.db.insertRow(
            session,
            TeamMember(teamId: teamId, authUserId: responderId),
            transaction: transaction,
          );
    });
    final team = await Team.db.findById(session, teamId);
    if (team != null) {
      await OrganizationChangeService.publish(
        session,
        team.organizationId,
        result,
      );
    }
    return result;
  }

  /// Internal read; public callers must authorize the organization first.
  static Future<List<TeamRoster>> read(
    Session session,
    UuidValue organizationId, {
    Transaction? transaction,
  }) async {
    final teams = await Team.db.find(
      session,
      where: (t) => t.organizationId.equals(organizationId),
      orderByList: (t) => [t.name.asc(), t.id.asc()],
      transaction: transaction,
    );
    if (teams.isEmpty) return [];
    final members = await OrganizationMember.db.find(
      session,
      where: (t) =>
          t.organizationId.equals(organizationId) &
          t.role.equals(MemberRole.responder),
      transaction: transaction,
    );
    final byUser = {for (final member in members) member.authUserId: member};
    final roster = await TeamMember.db.find(
      session,
      where: (t) => t.teamId.inSet(teams.map((team) => team.id!).toSet()),
      orderByList: (t) => [t.joinedAt.asc(), t.id.asc()],
      transaction: transaction,
    );
    final active = await Assignment.db.find(
      session,
      where: (t) =>
          t.organizationId.equals(organizationId) &
          t.status.inSet({
            AssignmentStatus.pending,
            AssignmentStatus.accepted,
            AssignmentStatus.responding,
          }),
      transaction: transaction,
    );
    return [
      for (final team in teams)
        TeamRoster(
          team: team,
          responders: [
            for (final entry in roster)
              if (entry.teamId == team.id && byUser[entry.authUserId] != null)
                byUser[entry.authUserId]!,
          ],
          activeAssignments: active.where((a) => a.teamId == team.id).length,
        ),
    ];
  }
}
