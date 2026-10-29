import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

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
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
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
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
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
        if (overlay == 'SeedAlertDialog') {
          expect(
            Uri.parse(updates.last['uri'] as String).queryParameters[key],
            'open',
          );
        } else {
          expect(Uri.parse(updates.last['uri'] as String).query, isEmpty);
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('$route Push action dismisses Step before detail at $width', (
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
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
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
        if (overlay == 'SeedAlertDialog') {
          // React Push closes controlled dialog, but does not clear Step.
          expect(
            Uri.parse(updates.last['uri'] as String).queryParameters[key],
            'open',
          );
        } else {
          expect(Uri.parse(updates.last['uri'] as String).query, isEmpty);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
