import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/theme_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.titleColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.primary;
    final fg = titleColor ?? AppColors.white;

    return AppBar(
      backgroundColor: bg,
      iconTheme: IconThemeData(color: fg),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      bottom: bottom,
      title: subtitle != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyLarge.copyWith(color: fg, fontWeight: FontWeight.bold),
                ),
                Text(subtitle!, style: context.bodySmall.copyWith(color: fg.withAlpha(180))),
              ],
            )
          : Text(
              title,
              style: context.bodyLarge.copyWith(color: fg, fontWeight: FontWeight.bold),
            ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
