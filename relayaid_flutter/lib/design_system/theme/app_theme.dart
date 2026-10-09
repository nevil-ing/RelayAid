import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final canvas = isDark ? AppColors.darkCanvas : AppColors.lightCanvas;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedText = isDark
        ? AppColors.darkMutedText
        : AppColors.lightMutedText;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.primaryPressed,
          surface: surface,
          onSurface: text,
          onSurfaceVariant: mutedText,
          outline: outline,
          outlineVariant: outline,
          error: AppColors.danger,
          shadow: AppColors.shadow,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: surface,
        titleTextStyle: AppTypography.textTheme.titleMedium?.copyWith(
          color: text,
        ),
      ),
      dividerTheme: DividerThemeData(color: outline),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.small),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.small),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.small,
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.small,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.small,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.textTheme.labelLarge,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primaryContainer,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        selectedLabelTextStyle: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
