import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:relayaid_flutter/core/location/device_location_service.dart';
import 'package:relayaid_flutter/core/location/location_controller.dart';
import 'package:relayaid_flutter/core/location/location_service.dart';
import 'package:relayaid_flutter/features/reporting/domain/report_validation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'GPS requests foreground permission only on demand and uses a timeout',
    () async {
      final platform = _LocationPlatform();
      final service = DeviceLocationService(platform: platform);
      expect(platform.requests, 0);
      final fix = await service.current();
      expect(platform.requests, 1);
      expect(fix.latitude, -0.3031);
      expect(fix.longitude, 36.08);
      expect(fix.accuracyMeters, 12);
      expect(platform.settings?.accuracy, LocationAccuracy.high);
      expect(platform.settings?.timeLimit, const Duration(seconds: 20));
    },
  );

  test('already granted permission is not requested again', () async {
    final platform = _LocationPlatform()
      ..permission = LocationPermission.whileInUse;
    await DeviceLocationService(platform: platform).current();
    expect(platform.requests, 0);
  });

  test('disabled services do not request permissions or a position', () async {
    final platform = _LocationPlatform()..enabled = false;
    await expectLater(
      DeviceLocationService(platform: platform).current(),
      throwsA(
        isA<LocationFailure>().having(
          (e) => e.problem,
          'problem',
          LocationProblem.disabled,
        ),
      ),
    );
    expect(platform.requests, 0);
    expect(platform.positions, 0);
  });

  test(
    'denied and permanently denied permissions have distinct safe recovery',
    () async {
      for (final permission in [
        LocationPermission.denied,
        LocationPermission.deniedForever,
      ]) {
        final platform = _LocationPlatform()..requestedPermission = permission;
        await expectLater(
          DeviceLocationService(platform: platform).current(),
          throwsA(
            isA<LocationFailure>().having(
              (e) => e.problem,
              'problem',
              permission == LocationPermission.denied
                  ? LocationProblem.denied
                  : LocationProblem.blocked,
            ),
          ),
        );
        expect(platform.positions, 0);
      }
    },
  );

  test(
    'timeout and unexpected platform errors never leak raw exceptions',
    () async {
      for (final error in [
        TimeoutException('native timeout'),
        StateError('private platform diagnostic'),
      ]) {
        final platform = _LocationPlatform()..error = error;
        final controller = LocationController(
          DeviceLocationService(platform: platform),
        );
        addTearDown(controller.dispose);
        expect(await controller.locate(), isNull);
        expect(controller.busy, isFalse);
        expect(controller.message, isNot(contains('private')));
        expect(
          controller.problem,
          error is TimeoutException
              ? LocationProblem.timeout
              : LocationProblem.unavailable,
        );
      }
    },
  );

  test(
    'a completed request after disposal does not update feature state',
    () async {
      final platform = _LocationPlatform()..pending = Completer<Position>();
      final controller = LocationController(
        DeviceLocationService(platform: platform),
      );
      final request = controller.locate();
      await Future<void>.delayed(Duration.zero);
      expect(await controller.locate(), isNull);
      expect(platform.positions, 1);
      controller.dispose();
      platform.pending!.complete(platform.position);
      expect(await request, isNull);
    },
  );

  test(
    'report validation matches server limits and rejects nonfinite coordinates',
    () {
      expect(ReportValidation.title('ab'), isNotNull);
      expect(ReportValidation.title('a' * 121), isNotNull);
      expect(ReportValidation.title('Flooded bridge'), isNull);
      expect(ReportValidation.peopleAffected('1000001'), isNotNull);
      expect(ReportValidation.peopleAffected('0'), isNull);
      expect(
        ReportValidation.coordinate('', latitude: true, other: ''),
        isNull,
      );
      expect(
        ReportValidation.coordinate('', latitude: true, other: '36'),
        isNotNull,
      );
      for (final invalid in ['NaN', 'Infinity', '-Infinity', '91']) {
        expect(
          ReportValidation.coordinate(invalid, latitude: true, other: '36'),
          isNotNull,
        );
      }
      expect(
        ReportValidation.coordinate('-90', latitude: true, other: '180'),
        isNull,
      );
      expect(
        ReportValidation.coordinate('180', latitude: false, other: '-90'),
        isNull,
      );
    },
  );
}

class _LocationPlatform extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.denied;
  LocationPermission requestedPermission = LocationPermission.whileInUse;
  int requests = 0;
  int positions = 0;
  LocationSettings? settings;
  Object? error;
  Completer<Position>? pending;
  final position = Position(
    longitude: 36.08,
    latitude: -0.3031,
    timestamp: DateTime.utc(2026, 10, 8),
    accuracy: 12,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return requestedPermission;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    positions++;
    settings = locationSettings;
    if (error != null) throw error!;
    return pending == null ? position : pending!.future;
  }
}
