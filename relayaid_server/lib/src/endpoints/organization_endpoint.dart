import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/organization_service.dart';

/// Authenticated entry point for organization setup and team context.
class OrganizationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<OrganizationContext?> myContext(Session session) =>
      OrganizationService.myContext(session);

  Future<OrganizationContext> contextFor(
    Session session,
    UuidValue organizationId,
  ) => OrganizationService.contextFor(session, organizationId);

  Future<OrganizationContext> create(Session session, String name) =>
      OrganizationService.create(session, name);

  Future<OrganizationMember> addMember(
    Session session,
    UuidValue organizationId,
    UuidValue authUserId,
    MemberRole role,
  ) => OrganizationService.addMember(session, organizationId, authUserId, role);

  Future<List<OrganizationMember>> listMembers(
    Session session,
    UuidValue organizationId,
  ) => OrganizationService.listMembers(session, organizationId);

  Future<Team> createTeam(
    Session session,
    UuidValue organizationId,
    String name,
  ) => OrganizationService.createTeam(session, organizationId, name);

  Future<List<Team>> listTeams(Session session, UuidValue organizationId) =>
      OrganizationService.listTeams(session, organizationId);
}
