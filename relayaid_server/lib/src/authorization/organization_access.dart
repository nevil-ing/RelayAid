import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Server-owned membership and role checks. Client-provided roles are ignored.
abstract final class OrganizationAccess {
  static UuidValue userId(Session session) {
    final authentication = session.authenticated;
    if (authentication == null) {
      throw AuthorizationException(message: 'Sign in is required.');
    }
    return authentication.authUserId;
  }

  static Future<OrganizationMember> member(
    Session session,
    UuidValue organizationId, {
    Set<MemberRole>? roles,
    Transaction? transaction,
  }) async {
    final membership = await OrganizationMember.db.findFirstRow(
      session,
      where: (table) =>
          table.organizationId.equals(organizationId) &
          table.authUserId.equals(userId(session)),
      transaction: transaction,
    );
    if (membership == null ||
        (roles != null && !roles.contains(membership.role))) {
      throw AuthorizationException(message: 'Organization access denied.');
    }
    return membership;
  }

  static Future<OrganizationMember> currentMember(
    Session session, {
    Set<MemberRole>? roles,
    Transaction? transaction,
  }) async {
    final membership = await OrganizationMember.db.findFirstRow(
      session,
      where: (table) => table.authUserId.equals(userId(session)),
      transaction: transaction,
    );
    if (membership == null ||
        (roles != null && !roles.contains(membership.role))) {
      throw AuthorizationException(message: 'Organization access denied.');
    }
    return membership;
  }
}
