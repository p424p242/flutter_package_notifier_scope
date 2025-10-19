# Flutter Development Guidelines

Comprehensive guidelines for implementing Flutter applications using `@flutter_package_notifier_scope/` and `@flutter_package_result/` packages.

## 📦 Package Management

### Adding Dependencies

**ALWAYS** use `flutter pub add` for dependencies:

```bash
# ✅ CORRECT: Use flutter pub add
flutter pub add get_it
flutter pub add go_router

# ✅ CORRECT: Git dependencies (edit pubspec.yaml manually)
notifier_scope:
  git: https://github.com/p424p242/flutter_package_notifier_scope.git

result:
  git: https://github.com/p424p242/flutter_package_result.git

# ✅ CORRECT: Local development
flutter pub add notifier_scope --path ../flutter_package_notifier_scope/
flutter pub add result --path ../flutter_package_result/
```

**NEVER** manually edit `pubspec.yaml` unless absolutely necessary.

## 🏗️ Architecture & File Structure

### Recommended Directory Structure

```text
lib/
├── main.dart                 # App entry point
├── router.dart              # GoRouter configuration
├── models/                  # Data models
├── services/                # Business logic & API clients
├── notifiers/               # Business logic state management
├── pages/                   # UI pages/screens
└── widgets/                 # Reusable components
```

### Notifier Types: Business Logic vs Page-Specific

**ALWAYS** separate business logic notifiers from page-specific notifiers.

#### Business Logic Notifiers

Manage **application-wide business state** in `notifiers/` directory:

```dart
// ✅ CORRECT: Business logic notifier
class UserState {
  UserState({this.currentUser, this.isAuthenticated = false, this.isLoading = false});
  final User? currentUser;
  final bool isAuthenticated;
  final bool isLoading;

  UserState copyWith({User? currentUser, bool? isAuthenticated, bool? isLoading}) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final userNotifier = NotifierScope.global(UserNotifier(UserState()));
```

#### Page-Specific Notifiers

Manage **UI-specific state** alongside corresponding pages:

```dart
// ✅ CORRECT: Page-specific notifier
class TodoListPageState {
  TodoListPageState({this.searchQuery, this.selectedFilter = TodoFilter.all});
  final String? searchQuery;
  final TodoFilter selectedFilter;

  TodoListPageState copyWith({String? searchQuery, TodoFilter? selectedFilter}) {
    return TodoListPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

final todoListPageNotifier = NotifierScope.scoped(
  () => TodoListPageNotifier(TodoListPageState()),
);
```

### Using Multiple Notifiers

**ALWAYS** access notifiers independently in UI layer. **NEVER** create dependencies between notifiers.

```dart
// ✅ CORRECT: Independent access
class TodoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NotifierBuilder((context) {
      final userNotifier = userNotifier.instance;
      final pageNotifier = todoListPageNotifier.instance;
      final todoNotifier = todoNotifier.instance;

      // Combine data in UI layer
      return Scaffold(
        appBar: AppBar(title: Text('Todos for ${userNotifier.state.currentUser?.name}')),
        body: // UI code
      );
    });
  }
}
```

### Dependency Injection

**ALWAYS** use GetIt for services, **NEVER** for StateNotifiers:

```dart
// ✅ CORRECT: GetIt for services
void main() async {
  final getIt = GetIt.instance;
  getIt.registerSingleton<TodoService>(TodoService());
  runApp(const MainApp());
}

// ✅ CORRECT: NotifierScope for StateNotifiers
final todoNotifier = NotifierScope.global(TodoNotifier(TodoState()));

// ❌ WRONG: Never use GetIt for StateNotifiers
// getIt.registerSingleton<TodoNotifier>(TodoNotifier(TodoState()));
```

### Routing

**ALWAYS** use GoRouter:

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/todos', builder: (_, __) => const TodoListPage()),
  ],
);

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
```

## 🎯 NotifierScope Package Usage

### Avoid Stateful Widgets

**ALWAYS** prefer scoped StateNotifiers over StatefulWidgets for page-level state.

#### ❌ WRONG: StatefulWidget

```dart
class TodoListPage extends StatefulWidget {
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { /* UI code */ }
}
```

#### ✅ CORRECT: Scoped StateNotifier

```dart
class TodoListPageState {
  TodoListPageState({this.todos = const [], this.isInitialised = false});
  final List<Todo> todos;
  final bool isInitialised;

  TodoListPageState copyWith({List<Todo>? todos, bool? isInitialised}) {
    return TodoListPageState(
      todos: todos ?? this.todos,
      isInitialised: isInitialised ?? this.isInitialised,
    );
  }
}

final todoListPageNotifier = NotifierScope.scoped(
  () => TodoListPageNotifier(TodoListPageState()),
);

class TodoListPageNotifier extends StateNotifier<TodoListPageState> {
  TodoListPageNotifier(super.state);

  final TextEditingController _searchController = TextEditingController();
  final _todoService = GetIt.instance<TodoService>();

  @override
  Future<void> init() async {
    await loadTodos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  AsyncResult<List<Todo>, TodoNotifierError> loadTodos() async {
    state = state.copyWith(isLoadingTodos: true);
    final result = await _todoService.getTodos();
    return result
        .onOk((todos) => state = state.copyWith(todos: todos, isInitialised: true))
        .onError((_) => state = state.copyWith(isLoadingTodos: false))
        .mapError((_) => TodoNotifierError.getTodosError);
  }
}
```

### Async Initialization

**ALWAYS** track initialization state:

```dart
class UserProfileState {
  UserProfileState({this.user, this.isInitialised = false, this.isLoading = false});
  final User? user;
  final bool isInitialised;
  final bool isLoading;

  UserProfileState copyWith({User? user, bool? isInitialised, bool? isLoading}) {
    return UserProfileState(
      user: user ?? this.user,
      isInitialised: isInitialised ?? this.isInitialised,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
```

### Granular Loading States

**ALWAYS** use specific loading flags:

```dart
class CounterState {
  CounterState({
    required this.count,
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
  }) {
    return CounterState(
      count: count ?? this.count,
      isInitialised: isInitialised ?? this.isInitialised,
      isIncrementing: isIncrementing ?? this.isIncrementing,
      isDecrementing: isDecrementing ?? this.isDecrementing,
    );
  }
}
```

## ✅ Result Package Usage

### Error Handling Patterns

#### Services: Use Try/Catch

```dart
class TodoService {
  AsyncResult<List<Todo>, TodoServiceError> getTodos() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return Ok(List.unmodifiable(_todos));
    } catch (e) {
      return Error(TodoServiceError.unknownError);
    }
  }
}

enum TodoServiceError { notFound, unknownError }
```

#### Notifiers: Use Extension Methods (No Try/Catch)

```dart
import 'package:result/result_extensions.dart';

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(super.state);

  final _todoService = GetIt.instance<TodoService>();

  AsyncResult<List<Todo>, TodoNotifierError> getTodos() async {
    state = state.copyWith(isLoading: true);
    final serviceResult = await _todoService.getTodos();
    return serviceResult
        .onOk((todos) => state = state.copyWith(todos: todos, isLoading: false))
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => TodoNotifierError.getTodosError);
  }
}

enum TodoNotifierError { getTodosError, addTodoError }
```

### Core Principle

**NEVER** use Dart pattern matching with Result types. **ALWAYS** use extension methods.

### Error State Management

**NEVER** store error states in state models:

```dart
// ❌ WRONG: Error state stored in model
class TodoState {
  TodoState({required this.todos, this.isLoading = false, this.error});
  final List<Todo> todos;
  final bool isLoading;
  final String? error;  // ❌ Don't store errors in state
}

// ✅ CORRECT: Clean state without error storage
class TodoState {
  TodoState({required this.todos, this.isLoading = false});
  final List<Todo> todos;
  final bool isLoading;
}
```

### UI Error Handling

**ALWAYS** handle errors in UI layer:

```dart
void _handleAddTodo(BuildContext context, TodoNotifier notifier) async {
  final result = await notifier.addTodo('New Todo');
  result
    .onOk((_) => _showSuccessSnackbar(context, 'Todo added successfully'))
    .onError((error) => _handleAddTodoError(context, error));
}

void _handleAddTodoError(BuildContext context, TodoNotifierError error) {
  final message = switch (error) {
    TodoNotifierError.addTodoError => 'Failed to add todo. Please try again.',
  };
  _showErrorSnackbar(context, message);
}
```

## 🔧 Data Models

**ALWAYS** use immutable models with `copyWith`:

```dart
class Todo {
  Todo({required this.id, required this.title, this.isCompleted = false});

  factory Todo.create({required String title}) {
    return Todo(id: const Uuid().v4(), title: title);
  }

  final String id;
  final String title;
  final bool isCompleted;

  Todo copyWith({String? id, String? title, bool? isCompleted}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

## 🧪 Task Completion Verification

### Before Marking Tasks as Complete

**ALWAYS** perform these checks:

1. **Run static analysis**:
   ```bash
   flutter analyze
   ```

2. **Verify no compilation errors** exist
3. **Ensure all tests pass** (if applicable)
4. **Check that the app builds successfully**

### NEVER Run the App

**NEVER** run `flutter run` or attempt to run the application. The user will:
- Run the app themselves when ready
- Report back with any errors or debug output
- Provide specific feedback based on actual app behavior

Your role is to ensure code quality through analysis and build verification, not to test the running application.

### Error-Free Code Requirement

- **ZERO** analysis warnings or errors
- **ZERO** compilation errors
- All code follows Dart/Flutter best practices
- All imports properly organized

## 📋 Summary of Key Rules

1. **Package Management**: Always use `flutter pub add` for dependencies
2. **Dependency Injection**: Use GetIt for services, NotifierScope for StateNotifiers
3. **Routing**: Use GoRouter with `MaterialApp.router`
4. **State Management**: Use NotifierScope with immutable state and `copyWith`
5. **Notifier Separation**: Keep business logic notifiers separate from page-specific notifiers
6. **Widget Architecture**: Avoid StatefulWidgets - use scoped StateNotifiers
7. **Error Handling**: Use Result package with extension methods (never pattern matching)
8. **Data Models**: Use immutable models with `copyWith`
9. **File Structure**: Follow the recommended directory structure
10. **Code Quality**: Ensure zero analysis errors before marking tasks complete
11. **App Execution**: Never run `flutter run` - user handles app execution

## 🚀 Quick Reference

### Essential Commands

```bash
# Add dependencies
flutter pub add package_name

# Git dependencies (edit pubspec.yaml)
notifier_scope:
  git: https://github.com/p424p242/flutter_package_notifier_scope.git

result:
  git: https://github.com/p424p242/flutter_package_result.git

# Run analysis
flutter analyze

# Run tests
flutter test

# Build app
flutter build apk
```

### Essential Imports

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:notifier_scope/notifier_scope.dart';
import 'package:result/result.dart';
import 'package:result/result_extensions.dart';
```

By following these guidelines, you'll create maintainable, scalable, and error-free Flutter applications with excellent developer experience.
