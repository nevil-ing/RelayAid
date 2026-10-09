import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'app_surface_card.dart';

enum AppViewState { loading, empty, error }

class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.state,
    required this.title,
    required this.description,
    super.key,
  });

  final AppViewState state;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = switch (state) {
      AppViewState.loading => (
        icon: Icons.hourglass_top_outlined,
        color: theme.colorScheme.primary,
      ),
      AppViewState.empty => (
        icon: Icons.inbox_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      AppViewState.error => (
        icon: Icons.error_outline,
        color: theme.colorScheme.error,
      ),
    };

    return Semantics(
      container: true,
      label: '$title. $description',
      child: AppSurfaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(presentation.icon, color: presentation.color),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
