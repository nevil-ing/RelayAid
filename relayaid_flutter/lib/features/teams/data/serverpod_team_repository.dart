import 'package:relayaid_client/relayaid_client.dart';

import '../domain/team_repository.dart';

class ServerpodTeamRepository implements TeamRepository {
  const ServerpodTeamRepository(this.client);
  final Client client;

  @override
  Future<List<OrganizationMember>> members(UuidValue id) =>
      client.organization.listMembers(id);
  @override
  Future<Team> create(UuidValue id, String name) =>
      client.organization.createTeam(id, name);
  @override
  Future<TeamMember> addResponder(UuidValue teamId, UuidValue responderId) =>
      client.team.addResponder(teamId, responderId);
}
