import 'package:flutter/material.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/services/session_entity.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../routes/routes_exports.dart';
import '../../domain/entities/auth_entity.dart';

/// Persists [auth] as the active session and routes to home — the one
/// piece of post-auth logic shared by the email/password flow
/// (`SignInBloc`'s listener) and the Google/Apple buttons (which skip the
/// bloc entirely, since a single OAuth call has no multi-field state to
/// track — see `features/home/presentation/views/home_view.dart`'s
/// sign-out for the same direct-usecase-call pattern).
void completeSignIn(BuildContext context, AuthEntity auth) {
  sl<SessionController>().setSession(
    SessionEntity(
      userId: auth.userId,
      email: auth.email,
      fullName: auth.fullName,
      shopId: auth.shopId,
      role: auth.role,
    ),
  );
  AppToastsUtils.showSuccessTop(context, context.l10n.youHaveLoggedInSuccessfully);
  context.go(RoutePaths.home);
}
