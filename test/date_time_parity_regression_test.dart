import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget pickerHost(Widget child) => MaterialApp(
  locale: const Locale('en', 'US'),
  supportedLocales: const [Locale('en', 'US')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 720, child: child)),
  ),
);

void main() {
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
        .ancestor(of: find.text('January 2027'), matching: find.byType(Column))
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

  testWidgets('British 12-hour columns place period after minutes', (
    tester,
  ) async {
    await tester.pumpWidget(
      pickerHost(
        const SeedTimePicker(
          locale: Locale('en', 'GB'),
          value: TimeOfDay(hour: 15, minute: 5),
        ),
      ),
    );
    final picker = tester.widget<SeedWheelPicker>(find.byType(SeedWheelPicker));
    expect(picker.columns.map((column) => column.itemCount).toList(), [
      12,
      12,
      2,
    ]);
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
    final picker = tester.widget<SeedWheelPicker>(find.byType(SeedWheelPicker));
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
}
