import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

import '../features/device/presentation/device_detail_page.dart';
import '../features/home/presentation/home_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String device = '/device';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.device,
      builder: (context, state) {
        final result = state.extra as ScanResult;
        return DeviceDetailPage(scanResult: result);
      },
    ),
  ],
);
