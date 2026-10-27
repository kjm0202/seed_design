import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('short custom dialogs do not reserve scrolling space', (
    tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('오버레이'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('커스텀 대화상자'));
    await tester.pumpAndSettle();
    final dialog = find.byType(SeedDialog);
    expect(
      find.descendant(of: dialog, matching: find.byType(SeedScrollFog)),
      findsNothing,
    );
    final body = find.text('현재 위치가 인증되었습니다. 이제 이웃들과 따뜻한 거래를 시작해보세요!');
    final button = find
        .ancestor(of: find.text('거래 시작하기'), matching: find.byType(SeedButton))
        .first;
    expect(
      tester.getTopLeft(button).dy - tester.getBottomLeft(body).dy,
      closeTo(16, .01),
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog tab targets and pagination windows remain navigable', (
    tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('탐색 & 레이아웃'));
    await tester.pumpAndSettle();
    final tabs = find.byType(SeedChipTabsView);
    for (final (label, index) in [
      ('가격낮은순', 3),
      ('추천순', 0),
      ('인기순', 2),
      ('추천순', 0),
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(tester.widget<SeedChipTabsView>(tabs).selectedIndex, index);
      final page = tester.widget<PageView>(
        find.descendant(of: tabs, matching: find.byType(PageView)),
      );
      expect(page.controller!.page, closeTo(index, .001));
      expect(tester.takeException(), isNull);
    }

    final pagination = find.byType(SeedPagination).first;
    await tester.ensureVisible(pagination);
    await tester.pumpAndSettle();
    Finder pageNumber(int number) =>
        find.descendant(of: pagination, matching: find.text('$number'));
    for (final page in [4, 5, 6, 7, 8, 10, 8, 7, 6, 5]) {
      await tester.tap(pageNumber(page));
      await tester.pumpAndSettle();
      expect(tester.widget<SeedPagination>(pagination).page, page);
      if (page == 8) expect(pageNumber(7), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('a minimized snap sheet can repeatedly expand again', (
    tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('오버레이'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('스냅 시트 열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('스냅 시트 열기'));
    await tester.pumpAndSettle();
    final sheet = find.byType(SeedSnappingBottomSheet);
    final handle = find.descendant(
      of: sheet,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector && widget.onVerticalDragUpdate != null,
      ),
    );
    final height = MediaQuery.sizeOf(tester.element(sheet)).height;
    DraggableScrollableController controller() => tester
        .widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet))
        .controller!;
    for (var attempt = 0; attempt < 3; attempt++) {
      await tester.drag(handle, Offset(0, height * .3));
      await tester.pumpAndSettle();
      expect(controller().size, closeTo(.2, .01));
      await tester.drag(handle, Offset(0, -height * .4));
      await tester.pumpAndSettle();
      expect(controller().size, greaterThan(.4));
      expect(tester.takeException(), isNull);
    }
  });
}
