import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_history.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> _browserNavigation(
  WidgetTester tester,
  String uri, {
  Object? state,
}) async {
  final response = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': uri, 'state': state}),
    ),
    (_) => response.complete(),
  );
  await tester.pump();
  await response.future;
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pushed Step browser Back preserves Forward entry on close', (
    tester,
  ) async {
    final entries = <Map<dynamic, dynamic>>[];
    var cursor = -1;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation,
      (call) async {
        if (call.method == 'routeInformationUpdated') {
          final update = Map<dynamic, dynamic>.from(call.arguments as Map);
          final replacing = update['replace'] == true;
          if (replacing && cursor >= 0) {
            entries[cursor] = update;
          } else {
            entries.removeRange(cursor + 1, entries.length);
            entries.add(update);
            cursor++;
          }
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
    var browserBackCalls = 0;
    await tester.pumpWidget(
      StackflowSpaApp(
        // Verifies the command contract and simulates browser cursor movement
        // without running a real Chrome instance.
        onBrowserBack: () {
          browserBackCalls++;
          cursor--;
        },
      ),
    );
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/menu-sheet-step');
    await tester.pumpAndSettle();
    final base = cursor;
    final history = SpaHistoryDelegate.of(
      tester.element(find.text('Menu Sheet 열기')),
    );
    history.pushStep('menu-sheet');
    await tester.pumpAndSettle();
    expect(cursor, base + 1);
    expect(
      Uri.parse(entries[cursor]['uri'] as String).queryParameters['menu-sheet'],
      'open',
    );
    history.popStep('menu-sheet');
    await tester.pumpAndSettle();
    // React historySyncPlugin.onBeforeStepPop calls history.back(). The
    // browser-provided popstate arrives later; Step remains in Forward history.
    expect(browserBackCalls, 1);
    expect(cursor, base);
    expect(
      Uri.parse(entries[base + 1]['uri'] as String)
          .queryParameters['menu-sheet'],
      'open',
    );
    await _browserNavigation(
      tester,
      entries[cursor]['uri'] as String,
      state: entries[cursor]['state'],
    );
    expect(history.isStepOpen('menu-sheet'), false);
    cursor++;
    await _browserNavigation(
      tester,
      entries[cursor]['uri'] as String,
      state: entries[cursor]['state'],
    );
    expect(history.isStepOpen('menu-sheet'), true);
  });

  testWidgets(
    'direct-entry Step has no known predecessor: never browser-back',
    (tester) async {
      var browserBackCalls = 0;
      final updates = <Map<dynamic, dynamic>>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.navigation,
        (call) async {
          if (call.method == 'routeInformationUpdated') {
            updates.add(Map<dynamic, dynamic>.from(call.arguments as Map));
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
      await tester.pumpWidget(
        StackflowSpaApp(onBrowserBack: () => browserBackCalls++),
      );
      await tester.pumpAndSettle();
      await _browserNavigation(tester, '/menu-sheet-step?menu-sheet=open');
      final history = SpaHistoryDelegate.of(
        tester.element(find.text('Menu Sheet 열기')),
      );
      expect(history.isStepOpen('menu-sheet'), true);
      history.popStep('menu-sheet');
      await tester.pumpAndSettle();
      expect(browserBackCalls, 0);
      expect(history.isStepOpen('menu-sheet'), false);
      expect(Uri.parse(updates.last['uri'] as String).query, isEmpty);
      expect(updates.last['replace'], true);
    },
  );

  testWidgets('Back to trailing-slash Step query retains Activity identity', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/menu-sheet-step');
    await tester.pumpAndSettle();
    final opener = find.widgetWithText(SeedButton, 'Menu Sheet 열기');
    final original = tester.element(opener);
    final names = [
      {'name': '/', 'arguments': null},
      {'name': '/menu-sheet-step/?menu-sheet=open', 'arguments': null},
    ];
    await _browserNavigation(
      tester,
      '/menu-sheet-step/?menu-sheet=open',
      state: {'seedActivities': names},
    );
    expect(identical(tester.element(opener), original), true);
    expect(
      SpaHistoryDelegate.of(tester.element(opener)).isStepOpen('menu-sheet'),
      true,
    );
  });

  test(
    '103 route inventory covers official root, query Step and transition paths',
    () async {
      const parser = SpaHistoryParser();
      final step = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/menu-sheet-step/?menu-sheet=open')),
      );
      expect(step.activities.single.name, '/menu-sheet-step/?menu-sheet=open');
      final transition = await parser.parseRouteInformation(
        RouteInformation(
          uri: Uri.parse('/transition-style?transitionStyle=fadeIn'),
        ),
      );
      expect(transition.activities.single.arguments, {
        'transitionStyle': 'fadeIn',
      });
      final article = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/demo/article-detail?articleId=3')),
      );
      expect(article.activities.single.arguments, 3);
    },
  );
}
