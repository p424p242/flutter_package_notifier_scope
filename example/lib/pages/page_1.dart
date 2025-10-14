import 'package:example/notifiers/counter.notifier.dart';
import 'package:example/widgets/counter_card.dart';
import 'package:flutter/material.dart';
import 'package:notifier_scope/notifier_scope.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page 1'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Global vs Scoped Notifiers',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    CounterCard(
                      title: 'Counter A (Global)',
                      notifier: counterANotifier,
                    ),
                    const SizedBox(height: 16),
                    CounterCard(
                      title: 'Counter B (Scoped)',
                      notifier: counterBNotifier,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
