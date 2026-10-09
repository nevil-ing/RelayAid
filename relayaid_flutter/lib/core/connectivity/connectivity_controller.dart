import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'connectivity_status.dart';

/// The small connectivity surface needed by the sync layer.
///
/// Keeping the platform plugin behind this interface makes sync behaviour
/// deterministic in tests and prevents widgets from depending on a plugin.
abstract interface class ConnectivitySource {
  Future<List<ConnectivityResult>> check();

  Stream<List<ConnectivityResult>> get changes;
}

class PlatformConnectivitySource implements ConnectivitySource {
  PlatformConnectivitySource([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<List<ConnectivityResult>> check() => _connectivity.checkConnectivity();

  @override
  Stream<List<ConnectivityResult>> get changes =>
      _connectivity.onConnectivityChanged;
}

class ConnectivityController extends ChangeNotifier {
  ConnectivityController({ConnectivitySource? source})
    : _source = source ?? PlatformConnectivitySource();

  final ConnectivitySource _source;
  ConnectivityStatus _baseStatus = ConnectivityStatus.unavailable;
  bool _syncing = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;

  ConnectivityStatus get status =>
      _syncing ? ConnectivityStatus.syncing : _baseStatus;

  bool get isOnline => _baseStatus == ConnectivityStatus.connected;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _subscription = _source.changes.listen(_applyResults);
    try {
      _applyResults(await _source.check());
    } catch (_) {
      _setBaseStatus(ConnectivityStatus.unavailable);
    }
  }

  void setSyncing(bool syncing) {
    if (_syncing == syncing) return;
    _syncing = syncing;
    notifyListeners();
  }

  void setStatusForTest(ConnectivityStatus next) {
    _syncing = next == ConnectivityStatus.syncing;
    _setBaseStatus(_syncing ? ConnectivityStatus.connected : next);
  }

  void _applyResults(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    _setBaseStatus(
      hasConnection ? ConnectivityStatus.connected : ConnectivityStatus.offline,
    );
  }

  void _setBaseStatus(ConnectivityStatus next) {
    if (_baseStatus == next) return;
    _baseStatus = next;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
