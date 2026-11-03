import 'session_entity.dart';
import 'session_manager.dart';
import 'session_resolver.dart';

class SplashServices {
  final ISessionResolver _sessionResolver;
  final SessionController _sessionController;

  SplashServices({
    required ISessionResolver sessionResolver,
    required SessionController sessionController,
  }) : _sessionResolver = sessionResolver,
       _sessionController = sessionController;

  /// Resolves the current session (if any) and caches it on
  /// [SessionController] so the rest of the app — notably the router's
  /// synchronous redirect guard — can read it without an extra round trip.
  Future<SessionEntity?> resolveSession() async {
    final session = await _sessionResolver.resolve();
    if (session != null) _sessionController.setSession(session);
    return session;
  }
}
