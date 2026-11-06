import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/theme_utils.dart';
import '../utils/extensions.dart';

/// Standard "nothing here" placeholder — drop-in replacement for the
/// inline `Column` every feature was hand-rolling for an empty list/detail.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  // Overrides [icon] with one of the app's own custom asset icons
  // (`AppIcons.*`, see core/constants/app_icons.dart) when the empty state
  // matches a branded section (Customers, Orders, ...) rather than a
  // generic Iconsax glyph.
  final String? iconAsset;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.title = 'Nothing here yet',
    this.subtitle,
    this.icon = Iconsax.document,
    this.iconAsset,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconAsset != null
                ? Image.asset(
                    iconAsset!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    color: context.textDisabled,
                  )
                : Icon(icon, size: 48, color: context.textDisabled),
            heightBox(12),
            Text(title, style: context.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              heightBox(4),
              Text(
                subtitle!,
                style: context.bodySmall.copyWith(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[heightBox(16), action!],
          ],
        ),
      ),
    );
  }
}
