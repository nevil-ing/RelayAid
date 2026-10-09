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

abstract class AttachmentValidationException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  AttachmentValidationException._({required this.message});

  factory AttachmentValidationException({required String message}) =
      _AttachmentValidationExceptionImpl;

  factory AttachmentValidationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AttachmentValidationException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [AttachmentValidationException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AttachmentValidationException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AttachmentValidationException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AttachmentValidationException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AttachmentValidationException(message: $message)';
  }
}

class _AttachmentValidationExceptionImpl extends AttachmentValidationException {
  _AttachmentValidationExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [AttachmentValidationException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AttachmentValidationException copyWith({String? message}) {
    return AttachmentValidationException(message: message ?? this.message);
  }
}
