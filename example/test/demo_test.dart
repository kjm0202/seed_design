import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_catalog.dart';
import 'package:seed_design_example/stackflow_spa/spa_history.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
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

  testWidgets('article ID survives actual platform Back Forward restoration', (
    tester,
  ) async {
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
  });

  testWidgets('Home icon pushes a history entry and Back restores its source', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final updates = <Map<dynamic, dynamic>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation,
      (call) async {
        if (call.method == 'routeInformationUpdated') {
          updates.add(call.arguments as Map);
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
    navigator.pushNamed('/tabs');
    await tester.pumpAndSettle();
    expect(updates.last['uri'], '/tabs');
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(updates.last['uri'], '/');
    await navigator.maybePop();
    await tester.pumpAndSettle();
    expect(updates.last['uri'], '/tabs');
  });

  testWidgets('unknown route shows React 404 title and content', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/nonexistent-route');
    await tester.pumpAndSettle();
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('404 Not Found'), findsOneWidget);
  });

  testWidgets('Home bell does not generate a Flutter-only Snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pump();
    expect(find.text('새로운 알림이 없습니다.'), findsNothing);
  });

  for (final (width, columns) in [
    (600.0, 1),
    (767.0, 1),
    (768.0, 2),
    (960.0, 2),
    (1279.0, 2),
    (1280.0, 3),
    (1439.0, 3),
    (1440.0, 4),
  ]) {
    testWidgets('Home React grid columns at $width = $columns', (tester) async {
      tester.view.physicalSize = Size(width, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      final grid = tester
          .widgetList<Wrap>(find.byType(Wrap))
          .firstWhere((wrap) => wrap.children.length == spaSections.length);
      final firstCard = tester.getSize(find.byWidget(grid.children.first));
      expect(
        firstCard.width,
        closeTo((width - 32 - (columns - 1) * 20) / columns, 0.1),
      );
    });
  }

  testWidgets('mobile active Home chip stays in the horizontal viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -7000));
    await tester.pumpAndSettle();
    final selected = tester
        .widgetList<SeedChip>(find.byType(SeedChip))
        .singleWhere((chip) => chip.checked == true);
    final location = tester.getCenter(find.byWidget(selected));
    expect(location.dx, inInclusiveRange(0, 390));
    expect(
      find.byKey(const ValueKey('spa-pinned-section-title')),
      findsOneWidget,
    );
  });

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
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    await tester.tap(find.text('구독'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('구독한 글이 없습니다.')).dy, lessThan(330));
    await tester.tap(find.text('추천 글 보기'));
    await tester.pumpAndSettle();
    expect(find.text('독서 습관 만들기').hitTestable(), findsOneWidget);
  });

  testWidgets('article hero reaches y=0, callout and Post match React', (
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
        .pushNamed('/demo/article-detail', arguments: 10);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(AspectRatio).first).dy, closeTo(0, 1));
    await tester.scrollUntilVisible(
      find.text('게시'),
      320,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeedCallout>(find.byType(SeedCallout)).prefixIcon,
      isNotNull,
    );
    await tester.tap(find.text('게시'));
    await tester.pump();
    expect(find.text('댓글 예제에서는 등록을 지원하지 않습니다.'), findsNothing);
  });
}
