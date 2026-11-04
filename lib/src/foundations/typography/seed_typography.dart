import 'package:material_ui/material_ui.dart';

/// Font size tokens defined by SEED Design System.
class SeedFontSize {
  const SeedFontSize._();

  /// Type scale t1 font size: 11.0 logical pixels.
  static const double t1 = 11.0;
  /// Type scale t2 font size: 12.0 logical pixels.
  static const double t2 = 12.0;
  /// Type scale t3 font size: 13.0 logical pixels.
  static const double t3 = 13.0;
  /// Type scale t4 font size: 14.0 logical pixels.
  static const double t4 = 14.0;
  /// Type scale t5 font size: 16.0 logical pixels.
  static const double t5 = 16.0;
  /// Type scale t6 font size: 18.0 logical pixels.
  static const double t6 = 18.0;
  /// Type scale t7 font size: 20.0 logical pixels.
  static const double t7 = 20.0;
  /// Type scale t8 font size: 22.0 logical pixels.
  static const double t8 = 22.0;
  /// Type scale t9 font size: 24.0 logical pixels.
  static const double t9 = 24.0;
  /// Type scale t10 font size: 26.0 logical pixels.
  static const double t10 = 26.0;
  /// Type scale t11 font size: 28.0 logical pixels.
  static const double t11 = 28.0;
  /// Type scale t12 font size: 32.0 logical pixels.
  static const double t12 = 32.0;
  /// Type scale t13 font size: 40.0 logical pixels.
  static const double t13 = 40.0;
  /// Type scale t14 font size: 48.0 logical pixels.
  static const double t14 = 48.0;
}

/// Line height tokens defined by SEED Design System (in pixels).
class SeedLineHeight {
  const SeedLineHeight._();

  /// Type scale t1 line height: 15.0 logical pixels.
  static const double t1 = 15.0;
  /// Type scale t2 line height: 16.0 logical pixels.
  static const double t2 = 16.0;
  /// Type scale t3 line height: 18.0 logical pixels.
  static const double t3 = 18.0;
  /// Type scale t4 line height: 19.0 logical pixels.
  static const double t4 = 19.0;
  /// Type scale t5 line height: 22.0 logical pixels.
  static const double t5 = 22.0;
  /// Type scale t6 line height: 24.0 logical pixels.
  static const double t6 = 24.0;
  /// Type scale t7 line height: 27.0 logical pixels.
  static const double t7 = 27.0;
  /// Type scale t8 line height: 30.0 logical pixels.
  static const double t8 = 30.0;
  /// Type scale t9 line height: 32.0 logical pixels.
  static const double t9 = 32.0;
  /// Type scale t10 line height: 35.0 logical pixels.
  static const double t10 = 35.0;
  /// Type scale t11 line height: 38.0 logical pixels.
  static const double t11 = 38.0;
  /// Type scale t12 line height: 42.0 logical pixels.
  static const double t12 = 42.0;
  /// Type scale t13 line height: 52.0 logical pixels.
  static const double t13 = 52.0;
  /// Type scale t14 line height: 60.0 logical pixels.
  static const double t14 = 60.0;
}

/// Font weight tokens defined by SEED Design System.
class SeedFontWeight {
  const SeedFontWeight._();

  /// Regular text weight: FontWeight.w400.
  static const FontWeight regular = FontWeight.w400;
  /// Medium text weight: FontWeight.w500.
  static const FontWeight medium = FontWeight.w500;
  /// Bold text weight: FontWeight.w700.
  static const FontWeight bold = FontWeight.w700;
}

/// Typography system of SEED Design System.
///
/// Implements both scale text styles (t1~t14 with regular, medium, bold)
/// and semantic text styles.
class SeedTypography extends ThemeExtension<SeedTypography> {
  /// SEED type scale t1, regular weight: 11 px font size with 15 px line height in [SeedTypography.base].
  final TextStyle t1Regular;
  /// SEED type scale t1, medium weight: 11 px font size with 15 px line height in [SeedTypography.base].
  final TextStyle t1Medium;
  /// SEED type scale t1, bold weight: 11 px font size with 15 px line height in [SeedTypography.base].
  final TextStyle t1Bold;

  /// SEED type scale t2, regular weight: 12 px font size with 16 px line height in [SeedTypography.base].
  final TextStyle t2Regular;
  /// SEED type scale t2, medium weight: 12 px font size with 16 px line height in [SeedTypography.base].
  final TextStyle t2Medium;
  /// SEED type scale t2, bold weight: 12 px font size with 16 px line height in [SeedTypography.base].
  final TextStyle t2Bold;

  /// SEED type scale t3, regular weight: 13 px font size with 18 px line height in [SeedTypography.base].
  final TextStyle t3Regular;
  /// SEED type scale t3, medium weight: 13 px font size with 18 px line height in [SeedTypography.base].
  final TextStyle t3Medium;
  /// SEED type scale t3, bold weight: 13 px font size with 18 px line height in [SeedTypography.base].
  final TextStyle t3Bold;

  /// SEED type scale t4, regular weight: 14 px font size with 19 px line height in [SeedTypography.base].
  final TextStyle t4Regular;
  /// SEED type scale t4, medium weight: 14 px font size with 19 px line height in [SeedTypography.base].
  final TextStyle t4Medium;
  /// SEED type scale t4, bold weight: 14 px font size with 19 px line height in [SeedTypography.base].
  final TextStyle t4Bold;

  /// SEED type scale t5, regular weight: 16 px font size with 22 px line height in [SeedTypography.base].
  final TextStyle t5Regular;
  /// SEED type scale t5, medium weight: 16 px font size with 22 px line height in [SeedTypography.base].
  final TextStyle t5Medium;
  /// SEED type scale t5, bold weight: 16 px font size with 22 px line height in [SeedTypography.base].
  final TextStyle t5Bold;

  /// SEED type scale t6, regular weight: 18 px font size with 24 px line height in [SeedTypography.base].
  final TextStyle t6Regular;
  /// SEED type scale t6, medium weight: 18 px font size with 24 px line height in [SeedTypography.base].
  final TextStyle t6Medium;
  /// SEED type scale t6, bold weight: 18 px font size with 24 px line height in [SeedTypography.base].
  final TextStyle t6Bold;

  /// SEED type scale t7, regular weight: 20 px font size with 27 px line height in [SeedTypography.base].
  final TextStyle t7Regular;
  /// SEED type scale t7, medium weight: 20 px font size with 27 px line height in [SeedTypography.base].
  final TextStyle t7Medium;
  /// SEED type scale t7, bold weight: 20 px font size with 27 px line height in [SeedTypography.base].
  final TextStyle t7Bold;

  /// SEED type scale t8, regular weight: 22 px font size with 30 px line height in [SeedTypography.base].
  final TextStyle t8Regular;
  /// SEED type scale t8, medium weight: 22 px font size with 30 px line height in [SeedTypography.base].
  final TextStyle t8Medium;
  /// SEED type scale t8, bold weight: 22 px font size with 30 px line height in [SeedTypography.base].
  final TextStyle t8Bold;

  /// SEED type scale t9, regular weight: 24 px font size with 32 px line height in [SeedTypography.base].
  final TextStyle t9Regular;
  /// SEED type scale t9, medium weight: 24 px font size with 32 px line height in [SeedTypography.base].
  final TextStyle t9Medium;
  /// SEED type scale t9, bold weight: 24 px font size with 32 px line height in [SeedTypography.base].
  final TextStyle t9Bold;

  /// SEED type scale t10, regular weight: 26 px font size with 35 px line height in [SeedTypography.base].
  final TextStyle t10Regular;
  /// SEED type scale t10, medium weight: 26 px font size with 35 px line height in [SeedTypography.base].
  final TextStyle t10Medium;
  /// SEED type scale t10, bold weight: 26 px font size with 35 px line height in [SeedTypography.base].
  final TextStyle t10Bold;

  /// SEED type scale t11, regular weight: 28 px font size with 38 px line height in [SeedTypography.base].
  final TextStyle t11Regular;
  /// SEED type scale t11, medium weight: 28 px font size with 38 px line height in [SeedTypography.base].
  final TextStyle t11Medium;
  /// SEED type scale t11, bold weight: 28 px font size with 38 px line height in [SeedTypography.base].
  final TextStyle t11Bold;

  /// SEED type scale t12, regular weight: 32 px font size with 42 px line height in [SeedTypography.base].
  final TextStyle t12Regular;
  /// SEED type scale t12, medium weight: 32 px font size with 42 px line height in [SeedTypography.base].
  final TextStyle t12Medium;
  /// SEED type scale t12, bold weight: 32 px font size with 42 px line height in [SeedTypography.base].
  final TextStyle t12Bold;

  /// SEED type scale t13, regular weight: 40 px font size with 52 px line height in [SeedTypography.base].
  final TextStyle t13Regular;
  /// SEED type scale t13, medium weight: 40 px font size with 52 px line height in [SeedTypography.base].
  final TextStyle t13Medium;
  /// SEED type scale t13, bold weight: 40 px font size with 52 px line height in [SeedTypography.base].
  final TextStyle t13Bold;

  /// SEED type scale t14, regular weight: 48 px font size with 60 px line height in [SeedTypography.base].
  final TextStyle t14Regular;
  /// SEED type scale t14, medium weight: 48 px font size with 60 px line height in [SeedTypography.base].
  final TextStyle t14Medium;
  /// SEED type scale t14, bold weight: 48 px font size with 60 px line height in [SeedTypography.base].
  final TextStyle t14Bold;

  // Semantic shortcuts
  /// Screen-heading semantic style, equal to [t10Bold].
  TextStyle get screenTitle => t10Bold;
  /// Long-form article body style: [t5Regular] with a 24 px line height.
  TextStyle get articleBody =>
      t5Regular.copyWith(height: SeedLineHeight.t6 / SeedFontSize.t5);
  /// Long-form article note style: [t4Regular] with a 22 px line height.
  TextStyle get articleNote =>
      t4Regular.copyWith(height: SeedLineHeight.t5 / SeedFontSize.t4);
  /// Section-heading semantic style, equal to [t6Bold].
  TextStyle get sectionTitle => t6Bold;
  /// Default body text style, equal to [t5Regular].
  TextStyle get body => t5Regular;
  /// Medium-weight body style, equal to [t5Medium].
  TextStyle get bodyMedium => t5Medium;
  /// Bold body style, equal to [t5Bold].
  TextStyle get bodyBold => t5Bold;
  /// Caption style, equal to [t3Regular].
  TextStyle get caption => t3Regular;
  /// Medium-weight caption style, equal to [t3Medium].
  TextStyle get captionMedium => t3Medium;
  /// Footnote style, equal to [t2Regular].
  TextStyle get footnote => t2Regular;

  /// Creates a complete typography extension.
  ///
  /// All 42 styles (t1–t14 in regular, medium and bold) are required.
  const SeedTypography({
    required this.t1Regular,
    required this.t1Medium,
    required this.t1Bold,
    required this.t2Regular,
    required this.t2Medium,
    required this.t2Bold,
    required this.t3Regular,
    required this.t3Medium,
    required this.t3Bold,
    required this.t4Regular,
    required this.t4Medium,
    required this.t4Bold,
    required this.t5Regular,
    required this.t5Medium,
    required this.t5Bold,
    required this.t6Regular,
    required this.t6Medium,
    required this.t6Bold,
    required this.t7Regular,
    required this.t7Medium,
    required this.t7Bold,
    required this.t8Regular,
    required this.t8Medium,
    required this.t8Bold,
    required this.t9Regular,
    required this.t9Medium,
    required this.t9Bold,
    required this.t10Regular,
    required this.t10Medium,
    required this.t10Bold,
    required this.t11Regular,
    required this.t11Medium,
    required this.t11Bold,
    required this.t12Regular,
    required this.t12Medium,
    required this.t12Bold,
    required this.t13Regular,
    required this.t13Medium,
    required this.t13Bold,
    required this.t14Regular,
    required this.t14Medium,
    required this.t14Bold,
  });

  /// Creates the SEED base type scale.
  ///
  /// [fontFamily] (default null) specifies the font; [defaultColor] (default null) sets every style
  /// foreground. Sizes and line heights come from [SeedFontSize] and [SeedLineHeight] with even leading
  /// distribution.
  factory SeedTypography.base({String? fontFamily, Color? defaultColor}) {
    TextStyle makeStyle(double fontSize, double lineHeight, FontWeight weight) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        height: lineHeight / fontSize,
        fontWeight: weight,
        color: defaultColor,
        leadingDistribution: TextLeadingDistribution.even,
      );
    }

    return SeedTypography(
      t1Regular: makeStyle(
        SeedFontSize.t1,
        SeedLineHeight.t1,
        SeedFontWeight.regular,
      ),
      t1Medium: makeStyle(
        SeedFontSize.t1,
        SeedLineHeight.t1,
        SeedFontWeight.medium,
      ),
      t1Bold: makeStyle(
        SeedFontSize.t1,
        SeedLineHeight.t1,
        SeedFontWeight.bold,
      ),

      t2Regular: makeStyle(
        SeedFontSize.t2,
        SeedLineHeight.t2,
        SeedFontWeight.regular,
      ),
      t2Medium: makeStyle(
        SeedFontSize.t2,
        SeedLineHeight.t2,
        SeedFontWeight.medium,
      ),
      t2Bold: makeStyle(
        SeedFontSize.t2,
        SeedLineHeight.t2,
        SeedFontWeight.bold,
      ),

      t3Regular: makeStyle(
        SeedFontSize.t3,
        SeedLineHeight.t3,
        SeedFontWeight.regular,
      ),
      t3Medium: makeStyle(
        SeedFontSize.t3,
        SeedLineHeight.t3,
        SeedFontWeight.medium,
      ),
      t3Bold: makeStyle(
        SeedFontSize.t3,
        SeedLineHeight.t3,
        SeedFontWeight.bold,
      ),

      t4Regular: makeStyle(
        SeedFontSize.t4,
        SeedLineHeight.t4,
        SeedFontWeight.regular,
      ),
      t4Medium: makeStyle(
        SeedFontSize.t4,
        SeedLineHeight.t4,
        SeedFontWeight.medium,
      ),
      t4Bold: makeStyle(
        SeedFontSize.t4,
        SeedLineHeight.t4,
        SeedFontWeight.bold,
      ),

      t5Regular: makeStyle(
        SeedFontSize.t5,
        SeedLineHeight.t5,
        SeedFontWeight.regular,
      ),
      t5Medium: makeStyle(
        SeedFontSize.t5,
        SeedLineHeight.t5,
        SeedFontWeight.medium,
      ),
      t5Bold: makeStyle(
        SeedFontSize.t5,
        SeedLineHeight.t5,
        SeedFontWeight.bold,
      ),

      t6Regular: makeStyle(
        SeedFontSize.t6,
        SeedLineHeight.t6,
        SeedFontWeight.regular,
      ),
      t6Medium: makeStyle(
        SeedFontSize.t6,
        SeedLineHeight.t6,
        SeedFontWeight.medium,
      ),
      t6Bold: makeStyle(
        SeedFontSize.t6,
        SeedLineHeight.t6,
        SeedFontWeight.bold,
      ),

      t7Regular: makeStyle(
        SeedFontSize.t7,
        SeedLineHeight.t7,
        SeedFontWeight.regular,
      ),
      t7Medium: makeStyle(
        SeedFontSize.t7,
        SeedLineHeight.t7,
        SeedFontWeight.medium,
      ),
      t7Bold: makeStyle(
        SeedFontSize.t7,
        SeedLineHeight.t7,
        SeedFontWeight.bold,
      ),

      t8Regular: makeStyle(
        SeedFontSize.t8,
        SeedLineHeight.t8,
        SeedFontWeight.regular,
      ),
      t8Medium: makeStyle(
        SeedFontSize.t8,
        SeedLineHeight.t8,
        SeedFontWeight.medium,
      ),
      t8Bold: makeStyle(
        SeedFontSize.t8,
        SeedLineHeight.t8,
        SeedFontWeight.bold,
      ),

      t9Regular: makeStyle(
        SeedFontSize.t9,
        SeedLineHeight.t9,
        SeedFontWeight.regular,
      ),
      t9Medium: makeStyle(
        SeedFontSize.t9,
        SeedLineHeight.t9,
        SeedFontWeight.medium,
      ),
      t9Bold: makeStyle(
        SeedFontSize.t9,
        SeedLineHeight.t9,
        SeedFontWeight.bold,
      ),

      t10Regular: makeStyle(
        SeedFontSize.t10,
        SeedLineHeight.t10,
        SeedFontWeight.regular,
      ),
      t10Medium: makeStyle(
        SeedFontSize.t10,
        SeedLineHeight.t10,
        SeedFontWeight.medium,
      ),
      t10Bold: makeStyle(
        SeedFontSize.t10,
        SeedLineHeight.t10,
        SeedFontWeight.bold,
      ),

      t11Regular: makeStyle(
        SeedFontSize.t11,
        SeedLineHeight.t11,
        SeedFontWeight.regular,
      ),
      t11Medium: makeStyle(
        SeedFontSize.t11,
        SeedLineHeight.t11,
        SeedFontWeight.medium,
      ),
      t11Bold: makeStyle(
        SeedFontSize.t11,
        SeedLineHeight.t11,
        SeedFontWeight.bold,
      ),

      t12Regular: makeStyle(
        SeedFontSize.t12,
        SeedLineHeight.t12,
        SeedFontWeight.regular,
      ),
      t12Medium: makeStyle(
        SeedFontSize.t12,
        SeedLineHeight.t12,
        SeedFontWeight.medium,
      ),
      t12Bold: makeStyle(
        SeedFontSize.t12,
        SeedLineHeight.t12,
        SeedFontWeight.bold,
      ),

      t13Regular: makeStyle(
        SeedFontSize.t13,
        SeedLineHeight.t13,
        SeedFontWeight.regular,
      ),
      t13Medium: makeStyle(
        SeedFontSize.t13,
        SeedLineHeight.t13,
        SeedFontWeight.medium,
      ),
      t13Bold: makeStyle(
        SeedFontSize.t13,
        SeedLineHeight.t13,
        SeedFontWeight.bold,
      ),

      t14Regular: makeStyle(
        SeedFontSize.t14,
        SeedLineHeight.t14,
        SeedFontWeight.regular,
      ),
      t14Medium: makeStyle(
        SeedFontSize.t14,
        SeedLineHeight.t14,
        SeedFontWeight.medium,
      ),
      t14Bold: makeStyle(
        SeedFontSize.t14,
        SeedLineHeight.t14,
        SeedFontWeight.bold,
      ),
    );
  }

  /// Transforms every scale style, including styles used by component themes.
  SeedTypography mapStyles(TextStyle Function(TextStyle) transform) {
    return copyWith(
      t1Regular: transform(t1Regular),
      t1Medium: transform(t1Medium),
      t1Bold: transform(t1Bold),
      t2Regular: transform(t2Regular),
      t2Medium: transform(t2Medium),
      t2Bold: transform(t2Bold),
      t3Regular: transform(t3Regular),
      t3Medium: transform(t3Medium),
      t3Bold: transform(t3Bold),
      t4Regular: transform(t4Regular),
      t4Medium: transform(t4Medium),
      t4Bold: transform(t4Bold),
      t5Regular: transform(t5Regular),
      t5Medium: transform(t5Medium),
      t5Bold: transform(t5Bold),
      t6Regular: transform(t6Regular),
      t6Medium: transform(t6Medium),
      t6Bold: transform(t6Bold),
      t7Regular: transform(t7Regular),
      t7Medium: transform(t7Medium),
      t7Bold: transform(t7Bold),
      t8Regular: transform(t8Regular),
      t8Medium: transform(t8Medium),
      t8Bold: transform(t8Bold),
      t9Regular: transform(t9Regular),
      t9Medium: transform(t9Medium),
      t9Bold: transform(t9Bold),
      t10Regular: transform(t10Regular),
      t10Medium: transform(t10Medium),
      t10Bold: transform(t10Bold),
      t11Regular: transform(t11Regular),
      t11Medium: transform(t11Medium),
      t11Bold: transform(t11Bold),
      t12Regular: transform(t12Regular),
      t12Medium: transform(t12Medium),
      t12Bold: transform(t12Bold),
      t13Regular: transform(t13Regular),
      t13Medium: transform(t13Medium),
      t13Bold: transform(t13Bold),
      t14Regular: transform(t14Regular),
      t14Medium: transform(t14Medium),
      t14Bold: transform(t14Bold),
    );
  }

  /// Returns an updated typography theme; every omitted/null type style retains its previous value.
  @override
  SeedTypography copyWith({
    TextStyle? t1Regular,
    TextStyle? t1Medium,
    TextStyle? t1Bold,
    TextStyle? t2Regular,
    TextStyle? t2Medium,
    TextStyle? t2Bold,
    TextStyle? t3Regular,
    TextStyle? t3Medium,
    TextStyle? t3Bold,
    TextStyle? t4Regular,
    TextStyle? t4Medium,
    TextStyle? t4Bold,
    TextStyle? t5Regular,
    TextStyle? t5Medium,
    TextStyle? t5Bold,
    TextStyle? t6Regular,
    TextStyle? t6Medium,
    TextStyle? t6Bold,
    TextStyle? t7Regular,
    TextStyle? t7Medium,
    TextStyle? t7Bold,
    TextStyle? t8Regular,
    TextStyle? t8Medium,
    TextStyle? t8Bold,
    TextStyle? t9Regular,
    TextStyle? t9Medium,
    TextStyle? t9Bold,
    TextStyle? t10Regular,
    TextStyle? t10Medium,
    TextStyle? t10Bold,
    TextStyle? t11Regular,
    TextStyle? t11Medium,
    TextStyle? t11Bold,
    TextStyle? t12Regular,
    TextStyle? t12Medium,
    TextStyle? t12Bold,
    TextStyle? t13Regular,
    TextStyle? t13Medium,
    TextStyle? t13Bold,
    TextStyle? t14Regular,
    TextStyle? t14Medium,
    TextStyle? t14Bold,
  }) {
    return SeedTypography(
      t1Regular: t1Regular ?? this.t1Regular,
      t1Medium: t1Medium ?? this.t1Medium,
      t1Bold: t1Bold ?? this.t1Bold,
      t2Regular: t2Regular ?? this.t2Regular,
      t2Medium: t2Medium ?? this.t2Medium,
      t2Bold: t2Bold ?? this.t2Bold,
      t3Regular: t3Regular ?? this.t3Regular,
      t3Medium: t3Medium ?? this.t3Medium,
      t3Bold: t3Bold ?? this.t3Bold,
      t4Regular: t4Regular ?? this.t4Regular,
      t4Medium: t4Medium ?? this.t4Medium,
      t4Bold: t4Bold ?? this.t4Bold,
      t5Regular: t5Regular ?? this.t5Regular,
      t5Medium: t5Medium ?? this.t5Medium,
      t5Bold: t5Bold ?? this.t5Bold,
      t6Regular: t6Regular ?? this.t6Regular,
      t6Medium: t6Medium ?? this.t6Medium,
      t6Bold: t6Bold ?? this.t6Bold,
      t7Regular: t7Regular ?? this.t7Regular,
      t7Medium: t7Medium ?? this.t7Medium,
      t7Bold: t7Bold ?? this.t7Bold,
      t8Regular: t8Regular ?? this.t8Regular,
      t8Medium: t8Medium ?? this.t8Medium,
      t8Bold: t8Bold ?? this.t8Bold,
      t9Regular: t9Regular ?? this.t9Regular,
      t9Medium: t9Medium ?? this.t9Medium,
      t9Bold: t9Bold ?? this.t9Bold,
      t10Regular: t10Regular ?? this.t10Regular,
      t10Medium: t10Medium ?? this.t10Medium,
      t10Bold: t10Bold ?? this.t10Bold,
      t11Regular: t11Regular ?? this.t11Regular,
      t11Medium: t11Medium ?? this.t11Medium,
      t11Bold: t11Bold ?? this.t11Bold,
      t12Regular: t12Regular ?? this.t12Regular,
      t12Medium: t12Medium ?? this.t12Medium,
      t12Bold: t12Bold ?? this.t12Bold,
      t13Regular: t13Regular ?? this.t13Regular,
      t13Medium: t13Medium ?? this.t13Medium,
      t13Bold: t13Bold ?? this.t13Bold,
      t14Regular: t14Regular ?? this.t14Regular,
      t14Medium: t14Medium ?? this.t14Medium,
      t14Bold: t14Bold ?? this.t14Bold,
    );
  }

  /// Interpolates each type scale style toward [other] by [t], or returns this for an incompatible/null
  /// theme.
  @override
  SeedTypography lerp(ThemeExtension<SeedTypography>? other, double t) {
    if (other is! SeedTypography) return this;
    return SeedTypography(
      t1Regular: TextStyle.lerp(t1Regular, other.t1Regular, t)!,
      t1Medium: TextStyle.lerp(t1Medium, other.t1Medium, t)!,
      t1Bold: TextStyle.lerp(t1Bold, other.t1Bold, t)!,
      t2Regular: TextStyle.lerp(t2Regular, other.t2Regular, t)!,
      t2Medium: TextStyle.lerp(t2Medium, other.t2Medium, t)!,
      t2Bold: TextStyle.lerp(t2Bold, other.t2Bold, t)!,
      t3Regular: TextStyle.lerp(t3Regular, other.t3Regular, t)!,
      t3Medium: TextStyle.lerp(t3Medium, other.t3Medium, t)!,
      t3Bold: TextStyle.lerp(t3Bold, other.t3Bold, t)!,
      t4Regular: TextStyle.lerp(t4Regular, other.t4Regular, t)!,
      t4Medium: TextStyle.lerp(t4Medium, other.t4Medium, t)!,
      t4Bold: TextStyle.lerp(t4Bold, other.t4Bold, t)!,
      t5Regular: TextStyle.lerp(t5Regular, other.t5Regular, t)!,
      t5Medium: TextStyle.lerp(t5Medium, other.t5Medium, t)!,
      t5Bold: TextStyle.lerp(t5Bold, other.t5Bold, t)!,
      t6Regular: TextStyle.lerp(t6Regular, other.t6Regular, t)!,
      t6Medium: TextStyle.lerp(t6Medium, other.t6Medium, t)!,
      t6Bold: TextStyle.lerp(t6Bold, other.t6Bold, t)!,
      t7Regular: TextStyle.lerp(t7Regular, other.t7Regular, t)!,
      t7Medium: TextStyle.lerp(t7Medium, other.t7Medium, t)!,
      t7Bold: TextStyle.lerp(t7Bold, other.t7Bold, t)!,
      t8Regular: TextStyle.lerp(t8Regular, other.t8Regular, t)!,
      t8Medium: TextStyle.lerp(t8Medium, other.t8Medium, t)!,
      t8Bold: TextStyle.lerp(t8Bold, other.t8Bold, t)!,
      t9Regular: TextStyle.lerp(t9Regular, other.t9Regular, t)!,
      t9Medium: TextStyle.lerp(t9Medium, other.t9Medium, t)!,
      t9Bold: TextStyle.lerp(t9Bold, other.t9Bold, t)!,
      t10Regular: TextStyle.lerp(t10Regular, other.t10Regular, t)!,
      t10Medium: TextStyle.lerp(t10Medium, other.t10Medium, t)!,
      t10Bold: TextStyle.lerp(t10Bold, other.t10Bold, t)!,
      t11Regular: TextStyle.lerp(t11Regular, other.t11Regular, t)!,
      t11Medium: TextStyle.lerp(t11Medium, other.t11Medium, t)!,
      t11Bold: TextStyle.lerp(t11Bold, other.t11Bold, t)!,
      t12Regular: TextStyle.lerp(t12Regular, other.t12Regular, t)!,
      t12Medium: TextStyle.lerp(t12Medium, other.t12Medium, t)!,
      t12Bold: TextStyle.lerp(t12Bold, other.t12Bold, t)!,
      t13Regular: TextStyle.lerp(t13Regular, other.t13Regular, t)!,
      t13Medium: TextStyle.lerp(t13Medium, other.t13Medium, t)!,
      t13Bold: TextStyle.lerp(t13Bold, other.t13Bold, t)!,
      t14Regular: TextStyle.lerp(t14Regular, other.t14Regular, t)!,
      t14Medium: TextStyle.lerp(t14Medium, other.t14Medium, t)!,
      t14Bold: TextStyle.lerp(t14Bold, other.t14Bold, t)!,
    );
  }

  /// Converts this [SeedTypography] into standard Flutter [TextTheme]
  /// for seamless Material 3 integration.
  TextTheme toTextTheme({Color? defaultColor}) {
    TextStyle applyColor(TextStyle style) {
      return defaultColor != null ? style.copyWith(color: defaultColor) : style;
    }

    return TextTheme(
      displayLarge: applyColor(t13Bold),
      displayMedium: applyColor(t12Bold),
      displaySmall: applyColor(t11Bold),
      headlineLarge: applyColor(t10Bold),
      headlineMedium: applyColor(t9Bold),
      headlineSmall: applyColor(t8Bold),
      titleLarge: applyColor(t7Bold),
      titleMedium: applyColor(t6Bold),
      titleSmall: applyColor(t5Bold),
      bodyLarge: applyColor(t5Regular),
      bodyMedium: applyColor(t4Regular),
      bodySmall: applyColor(t3Regular),
      labelLarge: applyColor(t4Bold),
      labelMedium: applyColor(t3Bold),
      labelSmall: applyColor(t2Bold),
    );
  }
}
