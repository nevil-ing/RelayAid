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

enum IncidentType implements _isc.SerializableModel {
  flooding,
  fire,
  medical,
  infrastructure,
  supplyShortage,
  displacement,
  security,
  other;

  static IncidentType fromJson(String name) {
    switch (name) {
      case 'flooding':
        return IncidentType.flooding;
      case 'fire':
        return IncidentType.fire;
      case 'medical':
        return IncidentType.medical;
      case 'infrastructure':
        return IncidentType.infrastructure;
      case 'supplyShortage':
        return IncidentType.supplyShortage;
      case 'displacement':
        return IncidentType.displacement;
      case 'security':
        return IncidentType.security;
      case 'other':
        return IncidentType.other;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "IncidentType"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
