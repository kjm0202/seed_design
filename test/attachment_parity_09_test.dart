import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 600, child: child)),
  ),
);

const failed = SeedAttachmentItem(
  id: 'failed',
  type: SeedAttachmentType.file,
  name: 'failed.pdf',
  status: SeedAttachmentStatus.error,
);

void main() {
  testWidgets('all immovable entries expose no reorder actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        SeedAttachmentInput(
          showTrigger: false,
          items: const [
            SeedAttachmentItem(
              id: 'a',
              name: 'a.pdf',
              type: SeedAttachmentType.file,
              enabled: false,
            ),
            SeedAttachmentItem(
              id: 'b',
              name: 'b.pdf',
              type: SeedAttachmentType.file,
              readOnly: true,
            ),
          ],
          onReorder: (_, _) => fail('Immovable entries cannot reorder'),
        ),
      ),
    );
    expect(find.byType(ReorderableListView), findsNothing);
    for (final name in ['a.pdf', 'b.pdf']) {
      expect(
        tester
            .getSemantics(find.text(name))
            .getSemanticsData()
            .customSemanticsActionIds,
        anyOf(isNull, isEmpty),
      );
    }
    semantics.dispose();
  });

  for (final direction in TextDirection.values) {
    testWidgets('keyboard reorder commits and cancels in $direction', (
      tester,
    ) async {
      var entries = const [
        SeedAttachmentItem(
          id: 'a',
          name: 'a.pdf',
          type: SeedAttachmentType.file,
        ),
        SeedAttachmentItem(
          id: 'b',
          name: 'b.pdf',
          type: SeedAttachmentType.file,
        ),
        SeedAttachmentItem(
          id: 'c',
          name: 'c.pdf',
          type: SeedAttachmentType.file,
        ),
      ];
      final calls = <(int, int)>[];
      await tester.pumpWidget(
        host(
          Directionality(
            textDirection: direction,
            child: StatefulBuilder(
              builder: (context, setState) => SeedAttachmentInput(
                items: entries,
                showTrigger: false,
                onReorder: (from, to) {
                  calls.add((from, to));
                  setState(() {
                    final copy = entries.toList();
                    copy.insert(to > from ? to - 1 : to, copy.removeAt(from));
                    entries = copy;
                  });
                },
              ),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(
        direction == TextDirection.ltr
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.arrowLeft,
      );
      await tester.pump();
      expect(find.text('2 / 3'), findsOneWidget);
      expect(calls, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('2 / 3'), findsNothing);
      expect(calls, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(
        direction == TextDirection.ltr
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.arrowLeft,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(calls, [(0, 2)]);
      expect(entries.map((entry) => entry.id), ['b', 'a', 'c']);
    });
  }

  testWidgets('field forwards retry availability and the active controller', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(const SeedAttachmentDisplayField(defaultEntries: [failed])),
    );
    var input = tester.widget<SeedAttachmentInput>(
      find.byType(SeedAttachmentInput),
    );
    expect(input.onRetry, isNull);
    final retry = tester.getSemantics(find.byTooltip('Retry'));
    expect(retry.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);

    SeedAttachmentItem? retried;
    SeedAttachmentController? usedController;
    final controller = SeedAttachmentController(items: [failed]);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        SeedAttachmentField(
          controller: controller,
          onRetry: (item, active) {
            retried = item;
            usedController = active;
          },
        ),
      ),
    );
    input = tester.widget<SeedAttachmentInput>(
      find.byType(SeedAttachmentInput),
    );
    expect(input.onRetry, isNotNull);
    await tester.tap(find.byTooltip('Retry'));
    expect(retried, same(failed));
    expect(usedController, same(controller));
    semantics.dispose();
  });

  testWidgets(
    'accessibility reorder changes entries using the existing index convention',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = SeedAttachmentController(
        items: const [
          SeedAttachmentItem(
            id: 'a',
            name: 'a.pdf',
            type: SeedAttachmentType.file,
          ),
          SeedAttachmentItem(
            id: 'b',
            name: 'b.pdf',
            type: SeedAttachmentType.file,
          ),
        ],
        maxCount: 2,
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          SeedAttachmentDisplayField(
            controller: controller,
            maxEntries: 2,
            reorderable: true,
          ),
        ),
      );
      final node = tester.getSemantics(find.text('a.pdf'));
      final action = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Move right'),
      );
      expect(
        node.getSemanticsData().customSemanticsActionIds,
        contains(action),
      );
      tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.customAction,
        action,
      );
      await tester.pumpAndSettle();
      expect(controller.items.map((item) => item.id), ['b', 'a']);
      semantics.dispose();
    },
  );

  testWidgets(
    'disabled list has no reorder semantics, disabled items cannot reorder',
    (tester) async {
      final semantics = tester.ensureSemantics();
      const items = [
        SeedAttachmentItem(
          id: 'a',
          name: 'a.pdf',
          type: SeedAttachmentType.file,
          enabled: false,
        ),
        SeedAttachmentItem(
          id: 'b',
          name: 'b.pdf',
          type: SeedAttachmentType.file,
        ),
      ];
      var calls = 0;
      await tester.pumpWidget(
        host(
          SeedAttachmentInput(
            items: items,
            enabled: false,
            onReorder: (_, _) => calls++,
          ),
        ),
      );
      expect(find.byType(ReorderableListView), findsNothing);
      expect(
        tester
            .getSemantics(find.text('a.pdf'))
            .getSemanticsData()
            .customSemanticsActionIds,
        anyOf(isNull, isEmpty),
      );
      await tester.pumpWidget(
        host(SeedAttachmentInput(items: items, onReorder: (_, _) => calls++)),
      );
      final node = tester.getSemantics(find.text('a.pdf'));
      final action = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Move right'),
      );
      tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.customAction,
        action,
      );
      await tester.pump();
      expect(calls, 0);
      semantics.dispose();
    },
  );
}
