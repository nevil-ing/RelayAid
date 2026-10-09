import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:relayaid_client/relayaid_client.dart';
import '../../../core/connectivity/connectivity_provider.dart';
import '../../auth/application/access_controller.dart';
import '../../auth/application/client_provider.dart';
import '../../incidents/application/incident_controller.dart';
import '../data/attachment_local_store.dart';
import '../data/device_photo_picker.dart';
import '../data/local_attachment_repository.dart';
import '../data/serverpod_attachment_remote.dart';
import '../domain/attachment_repository.dart';
import '../domain/queued_attachment.dart';
import 'attachment_controller.dart';
import 'photo_draft_controller.dart';
import 'upload_coordinator.dart';

final attachmentLocalStoreProvider = Provider<AttachmentLocalStore>(
  (ref) =>
      throw StateError('AttachmentLocalStore must be supplied at startup.'),
);
final photoFileStoreProvider = Provider<PhotoFileStore>(
  (ref) => throw StateError('PhotoFileStore must be supplied at startup.'),
);
final photoPickerProvider = Provider<PhotoPicker>((ref) => DevicePhotoPicker());

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  final access = ref.read(accessControllerProvider);
  final repository = LocalAttachmentRepository(
    store: ref.watch(attachmentLocalStoreProvider),
    files: ref.watch(photoFileStoreProvider),
    picker: ref.watch(photoPickerProvider),
    remote: ServerpodAttachmentRemote(ref.watch(serverpodClientProvider)),
    incidents: ref.watch(incidentLocalStoreProvider),
    incidentSync: ref.watch(localFirstIncidentRepositoryProvider),
    connectivity: ref.read(connectivityControllerProvider),
    readContext: () => access.context,
  );
  ref.onDispose(() => unawaited(repository.dispose()));
  return repository;
});

final uploadCoordinatorProvider = Provider<UploadCoordinator>((ref) {
  final coordinator = UploadCoordinator(
    repository: ref.watch(attachmentRepositoryProvider),
    incidents: ref.watch(localFirstIncidentRepositoryProvider),
    connectivity: ref.read(connectivityControllerProvider),
    access: ref.read(accessControllerProvider),
  )..start();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final photoDraftControllerProvider =
    ChangeNotifierProvider.autoDispose<PhotoDraftController>(
      (ref) => PhotoDraftController(ref.watch(attachmentRepositoryProvider)),
    );
final incidentPhotosProvider = ChangeNotifierProvider.autoDispose
    .family<AttachmentController, UuidValue>(
      (ref, id) => AttachmentController(
        ref.watch(attachmentRepositoryProvider),
        incidentId: id,
        onUploaded: () =>
            unawaited(ref.read(incidentControllerProvider).refreshSelected(id)),
      ),
    );
final uploadQueueProvider =
    ChangeNotifierProvider.autoDispose<AttachmentController>(
      (ref) => AttachmentController(ref.watch(attachmentRepositoryProvider)),
    );
final photoBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, QueuedAttachment>(
      (ref, photo) => ref.watch(attachmentRepositoryProvider).read(photo),
    );
