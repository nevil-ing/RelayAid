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
import 'assignment_status.dart' as _ikrvejjw;

abstract class Assignment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Assignment._({
    this.id,
    required this.organizationId,
    required this.incidentId,
    required this.teamId,
    this.designatedResponderId,
    required this.assignedBy,
    this.acceptedBy,
    required this.status,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.acceptedAt,
    this.respondingAt,
    this.resolvedAt,
    this.cancelledAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Assignment({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required _isc.UuidValue incidentId,
    required _isc.UuidValue teamId,
    _isc.UuidValue? designatedResponderId,
    required _isc.UuidValue assignedBy,
    _isc.UuidValue? acceptedBy,
    required _ikrvejjw.AssignmentStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? respondingAt,
    DateTime? resolvedAt,
    DateTime? cancelledAt,
  }) = _AssignmentImpl;

  factory Assignment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Assignment(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      organizationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      incidentId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['incidentId'],
      ),
      teamId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      designatedResponderId: jsonSerialization['designatedResponderId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['designatedResponderId'],
            ),
      assignedBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['assignedBy'],
      ),
      acceptedBy: jsonSerialization['acceptedBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['acceptedBy'],
            ),
      status: _ikrvejjw.AssignmentStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acceptedAt'],
            ),
      respondingAt: jsonSerialization['respondingAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['respondingAt'],
            ),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
      cancelledAt: jsonSerialization['cancelledAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['cancelledAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue organizationId;

  _isc.UuidValue incidentId;

  _isc.UuidValue teamId;

  _isc.UuidValue? designatedResponderId;

  _isc.UuidValue assignedBy;

  _isc.UuidValue? acceptedBy;

  _ikrvejjw.AssignmentStatus status;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? acceptedAt;

  DateTime? respondingAt;

  DateTime? resolvedAt;

  DateTime? cancelledAt;

  /// Returns a shallow copy of this [Assignment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Assignment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? organizationId,
    _isc.UuidValue? incidentId,
    _isc.UuidValue? teamId,
    _isc.UuidValue? designatedResponderId,
    _isc.UuidValue? assignedBy,
    _isc.UuidValue? acceptedBy,
    _ikrvejjw.AssignmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? respondingAt,
    DateTime? resolvedAt,
    DateTime? cancelledAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Assignment',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'incidentId': incidentId.toJson(),
      'teamId': teamId.toJson(),
      if (designatedResponderId != null)
        'designatedResponderId': designatedResponderId?.toJson(),
      'assignedBy': assignedBy.toJson(),
      if (acceptedBy != null) 'acceptedBy': acceptedBy?.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (respondingAt != null) 'respondingAt': respondingAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Assignment',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'incidentId': incidentId.toJson(),
      'teamId': teamId.toJson(),
      if (designatedResponderId != null)
        'designatedResponderId': designatedResponderId?.toJson(),
      'assignedBy': assignedBy.toJson(),
      if (acceptedBy != null) 'acceptedBy': acceptedBy?.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (respondingAt != null) 'respondingAt': respondingAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssignmentImpl extends Assignment {
  _AssignmentImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required _isc.UuidValue incidentId,
    required _isc.UuidValue teamId,
    _isc.UuidValue? designatedResponderId,
    required _isc.UuidValue assignedBy,
    _isc.UuidValue? acceptedBy,
    required _ikrvejjw.AssignmentStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? respondingAt,
    DateTime? resolvedAt,
    DateTime? cancelledAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         incidentId: incidentId,
         teamId: teamId,
         designatedResponderId: designatedResponderId,
         assignedBy: assignedBy,
         acceptedBy: acceptedBy,
         status: status,
         createdAt: createdAt,
         updatedAt: updatedAt,
         acceptedAt: acceptedAt,
         respondingAt: respondingAt,
         resolvedAt: resolvedAt,
         cancelledAt: cancelledAt,
       );

  /// Returns a shallow copy of this [Assignment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Assignment copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? organizationId,
    _isc.UuidValue? incidentId,
    _isc.UuidValue? teamId,
    Object? designatedResponderId = _Undefined,
    _isc.UuidValue? assignedBy,
    Object? acceptedBy = _Undefined,
    _ikrvejjw.AssignmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? acceptedAt = _Undefined,
    Object? respondingAt = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? cancelledAt = _Undefined,
  }) {
    return Assignment(
      id: id is _isc.UuidValue? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      incidentId: incidentId ?? this.incidentId,
      teamId: teamId ?? this.teamId,
      designatedResponderId: designatedResponderId is _isc.UuidValue?
          ? designatedResponderId
          : this.designatedResponderId,
      assignedBy: assignedBy ?? this.assignedBy,
      acceptedBy: acceptedBy is _isc.UuidValue? ? acceptedBy : this.acceptedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      respondingAt: respondingAt is DateTime?
          ? respondingAt
          : this.respondingAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      cancelledAt: cancelledAt is DateTime? ? cancelledAt : this.cancelledAt,
    );
  }
}
