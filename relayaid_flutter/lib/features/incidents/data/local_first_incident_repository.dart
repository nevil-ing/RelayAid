import 'dart:async';

import 'package:relayaid_client/relayaid_client.dart';

import '../../../core/connectivity/connectivity_controller.dart';
import 'incident_local_store.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_sync_state.dart';

typedef OrganizationContextReader = Future<OrganizationContext?> Function();

/// Persists reports on the device first, then replays them to Serverpod.
class LocalFirstIncidentRepository
    implements IncidentRepository, IncidentSyncRepository {
  LocalFirstIncidentRepository({
    required this.remote,
    required this.localStore,
    required this.connectivity,
    required this.readOrganizationContext,
  });

  final IncidentRepository remote;
  final IncidentLocalStore localStore;
  final ConnectivityController connectivity;
  final OrganizationContextReader readOrganizationContext;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  Future<void>? _syncInProgress;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<Incident>> list({int limit = 50}) async {
    final organizationId = await _organizationId();
    final localBeforeRefresh = await localStore.list(
      organizationId,
      limit: limit,
    );
    if (connectivity.isOnline) {
      try {
        final remoteIncidents = await remote.list(limit: limit);
        for (final incident in remoteIncidents) {
          final incidentId = incident.id;
          if (incidentId == null) continue;
          final cached = await localStore.get(incidentId);
          if (cached != null && cached.syncState != IncidentSyncState.synced) {
            continue;
          }
          await localStore.save(
            LocalIncidentRecord(
              detail: IncidentDetail(
                incident: incident,
                timeline: cached?.detail.timeline ?? const [],
              ),
              syncState: IncidentSyncState.synced,
            ),
          );
        }
      } catch (_) {
        if (localBeforeRefresh.isEmpty) rethrow;
      }
    }
    return (await localStore.list(
      organizationId,
      limit: limit,
    )).map((record) => record.detail.incident).toList(growable: false);
  }

  @override
  Future<IncidentDetail> create({
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) async {
    final context = await readOrganizationContext();
    final organizationId = context?.organization.id;
    final actorId = context?.membership.authUserId;
    if (organizationId == null || actorId == null) {
      throw StateError('A signed-in organization is required.');
    }

    final incidentId = id ?? Uuid().v7obj();
    final now = DateTime.now().toUtc();
    final incident = Incident(
      id: incidentId,
      organizationId: organizationId,
      type: type,
      severity: severity,
      status: IncidentStatus.reported,
      title: title.trim(),
      description: description.trim(),
      latitude: latitude,
      longitude: longitude,
      peopleAffected: peopleAffected,
      reportedBy: actorId,
      reportedAt: now,
      updatedAt: now,
    );
    final detail = IncidentDetail(
      incident: incident,
      timeline: [
        IncidentEvent(
          incidentId: incidentId,
          organizationId: organizationId,
          eventType: IncidentEventType.created,
          actorId: actorId,
          toStatus: IncidentStatus.reported,
          note: 'Saved on this device',
          createdAt: now,
        ),
      ],
    );
    await localStore.save(
      LocalIncidentRecord(
        detail: detail,
        syncState: connectivity.isOnline
            ? IncidentSyncState.pending
            : IncidentSyncState.offline,
      ),
    );
    _emitChange();
    if (connectivity.isOnline) unawaited(syncPending());
    return detail;
  }

  @override
  Future<IncidentDetail> detail(UuidValue incidentId) async {
    final context = await readOrganizationContext();
    final organizationId = context?.organization.id;
    final cached = await localStore.get(incidentId);
    final local = cached != null && cached.organizationId == organizationId
        ? cached
        : null;
    if (!connectivity.isOnline) {
      if (local != null) return local.detail;
      return remote.detail(incidentId);
    }
    try {
      final result = await remote.detail(incidentId);
      await localStore.save(
        LocalIncidentRecord(
          detail: result,
          syncState: IncidentSyncState.synced,
        ),
      );
      _emitChange();
      return result;
    } catch (_) {
      if (local != null) return local.detail;
      rethrow;
    }
  }

  @override
  Future<IncidentDetail> transition(
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) async {
    final cached = await localStore.get(incidentId);
    if (!connectivity.isOnline ||
        (cached != null && cached.syncState != IncidentSyncState.synced)) {
      throw StateError('Status updates need a connection.');
    }
    final result = await remote.transition(incidentId, nextStatus, note: note);
    await localStore.save(
      LocalIncidentRecord(detail: result, syncState: IncidentSyncState.synced),
    );
    _emitChange();
    return result;
  }

  @override
  Future<IncidentSyncState> syncStateFor(UuidValue incidentId) async =>
      (await localStore.get(incidentId))?.syncState ?? IncidentSyncState.synced;

  @override
  Future<void> syncPending() {
    if (_syncInProgress case final Future<void> active) return active;
    if (!connectivity.isOnline) return Future.value();
    final operation = _syncPending();
    _syncInProgress = operation;
    return operation.whenComplete(() => _syncInProgress = null);
  }

  Future<void> _syncPending() async {
    final context = await readOrganizationContext();
    final organizationId = context?.organization.id;
    if (organizationId == null) return;
    var pending = await localStore.pending(organizationId);
    if (pending.isEmpty) return;
    final attempted = <UuidValue>{};

    connectivity.setSyncing(true);
    try {
      while (pending.isNotEmpty) {
        for (final record in pending) {
          attempted.add(record.incidentId);
          final current = await readOrganizationContext();
          if (!connectivity.isOnline ||
              current?.membership.authUserId !=
                  context!.membership.authUserId) {
            return;
          }
          if (record.detail.incident.reportedBy !=
              context.membership.authUserId) {
            continue;
          }
          await localStore.save(
            LocalIncidentRecord(
              detail: record.detail,
              syncState: IncidentSyncState.syncing,
            ),
          );
          _emitChange();
          try {
            final incident = record.detail.incident;
            final synced = await remote.create(
              id: incident.id,
              type: incident.type,
              severity: incident.severity,
              title: incident.title,
              description: incident.description,
              latitude: incident.latitude,
              longitude: incident.longitude,
              peopleAffected: incident.peopleAffected,
            );
            await localStore.save(
              LocalIncidentRecord(
                detail: synced,
                syncState: IncidentSyncState.synced,
              ),
            );
          } catch (_) {
            await localStore.save(
              LocalIncidentRecord(
                detail: record.detail,
                syncState: IncidentSyncState.failed,
                syncError: 'Could not sync yet. Try again when connected.',
              ),
            );
          }
          _emitChange();
        }
        pending = (await localStore.pending(
          organizationId,
        )).where((record) => !attempted.contains(record.incidentId)).toList();
      }
    } finally {
      connectivity.setSyncing(false);
    }
  }

  Future<UuidValue> _organizationId() async {
    final id = (await readOrganizationContext())?.organization.id;
    if (id == null) throw StateError('A signed-in organization is required.');
    return id;
  }

  void _emitChange() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}

/// Starts queued incident synchronization when the device reconnects.
class IncidentSyncCoordinator {
  IncidentSyncCoordinator({
    required this.connectivity,
    required this.repository,
  });

  final ConnectivityController connectivity;
  final IncidentSyncRepository repository;
  bool _wasOnline = false;

  void start() {
    connectivity.addListener(_onConnectivityChanged);
    _onConnectivityChanged();
  }

  void _onConnectivityChanged() {
    final online = connectivity.isOnline;
    if (!online) {
      _wasOnline = false;
      return;
    }
    if (_wasOnline) return;
    _wasOnline = true;
    unawaited(
      repository.syncPending().catchError((Object _) {
        // Local storage/auth failures must not escape a background listener.
      }),
    );
  }

  void dispose() {
    connectivity.removeListener(_onConnectivityChanged);
  }
}
