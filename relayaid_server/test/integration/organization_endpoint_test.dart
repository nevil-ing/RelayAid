import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('organization access', (sessionBuilder, endpoints) {
    final adminA = Uuid().v4obj();
    final adminB = Uuid().v4obj();
    final fieldUser = Uuid().v4obj();
    final coordinatorUser = Uuid().v4obj();

    TestSessionBuilder signedIn(UuidValue userId) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userId.toString(),
        {},
      ),
    );

    test('blocks unauthenticated organization calls', () async {
      await expectLater(
        endpoints.organization.myContext(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('bootstraps an administrator with a persisted organization', () async {
      final created = await endpoints.organization.create(
        signedIn(adminA),
        'RelayAid Response',
      );
      expect(created.organization.name, 'RelayAid Response');
      expect(created.membership.role, MemberRole.administrator);
      expect(created.membership.authUserId, adminA);

      final restored = await endpoints.organization.myContext(signedIn(adminA));
      expect(restored?.organization.id, created.organization.id);
    });

    test('denies another organization even to an administrator', () async {
      final first = await endpoints.organization.create(
        signedIn(adminA),
        'First organization',
      );
      await endpoints.organization.create(
        signedIn(adminB),
        'Second organization',
      );

      await expectLater(
        endpoints.organization.contextFor(
          signedIn(adminB),
          first.organization.id!,
        ),
        throwsA(isA<AuthorizationException>()),
      );
      await expectLater(
        endpoints.organization.listTeams(
          signedIn(adminB),
          first.organization.id!,
        ),
        throwsA(isA<AuthorizationException>()),
      );
      await expectLater(
        endpoints.organization.addMember(
          signedIn(adminB),
          first.organization.id!,
          fieldUser,
          MemberRole.fieldWorker,
        ),
        throwsA(isA<AuthorizationException>()),
      );
    });

    test('field worker cannot create teams; coordinator can', () async {
      final organization = await endpoints.organization.create(
        signedIn(adminA),
        'Response group',
      );
      final session = sessionBuilder.build();
      await OrganizationMember.db.insertRow(
        session,
        OrganizationMember(
          organizationId: organization.organization.id!,
          authUserId: fieldUser,
          role: MemberRole.fieldWorker,
        ),
      );
      await OrganizationMember.db.insertRow(
        session,
        OrganizationMember(
          organizationId: organization.organization.id!,
          authUserId: coordinatorUser,
          role: MemberRole.coordinator,
        ),
      );
      await expectLater(
        endpoints.organization.createTeam(
          signedIn(fieldUser),
          organization.organization.id!,
          'Alpha',
        ),
        throwsA(isA<AuthorizationException>()),
      );
      await expectLater(
        endpoints.organization.listMembers(
          signedIn(fieldUser),
          organization.organization.id!,
        ),
        throwsA(isA<AuthorizationException>()),
      );
      final team = await endpoints.organization.createTeam(
        signedIn(coordinatorUser),
        organization.organization.id!,
        'Alpha',
      );
      expect(team.name, 'Alpha');
    });

    test(
      'administrator adds an existing account with a server-held role',
      () async {
        final organization = await endpoints.organization.create(
          signedIn(adminA),
          'Member onboarding',
        );
        await AuthUser.db.insertRow(
          sessionBuilder.build(),
          AuthUser(id: fieldUser, scopeNames: {}),
        );

        final added = await endpoints.organization.addMember(
          signedIn(adminA),
          organization.organization.id!,
          fieldUser,
          MemberRole.fieldWorker,
        );
        expect(added.role, MemberRole.fieldWorker);
        expect(added.organizationId, organization.organization.id);

        final fieldContext = await endpoints.organization.myContext(
          signedIn(fieldUser),
        );
        expect(fieldContext?.organization.id, organization.organization.id);
        expect(fieldContext?.membership.role, MemberRole.fieldWorker);
      },
    );
  });
}
