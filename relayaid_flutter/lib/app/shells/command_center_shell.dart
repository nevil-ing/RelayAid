import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/connectivity/connectivity_provider.dart';
import '../../design_system/tokens/app_breakpoints.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_workspace.dart';
import '../../design_system/components/relayaid_brand.dart';
import '../../features/auth/application/access_controller.dart';
import '../../shared/presentation/connectivity_indicator.dart';
import '../router/app_router.dart';

class CommandCenterShell extends ConsumerWidget {
  const CommandCenterShell({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  static const List<_CommandCenterDestination> _destinations =
      <_CommandCenterDestination>[
        _CommandCenterDestination(
          label: 'Overview',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          route: AppRoutes.overview,
        ),
        _CommandCenterDestination(
          label: 'Incidents',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          route: AppRoutes.incidents,
        ),
        _CommandCenterDestination(
          label: 'Map',
          icon: Icons.map_outlined,
          selectedIcon: Icons.map,
          route: AppRoutes.map,
        ),
        _CommandCenterDestination(
          label: 'Teams',
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          route: AppRoutes.teams,
        ),
        _CommandCenterDestination(
          label: 'Activity',
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          route: AppRoutes.activity,
        ),
        _CommandCenterDestination(
          label: 'Settings',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          route: AppRoutes.settings,
        ),
      ];

  int get _selectedIndex {
    final index = _destinations.indexWhere(
      (destination) => destination.route == currentPath,
    );
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final connectivity = ref.watch(connectivityControllerProvider).status;
    final access = ref.watch(accessControllerProvider);
    if (width < AppBreakpoints.commandCenter) {
      return Scaffold(
        appBar: AppBar(
          title: const RelayAidBrand(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space12),
              child: Center(child: ConnectivityIndicator(status: connectivity)),
            ),
          ],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Semantics(
              label: 'Command center navigation',
              container: true,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space16,
                ),
                children: [
                  for (final destination in _destinations)
                    ListTile(
                      leading: Icon(destination.icon),
                      title: Text(destination.label),
                      selected: destination.route == currentPath,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(destination.route);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        body: child,
      );
    }
    final isExpanded = width >= AppBreakpoints.expandedNavigation;
    return Scaffold(
      body: Row(
        children: <Widget>[
          Semantics(
            label: 'Command center navigation',
            container: true,
            child: NavigationRail(
              extended: isExpanded,
              minExtendedWidth: AppBreakpoints.commandCenter / 4,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                context.go(_destinations[index].route);
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space16,
                ),
                child: isExpanded
                    ? const RelayAidBrand()
                    : const RelayAidMark(),
              ),
              destinations: _destinations
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: AppWorkspace.toolbarHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space24,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          access.context?.organization.name ?? 'RelayAid',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space16),
                      ConnectivityIndicator(status: connectivity),
                      const SizedBox(width: AppSpacing.space16),
                      IconButton(
                        tooltip: 'Sign out',
                        icon: const Icon(Icons.logout),
                        onPressed: access.signOut,
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandCenterDestination {
  const _CommandCenterDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}
