import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Reads the committed (or transactional) aggregate after the caller authorizes.
abstract final class IncidentDetailReader {
  static Future<IncidentDetail> read(
    Session session,
    Incident incident, {
    Transaction? transaction,
  }) async {
    final timeline = await IncidentEvent.db.find(
      session,
      where: (t) => t.incidentId.equals(incident.id!),
      orderByList: (t) => [t.createdAt.asc(), t.id.asc()],
      transaction: transaction,
    );
    final assignment = await Assignment.db.findFirstRow(
      session,
      where: (t) => t.incidentId.equals(incident.id!),
      transaction: transaction,
    );
    final team = assignment == null
        ? null
        : await Team.db.findById(
            session,
            assignment.teamId,
            transaction: transaction,
          );
    return IncidentDetail(
      incident: incident,
      timeline: timeline,
      assignment: assignment,
      assignmentTeamName: team?.name,
    );
  }
}
