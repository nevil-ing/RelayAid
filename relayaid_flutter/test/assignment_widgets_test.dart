import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/app/relayaid_app.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_provider.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/assignments/application/assignment_providers.dart';
import 'package:relayaid_flutter/features/command_center/application/command_center_providers.dart';
import 'package:relayaid_flutter/features/command_center/presentation/incident_map.dart';
import 'package:relayaid_flutter/features/media/application/media_providers.dart';
import 'package:relayaid_flutter/features/teams/application/team_providers.dart';
import 'package:relayaid_flutter/design_system/theme/app_theme.dart';

import 'support/assignment_fixture.dart';
import 'support/command_center_fixture.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  setUpAll(() async {
    if (!autoUpdateGoldenFiles) return;
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
  Future<void> setSize(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Widget appForReview() {
    if (!autoUpdateGoldenFiles) return const RelayAidApp();
    // Token styles without an explicit family otherwise use the test engine's
    // Ahem even after FontLoader loads Roboto. Substitute only the font family
    // for isolated review captures; normal tests and production are unchanged.
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

  Future<AssignmentFixture> responderMount(
    WidgetTester tester, {
    AssignmentStatus status = AssignmentStatus.pending,
    double scale = 1,
    UuidValue? acceptedBy,
  }) async {
    await setSize(tester, scale: scale);
    final fixture = AssignmentFixture();
    await fixture.initialize();
    final photos = FakeCommandPhotos();
    final detail = assignmentDetail(status: status, acceptedBy: acceptedBy);
    fixture.repository.details[assignmentId] = detail;
    fixture.repository.current = assignmentFeed([assignmentSummary(detail)]);
    addTearDown(() async {
      await fixture.dispose(ownsConnectivity: false);
      await photos.notifications.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessControllerProvider.overrideWithValue(fixture.access),
          connectivityControllerProvider.overrideWith(
            (ref) => fixture.connectivity,
          ),
          assignmentRepositoryProvider.overrideWithValue(fixture.repository),
          attachmentRepositoryProvider.overrideWithValue(photos),
        ],
        child: RepaintBoundary(
          key: const ValueKey('phase7-preview'),
          child: appForReview(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return fixture;
  }

  Future<CommandCenterFixture> coordinatorMount(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    double scale = 1,
  }) async {
    await setSize(tester, size: size, scale: scale);
    final fixture = CommandCenterFixture();
    await fixture.initialize();
    final incident = commandIncident();
    fixture.repository.details[incident.id!] = IncidentDetail(
      incident: incident,
      timeline: [commandEvent(incident)],
    );
    fixture.repository.current = commandFeed([
      incident,
    ]).copyWith(teams: [assignmentRoster()]);
    final photos = FakeCommandPhotos();
    addTearDown(() async {
      await fixture.dispose(ownsConnectivity: false);
      await photos.notifications.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessControllerProvider.overrideWithValue(fixture.access),
          connectivityControllerProvider.overrideWith(
            (ref) => fixture.connectivity,
          ),
          commandCenterRepositoryProvider.overrideWithValue(fixture.repository),
          attachmentRepositoryProvider.overrideWithValue(photos),
          mapTileProvider.overrideWith((ref) => TestMapTileProvider()),
          teamRepositoryProvider.overrideWithValue(FakeTeamRepository()),
        ],
        child: RepaintBoundary(
          key: const ValueKey('phase7-preview'),
          child: appForReview(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return fixture;
  }

  testWidgets(
    'responder sees a live inbox and accepts, responds, and resolves with a timeline',
    (tester) async {
      final fixture = await responderMount(tester);
      expect(find.text('Your assignments'), findsOneWidget);
      expect(find.text('Report incident'), findsNothing);
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('phase7-preview')),
          matchesGoldenFile('../build/phase7-review/inbox.png'),
        );
      }
      await tester.tap(find.byKey(ValueKey('assignment-$assignmentId')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('accept-assignment')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('start-response')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('start-response')));
      await tester.pumpAndSettle();
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('phase7-preview')),
          matchesGoldenFile('../build/phase7-review/responding.png'),
        );
      }
      await tester.enterText(
        find.byKey(const ValueKey('resolution-note')),
        'Crossing secured.',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('resolve-assignment')),
      );
      await tester.tap(find.byKey(const ValueKey('resolve-assignment')));
      await tester.pumpAndSettle();
      expect(fixture.repository.actions, 3);
      expect(find.byKey(const ValueKey('resolve-assignment')), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Incident resolved'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Crossing secured.'), findsOneWidget);
      expect(find.text('Team assigned'), findsOneWidget);
      expect(find.text('Assignment accepted'), findsOneWidget);
      expect(find.text('Response started'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'offline assignment keeps its detail and exposes a disabled action',
    (tester) async {
      final fixture = await responderMount(tester);
      await tester.tap(find.byKey(ValueKey('assignment-$assignmentId')));
      await tester.pumpAndSettle();
      fixture.connectivity.setStatusForTest(ConnectivityStatus.offline);
      await tester.pumpAndSettle();
      expect(find.text('Offline · showing last update'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('accept-assignment')),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.text(
          'Reconnect before updating this response. Offline changes are not queued.',
        ),
        findsOneWidget,
      );
      expect(fixture.repository.actions, 0);
    },
  );

  testWidgets('competing responder cannot update a response already claimed', (
    tester,
  ) async {
    await responderMount(
      tester,
      status: AssignmentStatus.accepted,
      acceptedBy: Uuid().v4obj(),
    );
    await tester.tap(find.byKey(ValueKey('assignment-$assignmentId')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('start-response')), findsNothing);
    expect(
      find.text(
        'Another responder is leading this response. Only that responder can update it.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('responder controls remain reachable with 150 percent text', (
    tester,
  ) async {
    await responderMount(
      tester,
      status: AssignmentStatus.responding,
      scale: 1.5,
    );
    await tester.tap(find.byKey(ValueKey('assignment-$assignmentId')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('resolution-note')));
    await tester.enterText(
      find.byKey(const ValueKey('resolution-note')),
      'Crossing secured.',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('resolve-assignment')),
    );
    await tester.tap(find.byKey(const ValueKey('resolve-assignment')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('resolve-assignment')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'coordinator selects a real roster and assigns the selected report',
    (tester) async {
      final fixture = await coordinatorMount(tester);
      await tester.tap(
        find.byKey(ValueKey('incident-row-${commandIncident().id}')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('assignment-team')));
      await tester.tap(find.byKey(const ValueKey('assignment-team')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Team Alpha · 0 active').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('assign-team-submit')),
      );
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('phase7-preview')),
          matchesGoldenFile('../build/phase7-review/assign-team.png'),
        );
      }
      await tester.tap(find.byKey(const ValueKey('assign-team-submit')));
      await tester.pumpAndSettle();
      expect(fixture.repository.assignCalls, 1);
      expect(find.text('Team Alpha'), findsOneWidget);
      expect(find.text('Awaiting acceptance'), findsOneWidget);
      expect(find.byKey(const ValueKey('assign-team-submit')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'coordinator team form remains usable at phone width and larger text',
    (tester) async {
      await coordinatorMount(tester, size: const Size(390, 844), scale: 1.5);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      expect(find.text('Response teams'), findsOneWidget);
      expect(find.text('0 active assignments · 1 responder'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('new-team-name')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byKey(const ValueKey('new-team-name')),
        'Team Bravo',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('create-team-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('create-team-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
