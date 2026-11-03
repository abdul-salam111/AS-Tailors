import 'session_entity.dart';

/// Port for resolving "who is currently signed in, and what's their shop
/// membership" into a [SessionEntity]. `core` defines this interface but
/// never implements it — implementing it requires knowing about the `auth`
/// feature's domain (shop membership lookup), and `core` must stay
/// feature-agnostic (see CLAUDE.md §4). The `auth` feature provides the
/// real implementation and registers it in `register_auth.dart`; this is
/// plain dependency inversion, not a workaround.
abstract interface class ISessionResolver {
  /// Returns `null` when nobody is signed in. A non-null result may still
  /// have `shopId == null` if the user hasn't completed shop onboarding.
  Future<SessionEntity?> resolve();
}
