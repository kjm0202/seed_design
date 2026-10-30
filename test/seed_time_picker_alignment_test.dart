import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('time picker columns keep React intrinsic widths on a wide root', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 768,
              child: SeedTimePicker(
                value: const TimeOfDay(hour: 13, minute: 10),
                minuteStep: 10,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final picker = tester.getRect(find.byType(SeedTimePicker));
    final wheels = find.byType(ListWheelScrollView);
    expect(wheels, findsNWidgets(3));
    final rects = [for (var i = 0; i < 3; i++) tester.getRect(wheels.at(i))];
    // React CSS keeps each TimePicker column flex:0 0 auto / max-content,
    // centered inside a 100%-width picker (rather than three expanded thirds).
    for (final rect in rects) {
      expect(rect.width, inInclusiveRange(55, 100));
    }
    // Font loading on Web can change text advances after the first build.
    // Keep enough room for two Korean syllables and two tabular digits.
    expect(rects[0].width, greaterThanOrEqualTo(84));
    expect(rects[1].width, greaterThanOrEqualTo(65));
    expect(rects[2].width, greaterThanOrEqualTo(65));
    expect(
      rects.first.left,
      closeTo(picker.center.dx - (rects.last.right - rects.first.left) / 2, 1),
    );
    expect(rects.last.right - rects.first.left, lessThan(250));
  });

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
                closeTo(tester.getCenter(find.byType(SeedTimePicker)).dy, 0.5),
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
}
