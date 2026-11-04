import 'package:material_ui/material_ui.dart';

/// Corner radius tokens defined by SEED Design System.
class SeedRadius {
  const SeedRadius._();

  /// Corner radius r0_5: 2.0 logical pixels.
  static const double r0_5 = 2.0;
  /// Corner radius r1: 4.0 logical pixels.
  static const double r1 = 4.0;
  /// Corner radius r1_5: 6.0 logical pixels.
  static const double r1_5 = 6.0;
  /// Corner radius r2: 8.0 logical pixels.
  static const double r2 = 8.0;
  /// Corner radius r2_5: 10.0 logical pixels.
  static const double r2_5 = 10.0;
  /// Corner radius r3: 12.0 logical pixels.
  static const double r3 = 12.0;
  /// Corner radius r3_5: 14.0 logical pixels.
  static const double r3_5 = 14.0;
  /// Corner radius r4: 16.0 logical pixels.
  static const double r4 = 16.0;
  /// Corner radius r5: 20.0 logical pixels.
  static const double r5 = 20.0;
  /// Corner radius r6: 24.0 logical pixels.
  static const double r6 = 24.0;
  /// Pill-shaped corner radius (9999 logical pixels) for rounded ends.
  static const double full = 9999.0;
}

/// Convenience [BorderRadius] constants for SEED radius tokens.
class SeedBorderRadius {
  const SeedBorderRadius._();

  /// Uniform Flutter BorderRadius using [SeedRadius.r0_5].
  static const BorderRadius r0_5 = BorderRadius.all(
    Radius.circular(SeedRadius.r0_5),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r1].
  static const BorderRadius r1 = BorderRadius.all(
    Radius.circular(SeedRadius.r1),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r1_5].
  static const BorderRadius r1_5 = BorderRadius.all(
    Radius.circular(SeedRadius.r1_5),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r2].
  static const BorderRadius r2 = BorderRadius.all(
    Radius.circular(SeedRadius.r2),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r2_5].
  static const BorderRadius r2_5 = BorderRadius.all(
    Radius.circular(SeedRadius.r2_5),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r3].
  static const BorderRadius r3 = BorderRadius.all(
    Radius.circular(SeedRadius.r3),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r3_5].
  static const BorderRadius r3_5 = BorderRadius.all(
    Radius.circular(SeedRadius.r3_5),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r4].
  static const BorderRadius r4 = BorderRadius.all(
    Radius.circular(SeedRadius.r4),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r5].
  static const BorderRadius r5 = BorderRadius.all(
    Radius.circular(SeedRadius.r5),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.r6].
  static const BorderRadius r6 = BorderRadius.all(
    Radius.circular(SeedRadius.r6),
  );
  /// Uniform Flutter BorderRadius using [SeedRadius.full].
  static const BorderRadius full = BorderRadius.all(
    Radius.circular(SeedRadius.full),
  );
}
