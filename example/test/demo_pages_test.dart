import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/demo_pages.dart';
import 'package:seed_design_example/stackflow_spa/spa_history.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

// Official sources: ActivityDemoHome.tsx:69-112,159-339,
// ActivityDemoArticleDetail.tsx:81-169, ActivityCategorySheet.tsx:72-106,
// ActivityDialog.tsx:53-92 and the CSS tabs.css:152-165.
Future<void> _open(
  WidgetTester tester,
  String route, {
  double width = 390,
  double height = 844,
  Object? arguments,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .pushNamed(route, arguments: arguments);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _openDemo(
  WidgetTester tester, {
  required Size size,
  required double keyboardBottom,
  double textScale = 2,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardBottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
        viewInsets: EdgeInsets.only(bottom: keyboardBottom),
      ),
      child: const StackflowSpaApp(),
    ),
  );
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .pushNamed('/demo/home');
  await tester.pumpAndSettle();
}

void main() {
  group('article and feed', () {
    test(
      'article URL contains the selected id and survives a fresh visit',
      () async {
        const parser = SpaHistoryParser();
        final route = parser.restoreRouteInformation(
          const SpaHistory([
            RouteSettings(name: '/'),
            RouteSettings(name: '/demo/home'),
            RouteSettings(name: '/demo/article-detail', arguments: 3),
          ]),
        );
        expect(route.uri.path, '/demo/article-detail/');
        expect(route.uri.queryParameters['articleId'], '3');

        final restored = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/demo/article-detail?articleId=3')),
        );
        expect(restored.activities.last.name, '/demo/article-detail');
        expect(restored.activities.last.arguments, 3);
      },
    );

    testWidgets('direct article URL displays the requested article', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/demo/article-detail?articleId=3');
      await tester.pumpAndSettle();
      expect(find.text('알프스 하이킹 가이드'), findsOneWidget);
    });

    testWidgets(
      'article AppBar shows Back when stacked and inert Close at root',
      (tester) async {
        tester.view.physicalSize = const Size(390, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));

        navigator.pushNamed('/demo/article-detail', arguments: 1);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
        expect(find.byIcon(Icons.close_rounded), findsNothing);

        navigator.pop();
        await tester.pumpAndSettle();
        navigator.pushReplacementNamed('/demo/article-detail', arguments: 1);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text('산토리니의 일몰'), findsOneWidget);
      },
    );

    testWidgets(
      'article ID survives actual platform Back Forward restoration',
      (tester) async {
        tester.view.physicalSize = const Size(390, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final updates = <Map<dynamic, dynamic>>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            if (call.method == 'routeInformationUpdated') {
              updates.add(Map<dynamic, dynamic>.from(call.arguments as Map));
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pushNamed('/demo/home');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('알프스 하이킹 가이드'));
        await tester.tap(find.text('알프스 하이킹 가이드'));
        await tester.pumpAndSettle();
        expect(find.text('알프스 하이킹 가이드'), findsOneWidget);
        expect(updates.last['uri'], '/demo/article-detail/?articleId=3');
        final articleEntry = updates.last;
        navigator.pop();
        await tester.pumpAndSettle();
        expect(updates.last['uri'], '/demo/home');
        final completed = Completer<void>();
        tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          SystemChannels.navigation.name,
          SystemChannels.navigation.codec.encodeMethodCall(
            MethodCall('pushRouteInformation', {
              'location': articleEntry['uri'],
              'state': articleEntry['state'],
            }),
          ),
          (_) => completed.complete(),
        );
        await tester.pump();
        await completed.future;
        await tester.pumpAndSettle();
        expect(find.text('알프스 하이킹 가이드'), findsOneWidget);
        expect(updates.last['uri'], '/demo/article-detail/?articleId=3');
      },
    );

    testWidgets('Demo has leading title, top subscription state and no Back', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/demo/home');
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Demo')).dx, closeTo(16, 1));
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      await tester.tap(find.text('구독'));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('구독한 글이 없습니다.')).dy, lessThan(330));
      await tester.tap(find.text('추천 글 보기'));
      await tester.pumpAndSettle();
      expect(find.text('독서 습관 만들기').hitTestable(), findsOneWidget);
    });
    testWidgets('Demo filter sheet uses native footer and commits categories', (
      tester,
    ) async {
      await _open(tester, '/demo/home');
      await tester.tap(find.widgetWithText(SeedChip, '카테고리'));
      await tester.pumpAndSettle();
      final sheet = tester.widget<SeedBottomSheet>(
        find.byType(SeedBottomSheet),
      );
      expect(sheet.content, isA<Wrap>());
      final footer = sheet.footer! as Padding;
      expect(
        footer.padding.resolve(TextDirection.ltr),
        const EdgeInsets.only(top: 12),
      );
      await tester.tap(find.widgetWithText(SeedChip, '여행'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SeedButton, '완료'));
      await tester.pumpAndSettle();
      expect(find.text('알프스 하이킹 가이드'), findsOneWidget);
      expect(find.text('독서 습관 만들기'), findsNothing);
    });

    testWidgets('Demo preserves recommendation scroll after tab round-trip', (
      tester,
    ) async {
      await _open(tester, '/demo/home', height: 600);
      const key = PageStorageKey<String>('demo-recommendations');
      final scroll = find.byKey(key);
      await tester.drag(scroll, const Offset(0, -360));
      await tester.pumpAndSettle();
      final scrollable = find.descendant(
        of: scroll,
        matching: find.byType(Scrollable),
      );
      final saved = tester
          .state<ScrollableState>(scrollable.first)
          .position
          .pixels;
      expect(saved, greaterThan(200));
      await tester.tap(find.text('구독'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('추천'));
      await tester.pumpAndSettle();
      expect(
        tester.state<ScrollableState>(scrollable.first).position.pixels,
        closeTo(saved, 1),
      );
      expect(tester.takeException(), isNull);
    });
    for (final (size, keyboardBottom) in [
      (const Size(320, 568), 250.0),
      (const Size(390, 844), 520.0),
      (const Size(800, 800), 490.0),
    ]) {
      testWidgets(
        'Demo subscription CTA remains reachable in own scrollport with keyboard & 2x text $size',
        (tester) async {
          await _openDemo(tester, size: size, keyboardBottom: keyboardBottom);
          final tabs = find.byType(SeedTabs).last;
          expect(tester.getTopLeft(tabs).dy, closeTo(56, .5));
          expect(
            tester.getSize(tabs).height,
            greaterThanOrEqualTo(44),
            reason: 'Official medium tabs use min-height:44, not fixed height',
          );
          await tester.tap(find.text('구독'));
          await tester.pumpAndSettle();

          final action = find.widgetWithText(SeedButton, '추천 글 보기');
          expect(action, findsOneWidget);
          final subscriptionScroller = find.ancestor(
            of: action,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is SingleChildScrollView &&
                  widget.scrollDirection == Axis.vertical,
            ),
          );
          expect(
            subscriptionScroller,
            findsOneWidget,
            reason: 'React tabs.css:32-38 TabsContent overflow-y:auto, including the empty subscription tab',
          );
          final scrollable = find
              .descendant(
                of: subscriptionScroller,
                matching: find.byType(Scrollable),
              )
              .first;
          final position = tester.state<ScrollableState>(scrollable).position;
          expect(position.maxScrollExtent, greaterThan(0));
          final before = position.pixels;
          await tester.drag(subscriptionScroller, const Offset(0, -280));
          await tester.pumpAndSettle();
          expect(position.pixels, greaterThan(before));
          // On 320px with large text one gesture may not reach the button yet.
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          expect(
            tester.getBottomRight(action).dy,
            lessThanOrEqualTo(tester.getBottomRight(subscriptionScroller).dy),
          );
          expect(tester.getTopLeft(tabs).dy, closeTo(56, .5));

          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(find.text('독서 습관 만들기'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final (size, keyboardBottom) in [
      (const Size(320, 568), 250.0),
      (const Size(390, 844), 520.0),
      (const Size(800, 800), 490.0),
    ]) {
      testWidgets(
        'Demo tab list stays pinned and feed offset survives tabs at 2x $size',
        (tester) async {
          await _openDemo(tester, size: size, keyboardBottom: keyboardBottom);
          final tabs = find.byType(SeedTabs).last;
          final tabsTop = tester.getTopLeft(tabs).dy;
          final feed = find.byKey(
            const PageStorageKey<String>('demo-recommendations'),
          );
          final scrollable = find
              .descendant(of: feed, matching: find.byType(Scrollable))
              .first;
          await tester.drag(feed, const Offset(0, -280));
          await tester.pumpAndSettle();
          final saved = tester
              .state<ScrollableState>(scrollable)
              .position
              .pixels;
          expect(saved, greaterThan(0));
          expect(tester.getTopLeft(tabs).dy, closeTo(tabsTop, .5));

          await tester.tap(find.text('구독'));
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(tabs).dy, closeTo(tabsTop, .5));
          await tester.tap(find.text('추천'));
          await tester.pumpAndSettle();
          expect(
            tester.state<ScrollableState>(scrollable).position.pixels,
            closeTo(saved, 1),
          );
          expect(tester.getTopLeft(tabs).dy, closeTo(tabsTop, .5));
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('category filter', () {
    testWidgets(
      'Demo category filter affects listed articles and opens detail',
      (tester) async {
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
      },
    );
  });
}
