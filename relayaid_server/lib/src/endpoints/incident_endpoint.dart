import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/incident_service.dart';

/// Authenticated incident operations scoped to the caller's organization.
class IncidentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<IncidentDetail> create(
    Session session, {
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) => IncidentService.create(
    session,
    id: id,
    type: type,
    severity: severity,
    title: title,
    description: description,
    latitude: latitude,
    longitude: longitude,
    peopleAffected: peopleAffected,
  );

  Future<List<Incident>> list(Session session, {required int limit}) =>
      IncidentService.list(session, limit: limit);

  Future<IncidentDetail> detail(Session session, UuidValue incidentId) =>
      IncidentService.detail(session, incidentId);

  Future<IncidentDetail> transition(
    Session session,
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) => IncidentService.transition(
    session,
    incidentId,
    nextStatus,
    note: note,
  );
}
