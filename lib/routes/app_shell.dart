import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/const_exports.dart';
import '../core/theme/theme_exports.dart';
import '../core/utils/utils_exports.dart';
import 'route_paths.dart';

/// Persistent bottom-nav chrome for the four tabbed branches (Home,
/// Customers, Orders, Account) plus a center "Create Order" action that
/// pushes the Add Order screen outside the shell (full-screen, no bottom
/// nav) with no pre-selected customer — the form's own customer picker
/// handles that. Each branch keeps its own Navigator/state via
/// [StatefulNavigationShell] (wired in routes.dart), so switching tabs
/// doesn't rebuild the others.
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
      floatingActionButton: _CreateOrderFab(onTap: () => context.push(RoutePaths.addOrder)),
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
              iconAsset: AppIcons.homeIcon,
              label: context.l10n.home,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              iconAsset: AppIcons.customers,
              label: context.l10n.customers,
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            child: _NavBarItem(
              iconAsset: AppIcons.orders,
              label: context.l10n.orders,
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              iconAsset: AppIcons.profile,
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
  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.iconAsset,
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
            Image.asset(iconAsset, width: 22, height: 22, color: color),
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
          // Center loosens the Container's tight 58x58 constraint before it
          // reaches Image — without it, Image's own width/height request
          // gets clamped straight back up to 58x58 (RenderImage enforces
          // its requested size against the incoming constraints, and a
          // tight incoming constraint always wins), so the icon filled the
          // whole FAB no matter how small width/height were set.
          child: Center(
            child: Image.asset(
              AppIcons.createOrder,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
