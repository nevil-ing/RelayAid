import 'package:relayaid_client/relayaid_client.dart';

import '../domain/incident_repository.dart';

class ServerpodIncidentRepository implements IncidentRepository {
  const ServerpodIncidentRepository(this.client);

  final Client client;

  @override
  Future<List<Incident>> list({int limit = 50}) =>
      client.incident.list(limit: limit);

  @override
  Future<IncidentDetail> create({
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) => client.incident.create(
    id: id,
    type: type,
    severity: severity,
    title: title,
    description: description,
    latitude: latitude,
    longitude: longitude,
    peopleAffected: peopleAffected,
  );

  @override
  Future<IncidentDetail> detail(UuidValue incidentId) =>
      client.incident.detail(incidentId);

  @override
  Future<IncidentDetail> transition(
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) => client.incident.transition(incidentId, nextStatus, note: note);
}
