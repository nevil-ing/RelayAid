import 'package:flutter/foundation.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../domain/auth_gateway.dart';

class ServerpodAuthGateway extends ChangeNotifier implements AuthGateway {
  ServerpodAuthGateway(this.client) {
    client.auth.authInfoListenable.addListener(notifyListeners);
  }

  final Client client;

  @override
  bool get isAuthenticated => client.auth.isAuthenticated;

  @override
  UuidValue? get userId => client.auth.authInfo?.authUserId;

  @override
  Future<void> restore() async {
    await client.auth.initialize();
  }

  @override
  Future<void> signOut() => client.auth.signOutDevice().then((_) {});

  @override
  Future<OrganizationContext?> myContext() => client.organization.myContext();

  @override
  Future<OrganizationContext> createOrganization(String name) =>
      client.organization.create(name);

  @override
  Future<List<OrganizationMember>> listMembers(UuidValue organizationId) =>
      client.organization.listMembers(organizationId);

  @override
  Future<OrganizationMember> addMember(
    UuidValue organizationId,
    UuidValue authUserId,
    MemberRole role,
  ) => client.organization.addMember(organizationId, authUserId, role);

  @override
  Future<List<Team>> listTeams(UuidValue organizationId) =>
      client.organization.listTeams(organizationId);

  @override
  Future<Team> createTeam(UuidValue organizationId, String name) =>
      client.organization.createTeam(organizationId, name);

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(notifyListeners);
    super.dispose();
  }
}
