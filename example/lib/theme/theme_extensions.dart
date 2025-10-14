import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

extension ThemeContextExtension on BuildContext {
  // Reactive color accessors - use our reactive color system
  Color get primaryColor => AppColors.primary(this);
  Color get primaryContainer => AppColors.primaryContainer(this);
  Color get primaryVariant => AppColors.primaryVariant(this);
  Color get secondaryColor => AppColors.secondary(this);
  Color get secondaryContainer => AppColors.secondaryContainer(this);
  Color get secondaryVariant => AppColors.secondaryVariant(this);
  Color get surfaceColor => AppColors.surface(this);
  Color get backgroundColor => AppColors.background(this);
  Color get scaffoldBackgroundColor => AppColors.scaffoldBackground(this);
  Color get errorColor => AppColors.error(this);
  Color get successColor => AppColors.success(this);
  Color get warningColor => AppColors.warning(this);
  Color get infoColor => AppColors.info(this);
  Color get neutralColor => AppColors.neutral(this);
  Color get neutralVariantColor => AppColors.neutralVariant(this);

  // Text color accessors
  Color get onPrimaryColor => AppColors.onPrimary(this);
  Color get onSecondaryColor => AppColors.onSecondary(this);
  Color get onSurfaceColor => AppColors.onSurface(this);
  Color get onBackgroundColor => AppColors.onBackground(this);
  Color get onErrorColor => AppColors.onError(this);

  // Gradient accessors (context-aware)
  List<Color> get primaryGradient => AppColors.primaryGradient(this);

  List<Color> get surfaceGradient => AppColors.surfaceGradient(this);

  // Text style accessors with reactive colors
  TextStyle get displayLarge => AppTextStyles.displayLarge.copyWith(color: onSurfaceColor);
  TextStyle get displayMedium => AppTextStyles.displayMedium.copyWith(color: onSurfaceColor);
  TextStyle get displaySmall => AppTextStyles.displaySmall.copyWith(color: onSurfaceColor);
  TextStyle get headlineLarge => AppTextStyles.headlineLarge.copyWith(color: onSurfaceColor);
  TextStyle get headlineMedium => AppTextStyles.headlineMedium.copyWith(color: onSurfaceColor);
  TextStyle get headlineSmall => AppTextStyles.headlineSmall.copyWith(color: onSurfaceColor);
  TextStyle get titleLarge => AppTextStyles.titleLarge.copyWith(color: onSurfaceColor);
  TextStyle get titleMedium => AppTextStyles.titleMedium.copyWith(color: onSurfaceColor);
  TextStyle get titleSmall => AppTextStyles.titleSmall.copyWith(color: onSurfaceColor);
  TextStyle get bodyLarge => AppTextStyles.bodyLarge.copyWith(color: onSurfaceColor);
  TextStyle get bodyMedium => AppTextStyles.bodyMedium.copyWith(color: onSurfaceColor);
  TextStyle get bodySmall => AppTextStyles.bodySmall.copyWith(color: onSurfaceColor);
  TextStyle get labelLarge => AppTextStyles.labelLarge.copyWith(color: onSurfaceColor);
  TextStyle get labelMedium => AppTextStyles.labelMedium.copyWith(color: onSurfaceColor);
  TextStyle get labelSmall => AppTextStyles.labelSmall.copyWith(color: onSurfaceColor);
  TextStyle get buttonStyle => AppTextStyles.button.copyWith(color: onPrimaryColor);
  TextStyle get captionStyle => AppTextStyles.caption.copyWith(color: onSurfaceColor.withValues(alpha: 0.6));
  TextStyle get overlineStyle => AppTextStyles.overline.copyWith(color: onSurfaceColor);

  // Custom text style accessors with reactive colors
  TextStyle get appTitle => AppTextStyles.appTitle.copyWith(color: onSurfaceColor);
  TextStyle get featureItem => AppTextStyles.featureItem.copyWith(color: onSurfaceColor);
  TextStyle get counterValue => AppTextStyles.counterValue.copyWith(color: onSurfaceColor);
  TextStyle get gradientButton => AppTextStyles.gradientButton.copyWith(color: onPrimaryColor);

  // Theme data accessors
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // Brightness helpers
  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isLightMode => theme.brightness == Brightness.light;

  // Spacing helpers
  double get extraSmallSpacing => 4.0;
  double get smallSpacing => 8.0;
  double get mediumSpacing => 16.0;
  double get largeSpacing => 24.0;
  double get extraLargeSpacing => 32.0;
  double get hugeSpacing => 40.0;

  // Border radius helpers
  BorderRadius get extraSmallBorderRadius => BorderRadius.circular(4.0);
  BorderRadius get smallBorderRadius => BorderRadius.circular(8.0);
  BorderRadius get mediumBorderRadius => BorderRadius.circular(12.0);
  BorderRadius get largeBorderRadius => BorderRadius.circular(16.0);
  BorderRadius get extraLargeBorderRadius => BorderRadius.circular(20.0);
  BorderRadius get hugeBorderRadius => BorderRadius.circular(24.0);

  // Elevation helpers
  double get lowElevation => 2.0;
  double get mediumElevation => 4.0;
  double get highElevation => 8.0;
  double get extraHighElevation => 12.0;

  // Shadow helpers
  List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: lowElevation,
      offset: const Offset(0, 2),
    ),
  ];

  List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: mediumElevation,
      offset: const Offset(0, 4),
    ),
  ];

  List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: highElevation,
      offset: const Offset(0, 6),
    ),
  ];

  List<BoxShadow> get gradientShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: mediumElevation,
      offset: const Offset(0, 4),
    ),
  ];

  // Gradient helpers
  LinearGradient get primaryLinearGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: primaryGradient,
  );

  LinearGradient get surfaceLinearGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: surfaceGradient,
  );

  // Animation durations
  Duration get shortAnimationDuration => const Duration(milliseconds: 200);
  Duration get mediumAnimationDuration => const Duration(milliseconds: 300);
  Duration get longAnimationDuration => const Duration(milliseconds: 500);

  // Opacity helpers
  double get subtleOpacity => 0.1;
  double get mediumOpacity => 0.3;
  double get strongOpacity => 0.6;
}