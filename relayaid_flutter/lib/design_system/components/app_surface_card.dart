import 'package:flutter/material.dart';

import '../tokens/app_radii.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_spacing.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.space16),
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: AppRadii.medium,
        boxShadow: elevated ? AppShadows.surface : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
