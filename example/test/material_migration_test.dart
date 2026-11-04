import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/material_migration.dart';

void main() {
  testWidgets(
    'migration example validates saves and undoes a form with Select',
    (tester) async {
      await tester.pumpWidget(const MaterialMigrationExample());
      await tester.tap(find.text('저장'));
      await tester.pump();
      expect(find.text('이메일을 입력해 주세요'), findsOneWidget);
      expect(find.text('연락 방법을 선택해 주세요'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'neighbor@example.com');
      await tester.tap(find.text('선택해주세요'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('채팅'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.text('저장: neighbor@example.com · chat'), findsOneWidget);
      await tester.tap(find.text('되돌리기'));
      await tester.pumpAndSettle();
      expect(find.text('선택해주세요'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'migration example preserves tabs drawer and existing Material interactions',
    (tester) async {
      await tester.pumpWidget(const MaterialMigrationExample());
      await tester.tap(find.text('기존 위젯'));
      await tester.pumpAndSettle();
      expect(find.text('기존 Material 동작 유지').hitTestable(), findsOneWidget);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedDialog), findsOneWidget);
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedDialog), findsNothing);
      await tester.tap(find.byType(DrawerButton));
      await tester.pumpAndSettle();
      expect(find.text('기존 Drawer').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
