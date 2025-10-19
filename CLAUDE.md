# Flutter Development Guidelines

This document provides comprehensive guidelines for implementing Flutter applications using the `@flutter_package_notifier_scope/` and `@flutter_package_result/` packages.

## 📦 Package Management

### Adding Dependencies

**ALWAYS** use `flutter pub add` for adding packages:

```bash
# ✅ CORRECT: Use flutter pub add for pub.dev packages
flutter pub add get_it
flutter pub add go_router

# ✅ CORRECT: Use git for GitHub packages
Manually edit `pubspec.yaml` using the `git: https://github.com/p424p242/flutter_package_result.git` syntax.
Manually edit `pubspec.yaml` using the `git: https://github.com/p424p242/flutter_package_notifier_scope.git` syntax.

# ✅ CORRECT: Use path for local development (optional)
flutter pub add notifier_scope --path ../flutter_package_notifier_scope/
flutter pub add result --path ../flutter_package_result/

**NEVER** manually edit `pubspec.yaml` to add dependencies unless absolutely necessary.

```bash
# ❌ WRONG: Manual pubspec.yaml editing
# Don't manually add dependencies unless absolutely necessary
```

## 🏗️ Architecture & File Structure

### Recommended Directory Structure

```text
lib/
├── main.dart                 # App entry point
├── router.dart              # GoRouter configuration
├── models/                  # Data models
│   ├── user.model.dart
│   └── todo.model.dart
├── services/                # Business logic & API clients
│   ├── user.service.dart
│   └── todo.service.dart
├── notifiers/               # Business logic state management
│   ├── user.notifier.dart   # User-related business state
│   └── todo.notifier.dart   # Todo-related business state
├── pages/                   # UI pages/screens
│   ├── home.page.dart
│   ├── home.notifier.dart   # Page-specific UI state
│   └── todo_list.page.dart
│   └── todo_list.notifier.dart # Page-specific UI state
└── widgets/                 # Reusable components
    ├── custom_button.dart
    └── loading_indicator.dart
```

### Notifier Types: Business Logic vs Page-Specific

**ALWAYS** clearly differentiate between business logic notifiers and page-specific notifiers. They serve different purposes and should be kept separate.

#### Business Logic Notifiers

These manage **application-wide business state** and are typically stored in the `notifiers/` directory:

```dart
// ✅ CORRECT: Business logic notifier (in notifiers/user.notifier.dart)
class UserState {
  UserState({
    this.currentUser,
    this.isAuthenticated = false,
    this.isLoading = false,
  });

  final User? currentUser;
  final bool isAuthenticated;
  final bool isLoading;

  UserState copyWith({
    User? currentUser,
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final userNotifier = NotifierScope.global(UserNotifier(UserState()));

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(super.state);

  final _userService = GetIt.instance<UserService>();

  AsyncResult<User, UserNotifierError> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final result = await _userService.login(email, password);
    return result
        .onOk((user) => state = state.copyWith(
              currentUser: user,
              isAuthenticated: true,
              isLoading: false,
            ))
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => UserNotifierError.loginError);
  }

  AsyncResult<void, UserNotifierError> logout() async {
    state = state.copyWith(isLoading: true);
    final result = await _userService.logout();
    return result
        .onOk((_) => state = state.copyWith(
              currentUser: null,
              isAuthenticated: false,
              isLoading: false,
            ))
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => UserNotifierError.logoutError);
  }
}
```

#### Page-Specific Notifiers

These manage **UI-specific state** and are stored alongside their corresponding pages:

```dart
// ✅ CORRECT: Page-specific notifier (in pages/todo_list.notifier.dart)
class TodoListPageState {
  TodoListPageState({
    this.searchQuery,
    this.selectedFilter = TodoFilter.all,
    this.isSearching = false,
    this.isFiltering = false,
  });

  final String? searchQuery;
  final TodoFilter selectedFilter;
  final bool isSearching;
  final bool isFiltering;

  TodoListPageState copyWith({
    String? searchQuery,
    TodoFilter? selectedFilter,
    bool? isSearching,
    bool? isFiltering,
  }) {
    return TodoListPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isSearching: isSearching ?? this.isSearching,
      isFiltering: isFiltering ?? this.isFiltering,
    );
  }
}

final todoListPageNotifier = NotifierScope.scoped(
  () => TodoListPageNotifier(TodoListPageState()),
);

class TodoListPageNotifier extends StateNotifier<TodoListPageState> {
  TodoListPageNotifier(super.state);

  final TextEditingController _searchController = TextEditingController();

  @override
  Future<void> init() async {
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    state = state.copyWith(searchQuery: query, isSearching: true);
    // Debounce search logic here
  }

  void updateFilter(TodoFilter filter) {
    state = state.copyWith(selectedFilter: filter, isFiltering: true);
    // Filter logic here
  }
}
```

### Using Multiple Notifiers Together

**ALWAYS** keep notifiers separate and access them independently in the UI layer. **NEVER** create dependencies between notifiers.

#### ✅ CORRECT: Independent Notifier Access in UI

```dart
// ✅ CORRECT: Access both notifiers independently in UI
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) {
        // Access business logic notifier
        final userNotifier = userNotifier.instance;
        final userState = userNotifier.state;

        // Access page-specific notifier
        final pageNotifier = todoListPageNotifier.instance;
        final pageState = pageNotifier.state;

        // Access business data notifier
        final todoNotifier = todoNotifier.instance;
        final todoState = todoNotifier.state;

        // Combine data in UI layer
        final filteredTodos = _filterTodos(
          todoState.todos,
          pageState.searchQuery,
          pageState.selectedFilter,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Todos for ${userState.currentUser?.name ?? "User"}'),
            actions: [
              // User-related actions
              if (userState.isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => userNotifier.logout(),
                ),
              // Page-specific actions
              PopupMenuButton<TodoFilter>(
                onSelected: pageNotifier.updateFilter,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: TodoFilter.all,
                    child: Text('All'),
                  ),
                  const PopupMenuItem(
                    value: TodoFilter.completed,
                    child: Text('Completed'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Page-specific UI controls
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: pageNotifier._searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search todos...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              // Business data display
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return ListTile(
                      title: Text(todo.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => todoNotifier.deleteTodo(todo.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Todo> _filterTodos(
    List<Todo> todos,
    String? searchQuery,
    TodoFilter filter,
  ) {
    // Combine filtering logic in UI layer
    var filtered = todos;

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where(
        (todo) => todo.title.toLowerCase().contains(searchQuery.toLowerCase()),
      ).toList();
    }

    // Apply status filter
    switch (filter) {
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
      case TodoFilter.pending:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
      case TodoFilter.all:
      default:
        // No additional filtering
        break;
    }

    return filtered;
  }
}
```

#### ❌ WRONG: Notifier Dependencies

```dart
// ❌ WRONG: Creating dependencies between notifiers
class TodoListPageNotifier extends StateNotifier<TodoListPageState> {
  TodoListPageNotifier(super.state);

  final _userNotifier = userNotifier.instance; // ❌ Don't do this!
  final _todoNotifier = todoNotifier.instance; // ❌ Don't do this!

  @override
  Future<void> init() async {
    // ❌ Don't create dependencies between notifiers
    _userNotifier.addListener(_onUserChanged);
    _todoNotifier.addListener(_onTodosChanged);
  }

  void _onUserChanged() {
    // ❌ This creates tight coupling
    final user = _userNotifier.state.currentUser;
    // ...
  }
}
```

### Key Principles for Notifier Separation

1. **Business Logic Notifiers**:
   - Manage application-wide business state
   - Use `NotifierScope.global()` for app-wide access
   - Located in `notifiers/` directory
   - Examples: User authentication, app settings, feature flags

2. **Page-Specific Notifiers**:
   - Manage UI-specific state for a single page
   - Use `NotifierScope.scoped()` for page lifecycle
   - Located alongside their corresponding pages
   - Examples: Search queries, form state, scroll position

3. **Data Notifiers**:
   - Manage business data (todos, products, etc.)
   - Use `NotifierScope.global()` or `scoped()` based on scope
   - Located in `notifiers/` directory
   - Examples: Todo list, product catalog, user profiles

4. **Separation Rules**:
   - **NEVER** create dependencies between notifiers
   - **ALWAYS** access multiple notifiers in the UI layer
   - **NEVER** listen to one notifier from another
   - **ALWAYS** keep business logic separate from UI state

### Dependency Injection with GetIt

**ALWAYS** use GetIt for service registration in `main.dart`:

```dart
// ✅ CORRECT: Register services in main.dart
void main() async {
  final getIt = GetIt.instance;

  getIt.registerSingleton<TodoService>(TodoService());
  getIt.registerSingleton<UserService>(UserService());

  runApp(const MainApp());
}
```

### Routing with GoRouter

**ALWAYS** use GoRouter for navigation:

```dart
// ✅ CORRECT: Define routes in router.dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/todos', builder: (_, __) => const TodoListPage()),
  ],
);

// ✅ CORRECT: Use MaterialApp.router
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
```

## 🎯 NotifierScope Package Usage

### Avoid Stateful Widgets - Use Scoped StateNotifiers

**ALWAYS** prefer scoped StateNotifiers over StatefulWidgets for page-level state management. This centralizes disposal logic and makes resource management much cleaner.

#### Why Avoid StatefulWidgets?

```dart
// ❌ WRONG: StatefulWidget with manual controller management
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI code...
  }
}
```

#### ✅ CORRECT: Use Scoped StateNotifier with Controllers

```dart
// ✅ CORRECT: Page-specific notifier with controllers and initialization tracking
class TodoListPageState {
  TodoListPageState({
    this.todos = const [],
    this.isInitialised = false,
    this.isLoadingTodos = false,
    this.isAddingTodo = false,
    this.isDeletingTodo = false,
    this.isTogglingTodo = false,
  });

  final List<Todo> todos;
  final bool isInitialised;
  final bool isLoadingTodos;
  final bool isAddingTodo;
  final bool isDeletingTodo;
  final bool isTogglingTodo;

  TodoListPageState copyWith({
    List<Todo>? todos,
    bool? isInitialised,
    bool? isLoadingTodos,
    bool? isAddingTodo,
    bool? isDeletingTodo,
    bool? isTogglingTodo,
  }) {
    return TodoListPageState(
      todos: todos ?? this.todos,
      isInitialised: isInitialised ?? this.isInitialised,
      isLoadingTodos: isLoadingTodos ?? this.isLoadingTodos,
      isAddingTodo: isAddingTodo ?? this.isAddingTodo,
      isDeletingTodo: isDeletingTodo ?? this.isDeletingTodo,
      isTogglingTodo: isTogglingTodo ?? this.isTogglingTodo,
    );
  }
}

final todoListPageNotifier = NotifierScope.scoped(
  () => TodoListPageNotifier(TodoListPageState()),
);

class TodoListPageNotifier extends StateNotifier<TodoListPageState> {
  TodoListPageNotifier(super.state);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _todoService = GetIt.instance<TodoService>();

  @override
  Future<void> init() async {
    await loadTodos();

    // Set up controller listeners
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScrollChanged);
  }

  @override
  void dispose() {
    // Centralized disposal - automatically called when widget tree disposes
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Handle search changes
    final query = _searchController.text;
    // Update state based on search
  }

  void _onScrollChanged() {
    // Handle scroll events
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      loadMoreTodos();
    }
  }

  AsyncResult<List<Todo>, TodoNotifierError> loadTodos() async {
    state = state.copyWith(isLoadingTodos: true);
    final result = await _todoService.getTodos();
    return result
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
    final result = await _todoService.addTodo(title);
    return result
        .onOk((todo) => state = state.copyWith(
              todos: [...state.todos, todo],
              isAddingTodo: false,
            ))
        .onError((_) => state = state.copyWith(isAddingTodo: false))
        .mapError((_) => TodoNotifierError.addTodoError);
  }

  AsyncResult<void, TodoNotifierError> deleteTodo(String id) async {
    state = state.copyWith(isDeletingTodo: true);
    final result = await _todoService.removeTodo(id);
    return result
        .onOk((_) => state = state.copyWith(
              todos: state.todos.where((todo) => todo.id != id).toList(),
              isDeletingTodo: false,
            ))
        .onError((_) => state = state.copyWith(isDeletingTodo: false))
        .mapError((_) => TodoNotifierError.removeTodoError);
  }

  AsyncResult<Todo, TodoNotifierError> toggleTodo(String id) async {
    state = state.copyWith(isTogglingTodo: true);
    final result = await _todoService.toggleTodoStatus(id);
    return result
        .onOk((updatedTodo) => state = state.copyWith(
              todos: state.todos
                  .map((todo) => todo.id == id ? updatedTodo : todo)
                  .toList(),
              isTogglingTodo: false,
            ))
        .onError((_) => state = state.copyWith(isTogglingTodo: false))
        .mapError((_) => TodoNotifierError.toggleTodoStatusError);
  }
}
```

#### ✅ CORRECT: Stateless Widget with Scoped Notifier and Initialization Checks

```dart
// ✅ CORRECT: Clean stateless widget with initialization and loading state handling
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) {
        final pageNotifier = todoListPageNotifier.instance;
        final state = pageNotifier.state;

        // Handle initialization state
        if (!state.isInitialised && state.isLoadingTodos) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!state.isInitialised) {
          return Scaffold(
            appBar: AppBar(title: const Text('Todos')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Failed to load todos'),
                  SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final todos = state.todos;
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: pageNotifier._searchController,
              decoration: const InputDecoration(
                hintText: 'Search todos...',
                border: InputBorder.none,
              ),
            ),
          ),
          body: Stack(
            children: [
              if (state.isLoadingTodos)
                const Center(child: CircularProgressIndicator())
              else if (todos.isEmpty)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checklist_rounded, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No todos yet!'),
                      SizedBox(height: 8),
                      Text(
                        'Add your first todo to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  controller: pageNotifier._scrollController,
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      title: Text(todo.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isTogglingTodo)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Checkbox(
                              value: todo.isCompleted,
                              onChanged: state.isDeletingTodo || state.isAddingTodo
                                  ? null
                                  : (value) => pageNotifier.toggleTodo(todo.id),
                            ),
                          const SizedBox(width: 8),
                          if (state.isDeletingTodo)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: state.isAddingTodo || state.isTogglingTodo
                                  ? null
                                  : () => pageNotifier.deleteTodo(todo.id),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              if (state.isAddingTodo)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: state.isAddingTodo || state.isDeletingTodo || state.isTogglingTodo
                ? null
                : () => _showAddTodoDialog(context, pageNotifier),
            child: state.isAddingTodo
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context, TodoListPageNotifier notifier) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter todo title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  await notifier.addTodo(title);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
```

#### Benefits of This Approach

1. **Centralized Disposal**: All controllers and resources are disposed in one place
2. **Automatic Cleanup**: NotifierScope automatically disposes scoped notifiers when the widget tree disposes
3. **Better Separation**: Business logic is separated from UI code
4. **Testability**: Notifiers can be easily tested without widget dependencies
5. **Reusability**: Same notifier can be used across multiple widgets if needed

### Async Initialization Patterns

**ALWAYS** track initialization state for StateNotifiers that require async setup. This prevents accessing uninitialized data and provides better UX.

#### ✅ CORRECT: Track Initialization State

```dart
// ✅ CORRECT: State with initialization tracking
class UserProfileState {
  UserProfileState({
    this.user,
    this.isInitialised = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isUpdating = false,
  });

  final User? user;
  final bool isInitialised;
  final bool isLoading;
  final bool isRefreshing;
  final bool isUpdating;

  UserProfileState copyWith({
    User? user,
    bool? isInitialised,
    bool? isLoading,
    bool? isRefreshing,
    bool? isUpdating,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      isInitialised: isInitialised ?? this.isInitialised,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier(super.state);

  final _userService = GetIt.instance<UserService>();

  @override
  Future<void> init() async {
    await loadUserProfile();
  }

  AsyncResult<User, UserNotifierError> loadUserProfile() async {
    state = state.copyWith(isLoading: true);
    final result = await _userService.getCurrentUser();
    return result
        .onOk((user) => state = state.copyWith(
              user: user,
              isInitialised: true,
              isLoading: false,
            ))
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => UserNotifierError.loadProfileError);
  }

  AsyncResult<User, UserNotifierError> refreshUserProfile() async {
    state = state.copyWith(isRefreshing: true);
    final result = await _userService.getCurrentUser();
    return result
        .onOk((user) => state = state.copyWith(user: user, isRefreshing: false))
        .onError((_) => state = state.copyWith(isRefreshing: false))
        .mapError((_) => UserNotifierError.refreshProfileError);
  }

  AsyncResult<User, UserNotifierError> updateUserProfile(User updatedUser) async {
    state = state.copyWith(isUpdating: true);
    final result = await _userService.updateUser(updatedUser);
    return result
        .onOk((user) => state = state.copyWith(user: user, isUpdating: false))
        .onError((_) => state = state.copyWith(isUpdating: false))
        .mapError((_) => UserNotifierError.updateProfileError);
  }
}
```

#### ✅ CORRECT: UI with Initialization Checks

```dart
// ✅ CORRECT: Check initialization state in UI
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) {
        final userNotifier = userProfileNotifier.instance;
        final state = userNotifier.state;

        // Handle different states
        if (!state.isInitialised && state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!state.isInitialised) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64),
                  SizedBox(height: 16),
                  Text('Failed to load profile'),
                ],
              ),
            ),
          );
        }

        final user = state.user!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (state.isRefreshing)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => userNotifier.refreshUserProfile(),
                ),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User profile content
                  Text('Name: ${user.name}'),
                  Text('Email: ${user.email}'),
                  // ...
                ],
              ),
              if (state.isUpdating)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
```

### Granular Loading States

**ALWAYS** use specific loading flags for different operations rather than a single generic `isLoading` flag. This allows for more precise UI feedback.

#### ✅ CORRECT: Granular Loading States

```dart
// ✅ CORRECT: Specific loading states for different operations
class CounterState {
  CounterState({
    required this.count,
    this.isInitialised = false,
    this.isIncrementing = false,
    this.isDecrementing = false,
    this.isResetting = false,
  });

  final int count;
  final bool isInitialised;
  final bool isIncrementing;
  final bool isDecrementing;
  final bool isResetting;

  CounterState copyWith({
    int? count,
    bool? isInitialised,
    bool? isIncrementing,
    bool? isDecrementing,
    bool? isResetting,
  }) {
    return CounterState(
      count: count ?? this.count,
      isInitialised: isInitialised ?? this.isInitialised,
      isIncrementing: isIncrementing ?? this.isIncrementing,
      isDecrementing: isDecrementing ?? this.isDecrementing,
      isResetting: isResetting ?? this.isResetting,
    );
  }
}

class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier(super.state);

  @override
  Future<void> init() async {
    // Simulate async initialization
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isInitialised: true);
  }

  AsyncResult<int, CounterNotifierError> increment() async {
    state = state.copyWith(isIncrementing: true);
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate work
    final newCount = state.count + 1;
    state = state.copyWith(count: newCount, isIncrementing: false);
    return Ok(newCount);
  }

  AsyncResult<int, CounterNotifierError> decrement() async {
    state = state.copyWith(isDecrementing: true);
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate work
    final newCount = state.count - 1;
    state = state.copyWith(count: newCount, isDecrementing: false);
    return Ok(newCount);
  }

  AsyncResult<int, CounterNotifierError> reset() async {
    state = state.copyWith(isResetting: true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate work
    state = state.copyWith(count: 0, isResetting: false);
    return Ok(0);
  }
}
```

#### ✅ CORRECT: UI with Granular Loading Feedback

```dart
// ✅ CORRECT: Specific UI feedback for different operations
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) {
        final counterNotifier = counterNotifier.instance;
        final state = counterNotifier.state;

        if (!state.isInitialised) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Counter')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isResetting)
                  const CircularProgressIndicator()
                else
                  Text(
                    'Count: ${state.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.isDecrementing || state.isResetting
                          ? null
                          : () => counterNotifier.decrement(),
                      icon: state.isDecrementing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.remove),
                      label: const Text('Decrement'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: state.isIncrementing || state.isResetting
                          ? null
                          : () => counterNotifier.increment(),
                      icon: state.isIncrementing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: const Text('Increment'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: state.isResetting
                      ? null
                      : () => counterNotifier.reset(),
                  icon: state.isResetting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Reset'),
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

### StateNotifier Composition Guidelines

When composing StateNotifiers that depend on each other, **ALWAYS** handle initialization dependencies carefully:

```dart
// ✅ CORRECT: Handle dependencies between notifiers
class AppState {
  AppState({
    this.user,
    this.todos = const [],
    this.isInitialised = false,
    this.isLoadingUser = false,
    this.isLoadingTodos = false,
  });

  final User? user;
  final List<Todo> todos;
  final bool isInitialised;
  final bool isLoadingUser;
  final bool isLoadingTodos;

  AppState copyWith({
    User? user,
    List<Todo>? todos,
    bool? isInitialised,
    bool? isLoadingUser,
    bool? isLoadingTodos,
  }) {
    return AppState(
      user: user ?? this.user,
      todos: todos ?? this.todos,
      isInitialised: isInitialised ?? this.isInitialised,
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      isLoadingTodos: isLoadingTodos ?? this.isLoadingTodos,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier(super.state);

  final _userService = GetIt.instance<UserService>();
  final _todoService = GetIt.instance<TodoService>();

  @override
  Future<void> init() async {
    await _loadUserAndTodos();
  }

  AsyncResult<void, AppNotifierError> _loadUserAndTodos() async {
    state = state.copyWith(isLoadingUser: true, isLoadingTodos: true);

    final userResult = await _userService.getCurrentUser();
    final todosResult = await _todoService.getTodos();

    // Wait for both operations to complete
    final results = await Future.wait([userResult, todosResult]);

    return results[0]
        .andThen((user) => results[1].map((todos) => (user, todos)))
        .onOk((data) {
          final (user, todos) = data;
          state = state.copyWith(
            user: user,
            todos: todos,
            isInitialised: true,
            isLoadingUser: false,
            isLoadingTodos: false,
          );
        })
        .onError((_) => state = state.copyWith(
              isLoadingUser: false,
              isLoadingTodos: false,
            ))
        .mapError((_) => AppNotifierError.initializationError);
  }
}
```

### State Management Pattern

**ALWAYS** follow this pattern for state management:

#### 1. Define State Class

```dart
// ✅ CORRECT: Immutable state with copyWith
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
```

#### 2. Define Error Types

```dart
// ✅ CORRECT: Use enums for error types
enum TodoNotifierError {
  addTodoError,
  toggleTodoStatusError,
  removeTodoError,
  getTodosError,
}
```

#### 3. Create Notifier Scope

```dart
// ✅ CORRECT: Use scoped notifiers for local state
final todoNotifierScoped = NotifierScope.scoped(
  () => TodoNotifier(TodoState(todos: const [])),
);

// ✅ CORRECT: Use global notifiers for app-wide state
final todoNotifierGlobal = NotifierScope.global(
  TodoNotifier(TodoState(todos: const [])),
);
```

#### 4. Implement Notifier

```dart
// ✅ CORRECT: Extend StateNotifier and use Result pattern
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
        .onOk(
          (todo) => state = state.copyWith(
            todos: [...state.todos, todo],
            isLoading: false,
          ),
        )
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => TodoNotifierError.addTodoError);
  }
}
```

### UI Integration

**ALWAYS** use `NotifierBuilder` for UI integration:

```dart
// ✅ CORRECT: Use NotifierBuilder for reactive UI
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) {
        final todoNotifier = todoNotifierScoped.instance;
        final todos = todoNotifier.state.todos;
        final isLoading = todoNotifier.state.isLoading;

        return Scaffold(
          // Build UI using state
          body: isLoading
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return ListTile(
                    title: Text(todo.title),
                    onTap: () => todoNotifier.toggleTodoStatus(todo.id),
                  );
                },
              ),
        );
      },
    );
  }
}
```

## ✅ Result Package Usage

### Error Handling Patterns: Services vs Notifiers

**ALWAYS** follow these patterns for error handling:

#### Services/Repositories: Use Try/Catch for Error-Prone Operations

```dart
// ✅ CORRECT: Use try/catch in services for error-prone operations
class TodoService {
  final List<Todo> _todos = [];

  AsyncResult<List<Todo>, TodoServiceError> getTodos() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return Ok(List.unmodifiable(_todos));
    } catch (e) {
      return Error(TodoServiceError.unknownError);
    }
  }

  AsyncResult<Todo, TodoServiceError> addTodo(String title) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final newTodo = Todo.create(title: title);
      _todos.add(newTodo);
      return Ok(newTodo);
    } catch (e) {
      return Error(TodoServiceError.unknownError);
    }
  }
}

enum TodoServiceError { notFound, unknownError }
```

#### Notifiers: Use Result Extension Methods (No Try/Catch Needed)

**NEVER** use try/catch in notifiers. **ALWAYS** use result extension methods for clean, functional-style error handling:

```dart
// ✅ CORRECT: Use result extension methods in notifiers (no try/catch)
import 'package:result/result_extensions.dart';  // Import extension methods

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

  AsyncResult<Todo, TodoNotifierError> addTodo(String title) async {
    state = state.copyWith(isLoading: true);
    final serviceResult = await _todoService.addTodo(title);
    return serviceResult
        .onOk(
          (todo) => state = state.copyWith(
            todos: [...state.todos, todo],
            isLoading: false,
          ),
        )
        .onError((_) => state = state.copyWith(isLoading: false))
        .mapError((_) => TodoNotifierError.addTodoError);
  }
}
```

### Core Principle: Extension Methods > Pattern Matching

**NEVER** use Dart pattern matching (`switch` statements) with Result types. **ALWAYS** use extension methods.

### Service Layer Pattern

```dart
// ✅ CORRECT: Use Result with try/catch in service layer
class TodoService {
  final List<Todo> _todos = [];

  AsyncResult<List<Todo>, TodoServiceError> getTodos() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return Ok(List.unmodifiable(_todos));
    } catch (e) {
      return Error(TodoServiceError.unknownError);
    }
  }

  AsyncResult<Todo, TodoServiceError> addTodo(String title) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final newTodo = Todo.create(title: title);
      _todos.add(newTodo);
      return Ok(newTodo);
    } catch (e) {
      return Error(TodoServiceError.unknownError);
    }
  }
}

enum TodoServiceError { notFound, unknownError }
```

### Result Transformation Patterns

#### Chaining Operations

```dart
// ✅ CORRECT: Chain operations with andThen
AsyncResult<String, String> processUser(int userId) async {
  return await fetchUser(userId)
    .andThen((user) => validateUser(user))
    .andThen((validUser) => saveUser(validUser))
    .map((savedUser) => 'User processed: ${savedUser.name}')
    .mapError((error) => 'Processing failed: $error');
}
```

#### Error Recovery

```dart
// ✅ CORRECT: Use orElse for fallbacks
AsyncResult<String, String> fetchWithFallback(String url) async {
  return await fetchFromPrimary(url)
    .orElse((error) => fetchFromSecondary(url))
    .orElse((error) => fetchFromCache(url))
    .getOrElse((error) => 'Default content');
}
```

#### Side Effects

```dart
// ✅ CORRECT: Use tap/onOk/onError for side effects
void handleResult(Result<int, String> result) {
  result
    .onOk((value) => print('Success: $value'))
    .onError((error) => print('Error: $error'));
}
```

### Anti-Patterns to Avoid

```dart
// ❌ WRONG: Pattern matching
String describeResult(Result<int, String> result) {
  switch (result) {
    case Ok(:final value):
      return 'Success: $value';
    case Error(:final error):
      return 'Error: $error';
  }
}

// ✅ CORRECT: Use fold
String describeResult(Result<int, String> result) {
  return result.fold(
    (value) => 'Success: $value',
    (error) => 'Error: $error',
  );
}
```

## 🔧 Data Models

**ALWAYS** use immutable models with `copyWith`:

```dart
// ✅ CORRECT: Immutable model with copyWith
class Todo {
  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory Todo.create({required String title}) {
    return Todo(
      id: const Uuid().v4(),
      title: title,
    );
  }

  final String id;
  final String title;
  final bool isCompleted;

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
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

1. **Run static analysis** using one of these methods:
   ```bash
   # Option 1: Use flutter analyze (preferred for CI)
   flutter analyze

   # Option 2: Use Dart MCP server (preferred for development)
   # Ensure the Dart MCP server is running and shows no errors
```

2. **Verify no compilation errors** exist
3. **Ensure all tests pass** (if applicable)
4. **Check that the app builds successfully**

### Error-Free Code Requirement

- **ZERO** analysis warnings or errors must be present
- **ZERO** compilation errors must exist
- All code must follow Dart/Flutter best practices
- All imports must be properly organized

## 📋 Summary of Key Rules

1. **Package Management**: Always use `flutter pub add` for dependencies
2. **Dependency Injection**: Use GetIt for service registration in `main.dart`
3. **Routing**: Use GoRouter with `MaterialApp.router`
4. **State Management**: Use NotifierScope with immutable state and `copyWith`
5. **Notifier Separation**: Keep business logic notifiers separate from page-specific notifiers
6. **Widget Architecture**: Avoid StatefulWidgets - use scoped StateNotifiers for page-level state
7. **Error Handling**: Use Result package with extension methods (never pattern matching)
8. **Data Models**: Use immutable models with `copyWith`
9. **File Structure**: Follow the recommended directory structure
10. **Code Quality**: Ensure zero analysis errors before marking tasks complete

## 🚀 Quick Reference

### Essential Commands

```bash
# Add dependencies
flutter pub add package_name

# Add git dependencies (manually edit pubspec.yaml)
notifier_scope:
  git: https://github.com/p424p242/flutter_package_notifier_scope.git

result:
  git: https://github.com/p424p242/flutter_package_result.git

# Add local packages (for development)
flutter pub add notifier_scope --path ../flutter_package_notifier_scope/
flutter pub add result --path ../flutter_package_result/

# Run analysis
flutter analyze

# Run tests
flutter test

# Build app
flutter build apk  # or ios, web, etc.
```

### Essential Imports

```dart
// Core Flutter
import 'package:flutter/material.dart';

// Routing
import 'package:go_router/go_router.dart';

// Dependency Injection
import 'package:get_it/get_it.dart';

// State Management
import 'package:notifier_scope/notifier_scope.dart';

// Error Handling
import 'package:result/result.dart';
import 'package:result/result_extensions.dart';  // For extension methods
```

By following these guidelines, you'll create maintainable, scalable, and error-free Flutter applications with excellent developer experience.
