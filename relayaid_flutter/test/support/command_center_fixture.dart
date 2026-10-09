import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_controller.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/auth/domain/auth_gateway.dart';
import 'package:relayaid_flutter/features/command_center/domain/command_center_repository.dart';
import 'package:relayaid_flutter/features/media/domain/attachment_repository.dart';
import 'package:relayaid_flutter/features/media/domain/queued_attachment.dart';

final commandOrganizationId = UuidValue.fromString(
  '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f101',
);
final commandUserId = UuidValue.fromString(
  '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f102',
);

class CommandCenterFixture {
  final gateway = CommandAuthGateway();
  final connectivity = ConnectivityController()
    ..setStatusForTest(ConnectivityStatus.connected);
  final repository = FakeCommandCenterRepository();
  late final access = AccessController(gateway);

  Future<void> initialize() => access.initialize();
  Future<void> dispose({bool ownsConnectivity = true}) async {
    await repository.dispose();
    access.dispose();
    gateway.dispose();
    if (ownsConnectivity) connectivity.dispose();
  }
}

class CommandAuthGateway extends ChangeNotifier implements AuthGateway {
  bool authenticated = true;
  OrganizationContext context = OrganizationContext(
    organization: Organization(
      id: commandOrganizationId,
      name: 'RelayAid Response',
      createdBy: commandUserId,
    ),
    membership: OrganizationMember(
      organizationId: commandOrganizationId,
      authUserId: commandUserId,
      role: MemberRole.coordinator,
    ),
  );
  @override
  bool get isAuthenticated => authenticated;
  @override
  UuidValue? get userId => authenticated ? context.membership.authUserId : null;
  @override
  Future<void> restore() async {}
  @override
  Future<void> signOut() async {
    authenticated = false;
    notifyListeners();
  }

  @override
  Future<OrganizationContext?> myContext() async => context;
  @override
  Future<OrganizationContext> createOrganization(String name) async => context;
  @override
  Future<List<OrganizationMember>> listMembers(UuidValue id) async => [
    context.membership,
  ];
  @override
  Future<List<Team>> listTeams(UuidValue id) async => [];
  @override
  Future<OrganizationMember> addMember(
    UuidValue organizationId,
    UuidValue userId,
    MemberRole role,
  ) => throw UnimplementedError();
  @override
  Future<Team> createTeam(UuidValue organizationId, String name) =>
      throw UnimplementedError();
}

class FakeCommandCenterRepository implements CommandCenterRepository {
  final connections = <StreamController<IncidentFeed>>[];
  final details = <UuidValue, IncidentDetail>{};
  final detailGates = <UuidValue, Completer<IncidentDetail>>{};
  int cancelled = 0;
  int detailCalls = 0;
  int acknowledgeCalls = 0;
  int assignCalls = 0;
  Object? detailFailure;
  IncidentFeed current = commandFeed([]);

  @override
  Stream<IncidentFeed> watch() {
    late StreamController<IncidentFeed> connection;
    connection = StreamController<IncidentFeed>(
      onListen: () => connection.add(current),
      onCancel: () => cancelled++,
    );
    connections.add(connection);
    return connection.stream;
  }

  void emit(IncidentFeed feed) {
    current = feed;
    for (final connection in connections) {
      if (connection.hasListener && !connection.isClosed) connection.add(feed);
    }
  }

  void fail(Object error) => connections.last.addError(error);

  @override
  Future<IncidentDetail> detail(UuidValue id) async {
    detailCalls++;
    if (detailFailure != null) throw detailFailure!;
    return detailGates[id]?.future ?? details[id]!;
  }

  @override
  Future<IncidentDetail> acknowledge(UuidValue id) async {
    acknowledgeCalls++;
    final old = details[id]!;
    final event = commandEvent(
      old.incident,
      number: old.timeline.length + 1,
      type: IncidentEventType.statusChanged,
      status: IncidentStatus.acknowledged,
    );
    final next = IncidentDetail(
      incident: old.incident.copyWith(status: IncidentStatus.acknowledged),
      timeline: [...old.timeline, event],
    );
    details[id] = next;
    emit(
      commandFeed(
        [
          for (final incident in current.incidents)
            incident.id == id ? next.incident : incident,
        ],
        activity: [
          IncidentActivity(event: event, incidentTitle: next.incident.title),
          ...current.activity,
        ],
      ),
    );
    return next;
  }

  Future<void> dispose() async {
    for (final connection in connections) {
      await connection.close();
    }
  }

  @override
  Future<IncidentDetail> assign(
    UuidValue id,
    UuidValue teamId, {
    UuidValue? responderId,
  }) async {
    assignCalls++;
    final old = details[id]!;
    final team = current.teams!.singleWhere((r) => r.team.id == teamId).team;
    final next = IncidentDetail(
      incident: old.incident.copyWith(status: IncidentStatus.assigned),
      assignment: Assignment(
        id: Uuid().v7obj(),
        organizationId: commandOrganizationId,
        incidentId: id,
        teamId: teamId,
        assignedBy: commandUserId,
        designatedResponderId: responderId,
        status: AssignmentStatus.pending,
      ),
      assignmentTeamName: team.name,
      timeline: [
        ...old.timeline,
        commandEvent(
          old.incident,
          number: 2,
          type: IncidentEventType.assignmentCreated,
          status: IncidentStatus.assigned,
        ),
      ],
    );
    details[id] = next;
    emit(
      current.copyWith(
        incidents: [
          for (final incident in current.incidents)
            incident.id == id ? next.incident : incident,
        ],
      ),
    );
    return next;
  }

  @override
  Future<IncidentDetail> cancel(UuidValue id) async =>
      throw UnimplementedError();
}

Incident commandIncident({
  int number = 1,
  String title = 'Flooded bridge',
  IncidentSeverity severity = IncidentSeverity.high,
  IncidentStatus status = IncidentStatus.reported,
  double? latitude = -0.3031,
  double? longitude = 36.0800,
}) => Incident(
  id: UuidValue.fromString(
    '0199f2e9-9a4a-7e00-9a1f-${number.toString().padLeft(12, '0')}',
  ),
  organizationId: commandOrganizationId,
  reportedBy: commandUserId,
  type: IncidentType.flooding,
  severity: severity,
  status: status,
  title: title,
  description: 'Water has blocked the road. People need a safe crossing.',
  latitude: latitude,
  longitude: longitude,
  peopleAffected: 12,
  reportedAt: DateTime.utc(2026, 10, 3, 9),
  updatedAt: DateTime.utc(2026, 10, 3, 9),
);

IncidentEvent commandEvent(
  Incident incident, {
  int number = 1,
  IncidentEventType type = IncidentEventType.created,
  IncidentStatus status = IncidentStatus.reported,
}) => IncidentEvent(
  id: UuidValue.fromString(
    '0199f2e9-9a4a-7e00-9a2f-${number.toString().padLeft(12, '0')}',
  ),
  incidentId: incident.id!,
  organizationId: commandOrganizationId,
  actorId: commandUserId,
  eventType: type,
  fromStatus: type == IncidentEventType.statusChanged
      ? IncidentStatus.reported
      : null,
  toStatus: status,
  createdAt: DateTime.utc(2026, 10, 3, 9, number),
);

IncidentFeed commandFeed(
  List<Incident> incidents, {
  List<IncidentActivity> activity = const [],
}) => IncidentFeed(
  organizationId: commandOrganizationId,
  incidents: incidents,
  activity: activity,
  generatedAt: DateTime.utc(2026, 10, 3, 9),
  hasMoreIncidents: false,
);

// Deterministic, valid PNG; tests never fetch third-party map tiles.
class TestMapTileProvider extends TileProvider {
  final tile = MemoryImage(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  );
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      tile;
}

class FakeCommandPhotos implements AttachmentRepository {
  final notifications = StreamController<void>.broadcast();
  int refreshCalls = 0;
  @override
  Stream<void> get changes => notifications.stream;
  @override
  Future<List<QueuedAttachment>> list(
    UuidValue id, {
    bool refresh = false,
  }) async {
    if (refresh) refreshCalls++;
    return [];
  }

  @override
  Future<List<QueuedAttachment>> queue() async => [];
  @override
  Future<void> process({bool forceRetry = false}) async {}
  @override
  Future<void> recoverPhoto() async {}
  @override
  Future<UuidValue> draftIncidentId() => throw UnimplementedError();
  @override
  Future<void> capture(UuidValue id, PhotoSource source) =>
      throw UnimplementedError();
  @override
  Future<void> removeDraft(UuidValue id) => throw UnimplementedError();
  @override
  Future<Uint8List> read(QueuedAttachment attachment) =>
      throw UnimplementedError();
}
