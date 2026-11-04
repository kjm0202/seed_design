// Original MISMATCH: p2_list_item_800_suffix_{first,second}_alert, /list-item at 800x800.
// The browser event is observed through the callback test seam; the actual
// native window.alert API is implemented by list_item_native_alert_web.dart.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/navigation_pages.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

/// Mount the real Activity without the unrelated SPA Home layout so viewport
/// height, intrinsic feed extent and the vertical scroll owner are observable.
Future<void> _mountSwipeableTabs(
  WidgetTester tester, {
  required Size viewport,
  required double scale,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    mui.MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: mui.GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: mui.Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: SizedBox(height: 56),
        ),
        body: Builder(
          builder: (context) => buildNavigationPage(
            'ActivitySwipeableTabs',
            context,
            navigate: (_, {arguments}) {},
            goBack: () {},
          )!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Finder> _openListButtonPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushNamed('/list-item-button');
  await tester.pumpAndSettle();
  return find.byKey(const ValueKey('none-title-buttons'));
}

Finder _suffixes(Finder row) =>
    find.descendant(of: row, matching: find.byType(SeedButton));

Future<Finder> _openSuffix(WidgetTester tester, int suffixIndex) async {
  tester.view.physicalSize = const Size(800, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/list-item');
  await tester.pumpAndSettle();

  final row = find.byKey(const ValueKey('none-title-buttons'));
  expect(row, findsOneWidget);
  final suffixes = find.descendant(of: row, matching: find.byType(SeedButton));
  expect(suffixes, findsNWidgets(2));
  final first = suffixes.first;
  final second = suffixes.last;
  expect(tester.widget<SeedButton>(first).label, '라벨');
  expect(tester.widget<SeedButton>(first).size, SeedButtonSize.xsmall);
  expect(tester.widget<SeedButton>(first).onPressed, isNotNull);

  // Each original actor independently targets its named suffix position.
  final firstCenter = tester.getCenter(first);
  final secondCenter = tester.getCenter(second);
  expect(firstCenter.dx, lessThan(secondCenter.dx));
  expect(firstCenter.dx, inInclusiveRange(600, 800));
  expect(firstCenter.dy, inInclusiveRange(175, 325));

  // Keep the actual accessible action and label, not only the visible text.
  final semantics = tester.getSemantics(first);
  expect(semantics.label, '라벨');
  expect(semantics.flagsCollection.isButton, true);
  final target = suffixes.at(suffixIndex);
  expect(tester.getSemantics(target).label, '라벨');
  expect(tester.getSemantics(target).flagsCollection.isButton, true);
  return target;
}

Future<NavigatorState> _open(
  WidgetTester tester,
  String path,
  double width,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final nav = tester.state<NavigatorState>(find.byType(Navigator));
  nav.pushNamed(path);
  await tester.pumpAndSettle();
  return nav;
}

/// Mount the actual Activity directly, avoiding the unrelated SPA Home screen's
/// negative-width layout error at textScale=2.0.
Future<void> _mountSideNav(
  WidgetTester tester, {
  required double width,
  double scale = 1,
}) async {
  // Keep the full two group rows laid out even with large typography; the
  // viewport-width assertions are unaffected by test height.
  tester.view.physicalSize = Size(width, scale == 2 ? 1600 : 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    mui.MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: mui.Scaffold(
        body: Material(
          type: MaterialType.transparency,
          child: Builder(
            builder: (context) => buildNavigationPage(
              'ActivitySideNavigation',
              context,
              navigate: (_, {arguments}) {},
              goBack: () {},
            )!,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _groups() => find.byType(SeedSelectBoxGroup);

/// Mount the real pagination Activity as a named route, rather than rendering
/// SPA Home first: the independent Home index has a known negative-width bug
/// at high text scales which would conceal the pagination layout evidence.
Future<void> _openPagination(
  WidgetTester tester, {
  required double width,
  required double scale,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    mui.MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: mui.GlobalMaterialLocalizations.delegates,
      initialRoute: '/pagination',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      routes: {
        '/pagination': (context) => mui.Scaffold(
          body: Builder(
            builder: (context) => buildNavigationPage(
              'ActivityPagination',
              context,
              navigate: (_, {arguments}) {},
              goBack: () {},
            )!,
          ),
        ),
      },
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _tables => find.byType(SeedTablePagination);

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

Future<void> openStackflowSpaVisualFix(
  WidgetTester tester,
  String route, {
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

void main() {
  group('Tabs and SwipeableTabs', () {
    group('dynamic-height lazy tabs', () {
      // /tabs-auto-height-lazy: a lazy, dynamic-height carousel whose tabs load
      // immediately, after a 1s timer (Async) or after 1.5s (Suspense).
      Future<({Finder header, Finder carousel})> openLazyTabs(
        WidgetTester tester,
        Size size,
      ) async {
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
        expect(tabs, findsOneWidget);
        final view = tester.widget<SeedTabsView>(tabs);
        expect(view.defaultValue, '1');
        expect(view.carousel, isTrue);
        expect(view.dynamicHeight, isTrue);
        expect(view.lazyMount, isTrue);
        expect(find.text('Tab 1: Immediate (100px)'), findsOneWidget);
        return (
          header: find.descendant(of: tabs, matching: find.byType(SeedTabs)),
          carousel: find.descendant(of: tabs, matching: find.byType(PageView)),
        );
      }

      double heightOf(WidgetTester tester, Finder carousel) =>
          tester.getSize(carousel).height;

      for (final size in [const Size(390, 844), const Size(800, 800)]) {
        final width = size.width.toInt();

        testWidgets(
          'Async tab grows after loading and keeps it on return $width',
          (tester) async {
            final (:header, :carousel) = await openLazyTabs(tester, size);
            expect(heightOf(tester, carousel), closeTo(132, 0.05));
            const loaded = 'Tab 2: Async loaded (500px, 1s delay)';

            await tester.tap(find.text('Async').hitTestable());
            await tester.pumpAndSettle();
            expect(tester.widget<SeedTabs>(header).selectedIndex, 1);
            expect(find.text('Loading...'), findsOneWidget);
            if (width == 390) {
              expect(heightOf(tester, carousel), closeTo(51, 1));
            }
            expect(find.text(loaded), findsNothing);

            await tester.pump(const Duration(milliseconds: 1100));
            await tester.pumpAndSettle();
            expect(find.text(loaded), findsOneWidget);
            expect(heightOf(tester, carousel), closeTo(532, 0.05));

            // Returning to the first tab shrinks back; re-entering Async keeps the
            // loaded content alive instead of loading again.
            await tester.tap(find.text('Immediate'));
            await tester.pumpAndSettle();
            expect(heightOf(tester, carousel), closeTo(132, 0.05));
            await tester.tap(find.text('Async'));
            await tester.pumpAndSettle();
            expect(find.text('Loading...'), findsNothing);
            expect(find.text(loaded), findsOneWidget);
            expect(heightOf(tester, carousel), closeTo(532, 0.05));
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets('taller immediate tab grows the carousel at $width', (
          tester,
        ) async {
          final (:header, :carousel) = await openLazyTabs(tester, size);
          expect(heightOf(tester, carousel), closeTo(132, 0.05));

          await tester.tap(find.text('Immediate 2').hitTestable());
          await tester.pumpAndSettle();
          expect(tester.widget<SeedTabs>(header).selectedIndex, 2);
          expect(find.text('Tab 3: Immediate (200px)'), findsOneWidget);
          expect(heightOf(tester, carousel), closeTo(232, 0.05));
          expect(tester.takeException(), isNull);
        });

        testWidgets(
          'Suspense tab resolves after its delay and grows at $width',
          (tester) async {
            final (:header, :carousel) = await openLazyTabs(tester, size);
            expect(heightOf(tester, carousel), closeTo(132, 0.05));
            const loaded = 'Lazy loaded content (400px tall, 1500ms delay)';

            await tester.ensureVisible(find.text('Suspense'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Suspense').hitTestable());
            await tester.pumpAndSettle();
            expect(tester.widget<SeedTabs>(header).selectedIndex, 3);
            expect(find.text('Suspense loading...'), findsOneWidget);
            expect(find.text(loaded), findsNothing);

            await tester.pump(const Duration(milliseconds: 1850));
            await tester.pumpAndSettle();
            expect(find.text('Suspense loading...'), findsNothing);
            expect(find.text(loaded), findsOneWidget);
            expect(heightOf(tester, carousel), closeTo(432, 0.05));
            expect(tester.takeException(), isNull);
          },
        );
      }
    });
    group('SwipeableTabs gestures', () {
      testWidgets(
        'horizontal inner scrolling does not switch tabs; page edge swipe does',
        (tester) async {
          await _mountSwipeableTabs(
            tester,
            viewport: const Size(390, 600),
            scale: 1,
          );
          final horizontal = find.ancestor(
            of: find.text('Scrolling Area'),
            matching: find.byType(SingleChildScrollView),
          );
          expect(horizontal, findsNWidgets(2));
          final horizontalScroll = tester.state<ScrollableState>(
            find
                .descendant(
                  of: horizontal.first,
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.drag(horizontal.first, const Offset(-150, 0));
          await tester.pumpAndSettle();
          expect(horizontalScroll.position.pixels, greaterThan(0));
          expect(find.byType(SeedPullToRefresh), findsOneWidget);

          await tester.dragFrom(const Offset(330, 280), const Offset(-300, 0));
          await tester.pumpAndSettle();
          expect(find.byType(SeedPullToRefresh), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'first tab PTR awaits a one-second refresh and then settles',
        (tester) async {
          await _mountSwipeableTabs(
            tester,
            viewport: const Size(390, 600),
            scale: 1,
          );
          final gesture = await tester.startGesture(const Offset(220, 175));
          await gesture.moveBy(const Offset(0, 45));
          await tester.pump(const Duration(milliseconds: 20));
          await gesture.moveBy(const Offset(0, 145));
          await tester.pump(const Duration(milliseconds: 20));
          await gesture.moveBy(const Offset(0, 170));
          await tester.pump(const Duration(milliseconds: 20));
          await gesture.up();
          await tester.pump();
          final indicator = find.byType(SeedProgressCircle);
          expect(indicator, findsOneWidget);
          expect(tester.widget<SeedProgressCircle>(indicator).value, isNull);
          await tester.pump(const Duration(milliseconds: 1050));
          await tester.pumpAndSettle();
          expect(tester.widget<SeedProgressCircle>(indicator).value, 0);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'disabled tab stays inert; keyboard activates Tab 2 and back',
        (tester) async {
          await _mountSwipeableTabs(
            tester,
            viewport: const Size(390, 600),
            scale: 1.5,
          );
          final tabs = find.byType(SeedTabs);
          await tester.tap(find.text('Disabled'));
          await tester.pumpAndSettle();
          expect(tester.widget<SeedTabs>(tabs).selectedIndex, 0);
          final second = tester.widget<SeedPressable>(
            find
                .ancestor(
                  of: find.text('Tab 2'),
                  matching: find.byType(SeedPressable),
                )
                .first,
          );
          second.focusNode!.requestFocus();
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(tester.widget<SeedTabs>(tabs).selectedIndex, 2);
          expect(find.byType(SeedPullToRefresh), findsNothing);
          final first = tester.widget<SeedPressable>(
            find
                .ancestor(
                  of: find.text('Tab 1'),
                  matching: find.byType(SeedPressable),
                )
                .first,
          );
          first.focusNode!.requestFocus();
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(tester.widget<SeedTabs>(tabs).selectedIndex, 0);
          expect(find.byType(SeedPullToRefresh), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    });
  });

  group('ListButtonItem suffix', () {
    testWidgets(
      'suffix buttons are accessible and inert; the row opens its dialog',
      (tester) async {
        final alerts = <String>[];
        debugListItemNativeAlert = alerts.add;
        addTearDown(() => debugListItemNativeAlert = null);
        final semantics = tester.ensureSemantics();
        final row = await _openListButtonPage(tester);
        expect(row, findsOneWidget);
        final route = ModalRoute.of(tester.element(row));
        final buttons = _suffixes(row);
        expect(buttons, findsNWidgets(2));
        expect(
          tester.getCenter(buttons.first).dx,
          lessThan(tester.getCenter(buttons.last).dx),
        );

        for (var index = 0; index < 2; index++) {
          final button = buttons.at(index);
          final widget = tester.widget<SeedButton>(button);
          expect(widget.label, '라벨');
          expect(widget.size, SeedButtonSize.xsmall);
          expect(widget.variant, SeedButtonVariant.neutralWeak);
          expect(widget.onPressed, isNotNull);
          final node = tester.getSemantics(button);
          expect(node.label, '라벨');
          expect(node.flagsCollection.isButton, isTrue);

          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(find.byType(SeedSnackbar), findsNothing);
          expect(find.byType(SeedAlertDialog), findsNothing);
          expect(alerts, isEmpty);
          expect(ModalRoute.of(tester.element(row)), same(route));
          expect(route?.isCurrent, isTrue);
        }
        semantics.dispose();

        await tester.tapAt(Offset(85, tester.getCenter(buttons.first).dy));
        await tester.pumpAndSettle();
        expect(find.byType(SeedAlertDialog), findsOneWidget);
        expect(find.text('consectetur'), findsOneWidget);
        await tester.tap(find.widgetWithText(SeedButton, '닫기').last);
        await tester.pumpAndSettle();
        expect(find.byType(SeedAlertDialog), findsNothing);
        expect(ModalRoute.of(tester.element(row)), same(route));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('suffix buttons do not replace or renew an existing snackbar', (
      tester,
    ) async {
      final alerts = <String>[];
      debugListItemNativeAlert = alerts.add;
      addTearDown(() => debugListItemNativeAlert = null);
      final row = await _openListButtonPage(tester);
      final route = ModalRoute.of(tester.element(row));
      final buttons = _suffixes(row);
      expect(buttons, findsNWidgets(2));
      var closeCount = 0;
      SeedSnackbarProvider.of(tester.element(row)).show(
        child: const SeedSnackbar(message: 'Button clicked'),
        duration: const Duration(milliseconds: 1200),
        onClose: () => closeCount++,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      for (var index = 0; index < 2; index++) {
        await tester.tap(buttons.at(index));
        await tester.pump();
        expect(closeCount, 0);
        expect(find.byType(SeedSnackbar), findsOneWidget);
        expect(find.byType(SeedAlertDialog), findsNothing);
        expect(alerts, isEmpty);
        expect(ModalRoute.of(tester.element(row)), same(route));
      }
      await tester.pump(const Duration(milliseconds: 1250));
      await tester.pumpAndSettle();
      expect(closeCount, 1);
      expect(find.byType(SeedSnackbar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('list item native alert', () {
    for (final suffixIndex in [0, 1]) {
      final position = suffixIndex == 0 ? 'first' : 'second';
      testWidgets(
        '800 $position suffix sends one native alert message without modal, snackbar or route change',
        (tester) async {
          final handle = tester.ensureSemantics();
          final messages = <String>[];
          debugListItemNativeAlert = messages.add;
          addTearDown(() {
            debugListItemNativeAlert = null;
          });

          final first = await _openSuffix(tester, suffixIndex);
          final route = ModalRoute.of(tester.element(first));
          expect(route?.isCurrent, true);

          await tester.tap(first);
          await tester.pumpAndSettle();

          expect(messages, ['Button clicked']);
          expect(find.byType(SeedAlertDialog), findsNothing);
          expect(find.byType(SeedSnackbar), findsNothing);
          expect(ModalRoute.of(tester.element(first)), same(route));
          expect(route?.isCurrent, true);
          expect(tester.takeException(), isNull);
          handle.dispose();
        },
      );

      testWidgets(
        '800 $position suffix native Flutter keeps accessible modal fallback when no browser alert exists',
        (tester) async {
          final handle = tester.ensureSemantics();
          debugListItemNativeAlert = null;
          addTearDown(() {
            debugListItemNativeAlert = null;
          });

          final first = await _openSuffix(tester, suffixIndex);
          final route = ModalRoute.of(tester.element(first));
          await tester.tap(first);
          await tester.pumpAndSettle();

          expect(find.byType(SeedAlertDialog), findsOneWidget);
          expect(find.text('Button clicked'), findsOneWidget);
          expect(find.byType(SeedSnackbar), findsNothing);

          await tester.tap(find.widgetWithText(SeedButton, '확인').last);
          await tester.pumpAndSettle();
          expect(find.byType(SeedAlertDialog), findsNothing);
          expect(ModalRoute.of(tester.element(first)), same(route));
          expect(route?.isCurrent, true);
          expect(tester.takeException(), isNull);
          handle.dispose();
        },
      );
    }
  });

  group('ImageFrame, PullToRefresh list, SideNavigation and Pagination', () {
    for (final width in [390.0, 800.0]) {
      testWidgets(
        'image list retains six configured variants after scroll return $width',
        (tester) async {
          await _open(tester, '/list-image-frame', width);
          final list = find.byType(ListView).last;
          final first = find.text('ratio=1, width=96');
          final last = find.text('ratio=3/4, width=120');
          expect(first, findsOneWidget);
          await tester.scrollUntilVisible(
            last,
            160,
            scrollable: find
                .descendant(of: list, matching: find.byType(Scrollable))
                .first,
          );
          await tester.pumpAndSettle();
          expect(last, findsOneWidget);
          final listState = tester.state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)).first,
          );
          expect(listState.position.pixels, greaterThan(0));
          listState.position.jumpTo(0);
          await tester.pumpAndSettle();
          expect(first, findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'list starts nonzero then one continuous contact returns to zero and arms PTR $width',
        (tester) async {
          await _open(tester, '/list-image-frame', width);
          final list = find.byType(ListView).last;
          final scrollable = find
              .descendant(of: list, matching: find.byType(Scrollable))
              .first;
          final position = tester.state<ScrollableState>(scrollable).position;
          expect(position.maxScrollExtent, greaterThan(0));
          position.jumpTo(math.min(80, position.maxScrollExtent));
          await tester.pumpAndSettle();
          expect(position.pixels, greaterThan(0));

          final listRect = tester.getRect(list);
          final origin = Offset(listRect.center.dx, listRect.top + 120);
          final gesture = await tester.startGesture(origin, pointer: 12);
          for (var i = 0; i < 24; i++) {
            await gesture.moveBy(const Offset(0, 15));
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(position.pixels, closeTo(0, 0.01));
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            1,
          );
          await gesture.up();
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );
          // A second contact during the original in-flight refresh must leave
          // the first Future in control. A follow-up pull after settlement can
          // still become ready from the same visible list.
          final retry = await tester.startGesture(origin, pointer: 13);
          for (var i = 0; i < 12; i++) {
            await retry.moveBy(const Offset(0, 20));
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(
            tester
                .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
                .value,
            isNull,
          );
          await retry.up();
          await tester.pump(const Duration(milliseconds: 1100));
          await tester.pumpAndSettle();
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
    testWidgets('320px narrow grid retains selectable radio semantics', (
      tester,
    ) async {
      await _mountSideNav(tester, width: 320);
      final tone = _groups().first;
      expect(tester.widget<SeedSelectBoxGroup>(tone).value, 'neutral');
      await tester.tapAt(
        tester.getCenter(
          find.byKey(const ValueKey('side-nav-grid-card-transparent')),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<SeedSelectBoxGroup>(tone).value, 'transparent');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '320 → 600 → 390 responsive selection persists without scroll',
      (tester) async {
        await _mountSideNav(tester, width: 320);
        final tone = find.byWidgetPredicate(
          (w) => w is SeedSelectBoxGroup && w.value == 'neutral',
        );
        await tester.tapAt(
          tester.getCenter(
            find.byKey(const ValueKey('side-nav-grid-card-transparent')),
          ),
        );
        await tester.pumpAndSettle();
        final transparent = find.byWidgetPredicate(
          (w) => w is SeedSelectBoxGroup && w.value == 'transparent',
        );
        expect(transparent, findsOneWidget);
        expect(tester.getSize(transparent).width, closeTo(48, .1));

        tester.view.physicalSize = const Size(600, 844);
        await tester.pumpAndSettle();
        expect(transparent, findsOneWidget);
        expect(tester.getSize(transparent).width, closeTo(328, .1));

        tester.view.physicalSize = const Size(390, 844);
        await tester.pumpAndSettle();
        expect(transparent, findsOneWidget);
        expect(tester.getSize(transparent).width, closeTo(118, .1));
        expect(
          find.byKey(const ValueKey('side-nav-grid-card-neutral')),
          findsOneWidget,
        );
        await tester.tapAt(
          tester.getCenter(
            find.byKey(const ValueKey('side-nav-grid-card-neutral')),
          ),
        );
        await tester.pumpAndSettle();
        expect(tone, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '320px textScale2 tiny density track remains a selectable radio',
      (tester) async {
        await _mountSideNav(tester, width: 320, scale: 2);
        final density = find.byWidgetPredicate(
          (w) => w is SeedSelectBoxGroup && w.value == 'medium',
        );
        if (density.evaluate().isEmpty) {
          final scrollable = find
              .ancestor(
                of: find.text('Side Navigation Tone'),
                matching: find.byType(Scrollable),
              )
              .first;
          await tester.scrollUntilVisible(
            density,
            400,
            scrollable: scrollable,
            maxScrolls: 16,
          );
          await tester.pumpAndSettle();
        }
        expect(density, findsOneWidget);
        final high = find.byKey(const ValueKey('side-nav-grid-card-high'));
        expect(high, findsOneWidget);
        expect(tester.getSize(high).width, closeTo(8, .1));
        await tester.tapAt(tester.getCenter(high));
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate(
            (w) => w is SeedSelectBoxGroup && w.value == 'high',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('390px controlled range Select and page-size update status', (
      tester,
    ) async {
      await _openPagination(tester, width: 390, scale: 1.5);
      final known = _tables.first;
      final selects = find.descendant(
        of: known,
        matching: find.byType(SeedSelect<int>),
      );
      expect(selects, findsNWidgets(2));
      await tester.ensureVisible(selects.last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: selects.last,
          matching: find.byType(SeedInputButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('76-100').last);
      await tester.pumpAndSettle();
      expect(find.text('4페이지 · 페이지당 25개'), findsOneWidget);

      await tester.ensureVisible(selects.first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: selects.first,
          matching: find.byType(SeedInputButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('50개').last);
      await tester.pumpAndSettle();
      expect(find.text('1페이지 · 페이지당 50개'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SwipeableTabs refresh', () {
    testWidgets('Swipeable tabs only refresh the first feed', (tester) async {
      await open(tester, '/swipeable-tabs');
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedPullToRefresh), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('tabs, SideNavigation and list keyboard', () {
    testWidgets(
      'Sticky tab list pins below AppBar while its introduction scrolls away',
      (tester) async {
        await openStackflowSpaVisualFix(tester, '/tabs');
        expect(find.text('Sticky Tablist'), findsOneWidget);
        await tester.drag(
          find.byType(CustomScrollView).last,
          const Offset(0, -350),
        );
        await tester.pumpAndSettle();
        expect(find.text('Sticky Tablist').hitTestable(), findsNothing);
        expect(tester.getTopLeft(find.byType(SeedTabs)).dy, 56);
        await tester.tap(find.text('Tab 2'));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(find.text('Tab 2 content'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'SideNavigation collapses and expands without layout overflow',
      (tester) async {
        await openStackflowSpaVisualFix(tester, '/side-navigation');
        expect(tester.getTopLeft(find.byType(SeedSideNavigation)).dy, 0);
        await tester.tap(find.byTooltip('사이드바 닫기'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 56);
        await tester.tap(find.byTooltip('사이드바 열기'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 240);
      },
    );

    for (final width in [390.0, 800.0]) {
      testWidgets('ListRadio ArrowDown chooses next enabled item at $width', (
        tester,
      ) async {
        await openStackflowSpaVisualFix(
          tester,
          '/list-item-radio',
          width: width,
        );
        const second = 'prefix-title-unchecked-suffix-icon-info';
        const third = 'prefix-title-unchecked-suffix-icon-chevron';
        final secondRow = find.text(second);
        await tester.ensureVisible(secondRow);
        await tester.pumpAndSettle();
        await tester.tap(secondRow);
        await tester.pumpAndSettle();
        Semantics radio(String label) => tester.widget<Semantics>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                (widget.properties.label == label ||
                    widget.properties.label?.startsWith('$label\n') == true),
          ),
        );
        expect(radio(second).properties.checked, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(radio(second).properties.checked, isFalse);
        expect(radio(third).properties.checked, isTrue);
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'ListRadio $third',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(radio(second).properties.checked, isTrue);
        expect(radio(third).properties.checked, isFalse);
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'ListRadio $second',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(radio(third).properties.checked, isTrue);
        // Three consecutive disabled radio rows must be skipped as one group.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        const following = 'prefix-title-detail-unchecked-suffix-none';
        await tester.scrollUntilVisible(
          find.text(following),
          80,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        expect(radio(following).properties.checked, isTrue);
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'ListRadio $following',
        );
        expect(tester.takeException(), isNull);
      });
    }

    for (final width in [390.0, 800.0]) {
      for (final (route, isSwitch) in [
        ('/list-item-check', false),
        ('/list-item-switch', true),
      ]) {
        testWidgets('$route activates with Space, not Enter at $width', (
          tester,
        ) async {
          await openStackflowSpaVisualFix(tester, route, width: width);
          const label = 'prefix-title-unchecked-suffix-none';
          final rowFinder = find.byKey(const ValueKey(label));
          bool value() {
            final row = tester.widget<SeedListItem>(rowFinder);
            return (isSwitch ? row.toggled : row.checked) ?? false;
          }

          expect(value(), isFalse);
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          expect(value(), isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(
            value(),
            isTrue,
            reason: 'React native checkbox/switch ignores Enter',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pumpAndSettle();
          expect(
            value(),
            isFalse,
            reason: 'React native checkbox/switch toggles on Space',
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
