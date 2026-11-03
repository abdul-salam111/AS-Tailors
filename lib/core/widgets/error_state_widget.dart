import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/theme_utils.dart';
import '../utils/extensions.dart';
import 'custom_button.dart';

/// Standard failure placeholder — message plus an optional retry action.
/// Drop-in replacement for the inline `Column` every feature was
/// hand-rolling for `ApiStatus.FAILURE`.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Iconsax.warning_2,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: context.error),
            heightBox(12),
            Text(message, style: context.bodyMedium, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              heightBox(16),
              CustomButton.text(label: 'Retry', onPressed: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}
