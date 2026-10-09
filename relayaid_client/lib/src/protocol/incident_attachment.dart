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

abstract class IncidentAttachment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentAttachment._({
    this.id,
    required this.incidentId,
    required this.organizationId,
    required this.uploadedBy,
    required this.contentType,
    required this.byteLength,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory IncidentAttachment({
    _isc.UuidValue? id,
    required _isc.UuidValue incidentId,
    required _isc.UuidValue organizationId,
    required _isc.UuidValue uploadedBy,
    required String contentType,
    required int byteLength,
    DateTime? uploadedAt,
  }) = _IncidentAttachmentImpl;

  factory IncidentAttachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentAttachment(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      incidentId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['incidentId'],
      ),
      organizationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      uploadedBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['uploadedBy'],
      ),
      contentType: jsonSerialization['contentType'] as String,
      byteLength: jsonSerialization['byteLength'] as int,
      uploadedAt: jsonSerialization['uploadedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['uploadedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue incidentId;

  _isc.UuidValue organizationId;

  _isc.UuidValue uploadedBy;

  String contentType;

  int byteLength;

  DateTime uploadedAt;

  /// Returns a shallow copy of this [IncidentAttachment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentAttachment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? incidentId,
    _isc.UuidValue? organizationId,
    _isc.UuidValue? uploadedBy,
    String? contentType,
    int? byteLength,
    DateTime? uploadedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentAttachment',
      if (id != null) 'id': id?.toJson(),
      'incidentId': incidentId.toJson(),
      'organizationId': organizationId.toJson(),
      'uploadedBy': uploadedBy.toJson(),
      'contentType': contentType,
      'byteLength': byteLength,
      'uploadedAt': uploadedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentAttachment',
      if (id != null) 'id': id?.toJson(),
      'incidentId': incidentId.toJson(),
      'organizationId': organizationId.toJson(),
      'uploadedBy': uploadedBy.toJson(),
      'contentType': contentType,
      'byteLength': byteLength,
      'uploadedAt': uploadedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentAttachmentImpl extends IncidentAttachment {
  _IncidentAttachmentImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue incidentId,
    required _isc.UuidValue organizationId,
    required _isc.UuidValue uploadedBy,
    required String contentType,
    required int byteLength,
    DateTime? uploadedAt,
  }) : super._(
         id: id,
         incidentId: incidentId,
         organizationId: organizationId,
         uploadedBy: uploadedBy,
         contentType: contentType,
         byteLength: byteLength,
         uploadedAt: uploadedAt,
       );

  /// Returns a shallow copy of this [IncidentAttachment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentAttachment copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? incidentId,
    _isc.UuidValue? organizationId,
    _isc.UuidValue? uploadedBy,
    String? contentType,
    int? byteLength,
    DateTime? uploadedAt,
  }) {
    return IncidentAttachment(
      id: id is _isc.UuidValue? ? id : this.id,
      incidentId: incidentId ?? this.incidentId,
      organizationId: organizationId ?? this.organizationId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      contentType: contentType ?? this.contentType,
      byteLength: byteLength ?? this.byteLength,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
