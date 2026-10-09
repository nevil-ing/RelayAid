class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      accuracyMeters.isFinite &&
      accuracyMeters >= 0;
}

enum LocationProblem { denied, blocked, disabled, timeout, unavailable }

class LocationFailure implements Exception {
  const LocationFailure(this.problem);
  final LocationProblem problem;

  String get message => switch (problem) {
    LocationProblem.denied =>
      'Location access was not allowed. You can retry or enter coordinates yourself.',
    LocationProblem.blocked =>
      'Allow location access in Settings, or enter coordinates yourself.',
    LocationProblem.disabled =>
      'Location services are off. Turn them on, or enter coordinates yourself.',
    LocationProblem.timeout =>
      'A location could not be found in time. Try outdoors, or enter coordinates yourself.',
    LocationProblem.unavailable =>
      'Location is unavailable. You can still report with manual coordinates or without a location.',
  };
}

abstract interface class LocationService {
  Future<LocationFix> current();
  Future<bool> openSettings({required bool locationServices});
}
