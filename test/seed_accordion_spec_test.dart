import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

void main() {
  testWidgets('separated accordion keeps its border visible at every corner', (
    tester,
  ) async {
    final theme = SeedThemeData.dark();
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme.toThemeData(),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: const SizedBox(
                width: 200,
                child: SeedAccordionItem(
                  variant: SeedAccordionVariant.separated,
                  title: 'Corners',
                  content: SizedBox(height: 40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> expectCornerBorders() async {
      final pixels = await tester.runAsync(() async {
        final image = await tester
            .renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey))
            .toImage(pixelRatio: 3);
        try {
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          // Midpoint of the 1px stroke on each 12px radius corner.
          // At 45 degrees this lies 12 - 11.5 / sqrt(2) pixels inward.
          const inset = 11;
          return [
            for (final x in [inset, image.width - 1 - inset])
              for (final y in [inset, image.height - 1 - inset])
                bytes.getUint8((y * image.width + x) * 4),
          ];
        } finally {
          image.dispose();
        }
      });
      final strokeRed =
          (theme.colorScheme.stroke.neutralWeak.toARGB32() >> 16) & 0xff;
      for (final pixel in pixels!) {
        expect(
          pixel,
          closeTo(strokeRed, 2),
          reason: 'The rounded border must not be covered by the item surface',
        );
      }
    }

    await expectCornerBorders();
    await tester.tap(find.text('Corners'));
    await tester.pumpAndSettle();
    await expectCornerBorders();
  });

  for (final variant in SeedAccordionVariant.values) {
    testWidgets(
      'dark $variant background stays dark throughout expand and collapse',
      (tester) async {
        final theme = SeedThemeData.dark();
        final background = theme.colorScheme.bg.layerDefault;
        final pressed = Color.alphaBlend(
          theme.colorScheme.bg.transparentPressed,
          background,
        );
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme.toThemeData(),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: ColoredBox(
                    color: background,
                    child: SizedBox(
                      width: 360,
                      height: 240,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SeedAccordion(
                          variant: variant,
                          items: const [
                            SeedAccordionItem(
                              value: 'a',
                              title: 'Toggle',
                              content: SizedBox(height: 80),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        Future<void> expectDarkFrame() async {
          final pixel = await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(boundaryKey),
            );
            final image = await boundary.toImage(pixelRatio: 1);
            try {
              final bytes = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              // Sample the trigger background above its text and icons.
              final offset = (8 * image.width + 180) * 4;
              return List.generate(3, (i) => bytes.getUint8(offset + i));
            } finally {
              image.dispose();
            }
          });
          final lower = background.toARGB32();
          final upper = pressed.toARGB32();
          for (var i = 0; i < 3; i++) {
            final shift = (2 - i) * 8;
            expect(
              pixel![i],
              inInclusiveRange(
                ((lower >> shift) & 0xff) - 1,
                ((upper >> shift) & 0xff) + 1,
              ),
              reason:
                  'Press feedback must stay between the dark surface '
                  'and its composited pressed color',
            );
          }
        }

        await expectDarkFrame();
        for (final expanded in [true, false]) {
          final gesture = await tester.startGesture(
            tester.getCenter(find.text('Toggle')),
          );
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump();
          // Cover both a held press and release before feedback finishes.
          for (var frame = 0; frame < (expanded ? 5 : 1); frame++) {
            await tester.pump(const Duration(milliseconds: 30));
            await expectDarkFrame();
          }
          await gesture.up();
          await tester.pump();
          for (var frame = 0; frame < 5; frame++) {
            await tester.pump(const Duration(milliseconds: 30));
            await expectDarkFrame();
          }
          await tester.pumpAndSettle();
          expect(
            tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
            expanded,
          );
          await expectDarkFrame();
        }
      },
    );
  }

  testWidgets('group keyboard navigation skips disabled items', (tester) async {
    await tester.pumpWidget(
      _host(
        const SeedAccordion(
          items: [
            SeedAccordionItem(value: 'a', title: 'A', content: SizedBox()),
            SeedAccordionItem(
              value: 'b',
              title: 'B',
              content: SizedBox(),
              enabled: false,
            ),
            SeedAccordionItem(value: 'c', title: 'C', content: SizedBox()),
          ],
        ),
      ),
    );
    final nodes = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .map((button) => button.focusNode!)
        .toList();

    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
    expect(nodes[1].hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
  });

  testWidgets(
    'controlled item requests an expansion without mutating its state',
    (tester) async {
      final requested = <bool>[];
      Widget item(bool expanded) => _host(
        SeedAccordionItem(
          title: 'Controlled',
          content: const Text('Details'),
          expanded: expanded,
          onExpansionChanged: requested.add,
        ),
      );

      await tester.pumpWidget(item(false));
      await tester.tap(find.text('Controlled'));
      await tester.pumpAndSettle();
      expect(requested, [true]);
      expect(
        tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
        false,
      );

      await tester.pumpWidget(item(true));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
        true,
      );
      expect(requested, [true]);
    },
  );
}
