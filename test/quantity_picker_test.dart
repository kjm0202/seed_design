import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

void main() {
  Future<void> mount(WidgetTester tester, SeedQuantityPicker picker) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(body: Center(child: picker)),
      ),
    );
  }

  testWidgets('read-only quantity picker cannot activate either button', (
    tester,
  ) async {
    await mount(tester, const SeedQuantityPicker(value: 3, onChanged: null));
    final buttons = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .toList();
    expect(buttons, hasLength(2));
    expect(buttons.every((button) => !button.enabled), isTrue);
  });

  testWidgets('quantity picker limits and step prevent invalid changes', (
    tester,
  ) async {
    final changes = <int>[];
    await mount(
      tester,
      SeedQuantityPicker(
        value: 1,
        min: 1,
        max: 5,
        step: 2,
        onChanged: changes.add,
      ),
    );
    var buttons = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .toList();
    expect(buttons.first.enabled, isFalse);
    expect(buttons.last.enabled, isTrue);
    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(changes, [3]);

    expect(
      () => SeedQuantityPicker(value: 3, step: 0, onChanged: changes.add),
      throwsAssertionError,
    );
  });
  group('uncontrolled', () {
    testWidgets('uncontrolled quantity updates without an external callback', (
      tester,
    ) async {
      await tester.pumpWidget(
        koreanApp(const SeedQuantityPicker(defaultValue: 3)),
      );
      await tester.tap(find.bySemanticsLabel('수량 늘리기'));
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
    });
  });

  group('remove and loading', () {
    testWidgets('quantity removable and independent loading guard actions', (
      tester,
    ) async {
      var removes = 0;
      final changes = <int>[];
      await tester.pumpWidget(
        koreanAppNarrow(
          SeedQuantityPicker(
            value: 1,
            onChanged: changes.add,
            removable: true,
            onRemove: () => removes++,
            incrementLoading: true,
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('상품 삭제'));
      await tester.pump();
      expect(removes, 1);
      expect(changes, isEmpty);
      expect(find.byType(SeedProgressCircle), findsOneWidget);
    });
  });

  group('changed bounds and controlled value', () {
    Widget host(Widget child) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(child: SizedBox(width: 300, child: child)),
      ),
    );
    testWidgets(
      'uncontrolled quantity reconciles changed bounds without callback',
      (tester) async {
        final changes = <int>[];
        Widget picker(int min, int max) => host(
          SeedQuantityPicker(
            key: const ValueKey('quantity'),
            min: min,
            max: max,
            onValueChange: changes.add,
          ),
        );
        await tester.pumpWidget(picker(1, 5));
        await tester.pumpWidget(picker(2, 5));
        expect(tester.takeException(), isNull);
        expect(find.text('2'), findsOneWidget);
        expect(changes, isEmpty);
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();
        expect(find.text('3'), findsOneWidget);
        expect(changes, [3]);
        await tester.pumpWidget(picker(1, 2));
        expect(find.text('2'), findsOneWidget);
        expect(changes, [3]);
        await tester.pumpWidget(picker(1, 5));
        expect(find.text('2'), findsOneWidget);
      },
    );
    testWidgets('controlled quantity proposes without replacing parent value', (
      tester,
    ) async {
      final changes = <int>[];
      Widget picker(int min) => host(
        SeedQuantityPicker(
          key: const ValueKey('controlled'),
          value: 3,
          min: min,
          max: 5,
          onValueChange: changes.add,
        ),
      );
      await tester.pumpWidget(picker(1));
      await tester.pumpWidget(picker(2));
      expect(find.text('3'), findsOneWidget);
      expect(changes, isEmpty);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(changes, [4]);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
