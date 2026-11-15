import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

import 'dart:ui' show CheckedState;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

void main() {
  testWidgets('readonly select box does not change and group fits columns', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      koreanApp(
        SizedBox(
          width: 320,
          child: SeedSelectBoxGroup(
            columns: 2,
            children: [
              SeedSelectBox(
                title: 'One',
                readOnly: true,
                onSelected: (_) => changes++,
              ),
              const SeedSelectBox(
                title: 'Two',
                selected: true,
                footer: Text('Extra'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(changes, 0);
    expect(tester.takeException(), isNull);
  });

  group('group selection and semantics', () {
    List<bool?> checks(WidgetTester tester) => tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .map((item) => item.checked)
        .toList();
    testWidgets('indeterminate check card displays a mixed mark', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        seedApp(const SeedSelectBox(title: 'Mixed', indeterminate: true)),
      );
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      final semantics = tester.getSemantics(find.byType(SeedSelectBox));
      expect(
        semantics.getSemanticsData().flagsCollection.isChecked,
        CheckedState.mixed,
      );
      handle.dispose();
    });

    testWidgets('explicit empty uncontrolled radio chooses exactly one', (
      tester,
    ) async {
      await tester.pumpWidget(
        seedApp(
          const SeedSelectBoxGroup.radio(
            children: [
              SeedSelectBox(title: 'One', value: 'one'),
              SeedSelectBox(title: 'Two', value: 'two'),
            ],
          ),
        ),
      );
      expect(checks(tester), [false, false]);
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(checks(tester), [true, false]);
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();
      expect(checks(tester), [false, true]);
    });

    testWidgets('layout-only group still permits multiple checked cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        seedApp(
          const SeedSelectBoxGroup(
            children: [
              SeedSelectBox(title: 'One'),
              SeedSelectBox(title: 'Two'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('One'));
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();
      expect(checks(tester), [true, true]);
    });

    testWidgets(
      'mark visibility does not affect input semantics and Space only',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          seedApp(
            const SeedSelectBoxGroup.radio(
              children: [
                SeedSelectBox(
                  title: 'One',
                  value: 'one',
                  control: SeedSelectBoxControl.none,
                  invalid: true,
                ),
                SeedSelectBox(
                  title: 'Two',
                  value: 'two',
                  control: SeedSelectBoxControl.checkmark,
                ),
              ],
            ),
          ),
        );
        final first = tester
            .getSemantics(find.byType(SeedSelectBox).first)
            .getSemanticsData();
        expect(first.validationResult, SemanticsValidationResult.invalid);
        expect(first.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
        expect(first.flagsCollection.isChecked, CheckedState.isFalse);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(checks(tester), [false, false]);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(checks(tester), [true, false]);
        handle.dispose();
      },
    );

    testWidgets(
      'readOnly cards remain navigable but selection stays unchanged',
      (tester) async {
        final events = <Object?>[];
        await tester.pumpWidget(
          seedApp(
            SeedSelectBoxGroup.radio(
              defaultValue: 'one',
              readOnly: true,
              onValueChange: events.add,
              children: const [
                SeedSelectBox(title: 'One', value: 'one'),
                SeedSelectBox(title: 'Two', value: 'two'),
              ],
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final nodes = tester
            .widgetList<FocusableActionDetector>(
              find.byType(FocusableActionDetector),
            )
            .map((e) => e.focusNode!)
            .toList();
        expect(nodes.first.hasPrimaryFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(nodes.last.hasPrimaryFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.tap(find.text('Two'));
        await tester.pumpAndSettle();
        expect(checks(tester), [true, false]);
        expect(events, isEmpty);
      },
    );

    testWidgets('radio option reactivation does not emit a change', (
      tester,
    ) async {
      final events = <String?>[];
      await tester.pumpWidget(
        seedApp(
          SeedRadioGroup<String>(
            defaultValue: 'one',
            onValueChange: events.add,
            child: const Column(
              children: [
                SeedRadio(value: 'one', label: 'One'),
                SeedRadio(value: 'two', label: 'Two'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('One'));
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Two'));
      expect(events, ['two']);
    });

    testWidgets(
      'radio uses the group value even with individual checked state',
      (tester) async {
        await tester.pumpWidget(
          seedApp(
            const SeedSelectBoxGroup.radio(
              children: [
                SeedSelectBox(title: 'One', value: 'one', checked: true),
              ],
            ),
          ),
        );
        expect(checks(tester), [false]);
        await tester.tap(find.text('One'));
        await tester.pumpAndSettle();
        expect(checks(tester), [true]);
      },
    );
  });
}
