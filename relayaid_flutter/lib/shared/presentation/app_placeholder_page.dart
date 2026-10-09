import 'package:flutter/material.dart';

import '../../design_system/components/app_state_view.dart';
import '../../design_system/tokens/app_spacing.dart';

/// A structural route page used until a feature owns its real presentation.
class AppPlaceholderPage extends StatelessWidget {
  const AppPlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space32),
          Icon(
            icon,
            size: AppSpacing.space40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.space16),
          const AppStateView(
            state: AppViewState.empty,
            title: 'Workspace ready',
            description:
                'This route is available for the next implementation phase.',
          ),
        ],
      ),
    );
  }
}
