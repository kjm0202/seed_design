import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  group('SeedThemeData Material 3 Migration Tests', () {
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
      expect(theme.appBarTheme.backgroundColor, seedLight.colorScheme.bg.layerDefault);

      // Button Themes
      expect(theme.filledButtonTheme.style, isNotNull);
      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.outlinedButtonTheme.style, isNotNull);
      expect(theme.textButtonTheme.style, isNotNull);
      expect(theme.floatingActionButtonTheme.backgroundColor, seedLight.colorScheme.bg.brandSolid);

      // Input Theme
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.fillColor, seedLight.colorScheme.bg.layerDefault);

      // Selection Themes
      expect(theme.switchTheme.thumbColor, isNotNull);
      expect(theme.checkboxTheme.side?.color, seedLight.colorScheme.stroke.neutralWeak);
      expect(theme.radioTheme.fillColor, isNotNull);

      // Dialog & BottomSheet Themes
      expect(theme.dialogTheme.backgroundColor, seedLight.colorScheme.bg.layerFloating);
      expect(theme.dialogTheme.surfaceTintColor, Colors.transparent);
      expect(theme.bottomSheetTheme.backgroundColor, seedLight.colorScheme.bg.layerFloating);
      expect(theme.bottomSheetTheme.showDragHandle, isTrue);

      // Extensions
      expect(theme.extension<SeedColorScheme>(), isNotNull);
      expect(theme.extension<SeedTypography>(), isNotNull);
      expect(theme.extension<SeedShadows>(), isNotNull);
    });

    test('withSeedDesign() enriches existing ThemeData', () {
      final existingTheme = ThemeData(
        fontFamily: 'CustomFont',
        useMaterial3: true,
      );

      final enriched = existingTheme.withSeedDesign(brightness: Brightness.light);

      expect(enriched.colorScheme.primary, const SeedColorScheme.light().fg.brand);
      expect(enriched.appBarTheme.elevation, 0.0);
      expect(enriched.extension<SeedColorScheme>(), isNotNull);
      expect(enriched.extension<SeedTypography>(), isNotNull);
      expect(enriched.extension<SeedShadows>(), isNotNull);
    });
  });

  group('Material 3 Widgets Rendering with SEED Theme', () {
    testWidgets('Standard Material 3 widgets render gracefully under SEED Theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('M3 AppBar with SEED Theme'),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Standard M3 Buttons
                  FilledButton(onPressed: () {}, child: const Text('Filled Button')),
                  ElevatedButton(onPressed: () {}, child: const Text('Elevated Button')),
                  OutlinedButton(onPressed: () {}, child: const Text('Outlined Button')),
                  TextButton(onPressed: () {}, child: const Text('Text Button')),

                  // Standard M3 Input
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'M3 TextField hint',
                      labelText: 'M3 Label',
                    ),
                  ),

                  // Standard M3 Controls
                  Switch(value: true, onChanged: (_) {}),
                  Checkbox(value: true, onChanged: (_) {}),
                  // ignore: deprecated_member_use
                  Radio<int>(value: 1, groupValue: 1, onChanged: (_) {}),

                  // Standard M3 Card & Divider
                  const Card(child: Padding(padding: EdgeInsets.all(8), child: Text('Card'))),
                  const Divider(),

                  // Standard Progress
                  const CircularProgressIndicator(value: 0.5),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('M3 AppBar with SEED Theme'), findsOneWidget);
      expect(find.text('Filled Button'), findsOneWidget);
      expect(find.text('Elevated Button'), findsOneWidget);
      expect(find.text('Outlined Button'), findsOneWidget);
      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(Radio<int>), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('SeedMaterialBridge wraps legacy subtrees', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SeedMaterialBridge(
            child: Builder(
              builder: (context) {
                final colors = context.seedColor;
                final typography = context.seedTypography;
                return Scaffold(
                  body: Text(
                    'Bridged Screen',
                    style: typography.t5Bold.copyWith(color: colors.fg.brand),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Bridged Screen'), findsOneWidget);
    });

    test('SeedMigration catalog verification', () {
      expect(SeedMigration.componentMapping['ElevatedButton'], isNotNull);
      expect(SeedMigration.componentMapping['AppBar'], isNotNull);
      expect(SeedMigration.componentMapping['TextField / TextFormField'], isNotNull);
      expect(SeedMigration.typographyMapping['bodyMedium'], isNotNull);
      expect(SeedMigration.typographyMapping['titleMedium'], isNotNull);
    });
  });
}
