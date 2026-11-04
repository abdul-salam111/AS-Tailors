import 'package:go_router/go_router.dart';
import '../core/di/di_exports.dart';
import '../core/services/session_manager.dart';
import '../features/auth/auth_exports.dart';
import '../features/customer/customer_exports.dart';
import '../features/home/home_exports.dart';
import '../features/splash/splash_exports.dart';
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
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: RoutePaths.customers,
        name: RouteNames.customers,
        builder: (context, state) => const CustomerListView(),
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
    ],
  );
}
