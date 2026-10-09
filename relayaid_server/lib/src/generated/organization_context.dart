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
import 'organization.dart' as _irjtvpke;
import 'organization_member.dart' as _ium4dl39;

abstract class OrganizationContext
    implements _is.SerializableModel, _is.ProtocolSerialization {
  OrganizationContext._({
    required this.organization,
    required this.membership,
  });

  factory OrganizationContext({
    required _irjtvpke.Organization organization,
    required _ium4dl39.OrganizationMember membership,
  }) = _OrganizationContextImpl;

  factory OrganizationContext.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrganizationContext(
      organization: _i24hraxo.Protocol().deserialize<_irjtvpke.Organization>(
        jsonSerialization['organization'],
      ),
      membership: _i24hraxo.Protocol()
          .deserialize<_ium4dl39.OrganizationMember>(
            jsonSerialization['membership'],
          ),
    );
  }

  _irjtvpke.Organization organization;

  _ium4dl39.OrganizationMember membership;

  /// Returns a shallow copy of this [OrganizationContext]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OrganizationContext copyWith({
    _irjtvpke.Organization? organization,
    _ium4dl39.OrganizationMember? membership,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrganizationContext',
      'organization': organization.toJson(),
      'membership': membership.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrganizationContext',
      'organization': organization.toJsonForProtocol(),
      'membership': membership.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _OrganizationContextImpl extends OrganizationContext {
  _OrganizationContextImpl({
    required _irjtvpke.Organization organization,
    required _ium4dl39.OrganizationMember membership,
  }) : super._(
         organization: organization,
         membership: membership,
       );

  /// Returns a shallow copy of this [OrganizationContext]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OrganizationContext copyWith({
    _irjtvpke.Organization? organization,
    _ium4dl39.OrganizationMember? membership,
  }) {
    return OrganizationContext(
      organization: organization ?? this.organization.copyWith(),
      membership: membership ?? this.membership.copyWith(),
    );
  }
}
