
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';


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
