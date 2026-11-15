import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

const _orderedFallbacks = <SeedOverlaySide>[
  SeedOverlaySide.right,
  SeedOverlaySide.left,
  SeedOverlaySide.top,
  SeedOverlaySide.bottom,
];

const _allSides = <SeedOverlaySide>[
  SeedOverlaySide.right,
  SeedOverlaySide.left,
  SeedOverlaySide.top,
  SeedOverlaySide.bottom,
];

Future<(SeedOverlaySide?, Offset?, Size)> _position(
  WidgetTester tester, {
  required Size viewport,
  required Rect anchor,
  required Size popup,
  SeedOverlaySide side = SeedOverlaySide.right,
  SeedOverlayAlign align = SeedOverlayAlign.center,
  List<SeedOverlaySide>? fallbacks = _allSides,
  bool flip = true,
  bool shift = true,
  TextDirection textDirection = TextDirection.ltr,
  double gap = 8,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  SeedOverlaySide? resolved;
  Offset? position;
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: CustomSingleChildLayout(
            delegate: SeedOverlayPositionDelegate(
              anchor: anchor,
              side: side,
              align: align,
              gap: gap,
              flip: flip,
              flipFallbackSides: fallbacks,
              shift: shift,
              textDirection: textDirection,
              insets: const EdgeInsets.all(16),
              onResolved: (value) => resolved = value,
              onPosition: (offset, _) => position = offset,
            ),
            child: SizedBox(
              key: const ValueKey('floating-child'),
              width: popup.width,
              height: popup.height,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return (
    resolved,
    position,
    tester.getSize(find.byKey(const ValueKey('floating-child'))),
  );
}

const _ordered = [
  SeedOverlaySide.right,
  SeedOverlaySide.left,
  SeedOverlaySide.top,
  SeedOverlaySide.bottom,
];

void main() {
  group('ordered flip fallback', () {
    setUpAll(loadSeedTestFonts);

    for (final viewport in [const Size(320, 640), const Size(390, 740)]) {
      testWidgets('ordered flip: cramped right/left chooses top at $viewport', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.reset);
        final anchor = Rect.fromLTWH(
          (viewport.width - 60) / 2,
          viewport.height / 2,
          60,
          32,
        );
        expect(anchor.left - 16 - 4, lessThan(220));
        expect(viewport.width - 16 - anchor.right - 4, lessThan(220));
        expect(anchor.top - 16 - 4, greaterThanOrEqualTo(100));
        SeedOverlaySide? resolved;
        Offset? placed;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomSingleChildLayout(
                delegate: SeedOverlayPositionDelegate(
                  anchor: anchor,
                  side: SeedOverlaySide.right,
                  gap: 4,
                  flip: true,
                  flipFallbackSides: _orderedFallbacks,
                  insets: const EdgeInsets.all(16),
                  onResolved: (value) => resolved = value,
                  onPosition: (offset, size) => placed = offset,
                ),
                child: const SizedBox(width: 220, height: 100),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(resolved, SeedOverlaySide.top);
        expect(placed!.dy, closeTo(anchor.top - 104, .01));
        expect(placed!.dx, greaterThanOrEqualTo(16));
        expect(placed!.dx + 220, lessThanOrEqualTo(viewport.width - 16));
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'ordered flip: top insufficient chooses bottom at $viewport',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport;
          addTearDown(tester.view.reset);
          final anchor = Rect.fromLTWH((viewport.width - 60) / 2, 60, 60, 32);
          expect(anchor.left - 16 - 4, lessThan(220));
          expect(viewport.width - 16 - anchor.right - 4, lessThan(220));
          expect(anchor.top - 16 - 4, lessThan(100));
          expect(viewport.height - 16 - anchor.bottom - 4, greaterThan(100));
          SeedOverlaySide? resolved;
          Offset? placed;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CustomSingleChildLayout(
                  delegate: SeedOverlayPositionDelegate(
                    anchor: anchor,
                    side: SeedOverlaySide.right,
                    gap: 4,
                    flipFallbackSides: _orderedFallbacks,
                    insets: const EdgeInsets.all(16),
                    onResolved: (value) => resolved = value,
                    onPosition: (offset, size) => placed = offset,
                  ),
                  child: const SizedBox(width: 220, height: 100),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(resolved, SeedOverlaySide.bottom);
          expect(placed!.dy, closeTo(anchor.bottom + 4, .01));
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('old default bool flip remains opposite-only', (tester) async {
      tester.view.physicalSize = const Size(390, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SeedOverlaySide? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSingleChildLayout(
              delegate: SeedOverlayPositionDelegate(
                anchor: const Rect.fromLTWH(300, 340, 48, 32),
                side: SeedOverlaySide.right,
                flip: true,
                insets: const EdgeInsets.all(16),
                onResolved: (side) => resolved = side,
              ),
              child: const SizedBox(width: 200, height: 100),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(resolved, SeedOverlaySide.left);
      expect(tester.takeException(), isNull);
    });

    testWidgets('flip=false ignores explicit fallback candidates', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SeedOverlaySide? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSingleChildLayout(
              delegate: SeedOverlayPositionDelegate(
                anchor: const Rect.fromLTWH(130, 310, 60, 32),
                side: SeedOverlaySide.right,
                flip: false,
                flipFallbackSides: _orderedFallbacks,
                insets: const EdgeInsets.all(16),
                onResolved: (value) => resolved = value,
              ),
              child: const SizedBox(width: 220, height: 100),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(resolved, SeedOverlaySide.right);
      expect(tester.takeException(), isNull);
    });

    testWidgets('public HelpBubbleTrigger forwards ordered fallback & arrow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Center(
              child: SeedHelpBubbleTrigger(
                title: 'Width adjust',
                description:
                    'A fairly long tooltip to occupy more than either side.',
                side: SeedOverlaySide.right,
                flipFallbackSides: _orderedFallbacks,
                showCloseButton: false,
                skipAnimation: true,
                triggerBuilder: (context, open, toggle) =>
                    TextButton(onPressed: toggle, child: const Text('Trigger')),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      final bubble = tester.widget<SeedHelpBubble>(find.byType(SeedHelpBubble));
      expect(bubble.arrowPlacement, SeedHelpBubbleArrowPlacement.bottom);
      expect(
        SeedOverlayScope.maybeOf(tester.element(find.byType(SeedHelpBubble)))!
            .side,
        SeedOverlaySide.top,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('placement and shift', () {
    setUpAll(loadSeedTestFonts);
    for (final width in [320.0, 390.0, 800.0]) {
      final viewport = Size(width, 640);
      testWidgets(
        'ordered right/left/top/bottom uses perpendicular sides $width',
        (tester) async {
          addTearDown(tester.view.reset);
          final popup = Size(width * .55, 120);
          final center = Rect.fromCenter(
            center: Offset(width / 2, 310),
            width: 60,
            height: 32,
          );
          final scenarios =
              <(SeedOverlaySide, List<SeedOverlaySide>, Rect, SeedOverlaySide)>[
                (SeedOverlaySide.right, _allSides, center, SeedOverlaySide.top),
                (
                  SeedOverlaySide.left,
                  const [
                    SeedOverlaySide.left,
                    SeedOverlaySide.right,
                    SeedOverlaySide.bottom,
                    SeedOverlaySide.top,
                  ],
                  center,
                  SeedOverlaySide.bottom,
                ),
                (
                  SeedOverlaySide.top,
                  const [
                    SeedOverlaySide.top,
                    SeedOverlaySide.bottom,
                    SeedOverlaySide.left,
                    SeedOverlaySide.right,
                  ],
                  Rect.fromLTWH(width / 2 - 30, 28, 60, 32),
                  SeedOverlaySide.bottom,
                ),
                (
                  SeedOverlaySide.bottom,
                  const [
                    SeedOverlaySide.bottom,
                    SeedOverlaySide.top,
                    SeedOverlaySide.right,
                    SeedOverlaySide.left,
                  ],
                  Rect.fromLTWH(width / 2 - 30, 570, 60, 32),
                  SeedOverlaySide.top,
                ),
              ];
          for (final (requested, list, anchor, expected) in scenarios) {
            final (resolved, location, actual) = await _position(
              tester,
              viewport: viewport,
              anchor: anchor,
              popup: popup,
              side: requested,
              fallbacks: list,
            );
            expect(resolved, expected, reason: '$requested at width $width');
            expect(location!.dx, greaterThanOrEqualTo(16));
            expect(location.dx + actual.width, lessThanOrEqualTo(width - 16));
            expect(location.dy, greaterThanOrEqualTo(16));
            expect(location.dy + actual.height, lessThanOrEqualTo(624));
            expect(tester.takeException(), isNull);
          }
        },
      );

      for (final align in [SeedOverlayAlign.start, SeedOverlayAlign.end]) {
        testWidgets('vertical $align cross-axis shift only, $width', (
          tester,
        ) async {
          addTearDown(tester.view.reset);
          final anchor = Rect.fromLTWH(
            align == SeedOverlayAlign.start ? width - 55 : 22,
            250,
            32,
            32,
          );
          final (resolved, offset, popup) = await _position(
            tester,
            viewport: viewport,
            anchor: anchor,
            popup: const Size(180, 90),
            side: SeedOverlaySide.bottom,
            align: align,
            fallbacks: const [SeedOverlaySide.bottom],
          );
          expect(resolved, SeedOverlaySide.bottom);
          expect(
            offset!.dx,
            closeTo(
              align == SeedOverlayAlign.start ? width - 16 - popup.width : 16,
              .01,
            ),
          );
          expect(offset.dy, closeTo(anchor.bottom + 8, .01));
          expect(tester.takeException(), isNull);
        });

        testWidgets('horizontal $align cross-axis shift only, $width', (
          tester,
        ) async {
          addTearDown(tester.view.reset);
          final anchor = Rect.fromLTWH(
            20,
            align == SeedOverlayAlign.start ? 600 : 20,
            32,
            32,
          );
          final (resolved, offset, popup) = await _position(
            tester,
            viewport: viewport,
            anchor: anchor,
            popup: const Size(100, 160),
            side: SeedOverlaySide.right,
            align: align,
            fallbacks: const [SeedOverlaySide.right],
          );
          expect(resolved, SeedOverlaySide.right);
          expect(offset!.dx, closeTo(anchor.right + 8, .01));
          expect(
            offset.dy,
            closeTo(
              align == SeedOverlayAlign.start ? 624 - popup.height : 16,
              .01,
            ),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('cross-axis overflow rejects right even when main axis fits', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      const anchor = Rect.fromLTWH(70, 18, 40, 32);
      final (resolved, offset, _) = await _position(
        tester,
        viewport: const Size(320, 640),
        anchor: anchor,
        popup: const Size(160, 180),
        side: SeedOverlaySide.right,
      );
      // Right has 186px of main-axis room for 160px of content, but its
      // centered Y would start at -56. React flip() checks cross-axis collisions
      // before shift() and prefers the bottom candidate with less total overflow.
      expect(resolved, SeedOverlaySide.bottom);
      expect(offset!.dy, closeTo(anchor.bottom + 8, .01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL start/end align to directional reference edges', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      const anchor = Rect.fromLTWH(160, 180, 64, 30);
      for (final (direction, align, expectedX) in [
        (TextDirection.rtl, SeedOverlayAlign.start, 104.0),
        (TextDirection.rtl, SeedOverlayAlign.end, 160.0),
        (TextDirection.ltr, SeedOverlayAlign.start, 160.0),
        (TextDirection.ltr, SeedOverlayAlign.end, 104.0),
      ]) {
        final (resolved, offset, _) = await _position(
          tester,
          viewport: const Size(390, 640),
          anchor: anchor,
          popup: const Size(120, 70),
          side: SeedOverlaySide.bottom,
          align: align,
          textDirection: direction,
          fallbacks: const [SeedOverlaySide.bottom],
        );
        expect(resolved, SeedOverlaySide.bottom);
        expect(offset!.dx, closeTo(expectedX, .01));
        expect(offset.dy, closeTo(anchor.bottom + 8, .01));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'new resolved-side observer is notified on delegate replacement',
      (tester) async {
        tester.view.physicalSize = const Size(390, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final first = <SeedOverlaySide>[];
        final replacement = <SeedOverlaySide>[];
        Widget build(ValueChanged<SeedOverlaySide> callback) => MaterialApp(
          home: Scaffold(
            body: CustomSingleChildLayout(
              delegate: SeedOverlayPositionDelegate(
                anchor: const Rect.fromLTWH(190, 130, 40, 30),
                side: SeedOverlaySide.bottom,
                insets: const EdgeInsets.all(16),
                onResolved: callback,
              ),
              child: const SizedBox(width: 140, height: 80),
            ),
          ),
        );
        await tester.pumpWidget(build(first.add));
        await tester.pump();
        expect(first, [SeedOverlaySide.bottom]);
        await tester.pumpWidget(build(replacement.add));
        await tester.pump();
        expect(replacement, [SeedOverlaySide.bottom]);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('shift never pulls a failed main axis across its anchor', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      const anchor = Rect.fromLTWH(271, 190, 32, 32);
      final (resolved, offset, _) = await _position(
        tester,
        viewport: const Size(320, 640),
        anchor: anchor,
        popup: const Size(80, 90),
        side: SeedOverlaySide.right,
        fallbacks: const [],
        flip: false,
      );
      // floating shift({mainAxis:true}) shifts perpendicular to the placement:
      // here Y, not X. The requested right side stays beyond the anchor.
      expect(resolved, SeedOverlaySide.right);
      expect(offset!.dx, closeTo(anchor.right + 8, .01));
    });

    testWidgets('excessively long floating content is viewport constrained', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      final (resolved, offset, popup) = await _position(
        tester,
        viewport: const Size(320, 400),
        anchor: const Rect.fromLTWH(135, 176, 50, 32),
        popup: const Size(600, 900),
        side: SeedOverlaySide.right,
      );
      expect(popup.width, lessThanOrEqualTo(288));
      expect(popup.height, lessThanOrEqualTo(368));
      expect(resolved, isNotNull);
      expect(offset, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolling a live anchor updates placement without closing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 350),
                  SeedHelpBubbleTrigger(
                    controller: controller,
                    title: 'Scrollable anchor',
                    side: SeedOverlaySide.right,
                    flipFallbackSides: _allSides,
                    closeOnInteractOutside: false,
                    skipAnimation: true,
                    showCloseButton: false,
                    triggerBuilder: (context, open, toggle) => TextButton(
                      onPressed: toggle,
                      child: const Text('Anchored trigger'),
                    ),
                  ),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Anchored trigger'));
      await tester.pumpAndSettle();
      final bubble = find.byType(SeedHelpBubble);
      final before = tester.getRect(bubble);
      expect(controller.isOpen, isTrue);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -96),
      );
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      expect(find.byType(SeedHelpBubble), findsOneWidget);
      final after = tester.getRect(bubble);
      expect(after.top, lessThan(before.top - 60));
      expect(tester.takeException(), isNull);
    });

    for (final width in [320.0, 390.0, 800.0]) {
      testWidgets('long Popover body scrolls inside safe viewport at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 536,
                    child: SeedPopoverTrigger(
                      controller: controller,
                      side: SeedOverlaySide.bottom,
                      maxHeight: 600,
                      autoFocus: false,
                      triggerBuilder: (context, open, toggle) => TextButton(
                        onPressed: toggle,
                        child: const Text('Long body trigger'),
                      ),
                      builder: (context) => SeedPopover(
                        titleText: 'Long scrollable content',
                        footer: const Text('Pinned footer action'),
                        body: Column(
                          children: [
                            for (var row = 0; row < 40; row++)
                              Text('Scrollable item $row'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Long body trigger'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        final popup = find.byType(SeedPopover);
        expect(popup, findsOneWidget);
        final rect = tester.getRect(popup);
        expect(rect.left, greaterThanOrEqualTo(15.5));
        expect(rect.right, lessThanOrEqualTo(width - 15.5));
        expect(rect.top, greaterThanOrEqualTo(15.5));
        expect(rect.bottom, lessThanOrEqualTo(624.5));
        expect(find.text('Pinned footer action'), findsOneWidget);
        final descendants = find.descendant(
          of: popup,
          matching: find.byType(Scrollable),
        );
        expect(descendants, findsWidgets);
        expect(
          tester
              .state<ScrollableState>(descendants.first)
              .position
              .maxScrollExtent,
          greaterThan(0),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('popover Escape closes and restores trigger focus', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final focus = FocusNode();
      final controller = SeedOverlayController();
      addTearDown(focus.dispose);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Center(
              child: SeedPopoverTrigger(
                controller: controller,
                triggerBuilder: (context, open, toggle) => TextButton(
                  focusNode: focus,
                  onPressed: toggle,
                  child: const Text('Open floating'),
                ),
                builder: (context) => const SeedPopover(
                  titleText: 'Floating title',
                  body: Text('Floating body'),
                ),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.tap(find.text('Open floating'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      expect(find.byType(SeedPopover), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
      expect(focus.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('constrained anchors', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'single trigger respects a tight 40px height with textScaler 2.5',
      (tester) async {
        tester.view.physicalSize = const Size(640, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 220,
                    height: 40,
                    child: SeedAnchoredOverlay(
                      controller: controller,
                      skipAnimation: true,
                      triggerBuilder: (context, open, toggle) => SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: toggle,
                          child: const Text('Tall trigger text'),
                        ),
                      ),
                      overlayBuilder: (_) =>
                          const SizedBox(width: 100, height: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final triggerRect = tester.getRect(find.text('Tall trigger text'));
        expect(triggerRect.top, greaterThanOrEqualTo(0));
        expect(triggerRect.bottom, lessThanOrEqualTo(40));
        await tester.tap(find.text('Tall trigger text'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('explicit anchor remains a separate positioned reference', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, top: 120),
                child: SeedAnchoredOverlay(
                  controller: controller,
                  skipAnimation: true,
                  gap: 8,
                  flip: false,
                  shift: false,
                  anchor: const SizedBox(
                    key: ValueKey('explicit-reference'),
                    width: 150,
                    height: 12,
                  ),
                  triggerBuilder: (context, open, toggle) => TextButton(
                    onPressed: toggle,
                    child: const Text('Separate trigger'),
                  ),
                  overlayBuilder: (_) => const SizedBox(
                    width: 120,
                    height: 60,
                    child: Text('Separate overlay'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final anchor = tester.getRect(
        find.byKey(const ValueKey('explicit-reference')),
      );
      final trigger = tester.getRect(find.text('Separate trigger'));
      expect(trigger.top, greaterThanOrEqualTo(anchor.bottom));
      await tester.tap(find.text('Separate trigger'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      final popup = tester.getRect(find.text('Separate overlay'));
      expect(popup.top, closeTo(anchor.bottom + 8, 0.1));
      expect(tester.takeException(), isNull);
    });
  });

  group('open floating layer follows its anchor', () {
    setUpAll(loadSeedTestFonts);

    for (final width in [320.0, 390.0, 800.0]) {
      testWidgets(
        'open HelpBubble ordered flip constrains tall, scaled content to a real side at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 320);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final controller = SeedOverlayController();
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
                child: Scaffold(
                  body: Stack(
                    children: [
                      Positioned(
                        top: 142,
                        left: width / 2 - 24,
                        child: SeedHelpBubbleTrigger(
                          controller: controller,
                          side: SeedOverlaySide.right,
                          flipFallbackSides: _ordered,
                          closeOnInteractOutside: false,
                          skipAnimation: true,
                          title: 'Expanded long title 1234567890',
                          description:
                              'Extended descriptive text wraps onto many lines'
                              ' when large type is used in small windows.',
                          triggerBuilder: (context, open, toggle) => TextButton(
                            onPressed: toggle,
                            child: const Text('Show help'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Show help'));
          await tester.pumpAndSettle();
          expect(controller.isOpen, isTrue);
          expect(tester.takeException(), isNull);
          final bubble = find.byType(SeedHelpBubble);
          expect(bubble, findsOneWidget);
          final rect = tester.getRect(bubble);
          expect(rect.width, lessThanOrEqualTo(width - 32));
          expect(rect.height, lessThanOrEqualTo(288));
          expect(rect.left, greaterThanOrEqualTo(15.9));
          expect(rect.right, lessThanOrEqualTo(width - 15.9));
          expect(rect.top, greaterThanOrEqualTo(15.9));
          expect(rect.bottom, lessThanOrEqualTo(304.1));
          final scrollable = find.descendant(
            of: bubble,
            matching: find.byType(Scrollable),
          );
          expect(scrollable, findsOneWidget);
          final position = tester.state<ScrollableState>(scrollable).position;
          expect(position.maxScrollExtent, greaterThan(0));
          position.jumpTo(position.maxScrollExtent);
          await tester.pump();
          expect(controller.isOpen, isTrue);
          expect(find.textContaining('when large type'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('open HelpBubble follows an animated anchor layout shift', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      final move = ValueNotifier(false);
      addTearDown(move.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Stack(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: move,
                  builder: (context, shifted, _) => AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    top: shifted ? 320 : 180,
                    left: 165,
                    child: SeedHelpBubbleTrigger(
                      controller: controller,
                      title: 'Follow moving anchor',
                      side: SeedOverlaySide.bottom,
                      flipFallbackSides: _ordered,
                      showCloseButton: false,
                      closeOnInteractOutside: false,
                      skipAnimation: true,
                      triggerBuilder: (context, open, toggle) => TextButton(
                        onPressed: toggle,
                        child: const Text('Moving target'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Moving target'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      final initial = tester.getRect(find.byType(SeedHelpBubble));
      final anchorBefore = tester.getRect(find.text('Moving target'));
      move.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      final anchorAfter = tester.getRect(find.text('Moving target'));
      final after = tester.getRect(find.byType(SeedHelpBubble));
      expect(anchorAfter.top - anchorBefore.top, closeTo(140, 1));
      expect(after.top - initial.top, closeTo(140, 4));
      expect(controller.isOpen, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'open HelpBubble tracks intrinsic anchor resize on active frames',
      (tester) async {
        tester.view.physicalSize = const Size(390, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        final wide = ValueNotifier(false);
        addTearDown(controller.dispose);
        addTearDown(wide.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: 220,
                    left: 95,
                    child: SeedHelpBubbleTrigger(
                      controller: controller,
                      title: 'Resize anchor',
                      side: SeedOverlaySide.bottom,
                      flip: false,
                      showCloseButton: false,
                      closeOnInteractOutside: false,
                      skipAnimation: true,
                      triggerBuilder: (context, open, toggle) =>
                          ValueListenableBuilder<bool>(
                            valueListenable: wide,
                            builder: (context, isWide, _) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isWide ? 160 : 80,
                              height: 44,
                              child: TextButton(
                                onPressed: toggle,
                                child: const Text('Resizing'),
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Resizing'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        final first = tester.getRect(find.byType(SeedHelpBubble));
        wide.value = true;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 220));
        await tester.pumpAndSettle();
        final after = tester.getRect(find.byType(SeedHelpBubble));
        expect(after.center.dx - first.center.dx, closeTo(40, 1));
        expect(controller.isOpen, isTrue);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'open Popover respects RTL start and Escape focus at large scale',
      (tester) async {
        tester.view.physicalSize = const Size(390, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        final triggerFocus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(triggerFocus.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: Stack(
                    children: [
                      Positioned(
                        top: 120,
                        left: 200,
                        child: SeedPopoverTrigger(
                          controller: controller,
                          side: SeedOverlaySide.bottom,
                          align: SeedOverlayAlign.start,
                          triggerBuilder: (context, open, toggle) => TextButton(
                            focusNode: triggerFocus,
                            onPressed: toggle,
                            child: const Text('RTL trigger'),
                          ),
                          builder: (context) => const SeedPopover(
                            titleText: 'Localized title',
                            body: Text('Readable content'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        triggerFocus.requestFocus();
        await tester.pump();
        await tester.tap(find.text('RTL trigger'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        final popover = tester.getRect(find.byType(SeedPopover));
        final anchor = tester.getRect(
          find.ancestor(
            of: find.text('RTL trigger'),
            matching: find.byType(TextButton),
          ),
        );
        expect(popover.right, closeTo(anchor.right, 0.5));
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(controller.isOpen, isFalse);
        expect(triggerFocus.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('open RTL end alignment stays at reference start edge', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: 200,
                    left: 32,
                    child: SeedPopoverTrigger(
                      controller: controller,
                      side: SeedOverlaySide.bottom,
                      align: SeedOverlayAlign.end,
                      triggerBuilder: (context, open, toggle) => TextButton(
                        onPressed: toggle,
                        child: const Text('End aligned'),
                      ),
                      builder: (context) => const SeedPopover(
                        titleText: 'RTL end',
                        body: Text('Short popup'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('End aligned'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      final popover = tester.getRect(find.byType(SeedPopover));
      final trigger = tester.getRect(
        find.ancestor(
          of: find.text('End aligned'),
          matching: find.byType(TextButton),
        ),
      );
      expect(popover.left, closeTo(trigger.left, 0.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('open Popover applies safe-area and view-insets after resize', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      final changed = ValueNotifier(false);
      addTearDown(changed.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: ValueListenableBuilder<bool>(
            valueListenable: changed,
            builder: (context, inset, _) => MediaQuery(
              data: MediaQueryData(
                textScaler: const TextScaler.linear(1.6),
                padding: const EdgeInsets.only(top: 24, bottom: 20),
                viewInsets: EdgeInsets.only(bottom: inset ? 90 : 0),
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    Positioned(
                      top: 365,
                      left: 162,
                      child: SeedPopoverTrigger(
                        controller: controller,
                        side: SeedOverlaySide.bottom,
                        triggerBuilder: (context, open, toggle) => TextButton(
                          onPressed: toggle,
                          child: const Text('Safe popup'),
                        ),
                        builder: (context) => SeedPopover(
                          titleText: 'Safe area popover',
                          footer: const Text('Persistent footer'),
                          body: Column(
                            children: [
                              for (var i = 0; i < 24; i++) Text('Body line $i'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Safe popup'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      Rect popover() => tester.getRect(find.byType(SeedPopover));
      expect(popover().top, greaterThanOrEqualTo(40 - .5));
      expect(popover().bottom, lessThanOrEqualTo(604 + .5));
      changed.value = true;
      tester.view.physicalSize = const Size(390, 560);
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      expect(popover().top, greaterThanOrEqualTo(40 - .5));
      expect(popover().bottom, lessThanOrEqualTo(560 - 90 - 16 + .5));
      expect(find.text('Persistent footer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('open Popover outside interaction closes with reason', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final events = <SeedOverlayDismissReason>[];
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Stack(
              children: [
                const Positioned(
                  left: 20,
                  top: 30,
                  child: TextButton(
                    onPressed: null,
                    child: Text('Outside press'),
                  ),
                ),
                Positioned(
                  left: 120,
                  top: 310,
                  child: SeedPopoverTrigger(
                    controller: controller,
                    onOpenChange: (open, reason) {
                      if (!open) events.add(reason);
                    },
                    triggerBuilder: (context, open, toggle) => TextButton(
                      onPressed: toggle,
                      child: const Text('Dismissible popup'),
                    ),
                    builder: (context) => const SeedPopover(
                      titleText: 'Dismiss on outside',
                      body: Text('Open popup body'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Dismissible popup'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      await tester.tap(find.text('Outside press'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
      expect(events, contains(SeedOverlayDismissReason.outside));
      expect(tester.takeException(), isNull);
    });
  });

  group('nested scrolling', () {
    setUpAll(loadSeedTestFonts);

    for (final width in [320.0, 390.0, 800.0]) {
      for (final scale in [1.0, 1.5, 2.5]) {
        testWidgets('open floating stays attached after nested horizontal/vertical scroll '
            'at $width scale $scale', (tester) async {
          tester.view.physicalSize = Size(width, 540);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          final vertical = ScrollController();
          final horizontal = ScrollController();
          final overlay = SeedOverlayController();
          addTearDown(vertical.dispose);
          addTearDown(horizontal.dispose);
          addTearDown(overlay.dispose);
          final referenceKey = UniqueKey();
          final popupKey = UniqueKey();

          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    controller: vertical,
                    child: SizedBox(
                      height: 1200,
                      child: Column(
                        children: [
                          const SizedBox(height: 160),
                          SingleChildScrollView(
                            controller: horizontal,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: width * 2 + 240,
                              height: 160,
                              child: Stack(
                                children: [
                                  Positioned(
                                    // The anchor remains partly visible while
                                    // its center is outside the safe viewport.
                                    left: width - 10,
                                    top: 48,
                                    child: SeedAnchoredOverlay(
                                      controller: overlay,
                                      side: SeedOverlaySide.bottom,
                                      flip: false,
                                      shift: true,
                                      skipAnimation: true,
                                      closeOnInteractOutside: false,
                                      triggerBuilder: (context, open, toggle) =>
                                          SizedBox(
                                            key: referenceKey,
                                            width: 60,
                                            height: 36,
                                            child: TextButton(
                                              onPressed: toggle,
                                              child: const Text('Anchor'),
                                            ),
                                          ),
                                      overlayBuilder: (context) => SizedBox(
                                        key: popupKey,
                                        width: 110,
                                        height: 80,
                                        child: const ColoredBox(
                                          color: Color(0xFF334455),
                                          child: Center(child: Text('Popup')),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          overlay.open();
          await tester.pumpAndSettle();
          expect(overlay.isOpen, isTrue);

          void expectAttached() {
            final anchor = tester.getRect(find.byKey(referenceKey));
            final bubble = tester.getRect(find.byKey(popupKey));
            // Floating UI's shift({ limiter: limitShift() }) keeps the
            // reference and floating element touching along the cross axis,
            // even when the reference is partially scrolled out of view.
            expect(bubble.right, greaterThanOrEqualTo(anchor.left - 0.5));
            expect(bubble.left, lessThanOrEqualTo(anchor.right + 0.5));
          }

          expectAttached();
          expect(
            tester.getRect(find.byKey(popupKey)).right,
            closeTo(tester.getRect(find.byKey(referenceKey)).left, .5),
          );
          // Now scroll almost the entire reference outside the *left* edge;
          // its last 5 px remain visible, below the 16 px collision inset.
          horizontal.jumpTo(width + 45);
          vertical.jumpTo(50);
          await tester.pumpAndSettle();
          final scrolledReference = tester.getRect(find.byKey(referenceKey));
          expect(scrolledReference.left, lessThan(0));
          expect(scrolledReference.right, greaterThan(0));
          expectAttached();
          expect(
            tester.getRect(find.byKey(popupKey)).left,
            closeTo(scrolledReference.right, .5),
          );
          expect(overlay.isOpen, isTrue);
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets(
        'ordered right-side floating follows vertically scrolled reference '
        'without detaching at $width in RTL',
        (tester) async {
          tester.view.physicalSize = Size(width, 540);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final vertical = ScrollController();
          final overlay = SeedOverlayController();
          addTearDown(vertical.dispose);
          addTearDown(overlay.dispose);
          final referenceKey = UniqueKey();
          final popupKey = UniqueKey();

          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Scaffold(
                    body: SingleChildScrollView(
                      controller: vertical,
                      child: SizedBox(
                        height: 1300,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 90,
                              top: 530,
                              child: SeedAnchoredOverlay(
                                controller: overlay,
                                side: SeedOverlaySide.right,
                                align: SeedOverlayAlign.end,
                                // Exercise the two-pass ordered-placement
                                // renderer as well as the legacy bool path.
                                flipFallbackSides: const [
                                  SeedOverlaySide.right,
                                ],
                                skipAnimation: true,
                                closeOnInteractOutside: false,
                                triggerBuilder: (context, open, toggle) =>
                                    SizedBox(
                                      key: referenceKey,
                                      width: 60,
                                      height: 60,
                                      child: const ColoredBox(
                                        color: Color(0xFF99AABB),
                                      ),
                                    ),
                                overlayBuilder: (context) => SizedBox(
                                  key: popupKey,
                                  width: 72,
                                  height: 110,
                                  child: const ColoredBox(
                                    color: Color(0xFF334455),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          overlay.open();
          await tester.pumpAndSettle();
          void expectAttached() {
            final anchor = tester.getRect(find.byKey(referenceKey));
            final bubble = tester.getRect(find.byKey(popupKey));
            expect(bubble.bottom, greaterThanOrEqualTo(anchor.top - .5));
            expect(bubble.top, lessThanOrEqualTo(anchor.bottom + .5));
            expect(bubble.left, closeTo(anchor.right + 8, .5));
          }

          expectAttached();
          expect(
            tester.getRect(find.byKey(popupKey)).bottom,
            closeTo(tester.getRect(find.byKey(referenceKey)).top, .5),
          );
          vertical.jumpTo(585);
          await tester.pumpAndSettle();
          final anchor = tester.getRect(find.byKey(referenceKey));
          expect(anchor.top, lessThan(0));
          expect(anchor.bottom, greaterThan(0));
          expectAttached();
          expect(
            tester.getRect(find.byKey(popupKey)).top,
            closeTo(anchor.bottom, .5),
          );
          expect(overlay.isOpen, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
  group('flip in small viewports', () {
    setUpAll(loadSeedTestFonts);

    // React headless Popover.tsx:174-189 uses
    // closeOnFocusOut={api.closeOnInteractOutside}, so an explicitly persistent
    // popover must not disappear merely because another control gains focus.
    for (final viewport in [const Size(390, 844), const Size(800, 800)]) {
      testWidgets('anchor flip and cross-axis shift stay inside $viewport', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.reset);
        final positions = <(Rect, SeedOverlaySide, SeedOverlaySide, Offset)>[
          (
            Rect.fromLTWH(viewport.width - 52, viewport.height - 60, 32, 32),
            SeedOverlaySide.bottom,
            SeedOverlaySide.top,
            Offset(viewport.width - 216, viewport.height - 60 - 8 - 140),
          ),
          (
            const Rect.fromLTWH(16, 20, 32, 32),
            SeedOverlaySide.top,
            SeedOverlaySide.bottom,
            const Offset(16, 60),
          ),
          (
            Rect.fromLTWH(viewport.width - 44, 120, 32, 32),
            SeedOverlaySide.right,
            SeedOverlaySide.left,
            Offset(viewport.width - 44 - 8 - 200, 66),
          ),
        ];
        for (final (anchor, requested, expected, expectedOffset) in positions) {
          SeedOverlaySide? resolved;
          Offset? position;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CustomSingleChildLayout(
                  delegate: SeedOverlayPositionDelegate(
                    anchor: anchor,
                    side: requested,
                    align: SeedOverlayAlign.start,
                    insets: const EdgeInsets.all(16),
                    onResolved: (value) => resolved = value,
                    onPosition: (offset, size) => position = offset,
                  ),
                  child: const SizedBox(width: 200, height: 140),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(resolved, expected);
          // A cross-axis shift must not move the surface off the visual viewport.
          expect(position!.dx, closeTo(expectedOffset.dx, 1));
          if (requested != SeedOverlaySide.right) {
            expect(position!.dy, closeTo(expectedOffset.dy, 1));
          }
          expect(position!.dx, greaterThanOrEqualTo(16));
          expect(position!.dx + 200, lessThanOrEqualTo(viewport.width - 16));
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets(
        'HelpBubble flips arrow away from upper viewport edge $viewport',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport;
          addTearDown(tester.view.reset);
          final controller = SeedOverlayController();
          final focus = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 0, 0),
                  child: SeedHelpBubbleTrigger(
                    controller: controller,
                    title: 'Tooltip source anchor',
                    showCloseButton: true,
                    skipAnimation: true,
                    triggerBuilder: (context, open, toggle) => TextButton(
                      focusNode: focus,
                      onPressed: toggle,
                      child: const Text('Help anchor'),
                    ),
                  ),
                ),
              ),
            ),
          );
          // A pointer tap does not necessarily focus a TextButton in Flutter;
          // pre-focus explicitly to test React autoFocus=false preservation.
          focus.requestFocus();
          await tester.pump();
          expect(focus.hasFocus, isTrue);
          await tester.tap(find.text('Help anchor'));
          await tester.pumpAndSettle();
          expect(controller.isOpen, isTrue);
          final popup = tester.widget<SeedHelpBubble>(
            find.byType(SeedHelpBubble),
          );
          expect(popup.arrowPlacement, SeedHelpBubbleArrowPlacement.top);
          expect(focus.hasFocus, isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(controller.isOpen, isFalse);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('anchored overlay control', () {
    testWidgets(
      'anchored overlay flips at edge and restores focus after Escape',
      (tester) async {
        final focus = FocusNode();
        addTearDown(focus.dispose);
        final reasons = <SeedOverlayDismissReason>[];
        await tester.pumpWidget(
          koreanApp(
            Align(
              alignment: Alignment.bottomRight,
              child: SeedAnchoredOverlay(
                triggerBuilder: (context, open, toggle) => TextButton(
                  focusNode: focus,
                  onPressed: toggle,
                  child: const Text('Open'),
                ),
                onOpenChanged: (open, reason) => reasons.add(reason),
                overlayBuilder: (context) => SizedBox(
                  width: 180,
                  height: 120,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Overlay action'),
                  ),
                ),
              ),
            ),
          ),
        );
        focus.requestFocus();
        await tester.pump();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          tester.getBottomRight(find.text('Overlay action')).dy,
          lessThan(tester.getTopLeft(find.text('Open')).dy),
        );
        expect(
          tester.getBottomRight(find.byType(SeedAnchoredOverlay)).dx,
          lessThanOrEqualTo(800),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Overlay action'), findsNothing);
        expect(reasons.last, SeedOverlayDismissReason.escapeKey);
        expect(focus.hasFocus, isTrue);
      },
    );

    testWidgets(
      'controlled overlay waits for parent and outside reports reason',
      (tester) async {
        final reasons = <SeedOverlayDismissReason>[];
        await tester.pumpWidget(
          koreanApp(
            Center(
              child: SeedAnchoredOverlay(
                open: true,
                triggerBuilder: (_, open, toggle) =>
                    TextButton(onPressed: toggle, child: const Text('Trigger')),
                onOpenChanged: (_, reason) => reasons.add(reason),
                overlayBuilder: (_) => const SizedBox(
                  width: 120,
                  height: 80,
                  child: Text('Content'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(reasons.last, SeedOverlayDismissReason.outside);
        expect(find.text('Content'), findsOneWidget);
      },
    );
  });

  group('overlay controller', () {
    test(
      'overlay controller can start open through its public constructor',
      () {
        final controller = SeedOverlayController(open: true);
        expect(controller.isOpen, isTrue);
        controller.dispose();
      },
    );
  });
}
