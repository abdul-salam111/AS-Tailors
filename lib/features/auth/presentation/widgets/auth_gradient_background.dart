import 'package:flutter/material.dart';
import '../../../../core/theme/theme_exports.dart';

/// Color tokens for [AuthGradientBackground]. Centralized here — rather
/// than hardcoded inside the widget's `build()` — so the palette can be
/// retuned in one place without touching the gradient/blend layout.
///
/// Same layered-wash technique (base diagonal gradient + two radial
/// glows + a flat dark-mode fallback) as a reference app's auth
/// background, re-tinted with AS Tailors' own brand palette instead of
/// carrying over that app's blue/lilac/rose identity.
class AuthGradientColors {
  const AuthGradientColors._();

  static const base = [
    AppColors.brandTealTint,
    Color(0xFFEAF6F5),
    AppColors.brandIvory,
    AppColors.brandGoldLight,
  ];
  static const baseStops = [0.0, 0.32, 0.64, 1.0];

  static const tealGlow = AppColors.brandTeal;
  static const tealGlowOpacity = 0.22;

  static const goldGlow = AppColors.brandGold;
  static const goldGlowOpacity = 0.20;

  static const darkFallback = AppColors.backgroundDark;
}

/// The soft teal/gold wash shared by the sign-in and sign-up screens —
/// a full-bleed background the animated form sheet slides up over,
/// rather than a separately-shaped hero banner.
class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isDark) {
      return ColoredBox(color: AuthGradientColors.darkFallback, child: child);
    }

    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.3, -1),
                end: Alignment(0.3, 1),
                colors: AuthGradientColors.base,
                stops: AuthGradientColors.baseStops,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-1.0, -0.9),
                radius: 0.9,
                colors: [
                  AuthGradientColors.tealGlow.withValues(alpha: AuthGradientColors.tealGlowOpacity),
                  AuthGradientColors.tealGlow.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(1.0, -0.3),
                radius: 0.8,
                colors: [
                  AuthGradientColors.goldGlow.withValues(alpha: AuthGradientColors.goldGlowOpacity),
                  AuthGradientColors.goldGlow.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
