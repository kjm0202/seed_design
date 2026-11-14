import 'dart:async';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> _open(
  WidgetTester tester,
  String path, {
  bool direct = false,
  double width = 440,
}) async {
  tester.view.physicalSize = Size(width, 960);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  if (direct && path != '/') {
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
  } else if (!direct) {
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(path);
  }
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('search submits, clears, and opens the registry search bar', (
    tester,
  ) async {
    await _open(tester, '/search-input');
    await tester.enterText(find.byType(EditableText), '동네');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('검색한 값: 동네'), findsOneWidget);

    final clear = find.bySemanticsLabel('지우기');
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      isEmpty,
    );

    await _tapText(tester, 'Search Bar 열기');
    final toolbar = find.ancestor(
      of: find.byType(SeedSearchInput).hitTestable(),
      matching: find.byType(SeedTopNavigation),
    );
    expect(
      find.descendant(of: toolbar, matching: find.byType(SeedSearchInput)),
      findsOneWidget,
    );
    await tester.enterText(find.byType(EditableText), '이웃');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('"이웃" 검색'), findsOneWidget);
    final back = find.descendant(
      of: toolbar,
      matching: find.byType(SeedTopNavigationIconButton),
    );
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('Search Bar 열기'), findsOneWidget);
    await _tapText(tester, 'Search Bar 열기');
    await _tapText(tester, '닫기');
    expect(find.text('Search Bar 열기'), findsOneWidget);
  });

  testWidgets('root search bar clears, dismisses focus, and closes in place', (
    tester,
  ) async {
    await _open(tester, '/search-bar', direct: true, width: 320);
    final editor = find.byType(EditableText);
    expect(ModalRoute.of(tester.element(editor))?.isFirst, isTrue);
    final toolbar = find.ancestor(
      of: editor,
      matching: find.byType(SeedTopNavigation),
    );
    expect(
      find.descendant(
        of: toolbar,
        matching: find.byType(SeedTopNavigationIconButton),
      ),
      findsNothing,
    );
    await tester.enterText(editor, '동네');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('지우기'));
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(editor);
    expect(editable.controller.text, isEmpty);
    expect(editable.focusNode.hasFocus, isTrue);
    await tester.tapAt(const Offset(20, 350));
    await tester.pumpAndSettle();
    expect(editable.focusNode.hasFocus, isFalse);
    await _tapText(tester, '닫기');
    expect(find.text('닫기를 눌렀습니다'), findsOneWidget);
    expect(editor, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('root search bar submit shows the official result text', (
    tester,
  ) async {
    await _open(tester, '/search-bar', direct: true);
    final editor = find.byType(EditableText);
    expect(ModalRoute.of(tester.element(editor))?.isFirst, isTrue);
    expect(find.text('검색어를 입력하고 검색해주세요'), findsOneWidget);
    await tester.tap(editor);
    await tester.pumpAndSettle();
    await tester.enterText(editor, '당근');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('"당근" 검색'), findsOneWidget);
    expect(find.text('검색어를 입력하고 검색해주세요'), findsNothing);
    expect(ModalRoute.of(tester.element(editor))?.isFirst, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search bar close from Home pops exactly one screen', (
    tester,
  ) async {
    await _open(tester, '/', direct: true);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
    // Home -> Search Bar -> close returns to Home.
    await _tapText(tester, 'Search Bar');
    expect(find.byType(SeedSearchInput), findsOneWidget);
    expect(navigator.canPop(), isTrue);
    await _tapText(tester, '닫기');
    expect(find.byType(SeedSearchInput), findsNothing);
    expect(find.text('Search Bar'), findsOneWidget);
    expect(navigator.canPop(), isFalse);

    // Under a deeper stack, close still pops only the Search Bar.
    navigator.pushNamed('/safe-area-bleed');
    await tester.pumpAndSettle();
    navigator.pushNamed('/search-bar');
    await tester.pumpAndSettle();
    expect(find.byType(SeedSearchInput), findsOneWidget);
    await _tapText(tester, '닫기');
    expect(find.byType(SeedSearchInput), findsNothing);
    expect(find.text('좌우 safe area와 bleed'), findsWidgets);
    expect(find.byType(SeedTabsView), findsOneWidget);
    expect(navigator.canPop(), isTrue, reason: 'the safe-area page remains');
    expect(tester.takeException(), isNull);
  });

  testWidgets('home lists Search Bar right after the transparent App Bar', (
    tester,
  ) async {
    await _open(tester, '/', direct: true);
    final order = [
      'App Bar 슬롯과 긴 제목',
      '투명 App Bar',
      'Search Bar',
      '좌우 safe area와 bleed',
    ];
    final tops = [
      for (final title in order) tester.getTopLeft(find.text(title)).dy,
    ];
    for (var i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThan(tops[i - 1]), reason: order[i]);
    }
    // Search Bar directly follows the transparent App Bar.
    final rowHeight = tops[3] - tops[2];
    expect(tops[2] - tops[1], closeTo(rowHeight, 0.5));
  });

  testWidgets('home opens both new AppScreen demos', (tester) async {
    await _open(tester, '/', direct: true);
    await _tapText(tester, 'Search Bar');
    expect(find.byType(SeedSearchInput), findsOneWidget);
    await _tapText(tester, '닫기');
    await _tapText(tester, 'App Bar 텍스트 버튼');
    expect(find.text('작성하기'), findsOneWidget);
    expect(find.text('마지막 액션: 없음'), findsOneWidget);
    await _tapText(tester, '취소');
    expect(find.text('마지막 액션: 취소'), findsOneWidget);
    await _tapText(tester, '완료');
    expect(find.text('마지막 액션: 완료'), findsOneWidget);
  });

  testWidgets('segmented number previews advance and toggle registry formats', (
    tester,
  ) async {
    await _open(tester, '/segmented-text-input');
    final fields = find.byType(SeedSegmentedTextInput);
    List<SeedSegmentedTextInputSegment> segments(int index) => tester
        .widget<SeedSegmentedTextInput>(fields.at(index))
        .children
        .whereType<SeedSegmentedTextInputSegment>()
        .toList();
    expect(segments(0).map((part) => part.length), [4, 4, 4, 4]);
    expect(segments(0).map((part) => part.masked), [false, true, true, false]);
    final editors = find.byType(EditableText);
    await tester.enterText(editors.first, '1234');
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(editors.at(1)).focusNode.hasFocus,
      isTrue,
    );
    await _tapText(tester, '공식 카드 조합 보기');
    expect(segments(0).map((part) => part.masked), [false, false, true, true]);
    expect(segments(1).map((part) => part.length), [6, 1]);
    expect(
      (segments(1).last.staticSuffix as SeedSegmentedTextInputDots).count,
      6,
    );
    await _tapText(tester, '6자리');
    expect(find.byType(EditableText), findsNWidgets(5));
    await _tapText(tester, '13자리');
    expect(segments(1).last.length, 7);
    expect(segments(1).last.masked, isTrue);
  });

  testWidgets('standalone menu and collapsed sidebar select items', (
    tester,
  ) async {
    await _open(tester, '/navigation-menu');
    await _tapText(tester, '작업');
    await _tapText(tester, '작업 내역');
    expect(find.text('선택: 작업 내역'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('워크스페이스'));
    await tester.pumpAndSettle();
    await _tapText(tester, '팀 목록');
    expect(find.text('선택: 팀 목록'), findsOneWidget);
  });

  testWidgets('two-week calendar crosses the year and retains selection', (
    tester,
  ) async {
    await _open(tester, '/date-picker-two-weeks');
    expect(find.text('2026년 12월'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    await _tapText(tester, '30');
    await tester.tap(find.byTooltip('다음 2주'));
    await tester.pumpAndSettle();
    expect(find.text('2027년 1월'), findsOneWidget);
    expect(find.text('30'), findsNothing);
    expect(find.text('선택: 2026-12-30'), findsOneWidget);
    await tester.tap(find.byTooltip('이전 2주'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 12월'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('선택: 2026-12-30'), findsOneWidget);
  });

  testWidgets('two-week selected day cell stays selected after moving back', (
    tester,
  ) async {
    await _open(tester, '/date-picker-two-weeks');
    final semantics = tester.ensureSemantics();
    await _tapText(tester, '30');
    expect(tester.getSemantics(find.text('30')), isSemantics(isSelected: true));
    expect(
      tester.getSemantics(find.text('29')),
      isNot(isSemantics(isSelected: true)),
    );
    await tester.tap(find.byTooltip('다음 2주'));
    await tester.pumpAndSettle();
    expect(find.text('30'), findsNothing);
    await tester.tap(find.byTooltip('이전 2주'));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.text('30')), isSemantics(isSelected: true));
    expect(
      tester.getSemantics(find.text('29')),
      isNot(isSemantics(isSelected: true)),
    );
    expect(find.text('선택: 2026-12-30'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('two-week route respects reduced motion during a view change', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _open(tester, '/date-picker-two-weeks');
    await tester.tap(find.byTooltip('다음 2주'));
    await tester.pump();
    final day = find.text('12');
    final enteringCenter = tester.getCenter(day);
    await tester.pumpAndSettle();
    expect(tester.getCenter(day), enteringCenter);
    expect(find.text('2027년 1월'), findsOneWidget);
  });

  testWidgets('text width, loading layout, and static text scale', (
    tester,
  ) async {
    await _open(tester, '/text-and-loading');
    final width = tester.getSize(find.byType(SeedConsistentWidth)).width;
    await _tapText(tester, '굵기 전환');
    expect(tester.getSize(find.byType(SeedConsistentWidth)).width, width);

    final indicator = find.byType(SeedLoadingIndicator);
    final size = tester.getSize(indicator);
    await tester.tap(find.text('로딩 시작'));
    await tester.pump();
    expect(find.byType(SeedProgressCircle), findsOneWidget);
    expect(tester.getSize(indicator), size);
    await _tapText(tester, '로딩 종료');
    expect(find.byType(SeedProgressCircle), findsNothing);

    await _tapText(tester, '글자 배율 전환');
    double fontSize(String label) =>
        MediaQuery.textScalerOf(tester.element(find.text(label))).scale(20);
    expect(fontSize('시스템 배율 적용'), 36);
    expect(fontSize('고정 타이포그래피'), 20);
  });

  testWidgets('safe-area toggle changes scroll viewport and tabs work', (
    tester,
  ) async {
    await _open(tester, '/extend-safe-area-x');
    final tabs = find.byType(SeedTabs);
    final viewport = find.descendant(
      of: tabs,
      matching: find.byType(Scrollable),
    );
    final extended = tester.getRect(viewport);
    await _tapText(tester, '가로 확장 끄기');
    expect(tester.getRect(viewport).left - extended.left, 36);
    expect(extended.right - tester.getRect(viewport).right, 24);
    await _tapText(tester, '탭 2');
    expect(tester.widget<SeedTabs>(tabs).selectedIndex, 1);
    await _tapText(tester, '가로 확장 켜기');
    expect(tester.getRect(viewport), extended);
  });

  testWidgets('accordion slots expand and fieldset clears its error', (
    tester,
  ) async {
    await _open(tester, '/accordion-fieldset');
    expect(find.text('자세한 안내'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    final content = find.text('배송 예정일은 주문 화면에서 확인할 수 있습니다.');
    expect(content.hitTestable(), findsNothing);
    await _tapText(tester, '배송 정보와 일정');
    expect(content.hitTestable(), findsOneWidget);
    expect(find.text('연락처를 확인해 주세요.'), findsOneWidget);
    await _tapText(tester, '오류 지우기');
    expect(find.text('연락처를 확인해 주세요.'), findsNothing);
  });

  group('web follows the official theme.ts UA rule', () {
    // Flutter web reports iOS for a "Mac*" navigator.platform with more than
    // two touch points (a Mac browser emulating a phone). The official SPA
    // only looks at the userAgent.
    for (final (name, ua, enginePlatform) in [
      ('Android UA on a touch-emulating Mac', _androidUa, TargetPlatform.iOS),
      ('desktop Mac UA', _macUa, TargetPlatform.macOS),
    ]) {
      testWidgets('$name left-aligns the title after the left slot', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = enginePlatform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await _openWithUa(tester, '/app-bar-text-button', ua);
        final cancel = tester.getRect(find.text('취소'));
        final done = tester.getRect(find.text('완료'));
        final title = tester.getRect(find.text('작성하기'));
        // Official android: "취소" at x=16, title at x=59.7 (16px
        // AppBarLeft padding-right minus the -10px button margin), "완료"
        // ends at 374.
        expect(cancel.left, closeTo(16, 0.01));
        expect(title.left, closeTo(cancel.right + 16, 0.01));
        expect(done.right, closeTo(374, 0.01));
        expect(
          Theme.of(tester.element(find.text('작성하기'))).platform,
          TargetPlatform.android,
        );
        debugDefaultTargetPlatformOverride = null;
      });
    }

    testWidgets('iPhone UA centers the title', (tester) async {
      await _openWithUa(tester, '/app-bar-text-button', _iphoneUa);
      expect(tester.getCenter(find.text('작성하기')).dx, closeTo(195, 0.5));
    });
  });

  group('search bar matches the official search-bar.tsx overrides', () {
    Finder closeButton() => find.ancestor(
      of: find.text('닫기'),
      matching: find.byType(SeedTopNavigationTextButton),
    );

    testWidgets('root: input 16..close button, label ends at 374', (
      tester,
    ) async {
      await _open(tester, '/search-bar', direct: true, width: 390);
      final input = tester.getRect(find.byType(SeedSearchInput));
      final close = tester.getRect(closeButton());
      expect(input.left, closeTo(16, 0.01));
      expect(input.right, closeTo(close.left, 0.01));
      expect(close.right, closeTo(384, 0.01));
      expect(tester.getRect(find.text('닫기')).right, closeTo(374, 0.01));
    });

    testWidgets('pushed: input starts at the back button touch area', (
      tester,
    ) async {
      await _open(tester, '/search-bar', width: 390);
      final input = tester.getRect(find.byType(SeedSearchInput));
      final back = tester.getRect(
        find.byType(SeedTopNavigationIconButton).last,
      );
      expect(back.left, closeTo(6, 0.01));
      expect(input.left, closeTo(back.right, 0.01));
      expect(input.left, closeTo(50, 0.01));
    });
  });
}

const _androidUa =
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/130.0 Mobile Safari/537.36';
const _macUa =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/130.0 Safari/537.36';
const _iphoneUa =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148';

Future<void> _openWithUa(
  WidgetTester tester,
  String path,
  String userAgent,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    StackflowSpaApp(debugBrowserUserAgentOverride: userAgent),
  );
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(path);
  await tester.pumpAndSettle();
}
