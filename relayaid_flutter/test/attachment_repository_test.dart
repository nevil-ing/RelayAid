import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/incidents/data/incident_local_store.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_sync_state.dart';
import 'package:relayaid_flutter/features/media/domain/attachment_repository.dart';
import 'package:relayaid_flutter/features/media/domain/queued_attachment.dart';
import 'support/media_fixture.dart';

void main() {
  late MediaFixture fixture;
  late UuidValue id;
  setUp(() {
    fixture = MediaFixture();
    id = Uuid().v7obj();
  });
  tearDown(() => fixture.dispose());

  Future<void> photoAndReport() async {
    await fixture.attachments.capture(id, PhotoSource.library);
    await fixture.report(id);
  }

  test('offline photos are copied before the report is saved', () async {
    await fixture.attachments.capture(id, PhotoSource.library);
    expect(await fixture.attachments.queue(), isEmpty);
    await fixture.attachments.process();
    expect(fixture.incidentRemote.calls, 0);
    final photo = (await fixture.attachments.list(id)).single;
    expect(photo.state, AttachmentUploadState.draft);
    expect(await fixture.attachments.read(photo), testPhotoBytes);
    expect(await fixture.attachments.draftIncidentId(), id);
    await fixture.report(id);
    expect(await fixture.attachments.queue(), hasLength(1));
    await fixture.attachments.process();
    expect(fixture.remote.calls, 0);
  });

  test('metadata synchronizes before photo upload', () async {
    await photoAndReport();
    fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
    await fixture.attachments.process();
    expect(await fixture.incidents.syncStateFor(id), IncidentSyncState.synced);
    expect(fixture.incidentRemote.calls, 1);
    expect(fixture.remote.calls, 1);
    expect(
      (await fixture.attachments.list(id)).single.state,
      AttachmentUploadState.uploaded,
    );
    await fixture.attachments.process();
    expect(fixture.remote.calls, 1);
  });

  test(
    'upload failure leaves incident synchronized and photo retryable',
    () async {
      await photoAndReport();
      fixture.remote.failures = 1;
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await fixture.attachments.process();
      final failed = (await fixture.attachments.list(id)).single;
      expect(failed.state, AttachmentUploadState.failed);
      expect(failed.attempts, 1);
      expect(
        failed.nextAttemptAt,
        fixture.time.add(const Duration(seconds: 5)),
      );
      expect(
        await fixture.incidents.syncStateFor(id),
        IncidentSyncState.synced,
      );
      expect(await fixture.attachments.read(failed), testPhotoBytes);
      await fixture.attachments.process();
      expect(fixture.remote.calls, 1); // Backoff is persisted, not a fake sync.
      await fixture.attachments.process(forceRetry: true);
      expect(fixture.remote.calls, 2);
      expect(
        (await fixture.attachments.list(id)).single.state,
        AttachmentUploadState.uploaded,
      );
    },
  );

  test('elapsed backoff retries automatically on next queue wake', () async {
    await photoAndReport();
    fixture.remote.failures = 1;
    fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
    await fixture.attachments.process();
    fixture.time = fixture.time.add(const Duration(seconds: 6));
    await fixture.attachments.process();
    expect(
      (await fixture.attachments.list(id)).single.state,
      AttachmentUploadState.uploaded,
    );
  });

  test('failed metadata does not send a photo without its incident', () async {
    await photoAndReport();
    fixture.incidentRemote.failures = 1;
    fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
    await fixture.attachments.process();
    expect(fixture.remote.calls, 0);
    expect(await fixture.incidents.syncStateFor(id), IncidentSyncState.failed);
    expect(await fixture.attachments.queue(), hasLength(1));
  });

  test(
    'new reports arriving during sync join the same drain without being stranded',
    () async {
      await photoAndReport();
      final gate = Completer<void>();
      fixture.incidentRemote.gate = gate;
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      final sync = fixture.incidents.syncPending();
      await fixture.incidentRemote.firstStarted.future;
      final secondId = Uuid().v7obj();
      await fixture.report(secondId);
      gate.complete();
      await sync;
      expect(fixture.incidentRemote.calls, 2);
      expect(
        await fixture.incidents.syncStateFor(secondId),
        IncidentSyncState.synced,
      );
    },
  );

  test(
    'server validation failure stays visible without automatic retry churn',
    () async {
      await photoAndReport();
      fixture.remote.rejection = AttachmentValidationException(
        message: 'Choose a smaller photo.',
      );
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await fixture.attachments.process();
      final rejected = (await fixture.attachments.list(id)).single;
      expect(rejected.state, AttachmentUploadState.failed);
      expect(rejected.nextAttemptAt, isNull);
      expect(rejected.error, 'Choose a smaller photo.');
      await fixture.attachments.process();
      expect(fixture.remote.calls, 1);
    },
  );

  test(
    'interrupted incident and photo sync are recovered without duplicates',
    () async {
      await photoAndReport();
      final incident = (await fixture.incidentStore.get(id))!;
      await fixture.incidentStore.save(
        LocalIncidentRecord(
          detail: incident.detail,
          syncState: IncidentSyncState.syncing,
        ),
      );
      final photo = (await fixture.attachments.list(id)).single;
      await fixture.store.save(
        photo.withState(AttachmentUploadState.uploading),
      );
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await Future.wait([
        fixture.attachments.process(),
        fixture.attachments.process(),
        fixture.incidents.syncPending(),
      ]);
      expect(fixture.incidentRemote.calls, 1);
      expect(fixture.remote.calls, 1);
      expect(
        (await fixture.attachments.list(id)).single.state,
        AttachmentUploadState.uploaded,
      );
    },
  );

  test('another signed-in account cannot upload this device queue', () async {
    await photoAndReport();
    fixture.context = fixture.context!.copyWith(
      membership: fixture.context!.membership.copyWith(
        authUserId: Uuid().v4obj(),
      ),
    );
    fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
    expect(await fixture.attachments.queue(), isEmpty);
    await fixture.attachments.process();
    expect(fixture.incidentRemote.calls, 0);
    expect(fixture.remote.calls, 0);
  });

  test('invalid photo never writes a queue record', () async {
    fixture.picker.bytes = Uint8List.fromList([1, 2, 3]);
    await expectLater(
      fixture.attachments.capture(id, PhotoSource.library),
      throwsA(isA<PhotoFailure>()),
    );
    expect(await fixture.attachments.list(id), isEmpty);
  });

  test(
    'Android interrupted picker recovery restores the original draft',
    () async {
      final photoId = Uuid().v7obj();
      await fixture.store.setCaptureRequest(fixture.userId, {
        'id': photoId.toString(),
        'incidentId': id.toString(),
        'organizationId': fixture.organizationId.toString(),
      });
      fixture.picker.recovered = testPhotoBytes;
      await fixture.attachments.recoverPhoto();
      expect((await fixture.attachments.list(id)).single.id, photoId);
      expect(await fixture.attachments.draftIncidentId(), id);
      expect(await fixture.store.captureRequest(fixture.userId), isNull);
    },
  );
}
