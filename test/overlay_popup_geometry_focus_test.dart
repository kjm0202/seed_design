import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  // React headless Popover.tsx:174-189 uses
  // closeOnFocusOut={api.closeOnInteractOutside}, so an explicitly persistent
  // popover must not disappear merely because another control gains focus.
  for (final viewport in [const Size(390, 844), const Size(800, 800)]) {
    testWidgets(
      'Popover outside interaction opt-out preserves content on focus-out $viewport',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.reset);
        final outside = FocusNode(debugLabel: 'outside control');
        final controller = SeedOverlayController();
        addTearDown(outside.dispose);
        addTearDown(controller.dispose);
        final reasons = <SeedOverlayDismissReason>[];

        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  SeedPopoverTrigger(
                    controller: controller,
                    closeOnInteractOutside: false,
                    onOpenChange: (open, reason) {
                      if (!open) reasons.add(reason);
                    },
                    triggerBuilder: (context, open, toggle) => TextButton(
                      onPressed: toggle,
                      child: const Text('Toggle persistent popover'),
                    ),
                    builder: (context) => const SeedPopover(
                      titleText: 'Persistent popup',
                      body: SizedBox(
                        height: 90,
                        child: Text('Popover body remains mounted'),
                      ),
                    ),
                  ),
                  TextButton(
                    focusNode: outside,
                    onPressed: () {},
                    child: const Text('Outside focusable'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Toggle persistent popover'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        expect(find.text('Persistent popup'), findsOneWidget);

        outside.requestFocus();
        await tester.pumpAndSettle();
        expect(outside.hasFocus, isTrue);
        expect(controller.isOpen, isTrue);
        expect(find.text('Persistent popup'), findsOneWidget);
        expect(reasons, isEmpty);

        // The Escape path remains independently dismissible when focus returns
        // to the popup, without reusing the earlier Shift+Tab boundary fix.
        await tester.tap(find.text('Toggle persistent popover'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isFalse);
        expect(reasons.single, SeedOverlayDismissReason.trigger);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Popover explicit focus-out override remains effective $viewport',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        final outsider = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(outsider.dispose);
        final reasons = <SeedOverlayDismissReason>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  SeedPopoverTrigger(
                    controller: controller,
                    closeOnInteractOutside: false,
                    closeOnFocusOut: true,
                    onOpenChange: (open, reason) {
                      if (!open) reasons.add(reason);
                    },
                    triggerBuilder: (context, open, toggle) => TextButton(
                      onPressed: toggle,
                      child: const Text('Explicit focus policy'),
                    ),
                    builder: (context) => const SeedPopover(
                      titleText: 'Explicit focus popup',
                      body: SizedBox(
                        height: 70,
                        child: Text('Keyboard content'),
                      ),
                    ),
                  ),
                  TextButton(
                    focusNode: outsider,
                    onPressed: () {},
                    child: const Text('Next focus'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Explicit focus policy'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        outsider.requestFocus();
        await tester.pumpAndSettle();
        expect(controller.isOpen, isFalse);
        expect(reasons, [SeedOverlayDismissReason.focusOut]);
        expect(tester.takeException(), isNull);
      },
    );

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
      'Menu popup near bottom edge flips, arrows and Escape work $viewport',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        final triggerFocus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(triggerFocus.dispose);
        final reasons = <SeedOverlayDismissReason>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    left: viewport.width - 112,
                    top: viewport.height - 68,
                    child: SeedMenuTrigger(
                      controller: controller,
                      skipAnimation: true,
                      onOpenChange: (open, reason) {
                        if (!open) reasons.add(reason);
                      },
                      triggerBuilder: (context, open, toggle) => TextButton(
                        focusNode: triggerFocus,
                        onPressed: toggle,
                        child: const Text('Menu anchor'),
                      ),
                      builder: (context) => const SeedMenu(
                        groups: [
                          SeedMenuGroupData(
                            items: [
                              SeedMenuItemData(label: 'First entry'),
                              SeedMenuItemData(label: 'Second entry'),
                              SeedMenuItemData(
                                label: 'Disabled entry',
                                enabled: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Menu anchor'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        final menu = tester.getRect(find.byType(SeedMenu));
        final anchor = tester.getRect(find.text('Menu anchor'));
        expect(menu.bottom, lessThan(anchor.top));
        expect(menu.left, greaterThanOrEqualTo(8));
        expect(menu.right, lessThanOrEqualTo(viewport.width - 8));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(find.text('Second entry'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(controller.isOpen, isFalse);
        expect(reasons, [SeedOverlayDismissReason.escapeKey]);
        expect(tester.takeException(), isNull);
      },
    );

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

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'Round4 Menu Tab exits nested dialog and focuses Confirm $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
        addTearDown(tester.view.reset);
        final menu = SeedOverlayController();
        final confirm = FocusNode(debugLabel: 'round4-confirm');
        final trigger = FocusNode(debugLabel: 'round4-menu-trigger');
        addTearDown(() {
          menu.dispose();
          confirm.dispose();
          trigger.dispose();
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (ctx) => TextButton(
                  onPressed: () => showSeedDialog<void>(
                    context: ctx,
                    child: SeedAlertDialog(
                      title: 'Menu in AlertDialog',
                      footer: Row(
                        children: [
                          SeedMenuTrigger(
                            controller: menu,
                            skipAnimation: true,
                            triggerBuilder: (_, _, toggle) => TextButton(
                              focusNode: trigger,
                              onPressed: toggle,
                              child: const Text('Open Menu'),
                            ),
                            builder: (_) => const SeedMenu(
                              groups: [
                                SeedMenuGroupData(
                                  items: [
                                    SeedMenuItemData(label: '추가'),
                                    SeedMenuItemData(label: '수정'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            focusNode: confirm,
                            onPressed: () {},
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Open dialog'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open dialog'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open Menu'));
        await tester.pumpAndSettle();
        expect(menu.isOpen, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(menu.isOpen, isFalse);
        expect(
          confirm.hasFocus,
          isTrue,
          reason: 'React closes nested menu on Tab and focuses Confirm',
        );
        await tester.tap(find.text('Open Menu'));
        await tester.pumpAndSettle();
        expect(menu.isOpen, isTrue);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        expect(
          menu.isOpen,
          isTrue,
          reason: 'React keeps the menu open at its reverse Tab boundary',
        );
        expect(
          trigger.hasFocus,
          isTrue,
          reason: 'React Shift+Tab moves from menu to trigger',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Round4 SeedPopover exposes native dialog semantics', (
    tester,
  ) async {
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
            triggerBuilder: (_, _, toggle) =>
                TextButton(onPressed: toggle, child: const Text('Open popup')),
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

  testWidgets('Round4 headerless Popover supports an explicit dialog name', (
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

  testWidgets('Round4 SeedMenu already exposes a native menu role', (
    tester,
  ) async {
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
                SeedMenuGroupData(items: [SeedMenuItemData(label: 'Entry A')]),
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

  testWidgets('Round13 Menu exposes an explicit accessible name', (
    tester,
  ) async {
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
                SeedMenuGroupData(items: [SeedMenuItemData(label: 'Entry A')]),
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
}
