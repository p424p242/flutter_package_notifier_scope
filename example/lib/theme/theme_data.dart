import 'package:flutter/material.dart';

class AppThemeData {
  AppThemeData._();
  static ThemeData get light =>
      ThemeData(useMaterial3: true, brightness: Brightness.light);

  static ThemeData get dark =>
      ThemeData(useMaterial3: true, brightness: Brightness.dark);
}

