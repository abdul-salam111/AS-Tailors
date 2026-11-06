import 'package:go_router/go_router.dart';
import '../core/di/di_exports.dart';
import '../core/services/session_manager.dart';
import '../features/auth/auth_exports.dart';
import '../features/customer/customer_exports.dart';
import '../features/home/home_exports.dart';
import '../features/measurement/measurement_exports.dart';
import '../features/orders/orders_exports.dart';
import '../features/profile/profile_exports.dart';
import '../features/splash/splash_exports.dart';
import 'app_shell.dart';
import 'route_names.dart';
import 'route_paths.dart';

/// Routes that do not require the user to be authenticated. Deliberately
/// just sign-in: this is a closed, single-shop deployment (not a public
/// SaaS signup funnel) — accounts are provisioned outside the app and
/// handed to whoever needs one, see scripts/create_user.dart.
const _publicRoutes = {RoutePaths.splash, RoutePaths.signin};

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final session = sl<SessionController>();
      final isLoggedIn = session.isLoggedIn;
      final location = state.matchedLocation;
      final isPublic = _publicRoutes.contains(location);

      // Unauthenticated user trying to access a protected route → signin.
      if (!isLoggedIn && !isPublic) return RoutePaths.signin;

      // Logged-in user landing on a public auth screen (not splash, which
      // handles its own routing once it resolves the session) → home.
      if (isLoggedIn && isPublic && location != RoutePaths.splash) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RoutePaths.signin,
        name: RouteNames.signin,
        builder: (context, state) => const SignInView(),
      ),
      // Bottom-nav tabs (Home/Customers/Orders/Account) — each branch keeps
      // its own Navigator/state via StatefulNavigationShell, see app_shell.dart.
      // Add/detail/edit customer screens stay OUTSIDE this shell (below) so
      // they render full-screen without the bottom nav bar, instead of
      // nesting inside the customers branch.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.customers,
                name: RouteNames.customers,
                builder: (context, state) => const CustomerListView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.orders,
                name: RouteNames.orders,
                builder: (context, state) => const OrdersView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.addCustomer,
        name: RouteNames.addCustomer,
        builder: (context, state) => const CustomerFormView(),
      ),
      GoRoute(
        path: RoutePaths.customerDetail,
        name: RouteNames.customerDetail,
        builder: (context, state) => CustomerDetailView(customerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.editCustomer,
        name: RouteNames.editCustomer,
        builder: (context, state) => CustomerFormView(customer: state.extra as CustomerEntity?),
      ),
      GoRoute(
        path: RoutePaths.addMeasurement,
        name: RouteNames.addMeasurement,
        builder: (context, state) => MeasurementFormView(customerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.addOrder,
        name: RouteNames.addOrder,
        builder: (context, state) => AddOrderView(initialCustomer: state.extra as CustomerEntity?),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileView(),
      ),
    ],
  );
}
