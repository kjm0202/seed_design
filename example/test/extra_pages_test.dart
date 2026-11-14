// Strict React ActivityCategorySheet direct-root guard:
// Stackflow pop() cannot pop the only history activity, so the sheet remains.
// Pushed CategorySheet from Form still sends its result and closes normally.
import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/extra_pages.dart';
import 'package:seed_design_example/stackflow_spa/spa_history.dart';
import 'package:seed_design_example/stackflow_spa/spa_types.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> _route(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .pushNamed(route, arguments: arguments);
  await tester.pumpAndSettle();
}

Future<void> _direct(WidgetTester tester, String route) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': route, 'state': null}),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

Future<void> directCategory(WidgetTester tester) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('pushRouteInformation', {
        'location': '/category-sheet',
        'state': null,
      }),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

// Official sources: ActivityDemoHome.tsx:69-112,159-339,
// ActivityDemoArticleDetail.tsx:81-169, ActivityCategorySheet.tsx:72-106,
// ActivityDialog.tsx:53-92 and the CSS tabs.css:152-165.
Future<void> _openDemo(
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

Future<NavigatorState> _openScreenRoutes(
  WidgetTester tester,
  String path,
  double width,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final nav = tester.state<NavigatorState>(find.byType(Navigator));
  nav.pushNamed(path);
  await tester.pumpAndSettle();
  return nav;
}

Finder _innerSearchField() => find.byWidgetPredicate((w) {
  if (w is! Container) return false;
  return w.constraints?.maxHeight == 40 &&
      w.padding == const EdgeInsets.symmetric(horizontal: 12) &&
      w.decoration is BoxDecoration;
});

// Source: ActivityAppScreenIntersectionObserver.tsx:56-89 and
// seed-design/ui/app-bar.tsx:99-130. AppBarCloseButton is rendered only
// for an activity with isRoot=true; the notification icon always remains.
Future<NavigatorState> _startAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  return tester.state<NavigatorState>(find.byType(Navigator).first);
}

Future<void> _openAsBrowserRoot(WidgetTester tester, String path) async {
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': path, 'state': null}),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

SeedTopNavigation _appBar(WidgetTester tester) =>
    tester.widget<SeedTopNavigation>(find.byType(SeedTopNavigation).last);

void _scrollPastHeader(WidgetTester tester) {
  expect(_appBar(tester).tone, SeedTopNavigationTone.transparent);
  final controller = tester.widget<ListView>(find.byType(ListView)).controller!;
  controller.jumpTo(401);
}

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets('direct URL app-bar-slot has no back $width', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _direct(tester, '/app-bar-slot');
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      expect(find.byType(SeedTopNavigation), findsOneWidget);
    });

    testWidgets(
      'direct URL AlertDialogStackflow has no stray host AppBar $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _direct(tester, '/alert-dialog-stackflow');
        expect(find.byType(SeedTopNavigation), findsNothing);
        final action = find.widgetWithText(SeedButton, '확인');
        expect(
          tester.widget<SeedButton>(action).variant,
          SeedButtonVariant.neutralSolid,
        );
      },
    );

    testWidgets('direct URL CategorySheet has no stray host AppBar $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _direct(tester, '/category-sheet');
      expect(find.byType(SeedTopNavigation), findsNothing);
      expect(find.byType(SeedBottomSheet), findsOneWidget);
    });
    testWidgets(
      'detail: one header title, body once, no invented Home text $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _route(
          tester,
          '/detail',
          arguments: {'title': 'Only Real Title', 'body': 'Only Real Body'},
        );
        expect(find.text('Only Real Title'), findsOneWidget);
        expect(find.text('Only Real Body'), findsOneWidget);
        expect(find.text('홈으로'), findsNothing);
      },
    );

    testWidgets(
      'stackflow alert: backdrop no AppBar and neutral confirm $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _route(tester, '/alert-dialog-stackflow');
        expect(find.byType(SeedAlertDialog), findsOneWidget);
        // React AlertDialogRoot is an overlay above the retained Activity.
        // Its own route has no AppBar, but Home remains visible behind the
        // non-opaque modal barrier (the same contract as CategorySheet).
        expect(find.byType(SeedTopNavigation), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SpaOwnScaffold).last,
            matching: find.byType(SeedTopNavigation),
          ),
          findsNothing,
        );
        final action = find.widgetWithText(SeedButton, '확인');
        expect(
          tester.widget<SeedButton>(action).variant,
          SeedButtonVariant.neutralSolid,
        );
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(find.byType(SeedAlertDialog), findsNothing);
      },
    );

    testWidgets(
      'category: background no AppBar and zero invented row dividers $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _route(tester, '/category-sheet');
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        // Only the retained parent's AppBar, visible behind the modal activity.
        expect(find.byType(SeedTopNavigation), findsOneWidget);
        final rows = find.byType(SeedRadioListItem<String>);
        expect(rows, findsWidgets);
        for (final row in tester.widgetList<SeedRadioListItem<String>>(rows)) {
          expect(row.showDivider, false);
        }
        await tester.tap(find.text('전자기기'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('완료'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedBottomSheet), findsNothing);
      },
    );
  }

  testWidgets(
    'app-bar-slot root hides back and bell buttons do nothing; nested has back',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = buildExtraPage(
                'ActivityAppBarSlot',
                context,
                navigate: (name, {arguments}) {},
                goBack: () {},
              );
              return page as SpaOwnScaffold;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      final bell = tester
          .widgetList<SeedTopNavigationIconButton>(
            find.byType(SeedTopNavigationIconButton),
          )
          .toList();
      expect(bell.length, 2);
      for (final icon in bell) {
        // Official React AppBarIconButton is enabled/focusable even when it
        // has no onClick handler. An inert callback preserves that contract.
        expect(icon.onPressed, isNotNull);
        expect(icon.enabled, isTrue);
      }
      for (var index = 0; index < bell.length; index++) {
        await tester.tap(find.byType(SeedTopNavigationIconButton).at(index));
        await tester.pumpAndSettle();
        expect(find.byType(SeedSnackbar), findsNothing);
        expect(find.text('알림 1'), findsNothing);
        expect(find.text('알림 2'), findsNothing);
        expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      }
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed('/app-bar-slot');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    },
  );
  group('CategorySheet root retention', () {
    for (final viewport in [const Size(390, 844), const Size(800, 800)]) {
      testWidgets(
        '${viewport.width.toInt()} direct root Fashion→완료 keeps visible sheet, does not leave empty route',
        (tester) async {
          tester.view.physicalSize = viewport;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await directCategory(tester);
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          await tester.tap(find.text('패션/의류'));
          await tester.pumpAndSettle();
          final fashion = find.byWidgetPredicate(
            (w) => w is SeedRadioListItem<String> && w.value == 'fashion',
          );
          expect(
            tester.widget<SeedRadioListItem<String>>(fashion).groupValue,
            'fashion',
          );
          await tester.tap(find.widgetWithText(SeedButton, '완료'));
          await tester.pumpAndSettle();
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          expect(find.text('카테고리 선택'), findsOneWidget);
          expect(
            tester.widget<SeedRadioListItem<String>>(fashion).groupValue,
            'fashion',
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        '${viewport.width.toInt()} parent push Fashion→완료 returns value and closes sheet',
        (tester) async {
          tester.view.physicalSize = viewport;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(const StackflowSpaApp());
          await tester.pumpAndSettle();
          final nav = tester.state<NavigatorState>(
            find.byType(Navigator).first,
          );
          final result = nav.pushNamed('/category-sheet');
          await tester.pumpAndSettle();
          await tester.tap(find.text('패션/의류'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(SeedButton, '완료'));
          await tester.pumpAndSettle();
          expect(await result, {'value': 'fashion', 'label': '패션/의류'});
          expect(find.byType(SeedBottomSheet), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('CategorySheet footer', () {
    testWidgets('CategorySheet last item stays reachable with footer', (
      tester,
    ) async {
      await _openDemo(tester, '/category-sheet', width: 390, height: 600);
      final list = find.byType(ListView).last;
      await tester.scrollUntilVisible(
        find.text('기타'),
        280,
        scrollable: find
            .descendant(of: list, matching: find.byType(Scrollable))
            .first,
        maxScrolls: 20,
      );
      await tester.pumpAndSettle();
      expect(find.text('기타').hitTestable(), findsOneWidget);
      expect(find.widgetWithText(SeedButton, '완료'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('IntersectionObserver, ArticlePreventDrag and AppBarSlot', () {
    for (final width in [390.0, 800.0]) {
      testWidgets(
        'intersection scroller leaves and returns to white region $width',
        (tester) async {
          await _openScreenRoutes(
            tester,
            '/app-screen-intersection-observer',
            width,
          );
          SeedTopNavigation appBar() =>
              tester.widget(find.byType(SeedTopNavigation));
          expect(appBar().tone, SeedTopNavigationTone.transparent);
          final scroll = tester
              .widget<ListView>(find.byType(ListView))
              .controller!;
          scroll.jumpTo(401);
          await tester.pumpAndSettle();
          expect(appBar().tone, SeedTopNavigationTone.layer);
          scroll.jumpTo(0);
          await tester.pumpAndSettle();
          expect(appBar().tone, SeedTopNavigationTone.transparent);
        },
      );

      testWidgets(
        'article drag preserves first tab on protected gesture $width',
        (tester) async {
          await _openScreenRoutes(tester, '/article-prevent-drag', width);
          SeedTabs tabs() => tester.widget(find.byType(SeedTabs).first);
          expect(tabs().selectedIndex, 0);
          final paragraph = find.textContaining('이 요소는 Article 내부에 있으므로');
          await tester.drag(paragraph, const Offset(-170, 0));
          await tester.pumpAndSettle();
          expect(tabs().selectedIndex, 0);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'article drag outside protected text advances to second tab $width',
        (tester) async {
          await _openScreenRoutes(tester, '/article-prevent-drag', width);
          SeedTabs tabs() => tester.widget(find.byType(SeedTabs).first);
          expect(tabs().selectedIndex, 0);
          final outside = find.textContaining('이 요소는 Article 외부에 있으므로');
          // Commit the page change at both viewport widths; 220px is less than
          // half of the 800px carousel and correctly snaps back at that size.
          await tester.drag(outside, Offset(-width * 0.65, 0));
          await tester.pumpAndSettle();
          expect(tabs().selectedIndex, 1);
          expect(find.text('안녕하세요!'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
    for (final width in [390.0, 800.0]) {
      testWidgets('AppBarSlot PUSH retains back, two reachable bells $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
            .pushNamed('/app-bar-slot');
        await tester.pumpAndSettle();

        expect(_innerSearchField(), findsOneWidget);
        expect(
          tester.getRect(_innerSearchField()),
          rectMoreOrLessEquals(
            Rect.fromLTWH(50, 8, width - 144, 40),
            epsilon: .1,
          ),
          reason:
              'the official left AppBarIconButton has a 44px hit target '
              'but takes 24px of Flex layout, so the growing field starts '
              '24px later on PUSH without changing the trailing icons',
        );
        expect(find.byIcon(Icons.chevron_left_rounded), findsWidgets);
        final bell = find.byWidgetPredicate(
          (w) => w is SeedTopNavigationIconButton && w.semanticsLabel == '알림',
        );
        expect(bell, findsNWidgets(2));
        final lastBellRect = tester.getRect(bell.last);
        expect(lastBellRect.right, lessThanOrEqualTo(width));
        expect(
          tester.getRect(_innerSearchField()).right,
          lessThanOrEqualTo(tester.getRect(bell.first).left + .1),
        );
        await tester.tap(bell.last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('IntersectionObserver Close and AlertDialogStackflow', () {
    const path = '/app-screen-intersection-observer';
    for (final width in [390.0, 800.0]) {
      testWidgets('Direct root shows inert Close and stable tone at $width', (
        tester,
      ) async {
        await _startAt(tester, width);
        await _openAsBrowserRoot(tester, path);
        final appBar = find.byType(SeedTopNavigation).last;
        final history = SpaHistoryDelegate.of(tester.element(appBar));
        expect(history.currentConfiguration.activities.map((e) => e.name), [
          path,
        ]);
        expect(ModalRoute.of(tester.element(appBar))?.isFirst, true);
        final leading = _appBar(tester).leading;
        expect(leading, isA<SeedTopNavigationIconButton>());
        expect(
          (leading! as SeedTopNavigationIconButton).semanticsLabel,
          'Close',
        );
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.notifications), findsOneWidget);
        expect(find.text('Preview'), findsOneWidget);

        _scrollPastHeader(tester);
        await tester.pumpAndSettle();
        expect(_appBar(tester).tone, SeedTopNavigationTone.layer);
        tester.widget<ListView>(find.byType(ListView)).controller!.jumpTo(0);
        await tester.pumpAndSettle();
        expect(_appBar(tester).tone, SeedTopNavigationTone.transparent);

        // Official AppBarCloseButton has no default navigation action.
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(history.currentConfiguration.activities.map((e) => e.name), [
          path,
        ]);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'PUSH nonroot hides Close while retaining bar and tone $width',
        (tester) async {
          final navigator = await _startAt(tester, width);
          navigator.pushNamed(path);
          await tester.pumpAndSettle();
          final appBar = find.byType(SeedTopNavigation).last;
          final history = SpaHistoryDelegate.of(tester.element(appBar));
          expect(history.currentConfiguration.activities.map((e) => e.name), [
            '/',
            path,
          ]);
          expect(ModalRoute.of(tester.element(appBar))?.isFirst, false);
          expect(_appBar(tester).leading, isNull);
          expect(find.byIcon(Icons.close), findsNothing);
          expect(find.byIcon(Icons.notifications), findsOneWidget);
          expect(find.text('Preview'), findsOneWidget);

          _scrollPastHeader(tester);
          await tester.pumpAndSettle();
          expect(_appBar(tester).tone, SeedTopNavigationTone.layer);
          tester.widget<ListView>(find.byType(ListView)).controller!.jumpTo(0);
          await tester.pumpAndSettle();
          expect(_appBar(tester).tone, SeedTopNavigationTone.transparent);
          navigator.pop();
          await tester.pumpAndSettle();
          expect(history.currentConfiguration.activities.map((e) => e.name), [
            '/',
          ]);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('stackflow AlertDialog Activity is a non-opaque route', (
      tester,
    ) async {
      expect(spaModalActivities, contains('ActivityAlertDialogStackflow'));
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed('/alert-dialog-stackflow');
      await tester.pumpAndSettle();
      final ownScaffold = find.byType(SpaOwnScaffold).last;
      expect(ownScaffold, findsOneWidget);
      expect(ModalRoute.of(tester.element(ownScaffold))!.opaque, isFalse);
      expect(find.widgetWithText(SeedButton, '확인'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
