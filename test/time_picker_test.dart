import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

Widget _host(Widget child) => mui.MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: mui.Scaffold(
    body: mui.Center(child: mui.SizedBox(width: 240, child: child)),
  ),
);

void main() {
  group('default and controlled values', () {
    testWidgets(
      'TimePicker defaultValue/initialTime seed three wheel columns; dynamic step count',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const SeedTimePicker(
              initialTime: mui.TimeOfDay(hour: 13, minute: 10),
              minuteStep: 10,
            ),
          ),
        );
        final wheel = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        expect(wheel.columns.map((c) => c.itemCount).toList(), [2, 12, 6]);
        expect(wheel.columns.map((c) => c.initialIndex).toList(), [1, 1, 1]);
        await tester.pumpWidget(
          _host(
            const SeedTimePicker(
              defaultValue: mui.TimeOfDay(hour: 13, minute: 10),
              minuteStep: 15,
            ),
          ),
        );
        final next = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        expect(next.columns.map((c) => c.itemCount).toList(), [2, 12, 4]);
      },
    );

    testWidgets(
      'uncontrolled initialTime is a one-time seed, not an external controlled update',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const SeedTimePicker(
              initialTime: mui.TimeOfDay(hour: 11, minute: 20),
              minuteStep: 10,
            ),
          ),
        );
        final old = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        expect(old.columns.map((c) => c.initialIndex).toList(), [0, 11, 2]);
        await tester.pumpWidget(
          _host(
            const SeedTimePicker(
              initialTime: mui.TimeOfDay(hour: 7, minute: 40),
              minuteStep: 10,
            ),
          ),
        );
        final updated = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        expect(updated.columns.map((c) => c.initialIndex).toList(), [0, 11, 2]);
      },
    );

    testWidgets(
      'controlled TimePicker value updates selected indexes without changing wheel item counts',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const SeedTimePicker(
              value: mui.TimeOfDay(hour: 13, minute: 10),
              minuteStep: 10,
            ),
          ),
        );
        await tester.pumpWidget(
          _host(
            const SeedTimePicker(
              value: mui.TimeOfDay(hour: 15, minute: 20),
              minuteStep: 10,
            ),
          ),
        );
        final wheel = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        expect(wheel.columns.map((c) => c.itemCount).toList(), [2, 12, 6]);
        expect(wheel.columns.map((c) => c.index).toList(), [1, 3, 2]);
      },
    );
  });

  group('label alignment', () {
    setUpAll(loadSeedTestFonts);

    for (final dark in [false, true]) {
      for (final height in [220.0, 280.0]) {
        testWidgets(
          'time labels center in each wheel (dark=$dark, height=$height)',
          (tester) async {
            TimeOfDay? selected;
            final theme = dark
                ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
                : SeedThemeData.light(fontFamily: seedTestFontFamily);
            await tester.pumpWidget(
              MaterialApp(
                theme: theme.toThemeData(),
                home: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 320,
                      child: SeedTimePicker(
                        height: height,
                        locale: const Locale('ko', 'KR'),
                        onChanged: (value) => selected = value,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();

            void expectCentered(List<String> labels) {
              final wheels = find.byType(ListWheelScrollView);
              for (var i = 0; i < labels.length; i++) {
                final label = find.descendant(
                  of: wheels.at(i),
                  matching: find.text(labels[i]),
                );
                // With intrinsically sized columns the RenderParagraph's
                // selection boxes can describe only part of a composed label.
                // Measure the painted Text widget's layout center instead.
                final center = tester.getCenter(label);
                final wheelCenter = tester.getCenter(wheels.at(i));
                expect(
                  center.dx,
                  closeTo(wheelCenter.dx, 0.5),
                  reason: '${labels[i]} horizontal',
                );
                expect(
                  center.dy,
                  closeTo(wheelCenter.dy, 0.5),
                  reason: '${labels[i]} vertical',
                );
                expect(
                  center.dy,
                  closeTo(
                    tester.getCenter(find.byType(SeedTimePicker)).dy,
                    0.5,
                  ),
                );
              }
            }

            expectCentered(['오전', '12', '00']);
            for (final (column, index) in [(0, 1), (1, 10), (2, 3)]) {
              final wheel = tester.widget<ListWheelScrollView>(
                find.byType(ListWheelScrollView).at(column),
              );
              (wheel.controller! as FixedExtentScrollController).jumpToItem(
                index,
              );
              await tester.pumpAndSettle();
            }
            expectCentered(['오후', '10', '15']);
            expect(selected, const TimeOfDay(hour: 22, minute: 15));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('AM/PM', () {
    testWidgets(
      'time picker keeps rounded AMPM when moving hour from 11 to 12',
      (tester) async {
        TimeOfDay? changed;
        await tester.pumpWidget(
          seedApp(
            SeedTimePicker(
              initialTime: const TimeOfDay(hour: 11, minute: 0),
              locale: const Locale('en', 'US'),
              onChanged: (d) => changed = d,
            ),
          ),
        );
        final wheel = tester.widget<ListWheelScrollView>(
          find.byType(ListWheelScrollView).first,
        );
        final controller = wheel.controller as FixedExtentScrollController;
        controller.animateToItem(
          12,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
        await tester.pumpAndSettle();
        expect(changed, const TimeOfDay(hour: 12, minute: 0));
        final pickers = tester
            .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
            .toList();
        expect(
          (pickers[2].controller as FixedExtentScrollController).selectedItem,
          1,
        );
      },
    );
  });

  group('step and value sync', () {
    testWidgets(
      'changing time step rebuilds wheel selection and reports valid minutes',
      (tester) async {
        TimeOfDay? changed;
        int step = 1;
        await tester.pumpWidget(
          koreanAppCentered(
            StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => setState(() => step = 15),
                    child: const Text('Step'),
                  ),
                  SeedTimePicker(
                    initialTime: const TimeOfDay(hour: 9, minute: 43),
                    minuteStep: step,
                    onChanged: (v) => changed = v,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Step'));
        await tester.pumpAndSettle();
        final picker = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        expect(picker.columns.last.itemCount, 4);
        expect(picker.columns.last.initialIndex, 3);
        await tester.drag(
          find.byType(ListWheelScrollView).last,
          const Offset(0, 120),
        );
        await tester.pumpAndSettle();
        expect(changed, isNotNull);
        expect(changed!.minute % 15, 0);
        expect(changed!.minute, isNot(45));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('updating value resynchronizes all three wheel positions', (
      tester,
    ) async {
      var value = const TimeOfDay(hour: 9, minute: 5);
      late StateSetter updateParent;
      final notifications = <TimeOfDay>[];
      await tester.pumpWidget(
        koreanAppCentered(
          SizedBox(
            width: 280,
            child: StatefulBuilder(
              builder: (context, setState) {
                updateParent = setState;
                return SeedTimePicker(
                  value: value,
                  minuteStep: 10,
                  onChanged: notifications.add,
                );
              },
            ),
          ),
        ),
      );

      List<int> positions() => tester
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .map(
            (wheel) =>
                (wheel.controller! as FixedExtentScrollController).selectedItem,
          )
          .toList();

      await tester.pumpAndSettle();
      expect(positions(), [0, 9, 1]); // 오전 9시 10분, 5분은 React처럼 올림.

      updateParent(() => value = const TimeOfDay(hour: 15, minute: 54));
      await tester.pumpAndSettle();
      expect(positions(), [1, 3, 5]); // 오후 3시 50분.
      expect(
        notifications,
        isEmpty,
      ); // External input updates are not user edits.
      expect(tester.takeException(), isNull);
    });
  });

  group('validation', () {
    testWidgets('invalid minute steps fail immediately', (tester) async {
      await tester.pumpWidget(
        koreanAppCentered(const SeedTimePicker(minuteStep: 0)),
      );
      expect(tester.takeException(), isArgumentError);
    });
  });

  group('locale column order', () {
    Widget pickerHost(Widget child) => MaterialApp(
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(child: SizedBox(width: 720, child: child)),
      ),
    );

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
      final picker = tester.widget<SeedWheelPicker>(
        find.byType(SeedWheelPicker),
      );
      expect(picker.columns.map((column) => column.itemCount).toList(), [
        12,
        12,
        2,
      ]);
    });
  });
}
