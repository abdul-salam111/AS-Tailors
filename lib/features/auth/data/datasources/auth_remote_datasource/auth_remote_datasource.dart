import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/env.dart';
import '../../../../../core/networks/exceptions/app_exceptions.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../models/shop_membership_model.dart';

abstract interface class IAuthRemoteDatasource {
  Future<AuthResponse> signInWithPassword({required String email, required String password});
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Native Google account picker, then exchanges the resulting ID token
  /// for a Supabase session. Requires `GOOGLE_SERVER_CLIENT_ID` to be
  /// configured (`.env`) and the matching provider enabled in the
  /// Supabase dashboard — see SECRETS.txt.
  Future<AuthResponse> signInWithGoogle();

  /// Native "Sign in with Apple" sheet, then exchanges the resulting
  /// identity token for a Supabase session. Requires the Apple provider
  /// to be configured in the Supabase dashboard and the capability
  /// enabled in Xcode — see SECRETS.txt.
  Future<AuthResponse> signInWithApple();

  Future<void> signOut();

  /// Exchanges the 6-digit code emailed to [email] for a real session.
  /// Requires the Supabase "Confirm signup" email template to include
  /// `{{ .Token }}` — see SECRETS.txt.
  Future<AuthResponse> verifySignupOtp({required String email, required String token});

  /// Re-sends the signup confirmation email (with a fresh code) to [email].
  Future<void> resendSignupOtp({required String email});

  /// The currently signed-in Supabase user, if any. Synchronous — reflects
  /// the session Supabase already restored during `Supabase.initialize`.
  User? get currentUser;

  /// This user's `shop_members` row, if they belong to a shop yet.
  Future<ShopMembershipModel?> fetchMembership(String userId);
}

class AuthRemoteDatasourceImpl extends BaseSupabaseDatasource implements IAuthRemoteDatasource {
  AuthRemoteDatasourceImpl({required super.client});

  Future<void>? _googleInit;

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
  Future<AuthResponse> signInWithGoogle() => guard(() async {
    try {
      await (_googleInit ??= GoogleSignIn.instance.initialize(
        serverClientId: Env.googleServerClientId.isEmpty ? null : Env.googleServerClientId,
      ));
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const UnauthorizedException('Google sign-in did not return an ID token.');
      }
      return await client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const UserCancelledException();
      throw UnauthorizedException('Google sign-in failed: ${e.description ?? e.code.name}');
    }
  });

  @override
  Future<AuthResponse> signInWithApple() => guard(() async {
    try {
      final rawNonce = _generateNonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: _sha256(rawNonce),
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const UnauthorizedException('Apple sign-in did not return an identity token.');
      }
      return await client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) throw const UserCancelledException();
      throw UnauthorizedException('Apple sign-in failed: ${e.message}');
    } on SignInWithAppleNotSupportedException catch (e) {
      throw UnauthorizedException(
        'Sign in with Apple is not available on this device/simulator: ${e.message}',
      );
    }
  });

  @override
  Future<void> signOut() => guard(() => client.auth.signOut());

  @override
  Future<AuthResponse> verifySignupOtp({required String email, required String token}) => guard(
    () => client.auth.verifyOTP(type: OtpType.signup, email: email, token: token),
  );

  @override
  Future<void> resendSignupOtp({required String email}) =>
      guard(() => client.auth.resend(type: OtpType.signup, email: email));

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

const _nonceCharset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

String _generateNonce([int length = 32]) {
  final random = Random.secure();
  return List.generate(length, (_) => _nonceCharset[random.nextInt(_nonceCharset.length)]).join();
}

String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();
