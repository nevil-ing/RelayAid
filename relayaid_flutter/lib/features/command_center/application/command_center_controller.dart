import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../core/connectivity/connectivity_controller.dart';
import '../../../core/network/live_feed_status.dart';
import '../../auth/application/access_controller.dart';
import '../domain/command_center_repository.dart';
import '../domain/incident_filter.dart';

export '../../../core/network/live_feed_status.dart';

/// Owns stream lifetime, account isolation, reconnects, filtering and selection.
/// Retry timers reopen the WebSocket; they never poll for incident data.
class CommandCenterController extends ChangeNotifier {
  CommandCenterController({
    required this.repository,
    required this.access,
    required this.connectivity,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 16),
      Duration(seconds: 30),
    ],
  }) : assert(retryDelays.isNotEmpty);

  final CommandCenterRepository repository;
  final AccessController access;
  final ConnectivityController connectivity;
  final List<Duration> retryDelays;
  StreamSubscription<IncidentFeed>? _subscription;
  Timer? _retry;
  String? _scope;
  int _generation = 0;
  int _detailVersion = 0;
  int _attempt = 0;
  bool _started = false;
  bool _disposed = false;
  IncidentFeed? _feed;
  IncidentFilter _filter = const IncidentFilter();
  LiveFeedStatus _status = LiveFeedStatus.connecting;
  UuidValue? _selectedId;
  IncidentDetail? _selected;
  bool _loadingDetail = false;
  bool _updating = false;
  String? _detailError;

  IncidentFeed? get feed => _feed;
  IncidentFilter get filter => _filter;
  LiveFeedStatus get status => _status;
  UuidValue? get selectedId => _selectedId;
  IncidentDetail? get selected => _selected;
  bool get loadingDetail => _loadingDetail;
  bool get updating => _updating;
  String? get detailError => _detailError;
  List<Incident> get visibleIncidents =>
      _feed?.incidents.where(_filter.matches).toList(growable: false) ??
      const [];
  List<IncidentActivity> get activity => _feed?.activity ?? const [];
  List<TeamRoster> get teams => _feed?.teams ?? const [];

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
    final canRead = access.status == AccessStatus.ready && access.isCoordinator;
    final scope = canRead && context != null
        ? '${access.userId}:${context.organization.id}:${context.membership.role}'
        : null;
    if (scope != _scope) {
      _stop();
      _clearData();
      _filter = const IncidentFilter();
      _scope = scope;
      _attempt = 0;
    }
    if (scope == null) {
      _status = LiveFeedStatus.accessDenied;
      _notify();
      return;
    }
    if (!connectivity.isOnline) {
      _stop();
      _status = LiveFeedStatus.offline;
      _notify();
      return;
    }
    if (_subscription == null && !(_retry?.isActive ?? false)) _open();
  }

  void reconnect() {
    if (_disposed || _scope == null || !connectivity.isOnline) return;
    _attempt = 0;
    _open();
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
          if (feed.organizationId != access.context?.organization.id) {
            _failed(
              AuthorizationException(message: 'Access changed.'),
              generation,
            );
            return;
          }
          _feed = feed;
          _status = LiveFeedStatus.live;
          _attempt = 0;
          if (_selectedId != null) unawaited(_loadSelected());
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

  void _failed(Object error, int generation) {
    if (_disposed || generation != _generation) return;
    _stop();
    if (_isAccessError(error)) {
      _clearData();
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

  bool _isAccessError(Object error) =>
      error is AuthorizationException ||
      error is ServerpodClientUnauthorized ||
      error is ServerpodClientForbidden;

  void search(String query) {
    _filter = IncidentFilter(
      query: query,
      severity: _filter.severity,
      status: _filter.status,
    );
    _notify();
  }

  void filterSeverity(IncidentSeverity? severity) {
    _filter = IncidentFilter(
      query: _filter.query,
      severity: severity,
      status: _filter.status,
    );
    _notify();
  }

  void filterStatus(IncidentStatus? status) {
    _filter = IncidentFilter(
      query: _filter.query,
      severity: _filter.severity,
      status: status,
    );
    _notify();
  }

  void select(UuidValue? incidentId) {
    _selectedId = incidentId;
    _selected = null;
    _detailError = null;
    _detailVersion++;
    if (incidentId != null) {
      unawaited(_loadSelected());
    } else {
      _loadingDetail = false;
      _notify();
    }
  }

  Future<void> _loadSelected() async {
    final id = _selectedId;
    if (id == null) return;
    final version = ++_detailVersion;
    final generation = _generation;
    if (!connectivity.isOnline) {
      _detailError = _selected == null
          ? 'Reconnect to load incident details.'
          : null;
      _loadingDetail = false;
      _notify();
      return;
    }
    _loadingDetail = _selected == null;
    _notify();
    try {
      final detail = await repository.detail(id);
      if (_disposed || version != _detailVersion || generation != _generation) {
        return;
      }
      if (detail.incident.organizationId != access.context?.organization.id) {
        _failed(AuthorizationException(message: 'Access changed.'), generation);
        return;
      }
      _selected = detail;
      _detailError = null;
    } catch (error) {
      if (_disposed || version != _detailVersion || generation != _generation) {
        return;
      }
      if (_isAccessError(error)) {
        _failed(error, generation);
        return;
      }
      _detailError = 'Incident details could not be refreshed.';
    } finally {
      if (!_disposed &&
          version == _detailVersion &&
          generation == _generation) {
        _loadingDetail = false;
        _notify();
      }
    }
  }

  Future<void> acknowledge() async {
    await _changeSelected(repository.acknowledge);
  }

  Future<void> assign(UuidValue teamId, {UuidValue? responderId}) =>
      _changeSelected(
        (id) => repository.assign(id, teamId, responderId: responderId),
      );

  Future<void> cancelAssignment() => _changeSelected(repository.cancel);

  Future<void> _changeSelected(
    Future<IncidentDetail> Function(UuidValue) change,
  ) async {
    final id = _selectedId;
    if (id == null || _updating || _status != LiveFeedStatus.live) return;
    final generation = _generation;
    _updating = true;
    _detailError = null;
    _notify();
    try {
      final detail = await change(id);
      if (!_disposed && generation == _generation && _selectedId == id) {
        _detailVersion++;
        _selected = detail;
        unawaited(_loadSelected());
      }
    } catch (error) {
      if (!_disposed && generation == _generation && _selectedId == id) {
        if (_isAccessError(error)) {
          _failed(error, generation);
        } else {
          _detailError = error is IncidentValidationException
              ? error.message
              : 'The incident could not be updated. Try again.';
        }
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _updating = false;
        _notify();
      }
    }
  }

  void _clearData() {
    _feed = null;
    _selectedId = null;
    _selected = null;
    _loadingDetail = false;
    _updating = false;
    _detailError = null;
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
    _loadingDetail = false;
    _updating = false;
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
