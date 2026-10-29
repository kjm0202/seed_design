import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  group('tabs async after delay reference390', () {
    testWidgets('390 async tab grows outer box to 532px after loading', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/tabs-auto-height-lazy');
      await tester.pumpAndSettle();
      final tabs = find.byType(SeedTabsView);
      expect(tabs, findsOneWidget);
      final page = find.descendant(of: tabs, matching: find.byType(PageView));
      expect(tester.getSize(page).height, closeTo(132, 0.05));

      // The source actor starts Async and observes after its delayed content.
      await tester.tap(find.text('Async'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();
      expect(
        find.text('Tab 2: Async loaded (500px, 1s delay)'),
        findsOneWidget,
      );
      // Official React selected Async outer box: 500px content + 2x16 padding.
      expect(tester.getSize(page).height, closeTo(532, 0.05));
      expect(tester.takeException(), isNull);
    });
  });

  // ONE original frozen MISMATCH: p2_tabs_auto_height_lazy_800_async_after_delay.
  // The old React 132px metric came from OFFSCREEN Tab1, not the selected Async
  // panel: selected React Tab2 is 532px (500px + x4 vertical padding).
  group('tabs async after delay reference800', () {
    testWidgets('800 Async tab loads after 1000ms and expands outer box to 532', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Real app route, real SeedTabsView state/timer and PageView measurement;
      // no mock carousel, direct callback or artificially fixed 132px geometry.
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/tabs-auto-height-lazy');
      await tester.pumpAndSettle();

      final tabs = find.byType(SeedTabsView);
      expect(tabs, findsOneWidget);
      final settings = tester.widget<SeedTabsView>(tabs);
      expect(settings.defaultValue, '1');
      expect(settings.lazyMount, isTrue);
      expect(settings.dynamicHeight, isTrue);
      expect(settings.carousel, isTrue);

      final header = find.descendant(of: tabs, matching: find.byType(SeedTabs));
      final page = find.descendant(of: tabs, matching: find.byType(PageView));
      expect(header, findsOneWidget);
      expect(page, findsOneWidget);
      expect(tester.widget<SeedTabs>(header).selectedIndex, 0);
      expect(find.text('Tab 1: Immediate (100px)'), findsOneWidget);
      expect(tester.getSize(page).height, closeTo(132, .05));

      // Frozen actor: real click on 'Async', and wait for its delayed 1s data.
      await tester.tap(find.text('Async').hitTestable());
      await tester.pumpAndSettle();
      expect(tester.widget<SeedTabs>(header).selectedIndex, 1);
      const loadedLabel = 'Tab 2: Async loaded (500px, 1s delay)';
      expect(find.text(loadedLabel), findsNothing);

      // Use the actual one-second timer; animation has already settled and
      // advancing fake time triggers the async build without inventing a state.
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();
      expect(find.text(loadedLabel), findsOneWidget);
      expect(tester.widget<SeedTabs>(header).selectedIndex, 1);
      // Selected React Async outer box=532 (500px content + 2x16 padding).
      expect(tester.getSize(page).height, closeTo(532, .05));
      expect(
        ModalRoute.of(tester.element(tabs))?.settings.name,
        '/tabs-auto-height-lazy',
      );
      expect(tester.takeException(), isNull);
    });
  });
  group('tabs async loading reference390', () {
    testWidgets('390 first Async visit measures the transient Loading height', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/tabs-auto-height-lazy');
      await tester.pumpAndSettle();
      final tabs = find.byType(SeedTabsView);
      final page = find.descendant(of: tabs, matching: find.byType(PageView));
      expect(tester.getSize(page).height, closeTo(132, .05));

      await tester.tap(find.text('Async'));
      await tester.pumpAndSettle();
      // The first one-second window contains a much shorter loading indicator.
      // The upstream React example explicitly says autoHeight can stay fixed.
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Tab 2: Async loaded (500px, 1s delay)'), findsNothing);
      expect(tester.getSize(page).height, closeTo(51, 1));
      expect(tester.takeException(), isNull);
    });
  });
  group('tabs async return reference390', () {
    for (final size in [const Size(390, 844), const Size(800, 800)]) {
      testWidgets(
        '${size.width.toInt()} Async loaded tab reentry retains 532px padded content',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(const StackflowSpaApp());
          await tester.pumpAndSettle();
          tester
              .state<NavigatorState>(find.byType(Navigator))
              .pushNamed('/tabs-auto-height-lazy');
          await tester.pumpAndSettle();
          final tabs = find.byType(SeedTabsView);
          final page = find.descendant(
            of: tabs,
            matching: find.byType(PageView),
          );
          expect(tester.getSize(page).height, closeTo(132, .05));

          await tester.tap(find.text('Async'));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 1100));
          await tester.pumpAndSettle();
          expect(
            find.text('Tab 2: Async loaded (500px, 1s delay)'),
            findsOneWidget,
          );
          expect(tester.getSize(page).height, closeTo(532, .05));

          // Return-visit actor from the frozen capture, after the Async load has
          // completed: keepAlive should preserve the loaded content, not re-load it.
          await tester.tap(find.text('Immediate'));
          await tester.pumpAndSettle();
          expect(tester.getSize(page).height, closeTo(132, .05));
          await tester.tap(find.text('Async'));
          await tester.pumpAndSettle();
          expect(find.text('Loading...'), findsNothing);
          expect(
            find.text('Tab 2: Async loaded (500px, 1s delay)'),
            findsOneWidget,
          );
          expect(tester.getSize(page).height, closeTo(532, .05));
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
  group('tabs autoheight immediate2 reference390', () {
    testWidgets('390 Immediate 2 selected outer box matches React 232px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/tabs-auto-height-lazy');
      await tester.pumpAndSettle();
      final tabs = find.byType(SeedTabsView);
      expect(tabs, findsOneWidget);
      expect(tester.widget<SeedTabsView>(tabs).dynamicHeight, isTrue);
      final carousel = find.descendant(
        of: tabs,
        matching: find.byType(PageView),
      );
      expect(carousel, findsOneWidget);
      expect(tester.getSize(carousel).height, closeTo(132, 0.05));

      // Exact historical actor: select Immediate 2. React's own demo explicitly
      // calls out that its carousel height stays fixed despite content changes.
      await tester.tap(find.text('Immediate 2'));
      await tester.pumpAndSettle();
      expect(find.text('Tab 3: Immediate (200px)'), findsOneWidget);
      // Official React: CSS Box height=200px plus 16px padding on both edges.
      // Original selected onscreen React tabpanel rect is 232px, not the stale
      // offscreen Tab1's 132px recorded by the old extractor.
      expect(tester.getSize(carousel).height, closeTo(232, 0.05));
      expect(tester.takeException(), isNull);
    });
  });

  // ONE frozen original MISMATCH: p2_tabs_auto_height_lazy_800_immediate2_geometry.
  // Original React aggregate 132px came from OFFSCREEN old Tab1, but the actual
  // selected React Tab3 is 232px (200px CSS height + 32px vertical padding).
  group('tabs autoheight immediate2 reference800', () {
    testWidgets('800 Immediate 2 selects Tab 3 and grows outer box to 232', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Use the actual routed SPA and same initial tab state as the frozen CDP
      // actor; do not mock SeedTabsView or calculate content height from a label.
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/tabs-auto-height-lazy');
      await tester.pumpAndSettle();

      final tabs = find.byType(SeedTabsView);
      expect(tabs, findsOneWidget);
      final view = tester.widget<SeedTabsView>(tabs);
      expect(view.carousel, isTrue);
      expect(view.dynamicHeight, isTrue);
      expect(view.lazyMount, isTrue);
      expect(view.defaultValue, '1');

      final header = find.descendant(of: tabs, matching: find.byType(SeedTabs));
      expect(header, findsOneWidget);
      expect(tester.widget<SeedTabs>(header).selectedIndex, 0);

      final carousel = find.descendant(
        of: tabs,
        matching: find.byType(PageView),
      );
      expect(carousel, findsOneWidget);
      expect(find.text('Tab 1: Immediate (100px)'), findsOneWidget);
      expect(tester.getSize(carousel).height, closeTo(132, .05));

      // The original actor clicks the real 'Immediate 2' tab at the 800px
      // viewport and expects Tab 3 content with the declared 200px height.
      final thirdTab = find.text('Immediate 2').hitTestable();
      expect(thirdTab, findsOneWidget);
      await tester.tap(thirdTab);
      await tester.pumpAndSettle();

      expect(tester.widget<SeedTabs>(header).selectedIndex, 2);
      expect(find.text('Tab 3: Immediate (200px)'), findsOneWidget);
      // Official selected React Tab3 is 232px: CSS 200px + 2x16 padding.
      expect(tester.getSize(carousel).height, closeTo(232, .05));
      expect(
        ModalRoute.of(tester.element(tabs))?.settings.name,
        '/tabs-auto-height-lazy',
      );
      expect(tester.takeException(), isNull);
    });
  });

  // Original MISMATCH: p2_tabs_auto_height_lazy_800_suspense_after_delay.
  // Frozen React after-click selected Suspense panel (x=0) is 432px; the
  // historical 132px tabpanel observation was offscreen Tab 1 (x=-2400).
  group('tabs suspense after delay800', () {
    testWidgets('800 Suspense click resolves after 1500ms at 432px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/tabs-auto-height-lazy');
      await tester.pumpAndSettle();

      final tabs = find.byType(SeedTabsView);
      final header = find.descendant(of: tabs, matching: find.byType(SeedTabs));
      final carousel = find.descendant(
        of: tabs,
        matching: find.byType(PageView),
      );
      expect(tabs, findsOneWidget);
      expect(carousel, findsOneWidget);
      final settings = tester.widget<SeedTabsView>(tabs);
      expect(settings.defaultValue, '1');
      expect(settings.lazyMount, isTrue);
      expect(settings.dynamicHeight, isTrue);
      expect(settings.carousel, isTrue);
      expect(tester.widget<SeedTabs>(header).selectedIndex, 0);
      expect(tester.getSize(carousel).height, closeTo(132, 0.05));
      const loaded = 'Lazy loaded content (400px tall, 1500ms delay)';
      expect(find.text(loaded), findsNothing);

      // The frozen actor clicks the real Suspense tab, then waits 1850ms.
      await tester.tap(find.text('Suspense').hitTestable());
      await tester.pumpAndSettle();
      expect(tester.widget<SeedTabs>(header).selectedIndex, 3);
      expect(find.text('Suspense loading...'), findsOneWidget);
      expect(find.text(loaded), findsNothing);

      await tester.pump(const Duration(milliseconds: 1850));
      await tester.pumpAndSettle();
      expect(find.text('Suspense loading...'), findsNothing);
      expect(find.text(loaded), findsOneWidget);
      expect(tester.widget<SeedTabs>(header).selectedIndex, 3);
      expect(tester.getSize(carousel).height, closeTo(432, 0.05));
      expect(
        ModalRoute.of(tester.element(tabs))?.settings.name,
        '/tabs-auto-height-lazy',
      );
      expect(tester.takeException(), isNull);
    });
  });
  group('tabs suspense after delay reference390', () {
    testWidgets('390 Suspense lazy content measures 432px padded outer panel', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/tabs-auto-height-lazy');
      await tester.pumpAndSettle();
      final tabs = find.byType(SeedTabsView);
      final page = find.descendant(of: tabs, matching: find.byType(PageView));
      expect(tester.getSize(page).height, closeTo(132, .05));
      expect(tester.widget<SeedTabsView>(tabs).lazyMount, isTrue);

      // Playwright's role locator automatically scrolls offscreen tab triggers
      // into view; WidgetTester must reproduce that prerequisite explicitly.
      await tester.ensureVisible(find.text('Suspense'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suspense').hitTestable());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
      expect(
        find.text('Lazy loaded content (400px tall, 1500ms delay)'),
        findsOneWidget,
      );
      // Official React selected/onscreen panel outer size: content 400px +
      // Box p=x4's 16px padding on both vertical edges.
      expect(tester.getSize(page).height, closeTo(432, .05));
      expect(tester.takeException(), isNull);
    });
  });
}
