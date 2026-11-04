
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/official_spec.dart';

void main() {


  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: Center(
              child: SizedBox(width: 320, child: Align(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('all input sizes and variants retain official minimum heights', (
    tester,
  ) async {
    for (final scale in [1.0, 2.0]) {
      for (final size in SeedTextInputSize.values) {
        for (final variant in SeedTextInputVariant.values) {
          for (final lines in [1, 3]) {
            await mount(
              tester,
              SeedTextInput(
                key: ValueKey('$scale/$size/$variant/$lines'),
                size: size,
                variant: variant,
                maxLines: lines,
                hintText: '상품명',
              ),
              scale: scale,
            );
            final spec = lines == 1
                ? 'variant=${variant.name},size=${size.name}'
                : 'type=multiline,size=${size.name}';
            expect(
              tester.getSize(find.byType(SeedTextInput)).height,
              greaterThanOrEqualTo(
                officialProp('text-input', spec, 'root', 'minHeight'),
              ),
              reason: '$spec, text scale $scale',
            );
          }
        }
      }
    }
    await mount(tester, const SeedTextInput(hintText: '상품명'));
    expect(tester.getSize(find.byType(SeedTextInput)).height, 52);
    expect(
      tester.widget<TextField>(find.byType(TextField)).style!.fontSize,
      16,
    );
    await mount(tester, const SeedInputButton(placeholder: '선택'));
    expect(tester.getSize(find.byType(SeedInputButton)).height, 52);
    await mount(tester, const SeedSelect<int>(groups: []));
    expect(tester.getSize(find.byType(SeedInputButton)).height, 52);
  });

  testWidgets('required marks scale with labels and retain the top offset', (
    tester,
  ) async {
    for (final scale in [1.0, 2.0]) {
      await mount(
        tester,
        const SeedField(label: '상품명', required: true, child: SizedBox()),
        scale: scale,
      );
      final mark = find.descendant(
        of: find.byType(SeedField),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.size == Size.square(6 * scale),
        ),
      );
      final labelRect = tester.getRect(find.text('상품명'));
      final markRect = tester.getRect(mark);
      expect(markRect.size, Size(6 * scale, 6 * scale));
      expect(markRect.top - labelRect.top, 4 * scale);
      expect(markRect.left - labelRect.right, 2 * scale);
    }
  });
}
