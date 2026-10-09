/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:relayaid_server/src/generated/incident.dart' as _i8w32a3w;
import 'package:relayaid_server/src/generated/incident_attachment.dart'
    as _ibvuuheb;
import 'package:relayaid_server/src/generated/organization_member.dart'
    as _irhwqovi;
import 'package:relayaid_server/src/generated/team.dart' as _iohg9vjr;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'assignment.dart' as _iavo6snm;
import 'assignment_feed.dart' as _it799hd1;
import 'assignment_status.dart' as _ikrvejjw;
import 'assignment_summary.dart' as _iufioc3f;
import 'attachment_validation_exception.dart' as _i5iovmxh;
import 'authorization_exception.dart' as _i4eo0p61;
import 'incident.dart' as _iy4wsyyx;
import 'incident_activity.dart' as _ilj9fez1;
import 'incident_attachment.dart' as _ip5i6jz3;
import 'incident_detail.dart' as _i99u8ngz;
import 'incident_event.dart' as _icglyrab;
import 'incident_event_type.dart' as _ic7pik0n;
import 'incident_feed.dart' as _i96ngj69;
import 'incident_severity.dart' as _ifp7jacs;
import 'incident_status.dart' as _ikduxsi0;
import 'incident_type.dart' as _i3tf8ajh;
import 'incident_validation_exception.dart' as _ilooz8p8;
import 'member_role.dart' as _insyygng;
import 'organization.dart' as _irjtvpke;
import 'organization_context.dart' as _i3ki8j83;
import 'organization_member.dart' as _ium4dl39;
import 'team.dart' as _iigd95ic;
import 'team_member.dart' as _ivu48j77;
import 'team_roster.dart' as _isfr4fbx;
export 'assignment.dart';
export 'assignment_feed.dart';
export 'assignment_status.dart';
export 'assignment_summary.dart';
export 'attachment_validation_exception.dart';
export 'authorization_exception.dart';
export 'incident.dart';
export 'incident_activity.dart';
export 'incident_attachment.dart';
export 'incident_detail.dart';
export 'incident_event.dart';
export 'incident_event_type.dart';
export 'incident_feed.dart';
export 'incident_severity.dart';
export 'incident_status.dart';
export 'incident_type.dart';
export 'incident_validation_exception.dart';
export 'member_role.dart';
export 'organization.dart';
export 'organization_context.dart';
export 'organization_member.dart';
export 'team.dart';
export 'team_member.dart';
export 'team_roster.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'relay_assignment',
      dartName: 'Assignment',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'organizationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'incidentId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'teamId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'designatedResponderId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'assignedBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'acceptedBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AssignmentStatus',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'acceptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'respondingAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'resolvedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'cancelledAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'assignment_incident_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'incidentId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'assignment_organization_team',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'teamId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'relay_incident',
      dartName: 'Incident',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'organizationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:IncidentType',
        ),
        _isp.ColumnDefinition(
          name: 'severity',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:IncidentSeverity',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:IncidentStatus',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'peopleAffected',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'reportedBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'reportedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'escalationDueAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'escalatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'relay_incident_organization_updated',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'updatedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'relay_incident_organization_status',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'relay_incident_escalation_due',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'severity',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'escalationDueAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'relay_incident_attachment',
      dartName: 'IncidentAttachment',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'incidentId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'organizationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'uploadedBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'contentType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'byteLength',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'storagePath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'uploadedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'relay_attachment_incident_uploaded',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'incidentId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'uploadedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'relay_incident_event',
      dartName: 'IncidentEvent',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'incidentId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'organizationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'eventType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:IncidentEventType',
        ),
        _isp.ColumnDefinition(
          name: 'actorId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'assignmentId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'fromStatus',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:IncidentStatus?',
        ),
        _isp.ColumnDefinition(
          name: 'toStatus',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:IncidentStatus?',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'relay_incident_event_incident_created',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'incidentId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'relay_organization',
      dartName: 'Organization',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'relay_organization_member',
      dartName: 'OrganizationMember',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'organizationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MemberRole',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'relay_member_user_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'relay_member_organization',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'relay_team',
      dartName: 'Team',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'organizationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'relay_team_org_name_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'relay_team_member',
      dartName: 'TeamMember',
      schema: 'public',
      module: 'relayaid',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'teamId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'relay_team_member_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'teamId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iavo6snm.Assignment) {
      return _iavo6snm.Assignment.fromJson(data) as T;
    }
    if (t == _it799hd1.AssignmentFeed) {
      return _it799hd1.AssignmentFeed.fromJson(data) as T;
    }
    if (t == _ikrvejjw.AssignmentStatus) {
      return _ikrvejjw.AssignmentStatus.fromJson(data) as T;
    }
    if (t == _iufioc3f.AssignmentSummary) {
      return _iufioc3f.AssignmentSummary.fromJson(data) as T;
    }
    if (t == _i5iovmxh.AttachmentValidationException) {
      return _i5iovmxh.AttachmentValidationException.fromJson(data) as T;
    }
    if (t == _i4eo0p61.AuthorizationException) {
      return _i4eo0p61.AuthorizationException.fromJson(data) as T;
    }
    if (t == _iy4wsyyx.Incident) {
      return _iy4wsyyx.Incident.fromJson(data) as T;
    }
    if (t == _ilj9fez1.IncidentActivity) {
      return _ilj9fez1.IncidentActivity.fromJson(data) as T;
    }
    if (t == _ip5i6jz3.IncidentAttachment) {
      return _ip5i6jz3.IncidentAttachment.fromJson(data) as T;
    }
    if (t == _i99u8ngz.IncidentDetail) {
      return _i99u8ngz.IncidentDetail.fromJson(data) as T;
    }
    if (t == _icglyrab.IncidentEvent) {
      return _icglyrab.IncidentEvent.fromJson(data) as T;
    }
    if (t == _ic7pik0n.IncidentEventType) {
      return _ic7pik0n.IncidentEventType.fromJson(data) as T;
    }
    if (t == _i96ngj69.IncidentFeed) {
      return _i96ngj69.IncidentFeed.fromJson(data) as T;
    }
    if (t == _ifp7jacs.IncidentSeverity) {
      return _ifp7jacs.IncidentSeverity.fromJson(data) as T;
    }
    if (t == _ikduxsi0.IncidentStatus) {
      return _ikduxsi0.IncidentStatus.fromJson(data) as T;
    }
    if (t == _i3tf8ajh.IncidentType) {
      return _i3tf8ajh.IncidentType.fromJson(data) as T;
    }
    if (t == _ilooz8p8.IncidentValidationException) {
      return _ilooz8p8.IncidentValidationException.fromJson(data) as T;
    }
    if (t == _insyygng.MemberRole) {
      return _insyygng.MemberRole.fromJson(data) as T;
    }
    if (t == _irjtvpke.Organization) {
      return _irjtvpke.Organization.fromJson(data) as T;
    }
    if (t == _i3ki8j83.OrganizationContext) {
      return _i3ki8j83.OrganizationContext.fromJson(data) as T;
    }
    if (t == _ium4dl39.OrganizationMember) {
      return _ium4dl39.OrganizationMember.fromJson(data) as T;
    }
    if (t == _iigd95ic.Team) {
      return _iigd95ic.Team.fromJson(data) as T;
    }
    if (t == _ivu48j77.TeamMember) {
      return _ivu48j77.TeamMember.fromJson(data) as T;
    }
    if (t == _isfr4fbx.TeamRoster) {
      return _isfr4fbx.TeamRoster.fromJson(data) as T;
    }
    if (t == _is.getType<_iavo6snm.Assignment?>()) {
      return (data != null ? _iavo6snm.Assignment.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_it799hd1.AssignmentFeed?>()) {
      return (data != null ? _it799hd1.AssignmentFeed.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikrvejjw.AssignmentStatus?>()) {
      return (data != null ? _ikrvejjw.AssignmentStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iufioc3f.AssignmentSummary?>()) {
      return (data != null ? _iufioc3f.AssignmentSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i5iovmxh.AttachmentValidationException?>()) {
      return (data != null
              ? _i5iovmxh.AttachmentValidationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i4eo0p61.AuthorizationException?>()) {
      return (data != null
              ? _i4eo0p61.AuthorizationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iy4wsyyx.Incident?>()) {
      return (data != null ? _iy4wsyyx.Incident.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilj9fez1.IncidentActivity?>()) {
      return (data != null ? _ilj9fez1.IncidentActivity.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ip5i6jz3.IncidentAttachment?>()) {
      return (data != null ? _ip5i6jz3.IncidentAttachment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i99u8ngz.IncidentDetail?>()) {
      return (data != null ? _i99u8ngz.IncidentDetail.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icglyrab.IncidentEvent?>()) {
      return (data != null ? _icglyrab.IncidentEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ic7pik0n.IncidentEventType?>()) {
      return (data != null ? _ic7pik0n.IncidentEventType.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i96ngj69.IncidentFeed?>()) {
      return (data != null ? _i96ngj69.IncidentFeed.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifp7jacs.IncidentSeverity?>()) {
      return (data != null ? _ifp7jacs.IncidentSeverity.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikduxsi0.IncidentStatus?>()) {
      return (data != null ? _ikduxsi0.IncidentStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3tf8ajh.IncidentType?>()) {
      return (data != null ? _i3tf8ajh.IncidentType.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilooz8p8.IncidentValidationException?>()) {
      return (data != null
              ? _ilooz8p8.IncidentValidationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_insyygng.MemberRole?>()) {
      return (data != null ? _insyygng.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_irjtvpke.Organization?>()) {
      return (data != null ? _irjtvpke.Organization.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3ki8j83.OrganizationContext?>()) {
      return (data != null
              ? _i3ki8j83.OrganizationContext.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ium4dl39.OrganizationMember?>()) {
      return (data != null ? _ium4dl39.OrganizationMember.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iigd95ic.Team?>()) {
      return (data != null ? _iigd95ic.Team.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ivu48j77.TeamMember?>()) {
      return (data != null ? _ivu48j77.TeamMember.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_isfr4fbx.TeamRoster?>()) {
      return (data != null ? _isfr4fbx.TeamRoster.fromJson(data) : null) as T;
    }
    if (t == List<_iufioc3f.AssignmentSummary>) {
      return (data as List)
              .map((e) => deserialize<_iufioc3f.AssignmentSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_icglyrab.IncidentEvent>) {
      return (data as List)
              .map((e) => deserialize<_icglyrab.IncidentEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_iy4wsyyx.Incident>) {
      return (data as List)
              .map((e) => deserialize<_iy4wsyyx.Incident>(e))
              .toList()
          as T;
    }
    if (t == List<_ilj9fez1.IncidentActivity>) {
      return (data as List)
              .map((e) => deserialize<_ilj9fez1.IncidentActivity>(e))
              .toList()
          as T;
    }
    if (t == List<_isfr4fbx.TeamRoster>) {
      return (data as List)
              .map((e) => deserialize<_isfr4fbx.TeamRoster>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_isfr4fbx.TeamRoster>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_isfr4fbx.TeamRoster>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ium4dl39.OrganizationMember>) {
      return (data as List)
              .map((e) => deserialize<_ium4dl39.OrganizationMember>(e))
              .toList()
          as T;
    }
    if (t == List<_i8w32a3w.Incident>) {
      return (data as List)
              .map((e) => deserialize<_i8w32a3w.Incident>(e))
              .toList()
          as T;
    }
    if (t == List<_ibvuuheb.IncidentAttachment>) {
      return (data as List)
              .map((e) => deserialize<_ibvuuheb.IncidentAttachment>(e))
              .toList()
          as T;
    }
    if (t == List<_irhwqovi.OrganizationMember>) {
      return (data as List)
              .map((e) => deserialize<_irhwqovi.OrganizationMember>(e))
              .toList()
          as T;
    }
    if (t == List<_iohg9vjr.Team>) {
      return (data as List).map((e) => deserialize<_iohg9vjr.Team>(e)).toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iavo6snm.Assignment => 'Assignment',
      _it799hd1.AssignmentFeed => 'AssignmentFeed',
      _ikrvejjw.AssignmentStatus => 'AssignmentStatus',
      _iufioc3f.AssignmentSummary => 'AssignmentSummary',
      _i5iovmxh.AttachmentValidationException =>
        'AttachmentValidationException',
      _i4eo0p61.AuthorizationException => 'AuthorizationException',
      _iy4wsyyx.Incident => 'Incident',
      _ilj9fez1.IncidentActivity => 'IncidentActivity',
      _ip5i6jz3.IncidentAttachment => 'IncidentAttachment',
      _i99u8ngz.IncidentDetail => 'IncidentDetail',
      _icglyrab.IncidentEvent => 'IncidentEvent',
      _ic7pik0n.IncidentEventType => 'IncidentEventType',
      _i96ngj69.IncidentFeed => 'IncidentFeed',
      _ifp7jacs.IncidentSeverity => 'IncidentSeverity',
      _ikduxsi0.IncidentStatus => 'IncidentStatus',
      _i3tf8ajh.IncidentType => 'IncidentType',
      _ilooz8p8.IncidentValidationException => 'IncidentValidationException',
      _insyygng.MemberRole => 'MemberRole',
      _irjtvpke.Organization => 'Organization',
      _i3ki8j83.OrganizationContext => 'OrganizationContext',
      _ium4dl39.OrganizationMember => 'OrganizationMember',
      _iigd95ic.Team => 'Team',
      _ivu48j77.TeamMember => 'TeamMember',
      _isfr4fbx.TeamRoster => 'TeamRoster',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('relayaid.', '');
    }

    switch (data) {
      case _iavo6snm.Assignment():
        return 'Assignment';
      case _it799hd1.AssignmentFeed():
        return 'AssignmentFeed';
      case _ikrvejjw.AssignmentStatus():
        return 'AssignmentStatus';
      case _iufioc3f.AssignmentSummary():
        return 'AssignmentSummary';
      case _i5iovmxh.AttachmentValidationException():
        return 'AttachmentValidationException';
      case _i4eo0p61.AuthorizationException():
        return 'AuthorizationException';
      case _iy4wsyyx.Incident():
        return 'Incident';
      case _ilj9fez1.IncidentActivity():
        return 'IncidentActivity';
      case _ip5i6jz3.IncidentAttachment():
        return 'IncidentAttachment';
      case _i99u8ngz.IncidentDetail():
        return 'IncidentDetail';
      case _icglyrab.IncidentEvent():
        return 'IncidentEvent';
      case _ic7pik0n.IncidentEventType():
        return 'IncidentEventType';
      case _i96ngj69.IncidentFeed():
        return 'IncidentFeed';
      case _ifp7jacs.IncidentSeverity():
        return 'IncidentSeverity';
      case _ikduxsi0.IncidentStatus():
        return 'IncidentStatus';
      case _i3tf8ajh.IncidentType():
        return 'IncidentType';
      case _ilooz8p8.IncidentValidationException():
        return 'IncidentValidationException';
      case _insyygng.MemberRole():
        return 'MemberRole';
      case _irjtvpke.Organization():
        return 'Organization';
      case _i3ki8j83.OrganizationContext():
        return 'OrganizationContext';
      case _ium4dl39.OrganizationMember():
        return 'OrganizationMember';
      case _iigd95ic.Team():
        return 'Team';
      case _ivu48j77.TeamMember():
        return 'TeamMember';
      case _isfr4fbx.TeamRoster():
        return 'TeamRoster';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Assignment') {
      return deserialize<_iavo6snm.Assignment>(data['data']);
    }
    if (dataClassName == 'AssignmentFeed') {
      return deserialize<_it799hd1.AssignmentFeed>(data['data']);
    }
    if (dataClassName == 'AssignmentStatus') {
      return deserialize<_ikrvejjw.AssignmentStatus>(data['data']);
    }
    if (dataClassName == 'AssignmentSummary') {
      return deserialize<_iufioc3f.AssignmentSummary>(data['data']);
    }
    if (dataClassName == 'AttachmentValidationException') {
      return deserialize<_i5iovmxh.AttachmentValidationException>(data['data']);
    }
    if (dataClassName == 'AuthorizationException') {
      return deserialize<_i4eo0p61.AuthorizationException>(data['data']);
    }
    if (dataClassName == 'Incident') {
      return deserialize<_iy4wsyyx.Incident>(data['data']);
    }
    if (dataClassName == 'IncidentActivity') {
      return deserialize<_ilj9fez1.IncidentActivity>(data['data']);
    }
    if (dataClassName == 'IncidentAttachment') {
      return deserialize<_ip5i6jz3.IncidentAttachment>(data['data']);
    }
    if (dataClassName == 'IncidentDetail') {
      return deserialize<_i99u8ngz.IncidentDetail>(data['data']);
    }
    if (dataClassName == 'IncidentEvent') {
      return deserialize<_icglyrab.IncidentEvent>(data['data']);
    }
    if (dataClassName == 'IncidentEventType') {
      return deserialize<_ic7pik0n.IncidentEventType>(data['data']);
    }
    if (dataClassName == 'IncidentFeed') {
      return deserialize<_i96ngj69.IncidentFeed>(data['data']);
    }
    if (dataClassName == 'IncidentSeverity') {
      return deserialize<_ifp7jacs.IncidentSeverity>(data['data']);
    }
    if (dataClassName == 'IncidentStatus') {
      return deserialize<_ikduxsi0.IncidentStatus>(data['data']);
    }
    if (dataClassName == 'IncidentType') {
      return deserialize<_i3tf8ajh.IncidentType>(data['data']);
    }
    if (dataClassName == 'IncidentValidationException') {
      return deserialize<_ilooz8p8.IncidentValidationException>(data['data']);
    }
    if (dataClassName == 'MemberRole') {
      return deserialize<_insyygng.MemberRole>(data['data']);
    }
    if (dataClassName == 'Organization') {
      return deserialize<_irjtvpke.Organization>(data['data']);
    }
    if (dataClassName == 'OrganizationContext') {
      return deserialize<_i3ki8j83.OrganizationContext>(data['data']);
    }
    if (dataClassName == 'OrganizationMember') {
      return deserialize<_ium4dl39.OrganizationMember>(data['data']);
    }
    if (dataClassName == 'Team') {
      return deserialize<_iigd95ic.Team>(data['data']);
    }
    if (dataClassName == 'TeamMember') {
      return deserialize<_ivu48j77.TeamMember>(data['data']);
    }
    if (dataClassName == 'TeamRoster') {
      return deserialize<_isfr4fbx.TeamRoster>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('relayaid', this);
    _iacs.Protocol().registerHostProtocol('relayaid', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iavo6snm.Assignment:
        return _iavo6snm.Assignment.t;
      case _iy4wsyyx.Incident:
        return _iy4wsyyx.Incident.t;
      case _ip5i6jz3.IncidentAttachment:
        return _ip5i6jz3.IncidentAttachment.t;
      case _icglyrab.IncidentEvent:
        return _icglyrab.IncidentEvent.t;
      case _irjtvpke.Organization:
        return _irjtvpke.Organization.t;
      case _ium4dl39.OrganizationMember:
        return _ium4dl39.OrganizationMember.t;
      case _iigd95ic.Team:
        return _iigd95ic.Team.t;
      case _ivu48j77.TeamMember:
        return _ivu48j77.TeamMember.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'relayaid';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
