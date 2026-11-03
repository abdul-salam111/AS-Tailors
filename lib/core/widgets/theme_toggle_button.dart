import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../shared/shared_exports.dart';
import '../theme/theme_exports.dart';

/// Light/dark toggle — drop into any `CustomAppBar(actions: [...])`.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDarkMode;
    return IconButton(
      icon: Icon(isDark ? Iconsax.sun_1 : Iconsax.moon),
      onPressed: () => context.read<ThemeBloc>().add(const ToggleTheme()),
    );
  }
}
