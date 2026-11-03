import 'package:supabase_flutter/supabase_flutter.dart';
import 'session_entity.dart';

/// In-memory cache of the resolved [SessionEntity] (identity + shop
/// membership), synchronously readable for the router's redirect guard.
///
/// Raw auth session storage/refresh is owned entirely by
/// `Supabase.instance.client.auth` (persisted securely by the SDK itself —
/// see `main.dart`'s `Supabase.initialize`), so this class doesn't
/// duplicate token handling. [isLoggedIn] reflects Supabase's session
/// directly; [session]/[hasShop] reflect the last value populated via
/// [setSession], since shop membership isn't something Supabase's own
/// session object knows about.
class SessionController {
  final SupabaseClient supabaseClient;

  SessionController({required this.supabaseClient});

  SessionEntity _session = SessionEntity.empty;
  SessionEntity get session => _session;

  bool get isLoggedIn => supabaseClient.auth.currentSession != null;
  bool get hasShop => _session.hasShop;

  void setSession(SessionEntity session) => _session = session;

  Future<void> clearSession() async {
    _session = SessionEntity.empty;
    await supabaseClient.auth.signOut();
  }
}
