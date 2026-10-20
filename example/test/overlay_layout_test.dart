import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/tabs/overlays_tab.dart';

import '../../test/support/seed_test_fonts.dart';

Future<void> mount(
  WidgetTester tester, {
  double width = 390,
  double scale = 1,
  bool dark = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 800);
  final theme = dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme.toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(16), child: OverlaysTab()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> open(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => loadSeedTestFonts(fontDirectory: '../test/assets/fonts'));

  testWidgets('confirmation sample uses a concise single-line Korean title', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await mount(tester);
    await open(tester, '기본 확인 알림창');
    expect(
      tester.getSize(find.text('알림 설정을 저장할까요?')).height,
      SeedLineHeight.t7,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.byType(SeedAlertDialog), findsNothing);
  });

  testWidgets(
    'sorting uses SEED row spacing and one horizontal screen gutter',
    (tester) async {
      addTearDown(tester.view.reset);
      await mount(tester);
      await open(tester, '바텀 시트 열기');
      final rows = find.byType(SeedListItem);
      expect(rows, findsNWidgets(3));
      final bounds = tester.getRect(find.byType(SeedBottomSheet));
      final title = tester.getRect(find.text('정렬 옵션 선택'));
      expect(title.top - bounds.top, 24);
      final first = tester.getRect(rows.first);
      expect(first.top - title.bottom, 16);
      expect(first.height, SeedLineHeight.t5 + 2 * SeedDimension.x3);
      expect(
        tester.getTopLeft(find.byIcon(Icons.access_time)).dx - bounds.left,
        16,
      );
      await tester.tap(find.text('최신순'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'detail panel shows listing content at phone and foldable widths',
    (tester) async {
      addTearDown(tester.view.reset);
      for (final width in [320.0, 900.0]) {
        for (final dark in [false, true]) {
          await mount(tester, width: width, scale: 2, dark: dark);
          await open(tester, '사이드 패널 슬라이드');
          expect(find.text('상품 정보'), findsOneWidget);
          expect(find.text('무선 헤드폰'), findsOneWidget);
          expect(find.text('거래 안내'), findsOneWidget);
          expect(find.text('SEED Side Panel의 본문 영역입니다.'), findsNothing);
          expect(find.text('확인 완료').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('확인 완료'));
          await tester.pumpAndSettle();
          expect(find.byType(SeedSidePanel), findsNothing);
        }
      }
    },
  );
}
