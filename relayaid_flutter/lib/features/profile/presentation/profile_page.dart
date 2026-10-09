import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/components/app_button.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../shared/presentation/member_id_view.dart';
import '../../../shared/presentation/member_role_label.dart';
import '../../auth/application/access_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessControllerProvider);
    final contextData = access.context;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.space24),
        if (contextData != null) ...[
          Text('Organization', style: Theme.of(context).textTheme.labelLarge),
          Text(contextData.organization.name),
          const SizedBox(height: AppSpacing.space16),
          Text('Role', style: Theme.of(context).textTheme.labelLarge),
          Text(memberRoleLabel(contextData.membership.role)),
          const SizedBox(height: AppSpacing.space16),
        ],
        MemberIdView(userId: access.userId?.toString()),
        const SizedBox(height: AppSpacing.space32),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.secondary,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text(
                    'Saved reports and photos remain on this device for this account. Sign in again to continue synchronization.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Stay signed in'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) await access.signOut();
            },
          ),
        ),
      ],
    );
  }
}
