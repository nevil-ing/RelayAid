import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/design_system/theme/app_theme.dart';
import 'package:relayaid_flutter/features/command_center/presentation/command_incident_list.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_attention.dart';
import 'package:relayaid_flutter/features/incidents/presentation/incident_escalation_notice.dart';
import 'package:relayaid_flutter/features/incidents/presentation/incident_timeline.dart';

import 'support/command_center_fixture.dart';

void main() {
  final now = DateTime.utc(2026, 10, 7, 9, 10);
  Incident escalated() =>
      commandIncident(severity: IncidentSeverity.critical).copyWith(
        escalationDueAt: now.subtract(const Duration(seconds: 1)),
        escalatedAt: now,
      );

  Widget app(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  test('only outstanding critical escalations need coordinator attention', () {
    final incident = escalated();
    expect(incident.needsCoordinatorAttention, isTrue);
    expect(commandIncident().needsCoordinatorAttention, isFalse);
    for (final status in IncidentStatus.values) {
      if (status == IncidentStatus.reported) continue;
      expect(
        incident.copyWith(status: status).needsCoordinatorAttention,
        isFalse,
      );
    }
    expect(
      incident
          .copyWith(severity: IncidentSeverity.high)
          .needsCoordinatorAttention,
      isFalse,
    );
  });

  test(
    'old cached reports remain readable and new escalation fields round-trip',
    () {
      final oldJson = commandIncident().toJson()
        ..remove('escalationDueAt')
        ..remove('escalatedAt');
      final old = Incident.fromJson(oldJson);
      expect(old.escalationDueAt, isNull);
      expect(old.escalatedAt, isNull);
      final fresh = escalated();
      final saved = Incident.fromJson(fresh.toJson());
      expect(saved.escalatedAt, fresh.escalatedAt);
      expect(saved.escalationDueAt, fresh.escalationDueAt);
      final event = IncidentEvent(
        incidentId: fresh.id!,
        organizationId: fresh.organizationId,
        eventType: IncidentEventType.escalated,
        actorId: null,
      );
      expect(IncidentEvent.fromJson(event.toJson()).actorId, isNull);
    },
  );

  testWidgets(
    'list uses text as well as color and removes warning after acknowledgement',
    (tester) async {
      final incident = escalated();
      await tester.pumpWidget(
        app(
          CommandIncidentList(
            incidents: [incident],
            selectedId: null,
            onSelect: (_) {},
          ),
        ),
      );
      expect(
        find.text('Escalated · Needs coordinator attention'),
        findsOneWidget,
      );
      await tester.pumpWidget(
        app(
          CommandIncidentList(
            incidents: [incident.copyWith(status: IncidentStatus.acknowledged)],
            selectedId: null,
            onSelect: (_) {},
          ),
        ),
      );
      expect(
        find.text('Escalated · Needs coordinator attention'),
        findsNothing,
      );
    },
  );

  testWidgets('detail warning becomes historical after assignment', (
    tester,
  ) async {
    final incident = escalated();
    await tester.pumpWidget(app(IncidentEscalationNotice(incident: incident)));
    expect(find.text('Needs coordinator attention'), findsOneWidget);
    await tester.pumpWidget(
      app(
        IncidentEscalationNotice(
          incident: incident.copyWith(status: IncidentStatus.assigned),
        ),
      ),
    );
    expect(find.text('Needs coordinator attention'), findsNothing);
    expect(find.text('Previous escalation'), findsOneWidget);
    expect(find.textContaining('Escalated automatically'), findsOneWidget);
  });

  testWidgets(
    'timeline identifies the real human and the automated scheduler',
    (tester) async {
      final incident = escalated();
      await tester.pumpWidget(
        app(
          SingleChildScrollView(
            child: IncidentTimeline(
              events: [
                commandEvent(incident),
                IncidentEvent(
                  incidentId: incident.id!,
                  organizationId: incident.organizationId,
                  eventType: IncidentEventType.escalated,
                  actorId: null,
                  createdAt: now,
                  note: 'Coordinator attention required.',
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Escalated automatically'), findsOneWidget);
      expect(find.text('By RelayAid scheduler'), findsOneWidget);
      expect(find.text('By $commandUserId'), findsOneWidget);
      expect(find.text('By null'), findsNothing);
    },
  );

  testWidgets(
    'narrow screens with large text retain readable escalation details',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        app(IncidentEscalationNotice(incident: escalated())),
      );
      expect(find.text('Needs coordinator attention'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
