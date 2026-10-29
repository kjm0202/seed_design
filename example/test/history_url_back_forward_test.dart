import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
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
}
