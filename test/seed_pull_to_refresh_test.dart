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

  // React pullToRefresh.preventPull excludes the root gesture while leaving
  // native text selection intact (react-headless/pull-to-refresh/src/dom.ts).
  // A mouse diagonal crosses Flutter's vertical gesture threshold; test the
  // actual selected range rather than relying on a painted selection color.
  for (final size in const [Size(390, 844), Size(800, 800)]) {
    testWidgets(
      'protected selectable text preserves diagonal mouse selection $size',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var refreshes = 0;
        await tester.pumpWidget(
          host(
            SeedPullToRefresh(
              onRefresh: () async => refreshes++,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: const [
                  SizedBox(height: 162),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SeedPullToRefreshPreventPull(
                      child: SelectableText(
                        '이 요소는 Article 내부에 있으므로 텍스트 선택이 가능합니다. '
                        '이 Article은 PTR 제스처를 호출하지 않도록 설정되어 있습니다. '
                        '여기를 아래로 끌어 당기면 PTR이 작동하는 대신 텍스트가 선택됩니다.',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 1600),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        const start = Offset(88, 176);
        final end = Offset(size.width == 390 ? 320 : 510, 220);
        expect(
          tester.getRect(find.byType(SelectableText)).contains(start),
          isTrue,
        );
        final mouse = await tester.startGesture(
          start,
          kind: PointerDeviceKind.mouse,
        );
        for (var step = 1; step <= 20; step++) {
          await mouse.moveTo(Offset.lerp(start, end, step / 20)!);
          await tester.pump(const Duration(milliseconds: 12));
        }
        final selection = tester
            .widget<EditableText>(find.byType(EditableText))
            .controller
            .selection;
        await mouse.up();
        await tester.pumpAndSettle();
        expect(
          selection.isValid,
          isTrue,
          reason: 'A protected React Article remains selectable on mouse drag',
        );
        expect(selection.end - selection.start, greaterThan(0));
        expect(refreshes, 0, reason: 'PreventPull must not trigger refresh');
      },
    );

    for (final pointerKind in [
      PointerDeviceKind.mouse,
      PointerDeviceKind.touch,
    ]) {
      testWidgets(
        'outside protected text preserves exact PTR callback sequence '
        '$pointerKind $size',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final pending = <Completer<void>>[];
          var refreshes = 0;
          await tester.pumpWidget(
            host(
              SeedPullToRefresh(
                onRefresh: () {
                  refreshes++;
                  pending.add(Completer<void>());
                  return pending.last.future;
                },
                child: ListView(
                  children: const [
                    SeedPullToRefreshPreventPull(
                      child: SizedBox(
                        height: 80,
                        child: Text('protected region'),
                      ),
                    ),
                    SizedBox(height: 1700),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final start = Offset(size.width / 2, 145); // Outside protected child.
          Future<TestGesture> ready() async {
            final g = await tester.startGesture(start, kind: pointerKind);
            await g.moveBy(const Offset(0, 30));
            await tester.pump();
            await g.moveBy(const Offset(0, 220));
            await tester.pump();
            return g;
          }

          final cancel = await ready();
          await cancel.cancel();
          await tester.pumpAndSettle();
          expect(refreshes, 0, reason: 'Cancel does not refresh');
          final first = await ready();
          expect(indicator(tester).value, 1);
          await first.up();
          await tester.pump();
          expect(refreshes, 1);
          final held = await tester.startGesture(start, kind: pointerKind);
          await held.moveBy(const Offset(0, 30));
          await tester.pump();
          await held.moveBy(const Offset(0, 25));
          await tester.pump();
          expect(
            refreshes,
            1,
            reason: 'Pending async refresh excludes overlap',
          );
          pending.first.complete();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 16));
          await held.moveBy(const Offset(0, 30));
          await tester.pump();
          await held.moveBy(const Offset(0, 190));
          await tester.pump();
          await held.up();
          await tester.pump();
          expect(refreshes, 2, reason: 'Same contact re-arms after settlement');
          pending.last.complete();
          await tester.pumpAndSettle();
          expect(refreshes, 2);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

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
