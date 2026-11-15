import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

Future<void> _action(
  WidgetTester tester,
  SemanticsNode node,
  SemanticsAction action,
) async {
  tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
    node.id,
    action,
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 800.0]) {
    void size(WidgetTester tester) {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets(
      'semantic activation establishes pressable keyboard focus $width',
      (tester) async {
        size(tester);
        final semantics = tester.ensureSemantics();
        final focus = FocusNode();
        var count = 0;
        await tester.pumpWidget(
          seedAppCentered(
            SeedPressable(
              focusNode: focus,
              semanticsLabel: 'Action',
              onTap: () => count++,
              child: const Text('Action'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final node = tester.getSemantics(find.bySemanticsLabel('Action'));
        await _action(tester, node, SemanticsAction.tap);
        expect(count, 1);
        expect(
          focus.hasPrimaryFocus,
          isTrue,
          reason:
              'Web accessibility activation must establish actual widget focus',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(count, 2);
        semantics.dispose();
        await tester.pumpWidget(const SizedBox.shrink());
        focus.dispose();
      },
    );

    testWidgets(
      'semantic focus on tab drives real ArrowRight selection $width',
      (tester) async {
        size(tester);
        final semantics = tester.ensureSemantics();
        var selected = 0;
        await tester.pumpWidget(
          seedAppCentered(
            StatefulBuilder(
              builder: (_, update) => SeedTabs(
                items: const [
                  SeedTabItem(label: 'One'),
                  SeedTabItem(label: 'Two'),
                ],
                selectedIndex: selected,
                onTabSelected: (index) => update(() => selected = index),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final node = tester.getSemantics(find.bySemanticsLabel('One'));
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.focus),
          isTrue,
        );
        await _action(tester, node, SemanticsAction.focus);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(selected, 1);
        semantics.dispose();
      },
    );

    testWidgets(
      'semantic menu click leaves the first arrow on the first item $width',
      (tester) async {
        size(tester);
        final semantics = tester.ensureSemantics();
        final selected = <String>[];
        await tester.pumpWidget(
          seedAppCentered(
            SeedMenuTrigger(
              triggerBuilder: (_, open, toggle) =>
                  SeedButton(label: 'Open menu', onPressed: toggle),
              builder: (_) => SeedMenu(
                groups: [
                  SeedMenuGroupData(
                    items: [
                      SeedMenuItemData(
                        label: 'First',
                        onTap: () => selected.add('first'),
                      ),
                      SeedMenuItemData(
                        label: 'Second',
                        onTap: () => selected.add('second'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await _action(
          tester,
          tester.getSemantics(find.text('Open menu')),
          SemanticsAction.tap,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(selected, ['first']);
        semantics.dispose();
      },
    );

    for (final key in [
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowUp,
    ]) {
      testWidgets(
        'semantic Select click seeds selected value on first $key $width',
        (tester) async {
          size(tester);
          final semantics = tester.ensureSemantics();
          final selected = <List<String>>[];
          await tester.pumpWidget(
            seedAppCentered(
              SeedSelect<String>(
                semanticsLabel: 'Fruit',
                defaultValue: const ['banana'],
                onValueChange: selected.add,
                groups: const [
                  SeedSelectGroup(
                    items: [
                      SeedSelectItem(value: 'apple', label: 'Apple'),
                      SeedSelectItem(value: 'banana', label: 'Banana'),
                      SeedSelectItem(value: 'cherry', label: 'Cherry'),
                    ],
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();
          await _action(
            tester,
            tester.getSemantics(find.bySemanticsLabel('Fruit')),
            SemanticsAction.tap,
          );
          await tester.sendKeyEvent(key);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(selected, isEmpty);
          expect(find.text('Banana'), findsOneWidget);
          semantics.dispose();
        },
      );
    }

    testWidgets(
      'readonly Select semantic focus is real and cannot edit $width',
      (tester) async {
        size(tester);
        final semantics = tester.ensureSemantics();
        final focus = FocusNode();
        var opened = 0;
        var changed = 0;
        await tester.pumpWidget(
          seedAppCentered(
            SeedField(
              label: 'Fruit',
              focusNode: focus,
              child: SeedSelect<String>(
                readOnly: true,
                groups: const [
                  SeedSelectGroup(
                    items: [SeedSelectItem(value: 'banana', label: 'Banana')],
                  ),
                ],
                defaultValue: const ['banana'],
                onOpenStateChanged: (_) => opened++,
                onValueChange: (_) => changed++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final node = tester.getSemantics(
          find
              .byWidgetPredicate(
                (widget) =>
                    widget is Semantics && widget.properties.readOnly == true,
              )
              .first,
        );
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.focus),
          isTrue,
        );
        await _action(tester, node, SemanticsAction.focus);
        expect(focus.hasPrimaryFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(focus.hasPrimaryFocus, isTrue);
        expect(opened, 0);
        expect(changed, 0);
        semantics.dispose();
        await tester.pumpWidget(const SizedBox.shrink());
        focus.dispose();
      },
    );

    testWidgets(
      'wheel semantic focus reaches actual column keyboard actor $width',
      (tester) async {
        size(tester);
        final semantics = tester.ensureSemantics();
        final changes = <int>[];
        await tester.pumpWidget(
          seedAppCentered(
            SizedBox(
              width: 360,
              child: SeedWheelPicker(
                columns: [
                  SeedWheelColumn.value<int>(
                    items: const [7, 8, 9],
                    defaultValue: 8,
                    semanticsLabel: 'Month',
                    onValueChange: (value, _) => changes.add(value),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final node = tester.getSemantics(find.bySemanticsLabel('Month'));
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.focus),
          isTrue,
        );
        await _action(tester, node, SemanticsAction.focus);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(changes, [9]);
        semantics.dispose();
      },
    );
  }
}
