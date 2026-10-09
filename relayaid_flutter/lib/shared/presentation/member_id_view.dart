import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/tokens/app_spacing.dart';

class MemberIdView extends StatelessWidget {
  const MemberIdView({required this.userId, super.key});
  final String? userId;

  Future<void> _copy(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: userId!));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User ID copied. Share it with your organization administrator.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Copy was unavailable. Select the user ID to copy it manually.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('User ID', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: AppSpacing.space8),
      SelectableText(userId ?? 'Unavailable'),
      const SizedBox(height: AppSpacing.space8),
      OutlinedButton.icon(
        onPressed: userId == null ? null : () => _copy(context),
        icon: const Icon(Icons.copy_outlined),
        label: const Text('Copy user ID'),
      ),
      const SizedBox(height: AppSpacing.space8),
      const Text(
        'An administrator adds this account ID in Settings → Members and chooses your role. A responder must also be added to a team before receiving assignments.',
      ),
    ],
  );
}
