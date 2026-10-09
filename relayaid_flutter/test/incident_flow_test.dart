import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/features/incidents/application/incident_controller.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_repository.dart';
import 'package:relayaid_flutter/features/incidents/presentation/report_incident_page.dart';
import 'package:relayaid_flutter/features/media/application/media_providers.dart';
import 'support/media_fixture.dart';

void main() {
  testWidgets(
    'report form submits an online incident and navigates to detail',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = _FakeIncidentRepository();
      final media = MediaFixture();
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
                const Scaffold(body: Text('incident detail')),
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
              (ref) => IncidentController(repository),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Flooded bridge',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Water has blocked the only crossing.',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '12');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      final submitButton = find.text('Save incident');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(repository.createCalls, 1);
      expect(repository.lastTitle, 'Flooded bridge');
      expect(find.text('incident detail'), findsOneWidget);
    },
  );

  testWidgets('report form blocks invalid required fields', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _FakeIncidentRepository();
    final media = MediaFixture();
    addTearDown(media.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          attachmentRepositoryProvider.overrideWithValue(media.attachments),
          photoPickerProvider.overrideWithValue(media.picker),
          incidentControllerProvider.overrideWith(
            (ref) => IncidentController(repository),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ReportIncidentPage())),
      ),
    );

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(repository.createCalls, 0);
    expect(find.text('Add a title of 3–120 characters.'), findsOneWidget);
    expect(
      find.text('Describe what happened in 3–5000 characters.'),
      findsOneWidget,
    );
  });
}

class _FakeIncidentRepository implements IncidentRepository {
  int createCalls = 0;
  String? lastTitle;

  final _incidentId = UuidValue.fromString(
    '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f001',
  );
  final _organizationId = UuidValue.fromString(
    '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f002',
  );
  final _userId = UuidValue.fromString('0199f2e9-9a4a-7e00-9a1f-4a6be0a1f003');

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
  }) async {
    createCalls++;
    lastTitle = title.trim();
    return _detail(
      title: lastTitle!,
      description: description.trim(),
      type: type,
      severity: severity,
      peopleAffected: peopleAffected,
    );
  }

  @override
  Future<IncidentDetail> detail(UuidValue incidentId) async => _detail();

  @override
  Future<List<Incident>> list({int limit = 50}) async => [];

  @override
  Future<IncidentDetail> transition(
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) async => _detail(status: nextStatus);

  IncidentDetail _detail({
    String title = 'Flooded bridge',
    String description = 'Water has blocked the only crossing.',
    IncidentType type = IncidentType.flooding,
    IncidentSeverity severity = IncidentSeverity.moderate,
    IncidentStatus status = IncidentStatus.reported,
    int peopleAffected = 12,
  }) {
    final incident = Incident(
      id: _incidentId,
      organizationId: _organizationId,
      type: type,
      severity: severity,
      status: status,
      title: title,
      description: description,
      peopleAffected: peopleAffected,
      reportedBy: _userId,
    );
    return IncidentDetail(
      incident: incident,
      timeline: [
        IncidentEvent(
          incidentId: _incidentId,
          organizationId: _organizationId,
          eventType: IncidentEventType.created,
          actorId: _userId,
          toStatus: IncidentStatus.reported,
        ),
      ],
    );
  }
}
