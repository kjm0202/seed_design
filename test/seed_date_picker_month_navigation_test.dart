import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Future<void> moveWheel(WidgetTester tester, int column, int index) async {
  final wheel = tester.widget<ListWheelScrollView>(
    find.byType(ListWheelScrollView).at(column),
  );
  (wheel.controller! as FixedExtentScrollController).jumpToItem(index);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('header opens wheels and jumps to 1999 without selecting a day', (
    tester,
  ) async {
    final selected = <DateTime>[];
    await tester.pumpWidget(
      host(
        SeedDatePicker(
          initialDate: DateTime(2026, 10, 25),
          firstDate: DateTime(1990),
          lastDate: DateTime(2040, 12, 31),
          onDateSelected: selected.add,
        ),
      ),
    );
    await tester.tap(find.text('2026년 10월'));
    await tester.pumpAndSettle();
    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    expect(find.byType(GridView), findsNothing);
    await moveWheel(tester, 0, 9);
    await moveWheel(tester, 1, 6);
    expect(find.text('1999년 7월'), findsOneWidget);
    expect(selected, isEmpty);
    await tester.tap(find.text('1999년 7월'));
    await tester.pumpAndSettle();
    expect(find.byType(ListWheelScrollView), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
    expect(selected, isEmpty);
    await tester.tap(find.text('15'));
    expect(selected, [DateTime(1999, 7, 15)]);
  });

  testWidgets(
    'year changes restrict months to first and last date boundaries',
    (tester) async {
      await tester.pumpWidget(
        host(
          SeedDatePicker(
            initialDate: DateTime(1999, 8, 10),
            firstDate: DateTime(1999, 5, 15),
            lastDate: DateTime(2000, 3, 5),
          ),
        ),
      );
      await tester.tap(find.text('1999년 8월'));
      await tester.pumpAndSettle();
      await moveWheel(tester, 0, 1);
      expect(find.text('2000년 3월'), findsOneWidget);
      var picker = tester.widget<SeedWheelPicker>(find.byType(SeedWheelPicker));
      expect(picker.columns.last.itemCount, 3);
      expect(picker.columns.last.looping, isFalse);
      await moveWheel(tester, 0, 0);
      expect(find.text('1999년 5월'), findsOneWidget);
      picker = tester.widget<SeedWheelPicker>(find.byType(SeedWheelPicker));
      expect(picker.columns.last.itemCount, 8);
      await tester.tap(find.text('1999년 5월'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<IconButton>(find.byType(IconButton).first).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'month wheel loops and Escape restores the calendar and header focus',
    (tester) async {
      await tester.pumpWidget(
        host(SeedDatePicker(initialDate: DateTime(2026, 12, 25))),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(SeedWheelPicker), findsOneWidget);
      await moveWheel(tester, 1, 12);
      expect(find.text('2026년 1월'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(SeedWheelPicker), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(SeedWheelPicker), findsOneWidget);
      await moveWheel(tester, 1, -1);
      expect(find.text('2026년 12월'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('opening month navigation preserves a selected date range', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var calls = 0;
    await tester.pumpWidget(
      host(
        SeedDatePicker(
          mode: SeedDatePickerMode.range,
          initialStartDate: DateTime(2026, 4, 10),
          initialEndDate: DateTime(2026, 4, 15),
          onRangeSelected: (_, _) => calls++,
        ),
      ),
    );
    await tester.tap(find.text('2026년 4월'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2026년 4월'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(
      tester.getSemantics(find.bySemanticsLabel('2026년 4월 10일')),
      matchesSemantics(
        label: '2026년 4월 10일',
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });
}
