import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  testWidgets('help bubble proposes close when content focus moves outside', (
    tester,
  ) async {
    final events = <SeedOverlayDismissReason>[];
    final outside = FocusNode();
    addTearDown(outside.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SeedHelpBubbleTrigger(
                title: 'Bubble',
                autoFocus: true,
                defaultOpen: true,
                onOpenChange: (open, reason) {
                  if (!open) events.add(reason);
                },
                triggerBuilder: (context, open, toggle) =>
                    TextButton(onPressed: toggle, child: const Text('trigger')),
              ),
              TextButton(
                focusNode: outside,
                onPressed: () {},
                child: const Text('outside'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    outside.requestFocus();
    await tester.pumpAndSettle();
    expect(events, [SeedOverlayDismissReason.focusOut]);
  });

  testWidgets(
    'group switching proposes close even when previous tooltip is controlled',
    (tester) async {
      final first = <bool>[];
      final second = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SeedTooltipDelayGroup(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SeedHelpBubbleTooltip(
                      open: true,
                      title: 'first bubble',
                      onOpenChange: first.add,
                      child: const SizedBox(
                        width: 80,
                        height: 40,
                        child: Text('first'),
                      ),
                    ),
                    SeedHelpBubbleTooltip(
                      title: 'second bubble',
                      onOpenChange: second.add,
                      child: const SizedBox(
                        width: 80,
                        height: 40,
                        child: Text('second'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(0, 0));
      await mouse.moveTo(tester.getCenter(find.text('second')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(first, [false]);
      expect(second, [true]);
      expect(find.text('first bubble'), findsOneWidget);
      await mouse.removePointer();
    },
  );

  testWidgets('tooltip focus closes immediately and reports focus-out', (
    tester,
  ) async {
    final focus = FocusNode();
    final outside = FocusNode();
    addTearDown(focus.dispose);
    addTearDown(outside.dispose);
    final reasons = <SeedOverlayDismissReason>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SeedHelpBubbleTooltip(
                title: 'tooltip',
                onOpenChanged: (open, reason) {
                  if (!open) reasons.add(reason);
                },
                child: TextButton(
                  focusNode: focus,
                  onPressed: () {},
                  child: const Text('trigger'),
                ),
              ),
              TextButton(
                focusNode: outside,
                onPressed: () {},
                child: const Text('outside'),
              ),
            ],
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.pump();
    expect(find.text('tooltip'), findsOneWidget);
    outside.requestFocus();
    await tester.pump();
    expect(reasons, [SeedOverlayDismissReason.focusOut]);
  });
}
