import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.push("/page1"),
              child: const Text('Go to Page1 (Scoped)'),
            ),
            ElevatedButton(
              onPressed: () => context.push("/page2"),
              child: const Text('Go to Page2 (Global)'),
            ),
          ],
        ),
      ),
    );
  }
}
