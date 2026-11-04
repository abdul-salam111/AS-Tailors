import 'package:flutter/material.dart';

/// Drives the staggered fade-in/slide-up entrance every auth screen uses:
/// one 1-second [AnimationController], with each element's appearance
/// carved out as an [Interval] on it so later elements visibly trail
/// earlier ones instead of everything popping in at once.
///
/// ```dart
/// class _MyScreenState extends State<MyScreen> with TickerProviderStateMixin {
///   late final _entrance = EntranceChoreography(this);
///
///   @override
///   void dispose() {
///     _entrance.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return _entrance.fadeSlideUp(
///       _entrance.interval(0.1, 0.55),
///       const Text('Welcome'),
///     );
///   }
/// }
/// ```
class EntranceChoreography {
  EntranceChoreography(TickerProvider vsync)
    : controller = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1000)) {
    controller.forward();
  }

  final AnimationController controller;

  void dispose() => controller.dispose();

  Animation<double> interval(double start, double end) {
    return CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Widget fadeSlideUp(Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(offset: Offset(0, 18 * (1 - animation.value)), child: child),
        );
      },
      child: child,
    );
  }
}
