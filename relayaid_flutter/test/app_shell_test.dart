import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/app/relayaid_app.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_controller.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_provider.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/command_center/application/command_center_providers.dart';
import 'package:relayaid_flutter/features/command_center/presentation/incident_map.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/auth/domain/auth_gateway.dart';
import 'package:relayaid_flutter/features/incidents/application/incident_controller.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_repository.dart';
import 'support/command_center_fixture.dart';

void main() {
  group('role-aware application shell', () {
    testWidgets('field worker gets field navigation at iPhone width', (
      tester,
    ) async {
      await _setSurfaceSize(tester, const Size(390, 844));
      final access = await _accessFor(MemberRole.fieldWorker);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessControllerProvider.overrideWithValue(access),
            incidentControllerProvider.overrideWith(
              (ref) => IncidentController(_FakeIncidentRepository()),
            ),
          ],
          child: const RelayAidApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.bySemanticsLabel('Field navigation'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('field worker stays in field shell on desktop', (tester) async {
      await _setSurfaceSize(tester, const Size(1440, 900));
      final access = await _accessFor(MemberRole.fieldWorker);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessControllerProvider.overrideWithValue(access),
            incidentControllerProvider.overrideWith(
              (ref) => IncidentController(_FakeIncidentRepository()),
            ),
          ],
          child: const RelayAidApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('coordinator gets command center navigation', (tester) async {
      await _setSurfaceSize(tester, const Size(1440, 900));
      final access = await _accessFor(MemberRole.coordinator);
      final feed = FakeCommandCenterRepository()
        ..current = commandFeed(
          [],
        ).copyWith(organizationId: access.context!.organization.id!);
      addTearDown(feed.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessControllerProvider.overrideWithValue(access),
            commandCenterRepositoryProvider.overrideWithValue(feed),
            mapTileProvider.overrideWith((ref) => TestMapTileProvider()),
            connectivityControllerProvider.overrideWith(
              (ref) =>
                  ConnectivityController()
                    ..setStatusForTest(ConnectivityStatus.connected),
            ),
            incidentControllerProvider.overrideWith(
              (ref) => IncidentController(_FakeIncidentRepository()),
            ),
          ],
          child: const RelayAidApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Overview'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Command center navigation',
        ),
        findsOneWidget,
      );
    });

    testWidgets('coordinator shell remains usable at phone width', (
      tester,
    ) async {
      await _setSurfaceSize(tester, const Size(390, 844));
      final access = await _accessFor(MemberRole.coordinator);
      final feed = FakeCommandCenterRepository()
        ..current = commandFeed(
          [],
        ).copyWith(organizationId: access.context!.organization.id!);
      addTearDown(feed.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessControllerProvider.overrideWithValue(access),
            commandCenterRepositoryProvider.overrideWithValue(feed),
            mapTileProvider.overrideWith((ref) => TestMapTileProvider()),
            connectivityControllerProvider.overrideWith(
              (ref) =>
                  ConnectivityController()
                    ..setStatusForTest(ConnectivityStatus.connected),
            ),
            incidentControllerProvider.overrideWith(
              (ref) => IncidentController(_FakeIncidentRepository()),
            ),
          ],
          child: const RelayAidApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Teams'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('restored identity reloads its server-held membership', () async {
    final gateway = _FakeAuthGateway(_contextFor(MemberRole.responder));
    final access = AccessController(gateway);
    await access.initialize();
    expect(gateway.restoreCalls, 1);
    expect(access.status, AccessStatus.ready);
    expect(access.context?.membership.role, MemberRole.responder);
    access.dispose();
  });
}

Future<AccessController> _accessFor(MemberRole role) async {
  final access = AccessController(_FakeAuthGateway(_contextFor(role)));
  await access.initialize();
  addTearDown(access.dispose);
  return access;
}

OrganizationContext _contextFor(MemberRole role) {
  final organizationId = UuidValue.fromString(
    '018fbfa5-2406-7c9a-b429-d35a857e5a51',
  );
  final userId = UuidValue.fromString('018fbfa5-2406-7c9a-b429-d35a857e5a52');
  return OrganizationContext(
    organization: Organization(
      id: organizationId,
      name: 'RelayAid Response',
      createdBy: userId,
    ),
    membership: OrganizationMember(
      id: UuidValue.fromString('018fbfa5-2406-7c9a-b429-d35a857e5a53'),
      organizationId: organizationId,
      authUserId: userId,
      role: role,
    ),
  );
}

class _FakeAuthGateway extends ChangeNotifier implements AuthGateway {
  _FakeAuthGateway(this._context);

  final OrganizationContext _context;
  int restoreCalls = 0;

  @override
  bool get isAuthenticated => true;

  @override
  UuidValue? get userId => _context.membership.authUserId;

  @override
  Future<void> restore() async => restoreCalls++;

  @override
  Future<void> signOut() async {}

  @override
  Future<OrganizationContext?> myContext() async => _context;

  @override
  Future<OrganizationContext> createOrganization(String name) async => _context;

  @override
  Future<OrganizationMember> addMember(
    UuidValue organizationId,
    UuidValue authUserId,
    MemberRole role,
  ) async => throw UnimplementedError();

  @override
  Future<Team> createTeam(UuidValue organizationId, String name) async =>
      throw UnimplementedError();

  @override
  Future<List<OrganizationMember>> listMembers(
    UuidValue organizationId,
  ) async => [_context.membership];

  @override
  Future<List<Team>> listTeams(UuidValue organizationId) async => [];
}

class _FakeIncidentRepository implements IncidentRepository {
  @override
  Future<IncidentDetail> create({
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) => throw UnimplementedError();

  @override
  Future<IncidentDetail> detail(UuidValue incidentId) =>
      throw UnimplementedError();

  @override
  Future<List<Incident>> list({int limit = 50}) async => [];

  @override
  Future<IncidentDetail> transition(
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) => throw UnimplementedError();
}

Future<void> _setSurfaceSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
