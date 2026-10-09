import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_flutter/core/location/location_controller.dart';
import 'package:relayaid_flutter/core/location/location_service.dart';
import 'package:relayaid_flutter/design_system/theme/app_theme.dart';
import 'package:relayaid_flutter/features/incidents/application/incident_controller.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_sync_state.dart';
import 'package:relayaid_flutter/features/media/application/media_providers.dart';
import 'package:relayaid_flutter/features/reporting/presentation/report_incident_page.dart';

import 'support/media_fixture.dart';

void main() {
  Future<MediaFixture> mount(
    WidgetTester tester, {
    LocationProblem? problem,
    bool large = false,
  }) async {
    tester.view.physicalSize = large
        ? const Size(320, 850)
        : const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final media = MediaFixture();
    final png = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.white, BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(2, 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      picture.dispose();
      return bytes!.buffer.asUint8List();
    });
    media.picker.bytes = png!;
    addTearDown(media.dispose);
    final router = GoRouter(
      initialLocation: '/report',
      routes: [
        GoRoute(
          path: '/report',
          builder: (context, state) =>
              const Scaffold(body: ReportIncidentPage()),
        ),
        GoRoute(
          path: '/incidents/preview',
          builder: (context, state) =>
              const Scaffold(body: Text('Saved detail')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          attachmentRepositoryProvider.overrideWithValue(media.attachments),
          photoPickerProvider.overrideWithValue(media.picker),
          incidentControllerProvider.overrideWith(
            (ref) => IncidentController(media.incidents),
          ),
          locationServiceProvider.overrideWithValue(_LocationService(problem)),
        ],
        child: MaterialApp.router(
          theme: large ? AppTheme.dark() : AppTheme.light(),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(large ? 2 : 1),
              disableAnimations: large,
            ),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return media;
  }

  Future<void> tap(WidgetTester tester, String text) async {
    if (find.text(text).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.text(text),
        300,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> enterIncident(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'Flooded bridge');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Water has blocked the only crossing.',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '12');
    await tap(tester, 'Continue');
  }

  testWidgets('offline flood with GPS and photo saves only after review', (
    tester,
  ) async {
    final media = await mount(tester);
    await enterIncident(tester);
    await tap(tester, 'Use current location');
    expect(find.textContaining('Location captured'), findsOneWidget);
    await tap(tester, 'Choose photo');
    await tap(tester, 'Continue');
    expect(find.text('Review your report'), findsOneWidget);
    expect(find.text('Photos: 1'), findsOneWidget);
    expect(find.text('-0.303100, 36.080000'), findsOneWidget);
    expect(await media.incidents.list(), isEmpty);
    await tap(tester, 'Save incident');
    final incident = (await media.incidents.list()).single;
    expect(incident.latitude, -0.3031);
    expect(incident.longitude, 36.08);
    expect(incident.peopleAffected, 12);
    expect(
      await media.incidents.syncStateFor(incident.id!),
      IncidentSyncState.offline,
    );
    expect(await media.attachments.list(incident.id!), hasLength(1));
    expect(media.incidentRemote.calls, 0);
    expect(find.text('Saved detail'), findsOneWidget);
  });

  testWidgets(
    'back navigation preserves inputs and permission denial does not block reporting',
    (tester) async {
      final media = await mount(tester, problem: LocationProblem.denied);
      await enterIncident(tester);
      await tap(tester, 'Use current location');
      expect(
        find.textContaining('Location access was not allowed'),
        findsOneWidget,
      );
      await tap(tester, 'Back');
      expect(find.text('Flooded bridge'), findsOneWidget);
      await tap(tester, 'Continue');
      await tap(tester, 'Continue');
      expect(find.text('Not provided'), findsOneWidget);
      await tap(tester, 'Save incident');
      expect((await media.incidents.list()).single.latitude, isNull);
    },
  );

  testWidgets('partial and nonfinite manual coordinates cannot reach review', (
    tester,
  ) async {
    await mount(tester);
    await enterIncident(tester);
    await tester.enterText(find.byType(TextFormField).at(0), '-0.3');
    await tap(tester, 'Continue');
    expect(find.text('Enter both coordinates.'), findsWidgets);
    await tester.enterText(find.byType(TextFormField).at(0), 'NaN');
    await tester.enterText(find.byType(TextFormField).at(1), '36.08');
    await tap(tester, 'Continue');
    expect(find.text('Enter a value from -90 to 90.'), findsOneWidget);
    expect(find.text('Review your report'), findsNothing);
  });

  testWidgets('all report steps fit a narrow dark-mode screen at 200% text', (
    tester,
  ) async {
    await mount(tester, large: true);
    await enterIncident(tester);
    expect(tester.takeException(), isNull);
    await tap(tester, 'Use current location');
    await tap(tester, 'Continue');
    expect(tester.takeException(), isNull);
    await tap(tester, 'Back');
    expect(tester.takeException(), isNull);
  });
}

class _LocationService implements LocationService {
  _LocationService(this.problem);
  final LocationProblem? problem;
  @override
  Future<LocationFix> current() async {
    if (problem != null) throw LocationFailure(problem!);
    return const LocationFix(
      latitude: -0.3031,
      longitude: 36.08,
      accuracyMeters: 12,
    );
  }

  @override
  Future<bool> openSettings({required bool locationServices}) async => false;
}
