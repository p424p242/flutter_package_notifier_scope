import 'package:example/pages/page1.page.dart';
import 'package:example/pages/page2.page.dart';
import 'package:go_router/go_router.dart';

import 'pages/home.page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/page1', builder: (_, __) => const Page1()),
    GoRoute(path: '/page2', builder: (_, __) => const Page2()),
  ],
);
