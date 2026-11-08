import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  setUpAll(loadSeedTestFonts);
  testWidgets('an item runs its action and a disabled one does not', (
    tester,
  ) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      _app(
        SeedMenu(
          groups: [
            SeedMenuGroupData(
              items: [
                SeedMenuItemData(label: 'Edit', onTap: () => tapped.add('e')),
                SeedMenuItemData(
                  label: 'Delete',
                  enabled: false,
                  onTap: () => tapped.add('d'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.byType(InkWell), findsNothing);
    await tester.tap(find.text('Edit'));
    await tester.tap(find.text('Delete'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tapped, ['e']);
  });
  SeedPressable pressableOf(WidgetTester tester, String text) =>
      tester.widget<SeedPressable>(
        find
            .ancestor(of: find.text(text), matching: find.byType(SeedPressable))
            .first,
      );

  Widget menu() => SeedAnchoredOverlay(
    triggerBuilder: (context, open, toggle) =>
        SeedButton(label: 'Open', onPressed: toggle),
    overlayBuilder: (context) => const SeedMenu(
      groups: [
        SeedMenuGroupData(
          items: [
            SeedMenuItemData(label: 'First'),
            SeedMenuItemData(label: 'Second'),
          ],
        ),
      ],
    ),
  );

  testWidgets('a pointer-opened menu activates nothing until an arrow key', (
    tester,
  ) async {
    await tester.pumpWidget(_app(menu()));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(pressableOf(tester, 'First').focusNode?.hasPrimaryFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(pressableOf(tester, 'First').focusNode?.hasPrimaryFocus, isTrue);
  });

  testWidgets('a keyboard-opened menu activates its first item', (
    tester,
  ) async {
    await tester.pumpWidget(_app(menu()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(pressableOf(tester, 'First').focusNode?.hasPrimaryFocus, isTrue);
  });

  testWidgets('a long menu shrinks below its trigger before flipping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 500),
            child: SeedMenuTrigger(
              triggerBuilder: (context, open, toggle) =>
                  SeedButton(label: 'Open', onPressed: toggle),
              builder: (context) => SeedMenu(
                groups: [
                  SeedMenuGroupData(
                    items: [
                      for (var i = 0; i < 30; i++)
                        SeedMenuItemData(label: 'Item $i'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final trigger = tester.getRect(find.byType(SeedButton));
    final menu = tester.getRect(find.byType(SeedMenu));
    expect(menu.top, greaterThanOrEqualTo(trigger.bottom));
    expect(menu.bottom, lessThanOrEqualTo(844));
  });

  testWidgets('a modal barrier tap closes an open Menu first', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSeedBottomSheet<void>(
                context: context,
                builder: (_) => SeedBottomSheet(
                  title: 'Layer',
                  content: SeedMenuTrigger(
                    triggerBuilder: (context, open, toggle) =>
                        TextButton(onPressed: toggle, child: const Text('M')),
                    builder: (_) => const SeedMenu(
                      groups: [
                        SeedMenuGroupData(
                          items: [SeedMenuItemData(label: 'Item')],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: const Text('Launch'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Launch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('M'));
    await tester.pumpAndSettle();
    expect(find.text('Item'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Item'), findsNothing);
    expect(find.text('Layer'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Layer'), findsNothing);
  });
  group('close reasons', () {
    setUpAll(loadSeedTestFonts);

    for (final width in [390.0, 800.0]) {
      testWidgets(
        'Menu item activation closes with React itemClick reason $width',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 844);
          addTearDown(tester.view.reset);
          final events = <(bool, String)>[];
          var activations = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: SeedMenuTrigger(
                  onOpenChange: (open, reason) =>
                      events.add((open, reason.name)),
                  triggerBuilder: (_, open, toggle) => TextButton(
                    onPressed: toggle,
                    child: const Text('Open menu'),
                  ),
                  builder: (_) => SeedMenu(
                    groups: [
                      SeedMenuGroupData(
                        items: [
                          const SeedMenuItemData(
                            label: 'Disabled',
                            enabled: false,
                          ),
                          SeedMenuItemData(
                            label: 'Action',
                            onTap: () => activations++,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open menu'));
          await tester.pumpAndSettle();
          expect(events.last, (true, 'trigger'));
          await tester.tap(find.text('Action'));
          await tester.pumpAndSettle();
          expect(activations, 1);
          expect(find.text('Action'), findsNothing);
          expect(events.last, (
            false,
            'itemClick',
          ), reason: 'React useMenu.ts reports item activation as itemClick');
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'closeOnSelect false keeps menu open and does not report itemClick',
      (tester) async {
        final events = <(bool, String)>[];
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: SeedMenuTrigger(
                onOpenChange: (open, reason) => events.add((open, reason.name)),
                triggerBuilder: (_, open, toggle) => TextButton(
                  onPressed: toggle,
                  child: const Text('Open menu'),
                ),
                builder: (_) => SeedMenu(
                  closeOnSelect: false,
                  groups: [
                    SeedMenuGroupData(
                      items: [
                        SeedMenuItemData(label: 'Stay', onTap: () => taps++),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Stay'));
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(find.text('Stay'), findsOneWidget);
        expect(events, [(true, 'trigger')]);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('MenuSheet gestures', () {
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
      testWidgets(
        'SwipeableMenuSheet 72px fast handle drag dismisses at $size',
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
        },
      );

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
  });

  group('arrow navigation', () {
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
  });

  group('placement and Tab', () {
    setUpAll(loadSeedTestFonts);

    // React headless Popover.tsx:174-189 uses
    // closeOnFocusOut={api.closeOnInteractOutside}, so an explicitly persistent
    // popover must not disappear merely because another control gains focus.
    for (final viewport in [const Size(390, 844), const Size(800, 800)]) {
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
        'short Menu stays below when it fits under the 200px minimum $viewport',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport;
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
                      left: 16,
                      top: viewport.height - 160,
                      child: SeedMenuTrigger(
                        controller: controller,
                        skipAnimation: true,
                        triggerBuilder: (context, open, toggle) => TextButton(
                          onPressed: toggle,
                          child: const Text('Reason anchor'),
                        ),
                        builder: (context) => const SeedMenu(
                          groups: [
                            SeedMenuGroupData(
                              items: [SeedMenuItemData(label: 'Only entry')],
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
          await tester.tap(find.text('Reason anchor'));
          await tester.pumpAndSettle();
          final menu = tester.getRect(find.byType(SeedMenu));
          final anchor = tester.getRect(
            find.ancestor(
              of: find.text('Reason anchor'),
              matching: find.byType(TextButton),
            ),
          );
          // React useMenu: size() caps at max(200, available) before flip(),
          // so a one-item menu with ~110px below keeps its bottom placement.
          expect(viewport.height - anchor.bottom, lessThan(200));
          expect(menu.top, greaterThan(anchor.bottom));
          expect(menu.bottom, lessThanOrEqualTo(viewport.height - 8));
        },
      );
    }

    for (final width in [390.0, 800.0]) {
      testWidgets('Menu Tab exits nested dialog and focuses Confirm $width', (
        tester,
      ) async {
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
      });
    }
  });

  group('Tab leaves the menu', () {
    Widget page({
      required SeedOverlayController menu,
      required FocusNode after,
      bool skipTrigger = false,
      bool ownScope = false,
      bool ordered = false,
    }) {
      Widget trigger = SeedMenuTrigger(
        controller: menu,
        skipAnimation: true,
        triggerBuilder: (_, _, toggle) => skipTrigger
            ? Focus(
                skipTraversal: true,
                child: GestureDetector(
                  onTap: toggle,
                  child: const Text('Open'),
                ),
              )
            : TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => const SeedMenu(
          groups: [
            SeedMenuGroupData(items: [SeedMenuItemData(label: 'Item')]),
          ],
        ),
      );
      if (ownScope) trigger = FocusScope(child: trigger);
      final next = TextButton(
        focusNode: after,
        onPressed: () {},
        child: const Text('After'),
      );
      return MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                if (ordered)
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: next,
                  ),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: trigger,
                ),
                if (!ordered) next,
              ],
            ),
          ),
        ),
      );
    }

    for (final (name, skip, scope, ordered) in [
      ('trigger skips traversal', true, false, false),
      ('trigger in its own scope', false, true, false),
      ('custom traversal order', false, false, true),
    ]) {
      testWidgets('closes and moves on: $name', (tester) async {
        final menu = SeedOverlayController();
        final after = FocusNode(debugLabel: 'after');
        addTearDown(() {
          menu.dispose();
          after.dispose();
        });
        await tester.pumpWidget(
          page(
            menu: menu,
            after: after,
            skipTrigger: skip,
            ownScope: scope,
            ordered: ordered,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(menu.isOpen, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(menu.isOpen, isFalse);
        if (!scope) expect(after.hasPrimaryFocus, isTrue);
        expect(find.text('Item'), findsNothing);
      });
    }
  });
}
