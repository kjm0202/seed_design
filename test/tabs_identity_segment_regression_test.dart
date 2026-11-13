import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

void main() {
  testWidgets('uncontrolled tab follows value and visited panels on reorder', (
    tester,
  ) async {
    final order = ValueNotifier<List<String>>(['a', 'b', 'c']);
    final items = [
      for (final value in order.value)
        SeedTabItem(label: value.toUpperCase(), value: value),
    ];
    await tester.pumpWidget(
      host(
        ValueListenableBuilder<List<String>>(
          valueListenable: order,
          builder: (_, values, _) => SeedTabsView(
            lazyMount: true,
            items: items,
            children: [for (final value in values) Text('page $value')],
          ),
        ),
      ),
    );
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    items.insert(0, items.removeLast());
    order.value = ['c', 'a', 'b'];
    await tester.pumpAndSettle();
    expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 2);
    expect(find.text('page b'), findsOneWidget);
    expect(find.text('page c', skipOffstage: false), findsNothing);
    items.removeLast();
    order.value = ['c', 'a'];
    await tester.pumpAndSettle();
    expect(find.text('page a'), findsOneWidget);
  });

  testWidgets('segment custom child determines control height', (tester) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 300,
          child: SeedSegmentedControl<int>(
            segments: [
              SeedSegment(
                value: 0,
                child: LayoutBuilder(
                  builder: (_, _) => const SizedBox(
                    key: ValueKey('tall'),
                    height: 80,
                    child: Text('Tall'),
                  ),
                ),
              ),
              SeedSegment(value: 1, label: 'Other'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const ValueKey('tall'))).height, 80);
    expect(
      tester.getSize(find.byType(SeedSegmentedControl<int>)).height,
      greaterThanOrEqualTo(100),
    );
  });

  testWidgets(
    'carousel retains selected identity and handles deletion with lazy panels',
    (tester) async {
      final order = ValueNotifier<List<String>>(['a', 'b', 'c']);
      final changes = <String>[];
      await tester.pumpWidget(
        host(
          ValueListenableBuilder<List<String>>(
            valueListenable: order,
            builder: (_, values, _) => SeedTabsView(
              carousel: true,
              dynamicHeight: true,
              lazyMount: true,
              onValueChange: changes.add,
              items: [
                for (final value in values)
                  SeedTabItem(label: value.toUpperCase(), value: value),
              ],
              children: [
                for (final value in values)
                  SizedBox(
                    height: value == 'b' ? 100 : 50,
                    child: Text('page $value'),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      order.value = ['c', 'a', 'b'];
      await tester.pumpAndSettle();
      expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 2);
      expect(find.text('page b'), findsOneWidget);
      expect(changes, ['b']);
      order.value = ['c', 'a'];
      await tester.pumpAndSettle();
      expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 1);
      expect(find.text('page a'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(changes, ['b']);
    },
  );

  testWidgets('segment exposes invalid status on its semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        SeedSegmentedControl<int>(
          segments: [
            SeedSegment(value: 0, label: 'Invalid', invalid: true),
            SeedSegment(value: 1, label: 'Valid'),
          ],
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.text('Invalid'))
          .getSemanticsData()
          .validationResult,
      SemanticsValidationResult.invalid,
    );
    handle.dispose();
  });
}
