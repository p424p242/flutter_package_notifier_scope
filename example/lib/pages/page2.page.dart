import 'package:example/notifiers/counter.notifier.dart';
import 'package:flutter/material.dart';
import 'package:notifier_scope/notifier_scope.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder((context) {
      final counterNotifier = counterNotifierGlobal.instance;
      return Scaffold(
        appBar: AppBar(title: const Text('Page2 (Global)')),
        body: counterNotifier.state.isInitialised
            ? InitialisedWidget(count: counterNotifier.state.counter!)
            : UninitialisedWidget(),
        floatingActionButton: IncrementButton(
          onPressed: counterNotifier.increment,
          isLoading:
              counterNotifier.state.isIncrementing ||
              !counterNotifier.state.isInitialised,
        ),
      );
    });
  }
}

class IncrementButton extends StatelessWidget {
  const IncrementButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : FloatingActionButton.small(
            onPressed: onPressed,
            child: const Icon(Icons.add),
          );
  }
}

class InitialisedWidget extends StatelessWidget {
  const InitialisedWidget({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: const TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }
}

class UninitialisedWidget extends StatelessWidget {
  const UninitialisedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
