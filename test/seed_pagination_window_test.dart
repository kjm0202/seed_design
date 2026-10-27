import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child, {double width = 328}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

List<String> labels(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byType(SeedPagination),
        matching: find.byType(Text),
      ),
    )
    .map((text) => text.data!)
    .toList();

void main() {
  testWidgets('selecting 10 then 8 keeps earlier neighboring pages reachable', (
    tester,
  ) async {
    var page = 9;
    final changes = <int>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => SeedPagination(
            currentPage: page,
            totalPages: 10,
            onPageChanged: (next) {
              changes.add(next);
              setState(() => page = next);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(page, 8);
    expect(labels(tester), ['...', '7', '8', '9', '10']);
    for (final previous in [7, 6, 5, 4, 3, 2, 1]) {
      await tester.tap(find.text('$previous'));
      await tester.pumpAndSettle();
      expect(page, previous);
    }
    expect(changes, [10, 8, 7, 6, 5, 4, 3, 2, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('five page slots follow the official compact page windows', (
    tester,
  ) async {
    const expected = [
      ['1', '2', '3', '4', '...'],
      ['1', '2', '3', '4', '...'],
      ['1', '2', '3', '4', '...'],
      ['...', '3', '4', '5', '...'],
      ['...', '4', '5', '6', '...'],
      ['...', '5', '6', '7', '...'],
      ['...', '6', '7', '8', '...'],
      ['...', '7', '8', '9', '10'],
      ['...', '7', '8', '9', '10'],
      ['...', '7', '8', '9', '10'],
    ];
    for (var page = 1; page <= 10; page++) {
      await tester.pumpWidget(
        host(SeedPagination(currentPage: page, totalPages: 10)),
      );
      await tester.pumpAndSettle();
      expect(labels(tester), expected[page - 1], reason: 'page=$page');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('seven page slots retain official desktop boundary pages', (
    tester,
  ) async {
    const expected = {
      1: ['1', '2', '3', '4', '5', '...', '10'],
      4: ['1', '2', '3', '4', '5', '...', '10'],
      5: ['1', '...', '4', '5', '6', '...', '10'],
      6: ['1', '...', '5', '6', '7', '...', '10'],
      7: ['1', '...', '6', '7', '8', '9', '10'],
      10: ['1', '...', '6', '7', '8', '9', '10'],
    };
    for (final entry in expected.entries) {
      await tester.pumpWidget(
        host(
          SeedPagination(currentPage: entry.key, totalPages: 10),
          width: 768,
        ),
      );
      await tester.pumpAndSettle();
      expect(labels(tester), entry.value, reason: 'page=${entry.key}');
      expect(tester.takeException(), isNull);
    }
  });
}
