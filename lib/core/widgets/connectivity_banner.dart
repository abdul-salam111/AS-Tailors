import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/connectivity_cubit.dart';
import '../theme/colors.dart';
import '../theme/theme_utils.dart';

/// Wraps [child] with a persistent top banner that appears whenever
/// [ConnectivityCubit] reports no internet access, and disappears the
/// moment connectivity returns. Provided once at the app root so no
/// individual screen has to wire up its own offline handling.
class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ConnectivityCubit, bool>(
          builder: (context, isOffline) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: isOffline
                  ? Material(
                      color: AppColors.error,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off, color: AppColors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'No internet connection',
                                style: context.bodySmall.copyWith(color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
        Expanded(child: child),
      ],
    );
  }
}
