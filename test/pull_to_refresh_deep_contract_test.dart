import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

// Official React usePullToRefresh.ts:
// - startEvent:134-136 retains originRef until end/cancel;
// - disableEvent:245-252 aborts the active pull but leaves originRef alive;
// - moveEvent:138-152 may start another pull on the SAME contact once enabled.
// This is a disabled->enabled rearm, NOT the previous negative-retreat fix.
void main() {
  for (final surface in [const Size(390, 844), const Size(800, 800)]) {
    testWidgets(
      'ROUND3 active disabled→enabled preserves contact origin $surface',
      (tester) async {
        await tester.binding.setSurfaceSize(surface);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var enabled = true;
        var ready = 0;
        var refreshes = 0;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (_, setState) {
                  update = setState;
                  return SeedPullToRefresh(
                    enabled: enabled,
                    onReady: () => ready++,
                    onRefresh: () async => refreshes++,
                    child: ListView(
                      children: const [
                        SizedBox(height: 1800, child: Text('PTR target')),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
        final held = await tester.startGesture(Offset(surface.width / 2, 120));
        await held.moveBy(const Offset(0, 35));
        await tester.pump();
        await held.moveBy(const Offset(0, 170));
        await tester.pump();
        expect(ready, 1, reason: 'same-contact first pull has reached READY');
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          1,
        );

        // React disableEvent aborts the pull and resets its displacement, but
        // keeps originRef until a true pointer-up/pointer-cancel is received.
        update(() => enabled = false);
        await tester.pump();
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        expect(refreshes, 0);

        // A second disabled parent rebuild must not erase the same held
        // contact. React's disable handler does nothing once state is idle.
        update(() => enabled = false);
        await tester.pump();
        update(() => enabled = true);
        await tester.pump();
        await held.moveBy(const Offset(0, 30));
        await tester.pump();
        await held.moveBy(const Offset(0, 170));
        await tester.pump();
        expect(
          ready,
          2,
          reason: 'React may start a fresh pull on the still-held contact after reenable',
        );
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          1,
        );
        expect(refreshes, 0);
        await held.up();
        await tester.pumpAndSettle();
        expect(refreshes, 1, reason: 'only the rearmed READY release commits');
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('ROUND3 disabled contact cancel clears stale origin $surface', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(surface);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var enabled = true;
      var ready = 0;
      var refreshes = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                update = setState;
                return SeedPullToRefresh(
                  enabled: enabled,
                  onReady: () => ready++,
                  onRefresh: () async => refreshes++,
                  child: ListView(children: const [SizedBox(height: 1800)]),
                );
              },
            ),
          ),
        ),
      );
      final held = await tester.startGesture(Offset(surface.width / 2, 130));
      await held.moveBy(const Offset(0, 35));
      await tester.pump();
      await held.moveBy(const Offset(0, 180));
      await tester.pump();
      expect(ready, 1);
      update(() => enabled = false);
      await tester.pump();
      await held.cancel();
      await tester.pump();
      update(() => enabled = true);
      await tester.pumpAndSettle();
      expect(refreshes, 0, reason: 'cancel must never commit prior READY');
      expect(
        tester
            .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
            .value,
        0,
      );

      final fresh = await tester.startGesture(Offset(surface.width / 2, 130));
      await fresh.moveBy(const Offset(0, 35));
      await tester.pump();
      await fresh.moveBy(const Offset(0, 170));
      await tester.pump();
      expect(ready, 2, reason: 'new contact re-arms from a clean origin');
      await fresh.up();
      await tester.pumpAndSettle();
      expect(refreshes, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
