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
import 'incident_event.dart' as _icglyrab;

abstract class IncidentActivity
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentActivity._({
    required this.event,
    required this.incidentTitle,
  });

  factory IncidentActivity({
    required _icglyrab.IncidentEvent event,
    required String incidentTitle,
  }) = _IncidentActivityImpl;

  factory IncidentActivity.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentActivity(
      event: _i9l9a2dk.Protocol().deserialize<_icglyrab.IncidentEvent>(
        jsonSerialization['event'],
      ),
      incidentTitle: jsonSerialization['incidentTitle'] as String,
    );
  }

  _icglyrab.IncidentEvent event;

  String incidentTitle;

  /// Returns a shallow copy of this [IncidentActivity]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentActivity copyWith({
    _icglyrab.IncidentEvent? event,
    String? incidentTitle,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentActivity',
      'event': event.toJson(),
      'incidentTitle': incidentTitle,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentActivity',
      'event': event.toJsonForProtocol(),
      'incidentTitle': incidentTitle,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _IncidentActivityImpl extends IncidentActivity {
  _IncidentActivityImpl({
    required _icglyrab.IncidentEvent event,
    required String incidentTitle,
  }) : super._(
         event: event,
         incidentTitle: incidentTitle,
       );

  /// Returns a shallow copy of this [IncidentActivity]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentActivity copyWith({
    _icglyrab.IncidentEvent? event,
    String? incidentTitle,
  }) {
    return IncidentActivity(
      event: event ?? this.event.copyWith(),
      incidentTitle: incidentTitle ?? this.incidentTitle,
    );
  }
}
