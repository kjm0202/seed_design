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
  final SeedThemeData data;
  final Widget child;

  const SeedTheme({super.key, required this.data, required this.child});

  static SeedThemeData of(BuildContext context) {
    return maybeOf(context) ??
        (Theme.of(context).brightness == Brightness.dark
            ? SeedThemeData.dark()
            : SeedThemeData.light());
  }

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

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).withSeedDesign(seedTheme: data),
    child: child,
  );
}

/// Convenience access to the nearest SEED ThemeExtensions.
extension SeedThemeContextExtension on BuildContext {
  SeedThemeData get seedTheme => SeedTheme.of(this);
  SeedColorScheme get seedColor => seedTheme.colorScheme;
  SeedTypography get seedTypography => seedTheme.typography;
  SeedShadows get seedShadows => seedTheme.shadows;
  bool get seedIsDark => seedTheme.isDark;
}
