import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../features/auth/application/access_controller.dart';
import '../../features/auth/presentation/access_unavailable_page.dart';
import '../../features/auth/presentation/organization_setup_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/command_center/presentation/command_center_page.dart';
import '../../features/assignments/presentation/assignment_inbox_page.dart';
import '../../features/teams/presentation/teams_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/sync/presentation/sync_center_page.dart';
import '../../features/incidents/presentation/incident_detail_page.dart';
import '../../features/incidents/presentation/incident_list_page.dart';
import '../../features/reporting/presentation/report_incident_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/map/presentation/field_map_page.dart';
import '../../features/teams/presentation/organization_settings_page.dart';
import '../../shared/presentation/app_placeholder_page.dart';
import '../shells/command_center_shell.dart';
import '../shells/entry_shell.dart';
import '../shells/field_worker_shell.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String organizationSetup = '/organization/setup';
  static const String accessUnavailable = '/access-unavailable';
  static const String loading = '/loading';
  static const String home = '/home';
  static const String incidents = '/incidents';
  static const String incidentDetail = '/incidents/preview';
  static const String report = '/report';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String syncCenter = '/sync';
  static const String overview = '/overview';
  static const String teams = '/teams';
  static const String activity = '/activity';
  static const String settings = '/settings';
}

GoRouter buildAppRouter(AccessController access) {
  const entryPaths = <String>{
    AppRoutes.onboarding,
    AppRoutes.signIn,
    AppRoutes.organizationSetup,
    AppRoutes.accessUnavailable,
    AppRoutes.loading,
  };
  const coordinatorPaths = <String>{
    AppRoutes.overview,
    AppRoutes.teams,
    AppRoutes.activity,
    AppRoutes.settings,
  };
  const fieldPaths = <String>{
    AppRoutes.home,
    AppRoutes.report,
    AppRoutes.profile,
    AppRoutes.syncCenter,
  };

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: access,
    redirect: (context, state) {
      final path = state.uri.path;
      switch (access.status) {
        case AccessStatus.loading:
          return path == AppRoutes.loading ? null : AppRoutes.loading;
        case AccessStatus.signedOut:
          return path == AppRoutes.signIn ? null : AppRoutes.signIn;
        case AccessStatus.needsOrganization:
          return path == AppRoutes.organizationSetup
              ? null
              : AppRoutes.organizationSetup;
        case AccessStatus.unavailable:
          return path == AppRoutes.accessUnavailable
              ? null
              : AppRoutes.accessUnavailable;
        case AccessStatus.ready:
          final defaultPath = access.isCoordinator
              ? AppRoutes.overview
              : AppRoutes.home;
          if (entryPaths.contains(path)) return defaultPath;
          if (access.isCoordinator && fieldPaths.contains(path)) {
            return defaultPath;
          }
          if (!access.isCoordinator && coordinatorPaths.contains(path)) {
            return defaultPath;
          }
          return null;
      }
    },
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) {
          final path = state.uri.path;
          if (entryPaths.contains(path)) return EntryShell(child: child);
          if (access.isCoordinator) {
            return CommandCenterShell(currentPath: path, child: child);
          }
          return FieldWorkerShell(currentPath: path, child: child);
        },
        routes: <RouteBase>[
          _route(
            AppRoutes.onboarding,
            'Welcome',
            'RelayAid starts with a secure organization workspace.',
            Icons.volunteer_activism_outlined,
          ),
          GoRoute(
            path: AppRoutes.signIn,
            builder: (context, state) => const SignInPage(),
          ),
          GoRoute(
            path: AppRoutes.organizationSetup,
            builder: (context, state) => const OrganizationSetupPage(),
          ),
          GoRoute(
            path: AppRoutes.accessUnavailable,
            builder: (context, state) => const AccessUnavailablePage(),
          ),
          GoRoute(
            path: AppRoutes.loading,
            builder: (context, state) => const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading workspace',
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                access.context?.membership.role == MemberRole.responder
                ? const AssignmentInboxPage()
                : const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.incidents,
            builder: (context, state) => access.isCoordinator
                ? const CommandCenterPage(view: CommandCenterView.incidents)
                : const IncidentListPage(
                    title: 'Incidents',
                    description: 'Incident records from your organization.',
                  ),
          ),
          GoRoute(
            path: AppRoutes.incidentDetail,
            builder: (context, state) => _incidentDetailPage(state),
          ),
          GoRoute(
            path: AppRoutes.report,
            builder: (context, state) => const ReportIncidentPage(),
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => access.isCoordinator
                ? const CommandCenterPage(view: CommandCenterView.map)
                : const FieldMapPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.syncCenter,
            builder: (context, state) => const SyncCenterPage(),
          ),
          GoRoute(
            path: AppRoutes.overview,
            builder: (context, state) => const CommandCenterPage(),
          ),
          GoRoute(
            path: AppRoutes.teams,
            builder: (context, state) => const TeamsPage(),
          ),
          GoRoute(
            path: AppRoutes.activity,
            builder: (context, state) =>
                const CommandCenterPage(view: CommandCenterView.activity),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const OrganizationSettingsPage(),
          ),
        ],
      ),
    ],
  );
}

Widget _incidentDetailPage(GoRouterState state) {
  final rawId = state.uri.queryParameters['id'];
  if (rawId == null) {
    return const AppPlaceholderPage(
      title: 'Incident detail',
      description: 'Choose an incident to view its timeline.',
      icon: Icons.article_outlined,
    );
  }
  try {
    return IncidentDetailPage(incidentId: UuidValue.fromString(rawId));
  } on FormatException {
    return const AppPlaceholderPage(
      title: 'Incident detail',
      description: 'This incident link is not valid.',
      icon: Icons.error_outline,
    );
  }
}

GoRoute _route(String path, String title, String description, IconData icon) {
  return GoRoute(
    path: path,
    builder: (context, state) =>
        AppPlaceholderPage(title: title, description: description, icon: icon),
  );
}
