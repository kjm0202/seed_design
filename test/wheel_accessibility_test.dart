import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

List<SemanticsNode> _nodes(WidgetTester tester) {
  final result = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    result.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return result;
}

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets('wheel exposes one named adjustable value per column $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final handle = tester.ensureSemantics();
      final changes = <int>[];
      await tester.pumpWidget(
        _host(
          SeedWheelPicker(
            columns: [
              SeedWheelColumn.value<int>(
                items: List.generate(12, (i) => i + 1),
                defaultValue: 8,
                semanticsLabel: '월',
                semanticsValueFormatter: (month) => '$month월',
                loop: true,
                onValueChange: (month, _) => changes.add(month),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final adjustable = _nodes(tester)
          .where(
            (node) =>
                node.getSemanticsData().hasAction(SemanticsAction.increase),
          )
          .toList();
      expect(
        adjustable,
        hasLength(1),
        reason: 'The scroll view must not expose a second unlabeled slider',
      );
      final data = adjustable.single.getSemanticsData();
      expect(data.label, '월');
      expect(data.value, '8월');
      expect(data.flagsCollection.isSlider, isTrue);
      expect(data.increasedValue, '9월');
      tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
        adjustable.single.id,
        SemanticsAction.increase,
      );
      await tester.pumpAndSettle();
      expect(changes, [9]);
      expect(tester.getSemantics(find.bySemanticsLabel('월')).value, '9월');
      handle.dispose();
    });

    testWidgets(
      'external wheel value and option count retain keyboard focus $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var value = 20;
        var count = 31;
        late StateSetter update;
        final changes = <int>[];
        await tester.pumpWidget(
          _host(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return SeedWheelPicker(
                  columns: [
                    SeedWheelColumn.value<int>(
                      items: List.generate(count, (i) => i + 1),
                      value: value,
                      semanticsLabel: '일',
                      onValueChange: (next, _) {
                        changes.add(next);
                        setState(() => value = next);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focus = FocusManager.instance.primaryFocus;
        expect(focus?.context, isNotNull);
        update(() {
          value = 21;
          count = 28;
        });
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus,
          same(focus),
          reason: 'Updating a controlled value must preserve the column actor',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(changes, [22]);
        expect(value, 22);
      },
    );
  }
}
