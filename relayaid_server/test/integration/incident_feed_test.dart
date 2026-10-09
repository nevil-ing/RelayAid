import 'dart:async';

import 'package:relayaid_client/relayaid_client.dart' as client;
import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:relayaid_server/src/generated/future_calls.dart';
import 'package:relayaid_server/src/services/incident_escalation_service.dart';
import 'package:relayaid_server/src/services/incident_feed_service.dart';
import 'package:serverpod/serverpod.dart';
// Serverpod 4.0.1's explicit test-only setter is not in its public exports.
// This import is confined to this integration test, never application code.
import 'package:serverpod/src/server/server.dart' show ServerInternalMethods;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  // Real HTTP writes and WebSocket reads must share committed test data.
  // The random-token authentication handler exists only in this isolated suite;
  // production JWT authentication is not changed or bypassed.
  withServerpod('live incident feed over WebSockets', (
    sessionBuilder,
    endpoints,
  ) {
    late UuidValue administrator;
    late OrganizationContext organization;
    late AuthenticationHandler originalHandler;
    late client.Client coordinatorClient;
    final usersByToken = <String, UuidValue>{};
    final clients = <client.Client>[];
    final organizations = <Organization>[];
    final streams = <StreamIterator<client.IncidentFeed>>[];

    TestSessionBuilder signedIn(UuidValue user) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        user.toString(),
        {},
      ),
    );

    client.Client connect([UuidValue? user]) {
      final remote = client.Client(
        'http://localhost:${sessionBuilder.build().server.port}/',
      );
      if (user != null) {
        final token = Uuid().v4();
        usersByToken[token] = user;
        remote.authKeyProvider = _TestAuthKey(token);
      }
      clients.add(remote);
      return remote;
    }

    Future<client.IncidentFeed> next(
      StreamIterator<client.IncidentFeed> stream,
    ) async {
      expect(
        await stream.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      return stream.current;
    }

    StreamIterator<client.IncidentFeed> watch(client.Client remote) {
      final stream = StreamIterator(remote.incidentFeed.watch());
      streams.add(stream);
      return stream;
    }

    Future<client.IncidentDetail> report(
      client.Client remote, {
      UuidValue? id,
      String title = 'Flooded bridge',
      client.IncidentSeverity severity = client.IncidentSeverity.high,
    }) => remote.incident.create(
      id: id,
      type: client.IncidentType.flooding,
      severity: severity,
      title: title,
      description: 'The crossing is blocked by flood water.',
      latitude: -0.3031,
      longitude: 36.08,
      peopleAffected: 12,
    );

    setUp(() async {
      final server = sessionBuilder.build().server;
      originalHandler = server.authenticationHandler;
      server.setAuthenticationHandlerForTesting((session, token) async {
        final user = usersByToken[token];
        return user == null
            ? null
            : AuthenticationInfo(user.toString(), {}, authId: token);
      });
      administrator = Uuid().v4obj();
      organization = await endpoints.organization.create(
        signedIn(administrator),
        'Live feed response',
      );
      organizations.add(organization.organization);
      coordinatorClient = connect(administrator);
    });

    tearDown(() async {
      await sessionBuilder.build().server.serverpod.futureCalls.cancel(
        IncidentEscalationService.scheduleIdentifier,
      );
      for (final stream in streams) {
        await stream.cancel();
      }
      streams.clear();
      for (final remote in clients) {
        await remote.closeStreamingMethodConnections();
        remote.close();
      }
      clients.clear();
      sessionBuilder.build().server.setAuthenticationHandlerForTesting(
        originalHandler,
      );
      usersByToken.clear();
      final session = sessionBuilder.build();
      for (final org in organizations) {
        await IncidentEvent.db.deleteWhere(
          session,
          where: (t) => t.organizationId.equals(org.id!),
        );
        await Incident.db.deleteWhere(
          session,
          where: (t) => t.organizationId.equals(org.id!),
        );
        await OrganizationMember.db.deleteWhere(
          session,
          where: (t) => t.organizationId.equals(org.id!),
        );
        await Organization.db.deleteRow(session, org);
      }
      organizations.clear();
    });

    test(
      'requires authentication and a server-held coordinator role',
      () async {
        await expectLater(
          connect().incidentFeed.watch().first,
          throwsA(isA<client.ServerpodClientUnauthorized>()),
        );
        for (final role in [MemberRole.fieldWorker, MemberRole.responder]) {
          final user = Uuid().v4obj();
          await OrganizationMember.db.insertRow(
            sessionBuilder.build(),
            OrganizationMember(
              organizationId: organization.organization.id!,
              authUserId: user,
              role: role,
            ),
          );
          await expectLater(
            connect(user).incidentFeed.watch().first,
            throwsA(isA<client.AuthorizationException>()),
          );
        }
        final coordinator = Uuid().v4obj();
        await OrganizationMember.db.insertRow(
          sessionBuilder.build(),
          OrganizationMember(
            organizationId: organization.organization.id!,
            authUserId: coordinator,
            role: MemberRole.coordinator,
          ),
        );
        expect(
          (await next(watch(connect(coordinator)))).organizationId,
          organization.organization.id,
        );
        expect(
          (await next(watch(coordinatorClient))).organizationId,
          organization.organization.id,
        );
      },
    );

    test(
      'publishes committed create and status changes with timeline activity',
      () async {
        final stream = watch(coordinatorClient);
        expect((await next(stream)).incidents, isEmpty);
        final created = await report(coordinatorClient);
        final createdFeed = await next(stream);
        expect(createdFeed.incidents.single.id, created.incident.id);
        expect(
          createdFeed.activity.single.event.eventType,
          client.IncidentEventType.created,
        );
        expect(createdFeed.activity.single.incidentTitle, 'Flooded bridge');
        // A new HTTP request proves the feed is not merely an in-memory echo.
        expect(
          (await coordinatorClient.incident.detail(
            created.incident.id!,
          )).timeline,
          hasLength(1),
        );
        await coordinatorClient.incident.transition(
          created.incident.id!,
          client.IncidentStatus.acknowledged,
        );
        final updated = await next(stream);
        expect(
          updated.incidents.single.status,
          client.IncidentStatus.acknowledged,
        );
        expect(updated.activity, hasLength(2));
        expect(
          updated.activity.first.event.toStatus,
          client.IncidentStatus.acknowledged,
        );
      },
    );

    test('snapshots and updates never expose another organization', () async {
      final otherUser = Uuid().v4obj();
      final otherOrganization = await endpoints.organization.create(
        signedIn(otherUser),
        'Other response',
      );
      organizations.add(otherOrganization.organization);
      final other = connect(otherUser);
      await report(other, title: 'Private other report');
      final stream = watch(coordinatorClient);
      final initial = await next(stream);
      expect(initial.incidents, isEmpty);
      expect(initial.activity, isEmpty);
      // If the other organization's channel leaks, that queued snapshot would
      // be returned before our own report's update below.
      await report(other, title: 'Another private report');
      final own = await report(coordinatorClient, title: 'Our report');
      final update = await next(stream);
      expect(update.organizationId, organization.organization.id);
      expect(update.incidents.map((incident) => incident.id), [
        own.incident.id,
      ]);
      expect(update.activity.map((entry) => entry.incidentTitle), [
        'Our report',
      ]);
    });

    test(
      'reopening catches changes missed while disconnected without duplicates',
      () async {
        final first = watch(coordinatorClient);
        await next(first);
        await first.cancel();
        final id = Uuid().v7obj();
        await report(coordinatorClient, id: id);
        await report(coordinatorClient, id: id);
        final second = watch(coordinatorClient);
        final snapshot = await next(second);
        expect(snapshot.incidents.map((incident) => incident.id), [id]);
        expect(snapshot.activity, hasLength(1));
      },
    );

    test(
      'revoked coordinator membership terminates an existing stream',
      () async {
        final user = Uuid().v4obj();
        final member = await OrganizationMember.db.insertRow(
          sessionBuilder.build(),
          OrganizationMember(
            organizationId: organization.organization.id!,
            authUserId: user,
            role: MemberRole.coordinator,
          ),
        );
        final stream = watch(connect(user));
        await next(stream);
        await OrganizationMember.db.updateRow(
          sessionBuilder.build(),
          member.copyWith(role: MemberRole.fieldWorker),
        );
        final denied = expectLater(
          stream.moveNext(),
          throwsA(isA<client.AuthorizationException>()),
        );
        await report(coordinatorClient);
        await denied;
      },
    );

    test(
      'invalid writes do not change the feed or persisted timeline',
      () async {
        final created = await report(coordinatorClient);
        await expectLater(
          coordinatorClient.incident.transition(
            created.incident.id!,
            client.IncidentStatus.resolved,
          ),
          throwsA(isA<client.IncidentValidationException>()),
        );
        final snapshot = await next(watch(coordinatorClient));
        expect(
          snapshot.incidents.single.status,
          client.IncidentStatus.reported,
        );
        expect(snapshot.activity, hasLength(1));
      },
    );

    test(
      'real scheduled escalation reaches the typed client over WebSockets',
      () async {
        final stream = watch(coordinatorClient);
        await next(stream);
        final created = await report(
          coordinatorClient,
          severity: client.IncidentSeverity.critical,
        );
        await next(stream);
        final session = sessionBuilder.build();
        final persisted = await Incident.db.findById(
          session,
          created.incident.id!,
        );
        await Incident.db.updateRow(
          session,
          persisted!.copyWith(
            escalationDueAt: DateTime.now().toUtc().subtract(
              const Duration(seconds: 1),
            ),
          ),
        );
        await IncidentEscalationService.ensureScheduled(session);
        expect(
          await stream.moveNext().timeout(const Duration(seconds: 15)),
          isTrue,
        );
        final live = stream.current;
        expect(live.incidents.single.id, created.incident.id);
        expect(live.incidents.single.status, client.IncidentStatus.reported);
        expect(live.incidents.single.escalatedAt, isNotNull);
        expect(
          live.activity.first.event.eventType,
          client.IncidentEventType.escalated,
        );
        expect(live.activity.first.event.actorId, isNull);
        final detail = await coordinatorClient.incident.detail(
          created.incident.id!,
        );
        expect(detail.timeline, hasLength(2));
        expect(
          detail.timeline.last.eventType,
          client.IncidentEventType.escalated,
        );
      },
    );

    test(
      'snapshot limits retain older escalations ahead of recent reports',
      () async {
        final session = sessionBuilder.build();
        final incidents = await Incident.db.insert(session, [
          for (
            var index = 0;
            index <= IncidentFeedService.maxIncidents;
            index++
          )
            Incident(
              organizationId: organization.organization.id!,
              reportedBy: administrator,
              type: IncidentType.flooding,
              severity: IncidentSeverity.high,
              status: IncidentStatus.reported,
              title: 'Report $index',
              description: 'A blocked crossing.',
              peopleAffected: 1,
            ),
        ]);
        await IncidentEvent.db.insert(session, [
          for (var index = 0; index <= IncidentFeedService.maxActivity; index++)
            IncidentEvent(
              organizationId: organization.organization.id!,
              incidentId: incidents[index].id!,
              actorId: administrator,
              eventType: IncidentEventType.created,
              toStatus: IncidentStatus.reported,
            ),
        ]);
        final oldEscalation = await Incident.db.insertRow(
          session,
          Incident(
            organizationId: organization.organization.id!,
            reportedBy: administrator,
            type: IncidentType.flooding,
            severity: IncidentSeverity.critical,
            status: IncidentStatus.reported,
            title: 'Older critical report',
            description: 'The crossing needs immediate attention.',
            peopleAffected: 12,
            escalationDueAt: DateTime.utc(2026, 1, 1),
            escalatedAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
        final snapshot = await next(watch(coordinatorClient));
        expect(snapshot.incidents, hasLength(IncidentFeedService.maxIncidents));
        expect(snapshot.incidents.first.id, oldEscalation.id);
        expect(snapshot.hasMoreIncidents, isTrue);
        expect(snapshot.activity, hasLength(IncidentFeedService.maxActivity));
        expect(
          snapshot.activity.every(
            (entry) => entry.incidentTitle.startsWith('Report '),
          ),
          isTrue,
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}

class _TestAuthKey implements client.ClientAuthKeyProvider {
  const _TestAuthKey(this.token);
  final String token;
  @override
  Future<String?> get authHeaderValue async =>
      client.wrapAsBearerAuthHeaderValue(token);
}
