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
import 'package:relayaid_client/src/protocol/protocol.dart' as _i9l9a2dk;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'assignment.dart' as _iavo6snm;
import 'incident.dart' as _iy4wsyyx;
import 'incident_event.dart' as _icglyrab;

abstract class IncidentDetail
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentDetail._({
    required this.incident,
    required this.timeline,
    this.assignment,
    this.assignmentTeamName,
  });

  factory IncidentDetail({
    required _iy4wsyyx.Incident incident,
    required List<_icglyrab.IncidentEvent> timeline,
    _iavo6snm.Assignment? assignment,
    String? assignmentTeamName,
  }) = _IncidentDetailImpl;

  factory IncidentDetail.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentDetail(
      incident: _i9l9a2dk.Protocol().deserialize<_iy4wsyyx.Incident>(
        jsonSerialization['incident'],
      ),
      timeline: _i9l9a2dk.Protocol().deserialize<List<_icglyrab.IncidentEvent>>(
        jsonSerialization['timeline'],
      ),
      assignment: jsonSerialization['assignment'] == null
          ? null
          : _i9l9a2dk.Protocol().deserialize<_iavo6snm.Assignment>(
              jsonSerialization['assignment'],
            ),
      assignmentTeamName: jsonSerialization['assignmentTeamName'] as String?,
    );
  }

  _iy4wsyyx.Incident incident;

  List<_icglyrab.IncidentEvent> timeline;

  _iavo6snm.Assignment? assignment;

  String? assignmentTeamName;

  /// Returns a shallow copy of this [IncidentDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentDetail copyWith({
    _iy4wsyyx.Incident? incident,
    List<_icglyrab.IncidentEvent>? timeline,
    _iavo6snm.Assignment? assignment,
    String? assignmentTeamName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentDetail',
      'incident': incident.toJson(),
      'timeline': timeline.toJson(valueToJson: (v) => v.toJson()),
      if (assignment != null) 'assignment': assignment?.toJson(),
      if (assignmentTeamName != null) 'assignmentTeamName': assignmentTeamName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentDetail',
      'incident': incident.toJsonForProtocol(),
      'timeline': timeline.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (assignment != null) 'assignment': assignment?.toJsonForProtocol(),
      if (assignmentTeamName != null) 'assignmentTeamName': assignmentTeamName,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentDetailImpl extends IncidentDetail {
  _IncidentDetailImpl({
    required _iy4wsyyx.Incident incident,
    required List<_icglyrab.IncidentEvent> timeline,
    _iavo6snm.Assignment? assignment,
    String? assignmentTeamName,
  }) : super._(
         incident: incident,
         timeline: timeline,
         assignment: assignment,
         assignmentTeamName: assignmentTeamName,
       );

  /// Returns a shallow copy of this [IncidentDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentDetail copyWith({
    _iy4wsyyx.Incident? incident,
    List<_icglyrab.IncidentEvent>? timeline,
    Object? assignment = _Undefined,
    Object? assignmentTeamName = _Undefined,
  }) {
    return IncidentDetail(
      incident: incident ?? this.incident.copyWith(),
      timeline: timeline ?? this.timeline.map((e0) => e0.copyWith()).toList(),
      assignment: assignment is _iavo6snm.Assignment?
          ? assignment
          : this.assignment?.copyWith(),
      assignmentTeamName: assignmentTeamName is String?
          ? assignmentTeamName
          : this.assignmentTeamName,
    );
  }
}
