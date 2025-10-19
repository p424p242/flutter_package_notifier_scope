import 'package:example/models/todo.model.dart';
import 'package:result/result.dart';

class TodoService {
  final List<Todo> _todos = [];

  AsyncResult<List<Todo>, TodoServiceError> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Ok(List.unmodifiable(_todos));
  }

  AsyncResult<Todo, TodoServiceError> addTodo(String title) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTodo = Todo.create(title: title);
    _todos.add(newTodo);
    return Ok(newTodo);
  }

  AsyncResult<Todo, TodoServiceError> toggleTodoStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _todos.indexWhere((todo) => todo.id == id);

    if (index == -1) return Error(TodoServiceError.notFound);

    final updatedTodo = _todos[index].copyWith(
      isCompleted: !_todos[index].isCompleted,
    );
    _todos[index] = updatedTodo;
    return Ok(updatedTodo);
  }

  AsyncResult<void, TodoServiceError> removeTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_todos.any((todo) => todo.id == id)) {
      return Error(TodoServiceError.notFound);
    }

    _todos.removeWhere((todo) => todo.id == id);
    return Ok(null);
  }
}

enum TodoServiceError { notFound, unknownError }
