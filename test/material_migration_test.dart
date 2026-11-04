import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  home: SeedMaterialBridge(
    child: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  ),
);

Widget hostMaterialMigrationContrac(
  Widget child, {
  Locale locale = const Locale('en'),
}) => MaterialApp(
  restorationScopeId: 'app',
  locale: locale,
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: ThemeData().withSeedDesign(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

class RouteLog extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      pushed.add(route);
}

void main() {
  test(
    'explicit font overrides a supplied SEED theme without losing fallbacks',
    () {
      final base = SeedThemeData.dark(fontFamily: 'SeedFont');
      final seed = base.copyWith(
        typography: base.typography.mapStyles(
          (style) => style.copyWith(fontFamilyFallback: const ['SeedFallback']),
        ),
      );
      final original = ThemeData(
        fontFamily: 'HostFont',
        visualDensity: VisualDensity.compact,
      );
      final theme = original.withSeedDesign(
        seedTheme: seed,
        fontFamily: 'ExplicitFont',
      );
      expect(theme.textTheme.bodyMedium!.fontFamily, 'ExplicitFont');
      expect(theme.textTheme.displayLarge!.fontFamily, 'ExplicitFont');
      expect(
        theme.extension<SeedTypography>()!.t4Regular.fontFamily,
        'ExplicitFont',
      );
      expect(
        theme.extension<SeedTypography>()!.t13Bold.fontFamily,
        'ExplicitFont',
      );
      expect(theme.appBarTheme.titleTextStyle!.fontFamily, 'ExplicitFont');
      expect(
        theme.filledButtonTheme.style!.textStyle!.resolve({})!.fontFamily,
        'ExplicitFont',
      );
      expect(
        theme.textTheme.bodyMedium!.fontFamilyFallback,
        contains('SeedFallback'),
      );
      expect(
        theme.extension<SeedTypography>()!.t4Regular.fontFamilyFallback,
        contains('SeedFallback'),
      );
      expect(theme.visualDensity, VisualDensity.compact);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, seed.colorScheme.fg.brand);
      expect(seed.typography.t4Regular.fontFamily, 'SeedFont');
      expect(original.textTheme.bodyMedium!.fontFamily, 'HostFont');
    },
  );

  test(
    'supplied SEED theme retains its font and brightness without font override',
    () {
      final seed = SeedThemeData.dark(fontFamily: 'SeedFont');
      final theme = ThemeData(fontFamily: 'HostFont')
          .withSeedDesign(seedTheme: seed, brightness: Brightness.light);
      expect(theme.brightness, Brightness.dark);
      expect(theme.textTheme.bodyMedium!.fontFamily, 'SeedFont');
      expect(
        theme.extension<SeedTypography>()!.t4Regular.fontFamily,
        'SeedFont',
      );
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets('incremental controls share brand colors in $brightness mode', (
      tester,
    ) async {
      late ThemeData theme;
      late SeedThemeData seed;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: SeedMaterialBridge(
            child: Builder(
              builder: (context) {
                theme = Theme.of(context);
                seed = context.seedTheme;
                return Scaffold(
                  body: Wrap(
                    children: [
                      Checkbox(value: true, onChanged: (_) {}),
                      const SeedCheckmark(
                        key: ValueKey('seed-check'),
                        value: true,
                      ),
                      Switch(value: true, onChanged: (_) {}),
                      SeedSwitchMark(
                        key: const ValueKey('seed-switch'),
                        checked: true,
                        onCheckedChange: (_) {},
                      ),
                      RadioGroup<String>(
                        groupValue: 'selected',
                        onChanged: (_) {},
                        child: const Radio<String>(value: 'selected'),
                      ),
                      SeedRadio<String>(
                        key: const ValueKey('seed-radio'),
                        value: 'selected',
                        groupValue: 'selected',
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      final selected = {WidgetState.selected};
      final disabled = {WidgetState.selected, WidgetState.disabled};
      final checkbox = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('seed-check')),
              matching: find.byType(Container),
            )
            .first,
      );
      final switchTrack = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byKey(const ValueKey('seed-switch')),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final radio = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('seed-radio')),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        theme.checkboxTheme.fillColor!.resolve(selected),
        (checkbox.decoration! as BoxDecoration).color,
      );
      expect(
        theme.switchTheme.trackColor!.resolve(selected),
        (switchTrack.decoration! as BoxDecoration).color,
      );
      expect(
        theme.radioTheme.fillColor!.resolve(selected),
        (radio.decoration! as BoxDecoration).color,
      );
      expect(
        theme.checkboxTheme.checkColor!.resolve(selected),
        seed.colorScheme.fg.onBrandSolid,
      );
      expect(
        theme.switchTheme.thumbColor!.resolve(selected),
        seed.colorScheme.fg.onBrandSolid,
      );
      expect(
        theme.checkboxTheme.fillColor!.resolve(disabled),
        seed.colorScheme.bg.disabled,
      );
      expect(
        theme.checkboxTheme.checkColor!.resolve(disabled),
        seed.colorScheme.fg.disabled,
      );
      expect(
        theme.switchTheme.trackColor!.resolve(disabled),
        seed.colorScheme.bg.disabled,
      );
      expect(
        theme.radioTheme.fillColor!.resolve(disabled),
        seed.colorScheme.bg.disabled,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'retained linear progress preserves numeric values and announcements',
    (tester) async {
      Widget progress(double value, String announcement) => host(
        LinearProgressIndicator(
          value: value,
          semanticsLabel: 'Download',
          semanticsValue: announcement,
        ),
      );
      await tester.pumpWidget(progress(0.35, '35%'));
      final finder = find.byType(LinearProgressIndicator);
      expect(tester.getSemantics(finder).getSemanticsData().value, '35%');
      expect(tester.getSemantics(finder).getSemanticsData().label, 'Download');
      expect(find.byType(SeedSkeleton), findsNothing);
      await tester.pumpWidget(progress(0.75, '75%'));
      await tester.pumpAndSettle();
      expect(tester.widget<LinearProgressIndicator>(finder).value, 0.75);
      expect(tester.getSemantics(finder).getSemanticsData().value, '75%');
    },
  );
  group('Form, Navigator and theme contracts', () {

    test('theme bridge can preserve Material component overrides while installing SEED tokens', () {
      final original = ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.all(31),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(120, 72)),
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      );
      final migrated = original.withSeedDesign(preserveComponentThemes: true);
      expect(
        migrated.inputDecorationTheme.contentPadding,
        const EdgeInsets.all(31),
      );
      expect(
        migrated.filledButtonTheme.style!.minimumSize!.resolve({}),
        const Size(120, 72),
      );
      expect(migrated.appBarTheme.centerTitle, isFalse);
      expect(migrated.extension<SeedTypography>(), isNotNull);
      expect(
        migrated.colorScheme.primary,
        const SeedColorScheme.light().fg.brand,
      );
    });

    test('preserved button styles win over SEED values they also set', () {
      final migrated = ThemeData(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(30),
            shape: const StadiumBorder(),
            backgroundColor: const Color(0xFF123456),
          ),
        ),
      ).withSeedDesign(preserveComponentThemes: true);
      final seed = ThemeData().withSeedDesign().filledButtonTheme.style!;
      final style = migrated.filledButtonTheme.style!;
      expect(style.padding!.resolve({}), const EdgeInsets.all(30));
      expect(style.shape!.resolve({}), const StadiumBorder());
      expect(style.backgroundColor!.resolve({}), const Color(0xFF123456));
      expect(style.textStyle!.resolve({}), seed.textStyle!.resolve({}));
    });

    test('partial component overrides keep the remaining SEED fields', () {
      final migrated = ThemeData(
        dialogTheme: const DialogThemeData(insetPadding: EdgeInsets.all(8)),
        appBarTheme: const AppBarTheme(centerTitle: false),
        chipTheme: const ChipThemeData(shape: RoundedRectangleBorder()),
      ).withSeedDesign(preserveComponentThemes: true);
      final seed = ThemeData().withSeedDesign();
      expect(migrated.dialogTheme.insetPadding, const EdgeInsets.all(8));
      expect(migrated.dialogTheme.shape, seed.dialogTheme.shape);
      expect(
        migrated.dialogTheme.backgroundColor,
        seed.dialogTheme.backgroundColor,
      );
      expect(migrated.appBarTheme.centerTitle, isFalse);
      expect(
        migrated.appBarTheme.titleTextStyle,
        seed.appBarTheme.titleTextStyle,
      );
      expect(migrated.chipTheme.shape, const RoundedRectangleBorder());
      expect(migrated.chipTheme.labelStyle, seed.chipTheme.labelStyle);
      expect(
        ThemeData().withSeedDesign(preserveComponentThemes: true).cardTheme,
        seed.cardTheme,
      );
    });

    testWidgets('FAB supports explicit Material Hero and tooltip integration', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostMaterialMigrationContrac(
          SeedFloatingActionButton(
            heroTag: 'compose',
            tooltip: 'Compose message',
            semanticsLabel: 'Compose message',
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      );
      final hero = find.descendant(
        of: find.byType(SeedFloatingActionButton),
        matching: find.byType(Hero),
      );
      expect(tester.widget<Hero>(hero).tag, 'compose');
      expect(
        tester.widget<Tooltip>(find.byType(Tooltip)).message,
        'Compose message',
      );
    });
  });
}
