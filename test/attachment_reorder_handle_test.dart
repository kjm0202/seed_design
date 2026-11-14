import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

// SEED React 3.3.0 keeps reorder controls only on items that can move
// (AttachmentInput.ItemReorderHandle) and announces start, cancel and drop.

Widget host(
  Widget child, {
  double width = 600,
  TextDirection direction = TextDirection.ltr,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  locale: locale,
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      body: Center(child: SizedBox(width: width, child: child)),
    ),
  ),
);

SeedAttachmentItem file(String id, {bool enabled = true, bool readOnly = false}) =>
    SeedAttachmentItem(
      id: id,
      name: '$id.pdf',
      type: SeedAttachmentType.file,
      enabled: enabled,
      readOnly: readOnly,
    );

List<int>? customActions(WidgetTester tester, String text) => tester
    .getSemantics(find.text(text))
    .getSemanticsData()
    .customSemanticsActionIds;

List<String> recordAnnouncements(WidgetTester tester) {
  final messages = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (message) async {
      final map = (message as Map).cast<String, dynamic>();
      if (map['type'] == 'announce') {
        messages.add((map['data'] as Map)['message'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger
        .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
  );
  return messages;
}

void main() {
  testWidgets('parent removal cancels a provisional keyboard reorder', (
    tester,
  ) async {
    var entries = [file('a'), file('b'), file('c')];
    late StateSetter update;
    final calls = <(int, int)>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedAttachmentInput(
              items: entries,
              showTrigger: false,
              onReorder: (from, to) => calls.add((from, to)),
            );
          },
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('3 / 3'), findsOneWidget);

    update(() => entries = [entries[0], entries[1]]);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('a.pdf'), findsOneWidget);
    expect(find.text('b.pdf'), findsOneWidget);
    expect(find.text('3 / 3'), findsNothing);
    expect(calls, isEmpty);
  });

  testWidgets('rapid arrow keys keep the moving item focused past the viewport', (
    tester,
  ) async {
    var entries = [for (var i = 0; i < 8; i++) file('f$i')];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => SeedAttachmentInput(
            items: entries,
            showTrigger: false,
            onReorder: (from, to) {
              setState(() {
                final next = entries.toList();
                next.insert(to > from ? to - 1 : to, next.removeAt(from));
                entries = next;
              });
            },
          ),
        ),
        width: 360,
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    for (var i = 0; i < 7; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await tester.pumpAndSettle();
    expect(find.text('8 / 8'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(entries.last.id, 'f0');
    expect(find.text('8 / 8'), findsNothing);
  });

  testWidgets(
    'mixed list: immovable items expose no move actions but keep remove',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final removed = <String>[];
      var calls = 0;
      await tester.pumpWidget(
        host(
          SeedAttachmentInput(
            showTrigger: false,
            items: [
              file('a'),
              file('b', enabled: false),
              file('c', readOnly: true),
              file('d'),
            ],
            onReorder: (_, _) => calls++,
            onRemove: (item) => removed.add(item.id),
          ),
        ),
      );
      final moveLeft = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Move left'),
      );
      final moveRight = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Move right'),
      );
      expect(customActions(tester, 'a.pdf'), contains(moveRight));
      expect(customActions(tester, 'd.pdf'), contains(moveLeft));
      expect(customActions(tester, 'b.pdf'), anyOf(isNull, isEmpty));
      expect(customActions(tester, 'c.pdf'), anyOf(isNull, isEmpty));

      // Keyboard focus skips the immovable items' reorder handles too.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(find.text('1 / 4'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      // The independent remove action stays on a movable neighbour.
      await tester.tap(find.bySemanticsLabel(RegExp('Remove file')).first);
      await tester.pump();
      expect(removed, ['a']);
      expect(calls, 0);
      semantics.dispose();
    },
  );

  for (final locale in const [Locale('en'), Locale('ko')]) {
    testWidgets('keyboard reorder announces start, cancel and drop in $locale', (
      tester,
    ) async {
      final announced = recordAnnouncements(tester);
      var entries = [file('a'), file('b'), file('c')];
      final calls = <(int, int)>[];
      await tester.pumpWidget(
        host(
          locale: locale,
          StatefulBuilder(
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
      );
      final ko = locale.languageCode == 'ko';
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(
        announced.last,
        ko ? 'a.pdf 항목 순서 변경을 시작했어요.' : 'Started reordering a.pdf.',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(
        announced.last,
        ko ? 'a.pdf 항목 순서 변경을 취소했어요.' : 'Canceled reordering a.pdf.',
      );
      expect(calls, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(
        announced.last,
        ko ? 'a.pdf 항목을 3번째에 놓았어요.' : 'Moved a.pdf to position 3.',
      );
      expect(calls, [(0, 3)]);
      expect(entries.map((entry) => entry.id), ['b', 'c', 'a']);
      expect(announced, hasLength(4));
    });
  }

  for (final direction in TextDirection.values) {
    testWidgets(
      'keyboard move scrolls the target position into view in $direction',
      (tester) async {
        final entries = [for (var i = 0; i < 12; i++) file('f$i')];
        final calls = <(int, int)>[];
        await tester.pumpWidget(
          host(
            width: 320,
            direction: direction,
            SeedAttachmentInput(
              items: entries,
              showTrigger: false,
              onReorder: (from, to) => calls.add((from, to)),
            ),
          ),
        );
        final position = tester
            .state<ScrollableState>(
              find.descendant(
                of: find.byType(SeedAttachmentInput),
                matching: find.byType(Scrollable),
              ),
            )
            .position;
        expect(position.pixels, 0);
        final forward = direction == TextDirection.ltr
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.arrowLeft;
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        for (var i = 0; i < 11; i++) {
          await tester.sendKeyEvent(forward);
          await tester.pumpAndSettle();
        }
        expect(find.text('12 / 12'), findsOneWidget);
        expect(position.pixels, closeTo(position.maxScrollExtent, 0.5));
        expect(position.pixels, greaterThan(0));

        // Canceling returns to the item's own, unchanged position.
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(position.pixels, 0);
        expect(calls, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
