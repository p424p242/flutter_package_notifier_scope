# NotifierScope + Result Package Example

This example demonstrates how to use the `notifier_scope` package together with the `flutter_package_result` package to build a robust Flutter application with modern functional programming patterns.

## Features

- **State Management**: Uses `notifier_scope` for automatic lifecycle management of global and scoped notifiers
- **Error Handling**: Leverages `flutter_package_result` for type-safe error handling with functional extension methods
- **Functional Programming**: Demonstrates modern FP patterns with Result extension methods
- **Clean Architecture**: Separation of concerns with services, notifiers, and UI layers

## Architecture Overview

### Service Layer

The service layer handles business logic and returns `Result` types:

```dart
class TodoService {
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
}
```

### Notifier Layer with Result Extensions

The notifier layer uses Result extension methods for clean state management:

```dart
class TodoNotifier extends StateNotifier<TodoState> {
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
}
```

### Available Result Extension Methods

The `flutter_package_result` provides powerful extension methods:

- `.onOk(void Function(O) op)`: Perform side effects on success
- `.onError(void Function(E) op)`: Perform side effects on error
- `.map<O2>(O2 Function(O) op)`: Transform success values
- `.mapError<E2>(E2 Function(E) op)`: Transform error values
- `.andThen<O2>(Result<O2, E> Function(O) op)`: Chain operations
- `.getOrElse(O Function(E) orElse)`: Get value or compute default
- `.fold<T2>(T2 Function(O) okOp, T2 Function(E) errorOp)`: Combine both cases

### Notifier Scope Usage

Create scoped and global notifiers with automatic lifecycle management:

```dart
// Scoped notifier - automatically disposed when no longer used
final todoNotifierScoped = NotifierScope.scoped(
  () => TodoNotifier(TodoState(todos: const [])),
);

// Global notifier - persists throughout app lifetime
final todoNotifierGlobal = NotifierScope.global(
  TodoNotifier(TodoState(todos: const [])),
);
```

### UI Layer with NotifierBuilder

The UI layer uses `NotifierBuilder` for automatic state management:

```dart
class TodoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NotifierBuilder((context) {
      final todoNotifier = todoNotifierScoped.instance;
      final todos = todoNotifier.state.todos;
      final isLoading = todoNotifier.state.isLoading;

      return Scaffold(
        // UI implementation using the state
      );
    });
  }
}
```

## Key Benefits

### 1. Type-Safe Error Handling
No more runtime exceptions - all errors are handled at compile time:

```dart
// Compile-time safety - you must handle both success and error cases
final result = await todoNotifier.addTodo('New task');
result.onOk((todo) => print('Added: ${todo.title}'))
     .onError((error) => print('Error: $error'));
```

### 2. Functional Composition
Chain operations cleanly without nested conditionals:

```dart
final result = await service.getData()
    .map(transformData)
    .andThen(validateData)
    .onOk(updateUI)
    .onError(showError);
```

### 3. Automatic Lifecycle Management
`NotifierScope` handles disposal automatically:

- **Scoped notifiers**: Automatically disposed when widget is removed
- **Global notifiers**: Persist throughout app lifetime
- **Reference counting**: Prevents memory leaks

### 4. Clean Separation of Concerns
- **Services**: Pure business logic with Result returns
- **Notifiers**: State management with Result chaining
- **UI**: Simple state consumption with NotifierBuilder

## Dependencies

This example uses:
- [`notifier_scope`](../): For state management with automatic lifecycle
- [`flutter_package_result`](/Users/paka/dev/flutter_package_result/): For functional error handling
- `go_router`: For navigation
- `get_it`: For dependency injection

## Running the Example

1. Ensure you have the `flutter_package_result` package available locally
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

The example demonstrates a complete todo application with loading states, error handling, and modern Flutter architecture patterns.
