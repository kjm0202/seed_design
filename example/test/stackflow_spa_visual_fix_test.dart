import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> open(
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
  testWidgets(
    'LayerBar uses a white surface and starts controls below AppBar',
    (tester) async {
      await open(tester, '/layer-bar');
      final button = find.widgetWithText(SeedButton, 'ActivityTransparentBar');
      expect(tester.getTopLeft(button).dy, 68);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, Colors.white);
      expect(find.text('AppBarLeft / AppBarRight'), findsNothing);
      expect(
        tester
            .widget<SeedTopNavigation>(find.byType(SeedTopNavigation).last)
            .centerTitle,
        false,
      );
      await tester.tap(find.text('Append Left'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Left notification 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Sticky tab list pins below AppBar while its introduction scrolls away',
    (tester) async {
      await open(tester, '/tabs');
      expect(find.text('Sticky Tablist'), findsOneWidget);
      await tester.drag(
        find.byType(CustomScrollView).last,
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sticky Tablist').hitTestable(), findsNothing);
      expect(tester.getTopLeft(find.byType(SeedTabs)).dy, 56);
      await tester.tap(find.text('Tab 2'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Tab 2 content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('SideNavigation collapses and expands without layout overflow', (
    tester,
  ) async {
    await open(tester, '/side-navigation');
    expect(tester.getTopLeft(find.byType(SeedSideNavigation)).dy, 0);
    await tester.tap(find.byTooltip('접기'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SeedSideNavigation)).width, 56);
    await tester.tap(find.byTooltip('펼치기'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SeedSideNavigation)).width, 240);
  });

  for (final route in ['/side-panel', '/responsive-side-panel']) {
    testWidgets('$route keeps the default 80% panel cap at desktop width', (
      tester,
    ) async {
      await open(tester, route);
      final panel = find.byType(SeedSidePanel);
      expect(tester.getSize(panel).width, 640);
      expect(tester.getTopLeft(panel).dx, 160);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'Form keeps email and address side by side and serializes successful controls',
    (tester) async {
      await open(tester, '/form', width: 390);
      final email = find.byWidgetPredicate(
        (w) => w is SeedTextField && w.label == '이메일',
      );
      final address = find.byWidgetPredicate(
        (w) => w is SeedTextField && w.label == '주소',
      );
      expect(tester.getTopLeft(email).dy, tester.getTopLeft(address).dy);
      expect(
        tester.getTopLeft(email).dx,
        lessThan(tester.getTopLeft(address).dx),
      );
      await tester.tap(find.widgetWithText(SeedButton, '제출'));
      await tester.pumpAndSettle();
      final data = jsonDecode(
        tester.widget<SeedSnackbar>(find.byType(SeedSnackbar)).message,
      ) as Map;
      expect(data['attachments'], [{}]);
      for (final key in ['category', 'extra', 'fruit', 'agreement']) {
        expect(data.containsKey(key), false);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Avatar ALL sizes fit in the 800px preview without artificial tile widths',
    (tester) async {
      await open(tester, '/avatar');
      await tester.tap(find.byType(DropdownButton<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('All').last);
      await tester.pumpAndSettle();
      expect(find.byType(SeedAvatar), findsNWidgets(10));
      for (final avatar in find.byType(SeedAvatar).evaluate()) {
        final rect = tester.getRect(
          find.byElementPredicate((e) => e == avatar),
        );
        expect(rect.left, greaterThanOrEqualTo(16));
        expect(rect.right, lessThanOrEqualTo(784.01));
        expect(rect.top, 72);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'transparent AppScreen has the official full-screen slate surface and slots',
    (tester) async {
      await open(tester, '/app-screen-transparent');
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.extendBodyBehindAppBar, true);
      expect(scaffold.backgroundColor, SeedPalette.gray800Light);
      // React app-bar.tsx:111-115 renders Close only for root activities.
      // open() pushes this page on top of Home, so it is a nested activity.
      expect(find.bySemanticsLabel('Close'), findsNothing);
      expect(find.bySemanticsLabel('Notification'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
