import 'package:example/services/counter.service.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';
import 'package:result/result.dart';

// ══════════════════════════════════════════════════════════════════════════
//  STATE MODEL
// ══════════════════════════════════════════════════════════════════════════

class CounterState {
  CounterState({required this.count, required this.isIncrementing});
  final int? count;
  final bool isIncrementing;

  copyWith({int? count, bool? isIncrementing}) => CounterState(
    count: count ?? this.count,
    isIncrementing: isIncrementing ?? this.isIncrementing,
  );
}

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFIER
// ══════════════════════════════════════════════════════════════════════════

class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier() : super(CounterState(count: null, isIncrementing: false));

  // ════════════════════════════════════════════════════════════════════════
  //  METHODS
  // ════════════════════════════════════════════════════════════════════════

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

// ══════════════════════════════════════════════════════════════════════════
//  ERRORS
// ══════════════════════════════════════════════════════════════════════════

enum CounterNotifierError { incrementError }

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFIER INSTANCES
// ══════════════════════════════════════════════════════════════════════════

// Global counter notifier - shared across the entire app
final counterANotifier = NotifierScope.global(CounterNotifier());

// Scoped counter notifier - created per usage scope
final counterBNotifier = NotifierScope.scoped(() => CounterNotifier());
