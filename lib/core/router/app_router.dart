import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/create_password_screen.dart';
import '../../features/auth/presentation/screens/first_access_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/clients/presentation/screens/client_detail_screen.dart';
import '../../features/clients/presentation/screens/clients_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/screens/new_order_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/sync/presentation/screens/sync_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

/// Notifica o [GoRouter] sempre que o estado de autenticação mudar, para que
/// o `redirect` seja reavaliado (login/logout).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

final _authRefreshProvider = Provider<_AuthRefreshNotifier>((ref) {
  return _AuthRefreshNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_authRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (authState.isLoading && !authState.hasValue && !authState.hasError) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isLoggedIn = authState.valueOrNull != null;

      const publicRoutes = {
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.firstAccess,
        AppRoutes.createPassword,
      };

      if (!isLoggedIn) {
        return publicRoutes.contains(location) ? null : AppRoutes.welcome;
      }
      if (location == AppRoutes.splash || publicRoutes.contains(location)) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.firstAccess,
        builder: (context, state) => const FirstAccessScreen(),
        routes: [
          GoRoute(
            path: 'create-password',
            builder: (context, state) => const CreatePasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.newOrder,
        builder: (context, state) => const NewOrderScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectClient,
        builder: (context, state) => const ClientsScreen(pickMode: true),
      ),
      GoRoute(
        path: AppRoutes.catalog,
        builder: (context, state) => const CatalogScreen(),
        routes: [
          GoRoute(
            path: ':productId',
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['productId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.sync,
        builder: (context, state) => const SyncScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.clients,
                builder: (context, state) => const ClientsScreen(),
                routes: [
                  GoRoute(
                    path: ':clientId',
                    builder: (context, state) => ClientDetailScreen(
                      clientId: state.pathParameters['clientId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.agenda,
                builder: (context, state) => const AgendaScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
