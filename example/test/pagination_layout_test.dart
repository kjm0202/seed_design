import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/tabs/navigation_tab.dart';

import '../../test/support/seed_test_fonts.dart';

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
  setUpAll(() => loadSeedTestFonts(fontDirectory: '../test/assets/fonts'));

  testWidgets(
    'the real navigation demo fits mobile widths and keeps both page states independent',
    (tester) async {
      for (final width in [320.0, 360.0, 400.0]) {
        await mount(
          tester,
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: NavigationTab(key: ValueKey(width)),
            ),
          ),
          width,
          1,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'navigation demo width=$width',
        );
        final pagination = find.byType(SeedPagination);
        await tester.ensureVisible(pagination);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: pagination,
            matching: find.byIcon(Icons.chevron_right),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<SeedPagination>(pagination).currentPage, 2);

        final table = find.byType(SeedTablePagination);
        await tester.ensureVisible(table);
        await tester.pumpAndSettle();
        for (var index = 0; index < 10; index++) {
          await tester.tap(
            find.descendant(
              of: table,
              matching: find.byIcon(Icons.chevron_right),
            ),
          );
          await tester.pumpAndSettle();
        }
        expect(tester.widget<SeedTablePagination>(table).currentPage, 11);
        expect(tester.widget<SeedPagination>(pagination).currentPage, 2);
        expect(tester.takeException(), isNull);

        await tester.tap(
          find
              .descendant(of: table, matching: find.byType(SeedInputButton))
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('50개').last);
        await tester.pumpAndSettle();
        expect(tester.widget<SeedTablePagination>(table).currentPage, 1);
        expect(tester.widget<SeedTablePagination>(table).rowsPerPage, 50);
        expect(find.text('1–50 / 총 320개'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
