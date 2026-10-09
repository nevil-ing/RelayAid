import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/app/relayaid_app.dart';
import 'package:relayaid_flutter/app/router/app_router.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_provider.dart';
import 'package:relayaid_flutter/design_system/theme/app_theme.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/incidents/application/incident_controller.dart';
import 'package:relayaid_flutter/features/map/presentation/incident_map.dart';
import 'package:relayaid_flutter/features/media/application/media_providers.dart';

import 'support/command_center_fixture.dart';
import 'support/media_fixture.dart';

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester, {
    bool large = false,
  }) async {
    tester.view.physicalSize = Size(large ? 320 : 390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final access = CommandCenterFixture();
    access.gateway.context.membership.role = MemberRole.fieldWorker;
    await access.initialize();
    addTearDown(access.dispose);
    final media = MediaFixture();
    addTearDown(() => media.dispose(ownsConnectivity: false));
    await media.report(Uuid().v7obj());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessControllerProvider.overrideWithValue(access.access),
          connectivityControllerProvider.overrideWith(
            (ref) => media.connectivity,
          ),
          incidentControllerProvider.overrideWith(
            (ref) => IncidentController(media.incidents),
          ),
          mapTileProvider.overrideWith((ref) => TestMapTileProvider()),
          attachmentRepositoryProvider.overrideWithValue(media.attachments),
          photoPickerProvider.overrideWithValue(media.picker),
        ],
        child: Consumer(
          builder: (context, ref, child) => MaterialApp.router(
            theme: large ? AppTheme.dark() : AppTheme.light(),
            routerConfig: ref.watch(appRouterProvider),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(large ? 2 : 1)),
              child: child!,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  testWidgets(
    'Home exposes offline reporting and saved incidents without duplicate primary actions',
    (tester) async {
      final container = await mount(tester);
      final id = container
          .read(incidentControllerProvider)
          .incidents
          .single
          .id!;
      expect(find.text('Report incident'), findsOneWidget);
      expect(
        find.textContaining('Offline. Reports and photos'),
        findsOneWidget,
      );
      expect(find.text('Flooded bridge'), findsOneWidget);
      expect(find.text('View synchronization and photo queue'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Flooded bridge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Flooded bridge'));
      await tester.pumpAndSettle();
      expect(
        container.read(incidentControllerProvider).selected?.incident.id,
        id,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('field map selects a real saved incident and opens its detail', (
    tester,
  ) async {
    final container = await mount(tester);
    container.read(appRouterProvider).go(AppRoutes.map);
    await tester.pumpAndSettle();
    final controller = container.read(incidentControllerProvider);
    final id = controller.incidents.single.id!;
    expect(find.byKey(ValueKey('incident-marker-$id')), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('incident-marker-$id')));
    await tester.pumpAndSettle();
    expect(find.text('Flooded bridge'), findsOneWidget);
    expect(
      find.textContaining('coordinates and saved reports remain'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Flooded bridge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flooded bridge'));
    await tester.pumpAndSettle();
    expect(
      container.read(incidentControllerProvider).selected?.incident.id,
      id,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'member ID is copyable and role labels fit 200% text in dark mode',
    (tester) async {
      final container = await mount(tester, large: true);
      expect(tester.takeException(), isNull);
      container.read(appRouterProvider).go(AppRoutes.profile);
      await tester.pumpAndSettle();
      expect(find.text('Field worker'), findsOneWidget);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.ensureVisible(find.text('Copy user ID'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy user ID'));
      await tester.pumpAndSettle();
      expect(copied, commandUserId.toString());
      expect(find.textContaining('User ID copied.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
