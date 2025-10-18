import 'package:example/services/counter.service.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';
import 'package:result/result.dart';

final counterNotifierScoped = NotifierScope.scoped(
  () => CounterNotifier(
    CounterState(counter: null, isIncrementing: false, isInitialised: false),
  ),
);

final counterNotifierGlobal = NotifierScope.global(
  CounterNotifier(
    CounterState(counter: null, isIncrementing: false, isInitialised: false),
  ),
);

class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier(super.state);
  final _counterService = GetIt.instance<CounterService>();

  AsyncResult<int, CounterNotifierError> getCounter() async {
    state = state.copyWith(isIncrementing: true);
    final result = await _counterService.getCounter();
    switch (result) {
      case Ok<int, CounterServiceError>(:final value):
        state = state.copyWith(isIncrementing: false, counter: value);
        return Ok(value);
      case Error<int, CounterServiceError>():
        state = state.copyWith(isIncrementing: false);
        return Error(CounterNotifierError.getCounterError);
    }
  }

  AsyncResult<Null, CounterNotifierError> increment() async {
    state = state.copyWith(isIncrementing: true);
    final result = await _counterService.increment();
    switch (result) {
      case Ok<int, CounterServiceError>(:final value):
        state = state.copyWith(isIncrementing: false, counter: value);
        return Ok(null);
      case Error<int, CounterServiceError>():
        state = state.copyWith(isIncrementing: false);
        return Error(CounterNotifierError.incrementError);
    }
  }

  @override
  Future<void> dispose() async {
    await _counterService.reset();
    super.dispose();
  }

  @override
  Future<void> init() async {
    await getCounter();
    state = state.copyWith(isInitialised: true);
  }
}

class CounterState {
  CounterState({
    required this.counter,
    required this.isIncrementing,
    required this.isInitialised,
  });
  final int? counter;
  final bool isIncrementing;
  final bool isInitialised;

  CounterState copyWith({
    int? counter,
    bool? isIncrementing,
    bool? isInitialised,
  }) {
    return CounterState(
      counter: counter ?? this.counter,
      isIncrementing: isIncrementing ?? this.isIncrementing,
      isInitialised: isInitialised ?? this.isInitialised,
    );
  }
}

enum CounterNotifierError { getCounterError, incrementError }
