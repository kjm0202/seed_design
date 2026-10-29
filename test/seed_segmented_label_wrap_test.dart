import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  testWidgets(
    'long labels wrap fully and remain selectable at phone widths and text scales',
    (tester) async {
      for (final scale in [1.0, 1.5, 2.0]) {
        String? selected;
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: Center(
                child: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: SizedBox(
                    width: 358,
                    child: SeedSegmentedControl<String>(
                      key: ValueKey(scale),
                      defaultValue: '1',
                      onValueChange: (value) => selected = value,
                      segments: const [
                        SeedSegment(value: '1', label: '가격 높은 순'),
                        SeedSegment(value: '2', label: '할인율 높은 순'),
                        SeedSegment(value: '3', label: '인기 많은 순'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final label in ['가격 높은 순', '할인율 높은 순', '인기 많은 순']) {
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(label),
          );
          expect(paragraph.didExceedMaxLines, false);
          expect(
            tester
                .getRect(find.byType(SeedSegmentedControl<String>))
                .contains(tester.getCenter(find.text(label))),
            true,
          );
        }
        await tester.tap(find.text('할인율 높은 순'));
        await tester.pumpAndSettle();
        expect(selected, '2');
        expect(tester.takeException(), isNull);
      }
    },
  );
}
