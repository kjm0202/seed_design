import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets(
    'Popover: autofocus content, Tab first control, Escape restores trigger',
    (tester) async {
      final controller = SeedOverlayController();
      final trigger = FocusNode(debugLabel: 'popover-trigger');
      final first = FocusNode(debugLabel: 'popover-first');
      final second = FocusNode(debugLabel: 'popover-second');
      final changes = <SeedOverlayDismissReason>[];
      addTearDown(() {
        controller.dispose();
        trigger.dispose();
        first.dispose();
        second.dispose();
      });
      await tester.pumpWidget(
        _app(
          SeedPopoverTrigger(
            controller: controller,
            onOpenChange: (open, reason) {
              if (!open) changes.add(reason);
            },
            triggerBuilder: (_, _, toggle) => TextButton(
              focusNode: trigger,
              onPressed: toggle,
              child: const Text('Open popover'),
            ),
            builder: (_) => SeedPopover(
              titleText: 'Contents',
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    focusNode: first,
                    onPressed: () {},
                    child: const Text('First action'),
                  ),
                  TextButton(
                    focusNode: second,
                    onPressed: () {},
                    child: const Text('Second action'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      trigger.requestFocus();
      await tester.pump();
      await _key(tester, LogicalKeyboardKey.space);
      expect(controller.isOpen, isTrue);
      expect(
        trigger.hasFocus,
        isFalse,
        reason: 'React Popover focuses the content on open',
      );
      expect(FocusManager.instance.primaryFocus, isNotNull);
      await _key(tester, LogicalKeyboardKey.tab);
      expect(
        first.hasFocus,
        isTrue,
        reason: 'Tab from the content enters the first action',
      );
      await _key(tester, LogicalKeyboardKey.tab);
      expect(
        second.hasFocus,
        isTrue,
        reason: 'Tab advances to the next popup action',
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await _key(tester, LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(
        first.hasFocus,
        isTrue,
        reason: 'Shift+Tab reverses popup action order',
      );
      await _key(tester, LogicalKeyboardKey.escape);
      expect(controller.isOpen, isFalse);
      expect(changes, contains(SeedOverlayDismissReason.escapeKey));
      expect(trigger.hasFocus, isTrue);
    },
  );

  for (final autoFocus in [false, true]) {
    testWidgets(
      'HelpBubble: Escape closes with autoFocus=$autoFocus and restores trigger',
      (tester) async {
        final controller = SeedOverlayController();
        final trigger = FocusNode(debugLabel: 'help-trigger');
        final closes = <SeedOverlayDismissReason>[];
        addTearDown(() {
          controller.dispose();
          trigger.dispose();
        });
        await tester.pumpWidget(
          _app(
            SeedHelpBubbleTrigger(
              controller: controller,
              title: 'Contextual help',
              autoFocus: autoFocus,
              skipAnimation: true,
              onOpenChange: (open, reason) {
                if (!open) closes.add(reason);
              },
              triggerBuilder: (_, _, toggle) => TextButton(
                focusNode: trigger,
                onPressed: toggle,
                child: const Text('Open help'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        trigger.requestFocus();
        await tester.pump();
        await tester.tap(find.text('Open help'));
        await tester.pumpAndSettle();
        expect(controller.isOpen, isTrue);
        await _key(tester, LogicalKeyboardKey.escape);
        expect(controller.isOpen, isFalse);
        expect(closes, contains(SeedOverlayDismissReason.escapeKey));
        expect(trigger.hasFocus, isTrue);
      },
    );
  }

  testWidgets(
    'Tooltip: focused trigger opens, Escape dismisses without losing focus',
    (tester) async {
      final trigger = FocusNode(debugLabel: 'tooltip-trigger');
      final changes = <String>[];
      addTearDown(trigger.dispose);
      await tester.pumpWidget(
        _app(
          SeedHelpBubbleTooltip(
            title: 'Tooltip content',
            openDelay: Duration.zero,
            closeDelay: Duration.zero,
            onOpenChanged: (open, reason) =>
                changes.add('$open:${reason.name}'),
            child: TextButton(
              focusNode: trigger,
              onPressed: () {},
              child: const Text('Tooltip trigger'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      trigger.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();
      expect(find.text('Tooltip content'), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.escape);
      expect(changes, contains('false:escapeKey'));
      expect(find.text('Tooltip content'), findsNothing);
      expect(trigger.hasFocus, isTrue);
    },
  );

  testWidgets('Nested HelpBubble: Escape closes child before parent', (
    tester,
  ) async {
    final parent = SeedOverlayController();
    final child = SeedOverlayController();
    final parentTrigger = FocusNode(debugLabel: 'parent-trigger');
    final childTrigger = FocusNode(debugLabel: 'child-trigger');
    final closed = <String>[];
    addTearDown(() {
      parent.dispose();
      child.dispose();
      parentTrigger.dispose();
      childTrigger.dispose();
    });
    await tester.pumpWidget(
      _app(
        SeedPopoverTrigger(
          controller: parent,
          onOpenChange: (open, reason) {
            if (!open) closed.add('parent:${reason.name}');
          },
          triggerBuilder: (_, _, toggle) => TextButton(
            focusNode: parentTrigger,
            onPressed: toggle,
            child: const Text('Parent trigger'),
          ),
          builder: (_) => SeedPopover(
            titleText: 'Parent popover',
            scrollBody: false,
            body: SeedHelpBubbleTrigger(
              controller: child,
              title: 'Child bubble',
              autoFocus: false,
              skipAnimation: true,
              onOpenChange: (open, reason) {
                if (!open) closed.add('child:${reason.name}');
              },
              triggerBuilder: (_, _, toggle) => TextButton(
                focusNode: childTrigger,
                onPressed: toggle,
                child: const Text('Child trigger'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    parentTrigger.requestFocus();
    await tester.pump();
    await tester.tap(find.text('Parent trigger'));
    await tester.pumpAndSettle();
    expect(parent.isOpen, isTrue);
    childTrigger.requestFocus();
    await tester.pump();
    await tester.tap(find.text('Child trigger'));
    await tester.pumpAndSettle();
    expect(parent.isOpen, isTrue);
    expect(child.isOpen, isTrue);

    await _key(tester, LogicalKeyboardKey.escape);
    expect(parent.isOpen, isTrue, reason: 'One Escape should keep the parent');
    expect(child.isOpen, isFalse);
    expect(childTrigger.hasFocus, isTrue);
    expect(closed, ['child:escapeKey']);

    await _key(tester, LogicalKeyboardKey.escape);
    expect(parent.isOpen, isFalse);
    expect(parentTrigger.hasFocus, isTrue);
    expect(closed, ['child:escapeKey', 'parent:escapeKey']);
  });

  testWidgets(
    'Popover non-modal: Tab after last action leaves for background',
    (tester) async {
      final controller = SeedOverlayController();
      final trigger = FocusNode(debugLabel: 'exit-trigger');
      final first = FocusNode(debugLabel: 'exit-first');
      final second = FocusNode(debugLabel: 'exit-second');
      final outside = FocusNode(debugLabel: 'exit-outside');
      addTearDown(() {
        controller.dispose();
        trigger.dispose();
        first.dispose();
        second.dispose();
        outside.dispose();
      });
      await tester.pumpWidget(
        _app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedPopoverTrigger(
                controller: controller,
                triggerBuilder: (_, _, toggle) => TextButton(
                  focusNode: trigger,
                  onPressed: toggle,
                  child: const Text('Open with two controls'),
                ),
                builder: (_) => SeedPopover(
                  titleText: 'Nonmodal contents',
                  scrollBody: false,
                  body: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        focusNode: first,
                        onPressed: () {},
                        child: const Text('Action one'),
                      ),
                      TextButton(
                        focusNode: second,
                        onPressed: () {},
                        child: const Text('Action two'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 200, child: TextField(focusNode: outside)),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      trigger.requestFocus();
      await tester.pump();
      await _key(tester, LogicalKeyboardKey.space);
      expect(controller.isOpen, isTrue);
      await _key(tester, LogicalKeyboardKey.tab);
      expect(first.hasFocus, isTrue);
      await _key(tester, LogicalKeyboardKey.tab);
      expect(second.hasFocus, isTrue);
      await _key(tester, LogicalKeyboardKey.tab);
      expect(
        outside.hasFocus,
        isTrue,
        reason: 'React nonmodal popup never traps Tab',
      );
      expect(
        controller.isOpen,
        isFalse,
        reason: 'Focus-out dismisses the open popover',
      );
    },
  );
}
