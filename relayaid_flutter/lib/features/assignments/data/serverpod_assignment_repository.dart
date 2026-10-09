import 'package:relayaid_client/relayaid_client.dart';

import '../domain/assignment_repository.dart';

class ServerpodAssignmentRepository implements AssignmentRepository {
  const ServerpodAssignmentRepository(this.client);
  final Client client;

  @override
  Stream<AssignmentFeed> watch() => client.assignment.watch();
  @override
  Future<IncidentDetail> detail(UuidValue id) => client.assignment.detail(id);
  @override
  Future<IncidentDetail> accept(UuidValue id) => client.assignment.accept(id);
  @override
  Future<IncidentDetail> respond(UuidValue id) => client.assignment.respond(id);
  @override
  Future<IncidentDetail> resolve(UuidValue id, String note) =>
      client.assignment.resolve(id, note);
}
