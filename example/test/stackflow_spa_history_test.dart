import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_routes.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

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
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
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
}
