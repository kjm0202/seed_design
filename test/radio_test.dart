// An isolated PACKAGE control comparison, independent of the Stackflow
// list-item-radio example (which composes a row and inner radio differently).
// React reference: doc/react_package/packages/react-headless/radio-group/
// src/useRadioGroup.ts (focus/key handling) and RadioGroup.tsx.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostFghFollowupRegression(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

Widget hostComponentAccessibilityOv(
  Widget child, {
  double scale = 1,
  bool dark = false,
}) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme:
      (dark
              ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
              : SeedThemeData.light(fontFamily: seedTestFontFamily))
          .toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

Widget hostLayoutParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('radio group: keyboard arrow changes selected item', (
    tester,
  ) async {
    final first = FocusNode(debugLabel: 'first');
    final second = FocusNode(debugLabel: 'second');
    final third = FocusNode(debugLabel: 'third');
    final events = <String?>[];
    addTearDown(() {
      first.dispose();
      second.dispose();
      third.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: SeedRadioGroup<String>(
            defaultValue: 'a',
            onValueChange: events.add,
            child: Column(
              children: [
                SeedRadio(value: 'a', label: 'First', focusNode: first),
                SeedRadio(value: 'b', label: 'Second', focusNode: second),
                SeedRadio(value: 'c', label: 'Third', focusNode: third),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    first.requestFocus();
    await tester.pump();
    expect(first.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    // State changes, rather than dispatch success or an image, are asserted.
    expect(events, contains('b'));
    expect(second.hasFocus, isTrue);
    // ignore: avoid_print
    print('RADIO_GROUP_SEMANTIC,first=selected-a,ArrowDown=selected-b,focus=b');
  });

  testWidgets('radio group: disabled item is not keyboard-selected', (
    tester,
  ) async {
    final first = FocusNode(debugLabel: 'first');
    final disabled = FocusNode(debugLabel: 'disabled');
    final third = FocusNode(debugLabel: 'third');
    final events = <String?>[];
    addTearDown(() {
      first.dispose();
      disabled.dispose();
      third.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: SeedRadioGroup<String>(
            defaultValue: 'a',
            onValueChange: events.add,
            child: Column(
              children: [
                SeedRadio(value: 'a', label: 'First', focusNode: first),
                SeedRadio(
                  value: 'b',
                  label: 'Disabled',
                  focusNode: disabled,
                  enabled: false,
                ),
                SeedRadio(value: 'c', label: 'Third', focusNode: third),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    first.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(events, isNot(contains('b')));
    expect(disabled.hasFocus, isFalse);
    // ignore: avoid_print
    print('RADIO_GROUP_SEMANTIC,disabled-b-skipped,events=$events');
  });
  group('native radio group', () {
    testWidgets(
      'native radio group handles arrows and ignores disabled radios',
      (tester) async {
        int? selected = 0;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) => SeedRadioGroup<int>(
                groupValue: selected,
                onChanged: (value) => setState(() => selected = value),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SeedRadio<int>(value: 0, label: 'First'),
                    SeedRadio<int>(value: 1, label: 'Disabled', enabled: false),
                    SeedRadio<int>(value: 2, label: 'Last'),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(selected, 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(selected, 0);
      },
    );
  });

  group('card radio group', () {
    testWidgets(
      'radio group skips disabled wrapped cards and has one Tab entry',
      (tester) async {
        final changes = <Object?>[];
        await tester.pumpWidget(
          hostFghFollowupRegression(
            SeedSelectBoxGroup(
              defaultValue: 'a',
              onValueChanged: changes.add,
              children: const [
                Padding(
                  padding: EdgeInsets.all(4),
                  child: SeedSelectBox(title: 'First', value: 'a'),
                ),
                SeedSelectBox(title: 'Disabled', value: 'b', enabled: false),
                SeedSelectBox(title: 'Last', value: 'c'),
              ],
            ),
          ),
        );
        final nodes = tester
            .widgetList<FocusableActionDetector>(
              find.byType(FocusableActionDetector),
            )
            .map((detector) => detector.focusNode!)
            .toList();
        expect(nodes.map((node) => node.skipTraversal), [false, true, true]);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(nodes.first.hasPrimaryFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(nodes.last.hasPrimaryFocus, isTrue);
        expect(changes, ['c']);
        expect(nodes.map((node) => node.skipTraversal), [true, true, false]);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(changes, ['c', 'a']);
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(changes, ['c', 'a', 'c']);
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expect(changes, ['c', 'a', 'c', 'a']);
      },
    );
  });

  group('radio row', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('radio row receives its parent radio press feedback', (
      tester,
    ) async {
      int? selected;
      await tester.pumpWidget(
        hostComponentAccessibilityOv(
          SeedRadioListItem<int>(
            title: 'Radio',
            value: 1,
            onChanged: (value) => selected = value,
            showDivider: false,
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Radio')),
      );
      await tester.pump(const Duration(milliseconds: 200));
      final row = find.descendant(
        of: find.byType(SeedListItem),
        matching: find.byType(AnimatedContainer),
      );
      expect(
        // The row's pressed surface; the radio mark is now inside the row.
        tester.widget<AnimatedContainer>(row.first).margin,
        const EdgeInsets.symmetric(horizontal: 6),
      );
      final scale = find.descendant(
        of: find.byType(SeedContentScale),
        matching: find.byType(AnimatedScale),
      );
      expect(tester.widget<AnimatedScale>(scale.first).scale, lessThan(1));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('chip radio and defaults', () {
    testWidgets('chip radio group skips disabled options with keyboard', (
      tester,
    ) async {
      final changes = <int>[];
      await tester.pumpWidget(
        hostLayoutParity(
          SeedChipRadioGroup<int>(
            defaultValue: 1,
            onChanged: changes.add,
            options: const [
              SeedChipOption(value: 1, label: 'One'),
              SeedChipOption(value: 2, label: 'Off', enabled: false),
              SeedChipOption(value: 3, label: 'Three'),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(changes, [3]);
      expect(
        tester
            .widgetList<SeedChip>(find.byType(SeedChip))
            .map((chip) => chip.selected),
        [false, false, true],
      );
    });
    testWidgets(
      'radio default selection can update without a controlled parent',
      (tester) async {
        await tester.pumpWidget(
          hostLayoutParity(
            const SeedRadioGroup<int>(
              defaultValue: 1,
              child: Column(
                children: [
                  SeedRadio(value: 1, label: 'First'),
                  SeedRadio(value: 2, label: 'Second'),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Second'));
        await tester.pumpAndSettle();
        final selected = tester
            .widgetList<SeedPressable>(find.byType(SeedPressable))
            .map((button) => button.checked);
        expect(selected, [false, true]);
      },
    );
  });
}
