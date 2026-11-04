import 'dart:ui' show CheckedState, SemanticsRole;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  setUpAll(loadSeedTestFonts);

  group('Accessible names match official ARIA', () {

    testWidgets('RadioGroup and Chip.RadioRoot expose radiogroup roles', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedRadioGroup<int>(
                label: 'Contact',
                defaultValue: 1,
                child: const SeedRadio<int>(value: 1, label: 'Mail'),
              ),
              const SeedChipRadioGroup<int>(
                semanticsLabel: 'Transition style',
                defaultValue: 1,
                options: [
                  SeedChipOption(value: 1, label: 'Slide'),
                  SeedChipOption(value: 2, label: 'Fade'),
                ],
              ),
            ],
          ),
        ),
      );
      final groups = tester.semantics
          .simulatedAccessibilityTraversal()
          .where((node) => node.role == SemanticsRole.radioGroup)
          .map((node) => node.label)
          .toList();
      expect(groups, containsAll(['Contact', 'Transition style']));
      final slide = tester.getSemantics(find.bySemanticsLabel('Slide'));
      expect(slide.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(slide.flagsCollection.isChecked, CheckedState.isTrue);
      expect(slide.flagsCollection.isButton, isFalse);
      // Finders that look for SeedChip keep working inside the group.
      expect(find.byType(SeedChip), findsNWidgets(2));
      handle.dispose();
    });

    testWidgets('ListLinkItem is one link node, not link plus button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SeedListLinkItem(
            uri: Uri.parse('https://example.com'),
            titleText: 'Row',
            onTap: () {},
          ),
        ),
      );
      final rows = tester.semantics
          .simulatedAccessibilityTraversal()
          .where((node) => node.label.contains('Row'))
          .toList();
      expect(rows, hasLength(1));
      expect(rows.single.flagsCollection.isLink, isTrue);
      expect(rows.single.flagsCollection.isButton, isFalse);
      handle.dispose();
    });
  });
  group('overlay roles', () {
    setUpAll(loadSeedTestFonts);
  });
}
