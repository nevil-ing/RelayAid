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
import 'assignment.dart' as _iavo6snm;
import 'incident.dart' as _iy4wsyyx;

abstract class AssignmentSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AssignmentSummary._({
    required this.assignment,
    required this.incident,
    required this.teamName,
  });

  factory AssignmentSummary({
    required _iavo6snm.Assignment assignment,
    required _iy4wsyyx.Incident incident,
    required String teamName,
  }) = _AssignmentSummaryImpl;

  factory AssignmentSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssignmentSummary(
      assignment: _i24hraxo.Protocol().deserialize<_iavo6snm.Assignment>(
        jsonSerialization['assignment'],
      ),
      incident: _i24hraxo.Protocol().deserialize<_iy4wsyyx.Incident>(
        jsonSerialization['incident'],
      ),
      teamName: jsonSerialization['teamName'] as String,
    );
  }

  _iavo6snm.Assignment assignment;

  _iy4wsyyx.Incident incident;

  String teamName;

  /// Returns a shallow copy of this [AssignmentSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssignmentSummary copyWith({
    _iavo6snm.Assignment? assignment,
    _iy4wsyyx.Incident? incident,
    String? teamName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssignmentSummary',
      'assignment': assignment.toJson(),
      'incident': incident.toJson(),
      'teamName': teamName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssignmentSummary',
      'assignment': assignment.toJsonForProtocol(),
      'incident': incident.toJsonForProtocol(),
      'teamName': teamName,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AssignmentSummaryImpl extends AssignmentSummary {
  _AssignmentSummaryImpl({
    required _iavo6snm.Assignment assignment,
    required _iy4wsyyx.Incident incident,
    required String teamName,
  }) : super._(
         assignment: assignment,
         incident: incident,
         teamName: teamName,
       );

  /// Returns a shallow copy of this [AssignmentSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AssignmentSummary copyWith({
    _iavo6snm.Assignment? assignment,
    _iy4wsyyx.Incident? incident,
    String? teamName,
  }) {
    return AssignmentSummary(
      assignment: assignment ?? this.assignment.copyWith(),
      incident: incident ?? this.incident.copyWith(),
      teamName: teamName ?? this.teamName,
    );
  }
}
