/// Dimension tokens defined by SEED Design System.
class SeedDimension {
  const SeedDimension._();

  static const double x0_5 = 2.0;
  static const double x1 = 4.0;
  static const double x1_5 = 6.0;
  static const double x2 = 8.0;
  static const double x2_5 = 10.0;
  static const double x3 = 12.0;
  static const double x3_5 = 14.0;
  static const double x4 = 16.0;
  static const double x4_5 = 18.0;
  static const double x5 = 20.0;
  static const double x6 = 24.0;
  static const double x7 = 28.0;
  static const double x8 = 32.0;
  static const double x9 = 36.0;
  static const double x10 = 40.0;
  static const double x12 = 48.0;
  static const double x13 = 52.0;
  static const double x14 = 56.0;
  static const double x16 = 64.0;
}

/// Semantic horizontal spacing tokens.
class SeedSpacingX {
  const SeedSpacingX._();

  static const double betweenChips = SeedDimension.x2; // 8px
  static const double globalGutter = SeedDimension.x4; // 16px
}

/// Semantic vertical spacing tokens.
class SeedSpacingY {
  const SeedSpacingY._();

  static const double componentDefault = SeedDimension.x3; // 12px
  static const double navToTitle = SeedDimension.x5; // 20px
  static const double screenBottom = SeedDimension.x14; // 56px
  static const double betweenText = SeedDimension.x1_5; // 6px
}
