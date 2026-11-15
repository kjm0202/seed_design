import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

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

SeedPressable _dateNavButton(WidgetTester tester, IconData icon) =>
    tester.widget<SeedPressable>(
      find.ancestor(
        of: find.byIcon(icon),
        matching: find.byType(SeedPressable),
      ),
    );

Widget themedKoreanApp(Widget child, {ThemeData? theme}) => MaterialApp(
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
          koreanAppCentered(
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
        koreanAppCentered(
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
          koreanAppNarrow(
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
        koreanAppNarrow(
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
          koreanAppNarrow(
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
          koreanAppNarrow(
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
        themedKoreanApp(
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

  group('bounds, constraints and navigation', () {
    Widget pickerHost(Widget child) => MaterialApp(
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(child: SizedBox(width: 720, child: child)),
      ),
    );
    testWidgets('two-month next navigation advances one month', (tester) async {
      await tester.pumpWidget(
        pickerHost(
          SeedDatePicker(
            visibleRange: SeedDatePickerLayout.twoMonths,
            defaultViewDate: DateTime(2026, 1),
          ),
        ),
      );
      expect(find.text('January 2026'), findsOneWidget);
      expect(find.text('February 2026'), findsOneWidget);
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('February 2026'), findsOneWidget);
      expect(find.text('March 2026'), findsOneWidget);
    });

    testWidgets('year and day bounds intersect in navigation and cells', (
      tester,
    ) async {
      final changes = <DateTime?>[];
      final cells = <DateTime, SeedDateCellInfo>{};
      await tester.pumpWidget(
        pickerHost(
          SeedDatePicker(
            visibleRange: SeedDatePickerLayout.twoMonths,
            defaultViewDate: DateTime(2026, 12),
            yearRange: (start: 2026, end: 2026),
            firstDate: DateTime(2025, 12),
            onValueChange: changes.add,
            dateCellContent: (context, info) {
              cells[info.date] = info;
              return Text('${info.date.day}');
            },
          ),
        ),
      );
      expect(cells[DateTime(2027, 1, 10)]!.unavailable, isTrue);
      final january = find
          .ancestor(
            of: find.text('January 2027'),
            matching: find.byType(Column),
          )
          .first;
      await tester.tap(find.descendant(of: january, matching: find.text('10')));
      await tester.pump();
      expect(changes, isEmpty);
    });

    testWidgets('multiple selection honors a constraint on deselection', (
      tester,
    ) async {
      final changes = <List<DateTime>>[];
      final date = DateTime(2026, 4, 10);
      await tester.pumpWidget(
        pickerHost(
          SeedDatePicker.multiple(
            defaultViewDate: DateTime(2026, 4),
            defaultValue: [date],
            constraints: [(day, proposal) => proposal.dates.contains(date)],
            onValueChange: changes.add,
          ),
        ),
      );
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(changes, isEmpty);
    });

    testWidgets('a selected day can be removed after the bounds narrow', (
      tester,
    ) async {
      final changes = <List<DateTime>>[];
      final selected = DateTime(2026, 4, 10);
      Widget picker(DateTime firstDate) => pickerHost(
        SeedDatePicker.multiple(
          defaultViewDate: DateTime(2026, 4),
          defaultValue: [selected],
          firstDate: firstDate,
          onValueChange: changes.add,
        ),
      );
      await tester.pumpWidget(picker(DateTime(2026, 4, 1)));
      await tester.pumpWidget(picker(DateTime(2026, 4, 11)));
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(changes, [<DateTime>[]]);
    });

    testWidgets('month wheel uses the intersection of all supplied bounds', (
      tester,
    ) async {
      await tester.pumpWidget(
        pickerHost(
          SeedDatePicker(
            defaultViewDate: DateTime(2026, 9),
            yearRange: (start: 2026, end: 2027),
            monthRange: DateTimeRange(
              start: DateTime(2025, 1),
              end: DateTime(2027, 10),
            ),
            firstDate: DateTime(2026, 6, 10),
            lastDate: DateTime(2026, 11, 20),
          ),
        ),
      );
      await tester.tap(find.text('September 2026'));
      await tester.pumpAndSettle();
      final picker = tester.widget<SeedWheelPicker>(
        find.byType(SeedWheelPicker),
      );
      expect(picker.columns.map((column) => column.itemCount).toList(), [1, 6]);
    });

    testWidgets(
      'maximum count permits removal when initial selection exceeds it',
      (tester) async {
        final changes = <List<DateTime>>[];
        await tester.pumpWidget(
          pickerHost(
            SeedDatePicker.multiple(
              defaultViewDate: DateTime(2026, 4),
              defaultValue: [
                DateTime(2026, 4, 10),
                DateTime(2026, 4, 11),
                DateTime(2026, 4, 12),
              ],
              constraints: [seedMaxSelectionCount(1)],
              onValueChange: changes.add,
            ),
          ),
        );
        await tester.tap(find.text('10'));
        await tester.pump();
        expect(changes.single, [DateTime(2026, 4, 11), DateTime(2026, 4, 12)]);
      },
    );

    testWidgets('disjoint month bounds render without selectable dates', (
      tester,
    ) async {
      final cells = <DateTime, SeedDateCellInfo>{};
      await tester.pumpWidget(
        pickerHost(
          SeedDatePicker(
            defaultViewDate: DateTime(2026, 6),
            monthRange: DateTimeRange(
              start: DateTime(2026, 8),
              end: DateTime(2026, 12),
            ),
            lastDate: DateTime(2026, 3, 31),
            dateCellContent: (context, info) {
              cells[info.date] = info;
              return Text('${info.date.day}');
            },
          ),
        ),
      );
      expect(cells.values.every((cell) => cell.unavailable), isTrue);
      await tester.tap(find.text('August 2026'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('two-week layout', () {
    Widget host(
      Widget picker, {
      Locale locale = const Locale('ko'),
      TextDirection? direction,
      bool reduceMotion = false,
    }) => MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ko')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: SeedThemeData.light().toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: direction == null
                ? picker
                : Directionality(textDirection: direction, child: picker),
          ),
        ),
      ),
    );

    /// Opacity of the nearest fade wrapping [text].
    double opacityOf(WidgetTester tester, String text) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.text(text),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    void expectVisible(List<int> days, {List<int> hidden = const []}) {
      for (final day in days) {
        expect(find.text('$day'), findsOneWidget, reason: 'day $day');
      }
      for (final day in hidden) {
        expect(find.text('$day'), findsNothing, reason: 'day $day');
      }
    }

    group('two-week navigation', () {
      testWidgets('reaches both month bounds using the visible week start', (
        tester,
      ) async {
        final views = <DateTime>[];
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.twoWeeks,
              defaultViewDate: DateTime(2026, 7, 18),
              weekStartsOn: DateTime.sunday,
              monthRange: DateTimeRange(
                start: DateTime(2026, 7),
                end: DateTime(2026, 7, 31),
              ),
              onViewDateChange: views.add,
            ),
          ),
        );

        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 7, 26)]);
        expectVisible([26, 31, 1, 8], hidden: [25]);
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pumpAndSettle();
        expect(views, hasLength(1));

        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pumpAndSettle();
        expect(views, [
          DateTime(2026, 7, 26),
          DateTime(2026, 7, 12),
          DateTime(2026, 6, 28),
        ]);
        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pumpAndSettle();
        expect(views, hasLength(3));
      });

      testWidgets('shows two rows from the week start and moves by two weeks', (
        tester,
      ) async {
        final views = <DateTime>[];
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.twoWeeks,
              defaultViewDate: DateTime(2026, 7, 1),
              weekStartsOn: DateTime.sunday,
              onViewDateChange: views.add,
            ),
          ),
        );
        expect(find.text('2026년 7월'), findsOneWidget);
        expectVisible([28, 29, 30, 1, 5, 11], hidden: [12, 27]);
        expect(find.byTooltip('이전 2주'), findsOneWidget);
        expect(find.byTooltip('다음 2주'), findsOneWidget);

        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 7, 12)]);
        expectVisible([12, 18, 19, 25], hidden: [11, 26]);
        expect(find.text('2026년 7월'), findsOneWidget);

        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pumpAndSettle();
        expect(views.last, DateTime(2026, 6, 28));
        expectVisible([28, 11], hidden: [12]);
      });

      testWidgets('PageDown and PageUp move focus and view by two weeks', (
        tester,
      ) async {
        final views = <DateTime>[];
        final values = <DateTime?>[];
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.twoWeeks,
              defaultViewDate: DateTime(2026, 7, 12),
              weekStartsOn: DateTime.sunday,
              onViewDateChange: views.add,
              onValueChange: values.add,
            ),
          ),
        );
        await tester.tap(find.text('13'));
        await tester.pumpAndSettle();
        expect(values, [DateTime(2026, 7, 13)]);

        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 7, 26)]);
        expectVisible([26, 31, 1, 8], hidden: [25, 9]);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(values.last, DateTime(2026, 7, 27));

        await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
        await tester.pumpAndSettle();
        expect(views.last, DateTime(2026, 7, 12));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(values.last, DateTime(2026, 7, 13));
      });

      testWidgets('PageDown clamps focus to the last navigable month', (
        tester,
      ) async {
        final views = <DateTime>[];
        final values = <DateTime?>[];
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.twoWeeks,
              defaultViewDate: DateTime(2026, 7, 12),
              weekStartsOn: DateTime.sunday,
              monthRange: DateTimeRange(
                start: DateTime(2026, 7),
                end: DateTime(2026, 7, 31),
              ),
              onViewDateChange: views.add,
              onValueChange: values.add,
            ),
          ),
        );
        await tester.tap(find.text('20'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 7, 26)]);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(values.last, DateTime(2026, 7, 31));
      });

      testWidgets('arrow keys move between the rows before paging the view', (
        tester,
      ) async {
        final views = <DateTime>[];
        final values = <DateTime?>[];
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.twoWeeks,
              defaultViewDate: DateTime(2026, 7, 12),
              weekStartsOn: DateTime.sunday,
              onViewDateChange: views.add,
              onValueChange: values.add,
            ),
          ),
        );
        await tester.tap(find.text('14'));
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(views, isEmpty, reason: 'the second row is already visible');
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(values.last, DateTime(2026, 7, 21));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 7, 26)]);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(values.last, DateTime(2026, 7, 28));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 7, 26)], reason: '8/4 and 7/28 visible');
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(views.last, DateTime(2026, 7, 19));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(values.last, DateTime(2026, 7, 21));
      });

      testWidgets('weekday row is 24 high and labels follow the locale', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.twoWeeks,
              defaultViewDate: DateTime(2026, 7, 12),
              locale: const Locale('en', 'US'),
              weekStartsOn: DateTime.sunday,
            ),
            locale: const Locale('en'),
          ),
        );
        final weekday = find
            .ancestor(of: find.text('Sun'), matching: find.byType(SizedBox))
            .first;
        expect(tester.getSize(weekday).height, 24);
        expect(find.byTooltip('Previous two weeks'), findsOneWidget);
        expect(find.byTooltip('Next two weeks'), findsOneWidget);

        await tester.pumpWidget(
          host(
            SeedLocalizations(
              labels: const {SeedLabel.nextTwoWeeks: 'Two weeks later'},
              child: SeedDatePicker(
                visibleRange: SeedDatePickerLayout.twoWeeks,
                defaultViewDate: DateTime(2026, 7, 12),
              ),
            ),
            locale: const Locale('en'),
          ),
        );
        expect(find.byTooltip('Two weeks later'), findsOneWidget);
        expect(find.byTooltip('Previous two weeks'), findsOneWidget);
      });

      testWidgets('title opens the year/month wheel in a popover', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.twoWeeks,
              defaultViewDate: DateTime(2026, 7, 12),
              weekStartsOn: DateTime.sunday,
            ),
          ),
        );
        await tester.tap(find.text('2026년 7월'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedWheelPicker), findsOneWidget);
        expect(find.text('25'), findsOneWidget, reason: 'rows stay visible');
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(SeedWheelPicker), findsNothing);
      });
    });

    group('two-week title', () {
      Future<void> pumpTitle(
        WidgetTester tester,
        DateTime view, {
        SeedDatePickerLayout layout = SeedDatePickerLayout.twoWeeks,
        int weekStartsOn = DateTime.sunday,
        ({int start, int end})? yearRange,
      }) => tester.pumpWidget(
        host(
          SeedDatePicker(
            key: UniqueKey(),
            visibleRange: layout,
            defaultViewDate: view,
            weekStartsOn: weekStartsOn,
            yearRange: yearRange,
          ),
        ),
      );

      testWidgets('uses the month owning more days of the first row', (
        tester,
      ) async {
        // 7/26-8/1: four July days. Week keeps its end-of-week rule (August).
        await pumpTitle(tester, DateTime(2026, 7, 30));
        expect(find.text('2026년 7월'), findsOneWidget);
        await pumpTitle(
          tester,
          DateTime(2026, 7, 30),
          layout: SeedDatePickerLayout.week,
        );
        expect(find.text('2026년 8월'), findsOneWidget);

        // 3/29-4/4: four April days.
        await pumpTitle(tester, DateTime(2026, 4, 2));
        expect(find.text('2026년 4월'), findsOneWidget);
      });

      testWidgets('falls back inside the navigable month bounds', (
        tester,
      ) async {
        // 2025/12/28-2026/1/3: the majority month precedes the year range.
        await pumpTitle(
          tester,
          DateTime(2026, 1, 1),
          yearRange: (start: 2026, end: 2026),
        );
        expect(find.text('2026년 1월'), findsOneWidget);

        // Tuesday start, 2026/12/29-2027/1/4: majority January 2027.
        await pumpTitle(
          tester,
          DateTime(2026, 12, 30),
          weekStartsOn: DateTime.tuesday,
        );
        expect(find.text('2027년 1월'), findsOneWidget);
        await pumpTitle(
          tester,
          DateTime(2026, 12, 30),
          weekStartsOn: DateTime.tuesday,
          yearRange: (start: 2026, end: 2026),
        );
        expect(find.text('2026년 12월'), findsOneWidget);
      });
    });

    testWidgets('selection and constraints survive two-week moves', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final ranges = <SeedDateRange?>[];
      await tester.pumpWidget(
        host(
          SeedDatePicker.range(
            visibleRange: SeedDatePickerLayout.twoWeeks,
            defaultViewDate: DateTime(2026, 6, 28),
            weekStartsOn: DateTime.sunday,
            constraints: [
              seedExcludeDates((day) => day == DateTime(2026, 7, 20)),
            ],
            onValueChange: ranges.add,
          ),
        ),
      );
      // A range across both rows.
      await tester.tap(find.text('30'));
      await tester.pump();
      await tester.tap(find.text('9'));
      await tester.pump();
      expect(ranges.last?.start, DateTime(2026, 6, 30));
      expect(ranges.last?.end, DateTime(2026, 7, 9));

      await tester.tap(find.byTooltip('다음 2주'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('이전 2주'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel('2026년 7월 5일')),
        isSemantics(isSelected: true),
      );

      await tester.tap(find.byTooltip('다음 2주'));
      await tester.pumpAndSettle();
      final count = ranges.length;
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(ranges, hasLength(count), reason: 'excluded date stays disabled');
      await tester.tap(find.text('21'));
      await tester.pump();
      expect(ranges.last?.start, DateTime(2026, 7, 21));
      expect(ranges.last?.end, isNull);
      semantics.dispose();
    });

    group('view transition', () {
      Future<void> pumpPicker(
        WidgetTester tester, {
        SeedDatePickerLayout layout = SeedDatePickerLayout.twoWeeks,
        TextDirection? direction,
        bool reduceMotion = false,
        ValueChanged<DateTime?>? onValueChange,
      }) => tester.pumpWidget(
        host(
          SeedDatePicker(
            visibleRange: layout,
            defaultViewDate: DateTime(2026, 7, 12),
            weekStartsOn: DateTime.sunday,
            onValueChange: onValueChange,
          ),
          direction: direction,
          reduceMotion: reduceMotion,
        ),
      );

      testWidgets('does not run on first build or for selection changes', (
        tester,
      ) async {
        final values = <DateTime?>[];
        await pumpPicker(tester, onValueChange: values.add);
        expect(opacityOf(tester, '14'), 1);
        await tester.tap(find.text('14'));
        await tester.pump();
        expect(values, [DateTime(2026, 7, 14)]);
        expect(opacityOf(tester, '14'), 1);
        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('next rows fade in from the right without resizing', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final values = <DateTime?>[];
        await pumpPicker(tester, onValueChange: values.add);
        final size = tester.getSize(find.byType(SeedDatePicker));
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pump();
        final start = tester.getCenter(find.text('30'));
        expect(opacityOf(tester, '30'), 0);
        expect(tester.getSize(find.byType(SeedDatePicker)), size);
        // New rows are announced and tappable while still entering.
        expect(find.bySemanticsLabel('2026년 7월 30일'), findsOneWidget);
        await tester.tap(find.text('30'));
        await tester.pump(const Duration(milliseconds: 150));
        expect(values, [DateTime(2026, 7, 30)]);
        final opacity = opacityOf(tester, '30');
        expect(opacity, inExclusiveRange(0, 1));
        await tester.pumpAndSettle();
        final end = tester.getCenter(find.text('30'));
        expect(start.dx - end.dx, moreOrLessEquals(20));
        expect(start.dy, end.dy);
        expect(opacityOf(tester, '30'), 1);
        expect(tester.getSize(find.byType(SeedDatePicker)), size);
        semantics.dispose();
      });

      testWidgets('previous rows enter from the left', (tester) async {
        await pumpPicker(tester);
        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pump();
        final start = tester.getCenter(find.text('30'));
        await tester.pumpAndSettle();
        final end = tester.getCenter(find.text('30'));
        expect(start.dx - end.dx, moreOrLessEquals(-20));
      });

      testWidgets('RTL reverses the slide direction', (tester) async {
        await pumpPicker(tester, direction: TextDirection.rtl);
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pump();
        final start = tester.getCenter(find.text('30'));
        await tester.pumpAndSettle();
        final end = tester.getCenter(find.text('30'));
        expect(start.dx - end.dx, moreOrLessEquals(-20));

        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pump();
        final back = tester.getCenter(find.text('12'));
        await tester.pumpAndSettle();
        expect(
          back.dx - tester.getCenter(find.text('12')).dx,
          moreOrLessEquals(20),
        );
      });

      testWidgets('reduced motion fades without sliding', (tester) async {
        await pumpPicker(tester, reduceMotion: true);
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pump();
        final start = tester.getCenter(find.text('30'));
        expect(opacityOf(tester, '30'), 0);
        await tester.pump(const Duration(milliseconds: 150));
        expect(opacityOf(tester, '30'), inExclusiveRange(0, 1));
        expect(tester.getCenter(find.text('30')), start);
        await tester.pumpAndSettle();
        expect(tester.getCenter(find.text('30')), start);
        expect(opacityOf(tester, '30'), 1);
      });

      testWidgets('consecutive moves restart the entrance', (tester) async {
        await pumpPicker(tester);
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(opacityOf(tester, '30'), greaterThan(0.5));
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pump();
        expect(opacityOf(tester, '9'), 0);
        final start = tester.getCenter(find.text('9'));
        await tester.pumpAndSettle();
        expect(
          start.dx - tester.getCenter(find.text('9')).dx,
          moreOrLessEquals(20),
        );
      });

      testWidgets('changing layout during an entrance shows the new rows', (
        tester,
      ) async {
        await pumpPicker(tester);
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pump();
        expect(opacityOf(tester, '30'), 0);

        await pumpPicker(tester, layout: SeedDatePickerLayout.month);
        expect(opacityOf(tester, '15'), 1);
      });

      testWidgets('month and week layouts animate but keep their steps', (
        tester,
      ) async {
        final views = <DateTime>[];
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              visibleRange: SeedDatePickerLayout.week,
              defaultViewDate: DateTime(2026, 7, 12),
              weekStartsOn: DateTime.sunday,
              onViewDateChange: views.add,
            ),
          ),
        );
        expect(find.byTooltip('다음 주'), findsOneWidget);
        await tester.tap(find.byTooltip('다음 주'));
        await tester.pump();
        expect(opacityOf(tester, '19'), 0);
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 7, 19)]);
        expectVisible([19, 25], hidden: [18, 26]);

        views.clear();
        await tester.pumpWidget(
          host(
            SeedDatePicker(
              defaultViewDate: DateTime(2026, 7, 12),
              onViewDateChange: views.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byTooltip('다음 달'), findsOneWidget);
        await tester.tap(find.byTooltip('다음 달'));
        await tester.pump();
        expect(opacityOf(tester, '15'), 0);
        await tester.pumpAndSettle();
        expect(views, [DateTime(2026, 8)]);
        expect(find.text('2026년 8월'), findsOneWidget);
        expect(opacityOf(tester, '15'), 1);
      });
    });
  });

  group('custom wheel builder', () {
    group('DatePickerWheelRenderProps', () {
      Widget korean(Widget child) => MaterialApp(
        locale: const Locale('ko'),
        supportedLocales: const [Locale('ko')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(body: Center(child: child)),
      );

      testWidgets('a custom wheel replaces the default and drives the view', (
        tester,
      ) async {
        final selected = <DateTime>[];
        late SeedDatePickerWheelRenderProps props;
        await tester.pumpWidget(
          korean(
            SeedDatePicker(
              initialDate: DateTime(2026, 10, 25),
              firstDate: DateTime(2025, 3),
              lastDate: DateTime(2027, 12, 31),
              onDateSelected: selected.add,
              wheelBuilder: (context, wheel) {
                props = wheel;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final column in wheel.columns)
                      TextButton(
                        onPressed: () => column.onValueChange(
                          column.id == SeedDatePickerWheelColumnId.year
                              ? 2025
                              : 3,
                        ),
                        child: Text('${column.id.name}:${column.value}'),
                      ),
                  ],
                );
              },
            ),
          ),
        );
        await tester.tap(find.text('2026년 10월'));
        await tester.pumpAndSettle();

        // The default wheel is not built.
        expect(find.byType(SeedWheelPicker), findsNothing);
        expect(find.text('year:2026'), findsOneWidget);
        expect(find.text('month:10'), findsOneWidget);

        expect(props.size, SeedWheelPickerSize.medium);
        expect(props.enabled, isTrue);
        expect(props.readOnly, isFalse);
        final year = props.columns[0];
        final month = props.columns[1];
        expect(year.semanticsLabel, '연도');
        expect(month.semanticsLabel, '월');
        expect(year.options.map((option) => option.value), [2025, 2026, 2027]);
        expect(year.options.first.label, '2025년');
        expect(year.loop, isFalse);
        expect(month.options, hasLength(12));
        expect(month.loop, isTrue);

        // Choosing a month moves the view without selecting a day.
        await tester.tap(find.text('month:10'));
        await tester.pumpAndSettle();
        expect(find.text('2026년 3월'), findsOneWidget);
        expect(selected, isEmpty);

        // The year at the lower bound leaves out the months before March.
        await tester.tap(find.text('year:2026'));
        await tester.pumpAndSettle();
        expect(find.text('2025년 3월'), findsOneWidget);
        expect(props.columns[1].options.first.value, 3);
        expect(props.columns[1].loop, isFalse);
      });

      testWidgets('without a builder the default wheel is unchanged', (
        tester,
      ) async {
        await tester.pumpWidget(
          korean(SeedDatePicker(initialDate: DateTime(2026, 10, 25))),
        );
        await tester.tap(find.text('2026년 10월'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedWheelPicker), findsOneWidget);
      });
    });
  });
}
