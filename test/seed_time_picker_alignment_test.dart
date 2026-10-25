import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
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
              final paragraph = tester.renderObject<RenderParagraph>(label);
              final lineBounds = paragraph
                  .getBoxesForSelection(
                    TextSelection(
                      baseOffset: 0,
                      extentOffset: labels[i].length,
                    ),
                  )
                  .map((box) => box.toRect())
                  .reduce((a, b) => a.expandToInclude(b));
              final center = paragraph.localToGlobal(lineBounds.center);
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

          expectCentered(['오전', '9', '00']);
          for (final (column, index) in [(0, 1), (1, 9), (2, 15)]) {
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
