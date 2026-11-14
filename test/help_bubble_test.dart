import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget host(Widget child, {double scale = 1, bool dark = false}) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme:
      (dark
              ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
              : SeedThemeData.light(fontFamily: seedTestFontFamily))
          .toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

Finder get closeButton => find.byWidgetPredicate(
  (widget) => widget is SeedPressable && widget.semanticsLabel == '닫기',
);

void main() {
  group('semantics and scroll', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('HelpBubble content advertises a named dialog semantics role', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final controller = SeedOverlayController();
      addTearDown(controller.dispose);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Center(
              child: SeedHelpBubbleTrigger(
                controller: controller,
                title: 'Flip 테스트',
                description: '팝업 설명',
                skipAnimation: true,
                triggerBuilder: (_, _, toggle) => TextButton(
                  onPressed: toggle,
                  child: const Text('Flip 테스트 버튼'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Flip 테스트 버튼'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      expect(find.byType(SeedHelpBubble), findsOneWidget);

      // Official React HelpBubble.test.tsx:47-64: Content role=dialog and
      // title/description exposed as its accessible name/description.
      // The dialog node is the painted card inside SeedHelpBubble; the arrow
      // around it stays outside the node.
      final popup = tester.getSemantics(
        find.descendant(
          of: find.byType(SeedHelpBubble),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.role == SemanticsRole.dialog,
          ),
        ),
      );
      final data = popup.getSemanticsData();
      expect(data.role, SemanticsRole.dialog);
      expect(data.label, contains('Flip 테스트'));
      expect(
        tester.getSemantics(find.text('팝업 설명')).getSemanticsData().hint,
        contains('팝업 설명'),
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets('HelpBubbleTooltip stays a tooltip rather than a dialog', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: const Scaffold(
            body: Center(
              child: SeedHelpBubbleTooltip(
                open: true,
                title: 'Hover help',
                description: 'Supplementary context',
                child: Text('Hover target'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SeedHelpBubble), findsOneWidget);

      // Flutter 3.47.9's debug semantics validator currently rejects
      // SemanticsRole.tooltip (the enum exists but its checks are unimplemented).
      // Preserve the native tooltip property without a misleading dialog role.
      final data = tester
          .getSemantics(find.byType(SeedHelpBubble))
          .getSemanticsData();
      expect(data.role, isNot(SemanticsRole.dialog));
      expect(data.tooltip, contains('Hover help'));
      expect(data.tooltip, contains('Supplementary context'));
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets('scroll position survives Escape from a long-page HelpBubble', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      final overlayController = SeedOverlayController();
      addTearDown(overlayController.dispose);
      final triggerFocus = FocusNode();
      addTearDown(triggerFocus.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: ListView(
              controller: scrollController,
              children: [
                const SizedBox(height: 2100),
                Center(
                  child: SeedHelpBubbleTrigger(
                    controller: overlayController,
                    title: '긴 컨텐츠 (placement=top)',
                    description: '긴 컨텐츠를 확인합니다. ' * 25,
                    skipAnimation: true,
                    triggerBuilder: (_, _, toggle) => TextButton(
                      focusNode: triggerFocus,
                      onPressed: toggle,
                      child: const Text('긴 컨텐츠 top 테스트'),
                    ),
                  ),
                ),
                const SizedBox(height: 900),
              ],
            ),
          ),
        ),
      );

      scrollController.jumpTo(2047);
      await tester.pumpAndSettle();
      final before = scrollController.offset;
      expect(before, 2047);
      expect(
        tester.getRect(find.text('긴 컨텐츠 top 테스트')).top,
        greaterThanOrEqualTo(0),
      );

      await tester.tap(find.text('긴 컨텐츠 top 테스트'));
      await tester.pumpAndSettle();
      expect(overlayController.isOpen, isTrue);

      // A test tap does not promise a browser-like primary keyboard focus.
      // Make Escape delivery explicit instead of treating absent focus as a
      // failed dismiss handler (the Round6 browser did deliver Escape).
      triggerFocus.requestFocus();
      await tester.pump();
      expect(triggerFocus.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(overlayController.isOpen, isFalse);
      expect(scrollController.offset, before);
      expect(tester.takeException(), isNull);
    });
  });

  group('semantic bounds', () {
    setUpAll(loadSeedTestFonts);

    for (final side in SeedOverlaySide.values) {
      testWidgets(
        'HelpBubble dialog semantics bounds exclude the arrow: $side',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final handle = tester.ensureSemantics();
          final controller = SeedOverlayController();
          addTearDown(controller.dispose);

          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Center(
                  child: SeedHelpBubbleTrigger(
                    controller: controller,
                    side: side,
                    flip: false,
                    skipAnimation: true,
                    showCloseButton: false,
                    maxWidth: 180,
                    title: 'Flip 테스트',
                    triggerBuilder: (_, _, toggle) => TextButton(
                      onPressed: toggle,
                      child: const Text('Open HelpBubble'),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open HelpBubble'));
          await tester.pumpAndSettle();
          expect(controller.isOpen, isTrue);

          final paintedCard = find.descendant(
            of: find.byType(SeedHelpBubble),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.decoration is BoxDecoration,
            ),
          );
          expect(paintedCard, findsOneWidget);
          final cardRect = tester.getRect(paintedCard);
          final dialog = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.role == SemanticsRole.dialog,
          );
          expect(dialog, findsOneWidget);
          final dialogRect = tester.getRect(dialog);
          expect(
            tester.getSemantics(dialog).getSemanticsData().role,
            SemanticsRole.dialog,
          );

          // React's dialog is HelpBubble.Content, whose CSS background/border and
          // rect belong to the card. The arrow is a separate positioned child,
          // and must not increase the dialog's semantic bounds by 8 or 12px.
          expect(dialogRect.left, closeTo(cardRect.left, 0.01));
          expect(dialogRect.top, closeTo(cardRect.top, 0.01));
          expect(dialogRect.width, closeTo(cardRect.width, 0.01));
          expect(dialogRect.height, closeTo(cardRect.height, 0.01));
          // The semantics node itself, which Flutter Web exposes, must also
          // stop at the card rather than merge into the arrow's parent.
          final node = tester.getSemantics(dialog);
          expect(node.rect.width, closeTo(cardRect.width, 0.01));
          expect(node.rect.height, closeTo(cardRect.height, 0.01));
          expect(tester.takeException(), isNull);
          handle.dispose();
        },
      );
    }
  });
  group('close target', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'help bubble close target fits the 38px body and works at its edges',
      (tester) async {
        var closed = 0;
        for (final dark in [false, true]) {
          await tester.pumpWidget(
            host(
              SeedHelpBubble(
                title: 'Tip',
                onClose: () => closed++,
                arrowPlacement: SeedHelpBubbleArrowPlacement.none,
              ),
              dark: dark,
            ),
          );
          final body = tester.getRect(find.byType(SeedHelpBubble));
          final close = tester.getRect(closeButton);
          expect(body.height, 38);
          expect(close.size, const Size(38, 38));
          expect(close.top, body.top);
          expect(close.right, body.right);
          await tester.tapAt(close.topRight + const Offset(-1, 1));
          await tester.pumpAndSettle();
        }
        expect(closed, 2);
        await tester.pumpWidget(
          host(
            SeedHelpBubble(
              title: 'A long title that wraps on a narrow screen',
              description: 'A longer description',
              maxWidth: 140,
              onClose: () {},
            ),
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('programmatic open while focus is elsewhere', () {
    setUpAll(loadSeedTestFonts);

    // Same overlay regression as Popover: HelpBubbleTrigger defaults to
    // autoFocus: false and closeOnFocusOut follows closeOnInteractOutside
    // (true), so a controller open while an outside TextField has focus must
    // not be treated as a focus-out.
    testWidgets(
      'HelpBubble opened by controller stays open while an outside TextField keeps focus',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        final outside = FocusNode(debugLabel: 'outside text field');
        addTearDown(controller.dispose);
        addTearDown(outside.dispose);
        final reasons = <SeedOverlayDismissReason>[];

        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  const SizedBox(height: 160),
                  SeedHelpBubbleTrigger(
                    controller: controller,
                    title: 'Programmatic bubble',
                    description: 'Opened from the controller',
                    onOpenChange: (open, reason) {
                      if (!open) reasons.add(reason);
                    },
                    triggerBuilder: (_, _, toggle) => TextButton(
                      onPressed: toggle,
                      child: const Text('Programmatic help'),
                    ),
                  ),
                  const SizedBox(height: 200),
                  TextField(focusNode: outside),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (var cycle = 0; cycle < 3; cycle++) {
          outside.requestFocus();
          await tester.pump();
          expect(outside.hasFocus, isTrue, reason: 'cycle $cycle');

          controller.open();
          for (var i = 0; i < 32; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(controller.isOpen, isTrue, reason: 'cycle $cycle');
          expect(
            find.text('Programmatic bubble'),
            findsOneWidget,
            reason: 'cycle $cycle',
          );
          expect(outside.hasFocus, isTrue, reason: 'cycle $cycle');
          expect(reasons, isEmpty, reason: 'cycle $cycle');

          controller.close();
          await tester.pumpAndSettle();
          expect(controller.isOpen, isFalse, reason: 'cycle $cycle');
          expect(find.text('Programmatic bubble'), findsNothing);
          reasons.clear();
        }
        expect(tester.takeException(), isNull);
      },
    );
  });
}
