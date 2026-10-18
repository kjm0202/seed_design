import 'package:material_ui/material_ui.dart';

import '../foundations/colors/seed_color_scheme.dart';
import '../foundations/typography/seed_typography.dart';
import '../foundations/elevation/seed_shadow.dart';
import '../foundations/radius/seed_radius.dart';

/// Complete configuration of SEED Design System theme.
class SeedThemeData {
  final Brightness brightness;
  final SeedColorScheme colorScheme;
  final SeedTypography typography;
  final SeedShadows shadows;

  const SeedThemeData({
    required this.brightness,
    required this.colorScheme,
    required this.typography,
    required this.shadows,
  });

  factory SeedThemeData.light({String? fontFamily}) {
    const colorScheme = SeedColorScheme.light();
    return SeedThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      typography: SeedTypography.base(
        fontFamily: fontFamily,
        defaultColor: colorScheme.fg.neutral,
      ),
      shadows: const SeedShadows.light(),
    );
  }

  factory SeedThemeData.dark({String? fontFamily}) {
    const colorScheme = SeedColorScheme.dark();
    return SeedThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      typography: SeedTypography.base(
        fontFamily: fontFamily,
        defaultColor: colorScheme.fg.neutral,
      ),
      shadows: const SeedShadows.dark(),
    );
  }

  bool get isDark => brightness == Brightness.dark;

  SeedThemeData copyWith({
    Brightness? brightness,
    SeedColorScheme? colorScheme,
    SeedTypography? typography,
    SeedShadows? shadows,
  }) {
    return SeedThemeData(
      brightness: brightness ?? this.brightness,
      colorScheme: colorScheme ?? this.colorScheme,
      typography: typography ?? this.typography,
      shadows: shadows ?? this.shadows,
    );
  }

  /// Generates a comprehensive Material 3 [ColorScheme] mapped to SEED Design color tokens.
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: colorScheme.fg.brand,
      onPrimary: colorScheme.fg.onBrandSolid,
      primaryContainer: colorScheme.bg.brandWeak,
      onPrimaryContainer: colorScheme.fg.brandContrast,
      secondary: colorScheme.bg.neutralSolid,
      onSecondary: colorScheme.fg.onNeutralSolid,
      secondaryContainer: colorScheme.bg.neutralWeak,
      onSecondaryContainer: colorScheme.fg.neutral,
      tertiary: colorScheme.fg.informative,
      onTertiary: colorScheme.fg.onInformativeSolid,
      tertiaryContainer: colorScheme.bg.informativeWeak,
      onTertiaryContainer: colorScheme.fg.informativeContrast,
      error: colorScheme.fg.critical,
      onError: colorScheme.fg.onCriticalSolid,
      errorContainer: colorScheme.bg.criticalWeak,
      onErrorContainer: colorScheme.fg.criticalContrast,
      surface: colorScheme.bg.layerDefault,
      onSurface: colorScheme.fg.neutral,
      onSurfaceVariant: colorScheme.fg.neutralMuted,
      surfaceContainerLowest: colorScheme.bg.layerBasement,
      surfaceContainerLow: colorScheme.bg.layerBasement,
      surfaceContainer: colorScheme.bg.layerDefault,
      surfaceContainerHigh: colorScheme.bg.layerFloating,
      surfaceContainerHighest: colorScheme.bg.neutralWeak,
      outline: colorScheme.stroke.neutralWeak,
      outlineVariant: colorScheme.stroke.neutralWeak.withValues(alpha: 0.5),
      shadow: Colors.black26,
      scrim: const Color(0x74000000),
      inverseSurface: colorScheme.bg.neutralInverted,
      onInverseSurface: colorScheme.fg.neutralInverted,
      inversePrimary: colorScheme.fg.brandContrast,
      surfaceTint: Colors.transparent,
    );
  }

  /// Converts this [SeedThemeData] into standard Flutter [ThemeData].
  ///
  /// Completely maps Material 3 color schemes, typography, and component themes
  /// (AppBar, Buttons, Inputs, Dialogs, BottomSheet, Switch, Checkbox, etc.)
  /// so that existing Material 3 apps immediately adopt SEED Design appearance.
  ThemeData toThemeData() {
    final m3ColorScheme = toColorScheme();
    final m3TextTheme = typography.toTextTheme(
      defaultColor: colorScheme.fg.neutral,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: m3ColorScheme,
      textTheme: m3TextTheme,
      scaffoldBackgroundColor: colorScheme.bg.layerBasement,
      canvasColor: colorScheme.bg.layerDefault,
      cardColor: colorScheme.bg.layerDefault,
      dividerColor: colorScheme.stroke.neutralWeak,
      extensions: [colorScheme, typography, shadows],

      // 1. AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.bg.layerDefault,
        foregroundColor: colorScheme.fg.neutral,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: typography.t6Bold.copyWith(
          color: colorScheme.fg.neutral,
        ),
        iconTheme: IconThemeData(color: colorScheme.fg.neutral, size: 24.0),
        actionsIconTheme: IconThemeData(
          color: colorScheme.fg.neutral,
          size: 24.0,
        ),
      ),

      // 2. Button Themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.bg.brandSolid,
          foregroundColor: colorScheme.fg.onBrandSolid,
          elevation: 0.0,
          shape: const RoundedRectangleBorder(
            borderRadius: SeedBorderRadius.r3,
          ),
          textStyle: typography.t4Bold,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.bg.neutralSolid,
          foregroundColor: colorScheme.fg.onNeutralSolid,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: SeedBorderRadius.r3,
          ),
          textStyle: typography.t4Bold,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.fg.neutral,
          side: BorderSide(color: colorScheme.stroke.neutralWeak, width: 1.0),
          elevation: 0.0,
          shape: const RoundedRectangleBorder(
            borderRadius: SeedBorderRadius.r3,
          ),
          textStyle: typography.t4Bold,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.fg.neutral,
          shape: const RoundedRectangleBorder(
            borderRadius: SeedBorderRadius.r3,
          ),
          textStyle: typography.t4Bold,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.bg.brandSolid,
        foregroundColor: colorScheme.fg.onBrandSolid,
        elevation: 4.0,
        shape: const CircleBorder(),
      ),

      // 3. Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.bg.layerDefault,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        hintStyle: typography.t4Regular.copyWith(
          color: colorScheme.fg.placeholder,
        ),
        labelStyle: typography.t4Regular.copyWith(
          color: colorScheme.fg.neutralSubtle,
        ),
        helperStyle: typography.t2Regular.copyWith(
          color: colorScheme.fg.neutralSubtle,
        ),
        errorStyle: typography.t2Regular.copyWith(
          color: colorScheme.fg.critical,
        ),
        border: const OutlineInputBorder(
          borderRadius: SeedBorderRadius.r3,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SeedBorderRadius.r3,
          borderSide: BorderSide(
            color: colorScheme.stroke.neutralWeak,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SeedBorderRadius.r3,
          borderSide: BorderSide(color: colorScheme.fg.neutral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: SeedBorderRadius.r3,
          borderSide: BorderSide(color: colorScheme.fg.critical, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: SeedBorderRadius.r3,
          borderSide: BorderSide(color: colorScheme.fg.critical, width: 1.5),
        ),
      ),

      // 4. Selection Themes
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.bg.disabled;
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.bg.neutralSolid;
          }
          return colorScheme.bg.neutralWeak;
        }),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.bg.disabled;
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.bg.neutralSolid;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(colorScheme.fg.onNeutralSolid),
        side: BorderSide(color: colorScheme.stroke.neutralWeak, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: SeedBorderRadius.r1),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.bg.disabled;
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.bg.neutralSolid;
          }
          return colorScheme.stroke.neutralWeak;
        }),
      ),

      // 5. Overlay Themes
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.bg.layerFloating,
        surfaceTintColor: Colors.transparent,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(borderRadius: SeedBorderRadius.r4),
        titleTextStyle: typography.t6Bold.copyWith(
          color: colorScheme.fg.neutral,
        ),
        contentTextStyle: typography.t4Regular.copyWith(
          color: colorScheme.fg.neutralMuted,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.bg.layerFloating,
        surfaceTintColor: Colors.transparent,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SeedRadius.r5),
            topRight: Radius.circular(SeedRadius.r5),
          ),
        ),
        dragHandleColor: colorScheme.stroke.neutralWeak,
        showDragHandle: true,
      ),

      // 6. Navigation Themes
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.bg.layerDefault,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.bg.neutralWeak,
        elevation: 0.0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.bg.layerDefault,
        selectedItemColor: colorScheme.fg.neutral,
        unselectedItemColor: colorScheme.fg.neutralSubtle,
        elevation: 0.0,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: colorScheme.fg.neutral,
        labelColor: colorScheme.fg.neutral,
        unselectedLabelColor: colorScheme.fg.neutralSubtle,
        labelStyle: typography.t4Bold,
        unselectedLabelStyle: typography.t4Regular,
        dividerColor: colorScheme.stroke.neutralWeak,
      ),

      // 7. Structural Themes
      cardTheme: CardThemeData(
        color: colorScheme.bg.layerDefault,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: SeedBorderRadius.r3,
          side: BorderSide(color: colorScheme.stroke.neutralWeak, width: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.stroke.neutralWeak,
        thickness: 1.0,
        space: 1.0,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        titleTextStyle: typography.t4Bold.copyWith(
          color: colorScheme.fg.neutral,
        ),
        subtitleTextStyle: typography.t3Regular.copyWith(
          color: colorScheme.fg.neutralMuted,
        ),
        leadingAndTrailingTextStyle: typography.t3Regular.copyWith(
          color: colorScheme.fg.neutralSubtle,
        ),
        iconColor: colorScheme.fg.neutral,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.bg.neutralWeak,
        selectedColor: colorScheme.bg.brandWeak,
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: typography.t3Bold.copyWith(color: colorScheme.fg.neutral),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.bg.neutralInverted,
        actionTextColor: colorScheme.fg.brand,
        behavior: SnackBarBehavior.floating,
        elevation: 4.0,
        shape: const RoundedRectangleBorder(borderRadius: SeedBorderRadius.r3),
        contentTextStyle: typography.t3Regular.copyWith(
          color: colorScheme.fg.neutralInverted,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.fg.brand,
        circularTrackColor: colorScheme.stroke.neutralWeak,
        linearTrackColor: colorScheme.stroke.neutralWeak,
      ),
    );
  }
}

/// Convenience extensions on [ThemeData] for seamlessly adopting SEED Design.
extension SeedMaterialThemeExtension on ThemeData {
  /// Enriches an existing [ThemeData] with SEED Design System tokens and component themes.
  ///
  /// Preserves custom app configurations while seamlessly applying SEED design tokens
  /// and Material 3 theme overrides.
  ThemeData withSeedDesign({
    SeedThemeData? seedTheme,
    Brightness? brightness,
    String? fontFamily,
  }) {
    final effectiveBrightness = brightness ?? this.brightness;
    final inheritedFont = textTheme.bodyMedium;
    final resolvedFont = fontFamily ?? inheritedFont?.fontFamily;
    var effectiveSeedTheme =
        seedTheme ??
        (effectiveBrightness == Brightness.dark
            ? SeedThemeData.dark(fontFamily: resolvedFont)
            : SeedThemeData.light(fontFamily: resolvedFont));
    if (seedTheme == null) {
      effectiveSeedTheme = effectiveSeedTheme.copyWith(
        typography: effectiveSeedTheme.typography.mapStyles(
          (style) => style.copyWith(
            fontFamilyFallback: inheritedFont?.fontFamilyFallback,
          ),
        ),
      );
    }

    final seedThemeData = effectiveSeedTheme.toThemeData();

    TextStyle? preserveFont(TextStyle? seedStyle, TextStyle? original) {
      if (seedTheme != null || fontFamily != null) return seedStyle;
      return seedStyle?.copyWith(
        fontFamily: original?.fontFamily,
        fontFamilyFallback: original?.fontFamilyFallback,
      );
    }

    final migratedText = seedThemeData.textTheme;
    return copyWith(
      // ThemeData.copyWith is required to retain app-specific configuration.
      // ignore: deprecated_member_use
      useMaterial3: true,
      colorScheme: seedThemeData.colorScheme,
      textTheme: migratedText.copyWith(
        displayLarge: preserveFont(
          migratedText.displayLarge,
          textTheme.displayLarge,
        ),
        displayMedium: preserveFont(
          migratedText.displayMedium,
          textTheme.displayMedium,
        ),
        displaySmall: preserveFont(
          migratedText.displaySmall,
          textTheme.displaySmall,
        ),
        headlineLarge: preserveFont(
          migratedText.headlineLarge,
          textTheme.headlineLarge,
        ),
        headlineMedium: preserveFont(
          migratedText.headlineMedium,
          textTheme.headlineMedium,
        ),
        headlineSmall: preserveFont(
          migratedText.headlineSmall,
          textTheme.headlineSmall,
        ),
        titleLarge: preserveFont(migratedText.titleLarge, textTheme.titleLarge),
        titleMedium: preserveFont(
          migratedText.titleMedium,
          textTheme.titleMedium,
        ),
        titleSmall: preserveFont(migratedText.titleSmall, textTheme.titleSmall),
        bodyLarge: preserveFont(migratedText.bodyLarge, textTheme.bodyLarge),
        bodyMedium: preserveFont(migratedText.bodyMedium, textTheme.bodyMedium),
        bodySmall: preserveFont(migratedText.bodySmall, textTheme.bodySmall),
        labelLarge: preserveFont(migratedText.labelLarge, textTheme.labelLarge),
        labelMedium: preserveFont(
          migratedText.labelMedium,
          textTheme.labelMedium,
        ),
        labelSmall: preserveFont(migratedText.labelSmall, textTheme.labelSmall),
      ),
      scaffoldBackgroundColor: seedThemeData.scaffoldBackgroundColor,
      canvasColor: seedThemeData.canvasColor,
      cardColor: seedThemeData.cardColor,
      dividerColor: seedThemeData.dividerColor,
      extensions: [
        ...extensions.values.where(
          (e) =>
              e is! SeedColorScheme &&
              e is! SeedTypography &&
              e is! SeedShadows,
        ),
        effectiveSeedTheme.colorScheme,
        effectiveSeedTheme.typography,
        effectiveSeedTheme.shadows,
      ],
      appBarTheme: seedThemeData.appBarTheme,
      filledButtonTheme: seedThemeData.filledButtonTheme,
      elevatedButtonTheme: seedThemeData.elevatedButtonTheme,
      outlinedButtonTheme: seedThemeData.outlinedButtonTheme,
      textButtonTheme: seedThemeData.textButtonTheme,
      floatingActionButtonTheme: seedThemeData.floatingActionButtonTheme,
      inputDecorationTheme: seedThemeData.inputDecorationTheme,
      switchTheme: seedThemeData.switchTheme,
      checkboxTheme: seedThemeData.checkboxTheme,
      radioTheme: seedThemeData.radioTheme,
      dialogTheme: seedThemeData.dialogTheme,
      bottomSheetTheme: seedThemeData.bottomSheetTheme,
      navigationBarTheme: seedThemeData.navigationBarTheme,
      bottomNavigationBarTheme: seedThemeData.bottomNavigationBarTheme,
      tabBarTheme: seedThemeData.tabBarTheme,
      cardTheme: seedThemeData.cardTheme,
      dividerTheme: seedThemeData.dividerTheme,
      listTileTheme: seedThemeData.listTileTheme,
      chipTheme: seedThemeData.chipTheme,
      snackBarTheme: seedThemeData.snackBarTheme,
      progressIndicatorTheme: seedThemeData.progressIndicatorTheme,
    );
  }
}
