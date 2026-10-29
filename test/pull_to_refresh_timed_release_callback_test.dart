// Round3 isolated PUBLIC API consumer tests. No React/Flutter SPA browser inference.
// Differentiator vs Round2: sample release at exact pump frame offsets and
// verify cancellation after READY retreat, followed by fresh async cycle.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final surface in const [Size(800, 800), Size(390, 844)]) {
    testWidgets('Round3 release timeline, overlapping retry blocked $surface', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(surface);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pending = <Completer<void>>[];
      var callbacks = 0;
      var readyCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedPullToRefresh(
              onReady: () => readyCalls++,
              onRefresh: () {
                callbacks++;
                final c = Completer<void>();
                pending.add(c);
                return c.future;
              },
              child: ListView(children: const [
                SizedBox(height: 1900, child: Text('release timeline consumer')),
              ]),
            ),
          ),
        ),
      );
      final x = surface.width / 2;
      final first = await tester.startGesture(Offset(x, 110));
      await first.moveBy(const Offset(0, 30));
      await tester.pump();
      await first.moveBy(const Offset(0, 220));
      await tester.pump();
      expect(readyCalls, 1);
      expect(callbacks, 0);
      expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 1);
      await first.up();
      await tester.pump(); // t=0: next Flutter render frame after pointer-up
      expect(callbacks, 1, reason: 'pointer-up invokes exactly one refresh');
      expect(pending.length, 1);
      expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, isNull);

      // Flutter test clocks are deterministic. They are not browser CDP event times.
      for (final dt in const [16, 34, 100, 150]) {
        await tester.pump(Duration(milliseconds: dt)); // cumulative 16/50/150/300
        expect(callbacks, 1);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, isNull);
      }
      // Explicitly try another contact while the original Future is unresolved.
      final attempt = await tester.startGesture(Offset(x, 110));
      await attempt.moveBy(const Offset(0, 30));
      await tester.pump();
      await attempt.moveBy(const Offset(0, 230));
      await tester.pump();
      await attempt.up();
      await tester.pump();
      expect(callbacks, 1, reason: 'loading disallows overlapping callback');
      expect(readyCalls, 1);

      pending.first.complete();
      await tester.pumpAndSettle();
      expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);
      final rearm = await tester.startGesture(Offset(x, 110));
      await rearm.moveBy(const Offset(0, 30));
      await tester.pump();
      await rearm.moveBy(const Offset(0, 220));
      await tester.pump();
      expect(readyCalls, 2);
      await rearm.up();
      await tester.pump();
      expect(callbacks, 2);
      pending.last.complete();
      await tester.pumpAndSettle();
      expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Round3 ready retreat release cancels callback; fresh contact succeeds $surface', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(surface);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var callbacks = 0;
      var readyCalls = 0;
      await tester.pumpWidget(MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(body: SeedPullToRefresh(
          onReady: () => readyCalls++,
          onRefresh: () async { callbacks++; },
          child: ListView(children: const [SizedBox(height: 1900)]),
        )),
      ));
      final x = surface.width / 2;
      final gesture = await tester.startGesture(Offset(x, 110));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 210));
      await tester.pump();
      expect(readyCalls, 1);
      expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 1);
      await gesture.moveBy(const Offset(0, -135));
      await tester.pump();
      expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, lessThan(1));
      await gesture.up();
      await tester.pump();
      expect(callbacks, 0, reason: 'retreated contact does not refresh on release');
      for (final dt in const [16, 34, 100, 150]) {
        await tester.pump(Duration(milliseconds: dt));
        expect(callbacks, 0);
      }
      await tester.pumpAndSettle();
      final fresh = await tester.startGesture(Offset(x, 110));
      await fresh.moveBy(const Offset(0, 30));
      await tester.pump();
      await fresh.moveBy(const Offset(0, 220));
      await tester.pump();
      await fresh.up();
      await tester.pumpAndSettle();
      expect(readyCalls, 2);
      expect(callbacks, 1);
      expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);
      expect(tester.takeException(), isNull);
    });
  }
}
