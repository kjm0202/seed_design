// Post927b: PUBLIC Flutter consumer contract ONLY, no browser parity claim.
// Do not substitute a WidgetTester GREEN for React strict/browser SPA evidence.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
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
        await tester.pumpWidget(MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(body: SeedPullToRefresh(
            onReady: () => readyCount++,
            onRefresh: () {
              callbackCount++;
              final pending = Completer<void>();
              requests.add(pending);
              return pending.future;
            },
            child: ListView(controller: owner, children: const [
              SizedBox(height: 1900, child: Text('SCROLLED OWNER ACTIVE')),
            ]),
          )),
        ));
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
        expect(owner.offset, 0, reason: 'first continuous drag must finish actual scroll owner');
        await cancel.moveBy(const Offset(0, 160));
        await tester.pump();
        expect(readyCount, 1);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 1);
        expect(callbackCount, 0);
        await cancel.cancel();
        await tester.pumpAndSettle();
        expect(owner.offset, 0);
        expect(callbackCount, 0, reason: 'READY cancelled contact cannot call onRefresh');
        expect(requests, isEmpty);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);

        // A separate origin after cancellation must start from a clean state,
        // launch exactly one Future, and block an overlapping new pointer.
        final rearm = await tester.startGesture(Offset(x, 170));
        await rearm.moveBy(const Offset(0, 30));
        await tester.pump();
        await rearm.moveBy(const Offset(0, 230));
        await tester.pump();
        expect(readyCount, 2);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 1);
        await rearm.up();
        await tester.pump();
        expect(callbackCount, 1);
        expect(requests.length, 1);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, isNull);

        final overlapping = await tester.startGesture(Offset(x, 170));
        await overlapping.moveBy(const Offset(0, 260));
        await tester.pump();
        expect(callbackCount, 1, reason: 'loading must not permit another callback');
        expect(readyCount, 2, reason: 'loading must not become ready again');
        await overlapping.cancel();
        await tester.pump();
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, isNull);
        requests.single.complete();
        await tester.pumpAndSettle();
        expect(callbackCount, 1);
        expect(readyCount, 2);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);
        expect(startOffset, greaterThan(200));
        expect(tester.takeException(), isNull);
        debugPrint('POST927B GREEN owner/cancel $surface: initialOffset=$startOffset, '
            'cancelCallback=0, rearmedReady=$readyCount, completedCallback=$callbackCount, '
            'loadingSuppressedOverlap=true, finalIndicator=0');
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
        await tester.pumpWidget(MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(body: SeedPullToRefresh(
            onReady: () => ready++,
            onRefresh: () { callbacks++; return request.future; },
            child: ListView(controller: outer, children: [
              const SizedBox(
                key: Key('outer-allowed'),
                height: 130,
                child: Center(child: Text('OUTER ALLOWED CONTACT')),
              ),
              SizedBox(
                key: const Key('nested-scroll-owner'),
                height: 140,
                child: ListView(controller: inner, children: const [
                  SizedBox(height: 900, child: Text('INNER SCROLLER LONG CONTENT')),
                ]),
              ),
              const SeedPullToRefreshPreventPull(child: SizedBox(
                key: Key('protected-pointer-origin'),
                height: 120,
                child: Center(child: Text('PROTECTED CONTACT')),
              )),
              const SizedBox(height: 1400, child: Text('OUTER LONG CONTENT')),
            ]),
          )),
        ));

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
        expect(inner.offset, lessThan(240), reason: 'gesture belongs to nested inner scroll owner');
        final innerAfterOwnDrag = inner.offset;
        expect(ready, 0, reason: 'depth=1 notification cannot arm depth=0 PTR');
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
        expect(ready, 0, reason: 'inner top is not a default depth=0 scroll notification');
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
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);
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
        expect(ready, 1, reason: 'fresh outer origin must still arm after nested+protected gestures');
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 1);
        await allowed.up();
        await tester.pump();
        expect(callbacks, 1);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, isNull);
        request.complete();
        await tester.pumpAndSettle();
        expect(callbacks, 1);
        expect(ready, 1);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);
        expect(tester.takeException(), isNull);
        debugPrint('POST927B GREEN nested/protect $surface: outerInitial=110, '
            'innerInitial=240, innerAfterDrag=$innerAfterOwnDrag, '
            'innerAtTopReady=0, protectedReady=0, outerFreshReady=$ready, '
            'completedCallback=$callbacks, finalIndicator=0');
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
        await tester.pumpWidget(MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(body: SeedPullToRefresh(
            onReady: () => ready++,
            onRefresh: () {
              callbacks++;
              return callbacks == 1 ? fails.future : succeeds.future;
            },
            child: ListView(children: const [
              SizedBox(height: 1800, child: Text('REJECTED REFRESH OWNER')),
            ]),
          )),
        ));

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
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, isNull);
        fails.completeError(StateError('intentionally rejected refresh Future'));
        await tester.pumpAndSettle();
        expect(callbacks, 1);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);

        final second = await tester.startGesture(Offset(x, 110));
        await second.moveBy(const Offset(0, 30));
        await tester.pump();
        await second.moveBy(const Offset(0, 230));
        await tester.pump();
        expect(ready, 2, reason: 'error cleanup must allow new READY state');
        await second.up();
        await tester.pump();
        expect(callbacks, 2);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, isNull);
        succeeds.complete();
        await tester.pumpAndSettle();
        expect(callbacks, 2);
        expect(tester.widget<SeedProgressCircle>(find.byType(SeedProgressCircle)).value, 0);
        expect(tester.takeException(), isNull);
        debugPrint('POST927B GREEN rejection $surface: rejectedFutureReset=true, '
            'freshReady=$ready, totalCallback=$callbacks, finalIndicator=0');
      },
    );
  }
}
