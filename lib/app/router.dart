import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_page.dart';

class AppRoutes {
  static const String home = '/';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
