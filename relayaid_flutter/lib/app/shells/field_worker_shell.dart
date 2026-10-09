import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../core/connectivity/connectivity_provider.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_breakpoints.dart';
import '../../design_system/components/relayaid_brand.dart';
import '../../shared/presentation/connectivity_indicator.dart';
import '../../features/auth/application/access_controller.dart';
import '../router/app_router.dart';

class FieldWorkerShell extends ConsumerWidget {
  const FieldWorkerShell({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  int get _selectedIndex => switch (currentPath) {
    AppRoutes.incidents || AppRoutes.incidentDetail => 1,
    AppRoutes.map => 2,
    AppRoutes.profile => 3,
    _ => 0,
  };

  void _onDestinationSelected(BuildContext context, int index) {
    final destination = switch (index) {
      0 => AppRoutes.home,
      1 => AppRoutes.incidents,
      2 => AppRoutes.map,
      _ => AppRoutes.profile,
    };
    context.go(destination);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityControllerProvider).status;
    final isCompact = MediaQuery.sizeOf(context).width < AppBreakpoints.compact;
    final inResponseInbox =
        currentPath == AppRoutes.home &&
        ref.watch(accessControllerProvider).context?.membership.role ==
            MemberRole.responder;
    return Scaffold(
      appBar: AppBar(
        title: const RelayAidBrand(),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.go(AppRoutes.syncCenter),
            icon: const Icon(Icons.sync_outlined),
            tooltip: 'Open sync center',
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space12),
            child: Center(
              child: ConnectivityIndicator(
                status: connectivity,
                compact: isCompact,
              ),
            ),
          ),
        ],
      ),
      body: child,
      floatingActionButton:
          inResponseInbox ||
              currentPath == AppRoutes.home ||
              currentPath == AppRoutes.report
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.go(AppRoutes.report),
              icon: const Icon(Icons.add),
              label: const Text('Report incident'),
              tooltip: 'Report incident',
            ),
      bottomNavigationBar: Semantics(
        label: 'Field navigation',
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              _onDestinationSelected(context, index),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Incidents',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
