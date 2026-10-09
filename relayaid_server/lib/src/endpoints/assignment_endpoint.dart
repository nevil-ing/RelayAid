import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/assignment_feed_service.dart';
import '../services/assignment_service.dart';

class AssignmentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<IncidentDetail> assign(
    Session session,
    UuidValue incidentId,
    UuidValue teamId, {
    UuidValue? responderId,
  }) => AssignmentService.assign(
    session,
    incidentId,
    teamId,
    responderId: responderId,
  );

  Stream<AssignmentFeed> watch(Session session) =>
      AssignmentFeedService.watch(session);

  Future<IncidentDetail> detail(Session session, UuidValue assignmentId) =>
      AssignmentService.detail(session, assignmentId);

  Future<IncidentDetail> accept(Session session, UuidValue assignmentId) =>
      AssignmentService.accept(session, assignmentId);

  Future<IncidentDetail> respond(Session session, UuidValue assignmentId) =>
      AssignmentService.respond(session, assignmentId);

  Future<IncidentDetail> resolve(
    Session session,
    UuidValue assignmentId,
    String note,
  ) => AssignmentService.resolve(session, assignmentId, note);
}
