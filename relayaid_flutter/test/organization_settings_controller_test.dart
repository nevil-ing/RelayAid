import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/teams/application/organization_settings_controller.dart';

import 'support/command_center_fixture.dart';

void main() {
  late _SettingsGateway gateway;
  late AccessController access;
  late CommandCenterFixture fixture;
  late OrganizationSettingsController controller;
  setUp(() async {
    fixture = CommandCenterFixture();
    gateway = _SettingsGateway();
    access = AccessController(gateway);
    await access.initialize();
    controller = OrganizationSettingsController(
      access: access,
      connectivity: fixture.connectivity,
    );
  });
  tearDown(() async {
    controller.dispose();
    access.dispose();
    gateway.dispose();
    await fixture.dispose();
  });

  test(
    'offline membership and team changes are never sent or queued',
    () async {
      fixture.connectivity.setStatusForTest(ConnectivityStatus.offline);
      await controller.load();
      expect(
        await controller.addMember(_newId.toString(), MemberRole.responder),
        isFalse,
      );
      expect(await controller.createTeam('Team Alpha'), isFalse);
      expect(gateway.loads, 0);
      expect(gateway.adds, 0);
      expect(gateway.creates, 0);
      expect(controller.loading, isFalse);
      expect(controller.error, isNull);
    },
  );

  test(
    'new member IDs are validated and the administrator cannot add their own ID',
    () async {
      expect(
        await controller.addMember('made-up-ID', MemberRole.responder),
        isFalse,
      );
      expect(controller.error, contains('copied by the new member'));
      expect(
        await controller.addMember(
          commandUserId.toString(),
          MemberRole.fieldWorker,
        ),
        isFalse,
      );
      expect(controller.error, contains('your account ID'));
      expect(
        await controller.addMember(_newId.toString(), MemberRole.administrator),
        isFalse,
      );
      expect(gateway.adds, 0);
    },
  );

  test(
    'successful member/team actions trim input and reload real gateway data',
    () async {
      expect(
        await controller.addMember(' $_newId ', MemberRole.responder),
        isTrue,
      );
      expect(controller.members.last.authUserId, _newId);
      expect(controller.members.last.role, MemberRole.responder);
      expect(
        await controller.addMember(_newId.toString(), MemberRole.fieldWorker),
        isFalse,
      );
      expect(gateway.adds, 1);
      expect(await controller.createTeam(' Team Alpha '), isTrue);
      expect(controller.teams.single.name, 'Team Alpha');
      expect(controller.busy, isFalse);
    },
  );

  test(
    'coordinators may create teams but cannot grant organization membership',
    () async {
      gateway.context.membership.role = MemberRole.coordinator;
      await access.refresh();
      expect(controller.canAddMember, isFalse);
      expect(
        await controller.addMember(_newId.toString(), MemberRole.responder),
        isFalse,
      );
      expect(gateway.adds, 0);
      expect(await controller.createTeam('Team Alpha'), isTrue);
    },
  );

  test(
    'reconnection automatically reloads without leaving an offline spinner',
    () async {
      fixture.connectivity.setStatusForTest(ConnectivityStatus.offline);
      await controller.load();
      expect(controller.loading, isFalse);
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await Future<void>.delayed(Duration.zero);
      expect(gateway.loads, 1);
      expect(controller.members, hasLength(1));
      expect(controller.loading, isFalse);
    },
  );

  test('late organization loads cannot restore data after sign-out', () async {
    final gate = Completer<List<OrganizationMember>>();
    gateway.gate = gate;
    final load = controller.load();
    await access.signOut();
    gate.complete([gateway.context.membership]);
    await load;
    expect(controller.members, isEmpty);
    expect(controller.teams, isEmpty);
    expect(controller.loading, isFalse);
    expect(controller.canManage, isFalse);
  });

  test('failed loads and mutations have friendly retryable messages', () async {
    gateway.failure = StateError('private database details');
    await controller.load();
    expect(controller.error, contains('retry'));
    expect(controller.error, isNot(contains('database')));
    expect(
      await controller.addMember(_newId.toString(), MemberRole.responder),
      isFalse,
    );
    expect(controller.error, contains('sign in first'));
    expect(controller.busy, isFalse);
    gateway.failure = null;
    await controller.load();
    expect(controller.error, isNull);
    expect(controller.members, hasLength(1));
  });
}

final _newId = UuidValue.fromString('0199f2e9-9a4a-7e00-9a1f-4a6be0a1f199');

class _SettingsGateway extends CommandAuthGateway {
  _SettingsGateway() {
    context.membership.role = MemberRole.administrator;
  }
  final added = <OrganizationMember>[];
  final teams = <Team>[];
  int loads = 0;
  int adds = 0;
  int creates = 0;
  Object? failure;
  Completer<List<OrganizationMember>>? gate;
  @override
  Future<List<OrganizationMember>> listMembers(UuidValue id) async {
    loads++;
    if (failure != null) throw failure!;
    return gate?.future ?? [context.membership, ...added];
  }

  @override
  Future<List<Team>> listTeams(UuidValue id) async => teams;
  @override
  Future<OrganizationMember> addMember(
    UuidValue organizationId,
    UuidValue userId,
    MemberRole role,
  ) async {
    adds++;
    if (failure != null) throw failure!;
    final member = OrganizationMember(
      organizationId: organizationId,
      authUserId: userId,
      role: role,
    );
    added.add(member);
    return member;
  }

  @override
  Future<Team> createTeam(UuidValue organizationId, String name) async {
    creates++;
    final team = Team(
      id: Uuid().v7obj(),
      organizationId: organizationId,
      name: name,
    );
    teams.add(team);
    return team;
  }
}
