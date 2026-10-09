import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'location_service.dart';

class DeviceLocationService implements LocationService {
  DeviceLocationService({GeolocatorPlatform? platform})
    : _platform = platform ?? GeolocatorPlatform.instance;

  final GeolocatorPlatform _platform;

  @override
  Future<LocationFix> current() async {
    try {
      if (!await _platform.isLocationServiceEnabled()) {
        throw const LocationFailure(LocationProblem.disabled);
      }
      var permission = await _platform.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _platform.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationFailure(LocationProblem.blocked);
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw const LocationFailure(LocationProblem.denied);
      }
      final position = await _platform.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final fix = LocationFix(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
      if (!fix.isValid) {
        throw const LocationFailure(LocationProblem.unavailable);
      }
      return fix;
    } on LocationFailure {
      rethrow;
    } on TimeoutException {
      throw const LocationFailure(LocationProblem.timeout);
    } on LocationServiceDisabledException {
      throw const LocationFailure(LocationProblem.disabled);
    } on PermissionDeniedException {
      throw const LocationFailure(LocationProblem.denied);
    } catch (_) {
      throw const LocationFailure(LocationProblem.unavailable);
    }
  }

  @override
  Future<bool> openSettings({required bool locationServices}) async {
    if (kIsWeb) return false;
    try {
      return locationServices
          ? await _platform.openLocationSettings()
          : await _platform.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}
