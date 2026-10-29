// Frozen original case: p5fup2-nav-800-responsive-panel-large-small-close-history.
// Uses the actual SPA/SidePanel controls at 800x800. Flutter widget tests do
// not simulate an actual Chromium about:blank / native Forward document load.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_history.dart';
import 'package:seed_design_example/stackflow_spa/spa_types.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

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

void main() {
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
      expect(tester.widget<SeedSidePanel>(panel).size, SeedSidePanelSize.large);
      expect(tester.getRect(panel).width, closeTo(640, 0.01));

      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
        'small',
      );
      expect(tester.widget<SeedSidePanel>(panel).size, SeedSidePanelSize.small);
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
      expect(tester.widget<SeedSidePanel>(panel).size, SeedSidePanelSize.small);
      expect(
        ModalRoute.of(tester.element(routeHost))?.settings.name,
        '/responsive-side-panel',
      );
      expect(
        history.currentConfiguration.activities.last.name,
        '/responsive-side-panel',
      );
      expect(
        platformUpdates.skip(emittedBeforeClose).where((e) => e['uri'] == '/'),
        isEmpty,
        reason: 'Direct root close cannot publish Home as a new/replace entry',
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
}
