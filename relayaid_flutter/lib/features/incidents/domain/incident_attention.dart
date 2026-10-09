import 'package:relayaid_client/relayaid_client.dart';

extension IncidentAttention on Incident {
  /// Acknowledging or assigning removes the warning, not its audit history.
  bool get needsCoordinatorAttention =>
      severity == IncidentSeverity.critical &&
      status == IncidentStatus.reported &&
      escalatedAt != null;
}
