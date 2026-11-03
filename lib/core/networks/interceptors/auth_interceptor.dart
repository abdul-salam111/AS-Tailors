import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles token injection for every outgoing Dio request (non-Supabase
/// HTTP only — see CLAUDE.md §1a; Supabase-backed calls go through
/// `BaseSupabaseDatasource` and carry their own auth via the Supabase SDK).
///
/// Two modes (set via [Options.extra] in the datasource call):
///   - default                       → injects the signed-in user's
///     Supabase JWT, read live from `SupabaseClient.auth` rather than
///     cached, so it's always current even after a token refresh.
///   - extra: {'useAppToken': true}  → injects the static app token instead
class AuthInterceptor extends Interceptor {
  final SupabaseClient _supabaseClient;
  final String _appToken;

  AuthInterceptor({required SupabaseClient supabaseClient, required String appToken})
    : _supabaseClient = supabaseClient,
      _appToken = appToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final useAppToken = options.extra['useAppToken'] == true;

    if (useAppToken) {
      options.headers['Authorization'] = 'Bearer $_appToken';
    } else {
      final userToken = _supabaseClient.auth.currentSession?.accessToken;
      if (userToken != null && userToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $userToken';
      }
    }

    handler.next(options);
  }
}
