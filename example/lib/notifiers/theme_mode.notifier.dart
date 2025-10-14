import 'package:example/services/theme_mode.service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';
import 'package:result/result.dart';

// ══════════════════════════════════════════════════════════════════════════
//  STATE MODEL
// ══════════════════════════════════════════════════════════════════════════
class ThemeModeState {
  ThemeModeState({required this.themeMode});
  final ThemeMode themeMode;

  copyWith({ThemeMode? themeMode}) =>
      ThemeModeState(themeMode: themeMode ?? this.themeMode);
}

class ThemeModeNotifier extends StateNotifier<ThemeModeState> {
  ThemeModeNotifier() : super(ThemeModeState(themeMode: ThemeMode.system));

  final themeModeService = GetIt.instance.get<ThemeModeService>();

  // ══════════════════════════════════════════════════════════════════════════
  //  METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Toggles the theme mode between system and dark
  AsyncResult<Null, ThemeModeNotifierError> toggleThemeMode() async {
    final currentThemeResult = await _getCurrentThemeMode();

    switch (currentThemeResult) {
      case Ok<ThemeMode, ThemeModeNotifierError>(:final value):
        return await _toggleAndUpdateThemeMode(value);
      case Error<ThemeMode, ThemeModeNotifierError>(:final error):
        return Error(error);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  init() async => await _loadInitialThemeMode();

  AsyncResult<Null, ThemeModeNotifierError> _loadInitialThemeMode() async {
    final themeModeResult = await themeModeService.getThemeMode();

    switch (themeModeResult) {
      case Ok<ThemeMode, ThemeModeServiceError>(:final value):
        return _updateStateWithThemeMode(value);
      case Error<ThemeMode, ThemeModeServiceError> _:
        return Error(ThemeModeNotifierError.getThemeModeError);
    }
  }

  AsyncResult<ThemeMode, ThemeModeNotifierError> _getCurrentThemeMode() async {
    final themeModeResult = await themeModeService.getThemeMode();

    switch (themeModeResult) {
      case Ok<ThemeMode, ThemeModeServiceError>(:final value):
        return Ok(value);
      case Error<ThemeMode, ThemeModeServiceError> _:
        return Error(ThemeModeNotifierError.getThemeModeError);
    }
  }

  ThemeMode _calculateNextThemeMode(ThemeMode currentMode) {
    return currentMode == ThemeMode.system ? ThemeMode.dark : ThemeMode.system;
  }

  AsyncResult<Null, ThemeModeNotifierError> _toggleAndUpdateThemeMode(
    ThemeMode currentMode,
  ) async {
    final newThemeMode = _calculateNextThemeMode(currentMode);
    final updateResult = await themeModeService.updateThemeMode(newThemeMode);

    switch (updateResult) {
      case Ok<Null, ThemeModeServiceError> _:
        return _updateStateWithThemeMode(newThemeMode);
      case Error<Null, ThemeModeServiceError> _:
        return Error(ThemeModeNotifierError.updateThemeModeError);
    }
  }

  Result<Null, ThemeModeNotifierError> _updateStateWithThemeMode(
    ThemeMode themeMode,
  ) {
    state = state.copyWith(themeMode: themeMode);
    return Ok(null);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ERRORS
// ══════════════════════════════════════════════════════════════════════════

enum ThemeModeNotifierError { getThemeModeError, updateThemeModeError }

final themeModeNotifier = NotifierScope.scoped(() => ThemeModeNotifier());
