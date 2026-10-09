import 'dart:async';
import '../../../core/connectivity/connectivity_controller.dart';
import '../../auth/application/access_controller.dart';
import '../../incidents/domain/incident_repository.dart';
import '../domain/attachment_repository.dart';
import '../domain/queued_attachment.dart';

/// Wakes on connectivity, identity, local changes, and persisted retry dates.
/// This is an upload queue scheduler, not a dashboard polling mechanism.
class UploadCoordinator {
  UploadCoordinator({
    required this.repository,
    required this.incidents,
    required this.connectivity,
    required this.access,
  });
  final AttachmentRepository repository;
  final IncidentSyncRepository incidents;
  final ConnectivityController connectivity;
  final AccessController access;
  StreamSubscription<void>? _photos;
  StreamSubscription<void>? _incidents;
  Timer? _retry;
  bool _running = false;
  bool _disposed = false;
  int _waitingSeconds = 5;

  void start() {
    connectivity.addListener(_kick);
    access.addListener(_kick);
    _photos = repository.changes.listen((_) => _kick());
    _incidents = incidents.changes.listen((_) => _kick());
    unawaited(_recover());
  }

  Future<void> _recover() async {
    try {
      await repository.recoverPhoto();
    } catch (_) {
      // A failed recovery never prevents existing reports from synchronizing.
    }
    _kick();
  }

  void _kick() {
    _retry?.cancel();
    if (_disposed ||
        _running ||
        !connectivity.isOnline ||
        access.context == null) {
      return;
    }
    _running = true;
    unawaited(_run());
  }

  Future<void> _run() async {
    try {
      await repository.recoverPhoto();
      await repository.process();
      final queue = await repository.queue();
      final dates =
          queue.map((p) => p.nextAttemptAt).whereType<DateTime>().toList()
            ..sort();
      // Evidence can arrive while the previous metadata batch is in flight.
      final waiting = queue.any(
        (p) => {
          AttachmentUploadState.draft,
          AttachmentUploadState.pending,
          AttachmentUploadState.uploading,
        }.contains(p.state),
      );
      if (waiting) {
        dates.add(
          DateTime.now().toUtc().add(Duration(seconds: _waitingSeconds)),
        );
        _waitingSeconds = (_waitingSeconds * 2).clamp(5, 300);
        dates.sort();
      } else {
        _waitingSeconds = 5;
      }
      if (!_disposed && connectivity.isOnline && dates.isNotEmpty) {
        final delay = dates.first.difference(DateTime.now().toUtc());
        _retry = Timer(
          delay.isNegative ? const Duration(seconds: 5) : delay,
          _kick,
        );
      }
    } catch (_) {
      // Storage/auth failures are exposed by the controllers; avoid unhandled
      // asynchronous exceptions from a background connectivity callback.
    } finally {
      _running = false;
    }
  }

  void dispose() {
    _disposed = true;
    _retry?.cancel();
    unawaited(_photos?.cancel());
    unawaited(_incidents?.cancel());
    connectivity.removeListener(_kick);
    access.removeListener(_kick);
  }
}
