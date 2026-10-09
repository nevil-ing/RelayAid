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
import 'incident_severity.dart' as _ifp7jacs;
import 'incident_status.dart' as _ikduxsi0;
import 'incident_type.dart' as _i3tf8ajh;

abstract class Incident
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Incident._({
    this.id,
    required this.organizationId,
    required this.type,
    required this.severity,
    required this.status,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    required this.peopleAffected,
    required this.reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    this.escalationDueAt,
    this.escalatedAt,
  }) : reportedAt = reportedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Incident({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required _i3tf8ajh.IncidentType type,
    required _ifp7jacs.IncidentSeverity severity,
    required _ikduxsi0.IncidentStatus status,
    required String title,
    required String description,
    double? latitude,
    double? longitude,
    required int peopleAffected,
    required _isc.UuidValue reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    DateTime? escalationDueAt,
    DateTime? escalatedAt,
  }) = _IncidentImpl;

  factory Incident.fromJson(Map<String, dynamic> jsonSerialization) {
    return Incident(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      organizationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      type: _i3tf8ajh.IncidentType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      severity: _ifp7jacs.IncidentSeverity.fromJson(
        (jsonSerialization['severity'] as String),
      ),
      status: _ikduxsi0.IncidentStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      peopleAffected: jsonSerialization['peopleAffected'] as int,
      reportedBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['reportedBy'],
      ),
      reportedAt: jsonSerialization['reportedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reportedAt'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      escalationDueAt: jsonSerialization['escalationDueAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['escalationDueAt'],
            ),
      escalatedAt: jsonSerialization['escalatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['escalatedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue organizationId;

  _i3tf8ajh.IncidentType type;

  _ifp7jacs.IncidentSeverity severity;

  _ikduxsi0.IncidentStatus status;

  String title;

  String description;

  double? latitude;

  double? longitude;

  int peopleAffected;

  _isc.UuidValue reportedBy;

  DateTime reportedAt;

  DateTime updatedAt;

  DateTime? escalationDueAt;

  DateTime? escalatedAt;

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Incident copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? organizationId,
    _i3tf8ajh.IncidentType? type,
    _ifp7jacs.IncidentSeverity? severity,
    _ikduxsi0.IncidentStatus? status,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    int? peopleAffected,
    _isc.UuidValue? reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    DateTime? escalationDueAt,
    DateTime? escalatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'type': type.toJson(),
      'severity': severity.toJson(),
      'status': status.toJson(),
      'title': title,
      'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'peopleAffected': peopleAffected,
      'reportedBy': reportedBy.toJson(),
      'reportedAt': reportedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (escalationDueAt != null) 'escalationDueAt': escalationDueAt?.toJson(),
      if (escalatedAt != null) 'escalatedAt': escalatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'type': type.toJson(),
      'severity': severity.toJson(),
      'status': status.toJson(),
      'title': title,
      'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'peopleAffected': peopleAffected,
      'reportedBy': reportedBy.toJson(),
      'reportedAt': reportedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (escalationDueAt != null) 'escalationDueAt': escalationDueAt?.toJson(),
      if (escalatedAt != null) 'escalatedAt': escalatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentImpl extends Incident {
  _IncidentImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required _i3tf8ajh.IncidentType type,
    required _ifp7jacs.IncidentSeverity severity,
    required _ikduxsi0.IncidentStatus status,
    required String title,
    required String description,
    double? latitude,
    double? longitude,
    required int peopleAffected,
    required _isc.UuidValue reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    DateTime? escalationDueAt,
    DateTime? escalatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         type: type,
         severity: severity,
         status: status,
         title: title,
         description: description,
         latitude: latitude,
         longitude: longitude,
         peopleAffected: peopleAffected,
         reportedBy: reportedBy,
         reportedAt: reportedAt,
         updatedAt: updatedAt,
         escalationDueAt: escalationDueAt,
         escalatedAt: escalatedAt,
       );

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Incident copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? organizationId,
    _i3tf8ajh.IncidentType? type,
    _ifp7jacs.IncidentSeverity? severity,
    _ikduxsi0.IncidentStatus? status,
    String? title,
    String? description,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    int? peopleAffected,
    _isc.UuidValue? reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    Object? escalationDueAt = _Undefined,
    Object? escalatedAt = _Undefined,
  }) {
    return Incident(
      id: id is _isc.UuidValue? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      peopleAffected: peopleAffected ?? this.peopleAffected,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedAt: reportedAt ?? this.reportedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      escalationDueAt: escalationDueAt is DateTime?
          ? escalationDueAt
          : this.escalationDueAt,
      escalatedAt: escalatedAt is DateTime? ? escalatedAt : this.escalatedAt,
    );
  }
}
