import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/storage/relayaid_local_database.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/incidents/data/incident_local_store.dart';
import 'package:relayaid_flutter/features/media/data/attachment_local_store.dart';
import 'package:relayaid_flutter/features/media/data/photo_file_store_native.dart';
import 'package:relayaid_flutter/features/media/domain/attachment_repository.dart';
import 'package:relayaid_flutter/features/media/domain/queued_attachment.dart';
import 'support/media_fixture.dart';

void main() {
  test(
    'disk photo and queue survive database close/reopen then upload',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'relayaid_media_restart_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final databasePath = path.join(directory.path, 'relayaid.sqlite');
      final photosPath = path.join(directory.path, 'photos');
      final firstDatabase = await RelayAidLocalDatabase.openAt(databasePath);
      final first = MediaFixture(
        incidentStore: SqliteIncidentLocalStore(firstDatabase),
        attachmentStore: SqliteAttachmentLocalStore(firstDatabase),
        files: NativePhotoFileStore(photosPath),
      );
      final id = Uuid().v7obj();
      await first.attachments.capture(id, PhotoSource.camera);
      await first.report(id);
      final originalPhoto = (await first.attachments.list(id)).single;
      await first.store.save(
        originalPhoto.withState(AttachmentUploadState.uploading),
      );
      await first.dispose();
      await firstDatabase.close();

      final reopened = await RelayAidLocalDatabase.openAt(databasePath);
      final second = MediaFixture(
        incidentStore: SqliteIncidentLocalStore(reopened),
        attachmentStore: SqliteAttachmentLocalStore(reopened),
        files: NativePhotoFileStore(photosPath),
      );
      addTearDown(() async {
        await second.dispose();
        await reopened.close();
      });
      expect(await second.attachments.queue(), hasLength(1));
      final recovered = (await second.attachments.list(id)).single;
      expect(recovered.id, originalPhoto.id);
      expect(await second.attachments.read(recovered), testPhotoBytes);
      second.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await second.attachments.process();
      expect(
        (await second.attachments.list(id)).single.state,
        AttachmentUploadState.uploaded,
      );
      expect(second.remote.calls, 1);
    },
  );
}
