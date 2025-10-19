import 'package:example/models/todo.model.dart';
import 'package:example/services/todo.service.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';
import 'package:result/result.dart';

class TodoState {
  TodoState({
    this.todos = const [],
    this.isInitialised = false,
    this.isLoadingTodos = false,
    this.isAddingTodo = false,
    this.isTogglingTodo = false,
    this.isDeletingTodo = false,
  });

  final List<Todo> todos;
  final bool isInitialised;
  final bool isLoadingTodos;
  final bool isAddingTodo;
  final bool isTogglingTodo;
  final bool isDeletingTodo;

  TodoState copyWith({
    List<Todo>? todos,
    bool? isInitialised,
    bool? isLoadingTodos,
    bool? isAddingTodo,
    bool? isTogglingTodo,
    bool? isDeletingTodo,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isInitialised: isInitialised ?? this.isInitialised,
      isLoadingTodos: isLoadingTodos ?? this.isLoadingTodos,
      isAddingTodo: isAddingTodo ?? this.isAddingTodo,
      isTogglingTodo: isTogglingTodo ?? this.isTogglingTodo,
      isDeletingTodo: isDeletingTodo ?? this.isDeletingTodo,
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
  () => TodoNotifier(TodoState()),
);

final todoNotifierGlobal = NotifierScope.global(
  TodoNotifier(TodoState()),
);

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(super.state);

  final _todoService = GetIt.instance<TodoService>();

  @override
  Future<void> init() async {
    await getTodos();
  }

  AsyncResult<List<Todo>, TodoNotifierError> getTodos() async {
    state = state.copyWith(isLoadingTodos: true);
    final serviceResult = await _todoService.getTodos();
    return serviceResult
        .onOk(
          (todos) => state = state.copyWith(
            todos: todos,
            isInitialised: true,
            isLoadingTodos: false,
          ),
        )
        .onError((_) => state = state.copyWith(isLoadingTodos: false))
        .mapError((_) => TodoNotifierError.getTodosError);
  }

  AsyncResult<Todo, TodoNotifierError> addTodo(String title) async {
    state = state.copyWith(isAddingTodo: true);
    final serviceResult = await _todoService.addTodo(title);
    return serviceResult
        .onOk(
          (todo) => state = state.copyWith(
            todos: [...state.todos, todo],
            isAddingTodo: false,
          ),
        )
        .onError((_) => state = state.copyWith(isAddingTodo: false))
        .mapError((_) => TodoNotifierError.addTodoError);
  }

  AsyncResult<Todo, TodoNotifierError> toggleTodoStatus(String id) async {
    state = state.copyWith(isTogglingTodo: true);
    final serviceResult = await _todoService.toggleTodoStatus(id);
    return serviceResult
        .onOk(
          (updatedTodo) => state = state.copyWith(
            todos: state.todos
                .map((todo) => todo.id == id ? updatedTodo : todo)
                .toList(),
            isTogglingTodo: false,
          ),
        )
        .onError((_) => state = state.copyWith(isTogglingTodo: false))
        .mapError((_) => TodoNotifierError.toggleTodoStatusError);
  }

  AsyncResult<void, TodoNotifierError> removeTodo(String id) async {
    state = state.copyWith(isDeletingTodo: true);
    final serviceResult = await _todoService.removeTodo(id);
    return serviceResult
        .onOk(
          (_) => state = state.copyWith(
            todos: state.todos.where((todo) => todo.id != id).toList(),
            isDeletingTodo: false,
          ),
        )
        .onError((_) => state = state.copyWith(isDeletingTodo: false))
        .mapError((_) => TodoNotifierError.removeTodoError);
  }
}
