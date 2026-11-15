import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

final _longTabs = <SeedTabItem>[
  for (var i = 0; i < 14; i++) SeedTabItem(label: 'Long tab title ${i + 1}'),
];

Widget _lineTabsHost({
  required double width,
  required bool fill,
  required TextDirection direction,
  required ValueNotifier<int> selected,
}) {
  return MaterialApp(
    theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: ValueListenableBuilder<int>(
              valueListenable: selected,
              builder: (context, index, _) => SeedTabs(
                items: _longTabs,
                selectedIndex: index,
                fill: fill,
                onTabSelected: (next) => selected.value = next,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _assertSelectedVisible(WidgetTester tester, int index, double width) {
  final viewport = find
      .descendant(of: find.byType(SeedTabs), matching: find.byType(Scrollable))
      .first;
  final position = tester.state<ScrollableState>(viewport).position;
  expect(
    position.maxScrollExtent,
    greaterThan(0),
    reason: 'Strict test requires an actually overflowing list',
  );
  final bounds = tester.getRect(viewport);
  expect(bounds.width, closeTo(width, 0.1));
  final label = tester.getRect(find.text('Long tab title ${index + 1}'));
  expect(
    label.left,
    greaterThanOrEqualTo(bounds.left - 0.5),
    reason: 'The selected line tab must be within its scroll viewport',
  );
  expect(
    label.right,
    lessThanOrEqualTo(bounds.right + 0.5),
    reason: 'Selecting an offscreen line tab must auto-reveal it',
  );
}

Widget tabsHost({
  required List<int> changes,
  bool controlled = false,
  SeedTabsController? controller,
}) {
  var selected = 0;
  return MaterialApp(
    theme: SeedThemeData.light().toThemeData(),
    home: Scaffold(
      body: StatefulBuilder(
        builder: (context, setState) => SeedChipTabsView(
          carousel: true,
          height: 120,
          duration: const Duration(seconds: 1),
          selectedIndex: controlled ? selected : null,
          controller: controller,
          onTabSelected: (index) {
            changes.add(index);
            if (controlled) setState(() => selected = index);
          },
          items: const [
            SeedTabItem(label: 'A'),
            SeedTabItem(label: 'B'),
            SeedTabItem(label: 'C'),
            SeedTabItem(label: 'D'),
          ],
          children: const [
            Text('Page A'),
            Text('Page B'),
            Text('Page C'),
            Text('Page D'),
          ],
        ),
      ),
    ),
  );
}

void expectPage(WidgetTester tester, int index) {
  expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, index);
  final page = tester.widget<PageView>(find.byType(PageView));
  expect(page.controller!.page, closeTo(index, .001));
}

final List<SeedTabItem> _items = [
  for (var index = 0; index < 14; index++)
    SeedTabItem(label: 'Chip Item ${index + 1}'),
];

Widget _host({
  required double width,
  required ValueNotifier<int> selected,
  required TextDirection direction,
  required bool scrollFog,
  EdgeInsetsGeometry? padding,
}) {
  return MaterialApp(
    theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: ValueListenableBuilder<int>(
              valueListenable: selected,
              builder: (context, value, _) => SeedTabs(
                variant: SeedTabsVariant.chipSolid,
                items: _items,
                selectedIndex: value,
                onTabSelected: (index) => selected.value = index,
                showScrollFog: scrollFog,
                chipListPadding: padding,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _assertFullyVisible(WidgetTester tester, int index, double width) {
  final label = tester.getRect(find.text('Chip Item ${index + 1}'));
  final viewport = tester.getRect(
    find
        .descendant(
          of: find.byType(SeedTabs),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  expect(viewport.width, closeTo(width, 0.1));
  expect(
    label.left,
    greaterThanOrEqualTo(viewport.left + 15.5),
    reason: 'React adds 16px of scroll padding when revealing a selected chip',
  );
  expect(
    label.right,
    lessThanOrEqualTo(viewport.right - 15.5),
    reason:
        'Selected offscreen chip must be revealed, not merely state-updated',
  );
}

Widget _sizedHost(
  Widget child, {
  double width = 800,
  Brightness brightness = Brightness.light,
}) {
  final theme = brightness == Brightness.dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  return MaterialApp(
    locale: const Locale('ko'),
    supportedLocales: const [Locale('en'), Locale('ko')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: theme.toThemeData(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

class _MountCounter {
  final List<int> created = [0, 0, 0];
  final List<int> disposed = [0, 0, 0];
}

class _CountingPanel extends StatefulWidget {
  const _CountingPanel(this.index, this.counter);
  final int index;
  final _MountCounter counter;

  @override
  State<_CountingPanel> createState() => _CountingPanelState();
}

class _CountingPanelState extends State<_CountingPanel> {
  @override
  void initState() {
    super.initState();
    widget.counter.created[widget.index]++;
  }

  @override
  void dispose() {
    widget.counter.disposed[widget.index]++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 80, child: Text('panel ${widget.index}'));
}

Widget _tabs(
  _MountCounter counter,
  SeedTabsController controller, {
  required bool lazyMount,
  bool unmountOnExit = false,
}) => _sizedHost(
  SizedBox(
    height: 300,
    width: 360,
    child: SeedTabsView(
      carousel: true,
      height: 200,
      controller: controller,
      duration: const Duration(milliseconds: 180),
      lazyMount: lazyMount,
      unmountOnExit: unmountOnExit,
      items: const [
        SeedTabItem(label: 'A', value: 'a'),
        SeedTabItem(label: 'B', value: 'b'),
        SeedTabItem(label: 'C', value: 'c'),
      ],
      children: [for (var i = 0; i < 3; i++) _CountingPanel(i, counter)],
    ),
  ),
);

class CounterPanel extends StatefulWidget {
  const CounterPanel({super.key});
  @override
  State<CounterPanel> createState() => _CounterPanelState();
}

class _CounterPanelState extends State<CounterPanel> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => count++),
      child: Text('count=$count'),
    ),
  );
}

void main() {
  setUpAll(loadSeedTestFonts);

  for (final width in [390.0, 800.0]) {
    for (final direction in TextDirection.values) {
      for (final fill in [true, false]) {
        testWidgets(
          'selected line tab is revealed: width=$width direction=$direction fill=$fill',
          (tester) async {
            final selected = ValueNotifier<int>(13);
            addTearDown(selected.dispose);
            await tester.pumpWidget(
              _lineTabsHost(
                width: width,
                fill: fill,
                direction: direction,
                selected: selected,
              ),
            );
            await tester.pumpAndSettle();
            _assertSelectedVisible(tester, 13, width);

            selected.value = 0;
            await tester.pumpAndSettle();
            _assertSelectedVisible(tester, 0, width);

            selected.value = 13;
            await tester.pumpAndSettle();
            _assertSelectedVisible(tester, 13, width);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final width in [390.0, 800.0]) {
    for (final swipeable in [true, false]) {
      testWidgets(
        'TabsCarousel mouse drag: width=$width swipeable=$swipeable',
        (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: width,
                    child: SeedTabsView(
                      items: const [
                        SeedTabItem(label: 'First'),
                        SeedTabItem(label: 'Second'),
                      ],
                      carousel: true,
                      height: 180,
                      swipeable: swipeable,
                      onTabSelected: selected.add,
                      children: const [
                        ColoredBox(color: Colors.red),
                        ColoredBox(color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex,
            0,
          );
          await tester.dragFrom(
            tester.getCenter(find.byType(PageView)),
            Offset(-width * 0.85, 0),
            kind: PointerDeviceKind.mouse,
          );
          await tester.pumpAndSettle();
          expect(
            tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex,
            swipeable ? 1 : 0,
            reason:
                'React Embla watchDrag accepts MouseEvent only if swipeable',
          );
          expect(selected, swipeable ? [1] : isEmpty);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'Mouse drag is still prevented inside nested horizontal content: $width',
      (tester) async {
        final selected = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: SeedTabsView(
                    items: const [
                      SeedTabItem(label: 'First'),
                      SeedTabItem(label: 'Second'),
                    ],
                    carousel: true,
                    height: 180,
                    swipeable: true,
                    onTabSelected: selected.add,
                    children: const [
                      SeedCarouselPreventDrag(
                        child: SizedBox.expand(
                          child: ColoredBox(color: Colors.red),
                        ),
                      ),
                      ColoredBox(color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragFrom(
          tester.getCenter(find.byType(SeedCarouselPreventDrag)),
          Offset(-width * 0.85, 0),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 0);
        expect(selected, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('Touch drag remains enabled for carousel: $width', (
      tester,
    ) async {
      final selected = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: SeedTabsView(
                  items: const [
                    SeedTabItem(label: 'First'),
                    SeedTabItem(label: 'Second'),
                  ],
                  carousel: true,
                  height: 180,
                  swipeable: true,
                  onTabSelected: selected.add,
                  children: const [
                    ColoredBox(color: Colors.red),
                    ColoredBox(color: Colors.blue),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.dragFrom(
        tester.getCenter(find.byType(PageView)),
        Offset(-width * 0.85, 0),
        kind: PointerDeviceKind.touch,
      );
      await tester.pumpAndSettle();
      expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 1);
      expect(selected, [1]);
      expect(tester.takeException(), isNull);
    });
  }
  group('carousel transitions', () {
    for (final direction in TextDirection.values) {
      testWidgets(
        'fill tabs keep enlarged labels inside their targets ($direction)',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Directionality(
                textDirection: direction,
                child: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                  child: Scaffold(
                    body: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 320,
                        child: SeedTabs(
                          fill: true,
                          selectedIndex: 0,
                          onTabSelected: (_) {},
                          items: const [
                            SeedTabItem(label: 'A'),
                            SeedTabItem(label: 'Neighborhood'),
                            SeedTabItem(label: 'Chat'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final label in ['A', 'Neighborhood', 'Chat']) {
            final text = find.text(label);
            final target = find.ancestor(
              of: text,
              matching: find.byType(SeedPressable),
            );
            final targetRect = tester.getRect(target);
            final textRect = tester.getRect(text);
            expect(textRect.left, greaterThanOrEqualTo(targetRect.left + 9.9));
            expect(textRect.right, lessThanOrEqualTo(targetRect.right - 9.9));
            expect(textRect.top, greaterThanOrEqualTo(targetRect.top + 9.9));
            expect(textRect.bottom, lessThanOrEqualTo(targetRect.bottom - 9.9));
          }
          final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
          expect(scroll.position.maxScrollExtent, greaterThan(0));
          await tester.ensureVisible(find.text('Chat'));
          await tester.pumpAndSettle();
          expect(find.text('Chat').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final initialHeight in <double?>[null, 80]) {
      testWidgets(
        'dynamic carousel settles its initial height without animating ($initialHeight)',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topCenter,
                  child: SeedTabsView(
                    carousel: true,
                    dynamicHeight: true,
                    height: initialHeight,
                    items: const [
                      SeedTabItem(label: 'A'),
                      SeedTabItem(label: 'B'),
                    ],
                    children: const [
                      SizedBox(height: 80),
                      SizedBox(height: 160),
                    ],
                  ),
                ),
              ),
            ),
          );
          final viewport = find.byType(PageView);
          if (initialHeight != null) {
            expect(tester.getSize(viewport).height, 80);
          }
          // The first post-frame measurement must apply immediately, rather than
          // starting a 300 -> 80 transition.
          await tester.pump();
          expect(tester.getSize(viewport).height, 80);
          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 16));
            expect(tester.getSize(viewport).height, 80);
          }
          await tester.pumpAndSettle();
          await tester.tap(find.text('B'));
          await tester.pump();
          final transitionHeights = <double>[];
          for (var i = 0; i < 12; i++) {
            await tester.pump(const Duration(milliseconds: 16));
            transitionHeights.add(tester.getSize(viewport).height);
          }
          expect(
            transitionHeights.any((height) => height > 80 && height < 160),
            isTrue,
          );
          await tester.pumpAndSettle();
          expect(tester.getSize(viewport).height, 160);
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final controlled in [false, true]) {
      testWidgets(
        'distant tab taps retain their target (controlled=$controlled)',
        (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            tabsHost(changes: changes, controlled: controlled),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('D'));
          await tester.pumpAndSettle();
          expectPage(tester, 3);
          await tester.tap(find.text('A'));
          await tester.pumpAndSettle();
          expectPage(tester, 0);
          expect(changes, [3, 0]);
          await tester.drag(find.byType(PageView), const Offset(-600, 0));
          await tester.pumpAndSettle();
          expectPage(tester, 1);
          expect(changes, [3, 0, 1]);
        },
      );
    }

    testWidgets('controller jumps do not emit intermediate selections', (
      tester,
    ) async {
      final changes = <int>[];
      final controller = SeedTabsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        tabsHost(changes: changes, controller: controller),
      );
      await tester.pumpAndSettle();
      controller.animateTo(3);
      await tester.pumpAndSettle();
      expectPage(tester, 3);
      expect(controller.index, 3);
      controller.animateTo(0);
      await tester.pumpAndSettle();
      expectPage(tester, 0);
      expect(controller.index, 0);
      expect(changes, isEmpty);
    });

    testWidgets('a new tab tap replaces an in-flight target', (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(tabsHost(changes: changes, controlled: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('D'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expectPage(tester, 0);
      expect(changes, [3, 0]);
      await tester.tap(find.text('D'));
      await tester.pumpAndSettle();
      expectPage(tester, 3);
      expect(changes, [3, 0, 3]);
    });

    testWidgets('a swipe can interrupt a tab transition', (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(tabsHost(changes: changes, controlled: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('D'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.drag(find.byType(PageView), const Offset(600, 0));
      await tester.pumpAndSettle();
      final page = tester
          .widget<PageView>(find.byType(PageView))
          .controller!
          .page!
          .round();
      expect(page, lessThan(3));
      expectPage(tester, page);
      expect(changes.last, page);
    });

    testWidgets('an immediate drag reconciles a canceled transition', (
      tester,
    ) async {
      final changes = <int>[];
      await tester.pumpWidget(tabsHost(changes: changes, controlled: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('D'));
      await tester.pump();
      await tester.drag(find.byType(PageView), const Offset(600, 0));
      await tester.pumpAndSettle();
      expectPage(tester, 0);
      expect(changes, [3, 0]);
    });

    testWidgets(
      'controlled rejected swipes restore the page without duplicates',
      (tester) async {
        final changes = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: SeedTabsView(
                carousel: true,
                height: 120,
                selectedIndex: 0,
                onTabSelected: changes.add,
                items: const [
                  SeedTabItem(label: 'A'),
                  SeedTabItem(label: 'B'),
                ],
                children: const [Text('Page A'), Text('Page B')],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(PageView), const Offset(-600, 0));
        await tester.pumpAndSettle();
        expectPage(tester, 0);
        expect(changes, [1]);
      },
    );
  });

  group('ChipTabs selected reveal', () {
    setUpAll(loadSeedTestFonts);

    for (final width in [390.0, 800.0]) {
      for (final padding in <EdgeInsetsGeometry?>[
        null,
        const EdgeInsets.symmetric(horizontal: 20),
      ]) {
        testWidgets(
          'ChipTabs selected reveal width=$width padding=${padding == null ? "default16" : "20"} with scroll fog',
          (tester) async {
            final selected = ValueNotifier<int>(0);
            addTearDown(selected.dispose);
            await tester.pumpWidget(
              _host(
                width: width,
                selected: selected,
                direction: TextDirection.ltr,
                scrollFog: true,
                padding: padding,
              ),
            );
            await tester.pumpAndSettle();
            _assertFullyVisible(tester, 0, width);

            selected.value = 13;
            await tester.pumpAndSettle();
            expect(
              tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex,
              13,
            );
            _assertFullyVisible(tester, 13, width);

            selected.value = 0;
            await tester.pumpAndSettle();
            _assertFullyVisible(tester, 0, width);
          },
        );
      }

      testWidgets(
        'ChipTabs leaves 16px beside a visible chip near the edge width=$width',
        (tester) async {
          final selected = ValueNotifier<int>(0);
          addTearDown(selected.dispose);
          await tester.pumpWidget(
            _host(
              width: width,
              selected: selected,
              direction: TextDirection.ltr,
              scrollFog: false,
            ),
          );
          await tester.pumpAndSettle();
          final scrollable = find
              .descendant(
                of: find.byType(SeedTabs),
                matching: find.byType(Scrollable),
              )
              .first;
          final position = tester.state<ScrollableState>(scrollable).position;
          Rect chip(int index) => tester.getRect(
            find
                .ancestor(
                  of: find.text('Chip Item ${index + 1}'),
                  matching: find.byType(SeedPressable),
                )
                .first,
          );
          final viewport = tester.getRect(scrollable);
          // Place chip 7 fully inside the viewport, 4px from its right edge.
          position.jumpTo(
            position.pixels + chip(6).right - (viewport.right - 4),
          );
          await tester.pump();
          expect(chip(6).right, closeTo(viewport.right - 4, 0.5));
          final gapBefore = chip(7).left - chip(6).right;

          selected.value = 6;
          await tester.pumpAndSettle();
          expect(chip(6).right, closeTo(viewport.right - 16, 0.5));
          expect(chip(7).left - chip(6).right, gapBefore);
        },
      );

      testWidgets('ChipTabs RTL directional padding and reveal width=$width', (
        tester,
      ) async {
        final selected = ValueNotifier<int>(0);
        addTearDown(selected.dispose);
        await tester.pumpWidget(
          _host(
            width: width,
            selected: selected,
            direction: TextDirection.rtl,
            scrollFog: false,
            padding: const EdgeInsetsDirectional.only(start: 20, end: 12),
          ),
        );
        await tester.pumpAndSettle();
        _assertFullyVisible(tester, 0, width);

        selected.value = 13;
        await tester.pumpAndSettle();
        _assertFullyVisible(tester, 13, width);

        selected.value = 0;
        await tester.pumpAndSettle();
        _assertFullyVisible(tester, 0, width);
      });
    }
  });

  group('carousel mounting and ChipTabs padding', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('carousel mounts all initial non-lazy panels', (tester) async {
      final counter = _MountCounter();
      final controller = SeedTabsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_tabs(counter, controller, lazyMount: false));
      await tester.pumpAndSettle();
      expect(counter.created, [1, 1, 1]);
      controller.animateTo(2);
      await tester.pumpAndSettle();
      expect(counter.created, [1, 1, 1]);
    });

    testWidgets(
      'carousel lazy panels mount only after selection, even during drag',
      (tester) async {
        final counter = _MountCounter();
        final controller = SeedTabsController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(_tabs(counter, controller, lazyMount: true));
        await tester.pumpAndSettle();
        expect(counter.created, [1, 0, 0]);
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(PageView)),
        );
        await gesture.moveBy(const Offset(-100, 0));
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 0);
        expect(counter.created, [1, 0, 0]);
        await gesture.up();
        await tester.pumpAndSettle();
        controller.animateTo(2);
        await tester.pumpAndSettle();
        expect(counter.created[2], 1);
      },
    );

    testWidgets('unmountOnExit discards visited carousel panel state', (
      tester,
    ) async {
      final counter = _MountCounter();
      final controller = SeedTabsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _tabs(counter, controller, lazyMount: true, unmountOnExit: true),
      );
      await tester.pumpAndSettle();
      controller.animateTo(1);
      await tester.pumpAndSettle();
      expect(counter.disposed[0], 1);
      controller.animateTo(0);
      await tester.pumpAndSettle();
      expect(counter.created[0], 2);
      expect(counter.disposed[1], 1);
    });

    for (final width in [800.0, 390.0]) {
      testWidgets(
        'dynamic-height carousel reflects delayed content at $width',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 900);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final height = ValueNotifier<double>(80);
          addTearDown(height.dispose);
          await tester.pumpWidget(
            _sizedHost(
              SeedTabsView(
                carousel: true,
                dynamicHeight: true,
                lazyMount: true,
                items: const [SeedTabItem(label: 'Async', value: 'async')],
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: height,
                    builder: (context, value, _) =>
                        SizedBox(height: value, child: const Text('Async')),
                  ),
                ],
              ),
              width: width,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.getSize(find.byType(PageView)).height, 80);
          height.value = 400;
          await tester.pumpAndSettle();
          expect(tester.getSize(find.byType(PageView)).height, 400);
        },
      );
    }

    for (final useChipSubclass in [false, true]) {
      testWidgets(
        'ChipTabs chipListPadding preserves default and forwards 20px, SeedChipTabsView=$useChipSubclass',
        (tester) async {
          Widget buildTabs(EdgeInsetsGeometry? padding) {
            const items = [
              SeedTabItem(label: 'Immediate', value: '1'),
              SeedTabItem(label: 'Async', value: '2'),
            ];
            final children = <Widget>[
              const SizedBox(height: 80, child: Text('One')),
              const SizedBox(height: 120, child: Text('Two')),
            ];
            if (useChipSubclass) {
              return SeedChipTabsView(
                items: items,
                chipListPadding: padding,
                children: children,
              );
            }
            return SeedTabsView(
              items: items,
              variant: SeedTabsVariant.chipSolid,
              chipListPadding: padding,
              showScrollFog: true,
              children: children,
            );
          }

          EdgeInsetsGeometry? actualHeaderPadding() => tester
              .widget<SingleChildScrollView>(
                find
                    .descendant(
                      of: find.byType(SeedTabs),
                      matching: find.byType(SingleChildScrollView),
                    )
                    .first,
              )
              .padding;

          await tester.pumpWidget(_sizedHost(buildTabs(null)));
          await tester.pumpAndSettle();
          expect(
            actualHeaderPadding(),
            const EdgeInsets.symmetric(horizontal: 16),
            reason: 'Null continues to use SeedTabs chip default',
          );

          await tester.pumpWidget(
            _sizedHost(buildTabs(const EdgeInsets.symmetric(horizontal: 20))),
          );
          await tester.pumpAndSettle();
          expect(
            tester.widget<SeedTabs>(find.byType(SeedTabs)).chipListPadding,
            const EdgeInsets.symmetric(horizontal: 20),
          );
          expect(
            actualHeaderPadding(),
            const EdgeInsets.symmetric(horizontal: 20),
            reason: 'React ChipTabsList explicitly pads both sides by 20px',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('chip tab size', () {
    testWidgets('large chip tabs honor their explicit size', (tester) async {
      for (final (size, height) in [
        (SeedTabsSize.medium, 36.0),
        (SeedTabsSize.large, 40.0),
      ]) {
        await tester.pumpWidget(
          koreanAppCentered(
            SeedTabs(
              items: const [
                SeedTabItem(label: 'A'),
                SeedTabItem(label: 'B'),
              ],
              selectedIndex: 0,
              onTabSelected: (_) {},
              variant: SeedTabsVariant.chipSolid,
              size: size,
            ),
          ),
        );
        final surface = find.ancestor(
          of: find.text('A'),
          matching: find.byType(AnimatedContainer),
        );
        expect(tester.getSize(surface).height, height);
      }
    });
  });

  group('keyboard', () {
    testWidgets(
      'tabs arrows wrap, skip disabled items and leave one Tab stop',
      (tester) async {
        var selected = 0;
        await tester.pumpWidget(
          koreanAppCentered(
            StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SeedTabs(
                    selectedIndex: selected,
                    onTabSelected: (index) => setState(() => selected = index),
                    items: const [
                      SeedTabItem(label: 'First'),
                      SeedTabItem(label: 'Disabled', enabled: false),
                      SeedTabItem(label: 'Last'),
                    ],
                  ),
                  TextButton(onPressed: () {}, child: const Text('After')),
                ],
              ),
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(selected, 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(selected, 0);
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expect(selected, 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();
        expect(selected, 0);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        final selectedBefore = selected;
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(selected, selectedBefore);
        expect(
          FocusManager.instance.primaryFocus!.context!
              .findAncestorWidgetOfExactType<TextButton>(),
          isNotNull,
        );
      },
    );
  });

  group('carousel swipe', () {
    testWidgets('tabs carousel changes selected header and swipe lifecycle', (
      tester,
    ) async {
      final changes = <int>[];
      var starts = 0, ends = 0;
      await tester.pumpWidget(
        koreanApp(
          SizedBox(
            height: 250,
            child: SeedTabsView(
              carousel: true,
              onTabSelected: changes.add,
              onSwipeStart: () => starts++,
              onSwipeEnd: () => ends++,
              items: const [
                SeedTabItem(label: 'Tab A'),
                SeedTabItem(label: 'Tab B'),
              ],
              children: const [Text('Page A'), Text('Page B')],
            ),
          ),
        ),
      );
      await tester.drag(find.byType(PageView), const Offset(-650, 0));
      await tester.pumpAndSettle();
      expect(changes.last, 1);
      expect(starts, 1);
      expect(ends, 1);
      expect(find.text('Page B'), findsOneWidget);
    });
  });

  group('sticky header', () {
    testWidgets(
      'sticky tab header stays at viewport top after content scroll',
      (tester) async {
        await tester.pumpWidget(
          koreanApp(
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 200)),
                const SeedStickyTabsHeader(child: Text('Sticky tabs')),
                const SliverToBoxAdapter(child: SizedBox(height: 1000)),
              ],
            ),
          ),
        );
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(find.text('Sticky tabs')).dy, closeTo(0, 1));
      },
    );
  });

  group('keepAlive', () {
    testWidgets('carousel tabs preserve state with default keepAlive', (
      tester,
    ) async {
      final controller = SeedTabsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        seedApp(
          SeedTabsView(
            controller: controller,
            carousel: true,
            height: 250,
            items: const [
              SeedTabItem(label: 'Tab A'),
              SeedTabItem(label: 'Tab B'),
              SeedTabItem(label: 'Tab C'),
            ],
            children: const [CounterPanel(), Text('second'), Text('third')],
          ),
        ),
      );
      await tester.tap(find.text('count=0'));
      await tester.pump();
      expect(find.text('count=1'), findsOneWidget);
      controller.animateTo(2);
      await tester.pumpAndSettle();
      controller.animateTo(0);
      await tester.pumpAndSettle();
      expect(find.text('count=1'), findsOneWidget);
    });

    for (final unmount in [false, true]) {
      testWidgets('carousel keepAlive honors unmountOnExit=$unmount', (
        tester,
      ) async {
        final controller = SeedTabsController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          seedApp(
            SeedTabsView(
              controller: controller,
              carousel: true,
              height: 200,
              lazyMount: true,
              unmountOnExit: unmount,
              items: const [
                SeedTabItem(label: 'A'),
                SeedTabItem(label: 'B'),
                SeedTabItem(label: 'C'),
              ],
              children: const [CounterPanel(), Text('B page'), Text('C page')],
            ),
          ),
        );
        await tester.tap(find.text('count=0'));
        await tester.pump();
        controller.animateTo(2);
        await tester.pumpAndSettle();
        controller.animateTo(0);
        await tester.pumpAndSettle();
        expect(find.text('count=${unmount ? 0 : 1}'), findsOneWidget);
      });
    }
  });

  group('ChipTabs strip padding', () {
    testWidgets(
      'ChipTabs respects explicit strip padding and keeps 16px default',
      (tester) async {
        Widget tabs({
          EdgeInsetsGeometry? padding,
          SeedTabsVariant variant = SeedTabsVariant.chipSolid,
          bool showScrollFog = false,
        }) => SeedTabs(
          items: const [
            SeedTabItem(label: 'One'),
            SeedTabItem(label: 'Two'),
          ],
          selectedIndex: 0,
          onTabSelected: (_) {},
          variant: variant,
          showScrollFog: showScrollFog,
          chipListPadding: padding,
        );
        await tester.pumpWidget(koreanAppCompact(tabs()));
        expect(
          tester
              .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
              .padding,
          const EdgeInsets.symmetric(horizontal: 16),
        );
        await tester.pumpWidget(
          koreanAppCompact(
            tabs(padding: const EdgeInsets.symmetric(horizontal: 20)),
          ),
        );
        expect(
          tester
              .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
              .padding,
          const EdgeInsets.symmetric(horizontal: 20),
        );
        await tester.pumpWidget(
          koreanAppCompact(
            tabs(
              variant: SeedTabsVariant.chipOutline,
              showScrollFog: true,
              padding: const EdgeInsetsDirectional.only(start: 24, end: 12),
            ),
          ),
        );
        expect(
          tester
              .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
              .padding,
          const EdgeInsetsDirectional.only(start: 24, end: 12),
        );
      },
    );
  });
  testWidgets('a rejected keyboard selection still reveals the focused tab', (
    tester,
  ) async {
    final proposals = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              child: SeedTabs(
                items: _longTabs,
                selectedIndex: 0,
                onTabSelected: proposals.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
    expect(proposals, [1, 2, 3, 4]);
    final viewport = tester.getRect(
      find
          .descendant(
            of: find.byType(SeedTabs),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    final focused = tester.getRect(find.text('Long tab title 5'));
    expect(focused.left, greaterThanOrEqualTo(viewport.left - 0.5));
    expect(focused.right, lessThanOrEqualTo(viewport.right + 0.5));
  });

  group('tab identity across reorder and deletion', () {
    testWidgets(
      'uncontrolled tab follows value and visited panels on reorder',
      (tester) async {
        final order = ValueNotifier<List<String>>(['a', 'b', 'c']);
        final items = [
          for (final value in order.value)
            SeedTabItem(label: value.toUpperCase(), value: value),
        ];
        await tester.pumpWidget(
          seedAppTopLeft(
            ValueListenableBuilder<List<String>>(
              valueListenable: order,
              builder: (_, values, _) => SeedTabsView(
                lazyMount: true,
                items: items,
                children: [for (final value in values) Text('page $value')],
              ),
            ),
          ),
        );
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        items.insert(0, items.removeLast());
        order.value = ['c', 'a', 'b'];
        await tester.pumpAndSettle();
        expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 2);
        expect(find.text('page b'), findsOneWidget);
        expect(find.text('page c', skipOffstage: false), findsNothing);
        items.removeLast();
        order.value = ['c', 'a'];
        await tester.pumpAndSettle();
        expect(find.text('page a'), findsOneWidget);
      },
    );

    testWidgets(
      'carousel retains selected identity and handles deletion with lazy panels',
      (tester) async {
        final order = ValueNotifier<List<String>>(['a', 'b', 'c']);
        final changes = <String>[];
        await tester.pumpWidget(
          seedAppTopLeft(
            ValueListenableBuilder<List<String>>(
              valueListenable: order,
              builder: (_, values, _) => SeedTabsView(
                carousel: true,
                dynamicHeight: true,
                lazyMount: true,
                onValueChange: changes.add,
                items: [
                  for (final value in values)
                    SeedTabItem(label: value.toUpperCase(), value: value),
                ],
                children: [
                  for (final value in values)
                    SizedBox(
                      height: value == 'b' ? 100 : 50,
                      child: Text('page $value'),
                    ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        order.value = ['c', 'a', 'b'];
        await tester.pumpAndSettle();
        expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 2);
        expect(find.text('page b'), findsOneWidget);
        expect(changes, ['b']);
        order.value = ['c', 'a'];
        await tester.pumpAndSettle();
        expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 1);
        expect(find.text('page a'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(changes, ['b']);
      },
    );
  });
}
