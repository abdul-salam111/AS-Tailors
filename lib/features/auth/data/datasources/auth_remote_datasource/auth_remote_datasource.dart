import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../models/shop_membership_model.dart';

abstract interface class IAuthRemoteDatasource {
  Future<AuthResponse> signInWithPassword({required String email, required String password});
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();

  /// The currently signed-in Supabase user, if any. Synchronous — reflects
  /// the session Supabase already restored during `Supabase.initialize`.
  User? get currentUser;

  /// This user's `shop_members` row, if they belong to a shop yet.
  Future<ShopMembershipModel?> fetchMembership(String userId);
}

class AuthRemoteDatasourceImpl extends BaseSupabaseDatasource implements IAuthRemoteDatasource {
  const AuthRemoteDatasourceImpl({required super.client});

  @override
  Future<AuthResponse> signInWithPassword({required String email, required String password}) =>
      guard(() => client.auth.signInWithPassword(email: email, password: password));

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) => guard(
    () => client.auth.signUp(email: email, password: password, data: {'full_name': fullName}),
  );

  @override
  Future<void> signOut() => guard(() => client.auth.signOut());

  @override
  User? get currentUser => client.auth.currentUser;

  @override
  Future<ShopMembershipModel?> fetchMembership(String userId) => maybeSingle(
    query: () => client
        .from('shop_members')
        .select('shop_id, role')
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle(),
    parser: ShopMembershipModel.fromJson,
  );
}
