import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';
import 'package:seed_design_example/stackflow_spa/demo_pages.dart';

void main() {
  for (final width in [440.0, 1000.0]) {
    testWidgets('Home chips jump to sections at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      final scroll = tester.widget<CustomScrollView>(
        find.byType(CustomScrollView),
      );
      final targetChip = find.widgetWithText(
        SeedChip,
        width < 600 ? 'Drawer' : 'Pull to Refresh',
      );
      await tester.tap(targetChip);
      await tester.pumpAndSettle();
      expect(scroll.controller!.offset, greaterThan(0));
      expect(tester.widget<SeedChip>(targetChip).checked, isTrue);
      expect(
        find
            .text(width < 600 ? 'Bottom Sheet' : 'ActivityPullToRefreshPreview')
            .hitTestable(),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(SeedChip, 'AppScreen'));
      await tester.pumpAndSettle();
      expect(scroll.controller!.offset, 0);
      expect(find.text('App Bar 슬롯과 긴 제목').hitTestable(), findsOneWidget);
    });
  }

  testWidgets('Home keeps the active section heading visible on phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('spa-pinned-section-title')),
      findsNothing,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('spa-pinned-section-title')),
      findsOneWidget,
    );
  });

  testWidgets('Stackflow home groups link to their own activity routes', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('AppScreen'), findsWidgets);

    await tester.tap(find.text('App Bar 슬롯과 긴 제목'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Random Long Title Hello World Commodo occaecat laboris voluptate aute magna.',
      ),
      findsOneWidget,
    );
    expect(find.byType(SeedTopNavigation), findsWidgets);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Demo category filter affects listed articles and opens detail', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();

    final navigation = tester.state<NavigatorState>(find.byType(Navigator));
    navigation.pushNamed('/demo/home');
    await tester.pumpAndSettle();

    expect(find.text('Demo'), findsOneWidget);
    expect(find.text('독서 습관 만들기'), findsOneWidget);

    await tester.tap(find.text('카테고리'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('음식').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.text('홈메이드 파스타의 비밀'), findsOneWidget);
    expect(find.text('독서 습관 만들기'), findsNothing);

    await tester.ensureVisible(find.text('커피 브루잉 팁'));
    await tester.tap(find.text('커피 브루잉 팁'));
    await tester.pumpAndSettle();
    expect(find.byType(SpaArticleDetailPage), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(find.text('커피 브루잉 팁'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('댓글 없음'), findsOneWidget);
  });

  testWidgets('Form category uses Stackflow route and returns selected value', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/form');
    await tester.pumpAndSettle();

    final select = find.byType(SeedFieldButton);
    await tester.ensureVisible(select);
    await tester.tap(select);
    await tester.pumpAndSettle();

    expect(find.text('전자기기'), findsOneWidget);
    await tester.tap(find.text('전자기기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.text('전자기기'), findsOneWidget);
    expect(find.text('카테고리 선택'), findsWidgets);
  });
}
