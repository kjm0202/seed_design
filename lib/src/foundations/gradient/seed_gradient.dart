// Generated from official SEED gradient.yaml by tool/seed_reference.py.
// Upstream: d18f14e70f7b73ba84c032717d6413610bce0437
import 'package:material_ui/material_ui.dart';

/// Official SEED gradient stops. Directions are set by the consuming component.
class SeedGradients {
  const SeedGradients._();
  static LinearGradient fadeMask({bool isDark = false}) => LinearGradient(
    colors: const [
      Color(0x00000000),
      Color(0x03000000),
      Color(0x05000000),
      Color(0x0D000000),
      Color(0x14000000),
      Color(0x21000000),
      Color(0x2E000000),
      Color(0x40000000),
      Color(0x52000000),
      Color(0x66000000),
      Color(0x7A000000),
      Color(0x94000000),
      Color(0xAB000000),
      Color(0xC7000000),
      Color(0xE3000000),
      Color(0xFF000000),
    ],
    stops: const [
      0,
      0.08,
      0.16,
      0.22,
      0.29,
      0.35,
      0.41,
      0.47,
      0.53,
      0.59,
      0.65,
      0.71,
      0.78,
      0.84,
      0.92,
      1,
    ],
  );
  static LinearGradient glowMagic({bool isDark = false}) => LinearGradient(
    colors: isDark
        ? const [Color(0xFF2D252D), Color(0xFF3A312B), Color(0xFF333232)]
        : const [Color(0xFFFEF6F7), Color(0xFFFEF0E7), Color(0xFFF9F7F5)],
    stops: const [0, 0.8, 1],
  );
  static LinearGradient glowMagicPressed({bool isDark = false}) =>
      LinearGradient(
        colors: isDark
            ? const [Color(0xFF3E333E), Color(0xFF51453E), Color(0xFF434242)]
            : const [Color(0xFFFBF0F2), Color(0xFFFFE8DB), Color(0xFFF5F2EF)],
        stops: const [0, 0.8, 1],
      );
  static LinearGradient highlightMagic({bool isDark = false}) => LinearGradient(
    colors: const [Color(0xFFFF6600), Color(0xFFD25ACA)],
    stops: const [0.2, 1],
  );
  static LinearGradient highlightMagicPressed({bool isDark = false}) =>
      LinearGradient(
        colors: isDark
            ? const [Color(0xFFFF9E65), Color(0xFFE89BEE)]
            : const [Color(0xFFE14F00), Color(0xFFAE58BF)],
        stops: const [0.2, 1],
      );
  static LinearGradient shimmerMagic({bool isDark = false}) => LinearGradient(
    colors: isDark
        ? const [
            Color(0x00FFF9F5),
            Color(0x1AFFF9F5),
            Color(0x1AFFF9F5),
            Color(0x00FFF9F5),
          ]
        : const [
            Color(0x00FFF9F5),
            Color(0xCCFFF9F5),
            Color(0xCCFFF9F5),
            Color(0x00FFF9F5),
          ],
    stops: const [0, 0.46, 0.54, 1],
  );
  static LinearGradient shimmerNeutral({bool isDark = false}) => LinearGradient(
    colors: isDark
        ? const [
            Color(0x00FFFFFF),
            Color(0x1AFFFFFF),
            Color(0x1AFFFFFF),
            Color(0x00FFFFFF),
          ]
        : const [
            Color(0x00FFFFFF),
            Color(0xABFFFFFF),
            Color(0xABFFFFFF),
            Color(0x00FFFFFF),
          ],
    stops: const [0, 0.46, 0.54, 1],
  );
}
