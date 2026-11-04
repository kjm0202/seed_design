import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
testWidgets('a snapping sheet footer follows the body content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: SeedBottomSheetTrigger(
            snapPoints: const [
              SeedSheetSnapPoint.fraction(.4),
              SeedSheetSnapPoint.fraction(1),
            ],
            triggerBuilder: (_, open, toggle) =>
                TextButton(onPressed: toggle, child: const Text('Open')),
            builder: (_) => const SeedBottomSheet(
              title: 'Sheet',
              content: SizedBox(height: 80, child: Text('Body')),
              footer: Text('Footer note'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final body = tester.getRect(find.text('Body'));
    final footer = tester.getRect(find.text('Footer note'));
    // Body (80px box) is followed directly by the footer, not pushed to the
    // bottom of the expanded sheet viewport.
    expect(footer.top - body.top, lessThan(80 + 60));
  });
}
