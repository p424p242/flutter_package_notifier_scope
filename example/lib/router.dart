import 'package:example/pages/todo_list.page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const TodoListPage()),
  ],
);
