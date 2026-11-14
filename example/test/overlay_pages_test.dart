// Frozen case: p5fup2-nav-390-responsive-panel-large-small-close-history.
// The real Flutter 390x844 responsive route shows a BottomSheet. This
// WidgetTester suite checks Activity state, not actual Chromium history.
// Frozen original case: p5fup2-nav-800-responsive-panel-large-small-close-history.
// Uses the actual SPA/SidePanel controls at 800x800. Flutter widget tests do
// not simulate an actual Chromium about:blank / native Forward document load.
import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_history.dart';
import 'package:seed_design_example/stackflow_spa/spa_types.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<NavigatorState> _open(
  WidgetTester tester,
  String route, {
  Size size = const Size(440, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pumpAndSettle();
  return navigator;
}

Future<void> _openDirect(WidgetTester tester, String path) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.binding.platformDispatcher.defaultRouteNameTestValue = path;
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
}

// Official JSX contracts:
// ActivitySidePanel.tsx:160-169 and
// ActivityResponsiveSidePanel.tsx:54-63.
// Both "확인" buttons have no onClick and therefore leave the panel open.
Future<void> _openNested(
  WidgetTester tester, {
  required String path,
  required double width,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(path);
  await tester.pumpAndSettle();
}

Future<void> _openAsRoot(WidgetTester tester, String path) async {
  tester.view.physicalSize = const Size(800, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();

  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': path, 'state': null}),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

Future<void> openOverlaySizingActivity(
  WidgetTester tester,
  String route, {
  Size viewport = const Size(800, 800),
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

Future<void> _directNested(WidgetTester tester) async {
  final completed = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('pushRouteInformation', {
        'location': '/nested-bottom-sheet',
        'state': null,
      }),
    ),
    (_) => completed.complete(),
  );
  await tester.pump();
  await completed.future;
  await tester.pumpAndSettle();
}

Future<void> _enterDirectResponsive(WidgetTester tester) async {
  final completed = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('pushRouteInformation', {
        'location': '/responsive-side-panel',
        'state': null,
      }),
    ),
    (_) => completed.complete(),
  );
  await tester.pump();
  await completed.future;
  await tester.pumpAndSettle();
}

Future<void> _visitDirect(WidgetTester tester) async {
  final delivered = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('pushRouteInformation', {
        'location': '/responsive-side-panel',
        'state': null,
      }),
    ),
    (_) => delivered.complete(),
  );
  await tester.pump();
  await delivered.future;
  await tester.pumpAndSettle();
}

Future<void> _route(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .pushNamed(route, arguments: arguments);
  await tester.pumpAndSettle();
}

Future<void> _direct(WidgetTester tester, String route) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': route, 'state': null}),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

Future<NavigatorState> open(WidgetTester tester, String route) async {
  tester.view.physicalSize = const Size(440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pumpAndSettle();
  return navigator;
}

Future<void> openStackflowSpaVisualFix(
  WidgetTester tester,
  String route, {
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

Future<void> openZzRestoreVisualFix(
  WidgetTester tester,
  String route, {
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

void main() {
  group('sheets, dialogs and popovers', () {
    testWidgets('MenuSheet Simple is swipeable and selection notifies parent', (
      tester,
    ) async {
      final navigator = await _open(tester, '/menu-sheet-activity');
      navigator.pushNamed('/menu-sheet-activity/simple');
      await tester.pumpAndSettle();
      final route = ModalRoute.of(tester.element(find.byType(SeedMenuSheet)))!;
      expect(route, isA<ModalBottomSheetRoute>());
      final widget = tester.widget<SeedMenuSheet>(find.byType(SeedMenuSheet));
      expect(widget.showCancelButton, isFalse);
      expect(find.text('닫기'), findsNothing);
      await tester.tap(find.text('수정'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsNothing);
      expect(find.textContaining('선택한 액션: edit'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MenuSheet Simple handle drag dismisses its activity', (
      tester,
    ) async {
      final navigator = await _open(tester, '/menu-sheet-activity');
      navigator.pushNamed('/menu-sheet-activity/simple');
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byType(SeedMenuSheet));
      await tester.timedDragFrom(
        Offset(rect.center.dx, rect.top + 8),
        const Offset(0, 400),
        const Duration(milliseconds: 320),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Nested AlertDialog ignores outside tap but confirms close', (
      tester,
    ) async {
      await _open(tester, '/nested-bottom-sheet');
      await tester.tap(find.widgetWithText(SeedButton, 'Open AlertDialog'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsOneWidget);
      await tester.tapAt(const Offset(10, 380));
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(SeedButton, '확인').last);
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsNothing);
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final width in [390.0, 1000.0]) {
      testWidgets('Responsive SidePanel confirm preserves layer at $width', (
        tester,
      ) async {
        await _open(tester, '/responsive-side-panel', size: Size(width, 900));
        expect(
          width < 768
              ? find.byType(SeedBottomSheet)
              : find.byType(SeedSidePanel),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(SeedButton, '확인').last);
        await tester.pumpAndSettle();
        expect(
          width < 768
              ? find.byType(SeedBottomSheet)
              : find.byType(SeedSidePanel),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Popover remains open while placement changes', (tester) async {
      await _open(tester, '/popover', size: const Size(800, 800));
      final trigger = find.widgetWithText(SeedButton, 'placement=bottom');
      await tester.ensureVisible(trigger);
      await tester.pumpAndSettle();
      await tester.tap(trigger);
      await tester.pumpAndSettle();
      expect(find.text('요청 placement: bottom'), findsOneWidget);

      final left = find.widgetWithText(SeedButton, 'left');
      // Exercising the same onPressed callback avoids an offscreen hit-test in
      // the widget harness while the floating popover remains open.
      tester.widget<SeedButton>(left).onPressed?.call();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SeedButton, 'placement=left'), findsOneWidget);
      expect(find.text('요청 placement: left'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Keyboard playground uses pixel snap and fixed is anchoring', (
      tester,
    ) async {
      await _open(tester, '/bottom-sheet-keyboard-playground');
      await tester.tap(find.text('fixed: off'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedBottomSheet>(find.byType(SeedBottomSheet)).expand,
        isFalse,
      );
      final snapToggle = find.text('snapPoints: off');
      await tester.ensureVisible(snapToggle);
      await tester.tap(snapToggle);
      await tester.pumpAndSettle();
      final sheet = tester.widget<SeedSnappingBottomSheet>(
        find.byType(SeedSnappingBottomSheet),
      );
      expect(sheet.snapPoints.first.pixels, 360);
      expect(sheet.snapPoints.last.fraction, 1);
      expect(tester.takeException(), isNull);
    });
    testWidgets('a directly entered sheet stays open like its React root', (
      tester,
    ) async {
      await _openDirect(tester, '/bottom-sheet');
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      await tester.tapAt(const Offset(195, 40));
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsOneWidget);
    });
  });

  group('SidePanel', () {
    for (final width in [390.0, 800.0]) {
      testWidgets('SidePanel confirming is inert at ${width.toInt()}px', (
        tester,
      ) async {
        await _openNested(tester, path: '/side-panel', width: width);
        expect(find.byType(SeedSidePanel), findsOneWidget);
        expect(find.widgetWithText(SeedButton, '확인'), findsOneWidget);

        // React has no onClick on this button. The existing open Activity and
        // controls must remain mounted after an actual pointer activation.
        await tester.tap(find.widgetWithText(SeedButton, '확인'));
        await tester.pumpAndSettle();

        expect(
          find.byType(SeedSidePanel),
          findsOneWidget,
          reason: 'React ActivitySidePanel confirm has no onClick/pop action',
        );
        expect(find.widgetWithText(SeedSwitch, '푸터 표시'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'nested SidePanel footer close still pops at ${width.toInt()}px',
        (tester) async {
          await _openNested(tester, path: '/side-panel', width: width);
          expect(find.byType(SeedSidePanel), findsOneWidget);
          await tester.tap(find.widgetWithText(SeedButton, '닫기'));
          await tester.pumpAndSettle();

          expect(find.byType(SeedSidePanel), findsNothing);
          expect(find.byType(CustomScrollView), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'ResponsiveSidePanel confirming is inert at ${width.toInt()}px',
        (tester) async {
          await _openNested(
            tester,
            path: '/responsive-side-panel',
            width: width,
          );
          if (width < 768) {
            expect(find.byType(SeedBottomSheet), findsOneWidget);
          } else {
            expect(find.byType(SeedSidePanel), findsOneWidget);
          }

          await tester.tap(find.widgetWithText(SeedButton, '확인'));
          await tester.pumpAndSettle();

          expect(find.widgetWithText(SeedButton, '확인'), findsOneWidget);
          expect(
            width < 768
                ? find.byType(SeedBottomSheet)
                : find.byType(SeedSidePanel),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final closeTarget in ['footer', 'header']) {
      testWidgets(
        'root SidePanel $closeTarget close preserves local controls',
        (tester) async {
          await _openAsRoot(tester, '/side-panel');
          expect(find.byType(SeedSidePanel), findsOneWidget);

          final sizeControl = tester.widget<SeedSegmentedControl<String>>(
            find.byWidgetPredicate(
              (w) =>
                  w is SeedSegmentedControl<String> &&
                  w.semanticsLabel == '패널 크기',
            ),
          );
          sizeControl.onValueChange?.call('small');
          await tester.pumpAndSettle();
          expect(
            tester.widget<SeedSidePanel>(find.byType(SeedSidePanel)).size,
            SeedSidePanelSize.small,
          );

          // Root Stackflow activity cannot pop. React's onOpenChange(false) and
          // footer close both run pop(), preserving React useState on a root.
          final close = closeTarget == 'footer'
              ? find.widgetWithText(SeedButton, '닫기')
              : find.descendant(
                  of: find.byType(SeedSidePanel),
                  matching: find.byIcon(Icons.close),
                );
          await tester.tap(close);
          await tester.pumpAndSettle();

          expect(find.byType(SeedSidePanel), findsOneWidget);
          expect(
            tester.widget<SeedSidePanel>(find.byType(SeedSidePanel)).size,
            SeedSidePanelSize.small,
            reason: 'Root React pop() is inert and preserves useState',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
    group('header slots', () {
      testWidgets(
        'SidePanel omits the entire header when all three slots hide',
        (tester) async {
          await openOverlaySizingActivity(tester, '/side-panel');
          final panel = find.byType(SeedSidePanel);
          expect(panel, findsOneWidget);
          final article = find.textContaining('Exercitation sint voluptate');
          expect(article, findsOneWidget);
          final panelTop = tester.getTopLeft(panel).dy;
          final initialBodyTop = tester.getTopLeft(article).dy - panelTop;
          expect(initialBodyTop, greaterThanOrEqualTo(70));

          for (final label in ['제목 표시', '설명 표시', '닫기 버튼 표시']) {
            final control = find.widgetWithText(SeedSwitch, label);
            expect(control, findsOneWidget);
            tester.widget<SeedSwitch>(control).onCheckedChange?.call(false);
            await tester.pumpAndSettle();
          }

          final hiddenPanel = tester.widget<SeedSidePanel>(panel);
          expect(hiddenPanel.title, isEmpty);
          expect(hiddenPanel.description, isNull);
          expect(hiddenPanel.showCloseButton, isFalse);
          final hiddenBodyTop =
              tester.getTopLeft(article).dy - tester.getTopLeft(panel).dy;
          expect(hiddenBodyTop, closeTo(0, 0.5));
          expect(initialBodyTop - hiddenBodyTop, greaterThanOrEqualTo(70));

          // A description-only header must appear without the title/description gap.
          tester
              .widget<SeedSwitch>(find.widgetWithText(SeedSwitch, '설명 표시'))
              .onCheckedChange
              ?.call(true);
          await tester.pumpAndSettle();
          final description = find.text('Side Panel 컴포넌트 데모입니다.');
          expect(description, findsOneWidget);
          expect(
            tester.getTopLeft(description).dy - tester.getTopLeft(panel).dy,
            closeTo(24, 1),
          );

          // Re-enable the title and confirm the ordinary header keeps its reserve.
          tester
              .widget<SeedSwitch>(find.widgetWithText(SeedSwitch, '제목 표시'))
              .onCheckedChange
              ?.call(true);
          await tester.pumpAndSettle();
          expect(
            tester.getTopLeft(article).dy - tester.getTopLeft(panel).dy,
            greaterThanOrEqualTo(70),
          );
          expect(tester.takeException(), isNull);
        },
      );
    });
  });

  group('nested modals', () {
    for (final width in [390.0, 800.0]) {
      for (final closeActor in ['footer', 'header']) {
        testWidgets(
          'direct root nested sheet retains content on $closeActor close $width',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(const StackflowSpaApp());
            await tester.pumpAndSettle();
            await _directNested(tester);
            final close = closeActor == 'footer'
                ? find.widgetWithText(SeedButton, '닫기')
                : find.byWidgetPredicate(
                    (w) =>
                        w is SeedPressable &&
                        w.semanticsLabel == '닫기' &&
                        !w.enableScale,
                  );
            expect(close.hitTestable(), findsOneWidget);
            await tester.tap(close);
            await tester.pumpAndSettle();
            expect(
              find.byType(SeedBottomSheet),
              findsOneWidget,
              reason: 'React pop() does nothing for a directly entered root Activity',
            );
            expect(
              find.widgetWithText(SeedButton, 'Open AlertDialog').hitTestable(),
              findsOneWidget,
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
            await tester.pumpAndSettle();
            expect(find.byType(SeedBottomSheet), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }

      testWidgets('nested modal paints retained parent beneath child $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _directNested(tester);
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        final parentRect = tester.getRect(find.byType(SeedBottomSheet));
        await tester.tap(find.widgetWithText(SeedButton, 'Open AlertDialog'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedAlertDialog), findsOneWidget);
        expect(
          find.byType(SeedBottomSheet),
          findsOneWidget,
          reason:
              'Mounted offstage content cannot paint the React parent sheet',
        );
        expect(tester.getRect(find.byType(SeedBottomSheet)), parentRect);
        final navigator = Navigator.of(
          tester.element(find.byType(SeedAlertDialog)),
        );
        final childActivity =
            navigator.widget.onGenerateRoute!(
                  const RouteSettings(name: '/alert-dialog'),
                )!
                as PageRoute<dynamic>;
        expect(childActivity.opaque, isFalse);
        childActivity.dispose();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(SeedAlertDialog), findsNothing);
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        expect(
          find.widgetWithText(SeedButton, 'Open AlertDialog').hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('ResponsiveSidePanel at 390', () {
    testWidgets(
      '390 direct responsive BottomSheet Large→Small→footer Close keeps root and selected size',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final routeUpdates = <Map<dynamic, dynamic>>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            if (call.method == 'routeInformationUpdated') {
              routeUpdates.add(
                Map<dynamic, dynamic>.from(call.arguments as Map),
              );
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _enterDirectResponsive(tester);

        final sheet = find.byType(SeedBottomSheet);
        final segmented = find.byType(SeedSegmentedControl<String>);
        final host = find.byType(SpaOwnScaffold);
        expect(sheet, findsOneWidget);
        expect(find.byType(SeedSidePanel), findsNothing);
        expect(segmented, findsOneWidget);
        expect(find.text('Responsive Side Panel'), findsOneWidget);
        expect(find.widgetWithText(SeedButton, '닫기'), findsOneWidget);
        expect(find.widgetWithText(SeedButton, '확인'), findsOneWidget);
        final history = SpaHistoryDelegate.of(tester.element(sheet));
        expect(history.currentConfiguration.activities.map((r) => r.name), [
          '/responsive-side-panel',
        ], reason: 'Fresh direct URL has no predecessor Stackflow Activity');
        final modal = ModalRoute.of(tester.element(sheet));
        expect(modal?.isCurrent, isTrue);
        expect(
          ModalRoute.of(tester.element(host))?.settings.name,
          '/responsive-side-panel',
        );
        expect(
          tester.widget<SeedSegmentedControl<String>>(segmented).value,
          'medium',
        );
        final sheetRect = tester.getRect(sheet);
        expect(sheetRect.left, closeTo(0, .01));
        expect(sheetRect.right, closeTo(390, .01));
        expect(sheetRect.bottom, closeTo(844, .01));

        // Original browser actors hit real Large and Small radio/segments.
        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(segmented).value,
          'large',
        );
        expect(sheet, findsOneWidget);
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(segmented).value,
          'small',
        );
        expect(sheet, findsOneWidget);

        final changesBeforeClose = routeUpdates.length;
        await tester.tap(find.widgetWithText(SeedButton, '닫기'));
        await tester.pumpAndSettle();
        // React's useFlow().pop() cannot pop a direct root Activity: the modal,
        // Small selection and original URL remain after footer Close.
        expect(sheet, findsOneWidget);
        expect(find.byType(SeedSidePanel), findsNothing);
        expect(
          tester.widget<SeedSegmentedControl<String>>(segmented).value,
          'small',
        );
        expect(ModalRoute.of(tester.element(sheet)), same(modal));
        expect(modal?.isCurrent, isTrue);
        expect(history.currentConfiguration.activities.map((r) => r.name), [
          '/responsive-side-panel',
        ]);
        expect(
          ModalRoute.of(tester.element(host))?.settings.name,
          '/responsive-side-panel',
        );
        expect(
          routeUpdates.skip(changesBeforeClose).where((u) => u['uri'] == '/'),
          isEmpty,
          reason: 'Direct root Close must never publish Home',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '390 Home-pushed responsive BottomSheet still closes to the Home Activity',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final nav = tester.state<NavigatorState>(find.byType(Navigator));
        nav.pushNamed('/responsive-side-panel');
        await tester.pumpAndSettle();

        final sheet = find.byType(SeedBottomSheet);
        final segmented = find.byType(SeedSegmentedControl<String>);
        expect(sheet, findsOneWidget);
        expect(find.byType(SeedSidePanel), findsNothing);
        final history = SpaHistoryDelegate.of(tester.element(sheet));
        expect(history.currentConfiguration.activities.map((r) => r.name), [
          '/',
          '/responsive-side-panel',
        ]);
        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(segmented).value,
          'small',
        );
        await tester.tap(find.widgetWithText(SeedButton, '닫기'));
        await tester.pumpAndSettle();

        expect(find.byType(SeedBottomSheet), findsNothing);
        expect(history.currentConfiguration.activities.last.name, '/');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '390 fresh direct-route document remount resets Small back to Medium',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _enterDirectResponsive(tester);
        final segmented = find.byType(SeedSegmentedControl<String>);
        expect(
          tester.widget<SeedSegmentedControl<String>>(segmented).value,
          'medium',
        );
        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(segmented).value,
          'small',
        );

        // Original native browser Back left the document (about:blank) and
        // Forward loaded a new document. This is only a VM remount model.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _enterDirectResponsive(tester);
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        expect(find.byType(SeedSidePanel), findsNothing);
        expect(
          tester
              .widget<SeedSegmentedControl<String>>(
                find.byType(SeedSegmentedControl<String>),
              )
              .value,
          'medium',
        );
        expect(
          SpaHistoryDelegate.of(tester.element(find.byType(SeedBottomSheet)))
              .currentConfiguration
              .activities
              .last
              .name,
          '/responsive-side-panel',
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('ResponsiveSidePanel at 800', () {
    testWidgets(
      '800 direct root ResponsiveSidePanel Large→Small→footer Close preserves root, external Forward resets Medium',
      (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final platformUpdates = <Map<dynamic, dynamic>>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            if (call.method == 'routeInformationUpdated') {
              platformUpdates.add(
                Map<dynamic, dynamic>.from(call.arguments as Map),
              );
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _visitDirect(tester);

        final panel = find.byType(SeedSidePanel);
        final sizeControl = find.byType(SeedSegmentedControl<String>);
        final routeHost = find.byType(SpaOwnScaffold);
        expect(panel, findsOneWidget);
        expect(sizeControl, findsOneWidget);
        expect(find.byType(SeedBottomSheet), findsNothing);
        expect(
          tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
          'medium',
        );
        expect(
          tester.widget<SeedSidePanel>(panel).size,
          SeedSidePanelSize.medium,
        );
        final history = SpaHistoryDelegate.of(tester.element(panel));
        expect(
          history.currentConfiguration.activities.map((route) => route.name),
          ['/responsive-side-panel'],
          reason: 'Direct entry has no prior in-app Stackflow Activity to pop',
        );
        expect(
          history.currentConfiguration.activities.last.name,
          '/responsive-side-panel',
        );
        expect(
          ModalRoute.of(tester.element(routeHost))?.settings.name,
          '/responsive-side-panel',
        );
        expect(tester.getRect(panel).width, closeTo(640, 0.01));

        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
          'large',
        );
        expect(
          tester.widget<SeedSidePanel>(panel).size,
          SeedSidePanelSize.large,
        );
        expect(tester.getRect(panel).width, closeTo(640, 0.01));

        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
          'small',
        );
        expect(
          tester.widget<SeedSidePanel>(panel).size,
          SeedSidePanelSize.small,
        );
        expect(tester.getRect(panel).width, closeTo(480, 0.01));

        // Official ActivityResponsiveSidePanel.tsx calls useFlow().pop().
        // On a DIRECT root entry Stackflow has no earlier Activity; its footer
        // click is observed to leave the root panel visible and Small selected.
        final emittedBeforeClose = platformUpdates.length;
        final footerClose = find.widgetWithText(SeedButton, '닫기');
        expect(footerClose, findsOneWidget);
        await tester.tap(footerClose);
        await tester.pumpAndSettle();

        expect(find.byType(SeedSidePanel), findsOneWidget);
        expect(find.text('Responsive Side Panel'), findsOneWidget);
        expect(find.byType(SeedBottomSheet), findsNothing);
        expect(
          tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
          'small',
        );
        expect(
          tester.widget<SeedSidePanel>(panel).size,
          SeedSidePanelSize.small,
        );
        expect(
          ModalRoute.of(tester.element(routeHost))?.settings.name,
          '/responsive-side-panel',
        );
        expect(
          history.currentConfiguration.activities.last.name,
          '/responsive-side-panel',
        );
        expect(
          platformUpdates
              .skip(emittedBeforeClose)
              .where((e) => e['uri'] == '/'),
          isEmpty,
          reason:
              'Direct root close cannot publish Home as a new/replace entry',
        );
        expect(tester.takeException(), isNull);

        // The original real Chrome Back left the document (about:blank), then
        // Forward loaded a NEW document at the same /responsive-side-panel.
        // Model only that known new-document behavior by remounting the app;
        // do not pretend pushRouteInformation equals a Chrome document reload.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _visitDirect(tester);
        expect(find.byType(SeedSidePanel), findsOneWidget);
        expect(
          tester
              .widget<SeedSegmentedControl<String>>(
                find.byType(SeedSegmentedControl<String>),
              )
              .value,
          'medium',
        );
        expect(
          tester.getRect(find.byType(SeedSidePanel)).width,
          closeTo(640, 0.01),
        );
        expect(
          ModalRoute.of(tester.element(find.byType(SpaOwnScaffold)))
              ?.settings
              .name,
          '/responsive-side-panel',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '800 Home-pushed responsive panel remains dismissible after Large→Small',
      (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pushNamed('/responsive-side-panel');
        await tester.pumpAndSettle();

        final panel = find.byType(SeedSidePanel);
        final control = find.byType(SeedSegmentedControl<String>);
        expect(panel, findsOneWidget);
        final history = SpaHistoryDelegate.of(tester.element(panel));
        expect(
          history.currentConfiguration.activities.map((route) => route.name),
          ['/', '/responsive-side-panel'],
          reason: 'Home-pushed panel has a genuine in-app predecessor',
        );
        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(control).value,
          'small',
        );

        await tester.tap(find.widgetWithText(SeedButton, '닫기'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedSidePanel), findsNothing);
        expect(history.currentConfiguration.activities.last.name, '/');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '800 fresh document at the original responsive URL initializes Medium',
      (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _visitDirect(tester);
        final control = find.byType(SeedSegmentedControl<String>);
        expect(
          tester.widget<SeedSegmentedControl<String>>(control).value,
          'medium',
        );
        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(control).value,
          'small',
        );

        // The real original browser goes Back to about:blank, then Forward
        // to a new document. A remount checks only Flutter state initialization.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _visitDirect(tester);
        expect(find.byType(SeedSidePanel), findsOneWidget);
        expect(
          tester
              .widget<SeedSegmentedControl<String>>(
                find.byType(SeedSegmentedControl<String>),
              )
              .value,
          'medium',
        );
        expect(
          SpaHistoryDelegate.of(tester.element(find.byType(SeedSidePanel)))
              .currentConfiguration
              .activities
              .last
              .name,
          '/responsive-side-panel',
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('HelpBubble and BottomSheetTextField', () {
    for (final width in [390.0, 800.0]) {
      testWidgets('HelpBubble dynamic trigger fills fractional width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _route(tester, '/help-bubble');

        await tester.scrollUntilVisible(
          find.text('Trigger 너비: 40%'),
          350,
          scrollable: find.byType(Scrollable).last,
          maxScrolls: 25,
        );
        await tester.pumpAndSettle();
        final changeTriggerWidth = tester
            .widget<Slider>(find.byType(Slider).first)
            .onChanged!;
        for (final percentage in [40, 96, 26]) {
          if (percentage != 40) {
            // Exercise the real demo slider callback while isolating geometry
            // from the unrelated browser/pointer event delivery contract.
            changeTriggerWidth(percentage.toDouble());
            await tester.pumpAndSettle();
          }
          final trigger = find.widgetWithText(SeedButton, '너비 $percentage%');
          expect(trigger, findsOneWidget);
          await tester.ensureVisible(trigger);
          await tester.pumpAndSettle();
          final fractional = find
              .ancestor(
                of: trigger,
                matching: find.byType(FractionallySizedBox),
              )
              .first;
          final parentWidth = tester.getSize(fractional).width;
          final factor = tester
              .widget<FractionallySizedBox>(fractional)
              .widthFactor;
          expect(factor, closeTo(percentage / 100, .0001));
          expect(
            tester.getSize(trigger).width,
            closeTo(parentWidth * factor!, 1),
            reason: 'React dynamically stretches the HelpBubble trigger',
          );
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'Root BottomSheetTextField preserves typed value after Escape $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await _direct(tester, '/bottom-sheet-text-field');
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          final input = find.byType(EditableText).first;
          await tester.enterText(input, 'RootName42');
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(
            find.byType(SeedBottomSheet),
            findsOneWidget,
            reason: 'React root Stackflow pop() has no predecessor',
          );
          await tester.tapAt(Offset(width / 2, 18));
          await tester.pumpAndSettle();
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText).first)
                .controller
                .text,
            'RootName42',
          );
          await tester.tap(find.widgetWithText(SeedButton, '제출'));
          await tester.pumpAndSettle();
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText).first)
                .controller
                .text,
            'RootName42',
          );
          expect(tester.takeException(), isNull);
        },
      );
      testWidgets(
        'Pushed BottomSheetTextField allows Escape to pop activity $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await _route(tester, '/bottom-sheet-text-field');
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.byType(SeedBottomSheet), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('results, keepMounted and resize', () {
    for (final route in ['/responsive-dialog', '/responsive-side-panel']) {
      testWidgets('$route changes surface while open on viewport resize', (
        tester,
      ) async {
        await open(tester, route);
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        tester.view.physicalSize = const Size(1000, 900);
        await tester.pumpAndSettle();
        expect(find.byType(SeedBottomSheet), findsNothing);
        expect(
          route == '/responsive-dialog'
              ? find.byType(SeedDialog)
              : find.byType(SeedSidePanel),
          findsOneWidget,
        );
        tester.view.physicalSize = const Size(440, 900);
        await tester.pumpAndSettle();
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
    for (final route in ['/menu-sheet', '/swipeable-menu-sheet']) {
      testWidgets('$route returns the selected action to its caller', (
        tester,
      ) async {
        final navigator = await open(tester, '/action-button');
        final result = navigator.pushNamed(route);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
        expect(await result, {'action': 'add'});
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets(
      'keyboard playground options change sheet geometry and use live insets',
      (tester) async {
        await open(tester, '/bottom-sheet-keyboard-playground');
        final fixed = find.text('fixed: off');
        await tester.ensureVisible(fixed);
        await tester.tap(fixed);
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedBottomSheet>(find.byType(SeedBottomSheet)).expand,
          isFalse,
          reason:
              'React fixed controls keyboard anchoring; it does not request '
              'an expanded sheet (useDrawer fixed + repositionInputs contract).',
        );
        await tester.ensureVisible(find.text('snapPoints: off'));
        await tester.tap(find.text('snapPoints: off'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedSnappingBottomSheet), findsOneWidget);
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        expect(find.textContaining('keyboard 250px'), findsOneWidget);
        expect(find.textContaining('sheet top'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    for (final keep in [false, true]) {
      testWidgets(
        'BottomSheet keepMounted=$keep controls uncontrolled input lifetime',
        (tester) async {
          final navigator = await open(tester, '/bottom-sheet');
          await tester.enterText(find.byType(EditableText), 'saved name');
          if (keep) {
            final toggle = find.text('Push 이후에도 BottomSheet 마운트 유지');
            await tester.ensureVisible(toggle);
            await tester.tap(toggle);
            await tester.pumpAndSettle();
          }
          await tester.ensureVisible(find.text('ActivityDetail'));
          await tester.tap(find.text('ActivityDetail'));
          await tester.pumpAndSettle();
          navigator.pop();
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText))
                .controller
                .text,
            keep ? 'saved name' : '',
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }

    testWidgets('AlertDialog returns hello to the activity caller', (
      tester,
    ) async {
      final navigator = await open(tester, '/action-button');
      final result = navigator.pushNamed('/alert-dialog');
      await tester.pumpAndSettle();
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(await result, {'message': 'hello'});
      expect(tester.takeException(), isNull);
    });
  });

  group('responsive overlays, Menu and Popover', () {
    testWidgets(
      'ResponsiveSidePanel 767/768 retains React compact layout on resize',
      (tester) async {
        await openStackflowSpaVisualFix(
          tester,
          '/responsive-side-panel',
          width: 767,
        );
        final sheet = tester.widget<SeedBottomSheet>(
          find.byType(SeedBottomSheet),
        );
        expect(sheet.showHandle, isFalse);
        expect(find.text('패널 크기'), findsNothing);
        final cancel = find.widgetWithText(SeedButton, '닫기');
        final confirm = find.widgetWithText(SeedButton, '확인');
        expect(tester.getTopLeft(cancel).dy, tester.getTopLeft(confirm).dy);
        expect(
          tester.getTopLeft(cancel).dx,
          lessThan(tester.getTopLeft(confirm).dx),
        );

        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        tester.view.physicalSize = const Size(768, 800);
        await tester.pumpAndSettle();
        expect(find.byType(SeedBottomSheet), findsNothing);
        expect(find.byType(SeedSidePanel), findsOneWidget);
        expect(
          tester
              .widget<SeedSegmentedControl<String>>(
                find.byType(SeedSegmentedControl<String>),
              )
              .value,
          'large',
        );
        expect(find.text('패널 크기'), findsNothing);
        expect(tester.getTopLeft(cancel).dy, tester.getTopLeft(confirm).dy);
        expect(
          tester.getTopLeft(cancel).dx,
          lessThan(tester.getTopLeft(confirm).dx),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ResponsiveDialog entered as root retains openStackflowSpaVisualFix selected size on Escape',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushReplacementNamed('/responsive-dialog');
        await tester.pumpAndSettle();
        final sizeControl = find.byType(SeedSegmentedControl<String>);
        expect(sizeControl, findsOneWidget);
        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
          'large',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Responsive Dialog'), findsWidgets);
        expect(sizeControl, findsOneWidget);
        expect(
          tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
          'large',
        );
        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();
        expect(sizeControl, findsOneWidget);
        await tester.tap(find.text('확인'));
        await tester.pumpAndSettle();
        expect(sizeControl, findsOneWidget);
        await tester.tap(
          find
              .byWidgetPredicate(
                (widget) =>
                    widget is SeedPressable && widget.semanticsLabel == '닫기',
              )
              .last,
        );
        await tester.pumpAndSettle();
        expect(sizeControl, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ResponsiveDialog pushed from Home still dismisses with Escape',
      (tester) async {
        await openStackflowSpaVisualFix(
          tester,
          '/responsive-dialog',
          width: 800,
        );
        expect(find.byType(SeedDialog), findsOneWidget);
        await tester.tap(find.text('Large'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(SeedDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    for (final route in ['/side-panel', '/responsive-side-panel']) {
      testWidgets('$route keeps the default 80% panel cap at desktop width', (
        tester,
      ) async {
        await openStackflowSpaVisualFix(tester, route);
        final panel = find.byType(SeedSidePanel);
        expect(tester.getSize(panel).width, 640);
        expect(tester.getTopLeft(panel).dx, 160);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets(
      'Menu onOpenChange reason labels match React outside and Escape',
      (tester) async {
        await openStackflowSpaVisualFix(tester, '/menu', width: 390);
        final reasonTrigger = find.text('Reason 추적');
        await tester.scrollUntilVisible(
          reasonTrigger,
          180,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        await tester.tap(reasonTrigger);
        await tester.pumpAndSettle();
        expect(find.text('마지막: trigger'), findsOneWidget);
        await tester.tapAt(const Offset(10, 95));
        await tester.pumpAndSettle();
        expect(find.text('마지막: interactOutside'), findsOneWidget);
        await tester.tap(reasonTrigger);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('마지막: escapeKeyDown'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Popover headerless sample has no header and uses Apply', (
      tester,
    ) async {
      await openStackflowSpaVisualFix(tester, '/popover', width: 390);
      await tester.tap(find.text('헤더 없음'));
      await tester.pumpAndSettle();
      final visiblePopover = tester.widget<SeedPopover>(
        find.byType(SeedPopover).last,
      );
      expect(visiblePopover.titleText, isNull);
      expect(visiblePopover.semanticsLabel, '필터');
      expect(visiblePopover.descriptionText, isNull);
      expect(visiblePopover.showCloseButton, isFalse);
      expect(find.text('적용'), findsOneWidget);
      await tester.tap(find.text('적용'));
      await tester.pumpAndSettle();
      expect(find.text('적용'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    for (final width in [390.0, 800.0]) {
      testWidgets(
        'Popover nested cascade reason labels match React at $width',
        (tester) async {
          await openStackflowSpaVisualFix(tester, '/popover', width: width);
          final outer = find.text('바깥 popover');
          await tester.scrollUntilVisible(
            outer,
            200,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
          await tester.tap(outer);
          await tester.pumpAndSettle();
          await tester.tap(find.text('안쪽 popover'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('바깥 popover 닫기'));
          await tester.pumpAndSettle();
          expect(find.text('outer close · -'), findsOneWidget);
          expect(find.text('nested close · cascadeDismiss'), findsOneWidget);
          expect(find.text('안쪽 레이어'), findsNothing);
          expect(find.text('바깥 레이어'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('ResponsiveDialog on mobile', () {
    testWidgets(
      'ResponsiveDialog mobile matches React sheet without a drag handle',
      (tester) async {
        await openZzRestoreVisualFix(tester, '/responsive-dialog', width: 390);
        final sheet = tester.widget<SeedBottomSheet>(
          find.byType(SeedBottomSheet),
        );
        expect(sheet.showHandle, isFalse);
        expect(find.text('Responsive Dialog'), findsWidgets);
      },
    );
  });

  for (final dismiss in ['escape', 'button', 'backdrop']) {
    testWidgets(
      'closing the form sheet by $dismiss releases its draft safely',
      (tester) async {
        await _open(tester, '/bottom-sheet', size: const Size(390, 844));
        await tester.enterText(find.byType(EditableText), 'Draft');
        if (dismiss == 'escape') {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        } else if (dismiss == 'button') {
          await tester.tap(find.text('닫기').first);
        } else {
          await tester.tapAt(const Offset(195, 100));
        }
        await tester.pumpAndSettle();
        expect(find.byType(SeedBottomSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'modal sheet uses a compact neutral Switch and toggles both ways',
    (tester) async {
      await _open(
        tester,
        '/bottom-sheet-modal-test',
        size: const Size(390, 800),
      );
      expect(find.text('현재 modal: true'), findsOneWidget);
      expect(tester.getRect(find.text('modal prop 토글')).right, closeTo(374, 1));
      final mark = tester.widget<SeedSwitch>(find.byType(SeedSwitch));
      expect(mark.size, SeedSwitchSize.size16);
      expect(mark.tone, SeedControlTone.neutral);
      await tester.tap(find.text('modal prop 토글'));
      await tester.pumpAndSettle();
      expect(find.text('현재 modal: false'), findsOneWidget);
      await tester.tap(find.text('modal prop 토글'));
      await tester.pumpAndSettle();
      expect(find.text('현재 modal: true'), findsOneWidget);
    },
  );
}
