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
testWidgets('dialogs have no drop shadow (official recipe has none)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SeedDialog(title: 'Body', content: SizedBox.shrink()),
        width: 390,
      ),
    );
    final shadows = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(SeedDialog),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);
    expect(shadows, isEmpty);
  });
}
