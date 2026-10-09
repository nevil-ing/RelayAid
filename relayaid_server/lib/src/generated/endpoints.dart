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
import 'package:relayaid_server/src/generated/future_calls.dart' as _is0cy685;
import 'package:relayaid_server/src/generated/incident_severity.dart'
    as _ilwv5xh6;
import 'package:relayaid_server/src/generated/incident_status.dart'
    as _i032y1lr;
import 'package:relayaid_server/src/generated/incident_type.dart' as _izp3tdnz;
import 'package:relayaid_server/src/generated/member_role.dart' as _imw4oc2a;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/assignment_endpoint.dart' as _ikob4jr3;
import '../endpoints/incident_endpoint.dart' as _idvfe0v9;
import '../endpoints/incident_feed_endpoint.dart' as _izb43qdz;
import '../endpoints/media_endpoint.dart' as _iaymoujt;
import '../endpoints/organization_endpoint.dart' as _i8tughdc;
import '../endpoints/team_endpoint.dart' as _in25xvlb;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'assignment': _ikob4jr3.AssignmentEndpoint()
        ..initialize(
          server,
          'assignment',
          null,
        ),
      'incident': _idvfe0v9.IncidentEndpoint()
        ..initialize(
          server,
          'incident',
          null,
        ),
      'incidentFeed': _izb43qdz.IncidentFeedEndpoint()
        ..initialize(
          server,
          'incidentFeed',
          null,
        ),
      'media': _iaymoujt.MediaEndpoint()
        ..initialize(
          server,
          'media',
          null,
        ),
      'organization': _i8tughdc.OrganizationEndpoint()
        ..initialize(
          server,
          'organization',
          null,
        ),
      'team': _in25xvlb.TeamEndpoint()
        ..initialize(
          server,
          'team',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['assignment'] = _is.EndpointConnector(
      name: 'assignment',
      endpoint: endpoints['assignment']!,
      methodConnectors: {
        'assign': _is.MethodConnector(
          name: 'assign',
          params: {
            'incidentId': _is.ParameterDescription(
              name: 'incidentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'teamId': _is.ParameterDescription(
              name: 'teamId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['assignment'] as _ikob4jr3.AssignmentEndpoint)
                      .assign(
                        session,
                        params['incidentId'],
                        params['teamId'],
                        responderId: params['responderId'],
                      ),
        ),
        'detail': _is.MethodConnector(
          name: 'detail',
          params: {
            'assignmentId': _is.ParameterDescription(
              name: 'assignmentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['assignment'] as _ikob4jr3.AssignmentEndpoint)
                      .detail(
                        session,
                        params['assignmentId'],
                      ),
        ),
        'accept': _is.MethodConnector(
          name: 'accept',
          params: {
            'assignmentId': _is.ParameterDescription(
              name: 'assignmentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['assignment'] as _ikob4jr3.AssignmentEndpoint)
                      .accept(
                        session,
                        params['assignmentId'],
                      ),
        ),
        'respond': _is.MethodConnector(
          name: 'respond',
          params: {
            'assignmentId': _is.ParameterDescription(
              name: 'assignmentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['assignment'] as _ikob4jr3.AssignmentEndpoint)
                      .respond(
                        session,
                        params['assignmentId'],
                      ),
        ),
        'resolve': _is.MethodConnector(
          name: 'resolve',
          params: {
            'assignmentId': _is.ParameterDescription(
              name: 'assignmentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['assignment'] as _ikob4jr3.AssignmentEndpoint)
                      .resolve(
                        session,
                        params['assignmentId'],
                        params['note'],
                      ),
        ),
        'watch': _is.MethodStreamConnector(
          name: 'watch',
          params: {},
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['assignment'] as _ikob4jr3.AssignmentEndpoint)
                  .watch(session),
        ),
      },
    );
    connectors['incident'] = _is.EndpointConnector(
      name: 'incident',
      endpoint: endpoints['incident']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'type': _is.ParameterDescription(
              name: 'type',
              type: _is.getType<_izp3tdnz.IncidentType>(),
              nullable: false,
            ),
            'severity': _is.ParameterDescription(
              name: 'severity',
              type: _is.getType<_ilwv5xh6.IncidentSeverity>(),
              nullable: false,
            ),
            'title': _is.ParameterDescription(
              name: 'title',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'peopleAffected': _is.ParameterDescription(
              name: 'peopleAffected',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).create(
                    session,
                    id: params['id'],
                    type: params['type'],
                    severity: params['severity'],
                    title: params['title'],
                    description: params['description'],
                    latitude: params['latitude'],
                    longitude: params['longitude'],
                    peopleAffected: params['peopleAffected'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).list(
                    session,
                    limit: params['limit'],
                  ),
        ),
        'detail': _is.MethodConnector(
          name: 'detail',
          params: {
            'incidentId': _is.ParameterDescription(
              name: 'incidentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).detail(
                    session,
                    params['incidentId'],
                  ),
        ),
        'transition': _is.MethodConnector(
          name: 'transition',
          params: {
            'incidentId': _is.ParameterDescription(
              name: 'incidentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'nextStatus': _is.ParameterDescription(
              name: 'nextStatus',
              type: _is.getType<_i032y1lr.IncidentStatus>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['incident'] as _idvfe0v9.IncidentEndpoint)
                  .transition(
                    session,
                    params['incidentId'],
                    params['nextStatus'],
                    note: params['note'],
                  ),
        ),
      },
    );
    connectors['incidentFeed'] = _is.EndpointConnector(
      name: 'incidentFeed',
      endpoint: endpoints['incidentFeed']!,
      methodConnectors: {
        'watch': _is.MethodStreamConnector(
          name: 'watch',
          params: {},
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['incidentFeed'] as _izb43qdz.IncidentFeedEndpoint)
                  .watch(session),
        ),
      },
    );
    connectors['media'] = _is.EndpointConnector(
      name: 'media',
      endpoint: endpoints['media']!,
      methodConnectors: {
        'beginUpload': _is.MethodConnector(
          name: 'beginUpload',
          params: {
            'incidentId': _is.ParameterDescription(
              name: 'incidentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'attachmentId': _is.ParameterDescription(
              name: 'attachmentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'contentType': _is.ParameterDescription(
              name: 'contentType',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'byteLength': _is.ParameterDescription(
              name: 'byteLength',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['media'] as _iaymoujt.MediaEndpoint).beginUpload(
                    session,
                    params['incidentId'],
                    params['attachmentId'],
                    contentType: params['contentType'],
                    byteLength: params['byteLength'],
                  ),
        ),
        'completeUpload': _is.MethodConnector(
          name: 'completeUpload',
          params: {
            'incidentId': _is.ParameterDescription(
              name: 'incidentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'attachmentId': _is.ParameterDescription(
              name: 'attachmentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _iaymoujt.MediaEndpoint)
                  .completeUpload(
                    session,
                    params['incidentId'],
                    params['attachmentId'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'incidentId': _is.ParameterDescription(
              name: 'incidentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _iaymoujt.MediaEndpoint).list(
                session,
                params['incidentId'],
              ),
        ),
        'read': _is.MethodConnector(
          name: 'read',
          params: {
            'attachmentId': _is.ParameterDescription(
              name: 'attachmentId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _iaymoujt.MediaEndpoint).read(
                session,
                params['attachmentId'],
              ),
        ),
      },
    );
    connectors['organization'] = _is.EndpointConnector(
      name: 'organization',
      endpoint: endpoints['organization']!,
      methodConnectors: {
        'myContext': _is.MethodConnector(
          name: 'myContext',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['organization'] as _i8tughdc.OrganizationEndpoint)
                      .myContext(session),
        ),
        'contextFor': _is.MethodConnector(
          name: 'contextFor',
          params: {
            'organizationId': _is.ParameterDescription(
              name: 'organizationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['organization'] as _i8tughdc.OrganizationEndpoint)
                      .contextFor(
                        session,
                        params['organizationId'],
                      ),
        ),
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['organization'] as _i8tughdc.OrganizationEndpoint)
                      .create(
                        session,
                        params['name'],
                      ),
        ),
        'addMember': _is.MethodConnector(
          name: 'addMember',
          params: {
            'organizationId': _is.ParameterDescription(
              name: 'organizationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'authUserId': _is.ParameterDescription(
              name: 'authUserId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<_imw4oc2a.MemberRole>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['organization'] as _i8tughdc.OrganizationEndpoint)
                      .addMember(
                        session,
                        params['organizationId'],
                        params['authUserId'],
                        params['role'],
                      ),
        ),
        'listMembers': _is.MethodConnector(
          name: 'listMembers',
          params: {
            'organizationId': _is.ParameterDescription(
              name: 'organizationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['organization'] as _i8tughdc.OrganizationEndpoint)
                      .listMembers(
                        session,
                        params['organizationId'],
                      ),
        ),
        'createTeam': _is.MethodConnector(
          name: 'createTeam',
          params: {
            'organizationId': _is.ParameterDescription(
              name: 'organizationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['organization'] as _i8tughdc.OrganizationEndpoint)
                      .createTeam(
                        session,
                        params['organizationId'],
                        params['name'],
                      ),
        ),
        'listTeams': _is.MethodConnector(
          name: 'listTeams',
          params: {
            'organizationId': _is.ParameterDescription(
              name: 'organizationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['organization'] as _i8tughdc.OrganizationEndpoint)
                      .listTeams(
                        session,
                        params['organizationId'],
                      ),
        ),
      },
    );
    connectors['team'] = _is.EndpointConnector(
      name: 'team',
      endpoint: endpoints['team']!,
      methodConnectors: {
        'addResponder': _is.MethodConnector(
          name: 'addResponder',
          params: {
            'teamId': _is.ParameterDescription(
              name: 'teamId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['team'] as _in25xvlb.TeamEndpoint).addResponder(
                    session,
                    params['teamId'],
                    params['responderId'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _is0cy685.FutureCalls();
  }
}
