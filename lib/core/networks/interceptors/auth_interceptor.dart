import 'package:dio/dio.dart';
import '../../services/session_manager.dart';

/// Handles token injection for every outgoing request.
///
/// Two modes (set via [Options.extra] in the datasource call):
///   - default              → injects the logged-in user's Bearer token
///   - extra: {'useAppToken': true} → injects the static app token instead
class AuthInterceptor extends Interceptor {
  final SessionController _sessionController;
  final String _appToken;

  AuthInterceptor({
    required SessionController sessionController,
    required String appToken,
  })  : _sessionController = sessionController,
        _appToken = appToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final useAppToken = options.extra['useAppToken'] == true;

    if (useAppToken) {
      options.headers['Authorization'] = 'Bearer $_appToken';
    } else {
      final userToken = _sessionController.session.accessToken;
      if (userToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $userToken';
      }
    }

    handler.next(options);
  }
}
