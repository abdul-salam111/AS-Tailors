import 'session_manager.dart';

class SplashServices {
  final SessionController _sessionController;

  SplashServices({required SessionController sessionController})
      : _sessionController = sessionController;

  Future<bool> checkLoginStatus() async {
    await _sessionController.loadSession();
    return _sessionController.isLoggedIn;
  }
}
