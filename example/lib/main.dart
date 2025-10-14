import 'package:example/services/counter.service.dart';
import 'package:example/services/theme_mode.service.dart';
import 'package:example/notifiers/theme_mode.notifier.dart';
import 'package:example/pages/home_page.dart';
import 'package:example/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';

void main() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<CounterService>(CounterService());
  getIt.registerSingleton<ThemeModeService>(ThemeModeService());

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) => MaterialApp(
        theme: AppThemeData.light,
        darkTheme: AppThemeData.dark,
        themeMode: themeModeNotifier.instance.state.themeMode,
        home: const HomePage(),
      ),
    );
  }
}
