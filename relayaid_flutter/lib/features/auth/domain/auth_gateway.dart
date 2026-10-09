import 'package:flutter/foundation.dart';
import 'package:relayaid_client/relayaid_client.dart';

/// Identity and organization operations used by application state.
abstract class AuthGateway extends Listenable {
  bool get isAuthenticated;
  UuidValue? get userId;

  Future<void> restore();
  Future<void> signOut();
  Future<OrganizationContext?> myContext();
  Future<OrganizationContext> createOrganization(String name);
  Future<List<OrganizationMember>> listMembers(UuidValue organizationId);
  Future<OrganizationMember> addMember(
    UuidValue organizationId,
    UuidValue authUserId,
    MemberRole role,
  );
  Future<List<Team>> listTeams(UuidValue organizationId);
  Future<Team> createTeam(UuidValue organizationId, String name);
}
