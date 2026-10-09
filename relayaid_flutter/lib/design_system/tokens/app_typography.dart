import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.12,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  );
}
