import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

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

void main() {
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
                  children: const [SizedBox(height: 80), SizedBox(height: 160)],
                ),
              ),
            ),
          ),
        );
        final viewport = find.byType(PageView);
        if (initialHeight != null) expect(tester.getSize(viewport).height, 80);
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
    await tester.pumpWidget(tabsHost(changes: changes, controller: controller));
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
}
