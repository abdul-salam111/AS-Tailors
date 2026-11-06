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

/// Account tab — identity card, app settings (language/theme — moved here
/// from the home header, see home_view.dart's `_DashboardHeader`; plus
/// the default measurement unit, read by `MeasurementFormView` at
/// screen-open time rather than toggled per form), and sign out.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _signingOut = false;

  Future<void> _openEditProfile() async {
    final updated = await context.push<bool>(RoutePaths.editProfile);
    if (!mounted) return;
    // Always refresh, not just when `updated == true` — an avatar change
    // uploads and updates SessionController immediately on pick (no
    // separate save step), so it can reach here via a plain back
    // navigation that never sets that flag. `updated == true` only
    // reflects whether the name was explicitly saved, which is what
    // gates the toast below (the avatar's own success toast already
    // fired inline, in EditProfileView, at upload time).
    setState(() {});
    if (updated == true) {
      AppToastsUtils.showSuccessTop(context, context.l10n.profileUpdatedSuccessfully);
    }
  }

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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ProfileHeaderCard(
              name: name,
              email: session.email,
              role: session.role,
              avatarUrl: session.avatarUrl,
              onEdit: _openEditProfile,
            ),
            heightBox(24),
            Text(
              context.l10n.settings,
              style: context.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            heightBox(8),
            const _SettingsSection(),
            heightBox(28),
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
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final ShopRole? role;
  final String? avatarUrl;
  final VoidCallback onEdit;
  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: context.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.divider),
            boxShadow: [
              BoxShadow(color: context.shadow, blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: avatarUrl == null
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.brandTeal, AppColors.brandTealDeep],
                        )
                      : null,
                  image: avatarUrl != null
                      ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandTeal.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: avatarUrl == null
                    ? const Icon(Iconsax.user, color: AppColors.white, size: 34)
                    : null,
              ),
              heightBox(14),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              heightBox(4),
              Text(
                email,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall.copyWith(color: context.textSecondary),
              ),
              if (role != null) ...[
                heightBox(10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleLabel(context, role!),
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
        PositionedDirectional(top: 12, end: 12, child: _EditProfileButton(onTap: onEdit)),
      ],
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Iconsax.user_edit, size: 17, color: context.primary),
    );
    return button.onTap(onTap);
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.divider),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Iconsax.language_square,
            label: context.l10n.language,
            trailing: const LanguageToggleButton(),
          ),
          Divider(height: 1, thickness: 1, color: context.divider, indent: 58),
          _SettingsRow(
            icon: Iconsax.moon,
            label: context.l10n.appearance,
            trailing: const ThemeToggleButton(),
          ),
          Divider(height: 1, thickness: 1, color: context.divider, indent: 58),
          _SettingsRow(
            icon: Iconsax.ruler,
            label: context.l10n.unit,
            trailing: const MeasurementUnitToggleButton(),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const _SettingsRow({required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: context.primary),
          ),
          widthBox(12),
          Expanded(
            child: Text(label, style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
          trailing,
        ],
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
