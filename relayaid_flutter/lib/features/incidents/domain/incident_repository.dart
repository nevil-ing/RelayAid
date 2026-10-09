import 'package:relayaid_client/relayaid_client.dart';

import 'incident_sync_state.dart';

abstract interface class IncidentRepository {
  Future<List<Incident>> list({int limit = 50});

  Future<IncidentDetail> create({
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  });

  Future<IncidentDetail> detail(UuidValue incidentId);

  Future<IncidentDetail> transition(
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  });
}

abstract interface class IncidentSyncRepository {
  Stream<void> get changes;

  Future<IncidentSyncState> syncStateFor(UuidValue incidentId);

  Future<void> syncPending();
}
