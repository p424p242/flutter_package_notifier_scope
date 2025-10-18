import 'package:result/result.dart';

class CounterService {
  int _counter = 0;

  AsyncResult<int, CounterServiceError> getCounter() async {
    await Future.delayed(const Duration(seconds: 1));
    return Ok(_counter);
  }

  AsyncResult<int, CounterServiceError> increment() async {
    await Future.delayed(const Duration(seconds: 1));
    _counter++;
    return Ok(_counter);
  }

  AsyncResult<int, CounterServiceError> reset() async {
    await Future.delayed(const Duration(seconds: 1));
    _counter = 0;
    return Ok(_counter);
  }
}

enum CounterServiceError { getCounterError, incrementError }
