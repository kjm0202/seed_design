import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(
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
double _opacityOf(WidgetTester tester, String text) => tester
    .widget<FadeTransition>(
      find
          .ancestor(of: find.text(text), matching: find.byType(FadeTransition))
          .first,
    )
    .opacity
    .value;

void _expectVisible(List<int> days, {List<int> hidden = const []}) {
  for (final day in days) {
    expect(find.text('$day'), findsOneWidget, reason: 'day $day');
  }
  for (final day in hidden) {
    expect(find.text('$day'), findsNothing, reason: 'day $day');
  }
}

void main() {
  group('two-week navigation', () {
    testWidgets('reaches both month bounds using the visible week start', (
      tester,
    ) async {
      final views = <DateTime>[];
      await tester.pumpWidget(
        _host(
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
      _expectVisible([26, 31, 1, 8], hidden: [25]);
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
        _host(
          SeedDatePicker(
            visibleRange: SeedDatePickerLayout.twoWeeks,
            defaultViewDate: DateTime(2026, 7, 1),
            weekStartsOn: DateTime.sunday,
            onViewDateChange: views.add,
          ),
        ),
      );
      expect(find.text('2026년 7월'), findsOneWidget);
      _expectVisible([28, 29, 30, 1, 5, 11], hidden: [12, 27]);
      expect(find.byTooltip('이전 2주'), findsOneWidget);
      expect(find.byTooltip('다음 2주'), findsOneWidget);

      await tester.tap(find.byTooltip('다음 2주'));
      await tester.pumpAndSettle();
      expect(views, [DateTime(2026, 7, 12)]);
      _expectVisible([12, 18, 19, 25], hidden: [11, 26]);
      expect(find.text('2026년 7월'), findsOneWidget);

      await tester.tap(find.byTooltip('이전 2주'));
      await tester.pumpAndSettle();
      expect(views.last, DateTime(2026, 6, 28));
      _expectVisible([28, 11], hidden: [12]);
    });

    testWidgets('PageDown and PageUp move focus and view by two weeks', (
      tester,
    ) async {
      final views = <DateTime>[];
      final values = <DateTime?>[];
      await tester.pumpWidget(
        _host(
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
      _expectVisible([26, 31, 1, 8], hidden: [25, 9]);
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
        _host(
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
        _host(
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
        _host(
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
        _host(
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
        _host(
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
      _host(
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

    testWidgets('falls back inside the navigable month bounds', (tester) async {
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
      _host(
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
      _host(
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
      expect(_opacityOf(tester, '14'), 1);
      await tester.tap(find.text('14'));
      await tester.pump();
      expect(values, [DateTime(2026, 7, 14)]);
      expect(_opacityOf(tester, '14'), 1);
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
      expect(_opacityOf(tester, '30'), 0);
      expect(tester.getSize(find.byType(SeedDatePicker)), size);
      // New rows are announced and tappable while still entering.
      expect(find.bySemanticsLabel('2026년 7월 30일'), findsOneWidget);
      await tester.tap(find.text('30'));
      await tester.pump(const Duration(milliseconds: 150));
      expect(values, [DateTime(2026, 7, 30)]);
      final opacity = _opacityOf(tester, '30');
      expect(opacity, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      final end = tester.getCenter(find.text('30'));
      expect(start.dx - end.dx, moreOrLessEquals(20));
      expect(start.dy, end.dy);
      expect(_opacityOf(tester, '30'), 1);
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
      expect(_opacityOf(tester, '30'), 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(_opacityOf(tester, '30'), inExclusiveRange(0, 1));
      expect(tester.getCenter(find.text('30')), start);
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('30')), start);
      expect(_opacityOf(tester, '30'), 1);
    });

    testWidgets('consecutive moves restart the entrance', (tester) async {
      await pumpPicker(tester);
      await tester.tap(find.byTooltip('다음 2주'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_opacityOf(tester, '30'), greaterThan(0.5));
      await tester.tap(find.byTooltip('다음 2주'));
      await tester.pump();
      expect(_opacityOf(tester, '9'), 0);
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
      expect(_opacityOf(tester, '30'), 0);

      await pumpPicker(tester, layout: SeedDatePickerLayout.month);
      expect(_opacityOf(tester, '15'), 1);
    });

    testWidgets('month and week layouts animate but keep their steps', (
      tester,
    ) async {
      final views = <DateTime>[];
      await tester.pumpWidget(
        _host(
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
      expect(_opacityOf(tester, '19'), 0);
      await tester.pumpAndSettle();
      expect(views, [DateTime(2026, 7, 19)]);
      _expectVisible([19, 25], hidden: [18, 26]);

      views.clear();
      await tester.pumpWidget(
        _host(
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
      expect(_opacityOf(tester, '15'), 0);
      await tester.pumpAndSettle();
      expect(views, [DateTime(2026, 8)]);
      expect(find.text('2026년 8월'), findsOneWidget);
      expect(_opacityOf(tester, '15'), 1);
    });
  });
}
