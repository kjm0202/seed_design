import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Future<void> mount(
  WidgetTester tester,
  Widget child,
  double width,
  double scale,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets(
    'page controls fit narrow containers and still select and advance',
    (tester) async {
      for (final width in [240.0, 288.0, 328.0, 768.0]) {
        for (final page in [1, 5, 10]) {
          int? selected;
          await mount(
            tester,
            SeedPagination(
              currentPage: page,
              totalPages: 10,
              onPageChanged: (value) => selected = value,
            ),
            width,
            1,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'width=$width, page=$page',
          );
          final bounds = tester.getRect(find.byType(SeedPagination));
          for (final ink
              in find
                  .descendant(
                    of: find.byType(SeedPagination),
                    matching: find.byType(InkWell),
                  )
                  .evaluate()) {
            final box = tester.getRect(find.byWidget(ink.widget));
            expect(box.left, greaterThanOrEqualTo(bounds.left));
            expect(box.right, lessThanOrEqualTo(bounds.right));
            expect(box.width, greaterThanOrEqualTo(40));
          }
          if (page < 10) {
            await tester.tap(find.byIcon(Icons.chevron_right));
            await tester.pumpAndSettle();
            expect(selected, page + 1);
          } else {
            await tester.tap(find.byIcon(Icons.chevron_right));
            expect(selected, isNull);
          }
          selected = null;
          await tester.tap(find.text('$page'));
          expect(selected, page);
        }
      }
    },
  );

  testWidgets('table page controls wrap at narrow widths and enlarged text', (
    tester,
  ) async {
    for (final width in [240.0, 288.0, 328.0, 768.0]) {
      for (final scale in [1.0, 2.0]) {
        int? selected;
        await mount(
          tester,
          SeedTablePagination(
            currentPage: 2,
            totalItems: 320,
            rowsPerPage: 10,
            onPageChanged: (value) => selected = value,
            onRowsPerPageChanged: (_) {},
          ),
          width,
          scale,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'width=$width, scale=$scale',
        );
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
        expect(selected, 3);
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        expect(selected, 1);
      }
    }
  });
  testWidgets(
    'custom slot limits keep the current page visible without duplicates',
    (tester) async {
      for (final slots in [1, 3, 5, 7]) {
        for (final page in [1, 5, 10]) {
          await mount(
            tester,
            SeedPagination(
              currentPage: page,
              totalPages: 10,
              maxVisibleSlots: slots,
              onPageChanged: (_) {},
            ),
            768,
            2,
          );
          final labels = tester
              .widgetList<Text>(
                find.descendant(
                  of: find.byType(SeedPagination),
                  matching: find.byType(Text),
                ),
              )
              .map((text) => text.data!)
              .toList();
          expect(labels.length, lessThanOrEqualTo(slots));
          expect(labels, contains('$page'));
          final numbers = labels.where((label) => label != '...').toList();
          expect(numbers.toSet().length, numbers.length);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
}
