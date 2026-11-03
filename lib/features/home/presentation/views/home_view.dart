import 'package:flutter/material.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../../../core/theme/theme_exports.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';
import '../../../../features/auth/auth_exports.dart';
import '../../../../routes/routes_exports.dart';

/// Placeholder landing screen for an authenticated, shop-having user.
/// FR-011's real dashboard (today's orders, collections, work queues,
/// ...) is a dedicated future feature — this just proves the auth → shop
/// → home redirect chain closes end-to-end and gives a way to sign out.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _signingOut = false;

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
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.appName,
        automaticallyImplyLeading: false,
        actions: const [LanguageToggleButton(), ThemeToggleButton()],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.dashboardComingSoon, style: context.titleMedium),
            heightBox(24),
            CustomButton.outline(
              label: context.l10n.signOut,
              isLoading: _signingOut,
              onPressed: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
