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
import 'member_role.dart' as _insyygng;

abstract class OrganizationMember
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  OrganizationMember._({
    this.id,
    required this.organizationId,
    required this.authUserId,
    required this.role,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory OrganizationMember({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required _isc.UuidValue authUserId,
    required _insyygng.MemberRole role,
    DateTime? joinedAt,
  }) = _OrganizationMemberImpl;

  factory OrganizationMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrganizationMember(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      organizationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      role: _insyygng.MemberRole.fromJson(
        (jsonSerialization['role'] as String),
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

  _isc.UuidValue organizationId;

  _isc.UuidValue authUserId;

  _insyygng.MemberRole role;

  DateTime joinedAt;

  /// Returns a shallow copy of this [OrganizationMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  OrganizationMember copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? organizationId,
    _isc.UuidValue? authUserId,
    _insyygng.MemberRole? role,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrganizationMember',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrganizationMember',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrganizationMemberImpl extends OrganizationMember {
  _OrganizationMemberImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required _isc.UuidValue authUserId,
    required _insyygng.MemberRole role,
    DateTime? joinedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         authUserId: authUserId,
         role: role,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [OrganizationMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  OrganizationMember copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? organizationId,
    _isc.UuidValue? authUserId,
    _insyygng.MemberRole? role,
    DateTime? joinedAt,
  }) {
    return OrganizationMember(
      id: id is _isc.UuidValue? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      authUserId: authUserId ?? this.authUserId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
