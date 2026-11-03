import 'package:go_router/go_router.dart';
import '../core/di/di_exports.dart';
import '../core/services/session_manager.dart';
import '../features/auth/auth_exports.dart';
import '../features/home/home_exports.dart';
import '../features/shop/shop_exports.dart';
import '../features/splash/splash_exports.dart';
import 'route_names.dart';
import 'route_paths.dart';

/// Routes that do not require the user to be authenticated.
const _publicRoutes = {RoutePaths.splash, RoutePaths.signin, RoutePaths.signup};

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
        path: RoutePaths.createShop,
        name: RouteNames.createShop,
        builder: (context, state) => const CreateShopView(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}
