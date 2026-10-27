import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets(
    'anchored overlay flips at edge and restores focus after Escape',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final reasons = <SeedOverlayDismissReason>[];
      await tester.pumpWidget(
        host(
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
        host(
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

  testWidgets('dialog close respects prevention and closes with reason', (
    tester,
  ) async {
    var prevent = true;
    final reasons = <SeedOverlayDismissReason>[];
    await tester.pumpWidget(
      host(
        Center(
          child: SeedDialogTrigger(
            responsive: false,
            canClose: (_) => !prevent,
            onOpenChanged: (_, reason) => reasons.add(reason),
            triggerBuilder: (_, open, toggle) =>
                TextButton(onPressed: toggle, child: const Text('Dialog open')),
            builder: (_) => const SeedDialog(
              title: 'Dialog title',
              content: Text('Dialog body'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Dialog open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog body'), findsOneWidget);
    prevent = false;
    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog body'), findsNothing);
    expect(reasons.last, SeedOverlayDismissReason.closeButton);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet supports min and max programmatic snap without overflow', (
    tester,
  ) async {
    final controller = SeedSheetController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        SeedSnappingBottomSheet(
          controller: controller,
          sheet: SeedBottomSheet(
            title: 'A sheet title',
            description: 'Some description',
            footer: const Text('Footer'),
            content: Column(
              children: List.generate(30, (i) => Text('Line $i')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    controller.snapTo(0);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    controller.snapTo(2);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs carousel changes selected header and swipe lifecycle', (
    tester,
  ) async {
    final changes = <int>[];
    var starts = 0, ends = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          height: 250,
          child: SeedTabsView(
            carousel: true,
            onTabSelected: changes.add,
            onSwipeStart: () => starts++,
            onSwipeEnd: () => ends++,
            items: const [
              SeedTabItem(label: 'Tab A'),
              SeedTabItem(label: 'Tab B'),
            ],
            children: const [Text('Page A'), Text('Page B')],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(PageView), const Offset(-650, 0));
    await tester.pumpAndSettle();
    expect(changes.last, 1);
    expect(starts, 1);
    expect(ends, 1);
    expect(find.text('Page B'), findsOneWidget);
  });

  testWidgets(
    'text field counts graphemes and exposes sliced input without truncating',
    (tester) async {
      SeedTextValueChange? change;
      await tester.pumpWidget(
        host(
          SeedTextField(
            maxGraphemeCount: 2,
            onValueChanged: (value) => change = value,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '🇰🇷👨‍👩‍👧‍👦가');
      await tester.pump();
      expect(change!.graphemes, hasLength(3));
      expect(change!.slicedValue, '🇰🇷👨‍👩‍👧‍👦');
      expect(find.text('🇰🇷👨‍👩‍👧‍👦가'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'menu arrow navigation skips disabled items and closes after action',
    (tester) async {
      var count = 0;
      await tester.pumpWidget(
        host(
          SeedMenuTrigger(
            triggerBuilder: (_, open, toggle) =>
                TextButton(onPressed: toggle, child: const Text('Menu open')),
            builder: (_) => SeedMenu(
              groups: [
                SeedMenuGroupData(
                  items: [
                    const SeedMenuItemData(label: 'Disabled', enabled: false),
                    SeedMenuItemData(label: 'Enabled', onTap: () => count++),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Menu open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(count, 1);
      expect(find.text('Enabled'), findsNothing);
    },
  );

  testWidgets('readonly select box does not change and group fits columns', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 320,
          child: SeedSelectBoxGroup(
            columns: 2,
            children: [
              SeedSelectBox(
                title: 'One',
                readOnly: true,
                onSelected: (_) => changes++,
              ),
              const SeedSelectBox(
                title: 'Two',
                selected: true,
                footer: Text('Extra'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(changes, 0);
    expect(tester.takeException(), isNull);
  });
}
