import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

enum AppStatusTone { neutral, info, success, warning, danger }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    required this.tone,
    super.key,
    this.icon,
  });

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      AppStatusTone.neutral => (
        background: Theme.of(context).colorScheme.surfaceContainerHighest,
        foreground: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      AppStatusTone.info => (
        background: AppColors.infoContainer,
        foreground: AppColors.info,
      ),
      AppStatusTone.success => (
        background: AppColors.successContainer,
        foreground: AppColors.success,
      ),
      AppStatusTone.warning => (
        background: AppColors.warningContainer,
        foreground: AppColors.warning,
      ),
      AppStatusTone.danger => (
        background: AppColors.dangerContainer,
        foreground: AppColors.danger,
      ),
    };

    return Semantics(
      label: 'Current status: $label',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: AppRadii.small,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: AppSpacing.space16,
                    color: colors.foreground,
                  ),
                  const SizedBox(width: AppSpacing.space4),
                ],
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colors.foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AppSeverity { low, moderate, high, critical }

class AppSeverityBadge extends StatelessWidget {
  const AppSeverityBadge({required this.severity, super.key});

  final AppSeverity severity;

  @override
  Widget build(BuildContext context) {
    final presentation = switch (severity) {
      AppSeverity.low => ('Low', AppStatusTone.neutral),
      AppSeverity.moderate => ('Moderate', AppStatusTone.info),
      AppSeverity.high => ('High', AppStatusTone.warning),
      AppSeverity.critical => ('Critical', AppStatusTone.danger),
    };

    return AppStatusBadge(
      label: presentation.$1,
      tone: presentation.$2,
      icon: Icons.priority_high,
    );
  }
}
