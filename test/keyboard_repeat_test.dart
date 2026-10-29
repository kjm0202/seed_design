import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final width in [390.0, 800.0]) {
    void size(WidgetTester tester) {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('held tab arrow repeats selection and skips disabled $width', (
      tester,
    ) async {
      size(tester);
      var selected = 0;
      final changes = <int>[];
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, update) => SeedTabs(
              items: const [
                SeedTabItem(label: 'One'),
                SeedTabItem(label: 'Disabled', enabled: false),
                SeedTabItem(label: 'Three'),
              ],
              selectedIndex: selected,
              onTabSelected: (index) {
                changes.add(index);
                update(() => selected = index);
              },
            ),
          ),
        ),
      );
      final first = tester
          .widgetList<SeedPressable>(find.byType(SeedPressable))
          .first;
      first.focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selected, 2);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
      expect(changes, [2, 0]);
      expect(selected, 0);
    });

    testWidgets(
      'held accordion arrow repeats focus with disabled skipping $width',
      (tester) async {
        size(tester);
        await tester.pumpWidget(
          _host(
            const SeedAccordion(
              items: [
                SeedAccordionItem(
                  value: 'one',
                  title: 'One',
                  content: Text('One body'),
                ),
                SeedAccordionItem(
                  value: 'disabled',
                  title: 'Disabled',
                  enabled: false,
                  content: Text('Disabled body'),
                ),
                SeedAccordionItem(
                  value: 'three',
                  title: 'Three',
                  content: Text('Three body'),
                ),
              ],
            ),
          ),
        );
        final triggers = tester
            .widgetList<SeedPressable>(find.byType(SeedPressable))
            .toList();
        triggers.first.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(triggers[2].focusNode!.hasPrimaryFocus, isTrue);
        await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
        expect(triggers.first.focusNode!.hasPrimaryFocus, isTrue);
      },
    );

    testWidgets('held wheel arrow keeps advancing the current value $width', (
      tester,
    ) async {
      size(tester);
      final values = <int>[];
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 300,
            child: SeedWheelPicker(
              columns: [
                SeedWheelColumn.value<int>(
                  items: const [7, 8, 9, 10, 11],
                  defaultValue: 8,
                  onValueChange: (value, _) => values.add(value),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(values, [9]);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      expect(values, [9, 10]);
    });

    testWidgets('fast wheel repeats preserve pending keyboard steps $width', (
      tester,
    ) async {
      size(tester);
      final values = <int>[];
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 300,
            child: SeedWheelPicker(
              columns: [
                SeedWheelColumn.value<int>(
                  items: const [7, 8, 9, 10, 11],
                  defaultValue: 8,
                  onValueChange: (value, _) => values.add(value),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(
        values.last,
        11,
        reason: 'Repeat events must advance the target while the first animation is still running',
      );
    });

    testWidgets('readonly Select holds focus during repeated arrows $width', (
      tester,
    ) async {
      size(tester);
      final focus = FocusNode();
      var changes = 0;
      var opens = 0;
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedField(
                label: 'Fruit',
                focusNode: focus,
                child: SeedSelect<String>(
                  readOnly: true,
                  defaultValue: const ['banana'],
                  groups: const [
                    SeedSelectGroup(
                      items: [SeedSelectItem(value: 'banana', label: 'Banana')],
                    ),
                  ],
                  onValueChange: (_) => changes++,
                  onOpenStateChanged: (_) => opens++,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('After')),
            ],
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(focus.hasPrimaryFocus, isTrue);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      expect(focus.hasPrimaryFocus, isTrue);
      expect(changes, 0);
      expect(opens, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      focus.dispose();
    });
  }
}
