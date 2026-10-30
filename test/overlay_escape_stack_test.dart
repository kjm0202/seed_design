// Round3 isolated PUBLIC API probe: overlay popup Escape vs parent Navigator.
// This is an observational Flutter widget test, not a React browser PASS.
// Run optional strict mode with --dart-define=ROUND3_OVERLAY_REACT_STRICT=true
// to enforce React's child-only first Escape contract separately.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'support/seed_test_fonts.dart';

const _strict = bool.fromEnvironment('ROUND3_OVERLAY_REACT_STRICT');

class _RouteWatch extends NavigatorObserver {
  int pushed = 0;
  int popped = 0;
  final active = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushed++;
    active.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    popped++;
    active.remove(route);
  }
}

void main() {
  setUpAll(loadSeedTestFonts);
  for (final width in [800, 390]) {
    for (final kind in ['dialog', 'sheet']) {
      for (final focusMode in ['explicit', 'auto']) {
      for (final mountMode in ['retain', 'unmount']) {
      testWidgets('Round3 nested popup Escape Navigator and FocusNode $kind $width $focusMode $mountMode', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), width == 800 ? 800 : 844);
        addTearDown(tester.view.reset);
        final observer = _RouteWatch();
        final openEvents = <String>[];
        final parentFocus = FocusNode(debugLabel: 'round3-parent-trigger-$kind-$width');
        final childFocus = FocusNode(debugLabel: 'round3-child-trigger-$kind-$width');
        final innerActionFocus = FocusNode(debugLabel: 'round3-inner-action-$kind-$width');
        addTearDown(() {
          parentFocus.dispose();
          childFocus.dispose();
          innerActionFocus.dispose();
        });

        Widget child() => SeedPopoverTrigger(
          lazyMount: mountMode == 'unmount',
          unmountOnExit: mountMode == 'unmount',
          onOpenChange: (open, reason) => openEvents.add('$open:${reason.name}'),
          triggerBuilder: (_, _, toggle) => TextButton(
            focusNode: childFocus,
            onPressed: toggle,
            child: const Text('R3 open popup'),
          ),
          builder: (_) => SeedPopover(
            titleText: 'R3 child popover',
            body: TextButton(
              focusNode: innerActionFocus,
              onPressed: () {},
              child: const Text('R3 inner action'),
            ),
          ),
        );

        await tester.pumpWidget(MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
          navigatorObservers: [observer],
          home: Scaffold(
            body: Align(
              alignment: Alignment.center,
              child: Builder(builder: (rootContext) {
                Widget parent() => kind == 'dialog'
                    ? SeedDialog(
                        title: 'R3 Parent Dialog',
                        content: const Text('R3 parent alive dialog'),
                        footer: child(),
                      )
                    : SeedBottomSheet(
                        title: 'R3 Parent Sheet',
                        showHandle: true,
                        content: const Text('R3 parent alive sheet'),
                        footer: child(),
                      );
                // Wrapped in a builder so the popup inherits the parent modal route.
                void showParent() {
                  if (kind == 'dialog') {
                    showSeedDialog<void>(context: rootContext, child: parent());
                  } else {
                    showSeedBottomSheet<void>(context: rootContext, child: parent());
                  }
                }
                return TextButton(
                  focusNode: parentFocus,
                  onPressed: showParent,
                  child: const Text('R3 open parent'),
                );
              }),
            ),
          ),
        ));
        // Actual Popover consumer embedded in the modal footer, with an
        // explicit focusable inner action for genuine FocusNode observations.
        await tester.pumpAndSettle();
        await tester.tap(find.text('R3 open parent'));
        await tester.pumpAndSettle();
        expect(find.text(kind == 'dialog' ? 'R3 parent alive dialog' : 'R3 parent alive sheet'), findsOneWidget);
        final navigatorAfterParent = observer.active.length;
        expect(navigatorAfterParent, greaterThanOrEqualTo(2));

        await tester.tap(find.text('R3 open popup'));
        await tester.pumpAndSettle();
        expect(find.text('R3 inner action'), findsOneWidget);
        final navigatorAfterChild = observer.active.length;
        if (focusMode == 'explicit') {
          innerActionFocus.requestFocus();
          await tester.pump();
        }
        final innerActionFocused = innerActionFocus.hasFocus;
        final primaryBeforeEscape = FocusManager.instance.primaryFocus?.debugLabel;
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        final parentStillVisible = find.text(kind == 'dialog' ? 'R3 parent alive dialog' : 'R3 parent alive sheet').evaluate().isNotEmpty;
        final innerStillVisible = find.text('R3 inner action').evaluate().isNotEmpty;
        final navigatorAfterEscape = observer.active.length;
        final innerTriggerFocused = childFocus.hasFocus;
        final primaryAfterFirst = FocusManager.instance.primaryFocus?.debugLabel;
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        final navigatorAfterSecondEscape = observer.active.length;
        final parentAfterSecondEscape = find.text(kind == 'dialog' ? 'R3 parent alive dialog' : 'R3 parent alive sheet').evaluate().isNotEmpty;
        // ignore: avoid_print
        print('ROUND3_PUBLIC,$kind,width=$width,focusMode=$focusMode,mountMode=$mountMode,routeParent=$navigatorAfterParent,'
            'routeChild=$navigatorAfterChild,routeEscape=$navigatorAfterEscape,'
            'routeSecondEscape=$navigatorAfterSecondEscape,parentSecondEscape=$parentAfterSecondEscape,'
            'pushed=${observer.pushed},popped=${observer.popped},'
            'parentVisible=$parentStillVisible,childVisible=$innerStillVisible,'
            'innerActionFocusedBefore=$innerActionFocused,'
            'primaryBefore=$primaryBeforeEscape,'
            'triggerFocusedAfter=$innerTriggerFocused,'
            'parentTriggerFocus=${parentFocus.hasFocus},'
            'primaryAfterFirst=$primaryAfterFirst,primary=${FocusManager.instance.primaryFocus?.debugLabel},'
            'openEvents=${openEvents.join(";")}');
        expect(tester.takeException(), isNull);
        if (_strict) {
          if (focusMode == 'explicit') {
            expect(innerActionFocused, isTrue, reason: 'Real child FocusNode starts Escape');
          }
          expect(innerStillVisible, isFalse, reason: 'One Escape closes child popup');
          expect(parentStillVisible, isTrue, reason: 'React retains parent Navigator layer after one Escape');
          expect(navigatorAfterEscape, navigatorAfterParent,
              reason: 'The parent Navigator route must not be popped by child Escape');
          expect(innerTriggerFocused, isTrue, reason: 'React expects focus returned to the child trigger');
        }
      });
      }
      }
    }
  }

  // The official React Accordion keeps its floating child Menu open when a
  // controlled parent collapses. Escape still dismisses that Menu even though
  // the Accordion trigger/content have become non-focusable. This is distinct
  // from the existing dialog/sheet Escape tests.
  for (final width in [390.0, 800.0]) {
    testWidgets('Accordion-controlled collapse retains nested Menu Escape $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late StateSetter updateParent;
      Set<String> values = {'a'};
      bool enabled = true;
      final controller = SeedOverlayController();
      final events = <String>[];
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: SizedBox(
              width: 350,
              child: StatefulBuilder(
                builder: (_, update) {
                  updateParent = update;
                  return SeedAccordion(
                    values: values,
                    enabled: enabled,
                    items: [
                      SeedAccordionItem(
                        value: 'a',
                        title: 'Accordion parent',
                        content: SeedMenuTrigger(
                          controller: controller,
                          skipAnimation: true,
                          onOpenChange: (open, reason) =>
                              events.add('$open:${reason.name}'),
                          triggerBuilder: (_, _, toggle) => TextButton(
                            onPressed: toggle,
                            child: const Text('Inner menu trigger'),
                          ),
                          builder: (_) => const SeedMenu(
                            groups: [
                              SeedMenuGroupData(
                                items: [SeedMenuItemData(label: 'Menu action')],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inner menu trigger'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);
      updateParent(() {
        values = {};
        enabled = false;
      });
      await tester.pumpAndSettle();
      expect(
        controller.isOpen,
        isTrue,
        reason: 'Controlled parent may collapse without dismissing nested Menu',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      // ignore: avoid_print
      print(
        'R13_TRACKED_MENU_ESCAPE width=$width open=${controller.isOpen} events=$events',
      );
      expect(
        controller.isOpen,
        isFalse,
        reason: 'Escape must reach the open Menu after parent loses focus',
      );
      expect(events, ['true:trigger', 'false:escapeKey']);
    });
  }

  // Route-scoped fallback must dismiss just the topmost orphaned Menu. It
  // must then release the scope handler once the final Menu closes.
  for (final width in [390.0, 800.0]) {
    testWidgets('Accordion collapsed stacked Menus Escape in LIFO order $width', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late StateSetter updateParent;
      bool collapsed = false;
      final first = SeedOverlayController();
      final second = SeedOverlayController();
      final events = <String>[];
      addTearDown(() {
        first.dispose();
        second.dispose();
      });

      Widget menu(String label, SeedOverlayController controller) =>
          SeedMenuTrigger(
            controller: controller,
            skipAnimation: true,
            onOpenChange: (open, reason) =>
                events.add('$label:$open:${reason.name}'),
            triggerBuilder: (_, _, toggle) => TextButton(
              onPressed: toggle,
              child: Text(label),
            ),
            builder: (_) => SeedMenu(
              groups: [
                SeedMenuGroupData(
                  items: [SeedMenuItemData(label: '$label item')],
                ),
              ],
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: SizedBox(
              width: 350,
              child: StatefulBuilder(builder: (_, update) {
                updateParent = update;
                return SeedAccordion(
                  values: collapsed ? const {} : const {'a'},
                  enabled: !collapsed,
                  items: [
                    SeedAccordionItem(
                      value: 'a',
                      title: 'Parent',
                      content: Column(
                        children: [
                          menu('first', first),
                          menu('second', second),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      first.open();
      await tester.pumpAndSettle();
      second.open();
      await tester.pumpAndSettle();
      expect(first.isOpen, isTrue);
      expect(second.isOpen, isTrue);
      updateParent(() => collapsed = true);
      await tester.pumpAndSettle();
      expect(first.isOpen, isTrue);
      expect(second.isOpen, isTrue);
      // Parent route scope owns the scoped Escape handler. A collapsed body
      // can legitimately leave primaryFocus null while two portals remain
      // open; never infer the owning scope from that transient focus state.
      final scope = FocusScope.of(tester.element(find.text('Parent')));
      expect(scope.onKeyEvent, isNotNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(second.isOpen, isFalse);
      expect(first.isOpen, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(first.isOpen, isFalse);
      expect(scope.onKeyEvent, isNull,
          reason: 'Route FocusScope handler must be restored after final close');
      expect(events, [
        'second:false:escapeKey',
        'first:false:escapeKey',
      ]);
    });
  }

  // Round13 post-8788661: a controlled multiple->single Accordion can hide
  // its still-open Menu. React keeps the trigger programmatically focusable
  // without exposing other hidden content to pointer/AX/Tab traversal.
  for (final width in [390.0, 800.0]) {
    for (final action in ['tab', 'shiftTab', 'escape', 'reenable']) {
      testWidgets('Accordion hidden Menu $action preserves focus $width', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        Set<String> values = {'a', 'c'};
        bool enabled = true;
        bool multiple = true;
        late StateSetter updateParent;
        final controller = SeedOverlayController();
        final trigger = FocusNode(debugLabel: 'collapsed-menu-trigger');
        final hiddenIdle = FocusNode(debugLabel: 'collapsed-hidden-control');
        final outside = FocusNode(debugLabel: 'outside');
        final events = <String>[];
        addTearDown(() {
          controller.dispose();
          trigger.dispose();
          hiddenIdle.dispose();
          outside.dispose();
        });
        await tester.pumpWidget(MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
          home: Scaffold(body: Column(children: [
            TextButton(focusNode: outside, onPressed: () {},
              child: const Text('Outside')),
            SizedBox(width: 340, child: StatefulBuilder(builder: (_, update) {
              updateParent = update;
              return SeedAccordion(
                values: values, multiple: multiple, enabled: enabled,
                items: [
                  SeedAccordionItem(value: 'a', title: 'Parent A',
                    content: Column(children: [
                      SeedMenuTrigger(
                        controller: controller, skipAnimation: true,
                        onOpenChange: (open, reason) =>
                            events.add('$open:${reason.name}'),
                        triggerBuilder: (_, _, toggle) => TextButton(
                          focusNode: trigger, onPressed: toggle,
                          child: const Text('Child Menu')),
                        builder: (_) => const SeedMenu(groups: [
                          SeedMenuGroupData(items: [
                            SeedMenuItemData(label: 'Action'),
                          ]),
                        ]),
                      ),
                      TextButton(focusNode: hiddenIdle, onPressed: () {},
                        child: const Text('Idle hidden button')),
                    ]),
                  ),
                  const SeedAccordionItem(
                    value: 'c', title: 'Parent C', content: Text('Content C')),
                ],
              );
            })),
          ])),
        ));
        await tester.pumpAndSettle();
        final semantics = tester.ensureSemantics();
        try {
          await tester.tap(find.text('Child Menu'));
          await tester.pumpAndSettle();
          expect(controller.isOpen, isTrue);
          updateParent(() {
            multiple = false;
            values = {'c', 'a'};
            enabled = false;
          });
          await tester.pumpAndSettle();
          expect(controller.isOpen, isTrue);
          expect(trigger.canRequestFocus, isTrue);
          expect(trigger.skipTraversal, isTrue);
          expect(hiddenIdle.skipTraversal, isTrue);
          expect(find.text('Idle hidden button').hitTestable(), findsNothing);
          final semanticsTree = tester.binding.rootPipelineOwner.semanticsOwner
              ?.rootSemanticsNode?.toStringDeep() ?? '';
          expect(semanticsTree.contains('Idle hidden button'), isFalse);

          if (action == 'reenable') {
            updateParent(() {
              multiple = true;
              values = {'a', 'c'};
              enabled = true;
            });
            await tester.pumpAndSettle();
            expect(trigger.canRequestFocus, isTrue);
          } else if (action == 'shiftTab') {
            await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          }
          await tester.sendKeyEvent(
            action == 'tab' || action == 'shiftTab'
                ? LogicalKeyboardKey.tab
                : LogicalKeyboardKey.escape,
          );
          if (action == 'shiftTab') {
            await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          }
          await tester.pumpAndSettle();
          expect(trigger.hasFocus, isTrue,
            reason: 'React returns keyboard focus to the child Menu trigger');
          expect(controller.isOpen, action == 'shiftTab');
          if (action == 'tab') {
            expect(events, contains('false:focusOut'));
          } else if (action != 'shiftTab') {
            expect(events, contains('false:escapeKey'));
          }
          expect(hiddenIdle.hasFocus, isFalse);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      });
    }
  }
}
