// Frozen case: p5fup2-nav-390-responsive-panel-large-small-close-history.
// The real Flutter 390x844 responsive route shows a BottomSheet. This
// WidgetTester suite checks Activity state, not actual Chromium history.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_history.dart';
import 'package:seed_design_example/stackflow_spa/spa_types.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

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

void main() {
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
            routeUpdates.add(Map<dynamic, dynamic>.from(call.arguments as Map));
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
}
