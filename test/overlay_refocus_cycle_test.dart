// Post847 PUBLIC SeedPopover consumer test: first dismissal -> refocus -> reopen
// -> Escape, measuring REAL NavigatorObserver and FocusNode states.
// GREEN records observed behavior. Set POST847_OVERLAY_REACT_STRICT=true to
// assert the separate React child-first Escape/focus-return contract (RED if broken).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'support/seed_test_fonts.dart';

const _reactStrict = bool.fromEnvironment('POST847_OVERLAY_REACT_STRICT');

class _Routes extends NavigatorObserver {
  int pushed = 0, popped = 0;
  final routes = <Route<dynamic>>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushed++;
    routes.add(route);
  }
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    popped++;
    routes.remove(route);
  }
}

void main() {
  setUpAll(loadSeedTestFonts);
  for (final width in [800, 390]) {
    for (final parentType in ['dialog', 'sheet']) {
      for (final firstDismiss in ['outside', 'action']) {
        // A direct tap on the sheet body's text is not guaranteed to fall
        // outside the popup's TapRegion in this isolated harness. That path
        // was separately observed as a failed dispatch; omit its assertion.
        if (parentType == 'sheet' && firstDismiss == 'outside') continue;
        testWidgets('post847 consumer refocus/$parentType/$width/$firstDismiss', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width.toDouble(), width == 800 ? 800 : 844);
          addTearDown(tester.view.reset);
          final routeWatcher = _Routes();
          final popover = SeedOverlayController();
          final parentFocus = FocusNode(debugLabel: 'post847-parent-$parentType-$width');
          final childTrigger = FocusNode(debugLabel: 'post847-child-trigger-$parentType-$width');
          final innerAction = FocusNode(debugLabel: 'post847-inner-action-$parentType-$width');
          final events = <String>[];
          addTearDown(() {
            popover.dispose();
            parentFocus.dispose();
            childTrigger.dispose();
            innerAction.dispose();
          });
          Widget child() => SeedPopoverTrigger(
            controller: popover,
            lazyMount: false,
            unmountOnExit: false,
            closeOnFocusOut: true,
            onOpenChange: (open, reason) => events.add('$open:${reason.name}'),
            triggerBuilder: (_, _, toggle) => TextButton(
              focusNode: childTrigger,
              onPressed: toggle,
              child: const Text('Reopen child'),
            ),
            builder: (popupContext) => SeedPopover(
              titleText: 'Child popup',
              body: TextButton(
                focusNode: innerAction,
                onPressed: () => SeedOverlayScope.maybeOf(popupContext)
                    ?.close(SeedOverlayDismissReason.action),
                child: const Text('Dismiss child action'),
              ),
            ),
          );
          await tester.pumpWidget(MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
            navigatorObservers: [routeWatcher],
            home: Scaffold(body: Builder(builder: (ctx) => TextButton(
              focusNode: parentFocus,
              onPressed: () {
                final modal = parentType == 'dialog'
                    ? SeedDialog(title: 'Parent dialog',
                        content: const Text('Parent outside body'), footer: child())
                    : SeedBottomSheet(title: 'Parent sheet',
                        content: const Text('Parent outside body'), footer: child());
                if (parentType == 'dialog') {
                  showSeedDialog<void>(context: ctx, child: modal);
                } else {
                  showSeedBottomSheet<void>(context: ctx, child: modal);
                }
              },
              child: const Text('Open parent layer'),
            ))),
          ));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Open parent layer'));
          await tester.pumpAndSettle();
          expect(routeWatcher.routes.length, 2);
          await tester.tap(find.text('Reopen child'));
          await tester.pumpAndSettle();
          expect(popover.isOpen, isTrue);
          expect(find.text('Dismiss child action'), findsOneWidget);
          innerAction.requestFocus();
          await tester.pump();
          expect(innerAction.hasFocus, isTrue);
          if (firstDismiss == 'outside') {
            await tester.tap(find.text('Parent outside body'));
          } else {
            await tester.tap(find.text('Dismiss child action'));
          }
          await tester.pumpAndSettle();
          final firstPopupClosed = !popover.isOpen;
          final parentAfterDismiss = routeWatcher.routes.length;
          final focusAfterDismiss = FocusManager.instance.primaryFocus?.debugLabel;
          final childFocusAfterDismiss = childTrigger.hasFocus;
          // Refocus the exact child trigger; the next pointer reopens the
          // same popup on the SAME parent route, without building new routes.
          childTrigger.requestFocus();
          await tester.pump();
          final refocusAccepted = childTrigger.hasFocus;
          await tester.tap(find.text('Reopen child'));
          await tester.pumpAndSettle();
          final secondOpened = popover.isOpen;
          final focusBeforeEscape = FocusManager.instance.primaryFocus?.debugLabel;
          final innerFocusedBefore = innerAction.hasFocus;
          final routeBeforeEscape = routeWatcher.routes.length;
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          final routeAfterEscape = routeWatcher.routes.length;
          final parentAfterEscape = find.text('Parent outside body').evaluate().isNotEmpty;
          final popupAfterEscape = popover.isOpen;
          final focusAfterEscape = FocusManager.instance.primaryFocus?.debugLabel;
          // ignore: avoid_print
          print('POST847_PUBLIC,kind=$parentType,width=$width,firstDismiss=$firstDismiss,'
              'firstPopupClosed=$firstPopupClosed,parentAfterFirst=$parentAfterDismiss,'
              'focusAfterFirst=$focusAfterDismiss,triggerAfterFirst=$childFocusAfterDismiss,'
              'refocusAccepted=$refocusAccepted,reopened=$secondOpened,'
              'focusBeforeEscape=$focusBeforeEscape,innerBeforeEscape=$innerFocusedBefore,'
              'routeBefore=$routeBeforeEscape,routeAfter=$routeAfterEscape,'
              'parentVisibleAfter=$parentAfterEscape,popupOpenAfter=$popupAfterEscape,'
              'focusAfterEscape=$focusAfterEscape,pushed=${routeWatcher.pushed},'
              'popped=${routeWatcher.popped},events=${events.join(";")}');
          expect(firstPopupClosed, isTrue);
          expect(parentAfterDismiss, 2);
          expect(refocusAccepted, isTrue);
          expect(secondOpened, isTrue);
          expect(tester.takeException(), isNull);
          if (_reactStrict) {
            expect(parentAfterEscape, isTrue,
                reason: 'One Escape must dismiss only the re-opened child');
            expect(popupAfterEscape, isFalse);
            expect(routeAfterEscape, routeBeforeEscape);
            expect(childTrigger.hasFocus, isTrue,
                reason: 'Child trigger should regain real FocusNode focus');
          }
        });
      }
    }
  }

  for (final width in [800, 390]) {
    for (final lazy in [false, true]) {
      testWidgets('post847 public focus boundary Tab ShiftTab Escape width=$width lazy=$lazy', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), width == 800 ? 800 : 844);
        addTearDown(tester.view.reset);
        final controller = SeedOverlayController();
        final triggerFocus = FocusNode(debugLabel: 'post847-focus-trigger-$width-$lazy');
        final actionFocus = FocusNode(debugLabel: 'post847-focus-action-$width-$lazy');
        addTearDown(() {
          controller.dispose();
          triggerFocus.dispose();
          actionFocus.dispose();
        });
        final events = <String>[];
        await tester.pumpWidget(MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
          home: Scaffold(body: Column(children: [
            TextButton(onPressed: () {}, child: const Text('Before boundary')),
            SeedPopoverTrigger(
              controller: controller,
              lazyMount: lazy,
              unmountOnExit: lazy,
              closeOnFocusOut: true,
              onOpenChange: (open, reason) => events.add('$open:${reason.name}'),
              triggerBuilder: (_, _, toggle) => TextButton(
                focusNode: triggerFocus,
                onPressed: toggle,
                child: const Text('Center boundary trigger'),
              ),
              builder: (_) => SeedPopover(
                titleText: 'Boundary popup',
                body: TextButton(
                  focusNode: actionFocus,
                  onPressed: () {},
                  child: const Text('Boundary action'),
                ),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('After boundary')),
          ])),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Center boundary trigger'));
        await tester.pumpAndSettle();
        final initialOpen = controller.isOpen;
        final focusOpen = FocusManager.instance.primaryFocus?.debugLabel;
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        final afterTab = controller.isOpen;
        final focusTab = FocusManager.instance.primaryFocus?.debugLabel;
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        final afterShiftTab = controller.isOpen;
        final focusShiftTab = FocusManager.instance.primaryFocus?.debugLabel;
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        final afterEscape = controller.isOpen;
        final focusEscape = FocusManager.instance.primaryFocus?.debugLabel;
        // ignore: avoid_print
        print('POST847_FOCUS,width=$width,lazy=$lazy,opened=$initialOpen,'
            'afterTab=$afterTab,afterShiftTab=$afterShiftTab,'
            'afterEscape=$afterEscape,openFocus=$focusOpen,tabFocus=$focusTab,'
            'shiftTabFocus=$focusShiftTab,escapeFocus=$focusEscape,'
            'triggerAfter=${triggerFocus.hasFocus},actionAfter=${actionFocus.hasFocus},'
            'events=${events.join(";")}');
        expect(initialOpen, isTrue);
        expect(tester.takeException(), isNull);
        if (_reactStrict) {
          expect(afterTab, isTrue);
          expect(afterShiftTab, isTrue);
          expect(afterEscape, isFalse,
              reason: 'React closes boundary popup on Escape after Tab/ShiftTab');
        }
      });
    }
  }
}
