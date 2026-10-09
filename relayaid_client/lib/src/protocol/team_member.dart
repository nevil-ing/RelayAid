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

abstract class TeamMember
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TeamMember._({
    this.id,
    required this.teamId,
    required this.authUserId,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory TeamMember({
    _isc.UuidValue? id,
    required _isc.UuidValue teamId,
    required _isc.UuidValue authUserId,
    DateTime? joinedAt,
  }) = _TeamMemberImpl;

  factory TeamMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamMember(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      teamId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue teamId;

  _isc.UuidValue authUserId;

  DateTime joinedAt;

  /// Returns a shallow copy of this [TeamMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TeamMember copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? teamId,
    _isc.UuidValue? authUserId,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamMember',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      'authUserId': authUserId.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamMember',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      'authUserId': authUserId.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamMemberImpl extends TeamMember {
  _TeamMemberImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue teamId,
    required _isc.UuidValue authUserId,
    DateTime? joinedAt,
  }) : super._(
         id: id,
         teamId: teamId,
         authUserId: authUserId,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [TeamMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TeamMember copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? teamId,
    _isc.UuidValue? authUserId,
    DateTime? joinedAt,
  }) {
    return TeamMember(
      id: id is _isc.UuidValue? ? id : this.id,
      teamId: teamId ?? this.teamId,
      authUserId: authUserId ?? this.authUserId,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
