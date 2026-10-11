import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import '../features/auth/application/access_controller.dart';
import 'router/app_router.dart';
import '../core/connectivity/connectivity_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = buildAppRouter(ref.read(accessControllerProvider));
  ref.onDispose(router.dispose);
  return router;
});

class RelayAidApp extends ConsumerStatefulWidget {
  const RelayAidApp({super.key});

  @override
  ConsumerState<RelayAidApp> createState() => _RelayAidAppState();
}

class _RelayAidAppState extends ConsumerState<RelayAidApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          unawaited(ref.read(connectivityControllerProvider).refresh()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RelayAid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
