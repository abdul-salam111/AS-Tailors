import 'package:flutter/material.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../../../core/theme/theme_exports.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';
import '../../../../features/auth/auth_exports.dart';
import '../../../../routes/routes_exports.dart';

/// Account tab — full-screen counterpart to the quick-glance profile
/// bottom sheet on Home. Same data, same sign-out flow, just reachable
/// from the bottom nav bar instead of tapping the header avatar.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    final result = await sl<SignOutUsecase>()(NoParams());
    if (!mounted) return;
    setState(() => _signingOut = false);
    result.fold(
      (failure) => AppToastsUtils.showErrorTop(context, AppFailureMapper.map(failure).message),
      (_) {
        sl<SessionController>().clearSession();
        context.go(RoutePaths.signin);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = sl<SessionController>().session;
    final name = (session.fullName?.trim().isNotEmpty ?? false) ? session.fullName! : session.email;

    return Scaffold(
      backgroundColor: context.background,
      appBar: CustomAppBar(title: context.l10n.account, centerTitle: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Iconsax.user, color: AppColors.white, size: 32),
                    ),
                    heightBox(14),
                    Text(name, style: context.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    heightBox(4),
                    Text(
                      session.email,
                      style: context.bodySmall.copyWith(color: context.textSecondary),
                    ),
                    if (session.role != null) ...[
                      heightBox(10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _roleLabel(context, session.role!),
                          style: context.labelSmall.copyWith(
                            color: context.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              heightBox(32),
              Divider(color: context.divider),
              heightBox(24),
              CustomButton.outline(
                label: context.l10n.signOut,
                isLoading: _signingOut,
                outlineColor: context.error,
                textColor: context.error,
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _roleLabel(BuildContext context, ShopRole role) => switch (role) {
  ShopRole.owner => context.l10n.roleOwner,
  ShopRole.admin => context.l10n.roleAdmin,
  ShopRole.tailor => context.l10n.roleTailor,
  ShopRole.staff => context.l10n.roleStaff,
};
