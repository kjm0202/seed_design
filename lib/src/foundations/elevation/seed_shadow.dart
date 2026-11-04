import 'package:material_ui/material_ui.dart';

/// Elevation shadow tokens defined by SEED Design System.
class SeedShadows extends ThemeExtension<SeedShadows> {
  /// Elevation level 1 BoxShadow layers for the configured light or dark theme.
  final List<BoxShadow> s1;
  /// Elevation level 2 BoxShadow layers for the configured light or dark theme.
  final List<BoxShadow> s2;
  /// Elevation level 3 BoxShadow layers for the configured light or dark theme.
  final List<BoxShadow> s3;

  /// Creates custom elevation shadows for [s1], [s2], and [s3].
  const SeedShadows({required this.s1, required this.s2, required this.s3});

  /// Creates light-theme elevation shadows: offsets 1, 2, and 4 px with blur radii 4, 10, and 16 px.
  const SeedShadows.light()
    : s1 = const [
        BoxShadow(
          color: Color(0x14000000),
          offset: Offset(0, 1),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
      s2 = const [
        BoxShadow(
          color: Color(0x1A000000),
          offset: Offset(0, 2),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
      s3 = const [
        BoxShadow(
          color: Color(0x1F000000),
          offset: Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  /// Creates dark-theme elevation shadows with the same geometry and greater opacity.
  const SeedShadows.dark()
    : s1 = const [
        BoxShadow(
          color: Color(0x80000000),
          offset: Offset(0, 1),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
      s2 = const [
        BoxShadow(
          color: Color(0xAD000000),
          offset: Offset(0, 2),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
      s3 = const [
        BoxShadow(
          color: Color(0xCC000000),
          offset: Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  /// Returns a shadow theme with any specified elevation lists replaced; null leaves each level unchanged.
  @override
  SeedShadows copyWith({
    List<BoxShadow>? s1,
    List<BoxShadow>? s2,
    List<BoxShadow>? s3,
  }) {
    return SeedShadows(s1: s1 ?? this.s1, s2: s2 ?? this.s2, s3: s3 ?? this.s3);
  }

  /// Interpolates the three shadow lists toward [other] by [t]; returns this if [other] is not [SeedShadows].
  @override
  SeedShadows lerp(ThemeExtension<SeedShadows>? other, double t) {
    if (other is! SeedShadows) return this;
    return SeedShadows(
      s1: BoxShadow.lerpList(s1, other.s1, t) ?? s1,
      s2: BoxShadow.lerpList(s2, other.s2, t) ?? s2,
      s3: BoxShadow.lerpList(s3, other.s3, t) ?? s3,
    );
  }
}
