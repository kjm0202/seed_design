import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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

  test('replacement catalog distinguishes form fields, tooltips and linear progress', () {
    expect(SeedMigration.componentMapping['TextField'], 'SeedTextInput');
    expect(SeedMigration.componentMapping['TextFormField'], 'SeedTextField');
    expect(
      SeedMigration.componentMapping['TextField / TextFormField'],
      'SeedTextInput / SeedTextField',
    );
    expect(SeedMigration.componentMapping['Tooltip'], 'SeedHelpBubbleTooltip');
    expect(
      SeedMigration.componentMapping['LinearProgressIndicator'],
      'LinearProgressIndicator (withSeedDesign theme)',
    );
  });

  testWidgets(
    'TextFormField replacement preserves validation, save and reset',
    (tester) async {
      final form = GlobalKey<FormState>();
      String? saved;
      await tester.pumpWidget(
        host(
          Form(
            key: form,
            child: SeedTextField(
              defaultValue: 'initial',
              validator: (value) =>
                  value?.startsWith('ok') == true ? null : 'Enter ok',
              onSaved: (value) => saved = value,
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter ok'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ok saved');
      expect(form.currentState!.validate(), isTrue);
      await tester.pump();
      form.currentState!.save();
      expect(saved, 'ok saved');
      form.currentState!.reset();
      await tester.pump();
      expect(find.text('initial'), findsOneWidget);
    },
  );

  testWidgets(
    'Tooltip replacement opens after hover delay and on keyboard focus',
    (tester) async {
      await tester.pumpWidget(
        host(
          SeedHelpBubbleTooltip(
            title: 'Migration tip',
            openDelay: const Duration(milliseconds: 100),
            closeDelay: const Duration(milliseconds: 50),
            child: TextButton(onPressed: () {}, child: const Text('Target')),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Target')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Migration tip'), findsNothing);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Migration tip'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Migration tip'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Migration tip'), findsOneWidget);
      await mouse.removePointer();
      await tester.pumpWidget(const SizedBox());
    },
  );

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

  testWidgets(
    'bridge preserves host configuration and captures its theme in dialogs',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'HostFont',
            visualDensity: VisualDensity.compact,
          ),
          home: SeedMaterialBridge(
            brightness: Brightness.dark,
            child: Builder(
              builder: (context) {
                expect(Theme.of(context).visualDensity, VisualDensity.compact);
                expect(Theme.of(context).brightness, Brightness.dark);
                expect(context.seedIsDark, isTrue);
                expect(context.seedTypography.t4Regular.fontFamily, 'HostFont');
                return Scaffold(
                  body: TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) {
                        expect(context.seedIsDark, isTrue);
                        expect(Theme.of(context).brightness, Brightness.dark);
                        return const AlertDialog(title: Text('Captured theme'));
                      },
                    ),
                    child: const Text('Open'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Captured theme'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
