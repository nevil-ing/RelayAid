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

abstract class Team
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Team._({
    this.id,
    required this.organizationId,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Team({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required String name,
    DateTime? createdAt,
  }) = _TeamImpl;

  factory Team.fromJson(Map<String, dynamic> jsonSerialization) {
    return Team(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      organizationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      name: jsonSerialization['name'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue organizationId;

  String name;

  DateTime createdAt;

  /// Returns a shallow copy of this [Team]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Team copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? organizationId,
    String? name,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Team',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Team',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamImpl extends Team {
  _TeamImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue organizationId,
    required String name,
    DateTime? createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Team]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Team copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? organizationId,
    String? name,
    DateTime? createdAt,
  }) {
    return Team(
      id: id is _isc.UuidValue? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
