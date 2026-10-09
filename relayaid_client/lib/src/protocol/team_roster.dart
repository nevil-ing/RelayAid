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
import 'organization_member.dart' as _ium4dl39;
import 'team.dart' as _iigd95ic;

abstract class TeamRoster
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TeamRoster._({
    required this.team,
    required this.responders,
    required this.activeAssignments,
  });

  factory TeamRoster({
    required _iigd95ic.Team team,
    required List<_ium4dl39.OrganizationMember> responders,
    required int activeAssignments,
  }) = _TeamRosterImpl;

  factory TeamRoster.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamRoster(
      team: _i9l9a2dk.Protocol().deserialize<_iigd95ic.Team>(
        jsonSerialization['team'],
      ),
      responders: _i9l9a2dk.Protocol()
          .deserialize<List<_ium4dl39.OrganizationMember>>(
            jsonSerialization['responders'],
          ),
      activeAssignments: jsonSerialization['activeAssignments'] as int,
    );
  }

  _iigd95ic.Team team;

  List<_ium4dl39.OrganizationMember> responders;

  int activeAssignments;

  /// Returns a shallow copy of this [TeamRoster]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TeamRoster copyWith({
    _iigd95ic.Team? team,
    List<_ium4dl39.OrganizationMember>? responders,
    int? activeAssignments,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamRoster',
      'team': team.toJson(),
      'responders': responders.toJson(valueToJson: (v) => v.toJson()),
      'activeAssignments': activeAssignments,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamRoster',
      'team': team.toJsonForProtocol(),
      'responders': responders.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'activeAssignments': activeAssignments,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TeamRosterImpl extends TeamRoster {
  _TeamRosterImpl({
    required _iigd95ic.Team team,
    required List<_ium4dl39.OrganizationMember> responders,
    required int activeAssignments,
  }) : super._(
         team: team,
         responders: responders,
         activeAssignments: activeAssignments,
       );

  /// Returns a shallow copy of this [TeamRoster]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TeamRoster copyWith({
    _iigd95ic.Team? team,
    List<_ium4dl39.OrganizationMember>? responders,
    int? activeAssignments,
  }) {
    return TeamRoster(
      team: team ?? this.team.copyWith(),
      responders:
          responders ?? this.responders.map((e0) => e0.copyWith()).toList(),
      activeAssignments: activeAssignments ?? this.activeAssignments,
    );
  }
}
