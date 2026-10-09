import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:relayaid_server/src/services/incident_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('incident domain', (sessionBuilder, endpoints) {
    final administrator = Uuid().v4obj();
    final secondAdministrator = Uuid().v4obj();
    final fieldWorker = Uuid().v4obj();

    TestSessionBuilder signedIn(UuidValue userId) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userId.toString(),
        {},
      ),
    );

    Future<OrganizationContext> createOrganization(
      UuidValue userId,
      String name,
    ) => endpoints.organization.create(signedIn(userId), name);

    Future<IncidentDetail> createIncident({
      required UuidValue userId,
      String title = 'Flooded bridge',
      IncidentSeverity severity = IncidentSeverity.high,
    }) => endpoints.incident.create(
      signedIn(userId),
      type: IncidentType.flooding,
      severity: severity,
      title: title,
      description: 'Water has crossed the bridge and traffic is blocked.',
      latitude: -0.3031,
      longitude: 36.0800,
      peopleAffected: 12,
    );

    setUp(() async {
      await createOrganization(administrator, 'Incident response');
    });

    test('creates an incident with an immutable creation event', () async {
      final created = await createIncident(userId: administrator);

      expect(created.incident.status, IncidentStatus.reported);
      expect(created.incident.reportedBy, administrator);
      expect(created.incident.latitude, -0.3031);
      expect(created.timeline, hasLength(1));
      expect(created.timeline.single.eventType, IncidentEventType.created);
      expect(created.timeline.single.toStatus, IncidentStatus.reported);
      expect(created.timeline.single.actorId, administrator);
    });

    test(
      'preserves a client UUID and makes an offline retry idempotent',
      () async {
        final offlineId = Uuid().v7obj();
        final first = await endpoints.incident.create(
          signedIn(administrator),
          id: offlineId,
          type: IncidentType.flooding,
          severity: IncidentSeverity.high,
          title: 'Flooded bridge',
          description: 'Water has crossed the bridge and traffic is blocked.',
          latitude: -0.3031,
          longitude: 36.0800,
          peopleAffected: 12,
        );
        final retried = await endpoints.incident.create(
          signedIn(administrator),
          id: offlineId,
          type: IncidentType.flooding,
          severity: IncidentSeverity.high,
          title: 'Flooded bridge',
          description: 'Water has crossed the bridge and traffic is blocked.',
          latitude: -0.3031,
          longitude: 36.0800,
          peopleAffected: 12,
        );

        expect(first.incident.id, offlineId);
        expect(retried.incident.id, offlineId);
        expect(retried.timeline, hasLength(1));
      },
    );

    test('validates report fields before writing', () async {
      await expectLater(
        endpoints.incident.create(
          signedIn(administrator),
          type: IncidentType.medical,
          severity: IncidentSeverity.moderate,
          title: 'x',
          description: 'A valid description.',
          latitude: null,
          longitude: null,
          peopleAffected: 1,
        ),
        throwsA(isA<IncidentValidationException>()),
      );
      await expectLater(
        endpoints.incident.create(
          signedIn(administrator),
          type: IncidentType.medical,
          severity: IncidentSeverity.moderate,
          title: 'Medical request',
          description: 'A valid description.',
          latitude: 91,
          longitude: 36,
          peopleAffected: 1,
        ),
        throwsA(isA<IncidentValidationException>()),
      );
    });

    test(
      'rejects nonfinite GPS coordinates without persisting a report',
      () async {
        for (final value in [
          double.nan,
          double.infinity,
          double.negativeInfinity,
        ]) {
          for (final latitude in [true, false]) {
            await expectLater(
              IncidentService.create(
                signedIn(administrator).build(),
                type: IncidentType.flooding,
                severity: IncidentSeverity.high,
                title: 'Invalid coordinates',
                description: 'Location must be finite.',
                latitude: latitude ? value : -0.3031,
                longitude: latitude ? 36.08 : value,
                peopleAffected: 12,
              ),
              throwsA(isA<IncidentValidationException>()),
            );
          }
        }
        expect(
          await endpoints.incident.list(signedIn(administrator), limit: 50),
          isEmpty,
        );
      },
    );

    test('enforces organization boundaries for lists and details', () async {
      final firstIncident = await createIncident(userId: administrator);
      await createOrganization(secondAdministrator, 'Other organization');

      expect(
        await endpoints.incident.list(signedIn(secondAdministrator), limit: 50),
        isEmpty,
      );
      await expectLater(
        endpoints.incident.detail(
          signedIn(secondAdministrator),
          firstIncident.incident.id!,
        ),
        throwsA(isA<AuthorizationException>()),
      );
    });

    test('acknowledges and cancels with immutable timeline events', () async {
      final created = await createIncident(userId: administrator);
      var current = created;
      for (final status in <IncidentStatus>[
        IncidentStatus.acknowledged,
        IncidentStatus.cancelled,
      ]) {
        current = await endpoints.incident.transition(
          signedIn(administrator),
          current.incident.id!,
          status,
          note: 'Moved to ${status.name}',
        );
      }

      expect(current.incident.status, IncidentStatus.cancelled);
      expect(current.timeline, hasLength(3));
      expect(
        current.timeline.map((event) => event.toStatus),
        [
          IncidentStatus.reported,
          IncidentStatus.acknowledged,
          IncidentStatus.cancelled,
        ],
      );
      await expectLater(
        endpoints.incident.transition(
          signedIn(administrator),
          current.incident.id!,
          IncidentStatus.responding,
        ),
        throwsA(isA<IncidentValidationException>()),
      );
    });

    test('only coordinators and administrators may change status', () async {
      final organization = await endpoints.organization.myContext(
        signedIn(administrator),
      );
      await OrganizationMember.db.insertRow(
        sessionBuilder.build(),
        OrganizationMember(
          organizationId: organization!.organization.id!,
          authUserId: fieldWorker,
          role: MemberRole.fieldWorker,
        ),
      );
      final created = await createIncident(userId: fieldWorker);

      await expectLater(
        endpoints.incident.transition(
          signedIn(fieldWorker),
          created.incident.id!,
          IncidentStatus.acknowledged,
        ),
        throwsA(isA<AuthorizationException>()),
      );
    });
  });
}
