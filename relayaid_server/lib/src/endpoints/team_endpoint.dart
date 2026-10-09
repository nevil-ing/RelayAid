import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/team_roster_service.dart';

class TeamEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<TeamMember> addResponder(
    Session session,
    UuidValue teamId,
    UuidValue responderId,
  ) => TeamRosterService.addResponder(session, teamId, responderId);
}
