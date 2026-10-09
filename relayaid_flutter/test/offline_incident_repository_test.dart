import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_controller.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/incidents/data/incident_local_store.dart';
import 'package:relayaid_flutter/features/incidents/data/local_first_incident_repository.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_repository.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_sync_state.dart';

void main() {
  late OrganizationContext context;
  late MemoryIncidentLocalStore store;
  late ConnectivityController connectivity;

  setUp(() {
    final organizationId = UuidValue.fromString(
      '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f101',
    );
    final userId = UuidValue.fromString('0199f2e9-9a4a-7e00-9a1f-4a6be0a1f102');
    context = OrganizationContext(
      organization: Organization(
        id: organizationId,
        name: 'RelayAid Response',
        createdBy: userId,
      ),
      membership: OrganizationMember(
        id: UuidValue.fromString('0199f2e9-9a4a-7e00-9a1f-4a6be0a1f103'),
        organizationId: organizationId,
        authUserId: userId,
        role: MemberRole.fieldWorker,
      ),
    );
    store = MemoryIncidentLocalStore();
    connectivity = ConnectivityController();
    connectivity.setStatusForTest(ConnectivityStatus.offline);
    addTearDown(connectivity.dispose);
  });

  LocalFirstIncidentRepository repositoryFor(_FakeRemoteRepository remote) =>
      LocalFirstIncidentRepository(
        remote: remote,
        localStore: store,
        connectivity: connectivity,
        readOrganizationContext: () async => context,
      );

  test('offline report remains available after a repository restart', () async {
    final remote = _FakeRemoteRepository();
    final firstRepository = repositoryFor(remote);
    final created = await firstRepository.create(
      type: IncidentType.flooding,
      severity: IncidentSeverity.high,
      title: 'Flooded bridge',
      description: 'Water has blocked the only crossing.',
      latitude: -0.3031,
      longitude: 36.0800,
      peopleAffected: 12,
    );
    await firstRepository.dispose();

    final reopenedRepository = repositoryFor(remote);
    final incidents = await reopenedRepository.list();
    final reopened = await reopenedRepository.detail(created.incident.id!);

    expect(incidents.single.id, created.incident.id);
    expect(reopened.incident.title, 'Flooded bridge');
    expect(
      await reopenedRepository.syncStateFor(created.incident.id!),
      IncidentSyncState.offline,
    );
    await reopenedRepository.dispose();
  });

  test(
    'reconnection syncs the original UUID and marks the report synced',
    () async {
      final remote = _FakeRemoteRepository();
      final repository = repositoryFor(remote);
      final created = await repository.create(
        type: IncidentType.medical,
        severity: IncidentSeverity.moderate,
        title: 'Medical request',
        description: 'A responder is needed at the community hall.',
        latitude: null,
        longitude: null,
        peopleAffected: 1,
      );

      connectivity.setStatusForTest(ConnectivityStatus.connected);
      await repository.syncPending();

      expect(remote.createdIds, [created.incident.id]);
      expect(
        await repository.syncStateFor(created.incident.id!),
        IncidentSyncState.synced,
      );
      await repository.dispose();
    },
  );

  test(
    'failed sync stays retryable and succeeds on the next attempt',
    () async {
      final remote = _FakeRemoteRepository(failCreates: 1);
      final repository = repositoryFor(remote);
      final created = await repository.create(
        type: IncidentType.infrastructure,
        severity: IncidentSeverity.low,
        title: 'Blocked road',
        description: 'Debris is blocking the access road.',
        latitude: null,
        longitude: null,
        peopleAffected: 0,
      );

      connectivity.setStatusForTest(ConnectivityStatus.connected);
      await repository.syncPending();
      expect(
        await repository.syncStateFor(created.incident.id!),
        IncidentSyncState.failed,
      );

      await repository.syncPending();
      expect(
        await repository.syncStateFor(created.incident.id!),
        IncidentSyncState.synced,
      );
      await repository.dispose();
    },
  );
}

class _FakeRemoteRepository implements IncidentRepository {
  _FakeRemoteRepository({this.failCreates = 0});

  int failCreates;
  final List<UuidValue?> createdIds = [];

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
    createdIds.add(id);
    if (failCreates > 0) {
      failCreates--;
      throw StateError('temporary failure');
    }
    final now = DateTime.now().toUtc();
    final incidentId = id!;
    final incident = Incident(
      id: incidentId,
      organizationId: _organizationId,
      type: type,
      severity: severity,
      status: IncidentStatus.reported,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      peopleAffected: peopleAffected,
      reportedBy: _userId,
      reportedAt: now,
      updatedAt: now,
    );
    return IncidentDetail(
      incident: incident,
      timeline: [
        IncidentEvent(
          incidentId: incidentId,
          organizationId: _organizationId,
          eventType: IncidentEventType.created,
          actorId: _userId,
          toStatus: IncidentStatus.reported,
          note: 'Incident reported',
          createdAt: now,
        ),
      ],
    );
  }

  @override
  Future<IncidentDetail> detail(UuidValue incidentId) =>
      throw UnimplementedError();

  @override
  Future<List<Incident>> list({int limit = 50}) async => [];

  @override
  Future<IncidentDetail> transition(
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) => throw UnimplementedError();
}

final _organizationId = UuidValue.fromString(
  '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f101',
);
final _userId = UuidValue.fromString('0199f2e9-9a4a-7e00-9a1f-4a6be0a1f102');
