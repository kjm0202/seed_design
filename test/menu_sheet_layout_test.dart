import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _host(Widget child, {double width = 320}) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
testWidgets('menu sheet items keep the official 52px minimum height', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SeedMenuSheet(
          groups: [
            SeedMenuGroupData(items: [SeedMenuItemData(label: '추가')]),
          ],
        ),
        width: 390,
      ),
    );
    final item = find.ancestor(
      of: find.text('추가'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(item.first).height, greaterThanOrEqualTo(52));
  });
}
