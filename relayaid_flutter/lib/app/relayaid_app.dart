import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import '../features/auth/application/access_controller.dart';
import 'router/app_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = buildAppRouter(ref.read(accessControllerProvider));
  ref.onDispose(router.dispose);
  return router;
});

class RelayAidApp extends ConsumerWidget {
  const RelayAidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
