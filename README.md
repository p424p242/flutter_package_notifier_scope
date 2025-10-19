# Notifier Scope 🎯

A Flutter state management package providing scoped and global notifiers with automatic lifecycle management, designed for modern Flutter applications with functional programming patterns.

## Features ✨

- **🏛️ Global Notifiers** - App-wide state that persists across the entire application
- **🔗 Scoped Notifiers** - State that's automatically disposed when no longer used
- **🔄 Automatic Lifecycle Management** - No manual disposal required
- **📱 Reactive Updates** - Built-in ChangeNotifier integration
- **🎯 Type Safety** - Generic state management with compile-time safety
- **🧩 Functional Programming** - Seamless integration with `flutter_package_result` extension methods
- **⚡ Granular Loading States** - Fine-grained control over different operation states
- **🚀 Async Initialization** - Built-in support for async notifier initialization

## Quick Start 🚀

### 1. Add the dependency

```yaml
dependencies:
  notifier_scope: ^0.1.0
```

### 2. Create a StateNotifier with Granular Loading States

```dart
class CounterState {
  CounterState({
    this.count = 0,
    this.isInitialised = false,
    this.isIncrementing = false,
    this.isDecrementing = false,
  });

  final int count;
  final bool isInitialised;
  final bool isIncrementing;
  final bool isDecrementing;

  CounterState copyWith({
    int? count,
    bool? isInitialised,
    bool? isIncrementing,
    bool? isDecrementing,
  }) => CounterState(
    count: count ?? this.count,
    isInitialised: isInitialised ?? this.isInitialised,
    isIncrementing: isIncrementing ?? this.isIncrementing,
    isDecrementing: isDecrementing ?? this.isDecrementing,
  );
}

class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier() : super(CounterState());

  @override
  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isInitialised: true);
  }

  Future<void> increment() async {
    state = state.copyWith(isIncrementing: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isIncrementing: false,
      count: state.count + 1,
    );
  }

  Future<void> decrement() async {
    state = state.copyWith(isDecrementing: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isDecrementing: false,
      count: state.count - 1,
    );
  }
}
```

### 3. Create Global and Scoped Instances

```dart
// Global counter - shared across entire app
final globalCounter = NotifierScope.global(CounterNotifier());

// Scoped counter - created per usage scope
final scopedCounter = NotifierScope.scoped(() => CounterNotifier());
```

### 4. Use in Your Widgets with Async Initialization

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) {
        final counter = scopedCounter.instance;
        final state = counter.state;

        // Handle initialization state
        if (!state.isInitialised) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Count: ${state.count}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: state.isIncrementing ? null : counter.increment,
                      child: state.isIncrementing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Increment'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: state.isDecrementing ? null : counter.decrement,
                      child: state.isDecrementing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Decrement'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

## Core Concepts 🧠

### Global Notifiers 🌍

Global notifiers maintain state across your entire application. They're perfect for:

- User authentication state
- App theme preferences
- Global configuration
- User profile data

```dart
final authNotifier = NotifierScope.global(AuthNotifier());
final themeNotifier = NotifierScope.global(ThemeNotifier());
```

### Scoped Notifiers 🎯

Scoped notifiers automatically dispose themselves when no longer used. Ideal for:

- Page-specific state
- Form data
- Temporary UI state
- Modal dialogs

```dart
final formNotifier = NotifierScope.scoped(() => FormNotifier());
final pageNotifier = NotifierScope.scoped(() => PageNotifier());
```

### The NotifierBuilder Widget 🏗️

Wrap your widgets with `NotifierBuilder` to automatically rebuild when state changes:

```dart
NotifierBuilder(
  (context) => YourWidget(
    // Access notifier state
    value: yourNotifier.instance.state.value,
  ),
)
```

## Advanced Usage 🚀

### Functional Programming with Result Extension Methods

NotifierScope works beautifully with the `flutter_package_result` extension methods for clean, functional state management. **Always prefer extension methods over Dart pattern matching** for cleaner, more maintainable code.

#### Service Layer Example with Functional Composition

```dart
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
}
```

### Error Handling with Result Pattern & Extension Methods

```dart
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
        .onOk((todos) => state = state.copyWith(
              todos: todos,
              isInitialised: true,
              isLoadingTodos: false,
            ))
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
}
```

## Architecture Patterns 🏛️

### Recommended File Structure

```
lib/
├── notifiers/           # Business logic state notifiers (.notifier.dart)
├── services/            # Business logic services (.service.dart)
├── pages/               # Full page widgets (.page.dart)
├── widgets/             # Reusable UI components (.widget.dart)
├── models/              # Pure data models (.model.dart)
└── main.dart            # Application entry point
```

### Business Logic vs Page-Specific Notifiers

**Business Logic Notifiers** (in `notifiers/` directory):
- Handle core application logic and data
- Manage state that represents business entities
- Use `NotifierScope.global()` for app-wide state
- Use `NotifierScope.scoped()` for page-specific business state

**Page-Specific Notifiers** (in `pages/` directory):
- Handle UI-specific state and presentation logic
- Manage temporary UI state like form validation, dialogs, etc.
- Always use `NotifierScope.scoped()` for automatic disposal
- Can access business logic notifiers independently

### Example Notifier Structure with Granular Loading States

```dart
// ══════════════════════════════════════════════════════════════════════════
//  STATE MODEL
// ══════════════════════════════════════════════════════════════════════════

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

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFIER
// ══════════════════════════════════════════════════════════════════════════

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(super.state);

  final _todoService = GetIt.instance<TodoService>();

  // ════════════════════════════════════════════════════════════════════════
  //  INITIALIZATION
  // ════════════════════════════════════════════════════════════════════════

  @override
  Future<void> init() async {
    await getTodos();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  METHODS WITH GRANULAR LOADING STATES
  // ════════════════════════════════════════════════════════════════════════

  AsyncResult<List<Todo>, TodoNotifierError> getTodos() async {
    state = state.copyWith(isLoadingTodos: true);
    final serviceResult = await _todoService.getTodos();
    return serviceResult
        .onOk((todos) => state = state.copyWith(
              todos: todos,
              isInitialised: true,
              isLoadingTodos: false,
            ))
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
}

// ══════════════════════════════════════════════════════════════════════════
//  ERRORS
// ══════════════════════════════════════════════════════════════════════════

enum TodoNotifierError {
  addTodoError,
  toggleTodoStatusError,
  removeTodoError,
  getTodosError,
}
```

## API Reference 📚

### StateNotifier<T>

The base class for all notifiers:

```dart
abstract class StateNotifier<T> extends ChangeNotifier {
  StateNotifier(T state);

  T get state;
  set state(T value);

  bool get isDisposed;
  void init();
}
```

### NotifierScope

Factory for creating global and scoped notifiers:

```dart
class NotifierScope<T extends StateNotifier> {
  factory NotifierScope.global(T notifier);
  factory NotifierScope.scoped(T Function() factory);

  T get instance;
  static void disposeGlobal();
  static void disposeAllScoped();
}
```

### NotifierBuilder

Widget that automatically rebuilds when notifier state changes:

```dart
class NotifierBuilder extends StatefulWidget {
  const NotifierBuilder(this.builder, {super.key});

  final Widget Function(BuildContext) builder;
}
```

## Example App 📱

Check out the comprehensive example in the `example/` directory that demonstrates:

- **Global vs scoped notifier behavior** - See how different notifier types behave across the app
- **Todo application with modern architecture** - Complete CRUD operations with proper state management
- **Integration with `flutter_package_result` extension methods** - Functional programming patterns throughout
- **Functional programming patterns** - Using `.onOk()`, `.onError()`, `.map()` for clean error handling
- **Async initialization** - Proper handling of notifier initialization with `isInitialised` flags
- **Granular loading states** - Fine-grained control over `isLoadingTodos`, `isAddingTodo`, `isTogglingTodo`, `isDeletingTodo`
- **Clean separation of concerns** - Services, notifiers, and UI layers properly separated
- **Automatic lifecycle management** - No manual disposal required
- **Business logic vs page-specific notifiers** - Demonstration of proper architecture patterns

## Contributing 🤝

Contributions are welcome! Please feel free to submit issues and pull requests.

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.