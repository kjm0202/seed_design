import 'package:flutter/animation.dart';

/// Duration tokens defined by SEED Design System.
class SeedDuration {
  const SeedDuration._();

  static const Duration d1 = Duration(milliseconds: 50);
  static const Duration d2 = Duration(milliseconds: 100);
  static const Duration d3 = Duration(milliseconds: 150);
  static const Duration d4 = Duration(milliseconds: 200);
  static const Duration d5 = Duration(milliseconds: 250);
  static const Duration d6 = Duration(milliseconds: 300);

  /// Semantic duration tokens
  static const Duration colorTransition = d3; // 150ms
  static const Duration pressedScale = d3; // 150ms
}

/// Timing curves defined by SEED Design System.
class SeedCurves {
  const SeedCurves._();

  /// linear: cubic-bezier(0, 0, 1, 1)
  static const Curve linear = Curves.linear;

  /// easing: cubic-bezier(0.35, 0, 0.35, 1)
  static const Curve easing = Cubic(0.35, 0.0, 0.35, 1.0);

  /// enter: cubic-bezier(0, 0, 0.15, 1)
  static const Curve enter = Cubic(0.0, 0.0, 0.15, 1.0);

  /// exit: cubic-bezier(0.35, 0, 1, 1)
  static const Curve exit = Cubic(0.35, 0.0, 1.0, 1.0);

  /// enter-expressive: cubic-bezier(0.03, 0.4, 0.1, 1)
  static const Curve enterExpressive = Cubic(0.03, 0.4, 0.1, 1.0);

  /// exit-expressive: cubic-bezier(0.35, 0, 0.95, 0.55)
  static const Curve exitExpressive = Cubic(0.35, 0.0, 0.95, 0.55);

  /// pressed-scale: cubic-bezier(0, 0, 0.15, 1)
  static const Curve pressedScale = Cubic(0.0, 0.0, 0.15, 1.0);
}
