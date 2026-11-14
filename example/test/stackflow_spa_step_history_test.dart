import 'dart:async';

import 'package:material_ui/material_ui.dart';
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

const _steps = <(String, String, String, String)>[
  ('/alert-dialog-step', 'alert-dialog', 'Alert Dialog 열기', 'SeedAlertDialog'),
  ('/bottom-sheet-step', 'bottom-sheet', 'Bottom Sheet 열기', 'SeedBottomSheet'),
  ('/menu-sheet-step', 'menu-sheet', 'Menu Sheet 열기', 'SeedMenuSheet'),
];

Future<void> _revisit(WidgetTester tester, Map<dynamic, dynamic> state) async {
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {
        'location': state['uri'],
        'state': state['state'],
      }),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'root Step owner survives browser reconstruction without gaining Activity PUSH provenance',
    (tester) async {
      final entries = <Map<dynamic, dynamic>>[];
      var browserBackCalls = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.navigation,
        (call) async {
          if (call.method == 'routeInformationUpdated') {
            entries.add(Map<dynamic, dynamic>.from(call.arguments as Map));
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
      await _browserNavigation(tester, '/menu-sheet-step');
      await tester.tap(find.text('Menu Sheet 열기'));
      await tester.pumpAndSettle();
      final stepEntry = Map<dynamic, dynamic>.from(entries.last);
      final metadata = stepEntry['state'] as Map;
      expect((metadata['seedActivityStateIds'] as List).single, isA<int>());
      expect(
        (metadata['seedLocalActivityIds'] as List).single,
        isNull,
        reason: 'a root owns UI state but is not an Activity PUSH',
      );
      await tester.tap(find.text('Push').last);
      await tester.pumpAndSettle();
      final detailEntry = Map<dynamic, dynamic>.from(entries.last);
      for (var pass = 0; pass < 2; pass++) {
        await _browserNavigation(
          tester,
          stepEntry['uri'] as String,
          state: stepEntry['state'],
        );
        expect(find.byType(SeedMenuSheet), findsNothing);
        if (pass == 0) {
          await _browserNavigation(
            tester,
            detailEntry['uri'] as String,
            state: detailEntry['state'],
          );
        }
      }
      await tester.tap(find.text('Menu Sheet 열기'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsOneWidget);
      SpaHistoryDelegate.of(tester.element(find.byType(SeedMenuSheet)))
          .popStep('menu-sheet');
      await tester.pumpAndSettle();
      expect(
        browserBackCalls,
        1,
        reason:
            'the root Step was locally pushed, unlike a direct open-query URL',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'new Activity at reused depth does not inherit a locally closed Step',
    (tester) async {
      final entries = <Map<dynamic, dynamic>>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.navigation,
        (call) async {
          if (call.method == 'routeInformationUpdated') {
            entries.add(Map<dynamic, dynamic>.from(call.arguments as Map));
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
      navigator.pushNamed('/menu-sheet-step');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Menu Sheet 열기'));
      await tester.pumpAndSettle();
      final oldEntry = Map<dynamic, dynamic>.from(entries.last);
      await tester.tap(find.text('수정').last);
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsNothing);
      navigator.pop();
      await tester.pumpAndSettle();
      navigator.pushNamed('/menu-sheet-step?menu-sheet=open');
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsOneWidget);
      final newEntry = Map<dynamic, dynamic>.from(entries.last);
      await _browserNavigation(
        tester,
        oldEntry['uri'] as String,
        state: oldEntry['state'],
      );
      expect(find.byType(SeedMenuSheet), findsNothing);
      await _browserNavigation(
        tester,
        newEntry['uri'] as String,
        state: newEntry['state'],
      );
      expect(find.byType(SeedMenuSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'restored in-session pushed Step still browser-backs on dismiss',
    (tester) async {
      final entries = <Map<dynamic, dynamic>>[];
      var browserBackCalls = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.navigation,
        (call) async {
          if (call.method == 'routeInformationUpdated') {
            entries.add(Map<dynamic, dynamic>.from(call.arguments as Map));
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
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/menu-sheet-step');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Menu Sheet 열기'));
      await tester.pumpAndSettle();
      final stepEntry = Map<dynamic, dynamic>.from(entries.last);
      await tester.tap(find.text('Push').last);
      await tester.pumpAndSettle();
      expect(Uri.parse(entries.last['uri'] as String).path, '/detail');
      await _browserNavigation(
        tester,
        stepEntry['uri'] as String,
        state: stepEntry['state'],
      );
      expect(find.byType(SeedMenuSheet), findsNothing);
      await tester.tap(find.text('Menu Sheet 열기'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenuSheet), findsOneWidget);
      final history = SpaHistoryDelegate.of(
        tester.element(find.text('Menu Sheet 열기')),
      );
      history.popStep('menu-sheet');
      await tester.pumpAndSettle();
      expect(
        browserBackCalls,
        1,
        reason: 'React Step pop uses browser Back even after Activity route rebuild',
      );
      expect(tester.takeException(), isNull);
    },
  );

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
  group('MenuSheet and BottomSheet steps', () {
    for (final width in [390.0, 800.0]) {
      testWidgets(
        'Menu Sheet Push then browser Back restores locally closed state at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
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
            () => tester.binding.defaultBinaryMessenger
                .setMockMethodCallHandler(SystemChannels.navigation, null),
          );
          await tester.pumpWidget(const StackflowSpaApp());
          await tester.pumpAndSettle();
          tester
              .state<NavigatorState>(find.byType(Navigator))
              .pushNamed('/menu-sheet-step');
          await tester.pumpAndSettle();
          final opener = find.widgetWithText(SeedButton, 'Menu Sheet 열기');
          await tester.tap(opener);
          await tester.pumpAndSettle();
          final stepEntry = Map<dynamic, dynamic>.from(updates.last);
          expect(
            Uri.parse(stepEntry['uri'] as String).queryParameters['menu-sheet'],
            'open',
          );
          await tester.tap(find.text('Push').last);
          await tester.pumpAndSettle();
          expect(Uri.parse(updates.last['uri'] as String).path, '/detail');
          final detailEntry = Map<dynamic, dynamic>.from(updates.last);
          await _revisit(tester, stepEntry);
          expect(
            Uri.parse(stepEntry['uri'] as String).queryParameters['menu-sheet'],
            'open',
          );
          expect(
            find.byType(SeedMenuSheet),
            findsNothing,
            reason: 'React retains setOpen(false) across detail Push and browser Back',
          );
          await _revisit(tester, detailEntry);
          expect(find.byType(SeedMenuSheet), findsNothing);
          await _revisit(tester, stepEntry);
          expect(
            find.byType(SeedMenuSheet),
            findsNothing,
            reason: 'Forward then Back must still restore local closed state',
          );
          await tester.tap(find.widgetWithText(SeedButton, 'Menu Sheet 열기'));
          await tester.pumpAndSettle();
          expect(find.byType(SeedMenuSheet), findsOneWidget);
          expect(
            SpaHistoryDelegate.of(tester.element(find.byType(SeedMenuSheet)))
                .isStepOpen('menu-sheet'),
            isTrue,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
    for (final width in [390.0, 800.0]) {
      testWidgets(
        'Menu Sheet Step action closes locally but retains query at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(const StackflowSpaApp());
          await tester.pumpAndSettle();
          tester
              .state<NavigatorState>(find.byType(Navigator))
              .pushNamed('/menu-sheet-step');
          await tester.pumpAndSettle();
          final opener = find.widgetWithText(SeedButton, 'Menu Sheet 열기');
          await tester.tap(opener);
          await tester.pumpAndSettle();
          expect(find.byType(SeedMenuSheet), findsOneWidget);
          expect(
            SpaHistoryDelegate.of(tester.element(opener))
                .isStepOpen('menu-sheet'),
            isTrue,
          );
          await tester.tap(find.text('추가'));
          await tester.pumpAndSettle();
          expect(find.byType(SeedMenuSheet), findsNothing);
          expect(
            SpaHistoryDelegate.of(tester.element(opener))
                .isStepOpen('menu-sheet'),
            isTrue,
            reason: 'React handleAction setOpen(false) does not call popStep',
          );
          // A later trigger may reopen without adding an extra query Step.
          await tester.tap(opener);
          await tester.pumpAndSettle();
          expect(find.byType(SeedMenuSheet), findsOneWidget);
          expect(
            SpaHistoryDelegate.of(tester.element(opener))
                .isStepOpen('menu-sheet'),
            isTrue,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
    for (final width in [390.0, 800.0]) {
      for (final (route, key, opener, overlay) in _steps) {
        testWidgets('$route open/close uses query step history at $width', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
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
          final navigator = tester.state<NavigatorState>(
            find.byType(Navigator),
          );
          navigator.pushNamed(route);
          await tester.pumpAndSettle();
          expect(Uri.parse(updates.last['uri'] as String).query, isEmpty);
          final closedEntry = Map<dynamic, dynamic>.from(updates.last);

          await tester.tap(find.widgetWithText(SeedButton, opener));
          await tester.pumpAndSettle();
          expect(
            Uri.parse(updates.last['uri'] as String).queryParameters[key],
            'open',
            reason: 'Official React pushStep changes the browser URL',
          );
          final openedEntry = Map<dynamic, dynamic>.from(updates.last);
          final closedActivities =
              (closedEntry['state'] as Map)['seedActivities'] as List;
          final openedActivities =
              (openedEntry['state'] as Map)['seedActivities'] as List;
          expect(
            openedActivities.length,
            closedActivities.length,
            reason:
                'React pushStep keeps one Activity and changes its URL params',
          );
          switch (overlay) {
            case 'SeedAlertDialog':
              expect(find.byType(SeedAlertDialog), findsOneWidget);
            case 'SeedBottomSheet':
              expect(find.byType(SeedBottomSheet), findsOneWidget);
            case 'SeedMenuSheet':
              expect(find.byType(SeedMenuSheet), findsOneWidget);
          }

          // Back/Forward must update the current Step in place, rather than
          // discard the parent activity or create a second unrelated activity.
          await _revisit(tester, closedEntry);
          switch (overlay) {
            case 'SeedAlertDialog':
              expect(find.byType(SeedAlertDialog), findsNothing);
            case 'SeedBottomSheet':
              expect(find.byType(SeedBottomSheet), findsNothing);
            case 'SeedMenuSheet':
              expect(find.byType(SeedMenuSheet), findsNothing);
          }
          expect(find.widgetWithText(SeedButton, opener), findsOneWidget);

          await _revisit(tester, openedEntry);
          switch (overlay) {
            case 'SeedAlertDialog':
              expect(find.byType(SeedAlertDialog), findsOneWidget);
            case 'SeedBottomSheet':
              expect(find.byType(SeedBottomSheet), findsOneWidget);
            case 'SeedMenuSheet':
              expect(find.byType(SeedMenuSheet), findsOneWidget);
          }

          if (overlay == 'SeedMenuSheet') {
            // SwipeableMenuSheetContent has no visible close button. Its
            // backdrop reports onOpenChange(false) and invokes popStep.
            await tester.tapAt(const Offset(4, 100));
          } else {
            await tester.tap(find.widgetWithText(SeedButton, '닫기').last);
          }
          await tester.pumpAndSettle();
          // React Alert Dialog footer closes its controlled overlay with
          // setOpen(false) only; unlike backdrop/BottomSheet dismissal it does
          // not call popStep and therefore retains ?alert-dialog=open.
          if (overlay == 'SeedAlertDialog') {
            expect(
              Uri.parse(updates.last['uri'] as String).queryParameters[key],
              'open',
            );
          } else {
            expect(
              Uri.parse(updates.last['uri'] as String).query,
              isEmpty,
              reason: 'React modal onOpenChange(false) invokes popStep',
            );
          }
          expect(Uri.parse(updates.last['uri'] as String).path, route);
          switch (overlay) {
            case 'SeedAlertDialog':
              expect(find.byType(SeedAlertDialog), findsNothing);
            case 'SeedBottomSheet':
              expect(find.byType(SeedBottomSheet), findsNothing);
            case 'SeedMenuSheet':
              expect(find.byType(SeedMenuSheet), findsNothing);
          }
          expect(tester.takeException(), isNull);
        });

        testWidgets('$route direct query opens and closes Step at $width', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
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
          final navigator = tester.state<NavigatorState>(
            find.byType(Navigator),
          );
          navigator.pushNamed('$route?$key=open');
          await tester.pumpAndSettle();
          expect(find.widgetWithText(SeedButton, opener), findsOneWidget);
          expect(
            Uri.parse(updates.last['uri'] as String).queryParameters[key],
            'open',
          );

          switch (overlay) {
            case 'SeedAlertDialog':
              expect(find.byType(SeedAlertDialog), findsOneWidget);
              await tester.tap(find.widgetWithText(SeedButton, '닫기').last);
            case 'SeedBottomSheet':
              expect(find.byType(SeedBottomSheet), findsOneWidget);
              await tester.tap(find.widgetWithText(SeedButton, '닫기').last);
            case 'SeedMenuSheet':
              expect(find.byType(SeedMenuSheet), findsOneWidget);
              await tester.tap(find.text('수정').last);
          }
          await tester.pumpAndSettle();
          expect(Uri.parse(updates.last['uri'] as String).path, route);
          if (overlay == 'SeedAlertDialog' || overlay == 'SeedMenuSheet') {
            // Menu Sheet's "수정" action and Alert footer both invoke React
            // setOpen(false) without emitting onOpenChange(false)/popStep.
            expect(
              Uri.parse(updates.last['uri'] as String).queryParameters[key],
              'open',
            );
          } else {
            expect(Uri.parse(updates.last['uri'] as String).query, isEmpty);
          }
          expect(tester.takeException(), isNull);
        });

        testWidgets(
          '$route Push action dismisses Step before detail at $width',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
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
            final navigator = tester.state<NavigatorState>(
              find.byType(Navigator),
            );
            navigator.pushNamed(route);
            await tester.pumpAndSettle();
            await tester.tap(find.widgetWithText(SeedButton, opener));
            await tester.pumpAndSettle();
            expect(
              Uri.parse(updates.last['uri'] as String).queryParameters[key],
              'open',
            );

            if (overlay == 'SeedMenuSheet') {
              await tester.tap(find.text('Push').last);
            } else {
              await tester.tap(find.widgetWithText(SeedButton, 'Push').last);
            }
            await tester.pumpAndSettle();
            expect(Uri.parse(updates.last['uri'] as String).path, '/detail');
            expect(Uri.parse(updates.last['uri'] as String).query, isEmpty);
            expect(find.widgetWithText(SeedButton, opener), findsNothing);
            navigator.pop();
            await tester.pumpAndSettle();
            expect(find.widgetWithText(SeedButton, opener), findsOneWidget);
            expect(find.byType(SeedAlertDialog), findsNothing);
            expect(find.byType(SeedBottomSheet), findsNothing);
            expect(find.byType(SeedMenuSheet), findsNothing);
            expect(Uri.parse(updates.last['uri'] as String).path, route);
            if (overlay == 'SeedAlertDialog' || overlay == 'SeedMenuSheet') {
              // React Push closes either controlled overlay locally, but does not
              // call popStep on its previous Activity's query.
              expect(
                Uri.parse(updates.last['uri'] as String).queryParameters[key],
                'open',
              );
            } else {
              expect(Uri.parse(updates.last['uri'] as String).query, isEmpty);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });
}
