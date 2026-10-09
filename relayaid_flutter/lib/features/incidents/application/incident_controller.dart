import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../core/connectivity/connectivity_provider.dart';
import '../../auth/application/access_controller.dart';
import '../../auth/application/client_provider.dart';
import '../data/incident_local_store.dart';
import '../data/local_first_incident_repository.dart';
import '../data/serverpod_incident_repository.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_sync_state.dart';

final incidentLocalStoreProvider = Provider<IncidentLocalStore>((ref) {
  throw StateError('IncidentLocalStore must be provided at startup.');
});

final localFirstIncidentRepositoryProvider =
    Provider<LocalFirstIncidentRepository>((ref) {
      final access = ref.watch(accessControllerProvider);
      final repository = LocalFirstIncidentRepository(
        remote: ServerpodIncidentRepository(ref.watch(serverpodClientProvider)),
        localStore: ref.watch(incidentLocalStoreProvider),
        connectivity: ref.read(connectivityControllerProvider),
        readOrganizationContext: () async => access.context,
      );
      ref.onDispose(() => unawaited(repository.dispose()));
      return repository;
    });

final incidentRepositoryProvider = Provider<IncidentRepository>(
  (ref) => ref.watch(localFirstIncidentRepositoryProvider),
);

final incidentSyncCoordinatorProvider = Provider<IncidentSyncCoordinator>((
  ref,
) {
  final coordinator = IncidentSyncCoordinator(
    connectivity: ref.read(connectivityControllerProvider),
    repository: ref.watch(localFirstIncidentRepositoryProvider),
  )..start();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final incidentControllerProvider = ChangeNotifierProvider<IncidentController>((
  ref,
) {
  ref.watch(incidentSyncCoordinatorProvider);
  return IncidentController(ref.watch(incidentRepositoryProvider));
});

enum IncidentViewStatus { idle, loading, ready, submitting, error }

class IncidentController extends ChangeNotifier {
  IncidentController(this.repository) {
    final syncRepository = _syncRepository;
    if (syncRepository != null) {
      _syncSubscription = syncRepository.changes.listen((_) {
        unawaited(_refreshSyncStates());
      });
    }
  }

  final IncidentRepository repository;
  final Map<UuidValue, IncidentSyncState> _syncStates = {};
  StreamSubscription<void>? _syncSubscription;
  IncidentViewStatus _status = IncidentViewStatus.idle;
  List<Incident> _incidents = const [];
  IncidentDetail? _selected;
  String? _error;
  bool _disposed = false;

  IncidentViewStatus get status => _status;
  List<Incident> get incidents => _incidents;
  IncidentDetail? get selected => _selected;
  String? get error => _error;
  int get pendingCount => _syncStates.values
      .where((state) => state != IncidentSyncState.synced)
      .length;

  IncidentSyncState syncStateFor(UuidValue? incidentId) => incidentId == null
      ? IncidentSyncState.synced
      : _syncStates[incidentId] ?? IncidentSyncState.synced;

  IncidentSyncRepository? get _syncRepository =>
      repository is IncidentSyncRepository
      ? repository as IncidentSyncRepository
      : null;

  Future<void> syncNow() async {
    await _syncRepository?.syncPending();
    await _refreshSyncStates();
  }

  Future<void> refreshSelected(UuidValue incidentId) async {
    if (_disposed || _selected?.incident.id != incidentId) return;
    try {
      final updated = await repository.detail(incidentId);
      if (_disposed || _selected?.incident.id != incidentId) return;
      _selected = updated;
      notifyListeners();
    } catch (_) {
      // Keep the saved report visible when a background refresh fails.
    }
  }

  Future<void> load() async {
    if (_status == IncidentViewStatus.loading) return;
    _setState(IncidentViewStatus.loading, clearError: true);
    try {
      _incidents = await repository.list();
      await _refreshSyncStates();
      _setState(IncidentViewStatus.ready);
    } catch (_) {
      _setState(
        IncidentViewStatus.error,
        error:
            'Incidents could not be loaded. Check your connection and try again.',
      );
    }
  }

  Future<void> loadDetail(UuidValue incidentId) async {
    _selected = null;
    _setState(IncidentViewStatus.loading, clearError: true);
    try {
      _selected = await repository.detail(incidentId);
      await _refreshSyncStates();
      _setState(IncidentViewStatus.ready);
    } catch (_) {
      _setState(
        IncidentViewStatus.error,
        error: 'Incident details could not be loaded.',
      );
    }
  }

  Future<IncidentDetail?> create({
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) async {
    _setState(IncidentViewStatus.submitting, clearError: true);
    try {
      final created = await repository.create(
        id: id,
        type: type,
        severity: severity,
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        peopleAffected: peopleAffected,
      );
      _selected = created;
      _incidents = [
        created.incident,
        ..._incidents.where((item) => item.id != created.incident.id),
      ];
      await _refreshSyncStates();
      _setState(IncidentViewStatus.ready);
      return created;
    } catch (_) {
      _setState(
        IncidentViewStatus.error,
        error:
            'Incident could not be submitted. Check the form and connection.',
      );
      return null;
    }
  }

  Future<IncidentDetail?> transition(
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) async {
    _setState(IncidentViewStatus.submitting, clearError: true);
    try {
      final updated = await repository.transition(
        incidentId,
        nextStatus,
        note: note,
      );
      _selected = updated;
      _incidents = [
        for (final incident in _incidents)
          if (incident.id == updated.incident.id)
            updated.incident
          else
            incident,
      ];
      await _refreshSyncStates();
      _setState(IncidentViewStatus.ready);
      return updated;
    } catch (_) {
      _setState(
        IncidentViewStatus.error,
        error: 'Status could not be updated. Try again.',
      );
      return null;
    }
  }

  Future<void> _refreshSyncStates() async {
    final syncRepository = _syncRepository;
    if (syncRepository == null) return;
    final ids = <UuidValue>{
      for (final incident in _incidents)
        if (incident.id != null) incident.id!,
      if (_selected?.incident.id case final UuidValue id) id,
    };
    final entries = await Future.wait(
      ids.map(
        (id) async => MapEntry(id, await syncRepository.syncStateFor(id)),
      ),
    );
    if (_disposed) return;
    final selectedId = _selected?.incident.id;
    final wasSynced = _syncStates[selectedId] == IncidentSyncState.synced;
    _syncStates
      ..clear()
      ..addEntries(entries);
    notifyListeners();
    if (selectedId != null &&
        !wasSynced &&
        _syncStates[selectedId] == IncidentSyncState.synced) {
      unawaited(refreshSelected(selectedId));
    }
  }

  void _setState(
    IncidentViewStatus status, {
    String? error,
    bool clearError = false,
  }) {
    if (_disposed) return;
    _status = status;
    if (clearError) _error = null;
    if (error != null) _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_syncSubscription?.cancel());
    super.dispose();
  }
}
