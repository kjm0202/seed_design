import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  testWidgets(
    'SidePanel keeps an accessible name when the title is visually hidden',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: SeedSidePanel(
                title: '',
                semanticsLabel: 'Side Panel',
                body: const Text('Content'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(find.byType(SeedSidePanel)).label,
          'Side Panel',
        );
        expect(find.text('Side Panel'), findsNothing);
        expect(find.text('Content'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'SidePanel derives the default accessible name from its visible title',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: const Scaffold(
              body: SeedSidePanel(title: '설정', body: Text('Content')),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.getSemantics(find.byType(SeedSidePanel)).label, '설정');
        expect(find.text('설정'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
}
