import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_routes.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

class _BrowserCursorModel {
  final entries = <Map<dynamic, dynamic>>[];
  int cursor = -1;
  int browserBackCalls = 0;
  int replacements = 0;

  Future<void> onRouteUpdate(MethodCall call) async {
    if (call.method != 'routeInformationUpdated') return;
    final entry = Map<dynamic, dynamic>.from(call.arguments as Map);
    if (entry['replace'] == true && cursor >= 0) {
      entries[cursor] = entry;
      replacements++;
    } else {
      entries.removeRange(cursor + 1, entries.length);
      entries.add(entry);
      cursor++;
    }
  }

  void back() {
    browserBackCalls++;
    if (cursor > 0) cursor--;
  }

  Future<void> visit(WidgetTester tester, int index) async {
    cursor = index;
    final entry = entries[index];
    final done = Completer<void>();
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      SystemChannels.navigation.codec.encodeMethodCall(
        MethodCall('pushRouteInformation', {
          'location': entry['uri'],
          'state': entry['state'],
        }),
      ),
      (_) => done.complete(),
    );
    await tester.pump();
    await done.future;
    await tester.pumpAndSettle();
  }
}

Future<_BrowserCursorModel> _start(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 960);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final browser = _BrowserCursorModel();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.navigation,
    browser.onRouteUpdate,
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation,
      null,
    ),
  );
  await tester.pumpWidget(StackflowSpaApp(onBrowserBack: browser.back));
  await tester.pumpAndSettle();
  return browser;
}

Future<void> browserVisit(
  WidgetTester tester,
  Map<dynamic, dynamic> entry,
) async {
  final done = Completer<void>();
  // The platform message emitted by Flutter Web for popstate.
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {
        'location': entry['uri'],
        'state': entry['state'],
      }),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('browser Back plays the top route exit transition', (
    tester,
  ) async {
    final browser = await _start(tester, 390);
    final homeIndex = browser.cursor;
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/animated-tabs');
    await tester.pumpAndSettle();
    final entry = browser.entries[homeIndex];
    browser.cursor = homeIndex;
    final done = Completer<void>();
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      SystemChannels.navigation.codec.encodeMethodCall(
        MethodCall('pushRouteInformation', {
          'location': entry['uri'],
          'state': entry['state'],
        }),
      ),
      (_) => done.complete(),
    );
    await tester.pump();
    await done.future;
    await tester.pump(const Duration(milliseconds: 60));
    // Both Activities stay painted while the top one leaves.
    expect(find.byType(SeedTopNavigation), findsNWidgets(2));
    await tester.pumpAndSettle();
    expect(find.byType(SeedTopNavigation), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'session PUSH POP invokes browser Back and preserves Forward at $width',
      (tester) async {
        final browser = await _start(tester, width);
        final homeIndex = browser.cursor;
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pushNamed('/animated-tabs');
        await tester.pumpAndSettle();
        final childIndex = browser.cursor;
        expect(childIndex, homeIndex + 1);
        expect(browser.entries[childIndex]['uri'], '/animated-tabs');
        navigator.pop();
        await tester.pumpAndSettle();
        expect(browser.browserBackCalls, 1);
        expect(browser.cursor, homeIndex);
        expect(browser.entries[childIndex]['uri'], '/animated-tabs');
        await browser.visit(tester, homeIndex);
        expect(find.text('Home'), findsOneWidget);
        await browser.visit(tester, childIndex);
        expect(find.text('Animated Tabs'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'nested POP preserves child and retained parent Back at $width',
      (tester) async {
        final browser = await _start(tester, width);
        final nav = tester.state<NavigatorState>(find.byType(Navigator));
        final homeIndex = browser.cursor;
        nav.pushNamed('/tabs');
        await tester.pumpAndSettle();
        final parentIndex = browser.cursor;
        nav.pushNamed('/animated-tabs');
        await tester.pumpAndSettle();
        final childIndex = browser.cursor;
        nav.pop();
        await tester.pumpAndSettle();
        expect(browser.cursor, parentIndex);
        expect(browser.browserBackCalls, 1);
        await browser.visit(tester, parentIndex);
        nav.pop();
        await tester.pumpAndSettle();
        // The parent was genuinely PUSHed within this browser session and
        // retained the *same* Route object after Back from its child. The
        // original React historySyncPlugin uses browser Back again, keeping
        // both forward entries. Only recreated/direct-entry routes lack this
        // provenance and must use the guarded fallback tested below.
        expect(browser.browserBackCalls, 2);
        expect(browser.cursor, homeIndex);
        expect(browser.entries[parentIndex]['uri'], '/tabs');
        expect(browser.entries[childIndex]['uri'], '/animated-tabs');
        expect(browser.entries[homeIndex]['uri'], '/');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'direct URL/reload without local PUSH never invokes browser Back at $width',
      (tester) async {
        final browser = await _start(tester, width);
        await browser.visit(tester, 0);
        // Direct-link platform navigation creates an Activity from URL, not
        // from an acknowledged browser PUSH in this session.
        final done = Completer<void>();
        tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          SystemChannels.navigation.name,
          SystemChannels.navigation.codec.encodeMethodCall(
            const MethodCall('pushRouteInformation', {
              'location': '/animated-tabs',
              'state': null,
            }),
          ),
          (_) => done.complete(),
        );
        await tester.pump();
        await done.future;
        await tester.pumpAndSettle();
        expect(find.text('Animated Tabs'), findsOneWidget);
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
          false,
        );
        expect(browser.browserBackCalls, 0);
        expect(browser.cursor, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Forward restores the session PUSH provenance at $width', (
      tester,
    ) async {
      final browser = await _start(tester, width);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      final rootIndex = browser.cursor;
      nav.pushNamed('/animated-tabs');
      await tester.pumpAndSettle();
      final activityIndex = browser.cursor;
      await browser.visit(tester, rootIndex);
      await browser.visit(tester, activityIndex);
      expect(find.text('Animated Tabs'), findsOneWidget);
      nav.pop();
      await tester.pumpAndSettle();
      // The serialized session and local PUSH identifier prove that this
      // recreated entry has the same in-session predecessor as before Back.
      expect(browser.browserBackCalls, 1);
      expect(browser.cursor, rootIndex);
      expect(browser.entries[activityIndex]['uri'], '/animated-tabs');
      expect(tester.takeException(), isNull);
    });

    testWidgets('foreign session history uses guarded replacement at $width', (
      tester,
    ) async {
      final browser = await _start(tester, width);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      final rootIndex = browser.cursor;
      nav.pushNamed('/animated-tabs');
      await tester.pumpAndSettle();
      final activityIndex = browser.cursor;
      await browser.visit(tester, rootIndex);
      final entry = browser.entries[activityIndex];
      final state = Map<dynamic, dynamic>.from(entry['state'] as Map);
      state['seedSessionId'] = 'foreign-session';
      entry['state'] = state;
      await browser.visit(tester, activityIndex);
      nav.pop();
      await tester.pumpAndSettle();
      expect(browser.browserBackCalls, 0);
      expect(browser.replacements, greaterThan(0));
    });
  }
  group('nested activities', () {
    for (final width in [390.0, 800.0]) {
      for (final dismissal in ['confirm', 'escape', 'backdrop']) {
        testWidgets(
          'nested activity restores parent URL after $dismissal at $width',
          (tester) async {
            tester.view.physicalSize = Size(width, 960);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final updates = <Map<dynamic, dynamic>>[];
            tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
              SystemChannels.navigation,
              (call) async {
                if (call.method == 'routeInformationUpdated') {
                  updates.add(call.arguments as Map);
                }
                return null;
              },
            );
            addTearDown(
              () => tester.binding.defaultBinaryMessenger
                  .setMockMethodCallHandler(SystemChannels.navigation, null),
            );
            await tester.pumpWidget(const StackflowSpaApp());
            await tester.pumpAndSettle();
            final nav = tester.state<NavigatorState>(find.byType(Navigator));
            nav.pushNamed('/nested-bottom-sheet');
            await tester.pumpAndSettle();
            for (var cycle = 0; cycle < 2; cycle++) {
              await tester.tap(
                find.widgetWithText(SeedButton, 'Open AlertDialog'),
              );
              await tester.pumpAndSettle();
              expect(updates.last['uri'], '/alert-dialog');
              if (dismissal == 'confirm') {
                await tester.tap(find.widgetWithText(SeedButton, '확인'));
              } else if (dismissal == 'escape') {
                await tester.sendKeyEvent(LogicalKeyboardKey.escape);
              } else {
                await tester.tapAt(const Offset(8, 120));
              }
              await tester.pumpAndSettle();
              if (dismissal == 'backdrop') {
                // React AlertDialogRoot defaults to
                // closeOnInteractOutside=false: tapping the backdrop must not
                // dismiss this nested alert or pop its Activity URL.
                expect(find.byType(SeedAlertDialog), findsOneWidget);
                expect(updates.last['uri'], '/alert-dialog');
                await tester.tap(find.widgetWithText(SeedButton, '확인'));
                await tester.pumpAndSettle();
              }
              expect(find.byType(SeedAlertDialog), findsNothing);
              expect(
                find.text('BottomSheet × AlertDialog (Activity)'),
                findsOneWidget,
              );
              expect(updates.last['uri'], '/nested-bottom-sheet');
            }
            await tester.tap(find.widgetWithText(SeedButton, '닫기'));
            await tester.pumpAndSettle();
            expect(find.text('Home'), findsOneWidget);
            expect(updates.last['uri'], '/');
            nav.pushNamed('/nested-bottom-sheet');
            await tester.pumpAndSettle();
            expect(
              find.text('BottomSheet × AlertDialog (Activity)'),
              findsOneWidget,
            );
            expect(updates.last['uri'], '/nested-bottom-sheet');
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          },
        );
      }
      testWidgets(
        'browser nested Back keeps the parent and Forward reopens child at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 960);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final updates = <Map<dynamic, dynamic>>[];
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            (call) async {
              if (call.method == 'routeInformationUpdated') {
                updates.add(call.arguments as Map);
              }
              return null;
            },
          );
          addTearDown(
            () => tester.binding.defaultBinaryMessenger
                .setMockMethodCallHandler(SystemChannels.navigation, null),
          );
          await tester.pumpWidget(const StackflowSpaApp());
          await tester.pumpAndSettle();
          final nav = tester.state<NavigatorState>(find.byType(Navigator));
          nav.pushNamed('/nested-bottom-sheet');
          await tester.pumpAndSettle();
          final parent = Map<dynamic, dynamic>.from(updates.last);
          await tester.tap(find.widgetWithText(SeedButton, 'Open AlertDialog'));
          await tester.pumpAndSettle();
          final child = Map<dynamic, dynamic>.from(updates.last);
          await browserVisit(tester, parent);
          expect(find.byType(SeedAlertDialog), findsNothing);
          expect(
            find.text('BottomSheet × AlertDialog (Activity)'),
            findsOneWidget,
          );
          await browserVisit(tester, child);
          expect(find.byType(SeedAlertDialog), findsOneWidget);
          await tester.tap(find.widgetWithText(SeedButton, '확인'));
          await tester.pumpAndSettle();
          expect(find.byType(SeedAlertDialog), findsNothing);
          expect(
            find.text('BottomSheet × AlertDialog (Activity)'),
            findsOneWidget,
          );
          expect(updates.last['uri'], '/nested-bottom-sheet');
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
      testWidgets('browser Back Forward restores Animated Tabs at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final updates = <Map<dynamic, dynamic>>[];
        final methods = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            methods.add(call.method);
            if (call.method == 'routeInformationUpdated') {
              updates.add(call.arguments as Map);
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
        final homeEntry = Map<dynamic, dynamic>.from(updates.last);
        final nav = tester.state<NavigatorState>(find.byType(Navigator));
        nav.pushNamed('/side-navigation');
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('성과 리포트'),
          250,
          scrollable: find
              .descendant(
                of: find.byType(SeedSideNavigation),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await Scrollable.ensureVisible(
          tester.element(find.text('성과 리포트')),
          alignment: 0.4,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('성과 리포트'));
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(
          tester.element(find.text('주간 리포트')),
          alignment: 0.4,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('주간 리포트'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedSideNavigation>(find.byType(SeedSideNavigation))
              .selectedId,
          '주간 리포트',
        );
        await browserVisit(tester, homeEntry);
        nav.pushNamed('/animated-tabs');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tab 2'));
        await tester.pumpAndSettle();
        expect(find.text('Tab 2 content'), findsOneWidget);
        final animatedEntry = Map<dynamic, dynamic>.from(updates.last);
        expect(methods, contains('selectMultiEntryHistory'));
        expect(animatedEntry['state'], isNotNull);
        await browserVisit(tester, homeEntry);
        expect(find.text('Home'), findsOneWidget);
        await browserVisit(tester, animatedEntry);
        expect(find.text('Animated Tabs'), findsOneWidget);
        expect(find.text('Tab 1 content'), findsOneWidget);
        expect(find.text('Tab 2 content'), findsNothing);
        expect(
          nav.widget.observers
              .whereType<SpaGestureObserver>()
              .single
              .activityIndex,
          1,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  });

  group('AppBar Home icon', () {
    testWidgets(
      'Home icon pushes a history entry and Back restores its source',
      (tester) async {
        tester.view.physicalSize = const Size(390, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final updates = <Map<dynamic, dynamic>>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            if (call.method == 'routeInformationUpdated') {
              updates.add(call.arguments as Map);
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
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pushNamed('/tabs');
        await tester.pumpAndSettle();
        expect(updates.last['uri'], '/tabs');
        await tester.tap(find.byIcon(Icons.home_outlined));
        await tester.pumpAndSettle();
        expect(updates.last['uri'], '/');
        await navigator.maybePop();
        await tester.pumpAndSettle();
        expect(updates.last['uri'], '/tabs');
      },
    );
  });
}
