import 'package:relayaid_client/relayaid_client.dart';

abstract interface class AssignmentRepository {
  Stream<AssignmentFeed> watch();
  Future<IncidentDetail> detail(UuidValue assignmentId);
  Future<IncidentDetail> accept(UuidValue assignmentId);
  Future<IncidentDetail> respond(UuidValue assignmentId);
  Future<IncidentDetail> resolve(UuidValue assignmentId, String note);
}
