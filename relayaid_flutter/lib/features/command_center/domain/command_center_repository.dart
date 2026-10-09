import 'package:relayaid_client/relayaid_client.dart';

abstract interface class CommandCenterRepository {
  Stream<IncidentFeed> watch();
  Future<IncidentDetail> detail(UuidValue incidentId);
  Future<IncidentDetail> acknowledge(UuidValue incidentId);
  Future<IncidentDetail> assign(
    UuidValue incidentId,
    UuidValue teamId, {
    UuidValue? responderId,
  });
  Future<IncidentDetail> cancel(UuidValue incidentId);
}
