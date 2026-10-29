import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  for (final size in [const Size(800, 800), const Size(390, 844)]) {
    testWidgets('React 90vh snap geometry and default fade at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final snap = SeedSheetController();
      addTearDown(snap.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedBottomSheet<void>(
                  context: context,
                  skipAnimation: true,
                  snapPoints: const [
                    SeedSheetSnapPoint.fraction(.5),
                    SeedSheetSnapPoint.fraction(.85),
                  ],
                  snapController: snap,
                  child: const SeedBottomSheet(
                    title: 'React capped sheet',
                    content: SizedBox(height: 1200),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.pump();
      final material = find.descendant(
        of: find.byType(SeedBottomSheet),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.clipBehavior == Clip.antiAlias,
        ),
      );
      final route =
          ModalRoute.of(tester.element(material))! as ModalBottomSheetRoute;
      final baseAlpha = SeedThemeData.light().colorScheme.bg.overlay.a;
      final first = tester.getRect(material);
      expect(first.top, closeTo(size.height * .6, 1.5));
      expect(first.height, closeTo(size.height * .4, 1.5));
      expect(first.width, closeTo(math.min(size.width, 480), 1));
      expect(route.barrierColor.a, closeTo(0, .0001));

      snap.snapTo(1);
      await tester.pumpAndSettle();
      await tester.pump();
      final last = tester.getRect(material);
      expect(last.top, closeTo(size.height * .25, 1.5));
      expect(last.height, closeTo(size.height * .75, 1.5));
      expect(route.barrierColor.a, closeTo(baseAlpha, .0001));
      expect(snap.index, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('MenuSheet retains group-local label alignment', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSeedMenuSheet<void>(
                context: context,
                title: 'Actions',
                showHandle: false,
                showCancelButton: false,
                groupLabelAlignments: const [TextAlign.start, TextAlign.center],
                groups: const [
                  SeedMenuGroupData(items: [SeedMenuItemData(label: 'Add')]),
                  SeedMenuGroupData(items: [SeedMenuItemData(label: 'Test1')]),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('Add')).textAlign, TextAlign.start);
    expect(tester.widget<Text>(find.text('Test1')).textAlign, TextAlign.center);
    expect(find.text('닫기'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final configuration in <(bool, bool, double)>[
    (false, true, 600),
    (false, false, 800),
    (true, true, 800),
    (true, false, 800),
  ]) {
    final (fixed, repositionInputs, expectedBottom) = configuration;
    testWidgets('Keyboard inset fixed=$fixed reposition=$repositionInputs', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(440, 800);
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedBottomSheet<void>(
                  context: context,
                  fixed: fixed,
                  repositionInputs: repositionInputs,
                  skipAnimation: true,
                  child: const SeedBottomSheet(
                    title: 'Keyboard layout',
                    content: SizedBox(height: 200),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final surface = find.descendant(
        of: find.byType(SeedBottomSheet),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.clipBehavior == Clip.antiAlias,
        ),
      );
      expect(tester.getRect(surface).bottom, closeTo(expectedBottom, 1));
      expect(tester.takeException(), isNull);
    });
  }
}
