import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors - context-aware for real-time theme switching
  static Color primary(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFFEC407A), // Pink 400
    dark: const Color(0xFFF48FB1), // Pink 200
  );

  static Color primaryContainer(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFFF8BBD0), // Pink 100
    dark: const Color(0xFF880E4F), // Pink 900
  );

  static Color primaryVariant(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFFAD1457), // Pink 800
    dark: const Color(0xFFC2185B), // Pink 700
  );

  // Secondary colors
  static Color secondary(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFF7B1FA2), // Deep Purple 700
    dark: const Color(0xFFCE93D8), // Deep Purple 200
  );

  static Color secondaryContainer(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFFE1BEE7), // Deep Purple 100
    dark: const Color(0xFF4A148C), // Deep Purple 900
  );

  static Color secondaryVariant(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFF4A148C), // Deep Purple 900
    dark: const Color(0xFF7B1FA2), // Deep Purple 700
  );

  // Surface colors
  static Color surface(BuildContext context) => _brightnessAware(
    context: context,
    light: Colors.white,
    dark: const Color(0xFF121212),
  );

  static Color background(BuildContext context) => _brightnessAware(
    context: context,
    light: Colors.white,
    dark: Colors.grey.withAlpha(50),
  );

  static Color scaffoldBackground(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFFF5F5F5),
    dark: const Color(0xFF1E1E1E),
  );

  // Error colors
  static Color error(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFFB00020),
    dark: const Color(0xFFCF6679),
  );

  // Text colors
  static Color onPrimary(BuildContext context) => _brightnessAware(
    context: context,
    light: Colors.white,
    dark: Colors.black87,
  );

  static Color onSecondary(BuildContext context) => _brightnessAware(
    context: context,
    light: Colors.white,
    dark: Colors.black87,
  );

  static Color onSurface(BuildContext context) => _brightnessAware(
    context: context,
    light: Colors.black87,
    dark: Colors.white,
  );

  static Color onBackground(BuildContext context) => _brightnessAware(
    context: context,
    light: Colors.black87,
    dark: Colors.white,
  );

  static Color onError(BuildContext context) => _brightnessAware(
    context: context,
    light: Colors.white,
    dark: Colors.black,
  );

  // Semantic colors
  static Color success(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFF4CAF50),
    dark: const Color(0xFF66BB6A),
  );

  static Color warning(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFFFF9800),
    dark: const Color(0xFFFFB74D),
  );

  static Color info(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFF2196F3),
    dark: const Color(0xFF64B5F6),
  );

  // Neutral colors
  static Color neutral(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFF9E9E9E),
    dark: const Color(0xFF757575),
  );

  static Color neutralVariant(BuildContext context) => _brightnessAware(
    context: context,
    light: const Color(0xFF616161),
    dark: const Color(0xFFBDBDBD),
  );

  // Gradient colors - context-aware
  static List<Color> primaryGradient(BuildContext context) => [
    primary(context),
    secondary(context),
  ];

  static List<Color> surfaceGradient(BuildContext context) => [
    surface(context),
    primaryContainer(context).withValues(alpha: 0.1),
  ];

  // Helper method for reactive brightness-aware colors
  static Color _brightnessAware({
    required BuildContext context,
    required Color light,
    required Color dark,
  }) {
    // Uses Theme.of(context).brightness for real-time theme reactivity
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? light : dark;
  }
}
