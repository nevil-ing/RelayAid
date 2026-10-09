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
import 'assignment_summary.dart' as _iufioc3f;

abstract class AssignmentFeed
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AssignmentFeed._({
    required this.organizationId,
    required this.authUserId,
    required this.assignments,
    required this.generatedAt,
    required this.hasMoreAssignments,
  });

  factory AssignmentFeed({
    required _isc.UuidValue organizationId,
    required _isc.UuidValue authUserId,
    required List<_iufioc3f.AssignmentSummary> assignments,
    required DateTime generatedAt,
    required bool hasMoreAssignments,
  }) = _AssignmentFeedImpl;

  factory AssignmentFeed.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssignmentFeed(
      organizationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      assignments: _i9l9a2dk.Protocol()
          .deserialize<List<_iufioc3f.AssignmentSummary>>(
            jsonSerialization['assignments'],
          ),
      generatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
      hasMoreAssignments: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasMoreAssignments'],
      ),
    );
  }

  _isc.UuidValue organizationId;

  _isc.UuidValue authUserId;

  List<_iufioc3f.AssignmentSummary> assignments;

  DateTime generatedAt;

  bool hasMoreAssignments;

  /// Returns a shallow copy of this [AssignmentFeed]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AssignmentFeed copyWith({
    _isc.UuidValue? organizationId,
    _isc.UuidValue? authUserId,
    List<_iufioc3f.AssignmentSummary>? assignments,
    DateTime? generatedAt,
    bool? hasMoreAssignments,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssignmentFeed',
      'organizationId': organizationId.toJson(),
      'authUserId': authUserId.toJson(),
      'assignments': assignments.toJson(valueToJson: (v) => v.toJson()),
      'generatedAt': generatedAt.toJson(),
      'hasMoreAssignments': hasMoreAssignments,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssignmentFeed',
      'organizationId': organizationId.toJson(),
      'authUserId': authUserId.toJson(),
      'assignments': assignments.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'generatedAt': generatedAt.toJson(),
      'hasMoreAssignments': hasMoreAssignments,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AssignmentFeedImpl extends AssignmentFeed {
  _AssignmentFeedImpl({
    required _isc.UuidValue organizationId,
    required _isc.UuidValue authUserId,
    required List<_iufioc3f.AssignmentSummary> assignments,
    required DateTime generatedAt,
    required bool hasMoreAssignments,
  }) : super._(
         organizationId: organizationId,
         authUserId: authUserId,
         assignments: assignments,
         generatedAt: generatedAt,
         hasMoreAssignments: hasMoreAssignments,
       );

  /// Returns a shallow copy of this [AssignmentFeed]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AssignmentFeed copyWith({
    _isc.UuidValue? organizationId,
    _isc.UuidValue? authUserId,
    List<_iufioc3f.AssignmentSummary>? assignments,
    DateTime? generatedAt,
    bool? hasMoreAssignments,
  }) {
    return AssignmentFeed(
      organizationId: organizationId ?? this.organizationId,
      authUserId: authUserId ?? this.authUserId,
      assignments:
          assignments ?? this.assignments.map((e0) => e0.copyWith()).toList(),
      generatedAt: generatedAt ?? this.generatedAt,
      hasMoreAssignments: hasMoreAssignments ?? this.hasMoreAssignments,
    );
  }
}
