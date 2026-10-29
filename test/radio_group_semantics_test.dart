// An isolated PACKAGE control comparison, independent of the Stackflow
// list-item-radio example (which composes a row and inner radio differently).
// React reference: doc/react_package/packages/react-headless/radio-group/
// src/useRadioGroup.ts (focus/key handling) and RadioGroup.tsx.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('PACKAGE radio group: keyboard arrow changes selected item', (
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

  testWidgets('PACKAGE radio group: disabled item is not keyboard-selected', (
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
                  value: 'b', label: 'Disabled',
                  focusNode: disabled, enabled: false,
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
}
