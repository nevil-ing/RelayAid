import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:relayaid_client/relayaid_client.dart';
import '../domain/attachment_repository.dart';
import '../domain/queued_attachment.dart';

class AttachmentController extends ChangeNotifier {
  AttachmentController(this.repository, {this.incidentId, this.onUploaded}) {
    _subscription = repository.changes.listen((_) => unawaited(load()));
    unawaited(load(refresh: incidentId != null));
  }
  final AttachmentRepository repository;
  final UuidValue? incidentId;
  final VoidCallback? onUploaded;
  late final StreamSubscription<void> _subscription;
  List<QueuedAttachment> photos = const [];
  String? error;
  bool loading = true;
  bool retrying = false;
  bool _disposed = false;
  int _version = 0;

  Future<void> load({bool refresh = false}) async {
    final version = ++_version;
    try {
      final result = incidentId == null
          ? await repository.queue()
          : await repository.list(incidentId!, refresh: refresh);
      if (_disposed || version != _version) return;
      final newlyUploaded =
          !loading &&
          result.any(
            (photo) =>
                photo.state == AttachmentUploadState.uploaded &&
                !photos.any(
                  (old) =>
                      old.id == photo.id &&
                      old.state == AttachmentUploadState.uploaded,
                ),
          );
      photos = result;
      error = null;
      if (newlyUploaded) onUploaded?.call();
    } catch (_) {
      if (_disposed || version != _version) return;
      if (incidentId != null && refresh) {
        try {
          photos = await repository.list(incidentId!);
        } catch (_) {
          /* Keep existing photos. */
        }
      }
      error =
          'Photos could not be refreshed. Saved photos remain on this device.';
    }
    if (_disposed) return;
    loading = false;
    notifyListeners();
  }

  Future<void> retry() async {
    if (retrying) return;
    retrying = true;
    notifyListeners();
    try {
      await repository.process(forceRetry: true);
    } catch (_) {
      error = 'Uploads could not start. Try again when connected.';
    }
    if (_disposed) return;
    retrying = false;
    await load();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
