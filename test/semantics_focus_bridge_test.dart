import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

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
          _host(
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
          _host(
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
      'readonly Select semantic focus is real and cannot edit $width',
      (tester) async {
        size(tester);
        final semantics = tester.ensureSemantics();
        final focus = FocusNode();
        var opened = 0;
        var changed = 0;
        await tester.pumpWidget(
          _host(
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
          _host(
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
