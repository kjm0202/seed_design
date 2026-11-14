import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

const _left = 44.0;
const _right = 30.0;
const _width = 800.0;

final _longTabs = <SeedTabItem>[
  for (var i = 0; i < 14; i++) SeedTabItem(label: 'Long tab title ${i + 1}'),
];
const _shortTabs = <SeedTabItem>[
  SeedTabItem(label: 'A'),
  SeedTabItem(label: 'B'),
];

/// Simulates a landscape notch: the view reports asymmetric horizontal
/// insets and the page content sits in a [SafeArea], which consumes them
/// from [MediaQuery] as a real app would.
void _landscapeNotch(WidgetTester tester) {
  tester.view.physicalSize = const Size(_width, 400);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(left: _left, right: _right);
  tester.view.viewPadding = const FakeViewPadding(left: _left, right: _right);
  addTearDown(tester.view.reset);
}

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: SizedBox(width: double.infinity, child: child),
              ),
            ),
          ),
        ),
      ),
    );

Rect _scrollRect(WidgetTester tester, Finder of) => tester.getRect(
  find.descendant(of: of, matching: find.byType(Scrollable)).first,
);

void main() {
  setUpAll(loadSeedTestFonts);

  group('SeedTabs', () {
    testWidgets('updates the bleed when consumed view insets change', (
      tester,
    ) async {
      _landscapeNotch(tester);
      await tester.pumpWidget(
        _app(
          SeedTabs(
            items: _shortTabs,
            selectedIndex: 0,
            variant: SeedTabsVariant.chipSolid,
            extendSafeAreaX: true,
            onTabSelected: (_) {},
          ),
        ),
      );
      tester.view.padding = const FakeViewPadding(left: 20, right: 10);
      tester.view.viewPadding = const FakeViewPadding(left: 20, right: 10);
      await tester.pumpAndSettle();
      final tabs = find.byType(SeedTabs);
      expect(_scrollRect(tester, tabs).left, 0);
      expect(_scrollRect(tester, tabs).right, _width);
      final first = tester.getRect(
        find.ancestor(of: find.text('A'), matching: find.byType(SeedPressable)),
      );
      expect(first.left, closeTo(20 + 16, 0.01));
      tester.view.padding = const FakeViewPadding(left: 60, right: 50);
      tester.view.viewPadding = const FakeViewPadding(left: 60, right: 50);
      await tester.pumpAndSettle();
      expect(_scrollRect(tester, tabs).left, 0);
      expect(_scrollRect(tester, tabs).right, _width);
      expect(tester.getRect(find.text('A')).left, greaterThan(60));
    });

    for (final direction in TextDirection.values) {
      testWidgets('line hug extends under the insets ($direction)', (
        tester,
      ) async {
        _landscapeNotch(tester);
        final selected = ValueNotifier(0);
        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<int>(
              valueListenable: selected,
              builder: (context, index, _) => SeedTabs(
                items: _longTabs,
                selectedIndex: index,
                fill: false,
                extendSafeAreaX: true,
                onTabSelected: (next) => selected.value = next,
              ),
            ),
            direction: direction,
          ),
        );
        await tester.pumpAndSettle();
        final tabs = find.byType(SeedTabs);
        // The widget keeps its safe-area box; its scroll area spans the view.
        expect(tester.getRect(tabs).left, _left);
        expect(tester.getRect(tabs).right, _width - _right);
        expect(_scrollRect(tester, tabs).left, 0);
        expect(_scrollRect(tester, tabs).right, _width);

        final first = tester.getRect(find.text('Long tab title 1'));
        final firstTab = tester.getRect(
          find.ancestor(
            of: find.text('Long tab title 1'),
            matching: find.byType(SeedPressable),
          ),
        );
        if (direction == TextDirection.ltr) {
          expect(firstTab.left, closeTo(_left + 16, 0.01));
        } else {
          expect(firstTab.right, closeTo(_width - _right - 16, 0.01));
        }
        expect(first.width, greaterThan(0));

        // Revealing the last tab keeps the 16px margin plus the inset.
        selected.value = 13;
        await tester.pumpAndSettle();
        final last = tester.getRect(
          find.ancestor(
            of: find.text('Long tab title 14'),
            matching: find.byType(SeedPressable),
          ),
        );
        if (direction == TextDirection.ltr) {
          expect(last.right, closeTo(_width - _right - 16, 0.5));
        } else {
          expect(last.left, closeTo(_left + 16, 0.5));
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('line fill shares the width inside the insets', (tester) async {
      _landscapeNotch(tester);
      await tester.pumpWidget(
        _app(
          SeedTabs(
            items: _shortTabs,
            selectedIndex: 0,
            extendSafeAreaX: true,
            onTabSelected: (_) {},
          ),
        ),
      );
      final a = tester.getRect(
        find.ancestor(of: find.text('A'), matching: find.byType(SeedPressable)),
      );
      final b = tester.getRect(
        find.ancestor(of: find.text('B'), matching: find.byType(SeedPressable)),
      );
      expect(a.left, closeTo(_left, 0.01));
      expect(b.right, closeTo(_width - _right, 0.01));
      expect(a.width, closeTo((_width - _left - _right) / 2, 0.01));
      expect(_scrollRect(tester, find.byType(SeedTabs)).width, _width);
    });

    testWidgets('chip list padding grows by the insets', (tester) async {
      _landscapeNotch(tester);
      await tester.pumpWidget(
        _app(
          SeedTabs(
            items: _shortTabs,
            selectedIndex: 0,
            variant: SeedTabsVariant.chipSolid,
            extendSafeAreaX: true,
            onTabSelected: (_) {},
          ),
        ),
      );
      final a = tester.getRect(
        find.ancestor(of: find.text('A'), matching: find.byType(SeedPressable)),
      );
      expect(a.left, closeTo(_left + 16, 0.01));
      expect(_scrollRect(tester, find.byType(SeedTabs)).left, 0);
    });

    testWidgets('MediaQuery padding alone also supplies the insets', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 600),
              padding: EdgeInsets.only(left: _left, right: _right),
            ),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.only(left: _left, right: _right),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: SeedTabs(
                      items: _shortTabs,
                      selectedIndex: 0,
                      variant: SeedTabsVariant.chipSolid,
                      extendSafeAreaX: true,
                      onTabSelected: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final a = tester.getRect(
        find.ancestor(of: find.text('A'), matching: find.byType(SeedPressable)),
      );
      expect(a.left, closeTo(_left + 16, 0.01));
    });

    testWidgets('default false is unchanged by the insets', (tester) async {
      Future<List<Rect>> layout({required bool notch}) async {
        if (notch) _landscapeNotch(tester);
        await tester.pumpWidget(
          _app(
            SeedTabs(
              items: _longTabs,
              selectedIndex: 0,
              fill: false,
              onTabSelected: (_) {},
            ),
          ),
        );
        final tabs = find.byType(SeedTabs);
        return [
          tester.getRect(tabs),
          _scrollRect(tester, tabs),
          tester.getRect(
            find.ancestor(
              of: find.text('Long tab title 1'),
              matching: find.byType(SeedPressable),
            ),
          ),
        ];
      }

      tester.view.physicalSize = const Size(_width - _left - _right, 400);
      tester.view.devicePixelRatio = 1;
      final plain = await layout(notch: false);
      final notched = await layout(notch: true);
      for (var i = 0; i < plain.length; i++) {
        expect(notched[i].shift(const Offset(-_left, 0)), plain[i]);
      }
    });
  });

  group('SeedTabBar / SeedTabsView / SeedChipTabsView', () {
    testWidgets('SeedTabBar forwards the flag', (tester) async {
      _landscapeNotch(tester);
      await tester.pumpWidget(
        _app(
          DefaultTabController(
            length: 2,
            child: SeedTabBar(items: _shortTabs, extendSafeAreaX: true),
          ),
        ),
      );
      expect(
        tester.widget<SeedTabs>(find.byType(SeedTabs)).extendSafeAreaX,
        isTrue,
      );
      expect(_scrollRect(tester, find.byType(SeedTabs)).width, _width);
    });

    for (final carousel in [false, true]) {
      testWidgets('SeedTabsView pads content by the insets '
          '(carousel: $carousel)', (tester) async {
        _landscapeNotch(tester);
        await tester.pumpWidget(
          _app(
            SeedTabsView(
              items: _shortTabs,
              carousel: carousel,
              height: carousel ? 100 : null,
              extendSafeAreaX: true,
              children: const [
                SizedBox(
                  key: ValueKey('page0'),
                  width: double.infinity,
                  height: 50,
                ),
                SizedBox(
                  key: ValueKey('page1'),
                  width: double.infinity,
                  height: 50,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final page = tester.getRect(find.byKey(const ValueKey('page0')));
        expect(page.left, closeTo(_left, 0.01));
        expect(page.right, closeTo(_width - _right, 0.01));
        if (carousel) {
          expect(tester.getRect(find.byType(PageView)).width, _width);
        }
        expect(tester.getRect(find.byType(SeedTabsView)).left, _left);
      });
    }

    testWidgets('SeedChipTabsView forwards the flag', (tester) async {
      _landscapeNotch(tester);
      await tester.pumpWidget(
        _app(
          const SeedChipTabsView(
            items: _shortTabs,
            extendSafeAreaX: true,
            children: [
              SizedBox(
                key: ValueKey('page0'),
                width: double.infinity,
                height: 50,
              ),
              SizedBox(width: double.infinity, height: 50),
            ],
          ),
        ),
      );
      final a = tester.getRect(
        find.ancestor(of: find.text('A'), matching: find.byType(SeedPressable)),
      );
      // The chip header hugs its chips inside the view's column; the first
      // chip is 16px plus the inset from the start of its scroll area.
      final strip = _scrollRect(tester, find.byType(SeedTabs));
      expect(a.left - strip.left, closeTo(16 + _left, 0.01));
      expect(
        tester.getRect(find.byKey(const ValueKey('page0'))).left,
        closeTo(_left, 0.01),
      );
    });
  });

  group('SeedPageBanner', () {
    testWidgets('updates the background after consumed insets change', (
      tester,
    ) async {
      _landscapeNotch(tester);
      await tester.pumpWidget(
        _app(
          const SeedPageBanner(description: 'Banner', extendSafeAreaX: true),
        ),
      );
      tester.view.padding = const FakeViewPadding(left: 20, right: 10);
      tester.view.viewPadding = const FakeViewPadding(left: 20, right: 10);
      await tester.pumpAndSettle();
      final backgrounds = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(SeedPageBanner),
              matching: find.byType(DecoratedBox),
            ),
          )
          .where(
            (box) =>
                box.decoration is BoxDecoration &&
                (box.decoration as BoxDecoration).color != null,
          );
      expect(
        backgrounds.map((box) => tester.getRect(find.byWidget(box))),
        contains(
          predicate<Rect>((rect) => rect.left == 0 && rect.right == _width),
        ),
      );
    });

    for (final tone in [SeedPageBannerTone.neutral, SeedPageBannerTone.magic]) {
      testWidgets('only the background bleeds ($tone)', (tester) async {
        _landscapeNotch(tester);
        Future<(Rect, Rect)> layout(bool extend) async {
          await tester.pumpWidget(
            _app(
              SeedPageBanner(
                key: ValueKey(extend),
                description: 'Banner',
                tone: tone,
                onTap: () {},
                extendSafeAreaX: extend,
              ),
            ),
          );
          return (
            tester.getRect(find.byType(SeedPageBanner)),
            tester.getRect(find.text('Banner')),
          );
        }

        final plain = await layout(false);
        final extended = await layout(true);
        // Box and content are where they are without the flag.
        expect(extended, plain);
        expect(plain.$1.left, _left);

        final backgrounds = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(SeedPageBanner),
                matching: find.byType(DecoratedBox),
              ),
            )
            .where((box) {
              final d = box.decoration;
              return d is BoxDecoration &&
                  (d.color != null || d.gradient != null);
            });
        final rects = [
          for (final box in backgrounds) tester.getRect(find.byWidget(box)),
        ];
        expect(
          rects.where((r) => r.left == 0 && r.right == _width),
          hasLength(1),
        );
      });
    }
  });

  // React's flag is a CSS variant: toggling it at runtime (the official
  // ActivitySafeAreaBleed example uses a Switch) remounts nothing, so the
  // selected page, scroll offsets, focus and child state all survive.
  group('flipping extendSafeAreaX at runtime keeps state', () {
    for (final initial in [false, true]) {
      final flip = '${initial ? 'true' : 'false'} <-> ${!initial}';

      testWidgets('SeedTabsView carousel keeps the selected page ($flip)', (
        tester,
      ) async {
        _landscapeNotch(tester);
        final extend = ValueNotifier(initial);
        addTearDown(extend.dispose);
        await tester.pumpWidget(
          _flipping(
            extend,
            (value) => SeedTabsView(
              items: _threeTabs,
              carousel: true,
              height: 120,
              extendSafeAreaX: value,
              children: [for (var i = 0; i < 3; i++) _Counter('page$i')],
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(find.byType(PageView), const Offset(-500, 0));
        await tester.pumpAndSettle();
        expect(_selectedTab(tester), 1);
        expect(_visiblePage(tester, 3), 1);
        await tester.tap(find.text('page1: 0'));
        await tester.pump();
        expect(find.text('page1: 1'), findsOneWidget);

        extend.value = !initial;
        await tester.pumpAndSettle();
        expect(_selectedTab(tester), 1);
        expect(_visiblePage(tester, 3), 1);
        expect(find.text('page1: 1'), findsOneWidget);

        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        expect(_selectedTab(tester), 2);
        expect(_visiblePage(tester, 3), 2);

        extend.value = initial;
        await tester.pumpAndSettle();
        expect(_selectedTab(tester), 2);
        expect(_visiblePage(tester, 3), 2);
        expect(find.text('page1: 1', skipOffstage: false), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('SeedTabsView keepAlive pages keep their state ($flip)', (
        tester,
      ) async {
        _landscapeNotch(tester);
        final extend = ValueNotifier(initial);
        addTearDown(extend.dispose);
        await tester.pumpWidget(
          _flipping(
            extend,
            (value) => SeedTabsView(
              items: _threeTabs,
              extendSafeAreaX: value,
              children: [for (var i = 0; i < 3; i++) _Counter('page$i')],
            ),
          ),
        );
        await tester.tap(find.text('page0: 0'));
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('page1: 0'));
        await tester.pump();

        extend.value = !initial;
        await tester.pumpAndSettle();
        expect(_selectedTab(tester), 1);
        expect(find.text('page1: 1'), findsOneWidget);
        expect(find.text('page0: 1', skipOffstage: false), findsOneWidget);

        extend.value = initial;
        await tester.pumpAndSettle();
        expect(find.text('page1: 1'), findsOneWidget);
        expect(find.text('page0: 1', skipOffstage: false), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('SeedTabs hug keeps a scrolled selection visible ($flip)', (
        tester,
      ) async {
        _landscapeNotch(tester);
        final extend = ValueNotifier(initial);
        final selected = ValueNotifier(0);
        addTearDown(extend.dispose);
        addTearDown(selected.dispose);
        await tester.pumpWidget(
          _app(
            ListenableBuilder(
              listenable: Listenable.merge([extend, selected]),
              builder: (context, _) => SeedTabs(
                items: _longTabs,
                selectedIndex: selected.value,
                fill: false,
                extendSafeAreaX: extend.value,
                onTabSelected: (next) => selected.value = next,
              ),
            ),
          ),
        );
        selected.value = 12;
        await tester.pumpAndSettle();
        final tabs = find.byType(SeedTabs);
        final scroll = _scrollState(tester, tabs);
        expect(scroll.position.pixels, greaterThan(0));
        _expectInsideSafeArea(tester, find.text('Long tab title 13'));

        for (final value in [!initial, initial]) {
          extend.value = value;
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(_scrollState(tester, tabs), same(scroll));
          expect(scroll.position.pixels, greaterThan(0));
          _expectInsideSafeArea(tester, find.text('Long tab title 13'));
        }
      });

      testWidgets('SeedChipTabsView keeps a scrolled selection visible '
          '($flip)', (tester) async {
        _landscapeNotch(tester);
        final extend = ValueNotifier(initial);
        final controller = SeedTabsController();
        addTearDown(extend.dispose);
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          _flipping(
            extend,
            (value) => SeedChipTabsView(
              items: _longTabs,
              controller: controller,
              extendSafeAreaX: value,
              children: [for (var i = 0; i < 14; i++) _Counter('page$i')],
            ),
          ),
        );
        controller.animateTo(12);
        await tester.pumpAndSettle();
        await tester.tap(find.text('page12: 0'));
        await tester.pump();
        final tabs = find.byType(SeedTabs);
        final scroll = _scrollState(tester, tabs);
        expect(scroll.position.pixels, greaterThan(0));
        _expectInsideSafeArea(tester, find.text('Long tab title 13'));

        for (final value in [!initial, initial]) {
          extend.value = value;
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(_scrollState(tester, tabs), same(scroll));
          expect(scroll.position.pixels, greaterThan(0));
          _expectInsideSafeArea(tester, find.text('Long tab title 13'));
          expect(find.text('page12: 1'), findsOneWidget);
        }
      });

      for (final tone in [
        SeedPageBannerTone.neutral,
        SeedPageBannerTone.magic,
      ]) {
        testWidgets('SeedPageBanner keeps its content state ($flip, $tone)', (
          tester,
        ) async {
          _landscapeNotch(tester);
          final extend = ValueNotifier(initial);
          addTearDown(extend.dispose);
          await tester.pumpWidget(
            _flipping(
              extend,
              (value) => SeedPageBanner(
                description: 'Banner',
                tone: tone,
                prefixIcon: const _Counter('icon'),
                dismissible: true,
                extendSafeAreaX: value,
              ),
            ),
          );
          await tester.tap(find.text('icon: 0'));
          await tester.pump();
          final box = tester.getRect(find.byType(SeedPageBanner));
          for (final value in [!initial, initial]) {
            extend.value = value;
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.text('icon: 1'), findsOneWidget);
            expect(tester.getRect(find.byType(SeedPageBanner)), box);
          }
        });
      }
    }
  });
}

const _threeTabs = <SeedTabItem>[
  SeedTabItem(label: 'A'),
  SeedTabItem(label: 'B'),
  SeedTabItem(label: 'C'),
];

/// Rebuilds [build] whenever [extend] changes, as a consumer Switch would.
Widget _flipping(ValueNotifier<bool> extend, Widget Function(bool) build) =>
    _app(
      ValueListenableBuilder<bool>(
        valueListenable: extend,
        builder: (context, value, _) => build(value),
      ),
    );

int _selectedTab(WidgetTester tester) =>
    tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex;

/// The one carousel page whose content is inside the page view, checked
/// against the page controller.
int _visiblePage(WidgetTester tester, int count) {
  final view = tester.getRect(find.byType(PageView));
  final visible = [
    for (var i = 0; i < count; i++)
      if (view.contains(
        tester.getCenter(find.textContaining('page$i:', skipOffstage: false)),
      ))
        i,
  ];
  expect(visible, hasLength(1));
  final page = tester.widget<PageView>(find.byType(PageView)).controller!.page;
  expect(page, closeTo(visible.single, 0.001));
  return visible.single;
}

ScrollableState _scrollState(WidgetTester tester, Finder of) =>
    tester.state<ScrollableState>(
      find.descendant(of: of, matching: find.byType(Scrollable)).first,
    );

void _expectInsideSafeArea(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  expect(rect.left, greaterThanOrEqualTo(_left - 0.5));
  expect(rect.right, lessThanOrEqualTo(_width - _right + 0.5));
}

class _Counter extends StatefulWidget {
  const _Counter(this.name);

  final String name;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => _count++),
    child: SizedBox(
      width: 120,
      height: 40,
      child: Text('${widget.name}: $_count'),
    ),
  );
}
