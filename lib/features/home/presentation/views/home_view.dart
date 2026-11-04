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

// Placeholder figures below (orders/revenue/payments) stand in until those
// features ship — see CLAUDE.md's gap list (§1a items 5-7). Only the
// customer counts coming out of [DashboardCubit] are real. Replace these
// consts with real usecases the day `orders`/`payments` land; nothing else
// about the layout should need to change.
const _dummyActiveOrders = 18;
const _dummyActiveOrdersDeltaPct = 12;
const _dummyRevenueThisMonth = 128500;
const _dummyRevenueDeltaPct = 8;
const _dummyPendingPayments = 6;
const _dummyPendingPaymentsDeltaPct = 3;

enum _DueStatus { overdue, dueToday, dueTomorrow }

class _DeliveryAlert {
  final String customerName;
  final String garment;
  final _DueStatus status;
  const _DeliveryAlert({required this.customerName, required this.garment, required this.status});
}

const _dummyDeliveries = [
  _DeliveryAlert(customerName: 'Ali Raza', garment: 'Shalwar Kameez', status: _DueStatus.overdue),
  _DeliveryAlert(customerName: 'Fatima Noor', garment: '3x Shirts', status: _DueStatus.dueToday),
  _DeliveryAlert(
    customerName: 'Hassan Ahmed',
    garment: 'Shalwar Kameez',
    status: _DueStatus.dueTomorrow,
  ),
];

enum _ActivityType { paymentReceived, orderReady, newOrder, newCustomer }

class _ActivityItem {
  final _ActivityType type;
  final String detail;
  final DateTime time;
  const _ActivityItem({required this.type, required this.detail, required this.time});
}

final _dummyActivityFeed = [
  _ActivityItem(
    type: _ActivityType.paymentReceived,
    detail: '₨8,500',
    time: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  _ActivityItem(
    type: _ActivityType.orderReady,
    detail: '#ORD-214',
    time: DateTime.now().subtract(const Duration(hours: 9)),
  ),
  _ActivityItem(
    type: _ActivityType.newOrder,
    detail: '#ORD-215',
    time: DateTime.now().subtract(const Duration(days: 1)),
  ),
  _ActivityItem(
    type: _ActivityType.newCustomer,
    detail: 'Ayesha Khan',
    time: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

/// The FR-011 dashboard. Real data (customer counts) comes from
/// [DashboardCubit]; everything else is realistic placeholder content so the
/// screen reads as a finished product rather than a half-built one — see the
/// dummy-data block above.
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
  final _scrollController = ScrollController();
  bool _signingOut = false;

  @override
  void dispose() {
    _entrance.dispose();
    _scrollController.dispose();
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

  void _comingSoon() => AppToastsUtils.showInfoTop(context, context.l10n.featureComingSoonMessage);

  @override
  Widget build(BuildContext context) {
    final session = sl<SessionController>().session;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().loadStats(),
          color: context.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _DashboardHeader(
                session: session,
                entrance: _entrance,
                onProfileTap: _openProfileSheet,
                scrollController: _scrollController,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _entrance.fadeSlideUp(_entrance.interval(0.12, 0.5), const _KpiGrid()),
                    heightBox(28),
                    _entrance.fadeSlideUp(
                      _entrance.interval(0.22, 0.6),
                      _SectionHeader(title: context.l10n.needsAttention, onViewAll: _comingSoon),
                    ),
                    heightBox(12),
                    _entrance.fadeSlideUp(
                      _entrance.interval(0.26, 0.64),
                      _AttentionList(onTap: _comingSoon),
                    ),
                    heightBox(28),
                    _entrance.fadeSlideUp(
                      _entrance.interval(0.34, 0.72),
                      _SectionHeader(title: context.l10n.quickActions),
                    ),
                    heightBox(12),
                    _entrance.fadeSlideUp(
                      _entrance.interval(0.38, 0.76),
                      _QuickActionsGrid(onComingSoon: _comingSoon),
                    ),
                    heightBox(28),
                    _entrance.fadeSlideUp(
                      _entrance.interval(0.46, 0.84),
                      _SectionHeader(title: context.l10n.recentActivity),
                    ),
                    heightBox(12),
                    _entrance.fadeSlideUp(
                      _entrance.interval(0.5, 0.9),
                      const _RecentActivityList(),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The collapsing gradient header: a full teal "card" with rounded bottom
/// corners that covers the whole app bar (not just a card sitting under it).
/// Expanded, it shows the greeting/role/date; scrolled up, [FlexibleSpaceBar]
/// fades that out and fades in the compact app-name title while staying
/// pinned — language/theme/profile stay in `actions` so they're reachable
/// in both states, never fading with the background.
class _DashboardHeader extends StatelessWidget {
  final SessionEntity session;
  final EntranceChoreography entrance;
  final VoidCallback onProfileTap;
  final ScrollController scrollController;

  static const double _expandedHeight = 240;
  static const double _maxCornerRadius = 28;
  // Distance (in scroll pixels) the header actually has to travel to go
  // from fully expanded to fully collapsed — independent of the top status
  // bar inset, which SliverAppBar adds equally to both extents.
  static const double _collapseDistance = _expandedHeight - kToolbarHeight;

  const _DashboardHeader({
    required this.session,
    required this.entrance,
    required this.onProfileTap,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // ERP-style: rounded bottom corners only at rest (fully expanded);
    // once scrolled into the compact app bar it should read as a normal,
    // sharp-edged app bar. SliverAppBar.shape doesn't animate on its own,
    // so this listens to the scroll offset directly and recomputes the
    // corner radius every frame, snapping to 0 by the time the header is
    // actually collapsed.
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final offset = scrollController.hasClients ? scrollController.offset : 0.0;
        final collapseT = (offset / _collapseDistance).clamp(0.0, 1.0);
        final cornerRadius = _maxCornerRadius * (1 - collapseT);

        return SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: _expandedHeight,
          backgroundColor: AppColors.brandTealDeep,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: AppColors.transparent,
          automaticallyImplyLeading: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(cornerRadius)),
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
          actionsIconTheme: const IconThemeData(color: AppColors.white),
          centerTitle: false,
          titleSpacing: 20,
          // Deliberately NOT FlexibleSpaceBar.title: that fades in based on
          // scroll offset, but the fade curve only reaches 0 opacity when
          // `collapsedHeight` is taller than `kToolbarHeight` — here it
          // isn't, so the title was rendering at partial opacity even near
          // full expansion, overlapping the greeting's name/date text. A
          // `title` set directly on SliverAppBar instead always renders in
          // the toolbar's pinned row (same place `actions` already
          // renders, never fading), which is also simpler: no overlap is
          // possible since the greeting content is already padded below
          // the toolbar height.
          title: const _CompactHeaderTitle(),
          flexibleSpace: FlexibleSpaceBar(
            background: entrance.fadeSlideUp(
              entrance.interval(0.0, 0.4),
              _ExpandedHeaderContent(session: session),
            ),
          ),
          actions: [
            const LanguageToggleButton(),
            const ThemeToggleButton(),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 16, left: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Iconsax.user, size: 16, color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompactHeaderTitle extends StatelessWidget {
  const _CompactHeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const AppLogo(),
        ),
        widthBox(8),
        Text(
          context.l10n.appName,
          style: context.titleMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ExpandedHeaderContent extends StatelessWidget {
  final SessionEntity session;
  const _ExpandedHeaderContent({required this.session});

  @override
  Widget build(BuildContext context) {
    final name = (session.fullName?.trim().isNotEmpty ?? false) ? session.fullName! : session.email;
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandTeal, AppColors.brandTealDeep],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -16,
            top: topInset + 6,
            child: Icon(Iconsax.ruler, size: 120, color: AppColors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + kToolbarHeight + 6, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
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
                            style: context.headlineSmall.copyWith(
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
                heightBox(14),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 14,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    widthBox(6),
                    Text(
                      DateTime.now().formattedLong,
                      style: context.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: context.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        ),
        if (onViewAll != null)
          CustomButton.text(
            label: context.l10n.viewAll,
            height: 28,
            fontSize: 13,
            onPressed: onViewAll!,
          ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final loading =
            state.apiStatus == ApiStatus.LOADING || state.apiStatus == ApiStatus.INITIAL;
        final newThisWeek = state.newCustomersThisWeek ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    icon: Iconsax.people,
                    color: context.primary,
                    label: context.l10n.totalCustomers,
                    value: '${state.totalCustomers ?? 0}',
                    loading: loading,
                    trendValue: newThisWeek > 0 ? '+$newThisWeek' : null,
                    trendGood: true,
                    onTap: () => context.push(RoutePaths.customers),
                  ),
                ),
                widthBox(14),
                Expanded(
                  child: _KpiCard(
                    icon: Iconsax.bag_timer,
                    color: AppColors.brandGoldDark,
                    label: context.l10n.activeOrders,
                    value: '$_dummyActiveOrders',
                    loading: loading,
                    trendValue: '+$_dummyActiveOrdersDeltaPct%',
                    trendGood: true,
                  ),
                ),
              ],
            ),
            heightBox(14),
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    icon: Iconsax.wallet_money,
                    color: context.success,
                    label: context.l10n.revenue,
                    value: _dummyRevenueThisMonth.asPKR,
                    loading: loading,
                    trendValue: '+$_dummyRevenueDeltaPct%',
                    trendGood: true,
                  ),
                ),
                widthBox(14),
                Expanded(
                  child: _KpiCard(
                    icon: Iconsax.empty_wallet_time,
                    color: context.warning,
                    label: context.l10n.pendingPayments,
                    value: '$_dummyPendingPayments',
                    loading: loading,
                    trendValue: '-$_dummyPendingPaymentsDeltaPct%',
                    trendUp: false,
                    trendGood: true,
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

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool loading;
  final String? trendValue;
  final bool trendUp;
  final bool trendGood;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.loading,
    this.trendValue,
    this.trendUp = true,
    this.trendGood = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = trendGood ? context.success : context.error;

    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.divider),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19, color: color),
              ),
              const Spacer(),
              if (trendValue != null && !loading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                        size: 10,
                        color: trendColor,
                      ),
                      widthBox(2),
                      Text(
                        trendValue!,
                        style: context.labelSmall.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          heightBox(14),
          loading
              ? ShimmerLoading(
                  isLoading: true,
                  child: Container(
                    width: 48,
                    height: 22,
                    decoration: BoxDecoration(
                      color: context.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
          heightBox(4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.bodySmall.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
    return onTap == null ? content : content.onTap(onTap!);
  }
}

class _AttentionList extends StatelessWidget {
  final VoidCallback onTap;
  const _AttentionList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _dummyDeliveries.length; i++) ...[
          _DeliveryAlertCard(alert: _dummyDeliveries[i], onTap: onTap),
          if (i != _dummyDeliveries.length - 1) heightBox(10),
        ],
      ],
    );
  }
}

class _DeliveryAlertCard extends StatelessWidget {
  final _DeliveryAlert alert;
  final VoidCallback onTap;
  const _DeliveryAlertCard({required this.alert, required this.onTap});

  (Color, String) _statusStyle(BuildContext context) => switch (alert.status) {
    _DueStatus.overdue => (context.error, context.l10n.overdue),
    _DueStatus.dueToday => (context.warning, context.l10n.dueToday),
    _DueStatus.dueTomorrow => (context.primary, context.l10n.dueTomorrow),
  };

  Widget _content(BuildContext context, Color color, String statusLabel) {
    final initial = alert.customerName.isNotEmpty ? alert.customerName[0].toUpperCase() : '?';

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: context.bodyMedium.copyWith(color: context.primary, fontWeight: FontWeight.bold),
          ),
        ),
        widthBox(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              heightBox(2),
              Text(
                alert.garment,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
        widthBox(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusLabel,
            style: context.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final (color, statusLabel) = _statusStyle(context);

    return Material(
      color: context.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.divider),
            boxShadow: [
              BoxShadow(color: context.shadow, blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          // A `Border` can't mix a colored accent side with `borderRadius` —
          // Flutter requires uniform border colors whenever corners are
          // rounded. The teal/amber/red accent is drawn as a real clipped
          // bar instead, inside a uniformly-bordered card. IntrinsicHeight
          // gives the Row a bounded height to stretch that bar against —
          // without it, the Row sits inside an unbounded-height scroll
          // Column and `stretch` has nothing finite to stretch to, which
          // crashes layout with "BoxConstraints forces an infinite height."
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _content(context, color, statusLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onComingSoon;
  const _QuickActionsGrid({required this.onComingSoon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
        ),
        heightBox(14),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Iconsax.bag_timer,
                color: context.success,
                label: context.l10n.newOrder,
                onTap: onComingSoon,
              ),
            ),
            widthBox(14),
            Expanded(
              child: _ActionTile(
                icon: Iconsax.wallet_money,
                color: context.warning,
                label: context.l10n.recordPayment,
                onTap: onComingSoon,
              ),
            ),
          ],
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
            border: Border.all(color: context.divider),
            boxShadow: [
              BoxShadow(color: context.shadow, blurRadius: 8, offset: const Offset(0, 3)),
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

(IconData, Color, String) _activityPresentation(BuildContext context, _ActivityType type) =>
    switch (type) {
      _ActivityType.newCustomer => (
        Iconsax.user_add,
        context.primary,
        context.l10n.recentActivityNewCustomer,
      ),
      _ActivityType.paymentReceived => (
        Iconsax.money_recive,
        context.success,
        context.l10n.recentActivityPaymentReceived,
      ),
      _ActivityType.orderReady => (
        Iconsax.box_tick,
        AppColors.brandGoldDark,
        context.l10n.recentActivityOrderReady,
      ),
      _ActivityType.newOrder => (
        Iconsax.bag_timer,
        context.primary,
        context.l10n.recentActivityNewOrder,
      ),
    };

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.divider),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          for (var i = 0; i < _dummyActivityFeed.length; i++) ...[
            _ActivityRow(item: _dummyActivityFeed[i]),
            if (i != _dummyActivityFeed.length - 1)
              Divider(height: 1, thickness: 1, color: context.divider, indent: 58, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, color, title) = _activityPresentation(context, item.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          widthBox(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                heightBox(2),
                Text(
                  item.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          widthBox(8),
          Text(
            item.time.timeAgoShort,
            style: context.labelSmall.copyWith(color: context.textDisabled),
          ),
        ],
      ),
    );
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
