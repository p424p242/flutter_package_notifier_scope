# Notifier Scope 🎯

A Flutter state management package providing scoped and global notifiers with automatic lifecycle management.

## Features ✨

- **🏛️ Global Notifiers** - App-wide state that persists across the entire application
- **🔗 Scoped Notifiers** - State that's automatically disposed when no longer used
- **🔄 Automatic Lifecycle Management** - No manual disposal required
- **📱 Reactive Updates** - Built-in ChangeNotifier integration
- **🎯 Type Safety** - Generic state management with compile-time safety

## Quick Start 🚀

### 1. Add the dependency

```yaml
dependencies:
  notifier_scope: ^0.1.0
```

### 2. Create a StateNotifier

```dart
class CounterState {
  CounterState({required this.count, required this.isIncrementing});
  final int? count;
  final bool isIncrementing;

  copyWith({int? count, bool? isIncrementing}) => CounterState(
    count: count ?? this.count,
    isIncrementing: isIncrementing ?? this.isIncrementing,
  );
}

class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier() : super(CounterState(count: null, isIncrementing: false));

  Future<void> increment() async {
    state = state.copyWith(isIncrementing: true);
    await Future.delayed(Duration(seconds: 1));
    state = state.copyWith(
      isIncrementing: false,
      count: (state.count ?? 0) + 1,
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

### 4. Use in Your Widgets

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Global: ${globalCounter.instance.state.count}'),
              Text('Scoped: ${scopedCounter.instance.state.count}'),
              ElevatedButton(
                onPressed: globalCounter.instance.increment,
                child: Text('Increment Global'),
              ),
              ElevatedButton(
                onPressed: scopedCounter.instance.increment,
                child: Text('Increment Scoped'),
              ),
            ],
          ),
        ),
      ),
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

### Error Handling with Result Pattern

```dart
class CounterNotifier extends StateNotifier<CounterState> {
  AsyncResult<Null, CounterError> increment() async {
    state = state.copyWith(isIncrementing: true);

    final result = await someService.updateCount();
    switch (result) {
      case Ok<int, ServiceError>(:final value):
        state = state.copyWith(isIncrementing: false, count: value);
        return Ok(null);
      case Error<int, ServiceError>():
        state = state.copyWith(isIncrementing: false);
        return Error(CounterError.incrementFailed);
    }
  }
}
```

### Service Integration

```dart
class CounterNotifier extends StateNotifier<CounterState> {
  AsyncResult<Null, CounterError> loadData() async {
    state = state.copyWith(isLoading: true);

    final service = GetIt.instance.get<CounterService>();
    switch (await service.getCount()) {
      case Ok<int, ServiceError>(:final value):
        state = state.copyWith(isLoading: false, count: value);
        return Ok(null);
      case Error<int, ServiceError>():
        state = state.copyWith(isLoading: false);
        return Error(CounterError.loadFailed);
    }
  }
}
```

## Architecture Patterns 🏛️

### Recommended File Structure

```
lib/
├── notifiers/           # State notifiers (.notifier.dart)
├── services/            # Business logic services (.service.dart)
├── pages/               # Full page widgets (.page.dart)
├── widgets/             # Reusable UI components (.widget.dart)
├── models/              # Pure data models (.model.dart)
└── main.dart            # Application entry point
```

### Example Notifier Structure

```dart
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

  AsyncResult<Null, CounterError> increment() async {
    // Implementation
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ERRORS
// ══════════════════════════════════════════════════════════════════════════

enum CounterError { incrementFailed }
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

- Global vs scoped notifier behavior
- Theme management
- Counter functionality
- Navigation between pages
- Error handling patterns

## Contributing 🤝

Contributions are welcome! Please feel free to submit issues and pull requests.

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.