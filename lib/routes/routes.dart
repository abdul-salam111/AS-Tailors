import 'package:go_router/go_router.dart';
import '../core/di/di_exports.dart';
import '../core/services/session_manager.dart';
import '../features/auth/auth_exports.dart';
import '../features/splash/splash_exports.dart';
import 'route_names.dart';
import 'route_paths.dart';


/// Routes that do not require the user to be authenticated.
const _publicRoutes = {RoutePaths.splash, RoutePaths.signin, RoutePaths.signup};

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final isLoggedIn = sl<SessionController>().isLoggedIn;
      final location = state.matchedLocation;
      final isPublic = _publicRoutes.contains(location);

      // Unauthenticated user trying to access a protected route → signin
      if (!isLoggedIn && !isPublic) return RoutePaths.signin;

      // Logged-in user landing on signin → send to home
      // Uncomment once the home route exists:
      // if (isLoggedIn && location == RoutePaths.signin) return RoutePaths.home;

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
    ],
  );
}
