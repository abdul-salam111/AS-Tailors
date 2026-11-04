import 'package:flutter/material.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/const_exports.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/services/session_entity.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../../../core/theme/theme_exports.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';
import '../../../../features/auth/auth_exports.dart';
import '../../../../routes/routes_exports.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

/// The real FR-011 dashboard. Only customer counts are wired to real data
/// today (see CLAUDE.md's gap list — orders/measurements/payments don't
/// exist as features yet), so those sections are deliberately styled as
/// "coming soon" rather than showing fabricated numbers.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<DashboardCubit>()..loadStats(), child: const _HomeBody());
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> with TickerProviderStateMixin {
  late final _entrance = EntranceChoreography(this);
  bool _signingOut = false;

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
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

  void _openProfileSheet() {
    final session = sl<SessionController>().session;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _ProfileSheet(
        session: session,
        signingOut: _signingOut,
        onSignOut: () {
          Navigator.of(sheetContext).pop();
          _signOut();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = sl<SessionController>().session;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().loadStats(),
          color: context.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _entrance.fadeSlideUp(
                  _entrance.interval(0.0, 0.4),
                  _TopBar(onProfileTap: _openProfileSheet),
                ),
                heightBox(18),
                _entrance.fadeSlideUp(
                  _entrance.interval(0.08, 0.5),
                  _GreetingCard(session: session),
                ),
                heightBox(18),
                _entrance.fadeSlideUp(_entrance.interval(0.18, 0.6), const _StatsRow()),
                heightBox(28),
                _entrance.fadeSlideUp(
                  _entrance.interval(0.28, 0.7),
                  _SectionTitle(context.l10n.quickActions),
                ),
                heightBox(12),
                _entrance.fadeSlideUp(_entrance.interval(0.32, 0.74), const _QuickActionsRow()),
                heightBox(28),
                _entrance.fadeSlideUp(
                  _entrance.interval(0.4, 0.8),
                  _SectionTitle(context.l10n.comingSoon),
                ),
                heightBox(12),
                _entrance.fadeSlideUp(_entrance.interval(0.46, 0.86), const _ComingSoonGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  const _TopBar({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: context.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: const AppLogo(),
        ),
        widthBox(10),
        Text(
          context.l10n.appName,
          style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const LanguageToggleButton(),
        const ThemeToggleButton(),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Iconsax.user, size: 18, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final SessionEntity session;
  const _GreetingCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final name = (session.fullName?.trim().isNotEmpty ?? false) ? session.fullName! : session.email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandTeal, AppColors.brandTealDeep],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandTeal.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(context),
                      style: context.bodyMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    heightBox(4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.titleLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (session.role != null) _RoleBadge(role: session.role!, onDark: true),
            ],
          ),
          heightBox(16),
          Row(
            children: [
              Icon(Iconsax.calendar_1, size: 14, color: AppColors.white.withValues(alpha: 0.8)),
              widthBox(6),
              Text(
                DateTime.now().formattedLong,
                style: context.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _greeting(BuildContext context) {
  final hour = DateTime.now().hour;
  if (hour < 12) return context.l10n.goodMorning;
  if (hour < 17) return context.l10n.goodAfternoon;
  return context.l10n.goodEvening;
}

class _RoleBadge extends StatelessWidget {
  final ShopRole role;
  final bool onDark;
  const _RoleBadge({required this.role, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final bg = onDark ? AppColors.white.withValues(alpha: 0.18) : context.primaryLight;
    final fg = onDark ? AppColors.white : context.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        _roleLabel(context, role),
        style: context.labelSmall.copyWith(color: fg, fontWeight: FontWeight.w600),
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

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final loading =
            state.apiStatus == ApiStatus.LOADING || state.apiStatus == ApiStatus.INITIAL;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Iconsax.people,
                    color: context.primary,
                    label: context.l10n.totalCustomers,
                    value: state.totalCustomers,
                    loading: loading,
                    onTap: () => context.push(RoutePaths.customers),
                  ),
                ),
                widthBox(14),
                Expanded(
                  child: _StatCard(
                    icon: Iconsax.user_add,
                    color: AppColors.brandGoldDark,
                    label: context.l10n.newThisWeek,
                    value: state.newCustomersThisWeek,
                    loading: loading,
                  ),
                ),
              ],
            ),
            if (state.apiStatus == ApiStatus.FAILURE) ...[
              heightBox(10),
              Row(
                children: [
                  Icon(Iconsax.warning_2, size: 16, color: context.error),
                  widthBox(6),
                  Expanded(
                    child: Text(
                      state.failure == null ? '' : AppFailureMapper.map(state.failure!).message,
                      style: context.bodySmall.copyWith(color: context.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CustomButton.text(
                    label: context.l10n.retry,
                    height: 28,
                    fontSize: 13,
                    onPressed: () => context.read<DashboardCubit>().loadStats(),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int? value;
  final bool loading;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.loading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
          heightBox(12),
          loading
              ? ShimmerLoading(
                  isLoading: true,
                  child: Container(
                    width: 36,
                    height: 22,
                    decoration: BoxDecoration(
                      color: context.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                )
              : Text(
                  '${value ?? 0}',
                  style: context.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
          heightBox(4),
          Text(label, style: context.bodySmall.copyWith(color: context.textSecondary)),
        ],
      ),
    );
    return onTap == null ? content : content.onTap(onTap!);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: context.titleSmall.copyWith(fontWeight: FontWeight.bold));
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Iconsax.user_add,
            color: context.primary,
            label: context.l10n.addCustomer,
            onTap: () => context.push(RoutePaths.addCustomer),
          ),
        ),
        widthBox(14),
        Expanded(
          child: _ActionTile(
            icon: Iconsax.people,
            color: AppColors.brandGoldDark,
            label: context.l10n.customers,
            onTap: () => context.push(RoutePaths.customers),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: context.shadow, blurRadius: 12, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: color),
              ),
              heightBox(10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonGrid extends StatelessWidget {
  const _ComingSoonGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Iconsax.receipt_2, context.l10n.orders),
      (Iconsax.ruler, context.l10n.measurements),
      (Iconsax.wallet_3, context.l10n.payments),
      (Iconsax.chart_2, context.l10n.reports),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 2.6,
      children: [for (final item in items) _ComingSoonTile(icon: item.$1, label: item.$2)],
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ComingSoonTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.textDisabled),
          widthBox(10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium.copyWith(color: context.textSecondary),
            ),
          ),
          Icon(Iconsax.lock_1, size: 14, color: context.textDisabled),
        ],
      ),
    ).onTap(() => AppToastsUtils.showInfoTop(context, context.l10n.featureComingSoonMessage));
  }
}

class _ProfileSheet extends StatelessWidget {
  final SessionEntity session;
  final bool signingOut;
  final VoidCallback onSignOut;

  const _ProfileSheet({required this.session, required this.signingOut, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final name = (session.fullName?.trim().isNotEmpty ?? false) ? session.fullName! : session.email;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Iconsax.user, color: AppColors.white, size: 20),
            ),
            heightBox(12),
            Text(name, style: context.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            heightBox(4),
            Text(session.email, style: context.bodySmall.copyWith(color: context.textSecondary)),
            if (session.role != null) ...[heightBox(10), _RoleBadge(role: session.role!)],
            heightBox(20),
            Divider(color: context.divider),
            heightBox(16),
            CustomButton.outline(
              label: context.l10n.signOut,
              isLoading: signingOut,
              outlineColor: context.error,
              textColor: context.error,
              onPressed: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}
