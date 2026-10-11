import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/app/relayaid_app.dart';
import 'package:relayaid_flutter/app/router/app_router.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_controller.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_provider.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/design_system/theme/app_theme.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/command_center/application/command_center_providers.dart';
import 'package:relayaid_flutter/features/command_center/presentation/incident_map.dart';
import 'package:relayaid_flutter/features/incidents/application/incident_controller.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_sync_state.dart';
import 'package:relayaid_flutter/features/media/application/media_providers.dart';
import 'package:relayaid_flutter/features/teams/application/team_providers.dart';

import 'support/assignment_fixture.dart';
import 'support/command_center_fixture.dart';
import 'support/media_fixture.dart';

void main() {
  late MediaFixture media;
  Future<ProviderContainer> mount(
    WidgetTester tester, {
    MemberRole role = MemberRole.administrator,
    Size size = const Size(390, 844),
    double textScale = 1,
    ConnectivityController? connection,
    bool savedReport = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = CommandCenterFixture();
    fixture.gateway.context.membership.role = role;
    await fixture.initialize();
    addTearDown(fixture.dispose);
    media = MediaFixture();
    media.context = fixture.gateway.context;
    addTearDown(() => media.dispose(ownsConnectivity: connection != null));
    if (savedReport) await media.report(Uuid().v7obj());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessControllerProvider.overrideWithValue(fixture.access),
          connectivityControllerProvider.overrideWith(
            (ref) => connection ?? media.connectivity,
          ),
          commandCenterRepositoryProvider.overrideWithValue(fixture.repository),
          mapTileProvider.overrideWith((ref) => TestMapTileProvider()),
          incidentControllerProvider.overrideWith(
            (ref) => IncidentController(media.incidents),
          ),
          attachmentRepositoryProvider.overrideWithValue(media.attachments),
          photoPickerProvider.overrideWithValue(media.picker),
          teamRepositoryProvider.overrideWithValue(FakeTeamRepository()),
        ],
        child: textScale == 1
            ? const RelayAidApp()
            : Consumer(
                builder: (context, ref, child) => MaterialApp.router(
                  theme: AppTheme.dark(),
                  routerConfig: ref.watch(appRouterProvider),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(textScale),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                ),
              ),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Future<void> tap(WidgetTester tester, String label) async {
    final finder = find.text(label);
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        250,
        scrollable: find.byType(Scrollable).last,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'administrator can report offline and find the saved report from the drawer',
    (tester) async {
      final container = await mount(tester);
      expect(find.text('Command center'), findsOneWidget);
      expect(find.text('Report incident'), findsOneWidget);
      await tap(tester, 'Report incident');
      expect(
        container.read(appRouterProvider).state.uri.path,
        AppRoutes.report,
      );
      expect(find.text('Step 1 of 3 · Incident'), findsOneWidget);
      expect(find.text('Report incident'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Flooded bridge',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Water has blocked the road.',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '12');
      await tap(tester, 'Continue');
      await tap(tester, 'Continue');
      await tap(tester, 'Save incident');
      expect((await media.incidents.list()).single.title, 'Flooded bridge');
      expect(media.incidentRemote.calls, 0);
      expect(find.text('Flooded bridge'), findsOneWidget);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tap(tester, 'Saved reports & sync');
      expect(find.text('Reports on this device'), findsOneWidget);
      expect(find.text('Check connection'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Flooded bridge'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Flooded bridge'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('coordinator desktop reporting and Profile stay accessible', (
    tester,
  ) async {
    final container = await mount(
      tester,
      role: MemberRole.coordinator,
      size: const Size(1440, 900),
    );
    expect(find.text('Report incident'), findsOneWidget);
    await tap(tester, 'Report incident');
    expect(container.read(appRouterProvider).state.uri.path, AppRoutes.report);
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Coordinator'), findsOneWidget);
    expect(find.text('Copy user ID'), findsOneWidget);
    await tester.tap(find.byTooltip('Saved reports & sync'));
    await tester.pumpAndSettle();
    expect(find.text('No saved reports yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'offline Settings explain member IDs, disable online-only writes and avoid an endless spinner',
    (tester) async {
      final container = await mount(
        tester,
        size: const Size(320, 850),
        textScale: 2,
      );
      container.read(appRouterProvider).go(AppRoutes.settings);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Check connection'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Check connection'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Connect before adding members'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('Connect before adding members'),
        findsOneWidget,
      );
      expect(find.text('Could not load organization settings.'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Add member'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Add member'));
      final add = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Add member'),
      );
      expect(add.onPressed, isNull);
      expect(
        find.textContaining('They should not create a separate organization'),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      container.read(appRouterProvider).go(AppRoutes.teams);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Connect to load members'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Connect to load members'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'saved device reports remain visible at large text with no overflow',
    (tester) async {
      final container = await mount(
        tester,
        size: const Size(320, 850),
        textScale: 2,
        savedReport: true,
      );
      expect(tester.takeException(), isNull);
      container.read(appRouterProvider).go(AppRoutes.syncCenter);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Flooded bridge'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Flooded bridge'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'synchronized device reports remain findable after the queue drains',
    (tester) async {
      final container = await mount(tester, savedReport: true);
      media.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await media.incidents.syncPending();
      container.read(appRouterProvider).go(AppRoutes.syncCenter);
      await tester.pumpAndSettle();
      final incident = container
          .read(incidentControllerProvider)
          .incidents
          .single;
      expect(
        container.read(incidentControllerProvider).syncStateFor(incident.id),
        IncidentSyncState.synced,
      );
      expect(find.text('0 reports waiting to synchronize.'), findsOneWidget);
      expect(find.text('Flooded bridge'), findsOneWidget);
      expect(find.text('No saved reports yet'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('field workers still cannot navigate to coordinator-only pages', (
    tester,
  ) async {
    final container = await mount(tester, role: MemberRole.fieldWorker);
    for (final path in [
      AppRoutes.overview,
      AppRoutes.teams,
      AppRoutes.activity,
      AppRoutes.settings,
    ]) {
      container.read(appRouterProvider).go(path);
      await tester.pumpAndSettle();
      expect(container.read(appRouterProvider).state.uri.path, AppRoutes.home);
    }
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets(
    'returning to the app rechecks a network change missed while suspended',
    (tester) async {
      final source = _ResumeSource();
      final connection = ConnectivityController(source: source);
      await connection.start();
      addTearDown(source.events.close);
      await mount(tester, connection: connection);
      source.result = [ConnectivityResult.wifi];
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(source.checks, 2);
      expect(connection.isOnline, isTrue);
      expect(find.text('Live updates connected'), findsOneWidget);
    },
  );
}

class _ResumeSource implements ConnectivitySource {
  final events = StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> result = [ConnectivityResult.none];
  int checks = 0;
  @override
  Future<List<ConnectivityResult>> check() async {
    checks++;
    return result;
  }

  @override
  Stream<List<ConnectivityResult>> get changes => events.stream;
}
