import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../core/connectivity/connectivity_controller.dart';
import '../../../core/network/live_feed_status.dart';
import '../../auth/application/access_controller.dart';
import '../domain/assignment_repository.dart';

/// Owns foreground delivery, account boundaries, reconnects and response actions.
/// Offline response actions are not queued; an authoritative connection is required.
class AssignmentController extends ChangeNotifier {
  AssignmentController({
    required this.repository,
    required this.access,
    required this.connectivity,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 30),
    ],
  }) : assert(retryDelays.isNotEmpty);

  final AssignmentRepository repository;
  final AccessController access;
  final ConnectivityController connectivity;
  final List<Duration> retryDelays;
  StreamSubscription<AssignmentFeed>? _subscription;
  Timer? _retry;
  String? _scope;
  int _generation = 0;
  int _detailVersion = 0;
  int _attempt = 0;
  bool _started = false;
  bool _disposed = false;
  AssignmentFeed? _feed;
  LiveFeedStatus _status = LiveFeedStatus.connecting;
  UuidValue? _selectedId;
  IncidentDetail? _selected;
  bool _loading = false;
  bool _busy = false;
  String? _error;

  AssignmentFeed? get feed => _feed;
  List<AssignmentSummary> get assignments => _feed?.assignments ?? const [];
  LiveFeedStatus get status => _status;
  UuidValue? get selectedId => _selectedId;
  IncidentDetail? get selected => _selected;
  bool get loading => _loading;
  bool get busy => _busy;
  String? get error => _error;
  bool get canAct {
    final assignment = _selected?.assignment;
    return _status == LiveFeedStatus.live &&
        connectivity.isOnline &&
        !_busy &&
        assignment != null &&
        (assignment.acceptedBy == null ||
            assignment.acceptedBy == access.userId) &&
        assignment.status != AssignmentStatus.resolved &&
        assignment.status != AssignmentStatus.cancelled;
  }

  void start() {
    if (_started || _disposed) return;
    _started = true;
    access.addListener(_environmentChanged);
    connectivity.addListener(_environmentChanged);
    _environmentChanged();
  }

  void _environmentChanged() {
    if (_disposed) return;
    final context = access.context;
    final scope =
        access.status == AccessStatus.ready &&
            context?.membership.role == MemberRole.responder
        ? '${access.userId}:${context!.organization.id}'
        : null;
    if (scope != _scope) {
      _stop();
      _clear();
      _scope = scope;
      _attempt = 0;
    }
    if (scope == null) {
      _status = LiveFeedStatus.accessDenied;
    } else if (!connectivity.isOnline) {
      _stop();
      _status = LiveFeedStatus.offline;
    } else if (_subscription == null && !(_retry?.isActive ?? false)) {
      _open();
      return;
    }
    _notify();
  }

  void reconnect() {
    if (!_disposed && _scope != null && connectivity.isOnline) {
      _attempt = 0;
      _open();
    }
  }

  void _open() {
    _stop();
    final generation = _generation;
    _status = _feed == null
        ? LiveFeedStatus.connecting
        : LiveFeedStatus.reconnecting;
    _notify();
    try {
      _subscription = repository.watch().listen(
        (feed) {
          if (_disposed || generation != _generation) return;
          if (feed.organizationId != access.context?.organization.id ||
              feed.authUserId != access.userId) {
            _failed(
              AuthorizationException(message: 'Access changed.'),
              generation,
            );
            return;
          }
          _feed = feed;
          _status = LiveFeedStatus.live;
          _attempt = 0;
          if (_selectedId != null) {
            if (!assignments.any((item) => item.assignment.id == _selectedId)) {
              select(null);
            } else {
              unawaited(_loadSelected());
            }
          }
          _notify();
        },
        onError: (Object error, StackTrace stack) => _failed(error, generation),
        onDone: () => _failed(StateError('Stream closed.'), generation),
        cancelOnError: true,
      );
    } catch (error) {
      _failed(error, generation);
    }
  }

  bool _isAccessError(Object error) =>
      error is AuthorizationException ||
      error is ServerpodClientUnauthorized ||
      error is ServerpodClientForbidden;

  void _failed(Object error, int generation) {
    if (_disposed || generation != _generation) return;
    _stop();
    if (_isAccessError(error)) {
      _clear();
      _status = LiveFeedStatus.accessDenied;
    } else if (!connectivity.isOnline) {
      _status = LiveFeedStatus.offline;
    } else {
      _status = LiveFeedStatus.reconnecting;
      final delay = retryDelays[_attempt.clamp(0, retryDelays.length - 1)];
      _attempt++;
      _retry = Timer(delay, () {
        if (!_disposed && _scope != null && connectivity.isOnline) _open();
      });
    }
    _notify();
  }

  void select(UuidValue? id) {
    _detailVersion++;
    _selectedId = id;
    _selected = null;
    _error = null;
    _loading = false;
    if (id != null) unawaited(_loadSelected());
    _notify();
  }

  Future<void> _loadSelected() async {
    final id = _selectedId;
    if (id == null) return;
    final version = ++_detailVersion;
    final generation = _generation;
    if (!connectivity.isOnline) {
      _error = _selected == null
          ? 'Reconnect to load assignment details.'
          : null;
      _loading = false;
      _notify();
      return;
    }
    _loading = _selected == null;
    _notify();
    try {
      final detail = await repository.detail(id);
      if (!_current(generation) || version != _detailVersion) return;
      if (detail.incident.organizationId != access.context?.organization.id ||
          detail.assignment?.id != id) {
        _failed(AuthorizationException(message: 'Access changed.'), generation);
        return;
      }
      _selected = detail;
      _error = null;
    } catch (error) {
      if (!_current(generation) || version != _detailVersion) return;
      if (_isAccessError(error)) {
        _failed(error, generation);
      } else {
        _error = 'Assignment details could not be refreshed.';
      }
    } finally {
      if (_current(generation) && version == _detailVersion) {
        _loading = false;
        _notify();
      }
    }
  }

  Future<void> accept() => _perform(repository.accept);
  Future<void> respond() => _perform(repository.respond);
  Future<void> resolve(String note) async {
    if (!canAct) return;
    if (note.trim().length < 3 || note.trim().length > 500) {
      _error = 'Add a resolution note of 3–500 characters.';
      _notify();
      return;
    }
    await _perform((id) => repository.resolve(id, note.trim()));
  }

  Future<void> _perform(
    Future<IncidentDetail> Function(UuidValue) action,
  ) async {
    final id = _selectedId;
    if (id == null || !canAct) return;
    final generation = _generation;
    _busy = true;
    _error = null;
    _notify();
    try {
      final detail = await action(id);
      if (_current(generation) && _selectedId == id) {
        _detailVersion++;
        _selected = detail;
        unawaited(_loadSelected());
      }
    } catch (error) {
      if (_current(generation) && _selectedId == id) {
        if (_isAccessError(error)) {
          _failed(error, generation);
        } else {
          _error = error is IncidentValidationException
              ? error.message
              : 'The update did not complete. Reconnect and retry.';
        }
      }
    } finally {
      if (_current(generation)) {
        _busy = false;
        _notify();
      }
    }
  }

  bool _current(int generation) => !_disposed && generation == _generation;
  void _clear() {
    _feed = null;
    _selectedId = null;
    _selected = null;
    _error = null;
    _loading = false;
    _busy = false;
    _detailVersion++;
  }

  void _stop() {
    _generation++;
    _detailVersion++;
    _retry?.cancel();
    _retry = null;
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) unawaited(subscription.cancel());
    _busy = false;
    _loading = false;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    access.removeListener(_environmentChanged);
    connectivity.removeListener(_environmentChanged);
    _stop();
    super.dispose();
  }
}
