// An isolated PACKAGE control comparison, independent of the Stackflow
// list-item-radio example (which composes a row and inner radio differently).
// React reference: doc/react_package/packages/react-headless/radio-group/
// src/useRadioGroup.ts (focus/key handling) and RadioGroup.tsx.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

import 'package:flutter/rendering.dart';

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
  });
  group('native radio group', () {
    testWidgets(
      'native radio group handles arrows and ignores disabled radios',
      (tester) async {
        int? selected = 0;
        await tester.pumpWidget(
          koreanAppCentered(
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
          seedApp(
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
        scaledApp(
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
        koreanApp(
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
          koreanApp(
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

  group('RadioGroup field composition', () {
    testWidgets('description renders in the footer below the options', (
      tester,
    ) async {
      await tester.pumpWidget(
        koreanAppTopLeft(
          SeedRadioGroup<String>(
            label: '선호하는 연락 방법',
            description: '연락 받고 싶은 방법을 선택해주세요.',
            value: 'email',
            child: const Column(
              children: [
                SeedRadio<String>(value: 'email', label: '이메일'),
                SeedRadio<String>(value: 'sms', label: '문자'),
              ],
            ),
          ),
        ),
      );
      final label = tester.getRect(find.text('선호하는 연락 방법'));
      final lastOption = tester.getRect(find.text('문자'));
      final description = tester.getRect(find.text('연락 받고 싶은 방법을 선택해주세요.'));
      expect(label.bottom, lessThan(lastOption.top));
      expect(description.top, greaterThan(lastOption.bottom));
    });

    testWidgets('showRequiredIndicator adds the required mark', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        koreanAppTopLeft(
          SeedRadioGroup<String>(
            label: '선호하는 연락 방법',
            showRequiredIndicator: true,
            value: 'email',
            child: const SeedRadio<String>(value: 'email', label: '이메일'),
          ),
        ),
      );
      expect(find.bySemanticsLabel('필수 입력'), findsOneWidget);
      handle.dispose();
    });
  });

  group('group invalid state and error message', () {
    Widget host(Widget child, {double width = 320}) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
    group('RadioGroupField.ErrorMessage', () {
      Widget group({required bool invalid, String? error}) => host(
        SeedRadioGroup<String>(
          label: 'Contact',
          description: 'Pick one',
          invalid: invalid,
          errorMessage: error,
          defaultValue: 'email',
          child: const Column(
            children: [
              SeedRadio<String>(value: 'email', label: 'Email'),
              SeedRadio<String>(value: 'sms', label: 'SMS'),
            ],
          ),
        ),
      );

      testWidgets('the error is shown only while the group is invalid', (
        tester,
      ) async {
        await tester.pumpWidget(group(invalid: false, error: 'Required'));
        expect(find.text('Required'), findsNothing);
        expect(find.text('Pick one'), findsOneWidget);

        await tester.pumpWidget(group(invalid: true, error: 'Required'));
        final error = find.text('Required');
        expect(error, findsOneWidget);
        expect(find.text('Pick one'), findsNothing);
        expect(
          tester.widget<Text>(error).style!.color,
          SeedThemeData.light().colorScheme.fg.critical,
        );
        expect(
          tester.getTopLeft(error).dy,
          greaterThan(tester.getBottomLeft(find.text('SMS')).dy),
        );
      });

      testWidgets('invalid without a message keeps the description', (
        tester,
      ) async {
        await tester.pumpWidget(group(invalid: true));
        expect(find.text('Pick one'), findsOneWidget);
      });

      testWidgets('invalid reaches the group and each option', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(group(invalid: true, error: 'Required'));
        SemanticsValidationResult of(Finder finder) =>
            tester.getSemantics(finder).getSemanticsData().validationResult;
        final options = find.byType(SeedRadio<String>);
        expect(of(options.first), SemanticsValidationResult.invalid);
        expect(of(options.last), SemanticsValidationResult.invalid);
        // The radiogroup node itself carries the group name and aria-invalid.
        final radioGroup = find.byType(RadioGroup<String>);
        expect(of(radioGroup), SemanticsValidationResult.invalid);
        expect(tester.getSemantics(radioGroup).label, 'Contact');

        await tester.pumpWidget(group(invalid: false, error: 'Required'));
        expect(of(options.first), SemanticsValidationResult.none);
        expect(of(radioGroup), SemanticsValidationResult.none);
        semantics.dispose();
      });
    });
  });
}
