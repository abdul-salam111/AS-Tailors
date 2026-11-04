import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/theme_exports.dart';
import '../core/utils/utils_exports.dart';
import '../core/widgets/widgets_exports.dart';

/// Persistent bottom-nav chrome for the four tabbed branches (Home,
/// Customers, Orders, Account) plus a center "Create Order" action that
/// isn't a branch at all — there's no `orders` feature to create one
/// against yet (see CLAUDE.md §1a), so it surfaces the same
/// "coming soon" toast as the dashboard's other not-yet-built actions.
/// Each branch keeps its own Navigator/state via [StatefulNavigationShell]
/// (wired in routes.dart), so switching tabs doesn't rebuild the others.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: _CreateOrderFab(
        onTap: () => AppToastsUtils.showInfoTop(context, context.l10n.featureComingSoonMessage),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _AppBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
      ),
    );
  }
}

class _AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _AppBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: context.surfaceElevated,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 12,
      height: 64,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: _NavBarItem(
              icon: Iconsax.home_2,
              label: context.l10n.home,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              icon: Iconsax.people,
              label: context.l10n.customers,
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            child: _NavBarItem(
              icon: Iconsax.receipt_2,
              label: context.l10n.orders,
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              icon: Iconsax.user,
              label: context.l10n.account,
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.primary : context.textDisabled;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            heightBox(4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.labelSmall.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateOrderFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateOrderFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandTeal, AppColors.brandTealDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandTeal.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const Icon(Iconsax.add, color: AppColors.white, size: 26),
        ),
      ),
    );
  }
}
