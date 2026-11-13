import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 300, child: child)),
  ),
);

void main() {
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

  testWidgets('allowed values advance from the closest value by keyboard', (
    tester,
  ) async {
    final changes = <List<double>>[];
    await tester.pumpWidget(
      host(
        SeedSlider(
          values: const [6],
          allowedValues: const [0, 10, 100],
          onValuesChange: changes.add,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(changes, [
      [100.0],
    ]);
  });

  testWidgets('slider reports decimal value without rounding to one place', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(SeedSlider(values: [0.25], min: 0, max: 1, step: 0.01)),
    );
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.semanticFormatterCallback!(0.25), '0.25');
  });

  testWidgets('empty allowed values keep normal step keyboard behavior', (
    tester,
  ) async {
    final changes = <List<double>>[];
    await tester.pumpWidget(
      host(
        SeedSlider(
          defaultValues: const [4],
          min: 0,
          max: 10,
          step: 2,
          allowedValues: const [],
          onValuesChange: changes.add,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(changes, [
      [6.0],
    ]);
  });
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

  testWidgets('pointer snaps to nearest allowed slider value', (tester) async {
    final changes = <List<double>>[];
    await tester.pumpWidget(
      host(
        SeedSlider(
          defaultValues: const [0],
          allowedValues: const [0, 30, 100],
          onValuesChange: changes.add,
        ),
      ),
    );
    final rect = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(rect.left + rect.width * 0.35, rect.center.dy));
    await tester.pump();
    expect(changes.last, [30.0]);
  });

  testWidgets('nonintegral step range advances by keyboard and semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final changes = <List<double>>[];
    await tester.pumpWidget(
      host(
        SeedSlider(
          defaultValues: const [0],
          min: 0,
          max: 90,
          step: 20,
          onValuesChange: changes.add,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(changes.last, [20.0]);
    final node = tester.getSemantics(find.byType(Slider));
    SemanticsNode? adjustable;
    node.visitChildren((child) {
      if (child.getSemanticsData().hasAction(SemanticsAction.increase)) {
        adjustable = child;
      }
      return true;
    });
    expect(adjustable, isNotNull);
    tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
      adjustable!.id,
      SemanticsAction.increase,
    );
    await tester.pump();
    expect(changes.last, [40.0]);
    semantics.dispose();
  });

  testWidgets('range pointer preserves the unchanged off-grid thumb', (
    tester,
  ) async {
    final changes = <List<double>>[];
    await tester.pumpWidget(
      host(
        SeedSlider(
          values: const [6, 100],
          allowedValues: const [0, 10, 100],
          onValuesChange: changes.add,
        ),
      ),
    );
    final rect = tester.getRect(find.byType(RangeSlider));
    final gesture = await tester.startGesture(
      Offset(rect.right - 10, rect.center.dy),
    );
    await gesture.moveTo(Offset(rect.left + 38, rect.center.dy));
    await gesture.up();
    await tester.pump();
    expect(changes, isNotEmpty);
    expect(changes.last, [6.0, 10.0]);
  });

  testWidgets('range semantics preserves the unchanged off-grid thumb', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final changes = <List<double>>[];
    await tester.pumpWidget(
      host(
        SeedSlider(
          values: const [6, 100],
          allowedValues: const [0, 10, 100],
          onValuesChange: changes.add,
        ),
      ),
    );
    final node = tester.getSemantics(find.byType(RangeSlider));
    SemanticsNode? endThumb;
    void findEnd(SemanticsNode current) {
      if (current.getSemanticsData().value == '100') endThumb = current;
      current.visitChildren((child) {
        findEnd(child);
        return true;
      });
    }

    findEnd(node);
    expect(endThumb, isNotNull);
    tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
      endThumb!.id,
      SemanticsAction.decrease,
    );
    await tester.pump();
    expect(changes.last, [6.0, 10.0]);
    semantics.dispose();
  });
}
