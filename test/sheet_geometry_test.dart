import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('React pixel snap re-resolves at 390x844 → 800x800 → 390x844', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final snap = SeedSheetController();
    addTearDown(snap.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: SeedSnappingBottomSheet(
            handleOnly: true,
            contentHeightFraction: .9,
            controller: snap,
            snapPoints: const [
              SeedSheetSnapPoint.pixels(360),
              SeedSheetSnapPoint.fraction(.85),
            ],
            sheet: const SeedBottomSheet(
              title: 'Resize snap',
              content: SizedBox(height: 1200),
            ),
          ),
        ),
      ),
    );
    final surface = find.descendant(
      of: find.byType(SeedSnappingBottomSheet),
      matching: find.byType(AnimatedContainer),
    );

    await tester.pumpAndSettle();
    // The React max-height=90vh surface exposes 360px - 10vh at a pixel snap.
    expect(tester.getSize(surface).height, closeTo(360 - 84.4, 1));
    tester.view.physicalSize = const Size(800, 800);
    await tester.pumpAndSettle();
    expect(tester.getSize(surface).height, closeTo(360 - 80, 1));

    snap.snapTo(1);
    await tester.pumpAndSettle();
    expect(snap.index, 1);
    expect(tester.getSize(surface).height, closeTo(800 * .75, 1));
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(tester.getSize(surface).height, closeTo(844 * .75, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag-enabled modal preserves physical pixel snap on resize', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
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
                snapController: snap,
                snapPoints: const [
                  SeedSheetSnapPoint.pixels(360),
                  SeedSheetSnapPoint.fraction(.85),
                ],
                child: const SeedBottomSheet(
                  title: 'Pixel snap',
                  content: SizedBox(height: 1200),
                ),
              ),
              child: const Text('Open sheet'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    DraggableScrollableController drag() => tester
        .widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet))
        .controller!;
    expect(drag().size, closeTo(360 / 844 - .1, .005));
    tester.view.physicalSize = const Size(800, 800);
    await tester.pumpAndSettle();
    expect(drag().size, closeTo(360 / 800 - .1, .005));
    expect(snap.index, 0);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(390, 844), const Size(800, 800)]) {
    for (final swipeable in [false, true]) {
      testWidgets('MenuSheet drawer=$swipeable top spacing at $size', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
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
                    enableDrag: swipeable,
                    showHandle: false,
                    showCancelButton: false,
                    groups: const [
                      SeedMenuGroupData(
                        items: [SeedMenuItemData(label: 'Add')],
                      ),
                    ],
                  ),
                  child: const Text('Open menu'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open menu'));
        await tester.pumpAndSettle();
        final root = find
            .descendant(
              of: find.byType(SeedMenuSheet),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Material &&
                    widget.clipBehavior == Clip.antiAlias &&
                    widget.borderRadius is BorderRadius,
              ),
            )
            .first;
        expect(
          tester.getTopLeft(find.text('Actions')).dy -
              tester.getTopLeft(root).dy,
          closeTo(swipeable ? 24 : 16, .5),
        );
        expect(tester.takeException(), isNull);
      });
    }

    for (final fromRight in [true, false]) {
      testWidgets(
        'SidePanel official 80vw cap and edge at $size right=$fromRight',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showSeedSidePanel<void>(
                      context: context,
                      title: 'Side Panel',
                      body: const SizedBox(height: 50),
                      size: SeedSidePanelSize.medium,
                      fromRight: fromRight,
                    ),
                    child: const Text('Open panel'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open panel'));
          await tester.pumpAndSettle();
          final surface = find
              .descendant(
                of: find.byType(SeedSidePanel),
                matching: find.byType(Material),
              )
              .first;
          final rect = tester.getRect(surface);
          final cap = size.width * .8;
          expect(rect.width, closeTo(cap, 1));
          expect(rect.left, closeTo(fromRight ? size.width - cap : 0, 1));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
