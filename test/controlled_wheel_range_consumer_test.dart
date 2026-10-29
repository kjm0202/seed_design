// Isolated Flutter PUBLIC SeedWheelPicker consumer contract: controlled date
// boundary changes from 31-day month to 28-day month and back. This is not a
// React/Flutter browser parity result or an original INC resolution.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final viewport in const [Size(800, 800), Size(390, 844)]) {
    testWidgets('controlled Wheel 31→28 day range and back $viewport', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var month = 8;
      var day = 31;
      final changeEvents = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  SizedBox(
                    width: 360,
                    child: SeedWheelPicker(
                      columns: [
                        SeedWheelColumn.value<int>(
                          items: [for (var year = 2020; year <= 2030; year++) year],
                          value: 2026,
                          semanticsLabel: '연도',
                          onValueChange: (value, _) => changeEvents.add('year=$value'),
                        ),
                        SeedWheelColumn.value<int>(
                          items: [for (var m = 1; m <= 12; m++) m],
                          value: month,
                          loop: true,
                          semanticsLabel: '월',
                          onValueChange: (value, _) => changeEvents.add('month=$value'),
                        ),
                        SeedWheelColumn.value<int>(
                          items: [for (var d = 1; d <= (month == 2 ? 28 : 31); d++) d],
                          value: day,
                          loop: true,
                          semanticsLabel: '일',
                          onValueChange: (value, _) => changeEvents.add('day=$value'),
                        ),
                      ],
                    ),
                  ),
                  SeedButton(
                    key: const ValueKey('to-feb'),
                    label: '2월로 변경',
                    onPressed: () => setState(() {
                      month = 2;
                      if (day > 28) day = 28;
                    }),
                  ),
                  SeedButton(
                    key: const ValueKey('to-aug'),
                    label: '8월로 변경',
                    onPressed: () => setState(() => month = 8),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      List<int> indexes() => tester
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .map((w) => (w.controller! as FixedExtentScrollController).selectedItem)
          .toList();

      await tester.pumpAndSettle();
      expect(indexes(), [6, 7, 30], reason: '2026-08-31 initial public value');
      expect(changeEvents, isEmpty, reason: 'mount does not simulate user edit');

      await tester.tap(find.byKey(const ValueKey('to-feb')));
      await tester.pumpAndSettle();
      expect(indexes(), [6, 1, 27], reason: 'Feb 2026 has 28 days; day 31 clamps to 28');
      expect(changeEvents, isEmpty, reason: 'parent-controlled update is not user wheel input');

      await tester.tap(find.byKey(const ValueKey('to-aug')));
      await tester.pumpAndSettle();
      expect(indexes(), [6, 7, 27], reason: 're-expand 31-day options; preserve selected day 28');
      expect(changeEvents, isEmpty, reason: 'no spurious callback on range expansion');
      expect(tester.takeException(), isNull);
    });
  }
}
