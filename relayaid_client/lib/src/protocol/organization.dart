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

abstract class Organization
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Organization._({
    this.id,
    required this.name,
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Organization({
    _isc.UuidValue? id,
    required String name,
    required _isc.UuidValue createdBy,
    DateTime? createdAt,
  }) = _OrganizationImpl;

  factory Organization.fromJson(Map<String, dynamic> jsonSerialization) {
    return Organization(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      createdBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdBy'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String name;

  _isc.UuidValue createdBy;

  DateTime createdAt;

  /// Returns a shallow copy of this [Organization]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Organization copyWith({
    _isc.UuidValue? id,
    String? name,
    _isc.UuidValue? createdBy,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Organization',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Organization',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrganizationImpl extends Organization {
  _OrganizationImpl({
    _isc.UuidValue? id,
    required String name,
    required _isc.UuidValue createdBy,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         createdBy: createdBy,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Organization]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Organization copyWith({
    Object? id = _Undefined,
    String? name,
    _isc.UuidValue? createdBy,
    DateTime? createdAt,
  }) {
    return Organization(
      id: id is _isc.UuidValue? ? id : this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
