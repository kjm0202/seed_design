import 'dart:ui' show PointerDeviceKind;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(800, 800)]) {
    testWidgets(
      'Isolated handle zero-elapsed mouse swipe closes without route drag at $size',
      (tester) async {
        final pointerTimes = <Duration>[];
        var moves = 0;
        var cancels = 0;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => Scaffold(
                        body: Listener(
                          onPointerDown: (e) => pointerTimes.add(e.timeStamp),
                          onPointerMove: (_) => moves++,
                          onPointerCancel: (_) => cancels++,
                          onPointerUp: (e) => pointerTimes.add(e.timeStamp),
                          child: SeedMenuSheet(
                            title: 'Actions',
                            swipeable: true,
                            showHandle: true,
                            handleDragDismissible: true,
                            showCancelButton: false,
                            closeOnSelect: false,
                            groups: const [
                              SeedMenuGroupData(
                                items: [
                                  SeedMenuItemData(label: 'Test1'),
                                  SeedMenuItemData(label: 'Test2'),
                                  SeedMenuItemData(label: 'Test3'),
                                  SeedMenuItemData(label: 'Test4'),
                                  SeedMenuItemData(label: 'Test5'),
                                  SeedMenuItemData(label: 'Test6'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Open isolated page'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open isolated page'));
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byType(SeedMenuSheet));
        expect(rect.height, greaterThan(288));
        final gesture = await tester.startGesture(
          Offset(rect.center.dx, rect.top + 12),
          kind: PointerDeviceKind.mouse,
        );
        // TestGesture.moveBy/up default to Duration.zero for every event,
        // unlike a timedDrag. The enclosing route is a normal PageRoute and
        // has NO ModalBottomSheetRoute drag recognizer to mask handle bugs.
        for (var i = 0; i < 10; i++) {
          await gesture.moveBy(const Offset(0, 7.2));
        }
        await gesture.up();
        await tester.pumpAndSettle();
        expect(pointerTimes, hasLength(2));
        expect(pointerTimes, [Duration.zero, Duration.zero]);
        expect(moves, 10);
        expect(cancels, 0);
        expect(find.text('Open isolated page'), findsOneWidget);
        expect(find.byType(SeedMenuSheet), findsNothing);

        // The same 72px drag with actual positive elapsed time must NOT
        // dismiss: it is below the 25% source distance fallback.
        await tester.tap(find.text('Open isolated page'));
        await tester.pumpAndSettle();
        final slowRect = tester.getRect(find.byType(SeedMenuSheet));
        final slow = await tester.startGesture(
          Offset(slowRect.center.dx, slowRect.top + 12),
          kind: PointerDeviceKind.mouse,
        );
        for (var i = 1; i <= 10; i++) {
          await slow.moveBy(
            const Offset(0, 7.2),
            timeStamp: Duration(milliseconds: 95 * i),
          );
        }
        await slow.up(timeStamp: const Duration(milliseconds: 950));
        await tester.pumpAndSettle();
        expect(find.byType(SeedMenuSheet), findsOneWidget);

        // Flutter pointer cancellation must never be mistaken for release.
        final cancelled = await tester.startGesture(
          Offset(slowRect.center.dx, slowRect.top + 12),
          kind: PointerDeviceKind.mouse,
        );
        for (var i = 0; i < 10; i++) {
          await cancelled.moveBy(const Offset(0, 7.2));
        }
        await cancelled.cancel();
        await tester.pumpAndSettle();
        expect(find.byType(SeedMenuSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('Browser-like mouse down/10 moves/up 72px closes at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedMenuSheet<void>(
                  context: context,
                  title: 'Actions',
                  showCancelButton: false,
                  groups: const [
                    SeedMenuGroupData(
                      items: [SeedMenuItemData(label: 'Test1')],
                    ),
                  ],
                ),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      final r = tester.getRect(find.byType(SeedMenuSheet));
      final gesture = await tester.startGesture(
        Offset(r.center.dx, r.top + 12),
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, 7.2));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('SwipeableMenuSheet 72px fast handle drag dismisses at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);

      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedMenuSheet<void>(
                  context: context,
                  enableDrag: true,
                  showHandle: true,
                  showCancelButton: false,
                  title: 'Actions',
                  groups: [
                    const SeedMenuGroupData(
                      items: [
                        SeedMenuItemData(label: 'Add'),
                        SeedMenuItemData(
                          label: 'Edit Proident pariatur do cillum labore nisi ex velit fugiat laboris pariatur consequat mollit ex culpa cillum.',
                          description: 'Aliqua reprehenderit nostrud ea laborum. Aliquip qui sint amet nulla aliqua mollit consequat sint nostrud cupidatat nisi.',
                        ),
                      ],
                    ),
                    SeedMenuGroupData(
                      items: [
                        const SeedMenuItemData(label: 'Test1'),
                        SeedMenuItemData(
                          label: 'Test2',
                          onTap: () => selected++,
                        ),
                        const SeedMenuItemData(
                          label: 'Adipisicing commodo et ex ad reprehenderit. Excepteur sint aute voluptate id.',
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byType(SeedMenuSheet));
      expect(
        rect.height,
        greaterThan(288),
        reason: '72px is below React 25% sheet-height dismissal threshold',
      );
      await tester.timedDragFrom(
        Offset(rect.center.dx, rect.top + 8),
        const Offset(0, 72),
        const Duration(milliseconds: 950),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(SeedMenuSheet),
        findsOneWidget,
        reason: 'a 72px slow drag below 25% must reset without closing',
      );
      await tester.timedDragFrom(
        Offset(rect.center.dx, rect.top + 8),
        const Offset(0, 72),
        const Duration(milliseconds: 120),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsNothing);
      expect(selected, 0, reason: 'drag must not invoke the menu item');
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test2'));
      await tester.pumpAndSettle();
      expect(
        selected,
        1,
        reason: 'a normal action click must reach its callback',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'MenuSheet non-swipeable selection closes with one callback at $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        var selected = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  child: const Text('Open sheet'),
                  onPressed: () => showSeedMenuSheet<void>(
                    context: context,
                    title: 'Actions',
                    enableDrag: false,
                    showHandle: false,
                    groups: [
                      SeedMenuGroupData(
                        items: [
                          SeedMenuItemData(
                            label: 'Test1',
                            onTap: () => selected++,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open sheet'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test1'));
        await tester.pumpAndSettle();
        expect(selected, 1);
        expect(find.byType(SeedMenuSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Explicitly non-dismissible swipeable sheet ignores handle drag at $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  child: const Text('Open sheet'),
                  onPressed: () => showSeedMenuSheet<void>(
                    context: context,
                    title: 'Actions',
                    enableDrag: true,
                    isDismissible: false,
                    showCancelButton: false,
                    groups: const [
                      SeedMenuGroupData(
                        items: [SeedMenuItemData(label: 'Test1')],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open sheet'));
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byType(SeedMenuSheet));
        await tester.timedDragFrom(
          Offset(rect.center.dx, rect.top + 8),
          const Offset(0, 72),
          const Duration(milliseconds: 120),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SeedMenuSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
