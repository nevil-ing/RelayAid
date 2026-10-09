import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/command_center/application/command_center_controller.dart';
import 'package:relayaid_flutter/features/command_center/domain/incident_filter.dart';

import 'support/command_center_fixture.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late CommandCenterFixture fixture;
  late CommandCenterController controller;
  setUp(() async {
    fixture = CommandCenterFixture();
    await fixture.initialize();
    controller = CommandCenterController(
      repository: fixture.repository,
      access: fixture.access,
      connectivity: fixture.connectivity,
      retryDelays: const [Duration(milliseconds: 5)],
    )..start();
    await flush();
  });
  tearDown(() async {
    controller.dispose();
    await fixture.dispose();
  });

  test(
    'new reports and status/activity updates arrive without refreshing',
    () async {
      final incident = commandIncident();
      fixture.repository.emit(commandFeed([incident]));
      await flush();
      expect(controller.status, LiveFeedStatus.live);
      expect(controller.visibleIncidents.single.id, incident.id);
      final event = commandEvent(
        incident,
        number: 2,
        type: IncidentEventType.statusChanged,
        status: IncidentStatus.acknowledged,
      );
      fixture.repository.emit(
        commandFeed(
          [incident.copyWith(status: IncidentStatus.acknowledged)],
          activity: [
            IncidentActivity(event: event, incidentTitle: incident.title),
          ],
        ),
      );
      await flush();
      expect(
        controller.visibleIncidents.single.status,
        IncidentStatus.acknowledged,
      );
      expect(controller.activity.single.event.id, event.id);
      expect(fixture.repository.connections, hasLength(1));
    },
  );

  test(
    'escalation snapshots refresh selected detail and retain server priority',
    () async {
      final incident = commandIncident(severity: IncidentSeverity.critical);
      fixture.repository.details[incident.id!] = IncidentDetail(
        incident: incident,
        timeline: [commandEvent(incident)],
      );
      fixture.repository.emit(commandFeed([incident]));
      await flush();
      controller.select(incident.id);
      await flush();
      final escalated = incident.copyWith(
        escalatedAt: DateTime.utc(2026, 10, 7),
      );
      final event = commandEvent(
        incident,
        number: 2,
        type: IncidentEventType.escalated,
      ).copyWith(actorId: null);
      fixture.repository.details[incident.id!] = IncidentDetail(
        incident: escalated,
        timeline: [commandEvent(incident), event],
      );
      fixture.repository.emit(
        commandFeed(
          [escalated, commandIncident(number: 2)],
          activity: [
            IncidentActivity(event: event, incidentTitle: incident.title),
          ],
        ),
      );
      await flush();
      expect(controller.visibleIncidents.first.id, incident.id);
      expect(controller.selected!.incident.escalatedAt, isNotNull);
      expect(
        controller.selected!.timeline.last.eventType,
        IncidentEventType.escalated,
      );
      expect(fixture.repository.connections, hasLength(1));
    },
  );

  test(
    'search, severity and status filters combine and preserve live updates',
    () async {
      fixture.repository.emit(
        commandFeed([
          commandIncident(),
          commandIncident(
            number: 2,
            title: 'Medical response',
            severity: IncidentSeverity.low,
          ),
          commandIncident(
            number: 3,
            title: 'Flood resolved',
            status: IncidentStatus.resolved,
          ),
        ]),
      );
      await flush();
      controller.search(' FLOOD ');
      controller.filterSeverity(IncidentSeverity.high);
      controller.filterStatus(IncidentStatus.reported);
      expect(controller.visibleIncidents.single.title, 'Flooded bridge');
      controller.filterStatus(null);
      expect(controller.visibleIncidents, hasLength(2));
      controller.search('safe crossing');
      controller.filterSeverity(null);
      expect(controller.visibleIncidents, hasLength(3));
    },
  );

  test(
    'selected detail and auditable status update refresh with the feed',
    () async {
      final incident = commandIncident();
      fixture.repository.details[incident.id!] = IncidentDetail(
        incident: incident,
        timeline: [commandEvent(incident)],
      );
      fixture.repository.emit(commandFeed([incident]));
      await flush();
      controller.select(incident.id);
      await flush();
      await controller.acknowledge();
      await flush();
      expect(controller.selected!.incident.status, IncidentStatus.acknowledged);
      expect(controller.selected!.timeline, hasLength(2));
      expect(
        controller.visibleIncidents.single.status,
        IncidentStatus.acknowledged,
      );
      expect(fixture.repository.acknowledgeCalls, 1);
    },
  );

  test('reconnect retains the last view then catches missed updates', () {
    controller.dispose();
    final initialConnections = fixture.repository.connections.length;
    fakeAsync((clock) {
      controller = CommandCenterController(
        repository: fixture.repository,
        access: fixture.access,
        connectivity: fixture.connectivity,
        retryDelays: const [Duration(seconds: 1)],
      )..start();
      clock.flushMicrotasks();
      final incident = commandIncident();
      fixture.repository.emit(commandFeed([incident]));
      clock.flushMicrotasks();
      fixture.repository.fail(StateError('network lost'));
      clock.flushMicrotasks();
      expect(controller.status, LiveFeedStatus.reconnecting);
      expect(controller.visibleIncidents.single.id, incident.id);
      fixture.repository.current = commandFeed([
        incident,
        commandIncident(number: 2),
      ]);
      clock.elapse(const Duration(seconds: 1));
      clock.flushMicrotasks();
      expect(fixture.repository.connections, hasLength(initialConnections + 2));
      expect(controller.status, LiveFeedStatus.live);
      expect(controller.visibleIncidents, hasLength(2));
      expect(clock.pendingTimers, isEmpty);
    });
  });

  test(
    'offline cancels the stream and online opens a fresh snapshot',
    () async {
      fixture.repository.emit(commandFeed([commandIncident()]));
      await flush();
      fixture.connectivity.setStatusForTest(ConnectivityStatus.offline);
      expect(controller.status, LiveFeedStatus.offline);
      expect(controller.visibleIncidents, hasLength(1));
      await controller.acknowledge();
      expect(fixture.repository.acknowledgeCalls, 0);
      fixture.repository.current = commandFeed([commandIncident(number: 2)]);
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await flush();
      expect(controller.status, LiveFeedStatus.live);
      expect(
        controller.visibleIncidents.single.id,
        commandIncident(number: 2).id,
      );
    },
  );

  test(
    'permission failures clear data and do not retry automatically',
    () async {
      fixture.repository.emit(commandFeed([commandIncident()]));
      await flush();
      fixture.repository.fail(
        AuthorizationException(message: 'Revoked membership'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(controller.status, LiveFeedStatus.accessDenied);
      expect(controller.feed, isNull);
      expect(fixture.repository.connections, hasLength(1));
    },
  );

  test('a feed for another organization is rejected', () async {
    fixture.repository.emit(
      commandFeed([commandIncident()]).copyWith(
        organizationId: UuidValue.fromString(
          '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f999',
        ),
      ),
    );
    await flush();
    expect(controller.status, LiveFeedStatus.accessDenied);
    expect(controller.feed, isNull);
  });

  test(
    'sign out invalidates in-flight selection and clears private data',
    () async {
      final incident = commandIncident();
      final gate = Completer<IncidentDetail>();
      fixture.repository.detailGates[incident.id!] = gate;
      fixture.repository.emit(commandFeed([incident]));
      await flush();
      controller.select(incident.id);
      await fixture.access.signOut();
      gate.complete(IncidentDetail(incident: incident, timeline: []));
      await flush();
      expect(controller.selected, isNull);
      expect(controller.selectedId, isNull);
      expect(controller.feed, isNull);
      expect(controller.status, LiveFeedStatus.accessDenied);
      expect(fixture.repository.cancelled, greaterThanOrEqualTo(1));
    },
  );

  test('slow detail responses cannot replace a newer selection', () async {
    final first = commandIncident();
    final second = commandIncident(number: 2);
    final gate = Completer<IncidentDetail>();
    fixture.repository.detailGates[first.id!] = gate;
    fixture.repository.details[second.id!] = IncidentDetail(
      incident: second,
      timeline: [],
    );
    controller.select(first.id);
    controller.select(second.id);
    await flush();
    gate.complete(IncidentDetail(incident: first, timeline: []));
    await flush();
    expect(controller.selected!.incident.id, second.id);
  });

  test('coordinates are never invented or silently clamped for map pins', () {
    expect(hasMapLocation(commandIncident()), isTrue);
    expect(
      hasMapLocation(commandIncident(latitude: null, longitude: null)),
      isFalse,
    );
    expect(hasMapLocation(commandIncident(latitude: 90)), isFalse);
    expect(hasMapLocation(commandIncident(longitude: 181)), isFalse);
    expect(hasMapLocation(commandIncident(latitude: double.nan)), isFalse);
  });
}
