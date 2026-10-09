import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as image;
import 'package:relayaid_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_client/serverpod_client.dart' show FileUploader;
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  // Direct uploads travel over HTTP and must see committed upload tokens.
  // Each test uses a unique organization; teardown removes only its test data.
  withServerpod('private incident photos', (sessionBuilder, endpoints) {
    late UuidValue userId;
    late OrganizationContext organization;
    late IncidentDetail incident;
    final uploadIds = <UuidValue>[];
    final bytes = ByteData.sublistView(
      image.encodePng(image.Image(width: 2, height: 2)),
    );

    TestSessionBuilder signedIn(UuidValue id) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        id.toString(),
        {},
      ),
    );

    setUp(() async {
      userId = Uuid().v4obj();
      uploadIds.clear();
      organization = await endpoints.organization.create(
        signedIn(userId),
        'Photo response',
      );
      incident = await endpoints.incident.create(
        signedIn(userId),
        type: IncidentType.flooding,
        severity: IncidentSeverity.high,
        title: 'Flooded bridge',
        description: 'Water has blocked the crossing.',
        latitude: null,
        longitude: null,
        peopleAffected: 12,
      );
    });

    tearDown(() async {
      final session = sessionBuilder.build();
      final orgId = organization.organization.id!;
      final attachments = await IncidentAttachment.db.find(
        session,
        where: (t) => t.organizationId.equals(orgId),
      );
      for (final photo in attachments) {
        await session.storage.deleteFile(
          storageId: 'private',
          path: photo.storagePath!,
        );
      }
      for (final id in uploadIds) {
        await session.storage.deleteFile(
          storageId: 'private',
          path: 'uploads/$orgId/${incident.incident.id}/$userId/$id',
        );
      }
      await IncidentAttachment.db.deleteWhere(
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
      await OrganizationMember.db.deleteWhere(
        session,
        where: (t) => t.organizationId.equals(orgId),
      );
      await Organization.db.deleteRow(session, organization.organization);
    });

    Future<String> begin(UuidValue id, {ByteData? data}) async {
      uploadIds.add(id);
      final description = (await endpoints.media.beginUpload(
        signedIn(userId),
        incident.incident.id!,
        id,
        contentType: 'image/png',
        byteLength: (data ?? bytes).lengthInBytes,
      ))!;
      final decoded = jsonDecode(description) as Map<String, dynamic>;
      final url = Uri.parse(decoded['url'] as String);
      // The test configuration deliberately advertises port zero. Resolve it
      // to the actual ephemeral listener, keeping the real upload token/path.
      if (url.port == 0) {
        decoded['url'] = url
            .replace(port: sessionBuilder.build().server.port)
            .toString();
      }
      return jsonEncode(decoded);
    }

    Future<IncidentAttachment> upload(UuidValue id) async {
      final description = await begin(id);
      expect(await FileUploader(description).uploadByteData(bytes), isTrue);
      return endpoints.media.completeUpload(
        signedIn(userId),
        incident.incident.id!,
        id,
      );
    }

    test(
      'real HTTP upload is verified, persisted, readable, and audited',
      () async {
        final feed = StreamIterator(
          endpoints.incidentFeed.watch(signedIn(userId)),
        );
        addTearDown(feed.cancel);
        expect(await feed.moveNext(), isTrue);
        expect(feed.current.activity, hasLength(1));
        final id = Uuid().v7obj();
        final attachment = await upload(id);
        expect(
          await feed.moveNext().timeout(const Duration(seconds: 5)),
          isTrue,
        );
        expect(
          feed.current.activity.first.event.eventType,
          IncidentEventType.attachmentAdded,
        );
        expect(attachment.id, id);
        expect(attachment.uploadedBy, userId);
        expect(attachment.contentType, 'image/png');
        expect(attachment.byteLength, bytes.lengthInBytes);
        expect(
          await endpoints.media.list(signedIn(userId), incident.incident.id!),
          hasLength(1),
        );
        final stored = await endpoints.media.read(signedIn(userId), id);
        expect(Uint8List.sublistView(stored), Uint8List.sublistView(bytes));
        final detail = await endpoints.incident.detail(
          signedIn(userId),
          incident.incident.id!,
        );
        expect(detail.timeline.map((e) => e.eventType), [
          IncidentEventType.created,
          IncidentEventType.attachmentAdded,
        ]);
      },
    );

    test(
      'duplicate finalize creates neither a duplicate photo nor event',
      () async {
        final id = Uuid().v7obj();
        await upload(id);
        expect(
          await endpoints.media.beginUpload(
            signedIn(userId),
            incident.incident.id!,
            id,
            contentType: 'image/png',
            byteLength: bytes.lengthInBytes,
          ),
          isNull,
        );
        await endpoints.media.completeUpload(
          signedIn(userId),
          incident.incident.id!,
          id,
        );
        final detail = await endpoints.incident.detail(
          signedIn(userId),
          incident.incident.id!,
        );
        expect(detail.timeline, hasLength(2));
        expect(
          await endpoints.media.list(signedIn(userId), incident.incident.id!),
          hasLength(1),
        );
      },
    );

    test(
      'requires sign-in and organization membership for uploads and reads',
      () async {
        final id = Uuid().v7obj();
        await upload(id);
        await expectLater(
          endpoints.media.list(sessionBuilder, incident.incident.id!),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        final other = Uuid().v4obj();
        await OrganizationMember.db.insertRow(
          sessionBuilder.build(),
          OrganizationMember(
            organizationId: Uuid().v4obj(),
            authUserId: other,
            role: MemberRole.administrator,
          ),
        );
        addTearDown(
          () => OrganizationMember.db.deleteWhere(
            sessionBuilder.build(),
            where: (t) => t.authUserId.equals(other),
          ),
        );
        await expectLater(
          endpoints.media.beginUpload(
            signedIn(other),
            incident.incident.id!,
            Uuid().v7obj(),
            contentType: 'image/png',
            byteLength: bytes.lengthInBytes,
          ),
          throwsA(isA<AuthorizationException>()),
        );
        await expectLater(
          endpoints.media.read(signedIn(other), id),
          throwsA(isA<AuthorizationException>()),
        );
        await expectLater(
          endpoints.media.completeUpload(
            signedIn(other),
            incident.incident.id!,
            id,
          ),
          throwsA(isA<AuthorizationException>()),
        );
      },
    );

    test(
      'invalid or incomplete upload never publishes metadata or history',
      () async {
        final id = Uuid().v7obj();
        await expectLater(
          endpoints.media.completeUpload(
            signedIn(userId),
            incident.incident.id!,
            id,
          ),
          throwsA(isA<AttachmentValidationException>()),
        );
        final fakeImage = ByteData.sublistView(
          Uint8List.fromList([1, 2, 3, 4]),
        );
        final description = await begin(id, data: fakeImage);
        expect(
          await FileUploader(description).uploadByteData(fakeImage),
          isTrue,
        );
        await expectLater(
          endpoints.media.completeUpload(
            signedIn(userId),
            incident.incident.id!,
            id,
          ),
          throwsA(isA<AttachmentValidationException>()),
        );
        expect(
          await endpoints.media.list(signedIn(userId), incident.incident.id!),
          isEmpty,
        );
        expect(
          (await endpoints.incident.detail(
            signedIn(userId),
            incident.incident.id!,
          )).timeline,
          hasLength(1),
        );
      },
    );

    test(
      'rejects oversized declarations, non-photo types, and wrong actual size',
      () async {
        final id = Uuid().v7obj();
        await expectLater(
          endpoints.media.beginUpload(
            signedIn(userId),
            incident.incident.id!,
            id,
            contentType: 'image/png',
            byteLength: 5 * 1024 * 1024 + 1,
          ),
          throwsA(isA<AttachmentValidationException>()),
        );
        await expectLater(
          endpoints.media.beginUpload(
            signedIn(userId),
            incident.incident.id!,
            id,
            contentType: 'application/pdf',
            byteLength: 100,
          ),
          throwsA(isA<AttachmentValidationException>()),
        );
        final description = await begin(id);
        expect(
          await FileUploader(description).uploadByteData(ByteData(1)),
          isFalse,
        );
      },
    );

    test(
      'old upload authorization cannot overwrite finalized evidence',
      () async {
        final id = Uuid().v7obj();
        final description = await begin(id);
        expect(await FileUploader(description).uploadByteData(bytes), isTrue);
        await endpoints.media.completeUpload(
          signedIn(userId),
          incident.incident.id!,
          id,
        );
        // Whether the provider revokes its token or accepts another staging
        // upload, the only readable object is the immutable canonical copy.
        await FileUploader(
          description,
        ).uploadByteData(ByteData(bytes.lengthInBytes));
        final stored = await endpoints.media.read(signedIn(userId), id);
        expect(Uint8List.sublistView(stored), Uint8List.sublistView(bytes));
      },
    );

    test('server enforces the five-photo limit', () async {
      for (var index = 0; index < 5; index++) {
        await upload(Uuid().v7obj());
      }
      await expectLater(
        endpoints.media.beginUpload(
          signedIn(userId),
          incident.incident.id!,
          Uuid().v7obj(),
          contentType: 'image/png',
          byteLength: bytes.lengthInBytes,
        ),
        throwsA(isA<AttachmentValidationException>()),
      );
    });

    test(
      'organization peers may read a photo but cannot replay another uploader ID',
      () async {
        final id = Uuid().v7obj();
        await upload(id);
        final peer = Uuid().v4obj();
        await OrganizationMember.db.insertRow(
          sessionBuilder.build(),
          OrganizationMember(
            organizationId: organization.organization.id!,
            authUserId: peer,
            role: MemberRole.fieldWorker,
          ),
        );
        expect(
          (await endpoints.media.read(signedIn(peer), id)).lengthInBytes,
          bytes.lengthInBytes,
        );
        await expectLater(
          endpoints.media.beginUpload(
            signedIn(peer),
            incident.incident.id!,
            id,
            contentType: 'image/png',
            byteLength: bytes.lengthInBytes,
          ),
          throwsA(isA<AuthorizationException>()),
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
