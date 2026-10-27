import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  testWidgets('fallback SEED typography preserves host application font', (
    tester,
  ) async {
    late SeedThemeData fallback;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'HostSans'),
        home: Builder(
          builder: (context) {
            fallback = SeedTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(fallback.typography.body.fontFamily, 'HostSans');
    expect(fallback.typography.body.fontSize, SeedFontSize.t5);
    expect(
      fallback.typography.body.height,
      SeedLineHeight.t5 / SeedFontSize.t5,
    );
  });

  group('SeedThemeData Material 3 integration', () {
    test('toThemeData() produces fully populated Material 3 ThemeData', () {
      final seedLight = SeedThemeData.light();
      final theme = seedLight.toThemeData();

      // M3 flag
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);

      // ColorScheme
      expect(theme.colorScheme.primary, seedLight.colorScheme.fg.brand);
      expect(theme.colorScheme.error, seedLight.colorScheme.fg.critical);
      expect(theme.colorScheme.surface, seedLight.colorScheme.bg.layerDefault);
      expect(theme.colorScheme.onSurface, seedLight.colorScheme.fg.neutral);
      expect(theme.colorScheme.surfaceTint, Colors.transparent);

      // TextTheme
      expect(theme.textTheme.bodyMedium?.fontSize, SeedFontSize.t4);
      expect(theme.textTheme.titleMedium?.fontSize, SeedFontSize.t6);
      expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w700);

      // AppBar Theme
      expect(theme.appBarTheme.elevation, 0.0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0.0);
      expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
      expect(
        theme.appBarTheme.backgroundColor,
        seedLight.colorScheme.bg.layerDefault,
      );

      // Button Themes
      expect(theme.filledButtonTheme.style, isNotNull);
      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.outlinedButtonTheme.style, isNotNull);
      expect(theme.textButtonTheme.style, isNotNull);
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        seedLight.colorScheme.bg.brandSolid,
      );

      // Input Theme
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(
        theme.inputDecorationTheme.fillColor,
        seedLight.colorScheme.bg.layerDefault,
      );

      // Selection Themes
      expect(theme.switchTheme.thumbColor, isNotNull);
      expect(
        theme.checkboxTheme.side?.color,
        seedLight.colorScheme.stroke.neutralWeak,
      );
      expect(theme.radioTheme.fillColor, isNotNull);

      // Dialog & BottomSheet Themes
      expect(
        theme.dialogTheme.backgroundColor,
        seedLight.colorScheme.bg.layerFloating,
      );
      expect(theme.dialogTheme.surfaceTintColor, Colors.transparent);
      expect(
        theme.bottomSheetTheme.backgroundColor,
        seedLight.colorScheme.bg.layerFloating,
      );
      expect(theme.bottomSheetTheme.showDragHandle, isTrue);

      // Extensions
      expect(theme.extension<SeedColorScheme>(), isNotNull);
      expect(theme.extension<SeedTypography>(), isNotNull);
      expect(theme.extension<SeedShadows>(), isNotNull);
    });
  });
}
