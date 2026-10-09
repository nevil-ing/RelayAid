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
import 'package:relayaid_server/src/generated/protocol.dart' as _i24hraxo;
import 'package:serverpod/serverpod.dart' as _is;
import 'incident.dart' as _iy4wsyyx;
import 'incident_activity.dart' as _ilj9fez1;
import 'team_roster.dart' as _isfr4fbx;

abstract class IncidentFeed
    implements _is.SerializableModel, _is.ProtocolSerialization {
  IncidentFeed._({
    required this.organizationId,
    required this.incidents,
    required this.activity,
    required this.generatedAt,
    required this.hasMoreIncidents,
    this.teams,
  });

  factory IncidentFeed({
    required _is.UuidValue organizationId,
    required List<_iy4wsyyx.Incident> incidents,
    required List<_ilj9fez1.IncidentActivity> activity,
    required DateTime generatedAt,
    required bool hasMoreIncidents,
    List<_isfr4fbx.TeamRoster>? teams,
  }) = _IncidentFeedImpl;

  factory IncidentFeed.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentFeed(
      organizationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      incidents: _i24hraxo.Protocol().deserialize<List<_iy4wsyyx.Incident>>(
        jsonSerialization['incidents'],
      ),
      activity: _i24hraxo.Protocol()
          .deserialize<List<_ilj9fez1.IncidentActivity>>(
            jsonSerialization['activity'],
          ),
      generatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
      hasMoreIncidents: _is.BoolJsonExtension.fromJson(
        jsonSerialization['hasMoreIncidents'],
      ),
      teams: jsonSerialization['teams'] == null
          ? null
          : _i24hraxo.Protocol().deserialize<List<_isfr4fbx.TeamRoster>>(
              jsonSerialization['teams'],
            ),
    );
  }

  _is.UuidValue organizationId;

  List<_iy4wsyyx.Incident> incidents;

  List<_ilj9fez1.IncidentActivity> activity;

  DateTime generatedAt;

  bool hasMoreIncidents;

  List<_isfr4fbx.TeamRoster>? teams;

  /// Returns a shallow copy of this [IncidentFeed]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IncidentFeed copyWith({
    _is.UuidValue? organizationId,
    List<_iy4wsyyx.Incident>? incidents,
    List<_ilj9fez1.IncidentActivity>? activity,
    DateTime? generatedAt,
    bool? hasMoreIncidents,
    List<_isfr4fbx.TeamRoster>? teams,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentFeed',
      'organizationId': organizationId.toJson(),
      'incidents': incidents.toJson(valueToJson: (v) => v.toJson()),
      'activity': activity.toJson(valueToJson: (v) => v.toJson()),
      'generatedAt': generatedAt.toJson(),
      'hasMoreIncidents': hasMoreIncidents,
      if (teams != null) 'teams': teams?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentFeed',
      'organizationId': organizationId.toJson(),
      'incidents': incidents.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'activity': activity.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'generatedAt': generatedAt.toJson(),
      'hasMoreIncidents': hasMoreIncidents,
      if (teams != null)
        'teams': teams?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentFeedImpl extends IncidentFeed {
  _IncidentFeedImpl({
    required _is.UuidValue organizationId,
    required List<_iy4wsyyx.Incident> incidents,
    required List<_ilj9fez1.IncidentActivity> activity,
    required DateTime generatedAt,
    required bool hasMoreIncidents,
    List<_isfr4fbx.TeamRoster>? teams,
  }) : super._(
         organizationId: organizationId,
         incidents: incidents,
         activity: activity,
         generatedAt: generatedAt,
         hasMoreIncidents: hasMoreIncidents,
         teams: teams,
       );

  /// Returns a shallow copy of this [IncidentFeed]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IncidentFeed copyWith({
    _is.UuidValue? organizationId,
    List<_iy4wsyyx.Incident>? incidents,
    List<_ilj9fez1.IncidentActivity>? activity,
    DateTime? generatedAt,
    bool? hasMoreIncidents,
    Object? teams = _Undefined,
  }) {
    return IncidentFeed(
      organizationId: organizationId ?? this.organizationId,
      incidents:
          incidents ?? this.incidents.map((e0) => e0.copyWith()).toList(),
      activity: activity ?? this.activity.map((e0) => e0.copyWith()).toList(),
      generatedAt: generatedAt ?? this.generatedAt,
      hasMoreIncidents: hasMoreIncidents ?? this.hasMoreIncidents,
      teams: teams is List<_isfr4fbx.TeamRoster>?
          ? teams
          : this.teams?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
