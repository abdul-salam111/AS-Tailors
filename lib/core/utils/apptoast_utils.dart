// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

import '../theme/colors.dart';


// ============================================================================
// TOAST POSITION ENUM 📍
// ============================================================================

enum ToastPosition {
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

// ============================================================================
// TOAST TYPE ENUM 🎨
// ============================================================================

enum ToastType { success, error, warning, info, custom }

// ============================================================================
// COMPLETE TOAST UTILITY 🎯
// ============================================================================

class AppToastsUtils {
  static Flushbar<dynamic>? _currentFlushbar;

  // ========================================================================
  // DISMISS CURRENT TOAST
  // ========================================================================

  static void _dismissCurrentToast() {
    if (_currentFlushbar != null && _currentFlushbar!.isShowing()) {
      _currentFlushbar!.dismiss();
      _currentFlushbar = null;
    }
  }

  // ========================================================================
  // MAIN SHOW METHOD (WITH ALL OPTIONS) 🎨
  // ========================================================================

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? mainButton,
    bool isDismissible = true,
    bool showProgressIndicator = false,
    double? maxWidth,
  }) {
    _dismissCurrentToast();

    final config = _getToastConfig(type);
    final positionConfig = _getPositionConfig(position);

    _currentFlushbar = Flushbar(
      title: title ?? config.title,
      message: message,
      backgroundColor: backgroundColor ?? config.backgroundColor,
      messageColor: textColor ?? AppColors.white,
      titleColor: textColor ?? AppColors.white,
      icon: icon != null
          ? Icon(icon, color: iconColor ?? AppColors.white)
          : Icon(config.icon, color: iconColor ?? AppColors.white),
      duration: duration,
      flushbarPosition: positionConfig.flushbarPosition,
      margin: positionConfig.margin,
      borderRadius: BorderRadius.circular(12),
      isDismissible: isDismissible,
      dismissDirection: positionConfig.dismissDirection,
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      boxShadows: const [
        BoxShadow(color: AppColors.shadowMedium, offset: Offset(0, 2), blurRadius: 8),
      ],
      mainButton: mainButton,
      onTap: onTap != null ? (_) => onTap() : null,
      showProgressIndicator: showProgressIndicator,
      progressIndicatorBackgroundColor: AppColors.whiteFaded,
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(
        textColor ?? AppColors.white,
      ),
      maxWidth: maxWidth,
    )..show(context).then((_) => _currentFlushbar = null);
  }

  // ========================================================================
  // PREDEFINED TOAST METHODS 🎯
  // ========================================================================

  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, title: title, type: ToastType.success,
        position: position, duration: duration);
  }

  static void showError(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, title: title, type: ToastType.error,
        position: position, duration: duration);
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, title: title, type: ToastType.warning,
        position: position, duration: duration);
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, title: title, type: ToastType.info,
        position: position, duration: duration);
  }

  // ========================================================================
  // DIRECTION-SPECIFIC METHODS 📍
  // ========================================================================

  static void showSuccessTop(BuildContext context, String message) =>
      showSuccess(context, message, position: ToastPosition.top);

  static void showErrorTop(BuildContext context, String message) =>
      showError(context, message, position: ToastPosition.top);

  static void showWarningTop(BuildContext context, String message) =>
      showWarning(context, message, position: ToastPosition.top);

  static void showInfoTop(BuildContext context, String message) =>
      showInfo(context, message, position: ToastPosition.top);

  static void showSuccessBottom(BuildContext context, String message) =>
      showSuccess(context, message, position: ToastPosition.bottom);

  static void showErrorBottom(BuildContext context, String message) =>
      showError(context, message, position: ToastPosition.bottom);

  static void showWarningBottom(BuildContext context, String message) =>
      showWarning(context, message, position: ToastPosition.bottom);

  static void showInfoBottom(BuildContext context, String message) =>
      showInfo(context, message, position: ToastPosition.bottom);

  static void showSuccessTopLeft(BuildContext context, String message) =>
      showSuccess(context, message, position: ToastPosition.topLeft);

  static void showErrorTopLeft(BuildContext context, String message) =>
      showError(context, message, position: ToastPosition.topLeft);

  static void showSuccessTopRight(BuildContext context, String message) =>
      showSuccess(context, message, position: ToastPosition.topRight);

  static void showErrorTopRight(BuildContext context, String message) =>
      showError(context, message, position: ToastPosition.topRight);

  static void showSuccessBottomLeft(BuildContext context, String message) =>
      showSuccess(context, message, position: ToastPosition.bottomLeft);

  static void showErrorBottomLeft(BuildContext context, String message) =>
      showError(context, message, position: ToastPosition.bottomLeft);

  static void showSuccessBottomRight(BuildContext context, String message) =>
      showSuccess(context, message, position: ToastPosition.bottomRight);

  static void showErrorBottomRight(BuildContext context, String message) =>
      showError(context, message, position: ToastPosition.bottomRight);

  static void showCenter(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
  }) {
    show(context, message: message, type: type, position: ToastPosition.center);
  }

  // ========================================================================
  // SPECIAL TOASTS 🌟
  // ========================================================================

  static void showLoading(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.top,
  }) {
    show(
      context,
      message: message,
      title: 'Loading',
      type: ToastType.info,
      position: position,
      duration: const Duration(days: 1),
      showProgressIndicator: true,
      isDismissible: false,
    );
  }

  static void showWithAction(
    BuildContext context, {
    required String message,
    required String actionText,
    required VoidCallback onActionPressed,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: type,
      position: position,
      mainButton: TextButton(
        onPressed: () {
          dismissCurrent();
          onActionPressed();
        },
        child: Text(actionText, style: const TextStyle(color: AppColors.white)),
      ),
    );
  }

  static void showPersistent(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.top,
  }) {
    show(context, message: message, type: type, position: position,
        duration: const Duration(days: 1), isDismissible: true);
  }

  static void showLong(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.top,
  }) {
    show(context, message: message, type: type, position: position,
        duration: const Duration(seconds: 5));
  }

  static void showShort(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.top,
  }) {
    show(context, message: message, type: type, position: position,
        duration: const Duration(seconds: 1));
  }

  // ========================================================================
  // HELPER METHODS 🔧
  // ========================================================================

  static void dismissCurrent() => _dismissCurrentToast();

  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          title: 'Success',
          backgroundColor: AppColors.success,
          icon: Icons.check_circle,
        );
      case ToastType.error:
        return _ToastConfig(
          title: 'Error',
          backgroundColor: AppColors.error,
          icon: Icons.error,
        );
      case ToastType.warning:
        return _ToastConfig(
          title: 'Warning',
          backgroundColor: AppColors.warning,
          icon: Icons.warning,
        );
      case ToastType.info:
        return _ToastConfig(
          title: 'Info',
          backgroundColor: AppColors.info,
          icon: Icons.info,
        );
      case ToastType.custom:
        return _ToastConfig(
          title: '',
          backgroundColor: AppColors.grey400,
          icon: Icons.notifications,
        );
    }
  }

  static _PositionConfig _getPositionConfig(ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
        return _PositionConfig(
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          dismissDirection: FlushbarDismissDirection.VERTICAL,
        );
      case ToastPosition.bottom:
        return _PositionConfig(
          flushbarPosition: FlushbarPosition.BOTTOM,
          margin: const EdgeInsets.all(8),
          dismissDirection: FlushbarDismissDirection.VERTICAL,
        );
      case ToastPosition.topLeft:
        return _PositionConfig(
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.only(left: 8, top: 8, right: 200),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        );
      case ToastPosition.topRight:
        return _PositionConfig(
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.only(left: 200, top: 8, right: 8),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        );
      case ToastPosition.bottomLeft:
        return _PositionConfig(
          flushbarPosition: FlushbarPosition.BOTTOM,
          margin: const EdgeInsets.only(left: 8, bottom: 8, right: 200),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        );
      case ToastPosition.bottomRight:
        return _PositionConfig(
          flushbarPosition: FlushbarPosition.BOTTOM,
          margin: const EdgeInsets.only(left: 200, bottom: 8, right: 8),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        );
      case ToastPosition.center:
        return _PositionConfig(
          flushbarPosition: FlushbarPosition.TOP,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical:
                MediaQueryData.fromView(
                  WidgetsBinding.instance.platformDispatcher.views.first,
                ).size.height *
                0.4,
          ),
          dismissDirection: FlushbarDismissDirection.VERTICAL,
        );
    }
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

class _ToastConfig {
  final String title;
  final Color backgroundColor;
  final IconData icon;

  _ToastConfig({
    required this.title,
    required this.backgroundColor,
    required this.icon,
  });
}

class _PositionConfig {
  final FlushbarPosition flushbarPosition;
  final EdgeInsets margin;
  final FlushbarDismissDirection dismissDirection;

  _PositionConfig({
    required this.flushbarPosition,
    required this.margin,
    required this.dismissDirection,
  });
}
