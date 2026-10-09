import 'package:serverpod/serverpod.dart';

import '../services/incident_escalation_service.dart';

/// Serverpod persists each recurring run before executing the current one.
/// Keeping deadlines with incidents avoids a save-to-schedule failure window.
class IncidentEscalationFutureCall extends FutureCall {
  Future<void> checkOverdue(Session session) =>
      IncidentEscalationService.checkOverdue(session);
}
