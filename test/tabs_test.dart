import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

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

void main() {
  setUpAll(loadSeedTestFonts);

  for (final width in [390.0, 800.0]) {
    for (final direction in TextDirection.values) {
      for (final fill in [true, false]) {
        testWidgets(
          'React selected line tab reveal: width=$width direction=$direction fill=$fill',
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
        'React TabsCarousel MouseEvent drag: width=$width swipeable=$swipeable',
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
}
