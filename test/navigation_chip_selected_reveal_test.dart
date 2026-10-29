import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

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

void main() {
  setUpAll(loadSeedTestFonts);

  for (final width in [390.0, 800.0]) {
    for (final padding in <EdgeInsetsGeometry?>[
      null,
      const EdgeInsets.symmetric(horizontal: 20),
    ]) {
      testWidgets(
        'strict ChipTabs selected reveal width=$width padding=${padding == null ? "default16" : "20"} with scroll fog',
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
      'strict ChipTabs RTL directional padding and reveal width=$width',
      (tester) async {
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
      },
    );
  }
}
