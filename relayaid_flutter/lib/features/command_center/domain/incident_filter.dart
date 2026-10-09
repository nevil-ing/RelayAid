import 'package:relayaid_client/relayaid_client.dart';

class IncidentFilter {
  const IncidentFilter({this.query = '', this.severity, this.status});

  final String query;
  final IncidentSeverity? severity;
  final IncidentStatus? status;

  bool matches(Incident incident) {
    final search = query.trim().toLowerCase();
    return (severity == null || incident.severity == severity) &&
        (status == null || incident.status == status) &&
        (search.isEmpty ||
            incident.title.toLowerCase().contains(search) ||
            incident.description.toLowerCase().contains(search));
  }
}

/// Web Mercator cannot render polar coordinates. Keep the original report
/// unchanged, and show these records in the list rather than inventing a pin.
bool hasMapLocation(Incident incident) =>
    incident.latitude != null &&
    incident.longitude != null &&
    incident.latitude!.isFinite &&
    incident.longitude!.isFinite &&
    incident.latitude!.abs() <= 85.05112878 &&
    incident.longitude!.abs() <= 180;
