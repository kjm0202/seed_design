import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/main.dart';

Future<void> show(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() async {
    final bytes = await File('../test/assets/fonts/WantedSansVariable.ttf')
        .readAsBytes();
    for (final family in ['Pretendard', 'Roboto']) {
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  });
  testWidgets('chip tab taps reach the requested content in both directions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('탐색 & 레이아웃'));
    await tester.pumpAndSettle();
    for (final (label, content, index) in [
      ('가격낮은순', '낮은 가격 상품', 3),
      ('추천순', '추천 상품', 0),
      ('인기순', '인기 상품', 2),
      ('추천순', '추천 상품', 0),
    ]) {
      await show(tester, find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      final tabs = find.byType(SeedChipTabsView);
      expect(tester.widget<SeedChipTabsView>(tabs).selectedIndex, index);
      final page = tester.widget<PageView>(
        find.descendant(of: tabs, matching: find.byType(PageView)),
      );
      expect(page.controller!.page, closeTo(index, .001));
      expect(find.text(content).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'navigation line tabs stay stable on each page entry and spread labels',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const SeedDesignCatalogApp());
      await tester.pumpAndSettle();
      for (final otherPage in ['컴포넌트', '피드백 & 상태', '입력 & 피커', '오버레이']) {
        await tester.tap(find.text(otherPage));
        // Feedback intentionally contains repeating loading animations.
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(find.text('탐색 & 레이아웃'));
        await tester.pump();
        final tabs = find.byKey(const ValueKey('line-tabs-content'));
        final header = find.descendant(
          of: tabs,
          matching: find.byType(SeedTabs),
        );
        expect(tester.widget<SeedTabs>(header).fill, isTrue);
        final body = find.descendant(of: tabs, matching: find.byType(PageView));
        for (var i = 0; i < 8; i++) {
          expect(tester.getSize(body).height, 80);
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        final first = tester.getRect(
          find.descendant(of: header, matching: find.text('홈')),
        );
        final next = tester.getRect(
          find.descendant(of: header, matching: find.text('동네생활')),
        );
        expect(next.left - first.right, greaterThan(20));
      }
    },
  );

  for (final width in [320.0, 1024.0]) {
    for (final dark in [false, true]) {
      testWidgets('integrated catalog fits width=$width dark=$dark', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const SeedDesignCatalogApp());
        await tester.pumpAndSettle();
        if (dark) {
          await tester.tap(find.bySemanticsLabel('다크 모드로 전환'));
          await tester.pumpAndSettle();
        }
        expect(find.bySemanticsLabel('공식 기능 예제'), findsNothing);
        await tester.tap(find.text('입력 & 피커'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedDatePicker), findsOneWidget);
        expect(find.byType(SeedAttachmentDisplayField), findsOneWidget);
        expect(find.byType(SeedTextField), findsNWidgets(2));
        await show(tester, find.byKey(const ValueKey('calendar-layout')));
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('탐색 & 레이아웃'));
        await tester.pumpAndSettle();
        final tabs = find.byKey(const ValueKey('line-tabs-content'));
        final pages = find.descendant(
          of: tabs,
          matching: find.byType(PageView),
        );
        await tester.drag(pages, Offset(-tester.getSize(pages).width * .7, 0));
        await tester.pumpAndSettle();
        expect(tester.widget<SeedTabsView>(tabs).selectedIndex, 1);
        expect(find.text('동네생활 콘텐츠').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('오버레이'));
        await tester.pumpAndSettle();
        await show(tester, find.text('키워드 알림이란?'));
        await tester.tap(find.text('키워드 알림이란?'));
        await tester.pumpAndSettle();
        expect(find.text('키워드 알림'), findsOneWidget);
        await tester.tap(find.text('확인'));
        await tester.pumpAndSettle();
        expect(find.text('키워드 알림'), findsNothing);
        await show(tester, find.text('스냅 시트 열기'));
        await tester.tap(find.text('스냅 시트 열기'));
        await tester.pumpAndSettle();
        expect(find.text('높이를 조절해 보세요'), findsOneWidget);
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }

  testWidgets('inputs preserve calendar choices and expose attachment state', (
    tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('입력 & 피커'));
    await tester.pumpAndSettle();
    final field = find.byType(SeedAttachmentDisplayField);
    final controller = tester
        .widget<SeedAttachmentDisplayField>(field)
        .controller!;
    expect(controller.items.length, 3);
    await show(tester, find.text('예시 첨부 항목 추가'));
    await tester.tap(find.text('예시 첨부 항목 추가'));
    await tester.pumpAndSettle();
    expect(controller.items.length, 4);
    final layout = find.byKey(const ValueKey('calendar-layout'));
    await show(tester, layout);
    await tester.tap(find.text('한 달'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한 주'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeedDatePicker>(find.byType(SeedDatePicker)).layout,
      SeedDatePickerLayout.week,
    );
    final original = tester
        .widget<SeedDatePicker>(find.byType(SeedDatePicker))
        .value;
    await tester.tap(find.text('한 주'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한 달'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeedDatePicker>(find.byType(SeedDatePicker)).value,
      original,
    );
    await show(tester, find.byKey(const ValueKey('calendar-mode')));
    await tester.tap(find.text('단일 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다중 선택'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeedDatePicker>(find.byType(SeedDatePicker)).mode,
      SeedDatePickerMode.multiple,
    );
    expect(find.text('다중 선택: 미선택'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap help bubble reopens after each dismissal method', (
    tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('피드백 & 상태'));
    await tester.pump(const Duration(milliseconds: 500));
    final trigger = find.text('도움말 확인');
    final bubble = find.descendant(
      of: find.byType(SeedHelpBubble),
      matching: find.text('버튼을 눌러 여는 도움말이에요'),
    );
    await show(tester, trigger);
    for (var attempt = 0; attempt < 3; attempt++) {
      await tester.tap(trigger);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(bubble, findsOneWidget, reason: 'Open attempt $attempt');
      switch (attempt) {
        case 0:
          await tester.tap(trigger);
        case 1:
          await tester.tap(find.text('SEED Design System'));
        case 2:
          await tester.tap(find.bySemanticsLabel('닫기'));
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(bubble, findsNothing);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('feedback snackbar clears the bottom navigation', (tester) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('피드백 & 상태'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SeedHelpBubbleTooltip), findsOneWidget);
    await show(tester, find.text('성공 안내'));
    await tester.tap(find.text('성공 안내'));
    await tester.pump(const Duration(milliseconds: 500));
    final message = find.byType(SeedSnackbar);
    expect(find.text('저장했어요.'), findsOneWidget);
    expect(
      tester.getBottomLeft(message).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byType(SeedBottomNavigation)).dy,
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
