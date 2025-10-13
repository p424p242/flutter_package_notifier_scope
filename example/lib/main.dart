import 'package:example/counter_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';
import 'package:result/result.dart';

typedef CounterState = ({int? count, bool isIncrementing});

extension CounterStateX on CounterState {
  CounterState copyWith({int? count, bool? isIncrementing}) => (
    count: count ?? this.count,
    isIncrementing: isIncrementing ?? this.isIncrementing,
  );
}

class CounterANotifier extends StateNotifier<CounterState> {
  CounterANotifier() : super((count: null, isIncrementing: false));

  AsyncResult<Null, CounterNotifierError> increment() async {
    if (state.count == null) {
      state = state.copyWith(isIncrementing: false, count: 0);
      return Ok(null);
    }

    state = state.copyWith(isIncrementing: true);
    final counterService = GetIt.instance.get<CounterService>();
    switch (await counterService.updateCount(state.count! + 1)) {
      case Ok<int, CounterServiceError>(:final value):
        state = state.copyWith(isIncrementing: false, count: value);
        return Ok(null);
      case Error<int, CounterServiceError>():
        state = state.copyWith(isIncrementing: false);
        return Error(CounterNotifierError.incrementError);
    }
  }
}

class CounterBNotifier extends StateNotifier<CounterState> {
  CounterBNotifier() : super((count: null, isIncrementing: false));

  AsyncResult<Null, CounterNotifierError> increment() async {
    if (state.count == null) {
      state = state.copyWith(isIncrementing: false, count: 0);
      return Ok(null);
    }

    state = state.copyWith(isIncrementing: true);
    final counterService = GetIt.instance.get<CounterService>();
    switch (await counterService.updateCount(state.count! + 1)) {
      case Ok<int, CounterServiceError>(:final value):
        state = state.copyWith(isIncrementing: false, count: value);
        return Ok(null);
      case Error<int, CounterServiceError>():
        state = state.copyWith(isIncrementing: false);
        return Error(CounterNotifierError.incrementError);
    }
  }
}

enum CounterNotifierError { incrementError }

final counterANotifier = NotifierScope.global(CounterANotifier());
final counterBNotifier = NotifierScope.scoped(() => CounterBNotifier());

// APP -------------------------------------------------------------------

void main() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<CounterService>(CounterService());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (c) => const Page1())),
            child: const Text("Page1"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (c) => const Page2())),
            child: const Text("Page2"),
          ),
        ],
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) => Scaffold(
        appBar: AppBar(title: const Text('Page1')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Counter A'),
              Text(counterANotifier.instance.state.count.toString()),
              const Text('Counter B'),
              Text(counterBNotifier.instance.state.count.toString()),
              ElevatedButton(
                onPressed: () {
                  counterANotifier.instance.increment();
                },
                child: const Text('Increment Counter A'),
              ),
              ElevatedButton(
                onPressed: () {
                  counterBNotifier.instance.increment();
                },
                child: const Text('Increment Counter B'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) => Scaffold(
        appBar: AppBar(title: Text('Page2')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Counter A'),
              Text(counterANotifier.instance.state.count.toString()),
              const Text('Counter B'),
              Text(counterBNotifier.instance.state.count.toString()),
              ElevatedButton(
                onPressed: () {
                  counterANotifier.instance.increment();
                },
                child: Text('Increment Counter A'),
              ),
              ElevatedButton(
                onPressed: () {
                  counterBNotifier.instance.increment();
                },
                child: Text('Increment Counter B'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
