import 'package:serverpod/serverpod.dart';

import '../authorization/organization_access.dart';
import '../generated/protocol.dart';
import 'incident_feed_service.dart';
import 'incident_detail_reader.dart';
import 'incident_escalation_policy.dart';

/// Owns incident validation, lifecycle transitions, and immutable timeline writes.
abstract final class IncidentService {
  static const _coordinatorRoles = {
    MemberRole.coordinator,
    MemberRole.administrator,
  };

  static Future<IncidentDetail> create(
    Session session, {
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) async {
    _validateReport(
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      peopleAffected: peopleAffected,
    );
    final membership = await OrganizationAccess.currentMember(session);
    final actorId = OrganizationAccess.userId(session);
    final now = DateTime.now().toUtc();

    IncidentEvent? createdEvent;
    final result = await session.db.transaction((transaction) async {
      if (id != null) {
        final existing = await Incident.db.findById(
          session,
          id,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (existing != null) {
          if (existing.organizationId != membership.organizationId) {
            throw AuthorizationException(message: 'Incident access denied.');
          }
          return IncidentDetailReader.read(
            session,
            existing,
            transaction: transaction,
          );
        }
      }
      final incident = await Incident.db.insertRow(
        session,
        Incident(
          id: id,
          organizationId: membership.organizationId,
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
          escalationDueAt: IncidentEscalationPolicy.fromEnvironment().deadline(
            severity,
            now,
          ),
        ),
        transaction: transaction,
      );
      createdEvent = await IncidentEvent.db.insertRow(
        session,
        IncidentEvent(
          incidentId: incident.id!,
          organizationId: membership.organizationId,
          eventType: IncidentEventType.created,
          actorId: actorId,
          toStatus: IncidentStatus.reported,
          note: 'Incident reported',
          createdAt: now,
        ),
        transaction: transaction,
      );
      return IncidentDetailReader.read(
        session,
        incident,
        transaction: transaction,
      );
    });
    if (createdEvent case final IncidentEvent event) {
      await IncidentFeedService.publish(session, event);
    }
    return result;
  }

  static Future<List<Incident>> list(
    Session session, {
    int limit = 50,
  }) async {
    if (limit < 1 || limit > 100) {
      throw IncidentValidationException(
        message: 'Incident list limit must be between 1 and 100.',
      );
    }
    final membership = await OrganizationAccess.currentMember(session);
    return Incident.db.find(
      session,
      where: (table) => table.organizationId.equals(membership.organizationId),
      orderByList: (table) => [table.updatedAt.desc()],
      limit: limit,
    );
  }

  static Future<IncidentDetail> detail(
    Session session,
    UuidValue incidentId,
  ) => session.db.transaction(
    (transaction) async {
      final incident = await Incident.db.findById(
        session,
        incidentId,
        transaction: transaction,
      );
      if (incident == null) {
        throw AuthorizationException(message: 'Incident access denied.');
      }
      await OrganizationAccess.member(
        session,
        incident.organizationId,
        transaction: transaction,
      );
      return IncidentDetailReader.read(
        session,
        incident,
        transaction: transaction,
      );
    },
    settings: const TransactionSettings(
      isolationLevel: IsolationLevel.repeatableRead,
    ),
  );

  static Future<IncidentDetail> transition(
    Session session,
    UuidValue incidentId,
    IncidentStatus nextStatus, {
    String? note,
  }) async {
    final actorId = OrganizationAccess.userId(session);
    final incident = await Incident.db.findById(session, incidentId);
    if (incident == null) {
      throw AuthorizationException(message: 'Incident access denied.');
    }
    await OrganizationAccess.member(
      session,
      incident.organizationId,
      roles: _coordinatorRoles,
    );
    final allowedStatuses = _allowedTransitions[incident.status] ?? const {};
    if (!allowedStatuses.contains(nextStatus)) {
      throw IncidentValidationException(
        message:
            'Incident cannot move from ${incident.status.name} to ${nextStatus.name}.',
      );
    }
    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.length > 500) {
      throw IncidentValidationException(
        message: 'Timeline notes must be 500 characters or fewer.',
      );
    }
    late IncidentEvent changedEvent;
    final result = await session.db.transaction((transaction) async {
      final lockedIncident = await Incident.db.findById(
        session,
        incidentId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (lockedIncident == null) {
        throw AuthorizationException(message: 'Incident access denied.');
      }
      if (lockedIncident.status != incident.status) {
        throw IncidentValidationException(
          message: 'Incident changed before this transition was applied.',
        );
      }
      await OrganizationAccess.member(
        session,
        lockedIncident.organizationId,
        roles: _coordinatorRoles,
        transaction: transaction,
      );
      final now = DateTime.now().toUtc();
      final assignment = await Assignment.db.findFirstRow(
        session,
        where: (t) => t.incidentId.equals(incidentId),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (nextStatus == IncidentStatus.cancelled && assignment != null) {
        await Assignment.db.updateRow(
          session,
          assignment.copyWith(
            status: AssignmentStatus.cancelled,
            cancelledAt: now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      }
      final updated = await Incident.db.updateRow(
        session,
        lockedIncident.copyWith(status: nextStatus, updatedAt: now),
        transaction: transaction,
      );
      changedEvent = await IncidentEvent.db.insertRow(
        session,
        IncidentEvent(
          incidentId: incidentId,
          organizationId: updated.organizationId,
          eventType: assignment == null
              ? IncidentEventType.statusChanged
              : IncidentEventType.assignmentCancelled,
          assignmentId: assignment?.id,
          actorId: actorId,
          fromStatus: incident.status,
          toStatus: nextStatus,
          note: trimmedNote?.isEmpty ?? true ? null : trimmedNote,
          createdAt: now,
        ),
        transaction: transaction,
      );
      return IncidentDetailReader.read(
        session,
        updated,
        transaction: transaction,
      );
    });
    await IncidentFeedService.publish(session, changedEvent);
    return result;
  }

  static void _validateReport({
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) {
    final titleLength = title.trim().length;
    if (titleLength < 3 || titleLength > 120) {
      throw IncidentValidationException(
        message: 'Incident titles must be 3–120 characters.',
      );
    }
    final descriptionLength = description.trim().length;
    if (descriptionLength < 3 || descriptionLength > 5000) {
      throw IncidentValidationException(
        message: 'Incident descriptions must be 3–5,000 characters.',
      );
    }
    if ((latitude == null) != (longitude == null)) {
      throw IncidentValidationException(
        message: 'Latitude and longitude must be supplied together.',
      );
    }
    if (latitude != null &&
        (!latitude.isFinite || latitude < -90 || latitude > 90)) {
      throw IncidentValidationException(message: 'Latitude is out of range.');
    }
    if (longitude != null &&
        (!longitude.isFinite || longitude < -180 || longitude > 180)) {
      throw IncidentValidationException(message: 'Longitude is out of range.');
    }
    if (peopleAffected < 0 || peopleAffected > 1000000) {
      throw IncidentValidationException(
        message: 'People affected must be between 0 and 1,000,000.',
      );
    }
  }

  static const Map<IncidentStatus, Set<IncidentStatus>> _allowedTransitions = {
    IncidentStatus.reported: {
      IncidentStatus.acknowledged,
      IncidentStatus.cancelled,
    },
    IncidentStatus.acknowledged: {
      IncidentStatus.cancelled,
    },
    IncidentStatus.assigned: {
      IncidentStatus.cancelled,
    },
    IncidentStatus.responding: {
      IncidentStatus.cancelled,
    },
  };
}
