import 'package:flutter/material.dart';
import 'package:result/result.dart';

class ThemeModeService {
  ThemeMode _themeMode = ThemeMode.system;

  /// Retrieves the current theme mode
  AsyncResult<ThemeMode, ThemeModeServiceError> getThemeMode() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return Ok(_themeMode);
    } catch (e) {
      return Error(ThemeModeServiceError.getThemeModeError);
    }
  }

  /// Updates the theme mode with validation
  AsyncResult<Null, ThemeModeServiceError> updateThemeMode(
    ThemeMode themeMode,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _themeMode = themeMode;
      return Ok(null);
    } catch (e) {
      return Error(ThemeModeServiceError.updateThemeModeError);
    }
  }

  /// Validates if a theme mode is supported
  bool isValidThemeMode(ThemeMode themeMode) {
    return ThemeMode.values.contains(themeMode);
  }

  /// Gets the current theme mode value (for internal use)
  ThemeMode get currentThemeMode => _themeMode;
}

enum ThemeModeServiceError {
  getThemeModeError,
  updateThemeModeError
}
