import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_endpoints.dart';
import '../networks/interceptors/auth_interceptor.dart';
import 'register_auth.dart';
import 'register_core.dart';
import 'register_customer.dart';
import 'register_network.dart';
import 'register_splash.dart';
import 'register_supabase.dart';

/// Global service locator instance.
/// Import this file wherever [sl] or [setupLocator] is needed.
final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Supabase.initialize() must already have run in main() before this.
  await registerSupabase();
  await registerNetwork();
  await registerCore();

  // Inserted at index 0 so the auth header is attached before the cache
  // interceptor (added in registerNetwork()) evaluates the request.
  sl<Dio>().interceptors.insert(
    0,
    AuthInterceptor(supabaseClient: sl<SupabaseClient>(), appToken: ApiEndPoints.appToken),
  );

  await registerAuth();
  await registerCustomer();
  await registerSplash();
}
