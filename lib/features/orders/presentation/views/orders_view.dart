import 'package:flutter/material.dart';
import '../../../../core/constants/const_exports.dart';
import '../../../../core/theme/theme_exports.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';

/// Orders tab placeholder. There is no `orders` feature yet — see
/// CLAUDE.md's gap list (§1a) — so this is an honest "not built yet"
/// screen rather than a fake list, reached from the bottom nav bar.
class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: CustomAppBar(title: context.l10n.orders, centerTitle: false),
      body: EmptyStateWidget(
        iconAsset: AppIcons.orders,
        title: context.l10n.orders,
        subtitle: context.l10n.featureComingSoonMessage,
      ),
    );
  }
}
