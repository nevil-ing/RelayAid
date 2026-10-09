import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:relayaid_client/relayaid_client.dart' as client;
import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:relayaid_server/src/services/assignment_feed_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_client/serverpod_client.dart' show FileUploader;
// Explicit test-only setter in Serverpod 4.0.1; never used in application code.
import 'package:serverpod/src/server/server.dart' show ServerInternalMethods;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('assignment delivery over real WebSockets', (
    sessionBuilder,
    endpoints,
  ) {
    late OrganizationContext organization;
    late Team alpha;
    late UuidValue admin;
    late UuidValue responder;
    late UuidValue peer;
    late UuidValue outsider;
    late UuidValue fieldWorker;
    late AuthenticationHandler originalHandler;
    late client.Client coordinatorClient;
    late client.Client responderClient;
    late client.Client fieldClient;
    final tokens = <String, UuidValue>{};
    final clients = <client.Client>[];
    final streams = <StreamIterator<dynamic>>[];

    TestSessionBuilder signed(UuidValue id) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        id.toString(),
        {},
      ),
    );
    client.Client connect([UuidValue? user]) {
      final remote = client.Client(
        'http://localhost:${sessionBuilder.build().server.port}/',
      );
      if (user != null) {
        final token = Uuid().v4();
        tokens[token] = user;
        remote.authKeyProvider = _TestAuthKey(token);
      }
      clients.add(remote);
      return remote;
    }

    StreamIterator<T> watch<T>(Stream<T> stream) {
      final iterator = StreamIterator<T>(stream);
      streams.add(iterator);
      return iterator;
    }

    Future<T> next<T>(StreamIterator<T> stream) async {
      expect(
        await stream.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      return stream.current;
    }

    Future<client.IncidentDetail> report() => coordinatorClient.incident.create(
      type: client.IncidentType.flooding,
      severity: client.IncidentSeverity.high,
      title: 'Flooded bridge',
      description: 'Water has blocked the crossing.',
      latitude: -0.3031,
      longitude: 36.08,
      peopleAffected: 12,
    );
    Future<client.IncidentDetail> assign({UuidValue? designated}) async {
      final detail = await report();
      return coordinatorClient.assignment.assign(
        detail.incident.id!,
        alpha.id!,
        responderId: designated,
      );
    }

    setUp(() async {
      final server = sessionBuilder.build().server;
      originalHandler = server.authenticationHandler;
      server.setAuthenticationHandlerForTesting((session, token) async {
        final id = tokens[token];
        return id == null
            ? null
            : AuthenticationInfo(id.toString(), {}, authId: token);
      });
      admin = Uuid().v4obj();
      responder = Uuid().v4obj();
      peer = Uuid().v4obj();
      outsider = Uuid().v4obj();
      fieldWorker = Uuid().v4obj();
      organization = await endpoints.organization.create(
        signed(admin),
        'Live assignment response',
      );
      for (final id in [responder, peer, outsider]) {
        await OrganizationMember.db.insertRow(
          sessionBuilder.build(),
          OrganizationMember(
            organizationId: organization.organization.id!,
            authUserId: id,
            role: MemberRole.responder,
          ),
        );
      }
      alpha = await endpoints.organization.createTeam(
        signed(admin),
        organization.organization.id!,
        'Team Alpha',
      );
      await endpoints.team.addResponder(signed(admin), alpha.id!, responder);
      await endpoints.team.addResponder(signed(admin), alpha.id!, peer);
      await OrganizationMember.db.insertRow(
        sessionBuilder.build(),
        OrganizationMember(
          organizationId: organization.organization.id!,
          authUserId: fieldWorker,
          role: MemberRole.fieldWorker,
        ),
      );
      coordinatorClient = connect(admin);
      responderClient = connect(responder);
      fieldClient = connect(fieldWorker);
    });

    tearDown(() async {
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
      tokens.clear();
      final session = sessionBuilder.build();
      final id = organization.organization.id!;
      final photos = await IncidentAttachment.db.find(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      for (final photo in photos) {
        await session.storage.deleteFile(
          storageId: 'private',
          path: photo.storagePath!,
        );
        await session.storage.deleteFile(
          storageId: 'private',
          path:
              'uploads/$id/${photo.incidentId}/${photo.uploadedBy}/${photo.id}',
        );
      }
      await IncidentAttachment.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      await Assignment.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      await IncidentEvent.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      await Incident.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      final teams = await Team.db.find(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      await TeamMember.db.deleteWhere(
        session,
        where: (t) => t.teamId.inSet(teams.map((team) => team.id!).toSet()),
      );
      await Team.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      await OrganizationMember.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(id),
      );
      await Organization.db.deleteRow(session, organization.organization);
    });

    test(
      'stream requires authentication and a current responder role',
      () async {
        await expectLater(
          connect().assignment.watch().first,
          throwsA(isA<client.ServerpodClientUnauthorized>()),
        );
        await expectLater(
          coordinatorClient.assignment.watch().first,
          throwsA(isA<client.AuthorizationException>()),
        );
        final snapshot = await next(watch(responderClient.assignment.watch()));
        expect(snapshot.authUserId, responder);
        expect(snapshot.organizationId, organization.organization.id);
      },
    );

    test(
      'assignment, acceptance, response and resolution update both live clients',
      () async {
        final coordinator = watch(coordinatorClient.incidentFeed.watch());
        final inbox = watch(responderClient.assignment.watch());
        expect((await next(coordinator)).incidents, isEmpty);
        expect((await next(inbox)).assignments, isEmpty);
        final created = await report();
        await next(coordinator);
        expect((await next(inbox)).assignments, isEmpty);
        var detail = await coordinatorClient.assignment.assign(
          created.incident.id!,
          alpha.id!,
        );
        final id = detail.assignment!.id!;
        expect((await next(inbox)).assignments.single.teamName, 'Team Alpha');
        var command = await next(coordinator);
        expect(command.incidents.single.status, client.IncidentStatus.assigned);
        expect(command.teams!.single.activeAssignments, 1);
        expect(command.activity.first.event.assignmentId, id);
        detail = await responderClient.assignment.accept(id);
        expect(
          (await next(inbox)).assignments.single.assignment.status,
          client.AssignmentStatus.accepted,
        );
        expect(
          (await next(coordinator)).activity.first.event.eventType,
          client.IncidentEventType.assignmentAccepted,
        );
        detail = await responderClient.assignment.respond(id);
        expect(
          (await next(inbox)).assignments.single.incident.status,
          client.IncidentStatus.responding,
        );
        expect(
          (await next(coordinator)).incidents.single.status,
          client.IncidentStatus.responding,
        );
        detail = await responderClient.assignment.resolve(
          id,
          'Crossing secured and residents safe.',
        );
        expect(
          (await next(inbox)).assignments.single.assignment.status,
          client.AssignmentStatus.resolved,
        );
        command = await next(coordinator);
        expect(command.incidents.single.status, client.IncidentStatus.resolved);
        expect(command.teams!.single.activeAssignments, 0);
        final persisted = await coordinatorClient.incident.detail(
          created.incident.id!,
        );
        expect(persisted.timeline, hasLength(5));
        expect(
          persisted.timeline.last.note,
          'Crossing secured and residents safe.',
        );
        expect(persisted.assignment!.acceptedBy, responder);
        expect(detail.assignment!.resolvedAt, isNotNull);
      },
    );

    test(
      'demo rehearsal persists a UUID report, real photo and complete live response timeline',
      () async {
        final command = watch(coordinatorClient.incidentFeed.watch());
        final inbox = watch(responderClient.assignment.watch());
        expect((await next(command)).incidents, isEmpty);
        expect((await next(inbox)).assignments, isEmpty);
        final offlineId = Uuid().v7obj();
        Future<client.IncidentDetail>
        syncReport() => fieldClient.incident.create(
          id: offlineId,
          type: client.IncidentType.flooding,
          severity: client.IncidentSeverity.high,
          title: 'Flooded bridge — rehearsal',
          description:
              'Water has blocked the only crossing. Demo data, not a real emergency.',
          latitude: -0.3031,
          longitude: 36.08,
          peopleAffected: 12,
        );
        final created = await syncReport();
        expect(created.incident.id, offlineId);
        expect((await next(command)).incidents.single.reportedBy, fieldWorker);
        expect((await next(inbox)).assignments, isEmpty);

        final bytes = ByteData.sublistView(
          image.encodePng(image.Image(width: 2, height: 2)),
        );
        final photoId = Uuid().v7obj();
        final upload = await fieldClient.media.beginUpload(
          offlineId,
          photoId,
          contentType: 'image/png',
          byteLength: bytes.lengthInBytes,
        );
        final description = jsonDecode(upload!) as Map<String, dynamic>;
        final address = Uri.parse(description['url'] as String);
        if (address.port == 0) {
          description['url'] = address
              .replace(port: sessionBuilder.build().server.port)
              .toString();
        }
        expect(
          await FileUploader(jsonEncode(description)).uploadByteData(bytes),
          isTrue,
        );
        await fieldClient.media.completeUpload(offlineId, photoId);
        expect(
          (await next(command)).activity.first.event.eventType,
          client.IncidentEventType.attachmentAdded,
        );
        expect((await next(inbox)).assignments, isEmpty);
        final storedPhoto = await coordinatorClient.media.read(photoId);
        expect(
          storedPhoto.buffer.asUint8List(
            storedPhoto.offsetInBytes,
            storedPhoto.lengthInBytes,
          ),
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );

        final assigned = await coordinatorClient.assignment.assign(
          offlineId,
          alpha.id!,
        );
        final assignmentId = assigned.assignment!.id!;
        expect(
          (await next(command)).incidents.single.status,
          client.IncidentStatus.assigned,
        );
        expect((await next(inbox)).assignments.single.teamName, 'Team Alpha');
        await responderClient.assignment.accept(assignmentId);
        expect(
          (await next(command)).activity.first.event.eventType,
          client.IncidentEventType.assignmentAccepted,
        );
        expect(
          (await next(inbox)).assignments.single.assignment.acceptedBy,
          responder,
        );
        await responderClient.assignment.respond(assignmentId);
        expect(
          (await next(command)).incidents.single.status,
          client.IncidentStatus.responding,
        );
        expect(
          (await next(inbox)).assignments.single.incident.status,
          client.IncidentStatus.responding,
        );
        await responderClient.assignment.resolve(
          assignmentId,
          'Crossing secured and residents safely evacuated.',
        );
        final resolvedFeed = await next(command);
        expect(
          resolvedFeed.incidents.single.status,
          client.IncidentStatus.resolved,
        );
        expect(resolvedFeed.teams!.single.activeAssignments, 0);
        expect(
          (await next(inbox)).assignments.single.assignment.status,
          client.AssignmentStatus.resolved,
        );

        final detail =
            await syncReport(); // A lost metadata response may be replayed even after resolution.
        expect(detail.timeline.map((e) => e.eventType), [
          client.IncidentEventType.created,
          client.IncidentEventType.attachmentAdded,
          client.IncidentEventType.assignmentCreated,
          client.IncidentEventType.assignmentAccepted,
          client.IncidentEventType.responseStarted,
          client.IncidentEventType.assignmentResolved,
        ]);
        expect(detail.timeline.first.actorId, fieldWorker);
        expect(detail.timeline.last.actorId, responder);
        expect(
          detail.timeline.last.note,
          'Crossing secured and residents safely evacuated.',
        );
        final session = sessionBuilder.build();
        expect(
          (await Incident.db.findById(session, offlineId))!.status,
          IncidentStatus.resolved,
        );
        expect(
          (await IncidentAttachment.db.findById(session, photoId))!.incidentId,
          offlineId,
        );
        expect(
          await IncidentEvent.db.count(
            session,
            where: (t) => t.incidentId.equals(offlineId),
          ),
          6,
        );
      },
    );

    test(
      'team peers do not receive another designated responder assignment',
      () async {
        await assign(designated: responder);
        final own = await next(watch(responderClient.assignment.watch()));
        final peerFeed = await next(watch(connect(peer).assignment.watch()));
        final outside = await next(watch(connect(outsider).assignment.watch()));
        expect(own.assignments, hasLength(1));
        expect(peerFeed.assignments, isEmpty);
        expect(outside.assignments, isEmpty);
      },
    );

    test('cross-organization roster corruption cannot leak incidents', () async {
      final otherId = Uuid().v4obj();
      final otherOrg = await endpoints.organization.create(
        signed(otherId),
        'Private other organization',
      );
      final otherResponder = Uuid().v4obj();
      await OrganizationMember.db.insertRow(
        sessionBuilder.build(),
        OrganizationMember(
          organizationId: otherOrg.organization.id!,
          authUserId: otherResponder,
          role: MemberRole.responder,
        ),
      );
      // Deliberate invalid test data: even a guessed foreign team ID is filtered.
      final entry = await TeamMember.db.insertRow(
        sessionBuilder.build(),
        TeamMember(teamId: alpha.id!, authUserId: otherResponder),
      );
      await assign();
      expect(
        (await next(
          watch(connect(otherResponder).assignment.watch()),
        )).assignments,
        isEmpty,
      );
      await TeamMember.db.deleteRow(sessionBuilder.build(), entry);
      await OrganizationMember.db.deleteWhere(
        sessionBuilder.build(),
        where: (t) => t.organizationId.equals(otherOrg.organization.id!),
      );
      await Organization.db.deleteRow(
        sessionBuilder.build(),
        otherOrg.organization,
      );
    });

    test(
      'adding to a roster delivers existing assignments without restarting the app',
      () async {
        final detail = await assign();
        final remote = connect(outsider);
        final inbox = watch(remote.assignment.watch());
        expect((await next(inbox)).assignments, isEmpty);
        await coordinatorClient.team.addResponder(alpha.id!, outsider);
        expect(
          (await next(inbox)).assignments.single.assignment.id,
          detail.assignment!.id,
        );
        await TeamMember.db.deleteWhere(
          sessionBuilder.build(),
          where: (t) =>
              t.teamId.equals(alpha.id!) & t.authUserId.equals(outsider),
        );
        await report();
        expect((await next(inbox)).assignments, isEmpty);
      },
    );

    test('revoked responder role terminates a long-lived feed', () async {
      final inbox = watch(responderClient.assignment.watch());
      await next(inbox);
      final membership = (await OrganizationMember.db.find(
        sessionBuilder.build(),
        where: (t) => t.authUserId.equals(responder),
      )).single;
      await OrganizationMember.db.updateRow(
        sessionBuilder.build(),
        membership.copyWith(role: MemberRole.fieldWorker),
      );
      final denied = expectLater(
        inbox.moveNext(),
        throwsA(isA<client.AuthorizationException>()),
      );
      await report();
      await denied;
    });

    test(
      'reopening catches missed assignments and reconnect sees current state',
      () async {
        final first = watch(responderClient.assignment.watch());
        await next(first);
        await first.cancel();
        final detail = await assign();
        await coordinatorClient.assignment.assign(
          detail.incident.id!,
          alpha.id!,
        );
        final second = watch(responderClient.assignment.watch());
        expect(
          (await next(second)).assignments.single.assignment.id,
          detail.assignment!.id,
        );
        await second.cancel();
        await responderClient.assignment.accept(detail.assignment!.id!);
        await responderClient.assignment.respond(detail.assignment!.id!);
        final reopened = await next(watch(responderClient.assignment.watch()));
        expect(
          reopened.assignments.single.assignment.status,
          client.AssignmentStatus.responding,
        );
        expect(
          (await responderClient.assignment.detail(
            detail.assignment!.id!,
          )).timeline,
          hasLength(4),
        );
      },
    );

    test(
      'simultaneous accepts have one winner and one acceptance event',
      () async {
        final detail = await assign();
        final other = connect(peer);
        Future<Object> accept(client.Client remote) async {
          try {
            return await remote.assignment.accept(detail.assignment!.id!);
          } catch (error) {
            return error;
          }
        }

        final results = await Future.wait([
          accept(responderClient),
          accept(other),
        ]);
        expect(results.whereType<client.IncidentDetail>(), hasLength(1));
        expect(
          results.whereType<client.AuthorizationException>(),
          hasLength(1),
        );
        final persisted = await coordinatorClient.incident.detail(
          detail.incident.id!,
        );
        expect(
          persisted.timeline.where(
            (e) => e.eventType == client.IncidentEventType.assignmentAccepted,
          ),
          hasLength(1),
        );
        expect(
          persisted.assignment!.acceptedBy,
          results
              .whereType<client.IncidentDetail>()
              .single
              .assignment!
              .acceptedBy,
        );
      },
    );

    test(
      'concurrent assignment retries produce a single database record',
      () async {
        final detail = await report();
        final results = await Future.wait(
          List.generate(
            4,
            (_) => coordinatorClient.assignment.assign(
              detail.incident.id!,
              alpha.id!,
            ),
          ),
        );
        expect(results.map((d) => d.assignment!.id).toSet(), hasLength(1));
        expect(
          (await coordinatorClient.incident.detail(
            detail.incident.id!,
          )).timeline,
          hasLength(2),
        );
      },
    );

    test(
      'cancellation is delivered live with matching assignment and incident states',
      () async {
        final detail = await assign();
        final inbox = watch(responderClient.assignment.watch());
        await next(inbox);
        await coordinatorClient.incident.transition(
          detail.incident.id!,
          client.IncidentStatus.cancelled,
        );
        final snapshot = await next(inbox);
        expect(
          snapshot.assignments.single.assignment.status,
          client.AssignmentStatus.cancelled,
        );
        expect(
          snapshot.assignments.single.incident.status,
          client.IncidentStatus.cancelled,
        );
      },
    );

    test(
      'active work is not displaced by history and snapshot limits are explicit',
      () async {
        final session = sessionBuilder.build();
        final incidents = await Incident.db.insert(session, [
          for (
            var i = 0;
            i <
                AssignmentFeedService.maxActive +
                    AssignmentFeedService.maxCompleted +
                    2;
            i++
          )
            Incident(
              organizationId: organization.organization.id!,
              reportedBy: admin,
              type: IncidentType.flooding,
              severity: IncidentSeverity.high,
              status: i <= AssignmentFeedService.maxActive
                  ? IncidentStatus.assigned
                  : IncidentStatus.resolved,
              title: 'Report $i',
              description: 'Crossing blocked.',
              peopleAffected: 1,
            ),
        ]);
        await Assignment.db.insert(session, [
          for (var i = 0; i < incidents.length; i++)
            Assignment(
              organizationId: organization.organization.id!,
              incidentId: incidents[i].id!,
              teamId: alpha.id!,
              assignedBy: admin,
              status: i <= AssignmentFeedService.maxActive
                  ? AssignmentStatus.pending
                  : AssignmentStatus.resolved,
            ),
        ]);
        final snapshot = await next(watch(responderClient.assignment.watch()));
        expect(
          snapshot.assignments,
          hasLength(
            AssignmentFeedService.maxActive +
                AssignmentFeedService.maxCompleted,
          ),
        );
        expect(snapshot.hasMoreAssignments, isTrue);
        expect(
          snapshot.assignments
              .take(AssignmentFeedService.maxActive)
              .every(
                (entry) =>
                    entry.assignment.status == client.AssignmentStatus.pending,
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
