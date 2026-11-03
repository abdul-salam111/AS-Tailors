import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';
import '../../../../routes/route_names.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';


class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..checkAuthStatus(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashAuthenticated) {
            context.goNamed(RouteNames.signin); 
          } else if (state is SplashUnauthenticated) {
            context.goNamed(RouteNames.signin);
          }
        },
        child: const Scaffold(body: Center(child: AppLogo())),
      ),
    );
  }
}
