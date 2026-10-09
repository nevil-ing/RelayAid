import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('assignment workflow', (sessionBuilder, endpoints) {
    final admin = Uuid().v4obj();
    final responder = Uuid().v4obj();
    final peer = Uuid().v4obj();
    final field = Uuid().v4obj();
    final coordinator = Uuid().v4obj();
    late OrganizationContext organization;
    late Team alpha;

    TestSessionBuilder signed(UuidValue user) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        user.toString(),
        {},
      ),
    );
    Future<IncidentDetail> report() => endpoints.incident.create(
      signed(field),
      type: IncidentType.flooding,
      severity: IncidentSeverity.high,
      title: 'Flooded bridge',
      description: 'Water has blocked the crossing.',
      latitude: -0.3031,
      longitude: 36.08,
      peopleAffected: 12,
    );
    Future<IncidentDetail> assign({UuidValue? designated}) async {
      final incident = await report();
      return endpoints.assignment.assign(
        signed(coordinator),
        incident.incident.id!,
        alpha.id!,
        responderId: designated,
      );
    }

    setUp(() async {
      organization = await endpoints.organization.create(
        signed(admin),
        'Assignment response',
      );
      for (final (user, role) in [
        (responder, MemberRole.responder),
        (peer, MemberRole.responder),
        (field, MemberRole.fieldWorker),
        (coordinator, MemberRole.coordinator),
      ]) {
        await OrganizationMember.db.insertRow(
          sessionBuilder.build(),
          OrganizationMember(
            organizationId: organization.organization.id!,
            authUserId: user,
            role: role,
          ),
        );
      }
      alpha = await endpoints.organization.createTeam(
        signed(admin),
        organization.organization.id!,
        'Team Alpha',
      );
      await endpoints.team.addResponder(signed(admin), alpha.id!, responder);
      await endpoints.team.addResponder(signed(coordinator), alpha.id!, peer);
    });

    test('assignment endpoints require sign-in', () async {
      await expectLater(
        endpoints.assignment.assign(sessionBuilder, Uuid().v7obj(), alpha.id!),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
      await expectLater(
        endpoints.team.addResponder(sessionBuilder, alpha.id!, field),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test(
      'coordinator assigns and the responder completes an audited lifecycle',
      () async {
        var detail = await assign();
        final id = detail.assignment!.id!;
        expect(detail.incident.status, IncidentStatus.assigned);
        expect(detail.assignment!.assignedBy, coordinator);
        expect(detail.assignmentTeamName, 'Team Alpha');
        expect(
          detail.timeline.last.eventType,
          IncidentEventType.assignmentCreated,
        );
        detail = await endpoints.assignment.accept(signed(responder), id);
        expect(detail.incident.status, IncidentStatus.assigned);
        expect(detail.assignment!.acceptedBy, responder);
        expect(detail.assignment!.acceptedAt, isNotNull);
        detail = await endpoints.assignment.respond(signed(responder), id);
        expect(detail.incident.status, IncidentStatus.responding);
        expect(detail.assignment!.respondingAt, isNotNull);
        detail = await endpoints.assignment.resolve(
          signed(responder),
          id,
          '  Crossing secured; everyone evacuated.  ',
        );
        expect(detail.incident.status, IncidentStatus.resolved);
        expect(detail.assignment!.status, AssignmentStatus.resolved);
        expect(detail.assignment!.resolvedAt, isNotNull);
        expect(detail.timeline.map((e) => e.eventType), [
          IncidentEventType.created,
          IncidentEventType.assignmentCreated,
          IncidentEventType.assignmentAccepted,
          IncidentEventType.responseStarted,
          IncidentEventType.assignmentResolved,
        ]);
        expect(
          detail.timeline.skip(1).every((e) => e.assignmentId == id),
          isTrue,
        );
        expect(detail.timeline.last.actorId, responder);
        expect(
          detail.timeline.last.note,
          'Crossing secured; everyone evacuated.',
        );
        final persisted = await endpoints.incident.detail(
          signed(admin),
          detail.incident.id!,
        );
        expect(persisted.assignment!.status, AssignmentStatus.resolved);
        expect(persisted.timeline, hasLength(5));
      },
    );

    test(
      'replayed assignment and responder requests add no duplicate history',
      () async {
        final original = await assign();
        final duplicate = await endpoints.assignment.assign(
          signed(admin),
          original.incident.id!,
          alpha.id!,
        );
        expect(duplicate.assignment!.id, original.assignment!.id);
        final id = original.assignment!.id!;
        await endpoints.assignment.accept(signed(responder), id);
        await endpoints.assignment.accept(signed(responder), id);
        await endpoints.assignment.respond(signed(responder), id);
        await endpoints.assignment.respond(signed(responder), id);
        await endpoints.assignment.resolve(
          signed(responder),
          id,
          'Everyone is safe.',
        );
        await endpoints.assignment.resolve(
          signed(responder),
          id,
          'Everyone is safe.',
        );
        final acceptedRetry = await endpoints.assignment.accept(
          signed(responder),
          id,
        );
        expect(acceptedRetry.assignment!.status, AssignmentStatus.resolved);
        expect(acceptedRetry.timeline, hasLength(5));
      },
    );

    test(
      'field workers and responders cannot assign or manage rosters',
      () async {
        final incident = await report();
        for (final user in [field, responder]) {
          await expectLater(
            endpoints.assignment.assign(
              signed(user),
              incident.incident.id!,
              alpha.id!,
            ),
            throwsA(isA<AuthorizationException>()),
          );
          await expectLater(
            endpoints.team.addResponder(signed(user), alpha.id!, peer),
            throwsA(isA<AuthorizationException>()),
          );
        }
        expect(
          (await endpoints.incident.detail(
            signed(admin),
            incident.incident.id!,
          )).timeline,
          hasLength(1),
        );
      },
    );

    test(
      'team and assignment reads/writes reject another organization',
      () async {
        final otherUser = Uuid().v4obj();
        final other = await endpoints.organization.create(
          signed(otherUser),
          'Other response',
        );
        final otherTeam = await endpoints.organization.createTeam(
          signed(otherUser),
          other.organization.id!,
          'Private team',
        );
        final detail = await assign();
        await expectLater(
          endpoints.assignment.assign(
            signed(otherUser),
            detail.incident.id!,
            otherTeam.id!,
          ),
          throwsA(isA<AuthorizationException>()),
        );
        final unassigned = await report();
        await expectLater(
          endpoints.assignment.assign(
            signed(admin),
            unassigned.incident.id!,
            otherTeam.id!,
          ),
          throwsA(isA<AuthorizationException>()),
        );
        await expectLater(
          endpoints.team.addResponder(signed(admin), otherTeam.id!, responder),
          throwsA(isA<AuthorizationException>()),
        );
        await expectLater(
          endpoints.assignment.detail(
            signed(otherUser),
            detail.assignment!.id!,
          ),
          throwsA(isA<AuthorizationException>()),
        );
        await expectLater(
          endpoints.assignment.accept(
            signed(otherUser),
            detail.assignment!.id!,
          ),
          throwsA(isA<AuthorizationException>()),
        );
      },
    );

    test(
      'only actual organization responders can join a team, with safe retries',
      () async {
        final first = await endpoints.team.addResponder(
          signed(admin),
          alpha.id!,
          responder,
        );
        final second = await endpoints.team.addResponder(
          signed(admin),
          alpha.id!,
          responder,
        );
        expect(first.id, second.id);
        for (final user in [field, coordinator, Uuid().v4obj()]) {
          await expectLater(
            endpoints.team.addResponder(signed(admin), alpha.id!, user),
            throwsA(isA<IncidentValidationException>()),
          );
        }
        expect(
          await TeamMember.db.count(
            sessionBuilder.build(),
            where: (t) => t.teamId.equals(alpha.id!),
          ),
          2,
        );
      },
    );

    test(
      'empty teams and responders outside the selected roster are rejected',
      () async {
        final empty = await endpoints.organization.createTeam(
          signed(admin),
          organization.organization.id!,
          'Empty team',
        );
        final incident = await report();
        await expectLater(
          endpoints.assignment.assign(
            signed(admin),
            incident.incident.id!,
            empty.id!,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
        await expectLater(
          endpoints.assignment.assign(
            signed(admin),
            incident.incident.id!,
            alpha.id!,
            responderId: field,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
        expect(
          (await endpoints.incident.detail(
            signed(admin),
            incident.incident.id!,
          )).assignment,
          isNull,
        );
      },
    );

    test('designated responder is enforced, including team peers', () async {
      final detail = await assign(designated: responder);
      await expectLater(
        endpoints.assignment.detail(signed(peer), detail.assignment!.id!),
        throwsA(isA<AuthorizationException>()),
      );
      await expectLater(
        endpoints.assignment.accept(signed(peer), detail.assignment!.id!),
        throwsA(isA<AuthorizationException>()),
      );
      final accepted = await endpoints.assignment.accept(
        signed(responder),
        detail.assignment!.id!,
      );
      expect(accepted.assignment!.acceptedBy, responder);
    });

    test(
      'a responder must remain on the roster and hold the responder role',
      () async {
        final detail = await assign();
        await TeamMember.db.deleteWhere(
          sessionBuilder.build(),
          where: (t) =>
              t.teamId.equals(alpha.id!) & t.authUserId.equals(responder),
        );
        await expectLater(
          endpoints.assignment.accept(
            signed(responder),
            detail.assignment!.id!,
          ),
          throwsA(isA<AuthorizationException>()),
        );
        final membership = (await OrganizationMember.db.find(
          sessionBuilder.build(),
          where: (t) => t.authUserId.equals(peer),
        )).single;
        await OrganizationMember.db.updateRow(
          sessionBuilder.build(),
          membership.copyWith(role: MemberRole.fieldWorker),
        );
        await expectLater(
          endpoints.assignment.accept(signed(peer), detail.assignment!.id!),
          throwsA(isA<AuthorizationException>()),
        );
        expect(
          (await endpoints.incident.detail(
            signed(admin),
            detail.incident.id!,
          )).timeline,
          hasLength(2),
        );
      },
    );

    test(
      'only the accepting responder can advance and steps cannot be skipped',
      () async {
        final detail = await assign();
        final id = detail.assignment!.id!;
        await expectLater(
          endpoints.assignment.respond(signed(responder), id),
          throwsA(isA<IncidentValidationException>()),
        );
        await expectLater(
          endpoints.assignment.resolve(
            signed(responder),
            id,
            'Completed safely.',
          ),
          throwsA(isA<IncidentValidationException>()),
        );
        await endpoints.assignment.accept(signed(responder), id);
        await expectLater(
          endpoints.assignment.accept(signed(peer), id),
          throwsA(isA<AuthorizationException>()),
        );
        await expectLater(
          endpoints.assignment.respond(signed(peer), id),
          throwsA(isA<AuthorizationException>()),
        );
        await expectLater(
          endpoints.assignment.resolve(
            signed(responder),
            id,
            'Completed safely.',
          ),
          throwsA(isA<IncidentValidationException>()),
        );
        expect(
          (await endpoints.incident.detail(
            signed(admin),
            detail.incident.id!,
          )).timeline,
          hasLength(3),
        );
      },
    );

    test(
      'coordinator cancellation closes assignment and incident atomically',
      () async {
        final detail = await assign();
        await endpoints.assignment.accept(
          signed(responder),
          detail.assignment!.id!,
        );
        final cancelled = await endpoints.incident.transition(
          signed(coordinator),
          detail.incident.id!,
          IncidentStatus.cancelled,
        );
        expect(cancelled.assignment!.status, AssignmentStatus.cancelled);
        expect(cancelled.assignment!.cancelledAt, isNotNull);
        expect(cancelled.incident.status, IncidentStatus.cancelled);
        expect(
          cancelled.timeline.last.eventType,
          IncidentEventType.assignmentCancelled,
        );
        await expectLater(
          endpoints.assignment.respond(
            signed(responder),
            detail.assignment!.id!,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
      },
    );

    test(
      'generic status API cannot fabricate assignment, response or resolution',
      () async {
        final detail = await report();
        await endpoints.incident.transition(
          signed(admin),
          detail.incident.id!,
          IncidentStatus.acknowledged,
        );
        await expectLater(
          endpoints.incident.transition(
            signed(admin),
            detail.incident.id!,
            IncidentStatus.assigned,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
        final assigned = await endpoints.assignment.assign(
          signed(admin),
          detail.incident.id!,
          alpha.id!,
        );
        await expectLater(
          endpoints.incident.transition(
            signed(admin),
            detail.incident.id!,
            IncidentStatus.responding,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
        await endpoints.assignment.accept(
          signed(responder),
          assigned.assignment!.id!,
        );
        await endpoints.assignment.respond(
          signed(responder),
          assigned.assignment!.id!,
        );
        await expectLater(
          endpoints.incident.transition(
            signed(admin),
            detail.incident.id!,
            IncidentStatus.resolved,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
      },
    );

    test(
      'resolution note and terminal state are validated without partial writes',
      () async {
        final detail = await assign();
        final id = detail.assignment!.id!;
        await endpoints.assignment.accept(signed(responder), id);
        await endpoints.assignment.respond(signed(responder), id);
        for (final note in ['', 'x', 'x' * 501]) {
          await expectLater(
            endpoints.assignment.resolve(signed(responder), id, note),
            throwsA(isA<IncidentValidationException>()),
          );
        }
        final current = await endpoints.incident.detail(
          signed(admin),
          detail.incident.id!,
        );
        expect(current.assignment!.status, AssignmentStatus.responding);
        expect(current.timeline, hasLength(4));
        await endpoints.assignment.resolve(
          signed(responder),
          id,
          'Crossing secured.',
        );
        await expectLater(
          endpoints.incident.transition(
            signed(admin),
            detail.incident.id!,
            IncidentStatus.cancelled,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
        final otherTeam = await endpoints.organization.createTeam(
          signed(admin),
          organization.organization.id!,
          'Team Bravo',
        );
        await expectLater(
          endpoints.assignment.assign(
            signed(admin),
            detail.incident.id!,
            otherTeam.id!,
          ),
          throwsA(isA<IncidentValidationException>()),
        );
      },
    );
  });
}
