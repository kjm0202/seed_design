import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'continuous calendar opens, scrolls and selects without freezing',
    (tester) async {
      await tester.pumpWidget(const SeedDesignCatalogApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('입력 & 피커'));
      await tester.pumpAndSettle();

      final layout = find.byKey(const ValueKey('calendar-layout'));
      for (var attempt = 0; attempt < 3; attempt++) {
        await tester.ensureVisible(layout);
        await tester.pumpAndSettle();
        await tester.tap(find.text('한 달'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('연속'));
        await tester.pumpAndSettle();
        final picker = find.byType(SeedDatePicker);
        expect(
          tester.widget<SeedDatePicker>(picker).visibleRange,
          SeedDatePickerLayout.continuous,
        );
        expect(
          find
              .descendant(of: picker, matching: find.byType(Focus))
              .evaluate()
              .length,
          lessThan(250),
        );

        await tester.ensureVisible(picker);
        await tester.pumpAndSettle();
        await tester.drag(picker, const Offset(0, -180));
        await tester.pumpAndSettle();
        await tester.drag(picker, const Offset(0, 180));
        await tester.pumpAndSettle();
        final day = find
            .descendant(of: picker, matching: find.text('15'))
            .hitTestable()
            .first;
        await tester.tap(day);
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: picker,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.selected == true,
            ),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(layout);
        await tester.pumpAndSettle();
        await tester.tap(find.text('연속'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('한 달'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('탐색 & 레이아웃'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedTabsView), findsWidgets);
      expect(find.bySemanticsLabel('공식 기능 예제'), findsNothing);
    },
  );
}
