import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/teams/application/team_controller.dart';

import 'support/assignment_fixture.dart';
import 'support/command_center_fixture.dart';

void main() {
  late CommandCenterFixture fixture;
  late FakeTeamRepository repository;
  late TeamController controller;
  setUp(() async {
    fixture = CommandCenterFixture();
    await fixture.initialize();
    repository = FakeTeamRepository();
    controller = TeamController(
      repository: repository,
      access: fixture.access,
      connectivity: fixture.connectivity,
    );
  });
  tearDown(() async {
    controller.dispose();
    await fixture.dispose();
  });
  test(
    'loads organization responders and delegates team creation and roster changes',
    () async {
      await controller.loadMembers();
      expect(controller.responders.single.authUserId, commandUserId);
      expect(await controller.create(' Team Alpha '), isTrue);
      expect(
        await controller.addResponder(assignmentTeamId, commandUserId),
        isTrue,
      );
      expect(repository.creates, 1);
      expect(repository.adds, 1);
    },
  );
  test('invalid names and offline changes do not reach the backend', () async {
    expect(await controller.create('x'), isFalse);
    fixture.connectivity.setStatusForTest(ConnectivityStatus.offline);
    expect(await controller.create('Team Alpha'), isFalse);
    expect(
      await controller.addResponder(assignmentTeamId, commandUserId),
      isFalse,
    );
    expect(repository.creates, 0);
    expect(repository.adds, 0);
    expect(controller.error, contains('Reconnect'));
  });
  test(
    'late member loads cannot restore organization data after sign-out',
    () async {
      final gate = Completer<List<OrganizationMember>>();
      repository.memberGate = gate;
      final loading = controller.loadMembers();
      await fixture.access.signOut();
      gate.complete(assignmentRoster().responders);
      await loading;
      expect(controller.responders, isEmpty);
      expect(controller.loading, isFalse);
    },
  );
  test('failed mutation shows a friendly retryable message', () async {
    repository.failure = StateError('private database failure');
    expect(await controller.create('Team Alpha'), isFalse);
    expect(controller.error, isNot(contains('database')));
    expect(controller.busy, isFalse);
  });
}
