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

void main() {
  testWidgets('group keyboard navigation skips disabled items', (tester) async {
    await tester.pumpWidget(
      _host(
        const SeedAccordion(
          items: [
            SeedAccordionItem(value: 'a', title: 'A', content: SizedBox()),
            SeedAccordionItem(
              value: 'b',
              title: 'B',
              content: SizedBox(),
              enabled: false,
            ),
            SeedAccordionItem(value: 'c', title: 'C', content: SizedBox()),
          ],
        ),
      ),
    );
    final nodes = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .map((button) => button.focusNode!)
        .toList();

    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
    expect(nodes[1].hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
  });

  testWidgets(
    'controlled item requests an expansion without mutating its state',
    (tester) async {
      final requested = <bool>[];
      Widget item(bool expanded) => _host(
        SeedAccordionItem(
          title: 'Controlled',
          content: const Text('Details'),
          expanded: expanded,
          onExpansionChanged: requested.add,
        ),
      );

      await tester.pumpWidget(item(false));
      await tester.tap(find.text('Controlled'));
      await tester.pumpAndSettle();
      expect(requested, [true]);
      expect(
        tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
        false,
      );

      await tester.pumpWidget(item(true));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
        true,
      );
      expect(requested, [true]);
    },
  );
}
