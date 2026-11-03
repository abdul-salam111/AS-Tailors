import 'package:go_router/go_router.dart';
import '../core/di/di_exports.dart';
import '../core/services/session_manager.dart';
import '../features/auth/auth_exports.dart';
import '../features/customer/customer_exports.dart';
import '../features/home/home_exports.dart';
import '../features/shop/shop_exports.dart';
import '../features/splash/splash_exports.dart';
import 'route_names.dart';
import 'route_paths.dart';

/// Routes that do not require the user to be authenticated.
const _publicRoutes = {
  RoutePaths.splash,
  RoutePaths.signin,
  RoutePaths.signup,
  RoutePaths.verifyEmail,
};

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final session = sl<SessionController>();
      final isLoggedIn = session.isLoggedIn;
      final hasShop = session.hasShop;
      final location = state.matchedLocation;
      final isPublic = _publicRoutes.contains(location);

      // Unauthenticated user trying to access a protected route → signin.
      if (!isLoggedIn && !isPublic) return RoutePaths.signin;

      // Logged-in user landing on a public auth screen (not splash, which
      // handles its own routing once it resolves the session) → send them
      // where they belong.
      if (isLoggedIn && isPublic && location != RoutePaths.splash) {
        return hasShop ? RoutePaths.home : RoutePaths.createShop;
      }

      // Logged-in but no shop yet → must finish onboarding first.
      if (isLoggedIn &&
          !hasShop &&
          location != RoutePaths.createShop &&
          location != RoutePaths.splash) {
        return RoutePaths.createShop;
      }

      // Already has a shop — no reason to revisit onboarding.
      if (isLoggedIn && hasShop && location == RoutePaths.createShop) {
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
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        name: RouteNames.verifyEmail,
        // No email in `extra` means this was reached some other way than
        // straight from a successful signup (e.g. a cold deep link) —
        // there's nothing to verify, so send them back to start over.
        redirect: (context, state) => state.extra is String ? null : RoutePaths.signup,
        builder: (context, state) => VerifyOtpView(email: state.extra as String),
      ),
      GoRoute(
        path: RoutePaths.createShop,
        name: RouteNames.createShop,
        builder: (context, state) => const CreateShopView(),
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
