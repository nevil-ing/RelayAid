import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/app/relayaid_app.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_provider.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/design_system/theme/app_theme.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/command_center/application/command_center_providers.dart';
import 'package:relayaid_flutter/features/command_center/presentation/command_center_page.dart';
import 'package:relayaid_flutter/features/command_center/presentation/incident_map.dart';
import 'package:relayaid_flutter/features/media/application/media_providers.dart';

import 'support/command_center_fixture.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  setUpAll(() async {
    if (!autoUpdateGoldenFiles) return;
    // The test runner normally uses the unreadable Ahem font. Optional local
    // review captures load real SDK fonts without shipping them in the app.
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    for (final (family, files) in [
      (
        'Roboto',
        ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf'],
      ),
      ('Ahem', ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']),
      ('MaterialIcons', ['MaterialIcons-Regular.otf']),
    ]) {
      final loader = FontLoader(family);
      for (final file in files) {
        loader.addFont(
          File(
            '${artifacts.path}/material_fonts/$file',
          ).readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
    }
  });
  Widget appForReview() {
    if (!autoUpdateGoldenFiles) return const RelayAidApp();
    // Some isolated token styles still select Ahem in the test engine. Keep
    // this font-family substitution exclusive to optional review captures.
    final theme = AppTheme.light();
    final label = theme.textTheme.labelLarge!.copyWith(fontFamily: 'Roboto');
    final review = theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Roboto',
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: theme.filledButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll(label),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: theme.outlinedButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll(label),
        ),
      ),
      navigationRailTheme: theme.navigationRailTheme.copyWith(
        selectedLabelTextStyle: theme.navigationRailTheme.selectedLabelTextStyle
            ?.copyWith(fontFamily: 'Roboto'),
      ),
      navigationBarTheme: theme.navigationBarTheme.copyWith(
        labelTextStyle: WidgetStatePropertyAll(label),
      ),
    );
    return Consumer(
      builder: (context, ref, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: review,
        routerConfig: ref.watch(appRouterProvider),
      ),
    );
  }

  Future<CommandCenterFixture> mount(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    double textScale = 1,
    FakeCommandPhotos? photos,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final fixture = CommandCenterFixture();
    await fixture.initialize();
    final photoRepository = photos ?? FakeCommandPhotos();
    final incident = commandIncident();
    fixture.repository.details[incident.id!] = IncidentDetail(
      incident: incident,
      timeline: [commandEvent(incident)],
    );
    fixture.repository.current = commandFeed(
      [incident],
      activity: [
        IncidentActivity(
          event: commandEvent(incident),
          incidentTitle: incident.title,
        ),
      ],
    );
    addTearDown(() async {
      await fixture.dispose(ownsConnectivity: false);
      await photoRepository.notifications.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessControllerProvider.overrideWithValue(fixture.access),
          connectivityControllerProvider.overrideWith(
            (ref) => fixture.connectivity,
          ),
          commandCenterRepositoryProvider.overrideWithValue(fixture.repository),
          mapTileProvider.overrideWith((ref) => TestMapTileProvider()),
          attachmentRepositoryProvider.overrideWithValue(photoRepository),
        ],
        child: RepaintBoundary(
          key: const ValueKey('command-center-preview'),
          child: appForReview(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return fixture;
  }

  testWidgets(
    'desktop map, report list and activity update without a refresh',
    (tester) async {
      final fixture = await mount(tester);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(IncidentMap), findsOneWidget);
      expect(find.text('Live updates connected'), findsOneWidget);
      expect(
        find.byKey(ValueKey('incident-marker-${commandIncident().id}')),
        findsOneWidget,
      );
      final newIncident = commandIncident(
        number: 2,
        title: 'Medical request',
        latitude: -0.3032,
      );
      fixture.repository.emit(commandFeed([commandIncident(), newIncident]));
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey('incident-row-${newIncident.id}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('incident-marker-${newIncident.id}')),
        findsOneWidget,
      );
      expect(find.text('Reports · 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('command-center-preview')),
          matchesGoldenFile('../build/phase6-review/overview.png'),
        );
      }
    },
  );

  testWidgets(
    'escalation is visible live in the row, selected detail and timeline',
    (tester) async {
      final fixture = await mount(tester);
      final incident = commandIncident(severity: IncidentSeverity.critical)
          .copyWith(
            escalationDueAt: DateTime.utc(2026, 10, 7, 9),
            escalatedAt: DateTime.utc(2026, 10, 7, 9, 10),
          );
      final event = commandEvent(
        incident,
        number: 2,
        type: IncidentEventType.escalated,
      ).copyWith(actorId: null);
      fixture.repository.details[incident.id!] = IncidentDetail(
        incident: incident,
        timeline: [commandEvent(incident), event],
      );
      fixture.repository.emit(
        commandFeed(
          [incident],
          activity: [
            IncidentActivity(event: event, incidentTitle: incident.title),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Escalated · Needs coordinator attention'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(ValueKey('incident-row-${incident.id}')));
      await tester.pumpAndSettle();
      expect(find.text('Needs coordinator attention'), findsOneWidget);
      expect(find.text('Escalated automatically'), findsOneWidget);
      expect(find.text('By RelayAid scheduler'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('command-center-preview')),
          matchesGoldenFile('../build/phase8-review/escalation.png'),
        );
      }
      await tester.ensureVisible(
        find.byKey(const ValueKey('acknowledge-incident')),
      );
      await tester.tap(find.byKey(const ValueKey('acknowledge-incident')));
      await tester.pumpAndSettle();
      expect(
        find.text('Escalated · Needs coordinator attention'),
        findsNothing,
      );
      expect(find.text('Needs coordinator attention'), findsNothing);
      expect(find.text('Previous escalation'), findsOneWidget);
      expect(find.text('By RelayAid scheduler'), findsOneWidget);
    },
  );

  testWidgets(
    'map selection opens details and acknowledgement updates timeline live',
    (tester) async {
      final fixture = await mount(tester);
      await tester.tap(
        find.byKey(ValueKey('incident-marker-${commandIncident().id}')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Incident detail'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('acknowledge-incident')));
      await tester.pumpAndSettle();
      expect(fixture.repository.acknowledgeCalls, 1);
      expect(find.text('Status changed to Acknowledged'), findsOneWidget);
      expect(find.text('High severity · Acknowledged'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('command-center-preview')),
          matchesGoldenFile('../build/phase6-review/detail.png'),
        );
      }
    },
  );

  testWidgets(
    'severity and status filtering remove the same rows and map markers',
    (tester) async {
      final fixture = await mount(tester);
      final low = commandIncident(
        number: 2,
        title: 'Supplies needed',
        severity: IncidentSeverity.low,
      );
      fixture.repository.emit(commandFeed([commandIncident(), low]));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All severities'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('High').last);
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('incident-row-${low.id}')), findsNothing);
      expect(find.byKey(ValueKey('incident-marker-${low.id}')), findsNothing);
      await tester.tap(find.text('All statuses'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resolved').last);
      await tester.pumpAndSettle();
      expect(find.text('Reports · 0'), findsOneWidget);
      expect(
        find.byKey(ValueKey('incident-marker-${commandIncident().id}')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('live photo activity refreshes the selected photo repository', (
    tester,
  ) async {
    final photos = FakeCommandPhotos();
    final fixture = await mount(tester, photos: photos);
    final incident = commandIncident();
    await tester.tap(find.byKey(ValueKey('incident-row-${incident.id}')));
    await tester.pumpAndSettle();
    expect(photos.refreshCalls, 1);
    final event = commandEvent(
      incident,
      number: 2,
      type: IncidentEventType.attachmentAdded,
    );
    fixture.repository.details[incident.id!] = IncidentDetail(
      incident: incident,
      timeline: [commandEvent(incident), event],
    );
    fixture.repository.emit(
      commandFeed(
        [incident],
        activity: [
          IncidentActivity(event: event, incidentTitle: incident.title),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(photos.refreshCalls, 2);
    expect(find.text('Photo uploaded'), findsOneWidget);
  });

  testWidgets(
    'compact coordinator view supports large text, selection and closing',
    (tester) async {
      await mount(tester, size: const Size(390, 844), textScale: 1.5);
      expect(
        MediaQuery.textScalerOf(
          tester.element(find.byType(CommandCenterPage)),
        ).scale(20),
        30,
      );
      expect(find.byType(NavigationRail), findsNothing);
      await tester.ensureVisible(
        find.byKey(ValueKey('incident-row-${commandIncident().id}')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(ValueKey('incident-row-${commandIncident().id}')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Incident detail'));
      expect(find.text('Incident detail'), findsOneWidget);
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('command-center-preview')),
          matchesGoldenFile('../build/phase6-review/compact-detail.png'),
        );
      }
      await tester.ensureVisible(find.byTooltip('Close incident detail'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close incident detail'));
      await tester.pumpAndSettle();
      expect(find.byType(IncidentMap), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'offline keeps reports visible and recovery catches missed incidents',
    (tester) async {
      final fixture = await mount(tester);
      fixture.connectivity.setStatusForTest(ConnectivityStatus.offline);
      await tester.pumpAndSettle();
      expect(find.text('Offline · showing last update'), findsOneWidget);
      expect(find.text('Reports · 1'), findsOneWidget);
      fixture.repository.current = commandFeed([
        commandIncident(),
        commandIncident(number: 2),
      ]);
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await tester.pumpAndSettle();
      expect(find.text('Live updates connected'), findsOneWidget);
      expect(find.text('Reports · 2'), findsOneWidget);
    },
  );

  testWidgets('map and activity navigation use the real command-center views', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Map').first);
    await tester.pumpAndSettle();
    expect(find.text('Incident map'), findsOneWidget);
    expect(find.byType(IncidentMap), findsOneWidget);
    await tester.tap(find.text('Activity').first);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CommandCenterPage &&
            widget.view == CommandCenterView.activity,
      ),
      findsOneWidget,
    );
    expect(find.byType(IncidentMap), findsNothing);
    expect(find.textContaining('Incident reported'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
