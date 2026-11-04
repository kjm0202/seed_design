import 'package:material_ui/material_ui.dart';

import 'seed_theme_data.dart';
import '../foundations/colors/seed_color_scheme.dart';
import '../foundations/typography/seed_typography.dart';
import '../foundations/elevation/seed_shadow.dart';

/// Applies SEED tokens and matching Material styles to a subtree.
///
/// App-wide themes should be installed through MaterialApp.theme/darkTheme.
/// This wrapper is useful for local overrides, which Flutter's inherited Theme
/// capture also preserves in dialogs and modal bottom sheets.
class SeedTheme extends StatelessWidget {
  /// SEED theme token bundle to install under this subtree.
  final SeedThemeData data;
  /// Descendant subtree receiving the SEED theme.
  final Widget child;

  /// Installs [data] as SEED ThemeExtensions and matching Material widget themes around [child].
  const SeedTheme({super.key, required this.data, required this.child});

  /// Resolves SEED ThemeExtensions in [context], falling back to light or dark defaults while preserving
  /// the app font family and fallback fonts.
  static SeedThemeData of(BuildContext context) {
    final inherited = Theme.of(context);
    final existing = maybeOf(context);
    if (existing != null) return existing;

    // Keep the app's configured font when a consumer reads SEED tokens before
    // installing the optional SEED ThemeExtensions.
    final inheritedFont = inherited.textTheme.bodyMedium;
    final fallback = inherited.brightness == Brightness.dark
        ? SeedThemeData.dark(fontFamily: inheritedFont?.fontFamily)
        : SeedThemeData.light(fontFamily: inheritedFont?.fontFamily);
    return fallback.copyWith(
      typography: fallback.typography.mapStyles(
        (style) => style.copyWith(
          fontFamilyFallback: inheritedFont?.fontFamilyFallback,
        ),
      ),
    );
  }

  /// Returns a SEED theme if all three ThemeExtensions are installed, or null otherwise.
  static SeedThemeData? maybeOf(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SeedColorScheme>();
    final typography = theme.extension<SeedTypography>();
    final shadows = theme.extension<SeedShadows>();
    if (colors == null || typography == null || shadows == null) return null;
    return SeedThemeData(
      brightness: theme.brightness,
      colorScheme: colors,
      typography: typography,
      shadows: shadows,
    );
  }

  /// Installs [data] into the nearest Material Theme while retaining other host configuration.
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).withSeedDesign(seedTheme: data),
    child: child,
  );
}

/// Convenience access to the nearest SEED ThemeExtensions.
extension SeedThemeContextExtension on BuildContext {
  /// Resolves the complete SEED theme from this BuildContext, creating defaults if none are installed.
  SeedThemeData get seedTheme => SeedTheme.of(this);
  /// Foreground, background and stroke color roles for the current BuildContext.
  SeedColorScheme get seedColor => seedTheme.colorScheme;
  /// SEED typography styles for the current BuildContext.
  SeedTypography get seedTypography => seedTheme.typography;
  /// Elevation shadow tokens for the current BuildContext.
  SeedShadows get seedShadows => seedTheme.shadows;
  /// Whether the resolved SEED theme is dark.
  bool get seedIsDark => seedTheme.isDark;
}
