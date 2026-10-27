import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

void main() {
  testWidgets(
    'opening a default continuous calendar only builds nearby months',
    (tester) async {
      var cellBuilds = 0;
      await tester.pumpWidget(
        host(
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
        host(
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
        host(
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
}
