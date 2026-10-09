/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'incident_event_type.dart' as _ic7pik0n;
import 'incident_status.dart' as _ikduxsi0;

abstract class IncidentEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentEvent._({
    this.id,
    required this.incidentId,
    required this.organizationId,
    required this.eventType,
    this.actorId,
    this.assignmentId,
    this.fromStatus,
    this.toStatus,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory IncidentEvent({
    _isc.UuidValue? id,
    required _isc.UuidValue incidentId,
    required _isc.UuidValue organizationId,
    required _ic7pik0n.IncidentEventType eventType,
    _isc.UuidValue? actorId,
    _isc.UuidValue? assignmentId,
    _ikduxsi0.IncidentStatus? fromStatus,
    _ikduxsi0.IncidentStatus? toStatus,
    String? note,
    DateTime? createdAt,
  }) = _IncidentEventImpl;

  factory IncidentEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      incidentId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['incidentId'],
      ),
      organizationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      eventType: _ic7pik0n.IncidentEventType.fromJson(
        (jsonSerialization['eventType'] as String),
      ),
      actorId: jsonSerialization['actorId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['actorId']),
      assignmentId: jsonSerialization['assignmentId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['assignmentId'],
            ),
      fromStatus: jsonSerialization['fromStatus'] == null
          ? null
          : _ikduxsi0.IncidentStatus.fromJson(
              (jsonSerialization['fromStatus'] as String),
            ),
      toStatus: jsonSerialization['toStatus'] == null
          ? null
          : _ikduxsi0.IncidentStatus.fromJson(
              (jsonSerialization['toStatus'] as String),
            ),
      note: jsonSerialization['note'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue incidentId;

  _isc.UuidValue organizationId;

  _ic7pik0n.IncidentEventType eventType;

  _isc.UuidValue? actorId;

  _isc.UuidValue? assignmentId;

  _ikduxsi0.IncidentStatus? fromStatus;

  _ikduxsi0.IncidentStatus? toStatus;

  String? note;

  DateTime createdAt;

  /// Returns a shallow copy of this [IncidentEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentEvent copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? incidentId,
    _isc.UuidValue? organizationId,
    _ic7pik0n.IncidentEventType? eventType,
    _isc.UuidValue? actorId,
    _isc.UuidValue? assignmentId,
    _ikduxsi0.IncidentStatus? fromStatus,
    _ikduxsi0.IncidentStatus? toStatus,
    String? note,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentEvent',
      if (id != null) 'id': id?.toJson(),
      'incidentId': incidentId.toJson(),
      'organizationId': organizationId.toJson(),
      'eventType': eventType.toJson(),
      if (actorId != null) 'actorId': actorId?.toJson(),
      if (assignmentId != null) 'assignmentId': assignmentId?.toJson(),
      if (fromStatus != null) 'fromStatus': fromStatus?.toJson(),
      if (toStatus != null) 'toStatus': toStatus?.toJson(),
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentEvent',
      if (id != null) 'id': id?.toJson(),
      'incidentId': incidentId.toJson(),
      'organizationId': organizationId.toJson(),
      'eventType': eventType.toJson(),
      if (actorId != null) 'actorId': actorId?.toJson(),
      if (assignmentId != null) 'assignmentId': assignmentId?.toJson(),
      if (fromStatus != null) 'fromStatus': fromStatus?.toJson(),
      if (toStatus != null) 'toStatus': toStatus?.toJson(),
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentEventImpl extends IncidentEvent {
  _IncidentEventImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue incidentId,
    required _isc.UuidValue organizationId,
    required _ic7pik0n.IncidentEventType eventType,
    _isc.UuidValue? actorId,
    _isc.UuidValue? assignmentId,
    _ikduxsi0.IncidentStatus? fromStatus,
    _ikduxsi0.IncidentStatus? toStatus,
    String? note,
    DateTime? createdAt,
  }) : super._(
         id: id,
         incidentId: incidentId,
         organizationId: organizationId,
         eventType: eventType,
         actorId: actorId,
         assignmentId: assignmentId,
         fromStatus: fromStatus,
         toStatus: toStatus,
         note: note,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [IncidentEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentEvent copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? incidentId,
    _isc.UuidValue? organizationId,
    _ic7pik0n.IncidentEventType? eventType,
    Object? actorId = _Undefined,
    Object? assignmentId = _Undefined,
    Object? fromStatus = _Undefined,
    Object? toStatus = _Undefined,
    Object? note = _Undefined,
    DateTime? createdAt,
  }) {
    return IncidentEvent(
      id: id is _isc.UuidValue? ? id : this.id,
      incidentId: incidentId ?? this.incidentId,
      organizationId: organizationId ?? this.organizationId,
      eventType: eventType ?? this.eventType,
      actorId: actorId is _isc.UuidValue? ? actorId : this.actorId,
      assignmentId: assignmentId is _isc.UuidValue?
          ? assignmentId
          : this.assignmentId,
      fromStatus: fromStatus is _ikduxsi0.IncidentStatus?
          ? fromStatus
          : this.fromStatus,
      toStatus: toStatus is _ikduxsi0.IncidentStatus?
          ? toStatus
          : this.toStatus,
      note: note is String? ? note : this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
