import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerScrollEvent;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_catalog.dart';
import 'package:seed_design_example/stackflow_spa/spa_routes.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

// Official ActivityHome.tsx:569-623 renders a real sticky HStack inside each
// scrollable grid section. It occupies the hit-test area above the card, while
// dragging from the heading still scrolls its parent AppScreenContent.
Future<ScrollController> _homeAt(
  WidgetTester tester, {
  required double width,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, 844),
        textScaler: TextScaler.linear(scale),
      ),
      child: const StackflowSpaApp(),
    ),
  );
  await tester.pumpAndSettle();
  final scroll = tester
      .widget<CustomScrollView>(find.byType(CustomScrollView))
      .controller!;
  scroll.jumpTo(140);
  await tester.pumpAndSettle();
  return scroll;
}

List<Rect> _gridCells(WidgetTester tester) {
  final grid = tester.widget<Wrap>(find.byType(Wrap).first);
  return [
    for (final card in grid.children) tester.getRect(find.byWidget(card)),
  ];
}

Future<NavigatorState> open(WidgetTester tester, String route) async {
  tester.view.physicalSize = const Size(440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pumpAndSettle();
  return navigator;
}

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
      // React ActivityHome's sticky HStack is a real hit-test surface. The
      // default ensureVisible may align an item immediately behind it, and
      // taps must not fall through the pinned heading (see the sticky section
      // title group below). Aim
      // the intended visible list row inside the scroll viewport before
      // tapping, as a user would scroll it below the sticky heading.
      await Scrollable.ensureVisible(
        tester.element(entry),
        alignment: 0.30,
        duration: Duration.zero,
      );
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
  for (final width in [320.0, 390.0, 768.0, 800.0, 1280.0, 1440.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets(
        'Home pinned header does not activate the card behind at $width scale $scale',
        (tester) async {
          addTearDown(tester.view.reset);
          final scroll = await _homeAt(tester, width: width, scale: scale);
          final heading = find.byKey(
            const ValueKey('spa-pinned-section-title-0'),
          );
          expect(heading, findsOneWidget);
          final center = tester.getCenter(heading);
          final oldOffset = scroll.offset;
          await tester.tapAt(center);
          await tester.pumpAndSettle();
          // The sticky title is a real element in React and covers the list's
          // clickable rows. Tap must remain on Home and must not select a row.
          expect(find.byType(CustomScrollView), findsOneWidget);
          expect(scroll.offset, closeTo(oldOffset, 1));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final width in [390.0, 800.0, 1440.0]) {
    testWidgets('Home scroll gesture begins from sticky title at $width', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      final scroll = await _homeAt(tester, width: width);
      final oldOffset = scroll.offset;
      final heading = find.byKey(const ValueKey('spa-pinned-section-title-0'));
      await tester.dragFrom(tester.getCenter(heading), const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(oldOffset + 50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Home wheel over sticky title scrolls content at $width', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      final scroll = await _homeAt(tester, width: width);
      final oldOffset = scroll.offset;
      final heading = find.byKey(const ValueKey('spa-pinned-section-title-0'));
      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: tester.getCenter(heading),
          scrollDelta: const Offset(0, 120),
        ),
      );
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(oldOffset + 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Home list rows remain tappable below sticky title at $width', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      await _homeAt(tester, width: width);
      // A transparent full-screen hit blocker could prevent navigation on the
      // underlying list. Only the actual sticky header footprint is inert.
      final item = find.text('전환: fadeIn');
      expect(item, findsOneWidget);
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(find.byType(CustomScrollView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Home sticky row yields to the next grid row and updates chip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();

    final scroll = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!;
    // Align the first title in the second two-column row above stickyTop.
    final dialogTitleY = tester.getTopLeft(find.text('Dialog').last).dy;
    scroll.jumpTo(dialogTitleY - 116 + 30);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('spa-pinned-section-title-0')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('spa-pinned-section-title-1')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('spa-pinned-section-title-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('spa-pinned-section-title-3')),
      findsOneWidget,
    );
    expect(
      tester.widget<SeedChip>(find.widgetWithText(SeedChip, 'Dialog')).checked,
      isTrue,
    );
    expect(
      tester
          .widget<SeedChip>(find.widgetWithText(SeedChip, 'Menu & Popover'))
          .checked,
      isFalse,
    );
  });
  testWidgets('Home reflows 1→4→2→1 columns and releases row minima', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    for (final (width, columns, scale) in <(double, int, double)>[
      (390, 1, 1),
      (1440, 4, 2),
      (800, 2, 1.5),
      (768, 2, 2),
      (390, 1, 1),
    ]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 844),
            textScaler: TextScaler.linear(scale),
          ),
          child: const StackflowSpaApp(),
        ),
      );
      await tester.pumpAndSettle();
      final cells = _gridCells(tester).toList();
      expect(cells.length, greaterThan(columns));
      final firstRow = cells.take(columns).toList();
      expect(
        firstRow.map((r) => r.top).toSet().length,
        1,
        reason: '$columns sections share the first row at $width',
      );
      expect(
        cells[columns].top,
        greaterThan(firstRow.first.top),
        reason: 'section ${columns + 1} wraps to the next row at $width',
      );
      expect(
        firstRow.map((r) => r.height).reduce(math.max) -
            firstRow.map((r) => r.height).reduce(math.min),
        lessThan(1),
      );
      expect(tester.takeException(), isNull);
    }
  });
  group('chips and section links', () {
    for (final width in [440.0, 1000.0]) {
      testWidgets('Home chips jump to sections at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final scroll = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
        final targetChip = find.widgetWithText(
          SeedChip,
          width < 600 ? 'Drawer' : 'Pull to Refresh',
        );
        await tester.tap(targetChip);
        await tester.pumpAndSettle();
        expect(scroll.controller!.offset, greaterThan(0));
        expect(tester.widget<SeedChip>(targetChip).checked, isTrue);
        expect(
          find
              .text(
                width < 600 ? 'Bottom Sheet' : 'ActivityPullToRefreshPreview',
              )
              .hitTestable(),
          findsOneWidget,
        );

        await tester.tap(find.widgetWithText(SeedChip, 'AppScreen'));
        await tester.pumpAndSettle();
        expect(scroll.controller!.offset, 0);
        expect(find.text('App Bar 슬롯과 긴 제목').hitTestable(), findsOneWidget);
      });
    }

    testWidgets('Home keeps the active section heading visible on phones', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(440, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('spa-pinned-section-title')),
        findsNothing,
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('spa-pinned-section-title')),
        findsOneWidget,
      );
    });

    testWidgets('Stackflow home groups link to their own activity routes', (
      tester,
    ) async {
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('AppScreen'), findsWidgets);

      await tester.tap(find.text('App Bar 슬롯과 긴 제목'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Random Long Title Hello World Commodo occaecat laboris voluptate aute magna.',
        ),
        findsOneWidget,
      );
      expect(find.byType(SeedTopNavigation), findsWidgets);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('bell, grid columns and chips', () {
    testWidgets('Home bell does not generate a Flutter-only Snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pump();
      expect(find.text('새로운 알림이 없습니다.'), findsNothing);
    });

    for (final (width, columns) in [
      (600.0, 1),
      (767.0, 1),
      (768.0, 2),
      (960.0, 2),
      (1279.0, 2),
      (1280.0, 3),
      (1439.0, 3),
      (1440.0, 4),
    ]) {
      testWidgets('Home React grid columns at $width = $columns', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final grid = tester
            .widgetList<Wrap>(find.byType(Wrap))
            .firstWhere((wrap) => wrap.children.length == spaSections.length);
        final firstCard = tester.getSize(find.byWidget(grid.children.first));
        expect(
          firstCard.width,
          closeTo((width - 32 - (columns - 1) * 20) / columns, 0.1),
        );
      });
    }

    testWidgets('mobile active Home chip stays in the horizontal viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -7000));
      await tester.pumpAndSettle();
      final selected = tester
          .widgetList<SeedChip>(find.byType(SeedChip))
          .singleWhere((chip) => chip.checked == true);
      final location = tester.getCenter(find.byWidget(selected));
      expect(location.dx, inInclusiveRange(0, 390));
      expect(
        find.byKey(const ValueKey('spa-pinned-section-title')),
        findsOneWidget,
      );
    });
  });

  group('root replacement and snackbar', () {
    testWidgets('home remains reachable after replacing its root activity', (
      tester,
    ) async {
      final navigator = await open(tester, '/action-button');
      navigator.pop();
      await tester.pumpAndSettle();
      navigator.pushReplacementNamed('/action-button');
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'home immediate snackbar replaces queued message and exposes Dance',
      (tester) async {
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        for (
          var i = 0;
          i < 30 && find.text('queued').hitTestable().evaluate().isEmpty;
          i++
        ) {
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -450),
          );
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('queued'));
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('Queued Snackbar'), findsOneWidget);
        await tester.tap(find.text('기본').last);
        await tester.pumpAndSettle();
        expect(find.text('Disco Party!'), findsOneWidget);
        expect(find.text('Queued Snackbar'), findsNothing);
        await tester.tap(find.text('Dance'));
        await tester.pumpAndSettle();
        expect(find.text('Disco Party!'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      },
    );
  });
}
