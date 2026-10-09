import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/components/app_button.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../application/access_controller.dart';

class AccessUnavailablePage extends ConsumerWidget {
  const AccessUnavailablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: AppSpacing.space40),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Workspace unavailable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.space8),
            const Text(
              'Your sign-in is saved. Reconnect to load organization access.',
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton(
              label: 'Try again',
              onPressed: () => ref.read(accessControllerProvider).refresh(),
            ),
          ],
        ),
      ),
    );
  }
}
