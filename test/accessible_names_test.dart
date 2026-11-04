import 'dart:ui' show CheckedState, SemanticsAction, SemanticsRole;

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
    testWidgets('SegmentedControl semanticsLabel names its radiogroup', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: SeedSegmentedControl<int>(
              semanticsLabel: 'Sort options',
              segments: const [
                SeedSegment(value: 1, label: 'A'),
                SeedSegment(value: 2, label: 'B'),
              ],
            ),
          ),
        ),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('Sort options'));
      expect(node.role, SemanticsRole.radioGroup);
      handle.dispose();
    });

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

    testWidgets('Select trigger is named by its label or semanticsLabel', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      const groups = [
        SeedSelectGroup(
          items: [SeedSelectItem(value: 'a', label: 'Apple')],
        ),
      ];
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeedSelect<String>(
                  label: 'Fruit',
                  defaultValue: ['a'],
                  groups: groups,
                ),
                SeedSelect<String>(
                  semanticsLabel: 'Fruit large',
                  defaultValue: ['a'],
                  groups: groups,
                ),
              ],
            ),
          ),
        ),
      );
      final triggers = tester.semantics
          .simulatedAccessibilityTraversal()
          .where((node) => node.flagsCollection.isButton)
          .map((node) => (node.label, node.value))
          .toList();
      expect(triggers, [('Fruit', 'Apple'), ('Fruit large', 'Apple')]);
      handle.dispose();
    });

    testWidgets('Field label tap target is not a separate button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const SeedTextField(label: 'Name', placeholder: 'Type')),
      );
      final unnamedTaps = tester.semantics
          .simulatedAccessibilityTraversal()
          .where(
            (node) =>
                node.getSemanticsData().hasAction(SemanticsAction.tap) &&
                node.label.isEmpty,
          );
      expect(unnamedTaps, isEmpty);
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

    testWidgets('SeedPopover exposes native dialog semantics', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: SeedPopoverTrigger(
              controller: controller,
              triggerBuilder: (_, _, toggle) => TextButton(
                onPressed: toggle,
                child: const Text('Open popup'),
              ),
              builder: (_) => const SeedPopover(
                titleText: 'Accessible popup',
                body: Text('body'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open popup'));
      await tester.pumpAndSettle();
      final semantics = tester.getSemantics(find.byType(SeedPopover));
      expect(semantics.getSemanticsData().role, SemanticsRole.dialog);
      expect(semantics.getSemanticsData().label, 'Accessible popup');
      handle.dispose();
    });

    testWidgets('headerless Popover supports an explicit dialog name', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: const Scaffold(
            body: SeedPopover(
              semanticsLabel: '필터',
              body: Text('Headerless body'),
            ),
          ),
        ),
      );
      final data = tester
          .getSemantics(find.byType(SeedPopover))
          .getSemanticsData();
      expect(data.role, SemanticsRole.dialog);
      expect(data.label, '필터');
      handle.dispose();
    });

    testWidgets('SeedMenu exposes a native menu role', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: SeedMenuTrigger(
              controller: controller,
              triggerBuilder: (_, _, toggle) => TextButton(
                onPressed: toggle,
                child: const Text('Open native menu'),
              ),
              builder: (_) => const SeedMenu(
                groups: [
                  SeedMenuGroupData(
                    items: [SeedMenuItemData(label: 'Entry A')],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open native menu'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(SeedMenu)).getSemanticsData().role,
        SemanticsRole.menu,
      );
      handle.dispose();
    });

    testWidgets('Menu exposes an explicit accessible name', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: SeedMenuTrigger(
              controller: controller,
              triggerBuilder: (_, _, toggle) => TextButton(
                onPressed: toggle,
                child: const Text('Open named menu'),
              ),
              builder: (_) => const SeedMenu(
                semanticsLabel: 'Open named menu',
                groups: [
                  SeedMenuGroupData(
                    items: [SeedMenuItemData(label: 'Entry A')],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open named menu'));
      await tester.pumpAndSettle();
      final data = tester
          .getSemantics(find.byType(SeedMenu))
          .getSemanticsData();
      expect(data.role, SemanticsRole.menu);
      expect(data.label, 'Open named menu');
      handle.dispose();
    });
  });
}
