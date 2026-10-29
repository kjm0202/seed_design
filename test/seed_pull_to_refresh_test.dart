import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

SeedProgressCircle indicator(WidgetTester tester) =>
    tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle));

Future<TestGesture> startPull(
  WidgetTester tester, {
  PointerDeviceKind kind = PointerDeviceKind.touch,
}) async {
  final gesture = await tester.startGesture(const Offset(200, 100), kind: kind);
  // First movement lets the scrollable accept the vertical drag.
  await gesture.moveBy(const Offset(0, 30));
  await tester.pump();
  return gesture;
}

void main() {
  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    for (final bouncing in [false, true]) {
      testWidgets('$kind (bouncing=$bouncing) only loads on ready release', (
        tester,
      ) async {
        final completion = Completer<void>();
        var refreshes = 0;
        var ready = 0;
        await tester.pumpWidget(
          host(
            SeedPullToRefresh(
              onReady: () => ready++,
              onRefresh: () {
                refreshes++;
                return completion.future;
              },
              child: ListView(
                physics: bouncing
                    ? const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      )
                    : null,
                children: const [SizedBox(height: 1200)],
              ),
            ),
          ),
        );
        final gesture = await startPull(tester, kind: kind);
        await gesture.moveBy(const Offset(0, 60));
        await tester.pump();
        expect(indicator(tester).value, closeTo(45 / 88, 0.001));
        expect(ready, 0);
        expect(refreshes, 0);

        await gesture.moveBy(const Offset(0, 100));
        await tester.pump(const Duration(seconds: 2));
        expect(indicator(tester).value, 1);
        expect(ready, 1);
        expect(refreshes, 0);
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump();
        expect(
          ready,
          2,
          reason: 'React fires onPtrReady again for a move while still ready',
        );

        await gesture.up();
        await tester.pump();
        expect(refreshes, 1);
        expect(indicator(tester).value, isNull);
        // A second pull during loading must not invoke onRefresh again.
        await tester.dragFrom(const Offset(200, 200), const Offset(0, 200));
        await tester.pump();
        expect(refreshes, 1);
        completion.complete();
        await tester.pumpAndSettle();
        expect(indicator(tester).value, 0);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('short pulls and ready pulls retreated below threshold cancel', (
    tester,
  ) async {
    var refreshes = 0;
    var ready = 0;
    await tester.pumpWidget(
      host(
        SeedPullToRefresh(
          onReady: () => ready++,
          onRefresh: () async => refreshes++,
          child: ListView(children: const [SizedBox(height: 1200)]),
        ),
      ),
    );
    var gesture = await startPull(tester);
    await gesture.moveBy(const Offset(0, 50));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(refreshes, 0);
    expect(ready, 0);

    gesture = await startPull(tester);
    await gesture.moveBy(const Offset(0, 160));
    await tester.pump();
    expect(ready, 1);
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(indicator(tester).value, closeTo(45 / 88, 0.001));
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.pixels, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(refreshes, 0);
  });

  testWidgets(
    'cancelled ready pulls and disabling during a pull do not refresh',
    (tester) async {
      var refreshes = 0;
      var enabled = true;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SeedPullToRefresh(
                enabled: enabled,
                onRefresh: () async => refreshes++,
                child: ListView(children: const [SizedBox(height: 1200)]),
              );
            },
          ),
        ),
      );
      var gesture = await startPull(tester);
      await gesture.moveBy(const Offset(0, 160));
      await tester.pump();
      expect(indicator(tester).value, 1);
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(refreshes, 0);
      expect(indicator(tester).value, 0);

      gesture = await startPull(tester);
      await gesture.moveBy(const Offset(0, 160));
      await tester.pump();
      update(() => enabled = false);
      await tester.pump();
      update(() => enabled = true);
      await tester.pump();
      await gesture.moveBy(const Offset(0, 160));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 0);
      expect(indicator(tester).value, 0);
    },
  );

  testWidgets('local drag handlers, preventPull and predicate exclude pulls', (
    tester,
  ) async {
    var refreshes = 0;
    for (final mode in ['local', 'prevent', 'disabled', 'predicate']) {
      await tester.pumpWidget(
        host(
          SeedPullToRefresh(
            key: ValueKey(mode),
            enabled: mode != 'disabled',
            preventPull: mode == 'prevent',
            notificationPredicate: mode == 'predicate' ? (_) => false : null,
            onRefresh: () async => refreshes++,
            child: ListView(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: mode == 'local' ? (_) {} : null,
                  child: const SizedBox(height: 1200),
                ),
              ],
            ),
          ),
        ),
      );
      final gesture = await startPull(tester);
      await gesture.moveBy(const Offset(0, 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 0, reason: mode);
    }
  });

  testWidgets(
    'prevent-pull marker preserves scrolling and allows other regions to refresh',
    (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var refreshes = 0;
      await tester.pumpWidget(
        host(
          SeedPullToRefresh(
            onRefresh: () async => refreshes++,
            child: ListView(
              controller: scroll,
              children: const [
                SeedPullToRefreshPreventPull(
                  child: SizedBox(height: 400, child: Text('protected')),
                ),
                SizedBox(height: 1800),
              ],
            ),
          ),
        ),
      );
      await tester.dragFrom(const Offset(200, 250), const Offset(0, -160));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(0));
      scroll.jumpTo(0);
      await tester.pump();
      var gesture = await startPull(tester);
      await gesture.moveBy(const Offset(0, 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 0);
      gesture = await tester.startGesture(const Offset(200, 450));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 1);
    },
  );

  testWidgets('scrolling away from the top and wheel events do not pull', (
    tester,
  ) async {
    final controller = ScrollController(initialScrollOffset: 500);
    addTearDown(controller.dispose);
    var refreshes = 0;
    await tester.pumpWidget(
      host(
        SeedPullToRefresh(
          onRefresh: () async => refreshes++,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );
    final gesture = await startPull(tester);
    await gesture.moveBy(const Offset(0, 180));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(refreshes, 0);
    expect(indicator(tester).value, 0);
    controller.jumpTo(0);
    await tester.pump();
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(200, 100),
        scrollDelta: Offset(0, -300),
      ),
    );
    await tester.pumpAndSettle();
    expect(refreshes, 0);
    expect(indicator(tester).value, 0);
  });

  testWidgets('configured threshold and multiplier work with short content', (
    tester,
  ) async {
    var refreshes = 0;
    await tester.pumpWidget(
      host(
        SeedPullToRefresh(
          threshold: 50,
          displacementMultiplier: 0.5,
          onRefresh: () async => refreshes++,
          child: ListView(children: const [Text('Short content')]),
        ),
      ),
    );
    final gesture = await startPull(tester);
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    expect(indicator(tester).value, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    // Reaching the threshold exactly is not ready (React uses > threshold).
    expect(refreshes, 0);
    final next = await startPull(tester);
    await next.moveBy(const Offset(0, 110));
    await next.up();
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });

  testWidgets('failed refresh settles and disposal during loading is safe', (
    tester,
  ) async {
    var refreshes = 0;
    final completion = Completer<void>();
    await tester.pumpWidget(
      host(
        SeedPullToRefresh(
          onRefresh: () {
            refreshes++;
            return refreshes == 1
                ? Future<void>.error(StateError('Refresh failed'))
                : completion.future;
          },
          child: ListView(children: const [SizedBox(height: 1200)]),
        ),
      ),
    );
    var gesture = await startPull(tester);
    await gesture.moveBy(const Offset(0, 200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(indicator(tester).value, 0);
    gesture = await startPull(tester);
    await gesture.moveBy(const Offset(0, 200));
    await gesture.up();
    await tester.pump();
    expect(refreshes, 2);
    await tester.pumpWidget(const SizedBox());
    completion.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
