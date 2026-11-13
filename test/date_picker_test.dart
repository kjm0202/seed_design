import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
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

Widget hostContinuousCalendar(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

Widget hostInputOverlayRegression(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

SeedPressable _dateNavButton(WidgetTester tester, IconData icon) =>
    tester.widget<SeedPressable>(
      find.ancestor(
        of: find.byIcon(icon),
        matching: find.byType(SeedPressable),
      ),
    );

Widget hostReactParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

Widget hostRegression(Widget child, {ThemeData? theme}) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: theme ?? SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('month navigation', () {
    testWidgets(
      'header opens wheels and jumps to 1999 without selecting a day',
      (tester) async {
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
      },
    );

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
        var picker = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        expect(picker.columns.last.itemCount, 3);
        expect(picker.columns.last.looping, isFalse);
        await moveWheel(tester, 0, 0);
        expect(find.text('1999년 5월'), findsOneWidget);
        picker = tester.widget<SeedWheelPicker>(find.byType(SeedWheelPicker));
        expect(picker.columns.last.itemCount, 8);
        await tester.tap(find.text('1999년 5월'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedPressable>(
                find.ancestor(
                  of: find.byIcon(Icons.chevron_left),
                  matching: find.byType(SeedPressable),
                ),
              )
              .enabled,
          isFalse,
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
  });

  group('continuous calendar', () {
    testWidgets(
      'opening a default continuous calendar only builds nearby months',
      (tester) async {
        var cellBuilds = 0;
        await tester.pumpWidget(
          hostContinuousCalendar(
            SeedDatePicker(
              layout: SeedDatePickerLayout.continuous,
              height: 420,
              today: DateTime(2026, 10, 26),
              dateCellContent: (context, info) {
                cellBuilds++;
                return Text(info.label);
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('2026년 10월'), findsOneWidget);
        expect(
          cellBuilds,
          lessThan(250),
          reason: 'Opening must not lay out the preceding 100 years.',
        );
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'far navigation keeps variable-height calendars virtualized and restores date focus',
      (tester) async {
        final controller = SeedDatePickerController();
        addTearDown(controller.dispose);
        final cells = <DateTime>{};
        await tester.pumpWidget(
          hostContinuousCalendar(
            SeedDatePicker(
              layout: SeedDatePickerLayout.continuous,
              height: 420,
              today: DateTime(2026, 10, 26),
              yearRange: (start: 1900, end: 2200),
              controller: controller,
              dateCellContent: (context, info) {
                cells.add(info.date);
                return SizedBox(
                  height: info.date.day.isOdd ? 84 : 48,
                  child: Text(info.label),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final target in [
          DateTime(2200, 8, 15),
          DateTime(1900, 1, 15),
          DateTime(2026, 10, 15),
        ]) {
          cells.clear();
          controller.focusDate(target);
          await tester.pumpAndSettle();
          expect(cells.length, lessThan(250));
          final focus = FocusManager.instance.primaryFocus!;
          expect(focus.context, isNotNull);
          final dateLabel = '${target.year}년 ${target.month}월 ${target.day}일';
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label == dateLabel &&
                  widget.properties.focused == true,
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'continuous calendars scroll to earlier and later months within bounds',
      (tester) async {
        await tester.pumpWidget(
          hostContinuousCalendar(
            SeedDatePicker(
              layout: SeedDatePickerLayout.continuous,
              height: 420,
              today: DateTime(2026, 10, 26),
              monthRange: DateTimeRange(
                start: DateTime(2026, 9),
                end: DateTime(2026, 11),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scroll = find.descendant(
          of: find.byType(SeedDatePicker),
          matching: find.byType(CustomScrollView),
        );
        expect(find.text('2026년 10월').hitTestable(), findsOneWidget);
        await tester.drag(scroll, const Offset(0, 350));
        await tester.pumpAndSettle();
        expect(find.text('2026년 9월').hitTestable(), findsOneWidget);
        await tester.drag(scroll, const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(find.text('2026년 11월').hitTestable(), findsOneWidget);
        expect(find.text('2026년 8월'), findsNothing);
        expect(find.text('2026년 12월'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('bounds', () {
    testWidgets(
      'date navigation is bounded and selected date has a full label',
      (tester) async {
        DateTime? picked;
        await tester.pumpWidget(
          hostInputOverlayRegression(
            SeedDatePicker(
              initialDate: DateTime(2026, 4, 12),
              firstDate: DateTime(2026, 4, 10),
              lastDate: DateTime(2026, 4, 20),
              onDateSelected: (day) => picked = day,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(_dateNavButton(tester, Icons.chevron_left).enabled, isFalse);
        expect(_dateNavButton(tester, Icons.chevron_right).enabled, isFalse);
        final expectedDisabledColor =
            SeedThemeData.light().colorScheme.fg.disabled;
        for (final icon in [Icons.chevron_left, Icons.chevron_right]) {
          expect(
            tester.widget<Icon>(find.byIcon(icon)).color,
            expectedDisabledColor,
          );
        }
        expect(find.text('2026년 4월'), findsOneWidget);
        final semantics = tester.ensureSemantics();
        expect(find.bySemanticsLabel('2026년 4월 12일'), findsOneWidget);
        await tester.tap(find.text('15'));
        expect(picked, DateTime(2026, 4, 15));
        semantics.dispose();
      },
    );

    testWidgets('date picker clamps an initial month outside allowed range', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostInputOverlayRegression(
          SeedDatePicker(
            initialDate: DateTime(2025, 1, 1),
            firstDate: DateTime(2026, 4, 10),
            lastDate: DateTime(2026, 5, 10),
          ),
        ),
      );
      expect(find.text('2026년 4월'), findsOneWidget);
      await tester.tap(find.byTooltip('다음 달'));
      await tester.pumpAndSettle();
      expect(find.text('2026년 5월'), findsOneWidget);
      expect(_dateNavButton(tester, Icons.chevron_right).enabled, isFalse);
    });
  });

  group('multiple and range selection', () {
    testWidgets(
      'multiple dates sort values, enforce counts and still allow deselection',
      (tester) async {
        final changes = <List<DateTime>>[];
        await tester.pumpWidget(
          hostReactParity(
            SeedDatePicker(
              mode: SeedDatePickerMode.multiple,
              initialDate: DateTime(2026, 4, 1),
              constraints: [seedMaxSelectionCount(2)],
              onDatesSelected: changes.add,
            ),
          ),
        );
        await tester.tap(find.text('20'));
        await tester.pump();
        await tester.tap(find.text('10'));
        await tester.pump();
        await tester.tap(find.text('15'));
        await tester.pump();
        expect(changes.last, [DateTime(2026, 4, 10), DateTime(2026, 4, 20)]);
        await tester.tap(find.text('10'));
        await tester.pump();
        expect(changes.last, [DateTime(2026, 4, 20)]);
      },
    );

    testWidgets('date range checks excluded days inside the interval', (
      tester,
    ) async {
      final changes = <SeedDateRange>[];
      await tester.pumpWidget(
        hostReactParity(
          SeedDatePicker(
            mode: SeedDatePickerMode.range,
            initialDate: DateTime(2026, 4, 1),
            constraints: [
              seedExcludeDates((day) => day == DateTime(2026, 4, 12)),
            ],
            onRangeSelected: (start, end) =>
                changes.add(SeedDateRange(start: start!, end: end)),
          ),
        ),
      );
      await tester.tap(find.text('10'));
      await tester.pump();
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(changes, hasLength(1));
      await tester.tap(find.text('11'));
      await tester.pump();
      expect(changes.last.end, DateTime(2026, 4, 11));
    });

    testWidgets(
      'English week layout spans two months and advances by one week',
      (tester) async {
        await tester.pumpWidget(
          hostReactParity(
            SeedDatePicker(
              layout: SeedDatePickerLayout.week,
              initialDate: DateTime(2026, 4, 30),
              locale: const Locale('en', 'US'),
              weekStartsOn: DateTime.monday,
            ),
          ),
        );
        expect(find.text('May 2026'), findsOneWidget);
        expect(find.text('Mon'), findsOneWidget);
        expect(find.text('27'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        await tester.tap(find.byTooltip('Next week'));
        await tester.pumpAndSettle();
        expect(find.text('4'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
      },
    );

    testWidgets(
      'range start readonly preserves start while choosing a later end',
      (tester) async {
        final changes = <SeedDateRange>[];
        await tester.pumpWidget(
          hostReactParity(
            SeedDatePicker(
              mode: SeedDatePickerMode.range,
              initialStartDate: DateTime(2026, 4, 10),
              initialEndDate: DateTime(2026, 4, 15),
              rangeStartReadOnly: true,
              onRangeSelected: (start, end) =>
                  changes.add(SeedDateRange(start: start!, end: end)),
            ),
          ),
        );
        await tester.tap(find.text('8'));
        await tester.pump();
        expect(changes, isEmpty);
        await tester.tap(find.text('20'));
        await tester.pump();
        expect(changes.last.start, DateTime(2026, 4, 10));
        expect(changes.last.end, DateTime(2026, 4, 20));
      },
    );
  });

  group('date bounds', () {
    testWidgets('date bounds ignore time of day', (tester) async {
      DateTime? selected;
      await tester.pumpWidget(
        hostRegression(
          SeedDatePicker(
            initialDate: DateTime(2026, 10, 18),
            firstDate: DateTime(2026, 10, 18, 12),
            onDateSelected: (date) => selected = date,
          ),
        ),
      );
      await tester.tap(find.text('18'));
      expect(selected, DateTime(2026, 10, 18));
    });
  });
}
