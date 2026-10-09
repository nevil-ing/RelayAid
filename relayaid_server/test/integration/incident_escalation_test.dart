import 'dart:async';

import 'package:relayaid_server/src/generated/future_calls.dart';
import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:relayaid_server/src/services/incident_escalation_policy.dart';
import 'package:relayaid_server/src/services/incident_escalation_service.dart';
import 'package:relayaid_server/src/services/incident_feed_service.dart';
import 'package:serverpod/protocol.dart'
    show FutureCallEntry, IntervalFutureCallScheduling;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  // Committed data is required for the real scheduler's independent sessions
  // and concurrent PostgreSQL row locks. Every test owns an isolated org.
  withServerpod('automatic critical escalation', (sessionBuilder, endpoints) {
    late UuidValue admin;
    late UuidValue responder;
    late OrganizationContext organization;
    late Team alpha;
    final streams = <StreamIterator<IncidentFeed>>[];

    TestSessionBuilder signed(UuidValue user) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        user.toString(),
        {},
      ),
    );

    Future<IncidentDetail> report({
      UuidValue? id,
      IncidentSeverity severity = IncidentSeverity.critical,
    }) => endpoints.incident.create(
      signed(admin),
      id: id,
      type: IncidentType.flooding,
      severity: severity,
      title: 'Critical flood report',
      description: 'People are stranded at the blocked crossing.',
      latitude: -0.3031,
      longitude: 36.08,
      peopleAffected: 12,
    );

    Future<void> makeDue(Incident incident) => Incident.db
        .updateRow(
          sessionBuilder.build(),
          incident.copyWith(
            escalationDueAt: DateTime.now().toUtc().subtract(
              const Duration(seconds: 1),
            ),
          ),
        )
        .then((_) {});

    Future<void> check() =>
        endpoints.futureCalls.incidentEscalation.checkOverdue(sessionBuilder);

    Future<IncidentDetail> detail(Incident incident) =>
        endpoints.incident.detail(signed(admin), incident.id!);

    setUp(() async {
      admin = Uuid().v4obj();
      responder = Uuid().v4obj();
      organization = await endpoints.organization.create(
        signed(admin),
        'Escalation response',
      );
      await OrganizationMember.db.insertRow(
        sessionBuilder.build(),
        OrganizationMember(
          organizationId: organization.organization.id!,
          authUserId: responder,
          role: MemberRole.responder,
        ),
      );
      alpha = await endpoints.organization.createTeam(
        signed(admin),
        organization.organization.id!,
        'Team Alpha',
      );
      await endpoints.team.addResponder(signed(admin), alpha.id!, responder);
    });

    tearDown(() async {
      final session = sessionBuilder.build();
      await session.server.serverpod.futureCalls.cancel(
        IncidentEscalationService.scheduleIdentifier,
      );
      for (final stream in streams) {
        await stream.cancel();
      }
      streams.clear();
      final orgId = organization.organization.id!;
      await Assignment.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(orgId),
      );
      await IncidentEvent.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(orgId),
      );
      await Incident.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(orgId),
      );
      await TeamMember.db.deleteWhere(
        session,
        where: (t) => t.teamId.equals(alpha.id!),
      );
      await Team.db.deleteRow(session, alpha);
      await OrganizationMember.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(orgId),
      );
      await Organization.db.deleteRow(session, organization.organization);
    });

    test(
      'deadline is saved with a critical report; other severities have none',
      () async {
        final incident = (await report()).incident;
        expect(
          incident.escalationDueAt,
          incident.reportedAt.add(IncidentEscalationPolicy.defaultDelay),
        );
        expect(incident.escalatedAt, isNull);
        final persisted = await detail(incident);
        expect(persisted.incident.escalationDueAt, incident.escalationDueAt);
        for (final severity in IncidentSeverity.values) {
          if (severity == IncidentSeverity.critical) continue;
          expect(
            (await report(severity: severity)).incident.escalationDueAt,
            isNull,
          );
        }
      },
    );

    test(
      'offline UUID retries never postpone the persisted deadline',
      () async {
        final first = await report(id: Uuid().v7obj());
        await makeDue(first.incident);
        final before = await detail(first.incident);
        final retry = await report(id: first.incident.id);
        expect(retry.incident.escalationDueAt, before.incident.escalationDueAt);
        expect(retry.timeline, hasLength(1));
        await check();
        final escalatedRetry = await report(id: first.incident.id);
        expect(escalatedRetry.incident.escalatedAt, isNotNull);
        expect(escalatedRetry.timeline, hasLength(2));
      },
    );

    test(
      'a persisted recurring Future Call runs automatically and sends a live snapshot',
      () async {
        final incident = (await report()).incident;
        await makeDue(incident);
        final stream = StreamIterator(
          IncidentFeedService.watch(signed(admin).build()),
        );
        streams.add(stream);
        expect(await stream.moveNext(), isTrue);
        expect(stream.current.incidents.single.escalatedAt, isNull);
        await IncidentEscalationService.ensureScheduled(sessionBuilder.build());
        final scheduled = await FutureCallEntry.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) =>
              t.identifier.equals(IncidentEscalationService.scheduleIdentifier),
        );
        expect(scheduled, isNotNull);
        expect(scheduled!.name, 'IncidentEscalationCheckOverdueFutureCall');
        expect(scheduled.scheduling, isA<IntervalFutureCallScheduling>());
        expect(
          (scheduled.scheduling as IntervalFutureCallScheduling).interval,
          IncidentEscalationPolicy.checkInterval,
        );
        // No direct service invocation, timer replacement or polling here.
        expect(
          await stream.moveNext().timeout(const Duration(seconds: 15)),
          isTrue,
        );
        expect(stream.current.incidents.single.escalatedAt, isNotNull);
        expect(
          stream.current.activity.first.event.eventType,
          IncidentEventType.escalated,
        );
        expect(stream.current.activity.first.event.actorId, isNull);
        final persisted = await detail(incident);
        expect(persisted.incident.status, IncidentStatus.reported);
        expect(persisted.timeline, hasLength(2));
        expect(persisted.timeline.last.fromStatus, IncidentStatus.reported);
        expect(persisted.timeline.last.toStatus, IncidentStatus.reported);
        // A loaded test host can read after the next scheduled time has
        // already arrived. Verify the persisted successor, not wall-clock
        // latency between the callback and this assertion.
        final successor = await FutureCallEntry.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) =>
              t.identifier.equals(
                IncidentEscalationService.scheduleIdentifier,
              ) &
              t.id.notEquals(scheduled.id!),
        );
        expect(successor, isNotNull);
        expect(successor!.time.isAfter(scheduled.time), isTrue);
        expect(successor.scheduling, isA<IntervalFutureCallScheduling>());
      },
    );

    test(
      'repeated and concurrent startup reuses the persisted schedule',
      () async {
        await Future.wait([
          IncidentEscalationService.ensureScheduled(sessionBuilder.build()),
          IncidentEscalationService.ensureScheduled(sessionBuilder.build()),
        ]);
        final before = await FutureCallEntry.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) =>
              t.identifier.equals(IncidentEscalationService.scheduleIdentifier),
        );
        await IncidentEscalationService.ensureScheduled(sessionBuilder.build());
        final after = await FutureCallEntry.db.find(
          sessionBuilder.build(),
          where: (t) =>
              t.identifier.equals(IncidentEscalationService.scheduleIdentifier),
        );
        expect(after, hasLength(1));
        expect(after.single.id, before!.id);
        expect(after.single.time, before.time);
      },
    );

    test(
      'repeated concurrent checks write exactly one automatic audit event',
      () async {
        final incident = (await report()).incident;
        await makeDue(incident);
        await Future.wait([check(), check(), check()]);
        await check();
        final persisted = await detail(incident);
        expect(persisted.timeline, hasLength(2));
        expect(persisted.timeline.last.eventType, IncidentEventType.escalated);
        expect(persisted.timeline.last.actorId, isNull);
        expect(persisted.timeline.first.actorId, admin);
        expect(
          persisted.incident.escalatedAt,
          persisted.timeline.last.createdAt,
        );
        expect(persisted.incident.updatedAt, persisted.incident.escalatedAt);
        expect(
          persisted.timeline.last.note,
          contains('Coordinator attention required'),
        );
      },
    );

    test(
      'old critical reports receive a deadline from their recorded receipt time',
      () async {
        final incident = (await report()).incident;
        final received = DateTime.now().toUtc().subtract(
          const Duration(minutes: 11),
        );
        await Incident.db.updateRow(
          sessionBuilder.build(),
          incident.copyWith(reportedAt: received, escalationDueAt: null),
        );
        await check();
        final persisted = await detail(incident);
        expect(
          persisted.incident.escalationDueAt,
          received.add(IncidentEscalationPolicy.defaultDelay),
        );
        expect(persisted.incident.escalatedAt, isNotNull);
        expect(persisted.timeline, hasLength(2));
      },
    );

    test(
      'recent legacy critical reports are initialized without premature history',
      () async {
        final incident = (await report()).incident;
        await Incident.db.updateRow(
          sessionBuilder.build(),
          incident.copyWith(escalationDueAt: null),
        );
        await check();
        final persisted = await detail(incident);
        expect(
          persisted.incident.escalationDueAt,
          incident.reportedAt.add(IncidentEscalationPolicy.defaultDelay),
        );
        expect(persisted.incident.escalatedAt, isNull);
        expect(persisted.incident.updatedAt, incident.updatedAt);
        expect(persisted.timeline, hasLength(1));
      },
    );

    test(
      'failed audit writes roll back escalation and the next run retries safely',
      () async {
        final incident = (await report()).incident;
        await makeDue(incident);
        final session = sessionBuilder.build();
        // Fault injection is confined to this suite's disposable PostgreSQL DB.
        await session.db.unsafeExecute('''
CREATE FUNCTION relayaid_test_reject_escalation() RETURNS trigger AS \$\$
BEGIN
  IF NEW."eventType" = 'escalated' THEN
    RAISE EXCEPTION 'Test-only simulated audit storage failure';
  END IF;
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;
''');
        await session.db.unsafeExecute('''
CREATE TRIGGER relayaid_test_escalation_failure
BEFORE INSERT ON relay_incident_event
FOR EACH ROW EXECUTE FUNCTION relayaid_test_reject_escalation();
''');
        try {
          await check();
          final failed = await detail(incident);
          expect(failed.incident.escalatedAt, isNull);
          expect(failed.incident.updatedAt, incident.updatedAt);
          expect(
            failed.incident.escalationDueAt!.isBefore(DateTime.now().toUtc()),
            isTrue,
          );
          expect(failed.timeline, hasLength(1));
        } finally {
          await session.db.unsafeExecute(
            'DROP TRIGGER relayaid_test_escalation_failure ON relay_incident_event;',
          );
          await session.db.unsafeExecute(
            'DROP FUNCTION relayaid_test_reject_escalation();',
          );
        }
        await check();
        final recovered = await detail(incident);
        expect(recovered.incident.escalatedAt, isNotNull);
        expect(recovered.timeline, hasLength(2));
        expect(recovered.timeline.last.eventType, IncidentEventType.escalated);
      },
    );

    test('before deadline and non-critical reports never escalate', () async {
      final critical = (await report()).incident;
      final high = (await report(severity: IncidentSeverity.high)).incident;
      await makeDue(high);
      await check();
      for (final incident in [critical, high]) {
        final persisted = await detail(incident);
        expect(persisted.incident.escalatedAt, isNull);
        expect(persisted.timeline, hasLength(1));
      }
    });

    test('acknowledged and cancelled reports never escalate', () async {
      for (final status in [
        IncidentStatus.acknowledged,
        IncidentStatus.cancelled,
      ]) {
        final incident = (await report()).incident;
        await makeDue(incident);
        await endpoints.incident.transition(
          signed(admin),
          incident.id!,
          status,
        );
        await check();
        final persisted = await detail(incident);
        expect(persisted.incident.escalatedAt, isNull);
        expect(persisted.timeline, hasLength(2));
      }
    });

    test(
      'assigned, accepted, responding and resolved reports never escalate',
      () async {
        final incident = (await report()).incident;
        await makeDue(incident);
        final assigned = await endpoints.assignment.assign(
          signed(admin),
          incident.id!,
          alpha.id!,
        );
        await check();
        final assignmentId = assigned.assignment!.id!;
        await endpoints.assignment.accept(signed(responder), assignmentId);
        await check();
        await endpoints.assignment.respond(signed(responder), assignmentId);
        await check();
        await endpoints.assignment.resolve(
          signed(responder),
          assignmentId,
          'Everyone has been evacuated.',
        );
        await check();
        final persisted = await detail(incident);
        expect(persisted.incident.escalatedAt, isNull);
        expect(persisted.timeline, hasLength(5));
        expect(persisted.incident.status, IncidentStatus.resolved);
      },
    );

    test(
      'an assignment row suppresses escalation even if status is inconsistent',
      () async {
        final incident = (await report()).incident;
        await makeDue(incident);
        await endpoints.assignment.assign(
          signed(admin),
          incident.id!,
          alpha.id!,
        );
        final assigned = await detail(incident);
        await Incident.db.updateRow(
          sessionBuilder.build(),
          assigned.incident.copyWith(status: IncidentStatus.reported),
        );
        await check();
        expect((await detail(incident)).incident.escalatedAt, isNull);
      },
    );

    test(
      'coordinator handling clears attention but preserves escalation history',
      () async {
        final incident = (await report()).incident;
        await makeDue(incident);
        await check();
        final escalated = await detail(incident);
        await endpoints.incident.transition(
          signed(admin),
          incident.id!,
          IncidentStatus.acknowledged,
        );
        await endpoints.assignment.assign(
          signed(admin),
          incident.id!,
          alpha.id!,
        );
        await check();
        final handled = await detail(incident);
        expect(handled.incident.escalatedAt, escalated.incident.escalatedAt);
        expect(handled.timeline.map((e) => e.eventType), [
          IncidentEventType.created,
          IncidentEventType.escalated,
          IncidentEventType.statusChanged,
          IncidentEventType.assignmentCreated,
        ]);
      },
    );

    test(
      'assignment racing escalation never creates an event after assignment',
      () async {
        final incident = (await report()).incident;
        await makeDue(incident);
        await Future.wait([
          check(),
          endpoints.assignment.assign(signed(admin), incident.id!, alpha.id!),
        ]);
        final persisted = await detail(incident);
        expect(persisted.incident.status, IncidentStatus.assigned);
        expect(
          persisted.timeline.last.eventType,
          IncidentEventType.assignmentCreated,
        );
        expect(
          persisted.timeline
              .where((e) => e.eventType == IncidentEventType.escalated)
              .length,
          lessThanOrEqualTo(1),
        );
        await check();
        expect(
          (await detail(incident)).timeline.length,
          persisted.timeline.length,
        );
      },
    );

    test(
      'a bounded run continues its backlog in subsequent Future Calls',
      () async {
        final now = DateTime.now().toUtc();
        await Incident.db.insert(sessionBuilder.build(), [
          for (
            var index = 0;
            index <= IncidentEscalationService.batchSize;
            index++
          )
            Incident(
              organizationId: organization.organization.id!,
              reportedBy: admin,
              type: IncidentType.flooding,
              severity: IncidentSeverity.critical,
              status: IncidentStatus.reported,
              title: 'Critical report $index',
              description: 'The crossing is blocked.',
              peopleAffected: 1,
              escalationDueAt: now.subtract(const Duration(seconds: 1)),
            ),
        ]);
        await check();
        expect(
          await IncidentEvent.db.count(sessionBuilder.build()),
          IncidentEscalationService.batchSize,
        );
        await check();
        expect(
          await IncidentEvent.db.count(sessionBuilder.build()),
          IncidentEscalationService.batchSize + 1,
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
