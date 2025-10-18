import 'package:example/models/todo.model.dart';
import 'package:example/services/todo.service.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';
import 'package:result/result.dart';

class TodoState {
  TodoState({
    required this.todos,
    this.isLoading = false,
  });

  final List<Todo> todos;
  final bool isLoading;

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

enum TodoNotifierError {
  addTodoError,
  toggleTodoStatusError,
  removeTodoError,
  getTodosError,
}

final todoNotifierScoped = NotifierScope.scoped(
  () => TodoNotifier(TodoState(todos: const [])),
);

final todoNotifierGlobal = NotifierScope.global(
  TodoNotifier(TodoState(todos: const [])),
);

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(super.state);

  final _todoService = GetIt.instance<TodoService>();

  @override
  Future<void> init() async {
    await getTodos();
  }

  AsyncResult<List<Todo>, TodoNotifierError> getTodos() async {
    state = state.copyWith(isLoading: true);
    final serviceResult = await _todoService.getTodos();
    return serviceResult
        .onOk((todos) => state = state.copyWith(todos: todos, isLoading: false))
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => TodoNotifierError.getTodosError);
  }

  AsyncResult<Todo, TodoNotifierError> addTodo(String title) async {
    state = state.copyWith(isLoading: true);
    final serviceResult = await _todoService.addTodo(title);
    return serviceResult
        .onOk((todo) => state = state.copyWith(todos: [...state.todos, todo], isLoading: false))
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => TodoNotifierError.addTodoError);
  }

  AsyncResult<Todo, TodoNotifierError> toggleTodoStatus(String id) async {
    state = state.copyWith(isLoading: true);
    final serviceResult = await _todoService.toggleTodoStatus(id);
    return serviceResult
        .onOk((updatedTodo) {
          state = state.copyWith(
            todos: state.todos.map((todo) => todo.id == id ? updatedTodo : todo).toList(),
            isLoading: false,
          );
        })
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => TodoNotifierError.toggleTodoStatusError);
  }

  AsyncResult<void, TodoNotifierError> removeTodo(String id) async {
    state = state.copyWith(isLoading: true);
    final serviceResult = await _todoService.removeTodo(id);
    return serviceResult
        .onOk((_) => state = state.copyWith(todos: state.todos.where((todo) => todo.id != id).toList(), isLoading: false))
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => TodoNotifierError.removeTodoError);
  }
}
