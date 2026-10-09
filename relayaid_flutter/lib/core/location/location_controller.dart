import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'device_location_service.dart';
import 'location_service.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => DeviceLocationService(),
);

final locationControllerProvider =
    ChangeNotifierProvider.autoDispose<LocationController>(
      (ref) => LocationController(ref.watch(locationServiceProvider)),
    );

class LocationController extends ChangeNotifier {
  LocationController(this._service);
  final LocationService _service;
  bool busy = false;
  LocationFix? fix;
  LocationProblem? problem;
  String? message;
  bool _disposed = false;

  Future<LocationFix?> locate() async {
    if (busy) return null;
    busy = true;
    problem = null;
    message = null;
    notifyListeners();
    LocationFix? result;
    try {
      result = await _service.current();
      if (!result.isValid) {
        throw const LocationFailure(LocationProblem.unavailable);
      }
      if (!_disposed) fix = result;
    } catch (error) {
      final failure = error is LocationFailure
          ? error
          : const LocationFailure(LocationProblem.unavailable);
      if (!_disposed) {
        problem = failure.problem;
        message = failure.message;
      }
    }
    if (_disposed) return null;
    busy = false;
    notifyListeners();
    return problem == null ? result : null;
  }

  Future<void> openSettings() async {
    final opened = await _service.openSettings(
      locationServices: problem == LocationProblem.disabled,
    );
    if (_disposed) return;
    message = opened
        ? 'Return here and choose Use current location again.'
        : 'Open your device or browser location settings, or enter coordinates yourself.';
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
