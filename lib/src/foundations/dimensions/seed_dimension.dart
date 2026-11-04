/// Dimension tokens defined by SEED Design System.
class SeedDimension {
  const SeedDimension._();

  /// SEED dimension scale x0_5: 2.0 logical pixels (dp) in Flutter.
  static const double x0_5 = 2.0;
  /// SEED dimension scale x1: 4.0 logical pixels (dp) in Flutter.
  static const double x1 = 4.0;
  /// SEED dimension scale x1_5: 6.0 logical pixels (dp) in Flutter.
  static const double x1_5 = 6.0;
  /// SEED dimension scale x2: 8.0 logical pixels (dp) in Flutter.
  static const double x2 = 8.0;
  /// SEED dimension scale x2_5: 10.0 logical pixels (dp) in Flutter.
  static const double x2_5 = 10.0;
  /// SEED dimension scale x3: 12.0 logical pixels (dp) in Flutter.
  static const double x3 = 12.0;
  /// SEED dimension scale x3_5: 14.0 logical pixels (dp) in Flutter.
  static const double x3_5 = 14.0;
  /// SEED dimension scale x4: 16.0 logical pixels (dp) in Flutter.
  static const double x4 = 16.0;
  /// SEED dimension scale x4_5: 18.0 logical pixels (dp) in Flutter.
  static const double x4_5 = 18.0;
  /// SEED dimension scale x5: 20.0 logical pixels (dp) in Flutter.
  static const double x5 = 20.0;
  /// SEED dimension scale x6: 24.0 logical pixels (dp) in Flutter.
  static const double x6 = 24.0;
  /// SEED dimension scale x7: 28.0 logical pixels (dp) in Flutter.
  static const double x7 = 28.0;
  /// SEED dimension scale x8: 32.0 logical pixels (dp) in Flutter.
  static const double x8 = 32.0;
  /// SEED dimension scale x9: 36.0 logical pixels (dp) in Flutter.
  static const double x9 = 36.0;
  /// SEED dimension scale x10: 40.0 logical pixels (dp) in Flutter.
  static const double x10 = 40.0;
  /// SEED dimension scale x12: 48.0 logical pixels (dp) in Flutter.
  static const double x12 = 48.0;
  /// SEED dimension scale x13: 52.0 logical pixels (dp) in Flutter.
  static const double x13 = 52.0;
  /// SEED dimension scale x14: 56.0 logical pixels (dp) in Flutter.
  static const double x14 = 56.0;
  /// SEED dimension scale x16: 64.0 logical pixels (dp) in Flutter.
  static const double x16 = 64.0;
}

/// Semantic horizontal spacing tokens.
class SeedSpacingX {
  const SeedSpacingX._();

  /// Horizontal spacing between chips, 8 logical pixels.
  static const double betweenChips = SeedDimension.x2; // 8px
  /// Horizontal global page gutter, 16 logical pixels.
  static const double globalGutter = SeedDimension.x4; // 16px
}

/// Semantic vertical spacing tokens.
class SeedSpacingY {
  const SeedSpacingY._();

  /// Default vertical component spacing, 12 logical pixels.
  static const double componentDefault = SeedDimension.x3; // 12px
  /// Vertical gap from navigation to page title, 20 logical pixels.
  static const double navToTitle = SeedDimension.x5; // 20px
  /// Bottom content padding, 56 logical pixels.
  static const double screenBottom = SeedDimension.x14; // 56px
  /// Vertical spacing between adjacent text blocks, 6 logical pixels.
  static const double betweenText = SeedDimension.x1_5; // 6px
}
