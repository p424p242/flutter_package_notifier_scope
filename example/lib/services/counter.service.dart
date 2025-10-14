import 'package:result/result.dart';

class CounterService {
  int _count = 0;

  AsyncResult<int, CounterServiceError> updateCount(int count) async {
    await Future.delayed(const Duration(seconds: 1));
    _count = count;
    return Ok(_count);
  }

  AsyncResult<int, CounterServiceError> getCount() async {
    await Future.delayed(const Duration(seconds: 1));
    return Ok(_count);
  }
}

enum CounterServiceError { updateCountError, getCountError }
