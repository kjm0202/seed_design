import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

// React usePullToRefresh.ts:155-180 rebases y0 to the retreating finger on
// displacement <= 0 instead of returning to idle or forgetting the origin.
// These tests isolate that contract from a previous dispose/late-up repair.
void main() {
  for (final size in [const Size(390, 844), const Size(800, 800)]) {
    testWidgets('strict 88px boundary and same-contact ready retreat $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var ready = 0;
      var refreshes = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedPullToRefresh(
              onReady: () => ready++,
              onRefresh: () async => refreshes++,
              child: ListView(children: const [SizedBox(height: 1700)]),
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(Offset(size.width / 2, 120));
      await gesture.moveBy(const Offset(0, 35));
      await tester.pump();
      // Exactly 88px displacement: 88 / 0.75 logical finger pixels.
      await gesture.moveBy(const Offset(0, 88 / 0.75));
      await tester.pump();
      expect(
        tester
            .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
            .value,
        closeTo(1, 1e-9),
      );
      expect(ready, 0, reason: 'React requires displacement > threshold');
      await gesture.moveBy(const Offset(0, 1));
      await tester.pump();
      expect(ready, 1);
      await gesture.moveBy(const Offset(0, -15));
      await tester.pump();
      expect(
        tester
            .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
            .value,
        lessThan(1),
      );
      await gesture.moveBy(const Offset(0, 16));
      await tester.pump();
      expect(ready, 2, reason: 'ready re-enters after retreat below 88px');
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 1);
    });

    testWidgets('continuous pointer rebases after retreat and re-arms $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var ready = 0;
      var refreshes = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedPullToRefresh(
              onReady: () => ready++,
              onRefresh: () async => refreshes++,
              child: ListView(
                children: const [
                  SizedBox(height: 1700, child: Text('PTR continuous region')),
                ],
              ),
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(Offset(size.width / 2, 120));
      // Move 35px first, so the native vertical scroll drag wins the arena.
      await gesture.moveBy(const Offset(0, 35));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 170));
      await tester.pump();
      expect(ready, 1, reason: 'the initial pull crosses 88px');
      // The pointer retreats ABOVE its accepted pull start without release.
      // React keeps pulling, rebases y0, and sets displacement to zero.
      await gesture.moveBy(const Offset(0, -250));
      await tester.pump();
      expect(
        tester
            .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
            .value,
        0,
      );
      // From the retreat position the same contact moves down 145px:
      // React displacement = 145 * 0.75 = 108.75 > 88; READY again.
      await gesture.moveBy(const Offset(0, 145));
      await tester.pump();
      expect(
        tester
            .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
            .value,
        1,
        reason: 'the same contact must re-arm from its rebased origin',
      );
      expect(ready, 2, reason: 'READY after retreat is a second transition');
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 1, reason: 'only the final READY release refreshes');
      expect(tester.takeException(), isNull);
    });
  }
}
