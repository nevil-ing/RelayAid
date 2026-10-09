import 'dart:async';

import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_controller.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/auth/application/access_controller.dart';
import 'package:relayaid_flutter/features/assignments/domain/assignment_repository.dart';
import 'package:relayaid_flutter/features/teams/domain/team_repository.dart';

import 'command_center_fixture.dart';

final assignmentTeamId = UuidValue.fromString(
  '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f103',
);
final assignmentId = UuidValue.fromString(
  '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f104',
);

class AssignmentFixture {
  AssignmentFixture() {
    gateway.context = gateway.context.copyWith(
      membership: gateway.context.membership.copyWith(
        role: MemberRole.responder,
      ),
    );
  }
  final gateway = CommandAuthGateway();
  final connectivity = ConnectivityController()
    ..setStatusForTest(ConnectivityStatus.connected);
  final repository = FakeAssignmentRepository();
  late final access = AccessController(gateway);
  Future<void> initialize() => access.initialize();
  Future<void> dispose({bool ownsConnectivity = true}) async {
    await repository.dispose();
    access.dispose();
    gateway.dispose();
    if (ownsConnectivity) connectivity.dispose();
  }
}

class FakeAssignmentRepository implements AssignmentRepository {
  final connections = <StreamController<AssignmentFeed>>[];
  final details = <UuidValue, IncidentDetail>{};
  final detailGates = <UuidValue, Completer<IncidentDetail>>{};
  Completer<void>? actionGate;
  Object? failure;
  int actions = 0;
  int cancelled = 0;
  String? resolutionNote;
  AssignmentFeed current = assignmentFeed([]);

  @override
  Stream<AssignmentFeed> watch() {
    late StreamController<AssignmentFeed> connection;
    connection = StreamController<AssignmentFeed>(
      onListen: () => connection.add(current),
      onCancel: () => cancelled++,
    );
    connections.add(connection);
    return connection.stream;
  }

  void emit(AssignmentFeed feed) {
    current = feed;
    for (final connection in connections) {
      if (connection.hasListener && !connection.isClosed) connection.add(feed);
    }
  }

  void fail(Object error) => connections.last.addError(error);
  @override
  Future<IncidentDetail> detail(UuidValue id) async =>
      detailGates[id]?.future ?? details[id]!;
  @override
  Future<IncidentDetail> accept(UuidValue id) =>
      _change(id, AssignmentStatus.accepted);
  @override
  Future<IncidentDetail> respond(UuidValue id) =>
      _change(id, AssignmentStatus.responding);
  @override
  Future<IncidentDetail> resolve(UuidValue id, String note) {
    resolutionNote = note;
    return _change(id, AssignmentStatus.resolved, note: note);
  }

  Future<IncidentDetail> _change(
    UuidValue id,
    AssignmentStatus status, {
    String? note,
  }) async {
    actions++;
    await actionGate?.future;
    if (failure != null) throw failure!;
    final old = details[id]!;
    final newDetail = assignmentDetail(status: status, id: id, note: note);
    details[id] = newDetail;
    emit(
      assignmentFeed([
        for (final summary in current.assignments)
          summary.assignment.id == id ? assignmentSummary(newDetail) : summary,
      ]),
    );
    return newDetail.copyWith(
      incident: newDetail.incident.copyWith(title: old.incident.title),
    );
  }

  Future<void> dispose() async {
    for (final connection in connections) {
      await connection.close();
    }
  }
}

IncidentDetail assignmentDetail({
  AssignmentStatus status = AssignmentStatus.pending,
  UuidValue? id,
  UuidValue? acceptedBy,
  String? note,
}) {
  final incident = commandIncident(
    status: switch (status) {
      AssignmentStatus.responding => IncidentStatus.responding,
      AssignmentStatus.resolved => IncidentStatus.resolved,
      AssignmentStatus.cancelled => IncidentStatus.cancelled,
      _ => IncidentStatus.assigned,
    },
  );
  final assignment = Assignment(
    id: id ?? assignmentId,
    organizationId: commandOrganizationId,
    incidentId: incident.id!,
    teamId: assignmentTeamId,
    assignedBy: commandUserId,
    acceptedBy: status == AssignmentStatus.pending
        ? null
        : acceptedBy ?? commandUserId,
    status: status,
    createdAt: DateTime.utc(2026, 10, 5),
    updatedAt: DateTime.utc(2026, 10, 5),
  );
  return IncidentDetail(
    incident: incident,
    assignment: assignment,
    assignmentTeamName: 'Team Alpha',
    timeline: [
      commandEvent(incident),
      commandEvent(
        incident,
        number: 2,
        type: IncidentEventType.assignmentCreated,
        status: IncidentStatus.assigned,
      ).copyWith(assignmentId: assignment.id, note: 'Assigned to Team Alpha'),
      if (status != AssignmentStatus.pending &&
          status != AssignmentStatus.cancelled)
        commandEvent(
          incident,
          number: 3,
          type: IncidentEventType.assignmentAccepted,
          status: IncidentStatus.assigned,
        ).copyWith(assignmentId: assignment.id),
      if (status == AssignmentStatus.responding ||
          status == AssignmentStatus.resolved)
        commandEvent(
          incident,
          number: 4,
          type: IncidentEventType.responseStarted,
          status: IncidentStatus.responding,
        ).copyWith(assignmentId: assignment.id),
      if (status == AssignmentStatus.resolved)
        commandEvent(
          incident,
          number: 5,
          type: IncidentEventType.assignmentResolved,
          status: IncidentStatus.resolved,
        ).copyWith(
          assignmentId: assignment.id,
          note: note ?? 'Crossing secured.',
        ),
    ],
  );
}

AssignmentSummary assignmentSummary(IncidentDetail detail) => AssignmentSummary(
  assignment: detail.assignment!,
  incident: detail.incident,
  teamName: detail.assignmentTeamName!,
);
AssignmentFeed assignmentFeed(List<AssignmentSummary> assignments) =>
    AssignmentFeed(
      organizationId: commandOrganizationId,
      authUserId: commandUserId,
      assignments: assignments,
      generatedAt: DateTime.utc(2026, 10, 5),
      hasMoreAssignments: false,
    );
TeamRoster assignmentRoster() => TeamRoster(
  team: Team(
    id: assignmentTeamId,
    organizationId: commandOrganizationId,
    name: 'Team Alpha',
  ),
  responders: [
    OrganizationMember(
      organizationId: commandOrganizationId,
      authUserId: commandUserId,
      role: MemberRole.responder,
    ),
  ],
  activeAssignments: 0,
);

class FakeTeamRepository implements TeamRepository {
  int creates = 0;
  int adds = 0;
  Object? failure;
  Completer<List<OrganizationMember>>? memberGate;
  @override
  Future<List<OrganizationMember>> members(UuidValue id) async =>
      memberGate?.future ?? assignmentRoster().responders;
  @override
  Future<Team> create(UuidValue id, String name) async {
    creates++;
    if (failure != null) throw failure!;
    return Team(id: assignmentTeamId, organizationId: id, name: name);
  }

  @override
  Future<TeamMember> addResponder(
    UuidValue teamId,
    UuidValue responderId,
  ) async {
    adds++;
    if (failure != null) throw failure!;
    return TeamMember(teamId: teamId, authUserId: responderId);
  }
}
