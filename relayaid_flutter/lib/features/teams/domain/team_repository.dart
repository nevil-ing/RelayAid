import 'package:relayaid_client/relayaid_client.dart';

abstract interface class TeamRepository {
  Future<List<OrganizationMember>> members(UuidValue organizationId);
  Future<Team> create(UuidValue organizationId, String name);
  Future<TeamMember> addResponder(UuidValue teamId, UuidValue responderId);
}
