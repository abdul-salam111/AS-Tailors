import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/env.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../../../core/theme/theme_exports.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';
import '../../domain/usecases/signin_with_apple_usecase.dart';
import '../../domain/usecases/signin_with_google_usecase.dart';
import 'complete_sign_in.dart';

/// "Or continue with" divider + Google/Apple buttons, shared by sign-in
/// and sign-up — one tap either signs an existing user in or creates
/// their account, Supabase treats both the same way for an OAuth
/// provider. Handles its own loading state and calls [completeSignIn]
/// directly on success rather than going through `SignInBloc`/
/// `SignupBloc`, since a single OAuth round-trip has no form fields to
/// track — same reasoning as `HomeView`'s direct sign-out call.
class SocialSignInButtons extends StatefulWidget {
  const SocialSignInButtons({super.key});

  @override
  State<SocialSignInButtons> createState() => _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends State<SocialSignInButtons> {
  bool _googleLoading = false;
  bool _appleLoading = false;

  Future<void> _signIn(
    Future<Either<Failure, dynamic>> Function() call,
    void Function(bool) setLoading,
  ) async {
    setLoading(true);
    final result = await call();
    if (!mounted) return;
    setLoading(false);
    result.fold((failure) {
      if (failure is UserCancelledFailure) return;
      AppToastsUtils.showErrorTop(context, AppFailureMapper.map(failure).message);
    }, (auth) => completeSignIn(context, auth));
  }

  /// `GIDSignIn` throws a raw `NSException` (not a catchable Dart error)
  /// when `GIDClientID` isn't set in Info.plist — i.e. before native setup
  /// is done (see SECRETS.txt). That exception crosses the plugin channel
  /// and crashes the whole app, so it must be headed off before ever
  /// calling the native plugin rather than caught afterwards.
  void _onGooglePressed() {
    if (Env.googleServerClientId.isEmpty) {
      AppToastsUtils.showInfoTop(
        context,
        'Google sign-in isn\'t set up yet — see SECRETS.txt for the required setup.',
      );
      return;
    }
    _signIn(() => sl<SignInWithGoogleUsecase>()(NoParams()), (v) => setState(() => _googleLoading = v));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: context.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                context.l10n.orContinueWith,
                style: context.bodySmall.copyWith(color: context.textSecondary),
              ),
            ),
            Expanded(child: Divider(color: context.border)),
          ],
        ),
        heightBox(20),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: FontAwesomeIcons.google,
                label: 'Google',
                isLoading: _googleLoading,
                onPressed: _onGooglePressed,
              ),
            ),
            widthBox(12),
            Expanded(
              child: _SocialButton(
                icon: FontAwesomeIcons.apple,
                label: 'Apple',
                isLoading: _appleLoading,
                onPressed: () => _signIn(
                  () => sl<SignInWithAppleUsecase>()(NoParams()),
                  (v) => setState(() => _appleLoading = v),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const LoadingIndicator(size: 18)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(icon, size: 16, color: context.textPrimary),
                  widthBox(8),
                  Text(label, style: context.bodySmall.copyWith(color: context.textPrimary)),
                ],
              ),
      ),
    );
  }
}
