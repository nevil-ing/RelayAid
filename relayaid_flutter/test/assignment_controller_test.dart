import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/core/network/live_feed_status.dart';
import 'package:relayaid_flutter/features/assignments/application/assignment_controller.dart';

import 'support/assignment_fixture.dart';
import 'support/command_center_fixture.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late AssignmentFixture fixture;
  late AssignmentController controller;
  setUp(() async {
    fixture = AssignmentFixture();
    await fixture.initialize();
    final detail = assignmentDetail();
    fixture.repository.details[assignmentId] = detail;
    fixture.repository.current = assignmentFeed([assignmentSummary(detail)]);
    controller = AssignmentController(
      repository: fixture.repository,
      access: fixture.access,
      connectivity: fixture.connectivity,
      retryDelays: const [Duration(seconds: 1)],
    )..start();
    await flush();
  });
  tearDown(() async {
    controller.dispose();
    await fixture.dispose();
  });
  test(
    'foreground feed delivers assignments and advances the complete lifecycle',
    () async {
      expect(controller.assignments.single.teamName, 'Team Alpha');
      controller.select(assignmentId);
      await flush();
      expect(controller.canAct, isTrue);
      await controller.accept();
      await flush();
      expect(
        controller.selected!.assignment!.status,
        AssignmentStatus.accepted,
      );
      await controller.respond();
      await flush();
      await controller.resolve('  Crossing secured.  ');
      await flush();
      expect(controller.selected!.incident.status, IncidentStatus.resolved);
      expect(
        controller.assignments.single.assignment.status,
        AssignmentStatus.resolved,
      );
      expect(controller.selected!.timeline, hasLength(5));
      expect(fixture.repository.resolutionNote, 'Crossing secured.');
      expect(controller.canAct, isFalse);
    },
  );
  test('invalid resolution notes are rejected before sending', () async {
    fixture.repository.details[assignmentId] = assignmentDetail(
      status: AssignmentStatus.responding,
    );
    controller.select(assignmentId);
    await flush();
    await controller.resolve('x');
    expect(fixture.repository.actions, 0);
    expect(controller.error, contains('3–500'));
  });
  test(
    'a peer cannot act on an assignment already accepted by someone else',
    () async {
      fixture.repository.details[assignmentId] = assignmentDetail(
        status: AssignmentStatus.accepted,
        acceptedBy: Uuid().v4obj(),
      );
      controller.select(assignmentId);
      await flush();
      await controller.respond();
      expect(controller.canAct, isFalse);
      expect(fixture.repository.actions, 0);
    },
  );
  test(
    'busy state prevents repeated taps and late response cannot restore signed-out data',
    () async {
      controller.select(assignmentId);
      await flush();
      final gate = Completer<void>();
      fixture.repository.actionGate = gate;
      final first = controller.accept();
      await controller.accept();
      expect(fixture.repository.actions, 1);
      await fixture.access.signOut();
      gate.complete();
      await first;
      expect(controller.feed, isNull);
      expect(controller.selected, isNull);
      expect(controller.status, LiveFeedStatus.accessDenied);
    },
  );
  test(
    'offline retains last detail, disables actions and reconnects to a fresh snapshot',
    () async {
      controller.select(assignmentId);
      await flush();
      fixture.connectivity.setStatusForTest(ConnectivityStatus.offline);
      await controller.accept();
      expect(controller.selected, isNotNull);
      expect(controller.status, LiveFeedStatus.offline);
      expect(fixture.repository.actions, 0);
      final detail = assignmentDetail(status: AssignmentStatus.accepted);
      fixture.repository.details[assignmentId] = detail;
      fixture.repository.current = assignmentFeed([assignmentSummary(detail)]);
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await flush();
      expect(controller.status, LiveFeedStatus.live);
      expect(
        controller.selected!.assignment!.status,
        AssignmentStatus.accepted,
      );
    },
  );
  test('stream failures retry the connection, not incident polling', () {
    controller.dispose();
    final initialConnections = fixture.repository.connections.length;
    fakeAsync((clock) {
      controller = AssignmentController(
        repository: fixture.repository,
        access: fixture.access,
        connectivity: fixture.connectivity,
        retryDelays: const [Duration(seconds: 1)],
      )..start();
      clock.flushMicrotasks();
      fixture.repository.fail(StateError('Connection lost'));
      clock.flushMicrotasks();
      expect(controller.status, LiveFeedStatus.reconnecting);
      expect(controller.assignments, hasLength(1));
      clock.elapse(const Duration(seconds: 1));
      clock.flushMicrotasks();
      expect(controller.status, LiveFeedStatus.live);
      expect(fixture.repository.connections, hasLength(initialConnections + 2));
      expect(clock.pendingTimers, isEmpty);
    });
  });
  test(
    'revoked access clears the inbox and does not retry automatically',
    () async {
      fixture.repository.fail(
        AuthorizationException(message: 'Access revoked'),
      );
      await flush();
      expect(controller.status, LiveFeedStatus.accessDenied);
      expect(controller.assignments, isEmpty);
      expect(fixture.repository.connections, hasLength(1));
    },
  );
  test(
    'a snapshot for another organization or identity is never displayed',
    () async {
      fixture.repository.emit(
        assignmentFeed([]).copyWith(authUserId: Uuid().v4obj()),
      );
      await flush();
      expect(controller.feed, isNull);
      fixture.repository.current = assignmentFeed([]);
      controller.reconnect();
      await flush();
      fixture.repository.emit(
        assignmentFeed([]).copyWith(organizationId: Uuid().v4obj()),
      );
      await flush();
      expect(controller.feed, isNull);
      expect(controller.status, LiveFeedStatus.accessDenied);
    },
  );
  test('roster removal clears selected private assignment data', () async {
    controller.select(assignmentId);
    await flush();
    fixture.repository.emit(assignmentFeed([]));
    await flush();
    expect(controller.selectedId, isNull);
    expect(controller.selected, isNull);
  });
  test('role change cancels the responder feed and clears its data', () async {
    fixture.gateway.context = fixture.gateway.context.copyWith(
      membership: fixture.gateway.context.membership.copyWith(
        role: MemberRole.fieldWorker,
      ),
    );
    await fixture.access.refresh();
    await flush();
    expect(controller.feed, isNull);
    expect(controller.status, LiveFeedStatus.accessDenied);
    expect(fixture.repository.cancelled, 1);
  });
  test('stale detail results do not replace a new selection', () async {
    final gate = Completer<IncidentDetail>();
    fixture.repository.detailGates[assignmentId] = gate;
    controller.select(assignmentId);
    final otherId = Uuid().v7obj();
    final detail = assignmentDetail(id: otherId);
    fixture.repository.details[otherId] = detail;
    controller.select(otherId);
    await flush();
    gate.complete(assignmentDetail());
    await flush();
    expect(controller.selected!.assignment!.id, otherId);
  });
  test(
    'friendly failure remains retryable without inventing progress',
    () async {
      controller.select(assignmentId);
      await flush();
      fixture.repository.failure = StateError('private socket failure');
      await controller.accept();
      expect(controller.selected!.assignment!.status, AssignmentStatus.pending);
      expect(controller.error, isNot(contains('private socket')));
      fixture.repository.failure = null;
      await controller.accept();
      await flush();
      expect(
        controller.selected!.assignment!.status,
        AssignmentStatus.accepted,
      );
    },
  );
  test(
    'coordinator identities never subscribe to the responder inbox',
    () async {
      fixture.gateway.context = fixture.gateway.context.copyWith(
        membership: fixture.gateway.context.membership.copyWith(
          role: MemberRole.coordinator,
        ),
      );
      await fixture.access.refresh();
      expect(controller.status, LiveFeedStatus.accessDenied);
      expect(controller.feed, isNull);
      expect(fixture.repository.connections, hasLength(1));
      expect(fixture.access.context!.organization.id, commandOrganizationId);
    },
  );
}
