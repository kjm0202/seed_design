import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

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
          seedApp(
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

  for (final primary in [true, false]) {
    testWidgets('short content still pulls (primary: $primary)', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      var refreshes = 0;
      await tester.pumpWidget(
        seedApp(
          SeedPullToRefresh(
            onRefresh: () async => refreshes++,
            child: ListView(
              controller: primary ? null : controller,
              primary: primary ? null : false,
              children: const [SizedBox(height: 80, child: Text('Only row'))],
            ),
          ),
        ),
      );
      final gesture = await startPull(tester);
      await gesture.moveBy(const Offset(0, 160));
      await tester.pump();
      expect(indicator(tester).value, 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 1);
    });
  }

  testWidgets('a short nested list leaves drags to the outer list', (
    tester,
  ) async {
    await tester.pumpWidget(
      seedApp(
        SeedPullToRefresh(
          onRefresh: () async {},
          child: ListView(
            children: [
              SizedBox(
                height: 100,
                child: ListView(
                  primary: false,
                  children: const [SizedBox(height: 40)],
                ),
              ),
              const SizedBox(height: 1600),
            ],
          ),
        ),
      ),
    );
    final outer = tester.state<ScrollableState>(find.byType(Scrollable).first);
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(outer.position.pixels, greaterThan(0));
  });

  testWidgets('short pulls and ready pulls retreated below threshold cancel', (
    tester,
  ) async {
    var refreshes = 0;
    var ready = 0;
    await tester.pumpWidget(
      seedApp(
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
        seedApp(
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
        seedApp(
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
        seedApp(
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
      seedApp(
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
      seedApp(
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
          seedApp(
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
            seedApp(
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
      seedApp(
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
  group('scroll ownership and offsets', () {
    for (final surface in const [Size(800, 800), Size(390, 844)]) {
      testWidgets(
        'PTR scrolled owner -> same-contact READY cancel -> fresh callback loading settle $surface',
        (tester) async {
          await tester.binding.setSurfaceSize(surface);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final owner = ScrollController();
          addTearDown(owner.dispose);
          final requests = <Completer<void>>[];
          var readyCount = 0;
          var callbackCount = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: SeedPullToRefresh(
                  onReady: () => readyCount++,
                  onRefresh: () {
                    callbackCount++;
                    final pending = Completer<void>();
                    requests.add(pending);
                    return pending.future;
                  },
                  child: ListView(
                    controller: owner,
                    children: const [
                      SizedBox(
                        height: 1900,
                        child: Text('SCROLLED OWNER ACTIVE'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          final x = surface.width / 2;
          // Precondition: actual consumer scroll owner has nonzero offset.
          await tester.dragFrom(Offset(x, 410), const Offset(0, -270));
          await tester.pumpAndSettle();
          expect(owner.offset, greaterThan(200));
          final startOffset = owner.offset;
          expect(callbackCount, 0);
          expect(readyCount, 0);

          // Contact born at a NONZERO offset first returns the SAME owner to 0,
          // only then becomes eligible. Cancel after READY, without PointerUp.
          final cancel = await tester.startGesture(Offset(x, 170));
          await cancel.moveBy(const Offset(0, 30));
          await tester.pump();
          await cancel.moveBy(const Offset(0, 320));
          await tester.pump();
          expect(
            owner.offset,
            0,
            reason: 'first continuous drag must finish actual scroll owner',
          );
          await cancel.moveBy(const Offset(0, 160));
          await tester.pump();
          expect(readyCount, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            1,
          );
          expect(callbackCount, 0);
          await cancel.cancel();
          await tester.pumpAndSettle();
          expect(owner.offset, 0);
          expect(
            callbackCount,
            0,
            reason: 'READY cancelled contact cannot call onRefresh',
          );
          expect(requests, isEmpty);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            0,
          );

          // A separate origin after cancellation must start from a clean state,
          // launch exactly one Future, and block an overlapping new pointer.
          final rearm = await tester.startGesture(Offset(x, 170));
          await rearm.moveBy(const Offset(0, 30));
          await tester.pump();
          await rearm.moveBy(const Offset(0, 230));
          await tester.pump();
          expect(readyCount, 2);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            1,
          );
          await rearm.up();
          await tester.pump();
          expect(callbackCount, 1);
          expect(requests.length, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );

          final overlapping = await tester.startGesture(Offset(x, 170));
          await overlapping.moveBy(const Offset(0, 260));
          await tester.pump();
          expect(
            callbackCount,
            1,
            reason: 'loading must not permit another callback',
          );
          expect(readyCount, 2, reason: 'loading must not become ready again');
          await overlapping.cancel();
          await tester.pump();
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );
          requests.single.complete();
          await tester.pumpAndSettle();
          expect(callbackCount, 1);
          expect(readyCount, 2);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            0,
          );
          expect(startOffset, greaterThan(200));
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'PTR nested inner ownership and protected origin blocked, outer allowed commits once $surface',
        (tester) async {
          await tester.binding.setSurfaceSize(surface);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final outer = ScrollController();
          final inner = ScrollController();
          addTearDown(outer.dispose);
          addTearDown(inner.dispose);
          final request = Completer<void>();
          var callbacks = 0;
          var ready = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: SeedPullToRefresh(
                  onReady: () => ready++,
                  onRefresh: () {
                    callbacks++;
                    return request.future;
                  },
                  child: ListView(
                    controller: outer,
                    children: [
                      const SizedBox(
                        key: Key('outer-allowed'),
                        height: 130,
                        child: Center(child: Text('OUTER ALLOWED CONTACT')),
                      ),
                      SizedBox(
                        key: const Key('nested-scroll-owner'),
                        height: 140,
                        child: ListView(
                          controller: inner,
                          children: const [
                            SizedBox(
                              height: 900,
                              child: Text('INNER SCROLLER LONG CONTENT'),
                            ),
                          ],
                        ),
                      ),
                      const SeedPullToRefreshPreventPull(
                        child: SizedBox(
                          key: Key('protected-pointer-origin'),
                          height: 120,
                          child: Center(child: Text('PROTECTED CONTACT')),
                        ),
                      ),
                      const SizedBox(
                        height: 1400,
                        child: Text('OUTER LONG CONTENT'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          // Two independent *actual* scroll ownership positions start nonzero.
          outer.jumpTo(110);
          inner.jumpTo(240);
          await tester.pump();
          expect(outer.offset, 110);
          expect(inner.offset, 240);
          final nested = await tester.startGesture(
            tester.getCenter(find.byKey(const Key('nested-scroll-owner'))),
          );
          await nested.moveBy(const Offset(0, 30));
          await tester.pump();
          await nested.moveBy(const Offset(0, 130));
          await tester.pump();
          expect(
            inner.offset,
            lessThan(240),
            reason: 'gesture belongs to nested inner scroll owner',
          );
          expect(
            ready,
            0,
            reason: 'depth=1 notification cannot arm depth=0 PTR',
          );
          expect(callbacks, 0);
          await nested.cancel();
          await tester.pumpAndSettle();
          expect(callbacks, 0);

          outer.jumpTo(0);
          inner.jumpTo(0);
          await tester.pump();
          expect(outer.offset, 0);
          expect(inner.offset, 0);
          // At a zero-offset INNER origin, its ScrollNotifications still have
          // depth=1; default notificationPredicate(depth==0) cannot arm the PTR.
          // This source-level distinction from React's findScroller requires a
          // separate real-browser pair before anyone calls it React parity.
          final nestedAtTop = await tester.startGesture(
            tester.getCenter(find.byKey(const Key('nested-scroll-owner'))),
          );
          await nestedAtTop.moveBy(const Offset(0, 30));
          await tester.pump();
          await nestedAtTop.moveBy(const Offset(0, 230));
          await tester.pump();
          expect(inner.offset, 0);
          expect(
            ready,
            0,
            reason: 'inner top is not a default depth=0 scroll notification',
          );
          expect(callbacks, 0);
          await nestedAtTop.cancel();
          await tester.pumpAndSettle();
          expect(callbacks, 0);
          // Touch originating inside protected subtree MUST not arm even when
          // it drags down across outside content / satisfies distance threshold.
          final blocked = await tester.startGesture(
            tester.getCenter(find.byKey(const Key('protected-pointer-origin'))),
          );
          await blocked.moveBy(const Offset(0, 30));
          await tester.pump();
          await blocked.moveBy(const Offset(0, 230));
          await tester.pump();
          expect(ready, 0);
          expect(callbacks, 0);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            0,
          );
          await blocked.cancel();
          await tester.pumpAndSettle();
          expect(callbacks, 0);

          final allowed = await tester.startGesture(
            tester.getCenter(find.byKey(const Key('outer-allowed'))),
          );
          await allowed.moveBy(const Offset(0, 30));
          await tester.pump();
          await allowed.moveBy(const Offset(0, 230));
          await tester.pump();
          expect(
            ready,
            1,
            reason: 'fresh outer origin must still arm after nested+protected gestures',
          );
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            1,
          );
          await allowed.up();
          await tester.pump();
          expect(callbacks, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );
          request.complete();
          await tester.pumpAndSettle();
          expect(callbacks, 1);
          expect(ready, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            0,
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'PTR rejected callback Future cleans loader and permits new refresh $surface',
        (tester) async {
          await tester.binding.setSurfaceSize(surface);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final fails = Completer<void>();
          final succeeds = Completer<void>();
          var ready = 0;
          var callbacks = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: SeedPullToRefresh(
                  onReady: () => ready++,
                  onRefresh: () {
                    callbacks++;
                    return callbacks == 1 ? fails.future : succeeds.future;
                  },
                  child: ListView(
                    children: const [
                      SizedBox(
                        height: 1800,
                        child: Text('REJECTED REFRESH OWNER'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          final x = surface.width / 2;
          final first = await tester.startGesture(Offset(x, 110));
          await first.moveBy(const Offset(0, 30));
          await tester.pump();
          await first.moveBy(const Offset(0, 230));
          await tester.pump();
          expect(ready, 1);
          await first.up();
          await tester.pump();
          expect(callbacks, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );
          fails.completeError(
            StateError('intentionally rejected refresh Future'),
          );
          await tester.pumpAndSettle();
          expect(callbacks, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            0,
          );

          final second = await tester.startGesture(Offset(x, 110));
          await second.moveBy(const Offset(0, 30));
          await tester.pump();
          await second.moveBy(const Offset(0, 230));
          await tester.pump();
          expect(ready, 2, reason: 'error cleanup must allow new READY state');
          await second.up();
          await tester.pump();
          expect(callbacks, 2);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );
          succeeds.complete();
          await tester.pumpAndSettle();
          expect(callbacks, 2);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            0,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('contact origin', () {
    // Official React usePullToRefresh.ts:
    // - startEvent:134-136 retains originRef until end/cancel;
    // - disableEvent:245-252 aborts the active pull but leaves originRef alive;
    // - moveEvent:138-152 may start another pull on the SAME contact once enabled.
    // This is a disabled->enabled rearm, NOT the previous negative-retreat fix.

    for (final surface in [const Size(390, 844), const Size(800, 800)]) {
      testWidgets('active disabled→enabled preserves contact origin $surface', (
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
      });
      testWidgets('disabled contact cancel clears stale origin $surface', (
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
  });

  group('threshold and re-arm', () {
    // React usePullToRefresh.ts:155-180 rebases y0 to the retreating finger on
    // displacement <= 0 instead of returning to idle or forgetting the origin.
    // These tests isolate that contract from a previous dispose/late-up repair.

    for (final size in [const Size(390, 844), const Size(800, 800)]) {
      testWidgets('88px boundary and same-contact ready retreat $size', (
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

      testWidgets(
        'continuous pointer rebases after retreat and re-arms $size',
        (tester) async {
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
                      SizedBox(
                        height: 1700,
                        child: Text('PTR continuous region'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          final gesture = await tester.startGesture(
            Offset(size.width / 2, 120),
          );
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
          expect(
            ready,
            2,
            reason: 'READY after retreat is a second transition',
          );
          await gesture.up();
          await tester.pumpAndSettle();
          expect(
            refreshes,
            1,
            reason: 'only the final READY release refreshes',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('release timing', () {
    for (final surface in const [Size(800, 800), Size(390, 844)]) {
      testWidgets('release timeline, overlapping retry blocked $surface', (
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
                child: ListView(
                  children: const [
                    SizedBox(
                      height: 1900,
                      child: Text('release timeline consumer'),
                    ),
                  ],
                ),
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
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          1,
        );
        await first.up();
        await tester.pump(); // t=0: next Flutter render frame after pointer-up
        expect(callbacks, 1, reason: 'pointer-up invokes exactly one refresh');
        expect(pending.length, 1);
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          isNull,
        );

        // Flutter test clocks are deterministic. They are not browser CDP event times.
        for (final dt in const [16, 34, 100, 150]) {
          await tester.pump(
            Duration(milliseconds: dt),
          ); // cumulative 16/50/150/300
          expect(callbacks, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );
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
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
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
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'ready retreat release cancels callback; fresh contact succeeds $surface',
        (tester) async {
          await tester.binding.setSurfaceSize(surface);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          var callbacks = 0;
          var readyCalls = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: SeedPullToRefresh(
                  onReady: () => readyCalls++,
                  onRefresh: () async {
                    callbacks++;
                  },
                  child: ListView(children: const [SizedBox(height: 1900)]),
                ),
              ),
            ),
          );
          final x = surface.width / 2;
          final gesture = await tester.startGesture(Offset(x, 110));
          await gesture.moveBy(const Offset(0, 30));
          await tester.pump();
          await gesture.moveBy(const Offset(0, 210));
          await tester.pump();
          expect(readyCalls, 1);
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            1,
          );
          await gesture.moveBy(const Offset(0, -135));
          await tester.pump();
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            lessThan(1),
          );
          await gesture.up();
          await tester.pump();
          expect(
            callbacks,
            0,
            reason: 'retreated contact does not refresh on release',
          );
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
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            0,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('ready notification', () {
    testWidgets('refresh supports ready notification and prevents pulls', (
      tester,
    ) async {
      var refreshes = 0, ready = 0;
      final completion = Completer<void>();
      await tester.pumpWidget(
        koreanApp(
          SeedPullToRefresh(
            onRefresh: () {
              refreshes++;
              return completion.future;
            },
            onReady: () => ready++,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 1000)],
            ),
          ),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, 900));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(ready, 1);
      expect(refreshes, 1);
      completion.complete();
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        koreanApp(
          SeedPullToRefresh(
            preventPull: true,
            onRefresh: () async {
              refreshes++;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 1000)],
            ),
          ),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, 900));
      await tester.pumpAndSettle();
      expect(refreshes, 1);
    });
  });
}
