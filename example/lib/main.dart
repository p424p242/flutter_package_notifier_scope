import 'package:example/router.dart';
import 'package:example/services/counter.service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() async {
  final getIt = GetIt.instance;

  getIt.registerSingleton<CounterService>(CounterService());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
