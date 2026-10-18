import 'package:material_ui/material_ui.dart';

import '../theme/seed_theme_data.dart';

/// A bridge widget for incrementally migrating legacy Material 3 screens or subtrees
/// to the SEED Design System.
///
/// Injects [SeedTheme] and wraps descendants in a standard Flutter [Theme] configured
/// with SEED design tokens and Material 3 overrides.
///
/// Useful when migrating an app screen-by-screen or feature-by-feature without
/// immediately changing the root `MaterialApp` theme.
///
/// Example:
/// ```dart
/// // Migrate a specific route or modal:
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const SeedMaterialBridge(
///       child: MyLegacyScreen(),
///     ),
///   ),
/// );
/// ```
class SeedMaterialBridge extends StatelessWidget {
  final Widget child;
  final SeedThemeData? theme;
  final Brightness? brightness;

  const SeedMaterialBridge({
    super.key,
    required this.child,
    this.theme,
    this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness = brightness ?? Theme.of(context).brightness;
    return Theme(
      data: Theme.of(context)
          .withSeedDesign(seedTheme: theme, brightness: effectiveBrightness),
      child: child,
    );
  }
}

/// Reference catalog and architectural migration utilities for transitioning
/// from Flutter Material 3 to SEED Design System.
class SeedMigration {
  const SeedMigration._();

  /// Direct mapping reference from Material 3 components to SEED Design components.
  static const Map<String, String> componentMapping = {
    'ElevatedButton': 'SeedButton(variant: SeedButtonVariant.neutralSolid)',
    'FilledButton': 'SeedButton(variant: SeedButtonVariant.brandSolid)',
    'OutlinedButton': 'SeedButton(variant: SeedButtonVariant.neutralOutline)',
    'TextButton': 'SeedButton(variant: SeedButtonVariant.ghost)',
    'FloatingActionButton':
        'SeedFloatingActionButton / SeedContextualFloatingButton',
    'AppBar': 'SeedTopNavigation',
    'TextField / TextFormField': 'SeedTextInput / SeedField',
    'Switch': 'SeedSwitch',
    'Checkbox': 'SeedCheckbox',
    'Radio': 'SeedRadio',
    'SegmentedButton': 'SeedSegmentedControl',
    'TabBar': 'SeedTabs',
    'NavigationBar / BottomNavigationBar': 'SeedBottomNavigation',
    'NavigationDrawer': 'SeedSideNavigation / SeedSidePanel',
    'Dialog / AlertDialog': 'SeedDialog / SeedAlertDialog / showSeedDialog',
    'BottomSheet / showModalBottomSheet':
        'SeedBottomSheet / SeedMenuSheet / showSeedBottomSheet',
    'Chip / FilterChip / ActionChip': 'SeedChip',
    'CircularProgressIndicator': 'SeedProgressCircle',
    'LinearProgressIndicator': 'SeedSkeleton / SeedProgressCircle',
    'SnackBar / ScaffoldMessenger': 'SeedSnackbar / showSeedSnackbar',
    'Divider': 'SeedDivider',
    'ListTile': 'SeedListItem',
    'Tooltip': 'SeedHelpBubble',
    'Slider': 'SeedSlider',
    'ExpansionTile': 'SeedAccordionItem',
    'Badge': 'SeedBadge / SeedNotificationBadge',
    'Banner': 'SeedPageBanner',
    'CircleAvatar': 'SeedAvatar',
  };

  /// Typography mapping from Material 3 TextTheme to SEED Typography tokens.
  static const Map<String, String> typographyMapping = {
    'displayLarge': 'SeedTypography.t13Bold (40pt)',
    'displayMedium': 'SeedTypography.t12Bold (32pt)',
    'displaySmall': 'SeedTypography.t11Bold (28pt)',
    'headlineLarge': 'SeedTypography.t10Bold (26pt)',
    'headlineMedium': 'SeedTypography.t9Bold (24pt)',
    'headlineSmall': 'SeedTypography.t8Bold (22pt)',
    'titleLarge': 'SeedTypography.t7Bold (20pt)',
    'titleMedium': 'SeedTypography.t6Bold (18pt)',
    'titleSmall': 'SeedTypography.t5Bold (16pt)',
    'bodyLarge': 'SeedTypography.t5Regular (16pt)',
    'bodyMedium': 'SeedTypography.t4Regular (14pt)',
    'bodySmall': 'SeedTypography.t3Regular (13pt)',
    'labelLarge': 'SeedTypography.t4Bold (14pt)',
    'labelMedium': 'SeedTypography.t3Bold (13pt)',
    'labelSmall': 'SeedTypography.t2Bold (12pt)',
  };
}
