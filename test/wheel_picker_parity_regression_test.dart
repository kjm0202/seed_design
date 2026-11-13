import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(
      body: Center(child: SizedBox(width: 300, child: child)),
    ),
  ),
);

int selectedItem(WidgetTester tester) =>
    (tester
                .widget<ListWheelScrollView>(find.byType(ListWheelScrollView))
                .controller!
            as FixedExtentScrollController)
        .selectedItem;

void main() {
  testWidgets('reordering a moving wheel keeps the last committed value', (
    tester,
  ) async {
    var items = ['A', 'B', 'C', 'D'];
    final changes = <String>[];
    final steps = <String>[];
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, setState) {
            update = setState;
            return SeedWheelPicker(
              columns: [
                SeedWheelColumn.value(
                  items: items,
                  onValueChange: (value, _) => changes.add(value),
                  onIndexChange: (_, value) => steps.add(value),
                ),
              ],
            );
          },
        ),
      ),
    );
    final wheel = find.byType(ListWheelScrollView);
    final extent = tester.widget<ListWheelScrollView>(wheel).itemExtent;
    final gesture = await tester.startGesture(tester.getCenter(wheel));
    await gesture.moveBy(const Offset(0, -20));
    await gesture.moveBy(Offset(0, -extent * 1.4));
    await tester.pump();
    expect(steps, isNotEmpty);
    expect(changes, isEmpty);
    update(() => items = ['D', 'C', 'A', 'B']);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selectedItem(tester), 2);
    expect(changes, isEmpty);
  });

  testWidgets(
    'value selection follows an in-place options reorder and removal',
    (tester) async {
      final items = ['A', 'B', 'C'];
      final changes = <String>[];
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SeedWheelPicker(
                columns: [
                  SeedWheelColumn.value(
                    items: items,
                    defaultValue: items.contains('B') ? 'B' : null,
                    onValueChange: (value, _) => changes.add(value),
                  ),
                ],
              );
            },
          ),
        ),
      );
      expect(selectedItem(tester), 1);
      update(() {
        items.insert(0, items.removeLast());
      });
      await tester.pumpAndSettle();
      expect(selectedItem(tester), 2); // B
      expect(changes, isEmpty);
      update(() {
        items.remove('B');
      });
      await tester.pumpAndSettle();
      expect(selectedItem(tester), 0); // first remaining option
      expect(changes, isEmpty);
    },
  );

  testWidgets('reduced motion moves keyboard and tapped options immediately', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(
      host(
        SeedWheelPicker(
          columns: [
            SeedWheelColumn.value(
              items: const ['A', 'B', 'C', 'D'],
              onValueChange: (value, _) => changes.add(value),
            ),
          ],
        ),
        reduceMotion: true,
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(selectedItem(tester), 1);
    expect(changes, ['B']);
    await tester.tap(find.text('C'));
    await tester.pump();
    expect(selectedItem(tester), 2);
    expect(changes, ['B', 'C']);
  });

  for (final constraint in [
    'column disabled',
    'column read-only',
    'root read-only',
  ]) {
    testWidgets('$constraint cancels movement at the committed value', (
      tester,
    ) async {
      var constrained = false;
      late StateSetter update;
      final changes = <String>[];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SeedWheelPicker(
                readOnly: constraint == 'root read-only' && constrained,
                columns: [
                  SeedWheelColumn.value(
                    items: const ['A', 'B', 'C', 'D'],
                    enabled: constraint != 'column disabled' || !constrained,
                    readOnly: constraint == 'column read-only' && constrained,
                    onValueChange: (value, _) => changes.add(value),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump(const Duration(milliseconds: 100));
      update(() => constrained = true);
      await tester.pumpAndSettle();
      expect(selectedItem(tester), 0);
      expect(changes, isEmpty);
      update(() => constrained = false);
      await tester.pumpAndSettle();
      expect(selectedItem(tester), 0);
    });
  }
}
