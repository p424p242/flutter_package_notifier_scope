# Notifier Scope Project Overview

This document provides an overview of the `notifier_scope` Flutter package, detailing its purpose, technologies, and development conventions.

## Project Overview

`notifier_scope` is a Flutter state management package designed to provide both scoped and global notifiers with automatic lifecycle management. It aims to simplify state management in Flutter applications by offering reactive updates, type safety, and automatic disposal of state when no longer needed.

**Key Features:**
*   **Global Notifiers:** For app-wide state that persists across the entire application (e.g., user authentication, theme preferences).
*   **Scoped Notifiers:** For state that is automatically disposed when no longer used (e.g., page-specific state, form data).
*   **Automatic Lifecycle Management:** Eliminates the need for manual disposal of notifiers.
*   **Reactive Updates:** Integrates with `ChangeNotifier` for automatic UI updates.
*   **Type Safety:** Provides generic state management with compile-time safety.

**Core Components:**
*   `StateNotifier<T>`: The base class for all notifiers, extending `ChangeNotifier`.
*   `NotifierScope`: A factory for creating global and scoped notifiers.
*   `NotifierBuilder`: A widget that automatically rebuilds its child when the state of an observed notifier changes.

**Technologies:**
*   **Flutter:** UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Dart:** The programming language used by Flutter.

## Building and Running

To set up and run the `notifier_scope` project, follow these steps:

1.  **Install Dependencies:**
    Navigate to the project root and run:
    ```bash
    flutter pub get
    ```

2.  **Run the Example Application:**
    The `example/` directory contains a comprehensive demonstration of the package's features. To run it, navigate into the `example/` directory and execute:
    ```bash
    cd example/
    flutter run
    ```

3.  **Run Tests:**
    To execute the tests for the package, navigate to the project root and run:
    ```bash
    flutter test
    ```

## Development Conventions

### Linting
This project adheres to the linting rules provided by `package:flutter_lints/flutter.yaml`, ensuring consistent code style and identifying potential issues.

### Recommended File Structure
The project follows a structured approach for organizing code, as recommended in its documentation:
*   `lib/notifiers/`: Contains state notifiers (`.notifier.dart` files).
*   `lib/services/`: Contains business logic services (`.service.dart` files).
*   `lib/pages/`: Contains full-page widgets (`.page.dart` files).
*   `lib/widgets/`: Contains reusable UI components (`.widget.dart` files).
*   `lib/models/`: Contains pure data models (`.model.dart` files).
*   `lib/main.dart`: The application entry point.

## Example Usage

A detailed example application demonstrating global vs. scoped notifier behavior, theme management, counter functionality, navigation, and error handling patterns is available in the `example/` directory. This serves as a practical guide for integrating `notifier_scope` into Flutter projects.
