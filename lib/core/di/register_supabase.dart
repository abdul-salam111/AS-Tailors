import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_dependencies.dart';

/// Must run after [Supabase.initialize] (called in `main()` before
/// [setupLocator]) — `Supabase.instance.client` throws otherwise.
Future<void> registerSupabase() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}
