import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  Future<void> mount(WidgetTester tester, SeedQuantityPicker picker) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(body: Center(child: picker)),
      ),
    );
  }

  testWidgets('read-only quantity picker cannot activate either button', (
    tester,
  ) async {
    await mount(tester, const SeedQuantityPicker(value: 3, onChanged: null));
    final buttons = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .toList();
    expect(buttons, hasLength(2));
    expect(buttons.every((button) => !button.enabled), isTrue);
  });

  testWidgets('quantity picker limits and step prevent invalid changes', (
    tester,
  ) async {
    final changes = <int>[];
    await mount(
      tester,
      SeedQuantityPicker(
        value: 1,
        min: 1,
        max: 5,
        step: 2,
        onChanged: changes.add,
      ),
    );
    var buttons = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .toList();
    expect(buttons.first.enabled, isFalse);
    expect(buttons.last.enabled, isTrue);
    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(changes, [3]);

    expect(
      () => SeedQuantityPicker(value: 3, step: 0, onChanged: changes.add),
      throwsAssertionError,
    );
  });
}
