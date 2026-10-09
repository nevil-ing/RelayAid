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
import 'dart:async' as _ida;
import 'dart:typed_data' as _idt;
import 'package:http/http.dart' as _i85jenna;
import 'package:relayaid_client/src/protocol/assignment_feed.dart' as _iiowq5b5;
import 'package:relayaid_client/src/protocol/incident.dart' as _ilbaqxu9;
import 'package:relayaid_client/src/protocol/incident_attachment.dart'
    as _iorx4rak;
import 'package:relayaid_client/src/protocol/incident_detail.dart' as _iwz4rozr;
import 'package:relayaid_client/src/protocol/incident_feed.dart' as _i2wplbfd;
import 'package:relayaid_client/src/protocol/incident_severity.dart'
    as _i5p54bkq;
import 'package:relayaid_client/src/protocol/incident_status.dart' as _igf7ngea;
import 'package:relayaid_client/src/protocol/incident_type.dart' as _i6xir1s8;
import 'package:relayaid_client/src/protocol/member_role.dart' as _iaxux3q6;
import 'package:relayaid_client/src/protocol/organization_context.dart'
    as _iuy5qbfb;
import 'package:relayaid_client/src/protocol/organization_member.dart'
    as _ickl1bji;
import 'package:relayaid_client/src/protocol/team.dart' as _iavwaank;
import 'package:relayaid_client/src/protocol/team_member.dart' as _iia4fa40;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// Makes Serverpod's email identity provider available to the typed client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// Enables automatic refresh of a persisted client session.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointAssignment extends _isc.EndpointRef {
  EndpointAssignment(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'assignment';

  _ida.Future<_iwz4rozr.IncidentDetail> assign(
    _isc.UuidValue incidentId,
    _isc.UuidValue teamId, {
    _isc.UuidValue? responderId,
  }) => caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
    'assignment',
    'assign',
    {
      'incidentId': incidentId,
      'teamId': teamId,
      'responderId': responderId,
    },
  );

  _ida.Stream<_iiowq5b5.AssignmentFeed> watch() =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iiowq5b5.AssignmentFeed>,
        _iiowq5b5.AssignmentFeed
      >(
        'assignment',
        'watch',
        {},
        {},
      );

  _ida.Future<_iwz4rozr.IncidentDetail> detail(_isc.UuidValue assignmentId) =>
      caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
        'assignment',
        'detail',
        {'assignmentId': assignmentId},
      );

  _ida.Future<_iwz4rozr.IncidentDetail> accept(_isc.UuidValue assignmentId) =>
      caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
        'assignment',
        'accept',
        {'assignmentId': assignmentId},
      );

  _ida.Future<_iwz4rozr.IncidentDetail> respond(_isc.UuidValue assignmentId) =>
      caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
        'assignment',
        'respond',
        {'assignmentId': assignmentId},
      );

  _ida.Future<_iwz4rozr.IncidentDetail> resolve(
    _isc.UuidValue assignmentId,
    String note,
  ) => caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
    'assignment',
    'resolve',
    {
      'assignmentId': assignmentId,
      'note': note,
    },
  );
}

/// Authenticated incident operations scoped to the caller's organization.
/// {@category Endpoint}
class EndpointIncident extends _isc.EndpointRef {
  EndpointIncident(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'incident';

  _ida.Future<_iwz4rozr.IncidentDetail> create({
    _isc.UuidValue? id,
    required _i6xir1s8.IncidentType type,
    required _i5p54bkq.IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) => caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
    'incident',
    'create',
    {
      'id': id,
      'type': type,
      'severity': severity,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'peopleAffected': peopleAffected,
    },
  );

  _ida.Future<List<_ilbaqxu9.Incident>> list({required int limit}) =>
      caller.callServerEndpoint<List<_ilbaqxu9.Incident>>(
        'incident',
        'list',
        {'limit': limit},
      );

  _ida.Future<_iwz4rozr.IncidentDetail> detail(_isc.UuidValue incidentId) =>
      caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
        'incident',
        'detail',
        {'incidentId': incidentId},
      );

  _ida.Future<_iwz4rozr.IncidentDetail> transition(
    _isc.UuidValue incidentId,
    _igf7ngea.IncidentStatus nextStatus, {
    String? note,
  }) => caller.callServerEndpoint<_iwz4rozr.IncidentDetail>(
    'incident',
    'transition',
    {
      'incidentId': incidentId,
      'nextStatus': nextStatus,
      'note': note,
    },
  );
}

/// The organization and role are resolved by the server, never the caller.
/// {@category Endpoint}
class EndpointIncidentFeed extends _isc.EndpointRef {
  EndpointIncidentFeed(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'incidentFeed';

  _ida.Stream<_i2wplbfd.IncidentFeed> watch() =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_i2wplbfd.IncidentFeed>,
        _i2wplbfd.IncidentFeed
      >(
        'incidentFeed',
        'watch',
        {},
        {},
      );
}

/// Evidence is private and authorized against its incident's organization.
/// {@category Endpoint}
class EndpointMedia extends _isc.EndpointRef {
  EndpointMedia(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'media';

  _ida.Future<String?> beginUpload(
    _isc.UuidValue incidentId,
    _isc.UuidValue attachmentId, {
    required String contentType,
    required int byteLength,
  }) => caller.callServerEndpoint<String?>(
    'media',
    'beginUpload',
    {
      'incidentId': incidentId,
      'attachmentId': attachmentId,
      'contentType': contentType,
      'byteLength': byteLength,
    },
  );

  _ida.Future<_iorx4rak.IncidentAttachment> completeUpload(
    _isc.UuidValue incidentId,
    _isc.UuidValue attachmentId,
  ) => caller.callServerEndpoint<_iorx4rak.IncidentAttachment>(
    'media',
    'completeUpload',
    {
      'incidentId': incidentId,
      'attachmentId': attachmentId,
    },
  );

  _ida.Future<List<_iorx4rak.IncidentAttachment>> list(
    _isc.UuidValue incidentId,
  ) => caller.callServerEndpoint<List<_iorx4rak.IncidentAttachment>>(
    'media',
    'list',
    {'incidentId': incidentId},
  );

  _ida.Future<_idt.ByteData> read(_isc.UuidValue attachmentId) =>
      caller.callServerEndpoint<_idt.ByteData>(
        'media',
        'read',
        {'attachmentId': attachmentId},
      );
}

/// Authenticated entry point for organization setup and team context.
/// {@category Endpoint}
class EndpointOrganization extends _isc.EndpointRef {
  EndpointOrganization(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'organization';

  _ida.Future<_iuy5qbfb.OrganizationContext?> myContext() =>
      caller.callServerEndpoint<_iuy5qbfb.OrganizationContext?>(
        'organization',
        'myContext',
        {},
      );

  _ida.Future<_iuy5qbfb.OrganizationContext> contextFor(
    _isc.UuidValue organizationId,
  ) => caller.callServerEndpoint<_iuy5qbfb.OrganizationContext>(
    'organization',
    'contextFor',
    {'organizationId': organizationId},
  );

  _ida.Future<_iuy5qbfb.OrganizationContext> create(String name) =>
      caller.callServerEndpoint<_iuy5qbfb.OrganizationContext>(
        'organization',
        'create',
        {'name': name},
      );

  _ida.Future<_ickl1bji.OrganizationMember> addMember(
    _isc.UuidValue organizationId,
    _isc.UuidValue authUserId,
    _iaxux3q6.MemberRole role,
  ) => caller.callServerEndpoint<_ickl1bji.OrganizationMember>(
    'organization',
    'addMember',
    {
      'organizationId': organizationId,
      'authUserId': authUserId,
      'role': role,
    },
  );

  _ida.Future<List<_ickl1bji.OrganizationMember>> listMembers(
    _isc.UuidValue organizationId,
  ) => caller.callServerEndpoint<List<_ickl1bji.OrganizationMember>>(
    'organization',
    'listMembers',
    {'organizationId': organizationId},
  );

  _ida.Future<_iavwaank.Team> createTeam(
    _isc.UuidValue organizationId,
    String name,
  ) => caller.callServerEndpoint<_iavwaank.Team>(
    'organization',
    'createTeam',
    {
      'organizationId': organizationId,
      'name': name,
    },
  );

  _ida.Future<List<_iavwaank.Team>> listTeams(_isc.UuidValue organizationId) =>
      caller.callServerEndpoint<List<_iavwaank.Team>>(
        'organization',
        'listTeams',
        {'organizationId': organizationId},
      );
}

/// {@category Endpoint}
class EndpointTeam extends _isc.EndpointRef {
  EndpointTeam(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'team';

  _ida.Future<_iia4fa40.TeamMember> addResponder(
    _isc.UuidValue teamId,
    _isc.UuidValue responderId,
  ) => caller.callServerEndpoint<_iia4fa40.TeamMember>(
    'team',
    'addResponder',
    {
      'teamId': teamId,
      'responderId': responderId,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    assignment = EndpointAssignment(this);
    incident = EndpointIncident(this);
    incidentFeed = EndpointIncidentFeed(this);
    media = EndpointMedia(this);
    organization = EndpointOrganization(this);
    team = EndpointTeam(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAssignment assignment;

  late final EndpointIncident incident;

  late final EndpointIncidentFeed incidentFeed;

  late final EndpointMedia media;

  late final EndpointOrganization organization;

  late final EndpointTeam team;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'assignment': assignment,
    'incident': incident,
    'incidentFeed': incidentFeed,
    'media': media,
    'organization': organization,
    'team': team,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
