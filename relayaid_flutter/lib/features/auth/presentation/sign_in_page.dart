import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/components/relayaid_brand.dart';
import '../application/client_provider.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RelayAidMark(size: AppSpacing.space40),
              const SizedBox(height: AppSpacing.space24),
              Text(
                'Sign in to RelayAid',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.space8),
              // Text(
              // 'Your response workspace stays connected to the right organization.',
              //   style: theme.textTheme.bodyLarge,
              // ),
              const SizedBox(height: AppSpacing.space32),
              SignInWidget(
                client: ref.watch(serverpodClientProvider),
                onError: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sign-in failed. Check your details and try again.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
