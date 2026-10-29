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
}
