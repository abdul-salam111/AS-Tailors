import 'package:flutter/material.dart';
import 'package:flutter_template/core/theme/colors.dart';
import 'loading_indicator.dart';

enum _ButtonVariant { filled, outline, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double radius;
  final double? width;
  final double height;
  final double elevation;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double iconSize;
  final Color? iconColor;
  final bool isLoading;
  final int fontSize;
  final _ButtonVariant _variant;

  // Outline-specific
  final Color? outlineColor;
  final double outlineWidth;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.radius = 50.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.elevation = 4.0,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize = 20.0,
    this.iconColor,
    this.isLoading = false,
    this.fontSize = 16,
    this.outlineColor,
    this.outlineWidth = 1.5,
  }) : _variant = _ButtonVariant.filled;

  const CustomButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlineColor,
    this.outlineWidth = 1.5,
    this.textColor,
    this.radius = 50.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize = 20.0,
    this.iconColor,
    this.isLoading = false,
    this.fontSize = 16,
  })  : _variant = _ButtonVariant.outline,
        backgroundColor = AppColors.transparent,
        elevation = 0;

  const CustomButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.radius = 50.0,
    this.width,
    this.height = 40.0,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize = 20.0,
    this.iconColor,
    this.isLoading = false,
    this.fontSize = 16,
  })  : _variant = _ButtonVariant.text,
        backgroundColor = AppColors.transparent,
        elevation = 0,
        outlineColor = null,
        outlineWidth = 0;

  @override
  Widget build(BuildContext context) {
    final resolvedBg = backgroundColor ?? AppColors.primary;
    final resolvedText = textColor ??
        (_variant == _ButtonVariant.filled ? AppColors.white : AppColors.primary);
    final resolvedIcon = iconColor ?? resolvedText;
    final resolvedOutline = outlineColor ?? AppColors.primary;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: _variant == _ButtonVariant.outline
          ? BorderSide(color: resolvedOutline, width: outlineWidth)
          : BorderSide.none,
    );

    final child = isLoading
        ? const LoadingIndicator(size: 24)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: iconSize, color: resolvedIcon),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: resolvedText,
                      fontSize: fontSize.toDouble(),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                Icon(suffixIcon, size: iconSize, color: resolvedIcon),
              ],
            ],
          );

    if (_variant == _ButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: resolvedText,
          shape: shape,
          minimumSize: Size(width ?? 0, height),
        ),
        child: child,
      );
    }

    if (_variant == _ButtonVariant.outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: resolvedText,
          backgroundColor: resolvedBg,
          shape: shape,
          side: BorderSide(color: resolvedOutline, width: outlineWidth),
          minimumSize: Size(width ?? 0, height),
          elevation: 0,
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        shadowColor: AppColors.transparent,
        backgroundColor: resolvedBg,
        shape: shape,
        elevation: elevation,
        minimumSize: Size(width ?? 0, height),
      ),
      child: child,
    );
  }
}
