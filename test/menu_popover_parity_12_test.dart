import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

FocusNode? itemFocus(WidgetTester tester, String label) => tester
    .widget<SeedPressable>(
      find
          .ancestor(of: find.text(label), matching: find.byType(SeedPressable))
          .first,
    )
    .focusNode;

void main() {
  testWidgets(
    'reopening during exit with ArrowUp focuses and reveals last enabled item',
    (tester) async {
      final triggerFocus = FocusNode();
      addTearDown(triggerFocus.dispose);
      await tester.pumpWidget(
        host(
          SeedMenuTrigger(
            triggerBuilder: (_, open, toggle) => TextButton(
              focusNode: triggerFocus,
              onPressed: toggle,
              child: const Text('Open'),
            ),
            builder: (_) => SeedMenu(
              maxHeight: 120,
              groups: [
                SeedMenuGroupData(
                  items: [
                    for (var i = 0; i < 12; i++)
                      SeedMenuItemData(label: 'Item $i', enabled: i != 11),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      // The portal remains mounted during the exit animation.
      expect(find.byType(SeedMenu), findsOneWidget);
      triggerFocus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(itemFocus(tester, 'Item 10')?.hasPrimaryFocus, isTrue);
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(SeedMenu),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(scroll.position.pixels, greaterThan(0));
      final viewport = tester.getRect(find.byType(SeedMenu));
      expect(viewport.contains(tester.getCenter(find.text('Item 10'))), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      triggerFocus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(itemFocus(tester, 'Item 0')?.hasPrimaryFocus, isTrue);
      expect(scroll.position.pixels, 0);
    },
  );

  testWidgets('retained anchored menu focuses on every open transition', (
    tester,
  ) async {
    final controller = SeedOverlayController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        SeedAnchoredOverlay(
          controller: controller,
          lazyMount: false,
          unmountOnExit: false,
          triggerBuilder: (_, open, toggle) =>
              TextButton(onPressed: toggle, child: const Text('Open')),
          overlayBuilder: (_) => const SeedMenu(
            groups: [
              SeedMenuGroupData(items: [SeedMenuItemData(label: 'First')]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    controller.open();
    await tester.pumpAndSettle();
    expect(itemFocus(tester, 'First')?.hasPrimaryFocus, isTrue);
    controller.close();
    await tester.pumpAndSettle();
    controller.open();
    await tester.pumpAndSettle();
    expect(itemFocus(tester, 'First')?.hasPrimaryFocus, isTrue);
  });

  testWidgets(
    'menu groups expose a label and their item semantics as children',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const SeedMenu(
            groups: [
              SeedMenuGroupData(
                label: 'Edit actions',
                items: [SeedMenuItemData(label: 'Copy')],
              ),
              SeedMenuGroupData(
                label: 'Danger actions',
                items: [SeedMenuItemData(label: 'Delete')],
              ),
            ],
          ),
        ),
      );
      for (final (group, item) in [
        ('Edit actions', 'Copy'),
        ('Danger actions', 'Delete'),
      ]) {
        final node = tester.getSemantics(find.bySemanticsLabel(group));
        final children = <SemanticsNode>[];
        node.visitChildren((child) {
          children.add(child);
          return true;
        });
        expect(
          children.any(
            (child) =>
                child.getSemanticsData().label.contains(item) &&
                child.getSemanticsData().role == SemanticsRole.menuItem,
          ),
          isTrue,
        );
      }
      handle.dispose();
    },
  );

  testWidgets('popover dialog exposes the rendered description on entry', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const SeedPopover(titleText: 'Title', descriptionText: 'Description'),
      ),
    );
    var data = tester.getSemantics(find.byType(SeedPopover)).getSemanticsData();
    expect(data.role, SemanticsRole.dialog);
    expect(data.label, 'Title');
    expect(data.hint, 'Description');
    await tester.pumpWidget(
      host(
        const SeedPopover(
          titleText: 'Title',
          description: Text('Rendered'),
          descriptionText: 'Hidden',
        ),
      ),
    );
    data = tester.getSemantics(find.byType(SeedPopover)).getSemanticsData();
    expect(data.hint, 'Rendered');
    handle.dispose();
  });
}
