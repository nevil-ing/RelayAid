import 'package:relayaid_client/relayaid_client.dart';

import '../domain/command_center_repository.dart';

class ServerpodCommandCenterRepository implements CommandCenterRepository {
  const ServerpodCommandCenterRepository(this.client);
  final Client client;

  @override
  Stream<IncidentFeed> watch() => client.incidentFeed.watch();

  @override
  Future<IncidentDetail> detail(UuidValue incidentId) =>
      client.incident.detail(incidentId);

  @override
  Future<IncidentDetail> acknowledge(UuidValue incidentId) =>
      client.incident.transition(incidentId, IncidentStatus.acknowledged);

  @override
  Future<IncidentDetail> assign(
    UuidValue incidentId,
    UuidValue teamId, {
    UuidValue? responderId,
  }) => client.assignment.assign(incidentId, teamId, responderId: responderId);

  @override
  Future<IncidentDetail> cancel(UuidValue incidentId) =>
      client.incident.transition(incidentId, IncidentStatus.cancelled);
}
