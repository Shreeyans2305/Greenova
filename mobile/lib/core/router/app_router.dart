import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/dashboard/carbon_dashboard_screen.dart';
import '../../presentation/screens/history/purchase_history_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/scan/barcode_scanner_screen.dart';
import '../../presentation/screens/scan/ingredient_scanner_screen.dart';
import '../../presentation/screens/scan/sustainability_report_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/widgets/shell_scaffold.dart';

/// Route path constants
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String scan = '/scan';
  static const String barcodeScanner = '/scan/barcode';
  static const String ingredientScanner = '/scan/ingredient';
  static const String sustainabilityReport = '/report';
  static const String search = '/search';
  static const String history = '/history';
  static const String dashboard = '/dashboard';
}

/// Navigation shell key for bottom nav persistence
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App Router Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.scan,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BarcodeScannerScreen(),
            ),
            routes: [
              GoRoute(
                path: 'barcode',
                builder: (context, state) => const BarcodeScannerScreen(),
              ),
              GoRoute(
                path: 'ingredient',
                builder: (context, state) => const IngredientScannerScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PurchaseHistoryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CarbonDashboardScreen(),
            ),
          ),
        ],
      ),
      // Full screen routes (outside shell)
      GoRoute(
        path: AppRoutes.sustainabilityReport,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final reportData = state.extra as Map<String, dynamic>?;
          return SustainabilityReportScreen(reportData: reportData);
        },
      ),
    ],
  );
});
