import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_routes.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets('Home Side Navigation replaces current Activity at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      final observer = navigator.widget.observers.singleWhere(
        (observer) => observer is SpaGestureObserver,
      ) as SpaGestureObserver;
      expect(observer.activityIndex, 0);

      final entry = find.text('Side Navigation');
      await tester.ensureVisible(entry);
      await tester.pumpAndSettle();
      await tester.tap(entry);
      await tester.pumpAndSettle();

      expect(find.byType(SeedSideNavigation), findsOneWidget);
      // React ActivityHome calls replace('ActivitySideNavigation'), so the
      // former Home must not remain underneath the new Activity.
      expect(observer.activityIndex, 0);
      expect(navigator.canPop(), isFalse);
    });
  }

  testWidgets('Home desktop highlights the first section of the visible row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    final scroll = find.byType(CustomScrollView);
    await tester.drag(scroll, const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(
      tester.widget<CustomScrollView>(scroll).controller!.offset,
      greaterThan(0),
    );
    // React ActivityHome uses visible.find(...) after choosing rowTop,
    // which selects the first matching section when cards share a grid row.
    expect(
      tester
          .widget<SeedChip>(find.widgetWithText(SeedChip, 'AppScreen'))
          .checked,
      isTrue,
    );
    expect(
      tester.widget<SeedChip>(find.widgetWithText(SeedChip, 'Drawer')).checked,
      isFalse,
    );
  });
}
