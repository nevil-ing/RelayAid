import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../authorization/organization_access.dart';
import '../generated/protocol.dart';
import 'organization_change_service.dart';

/// Owns organization setup and membership changes, including authorization.
abstract final class OrganizationService {
  static Future<OrganizationContext?> myContext(Session session) async {
    final membership = await OrganizationMember.db.findFirstRow(
      session,
      where: (table) => table.authUserId.equals(
        OrganizationAccess.userId(session),
      ),
    );
    if (membership == null) return null;
    final organization = await Organization.db.findById(
      session,
      membership.organizationId,
    );
    if (organization == null) {
      throw StateError('Membership references a missing organization.');
    }
    return OrganizationContext(
      organization: organization,
      membership: membership,
    );
  }

  static Future<OrganizationContext> contextFor(
    Session session,
    UuidValue organizationId,
  ) async {
    final membership = await OrganizationAccess.member(session, organizationId);
    final organization = await Organization.db.findById(
      session,
      organizationId,
    );
    if (organization == null) {
      throw AuthorizationException(message: 'Organization access denied.');
    }
    return OrganizationContext(
      organization: organization,
      membership: membership,
    );
  }

  static Future<OrganizationContext> create(
    Session session,
    String name,
  ) async {
    final trimmedName = name.trim();
    if (trimmedName.length < 3 || trimmedName.length > 80) {
      throw FormatException('Organization name must be 3–80 characters.');
    }
    final userId = OrganizationAccess.userId(session);
    return session.db.transaction((transaction) async {
      final existing = await OrganizationMember.db.findFirstRow(
        session,
        where: (table) => table.authUserId.equals(userId),
        transaction: transaction,
      );
      if (existing != null) {
        throw AuthorizationException(
          message: 'Account already has an organization.',
        );
      }
      final organization = await Organization.db.insertRow(
        session,
        Organization(name: trimmedName, createdBy: userId),
        transaction: transaction,
      );
      final membership = await OrganizationMember.db.insertRow(
        session,
        OrganizationMember(
          organizationId: organization.id!,
          authUserId: userId,
          role: MemberRole.administrator,
        ),
        transaction: transaction,
      );
      return OrganizationContext(
        organization: organization,
        membership: membership,
      );
    });
  }

  static Future<OrganizationMember> addMember(
    Session session,
    UuidValue organizationId,
    UuidValue authUserId,
    MemberRole role,
  ) async {
    await OrganizationAccess.member(
      session,
      organizationId,
      roles: {MemberRole.administrator},
    );
    if (role == MemberRole.administrator) {
      throw AuthorizationException(
        message: 'Administrator grants are not available.',
      );
    }
    final user = await AuthUser.db.findById(session, authUserId);
    if (user == null) {
      throw FormatException('No account exists for this user ID.');
    }
    final existing = await OrganizationMember.db.findFirstRow(
      session,
      where: (table) => table.authUserId.equals(authUserId),
    );
    if (existing != null) {
      throw FormatException('This account already belongs to an organization.');
    }
    return OrganizationMember.db.insertRow(
      session,
      OrganizationMember(
        organizationId: organizationId,
        authUserId: authUserId,
        role: role,
      ),
    );
  }

  static Future<List<OrganizationMember>> listMembers(
    Session session,
    UuidValue organizationId,
  ) async {
    await OrganizationAccess.member(
      session,
      organizationId,
      roles: {MemberRole.coordinator, MemberRole.administrator},
    );
    return OrganizationMember.db.find(
      session,
      where: (table) => table.organizationId.equals(organizationId),
    );
  }

  static Future<Team> createTeam(
    Session session,
    UuidValue organizationId,
    String name,
  ) async {
    await OrganizationAccess.member(
      session,
      organizationId,
      roles: {MemberRole.coordinator, MemberRole.administrator},
    );
    final trimmedName = name.trim();
    if (trimmedName.length < 2 || trimmedName.length > 80) {
      throw FormatException('Team name must be 2–80 characters.');
    }
    final team = await Team.db.insertRow(
      session,
      Team(organizationId: organizationId, name: trimmedName),
    );
    await OrganizationChangeService.publish(session, organizationId, team);
    return team;
  }

  static Future<List<Team>> listTeams(
    Session session,
    UuidValue organizationId,
  ) async {
    await OrganizationAccess.member(session, organizationId);
    return Team.db.find(
      session,
      where: (table) => table.organizationId.equals(organizationId),
    );
  }
}
