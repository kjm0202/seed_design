import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: theme ?? SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostInteraction(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('partial color theme also supplies fallback text foreground', (
    tester,
  ) async {
    final colors = const SeedColorScheme.light().copyWith(
      fg: const SeedColorScheme.dark().fg,
    );
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Text(
            'Custom foreground',
            style: context.seedTypography.t5Regular,
          ),
        ),
        theme: ThemeData(extensions: [colors]),
      ),
    );
    expect(
      tester.widget<Text>(find.text('Custom foreground')).style?.color,
      colors.fg.neutral,
    );
  });

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
  group('theme boundaries', () {
    testWidgets('MaterialApp dark theme overrides an outer legacy SeedTheme', (
      tester,
    ) async {
      await tester.pumpWidget(
        SeedTheme(
          data: SeedThemeData.light(),
          child: MaterialApp(
            locale: const Locale('ko'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: SeedThemeData.light().toThemeData(),
            darkTheme: SeedThemeData.dark().toThemeData(),
            themeMode: ThemeMode.dark,
            home: Builder(
              builder: (context) {
                expect(Theme.of(context).brightness, Brightness.dark);
                expect(context.seedIsDark, isTrue);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('subtree override synchronizes Material and modal themes', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          SeedTheme(
            data: SeedThemeData.dark(),
            child: Builder(
              builder: (context) {
                expect(context.seedIsDark, isTrue);
                expect(Theme.of(context).brightness, Brightness.dark);
                return TextButton(
                  onPressed: () => showSeedDialog<void>(
                    context: context,
                    child: Builder(
                      builder: (context) {
                        expect(context.seedIsDark, isTrue);
                        expect(Theme.of(context).brightness, Brightness.dark);
                        return const Center(child: Text('themed dialog'));
                      },
                    ),
                  ),
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('themed dialog'), findsOneWidget);
    });

    test('migration preserves fonts, fallbacks and unrelated extensions', () {
      final original = ThemeData(
        fontFamily: 'CustomFont',
        fontFamilyFallback: const ['Fallback'],
        extensions: const [_AppMarker()],
      );
      final result = original.withSeedDesign();
      expect(result.textTheme.bodyMedium!.fontFamily, 'CustomFont');
      expect(result.extension<_AppMarker>(), isNotNull);
      expect(
        result.textTheme.bodyMedium!.fontFamilyFallback,
        contains('Fallback'),
      );
      expect(
        result.extension<SeedTypography>()!.t4Regular.fontFamily,
        'CustomFont',
      );
      final explicit = original.withSeedDesign(fontFamily: 'ExplicitFont');
      expect(explicit.textTheme.bodyMedium!.fontFamily, 'ExplicitFont');
      expect(
        explicit.extension<SeedTypography>()!.t4Regular.fontFamily,
        'ExplicitFont',
      );
    });
  });

  group('local theme in overlays', () {
    testWidgets('dialog and sheets retain a local theme and custom font', (
      tester,
    ) async {
      for (final kind in ['dialog', 'sheet', 'menu', 'panel']) {
        await tester.pumpWidget(
          hostInteraction(
            SeedTheme(
              data: SeedThemeData.dark(fontFamily: 'LocalFont'),
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    final content = Builder(
                      builder: (context) {
                        expect(context.seedIsDark, isTrue);
                        expect(
                          context.seedTypography.t4Regular.fontFamily,
                          'LocalFont',
                        );
                        return const Text('Local content');
                      },
                    );
                    switch (kind) {
                      case 'dialog':
                        showSeedDialog<void>(
                          context: context,
                          child: SeedDialog(title: 'Title', content: content),
                        );
                      case 'sheet':
                        showSeedBottomSheet<void>(
                          context: context,
                          child: SeedBottomSheet(content: content),
                        );
                      case 'menu':
                        showSeedMenuSheet<void>(
                          context: context,
                          groups: [
                            SeedMenuGroupData(
                              items: [
                                SeedMenuItemData(
                                  label: 'Menu',
                                  prefixIcon: content,
                                ),
                              ],
                            ),
                          ],
                        );
                      case 'panel':
                        showSeedSidePanel<void>(
                          context: context,
                          title: 'Panel',
                          body: content,
                        );
                    }
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Local content'), findsOneWidget);
        // Remove the whole navigator between cases.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
    });
  });
}

class _AppMarker extends ThemeExtension<_AppMarker> {
  const _AppMarker();
  @override
  _AppMarker copyWith() => this;
  @override
  _AppMarker lerp(covariant _AppMarker? other, double t) => this;
}
