import 'dart:async';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/screen_pages.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<NavigatorState> _open(
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

Future<void> _visitBrowserHistory(
  WidgetTester tester,
  String path,
  Object? state,
) async {
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': path, 'state': state}),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

// ActivityFontMultiplierLayout.tsx:17-29,109-111:
// A web refresh reloads the document (not just this widget); on a native VM
// there is no window.location and the UI must not pretend to reload the page.
Future<void> _openFontMultiplierLayout(
  WidgetTester tester, {
  double fontScale = 1,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(fontScale),
      ),
      child: const StackflowSpaApp(),
    ),
  );
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .pushNamed('/font-multiplier-layout');
  await tester.pumpAndSettle();
}

// React contracts: ActivityMarginPlayground.tsx:193-201,
// packages/css/breakpoints/index.mjs:9-15,
// ActivityLayerBar.tsx:31-53 + recipes/app-bar-main.layered.css:30-42,
// ActivityTransitionStyle.tsx:57-83, ActivityPullToRefreshTabs.tsx:24-51,
// ActivitySafeAreaBleed.tsx:135-150 and ActivityTransparentBar.tsx:35-102.
Future<void> _openResponsive(
  WidgetTester tester,
  String route, {
  required double width,
  double height = 844,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

Future<NavigatorState> open(WidgetTester tester, String route) async {
  tester.view.physicalSize = const Size(440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pumpAndSettle();
  return navigator;
}

Future<void> _openHome(
  WidgetTester tester, {
  required double width,
  required double height,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: TextScaler.linear(scale),
      ),
      child: const StackflowSpaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _replaceRootRoute(WidgetTester tester, String path) async {
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

// Official ActivityPluginBasicUI.tsx:3,16-35 uses @stackflow/plugin-basic-ui.
// Its CSS has a 2.75rem (44px) Cupertino bar and a 3.5rem (56px) Android bar.
// The plugin's AppBar.tsx:145-151 hides Back on a root activity.
const _route = '/plugin-basic-ui';

Future<void> _mount(WidgetTester tester, {required double width}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
}

Future<void> _openAsRoot(WidgetTester tester) async {
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('pushRouteInformation', {
        'location': _route,
        'state': null,
      }),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

Future<void> _openNested(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(_route);
  await tester.pumpAndSettle();
}

void _checkAppBar(
  WidgetTester tester, {
  required TargetPlatform platform,
  required bool root,
}) {
  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
  expect(scaffold.appBar, isNotNull);
  final height = platform == TargetPlatform.iOS ? 44.0 : 56.0;
  expect(
    scaffold.appBar!.preferredSize.height,
    closeTo(height, .01),
    reason: 'basicUIPlugin AppBar has its own platform-specific height',
  );
  expect(find.text('Random Long Title Hello World'), findsOneWidget);

  if (platform == TargetPlatform.iOS) {
    expect(find.byType(AppBar), findsOneWidget);
    expect(tester.getSize(find.byType(AppBar)).height, closeTo(44, .01));
    expect(find.byTooltip('Back'), root ? findsNothing : findsOneWidget);
    expect(find.byTooltip('Home'), findsOneWidget);
  } else {
    expect(find.byType(SeedTopNavigation), findsOneWidget);
    expect(
      tester.getSize(find.byType(SeedTopNavigation)).height,
      closeTo(56, .01),
    );
    expect(
      find.byIcon(Icons.chevron_left_rounded),
      root ? findsNothing : findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SeedTopNavigationIconButton &&
            widget.semanticsLabel == 'Home',
      ),
      findsOneWidget,
    );
  }
}

Future<void> _tapHome(
  WidgetTester tester, {
  required TargetPlatform platform,
}) async {
  final home = platform == TargetPlatform.iOS
      ? find.byTooltip('Home')
      : find.byWidgetPredicate(
          (widget) =>
              widget is SeedTopNavigationIconButton &&
              widget.semanticsLabel == 'Home',
        );
  await tester.tap(home);
  await tester.pumpAndSettle();
  expect(find.byType(CustomScrollView), findsOneWidget);
  expect(tester.takeException(), isNull);
}

const _categoriesForTest = [
  '전체',
  '디지털기기',
  '생활가전',
  '가구/인테리어',
  '생활/주방',
  '유아동',
  '여성의류',
  '남성패션/잡화',
  '뷰티/미용',
];

// Opens /safe-area-bleed with left 38 / right 24 insets on a 390pt screen.
// RTL wraps the same page in a pushed route with an RTL Directionality.
Future<void> _openSafeAreaBleed(
  WidgetTester tester,
  TextDirection direction,
) async {
  tester.view.padding = const FakeViewPadding(left: 38, right: 24);
  tester.view.viewPadding = tester.view.padding;
  final navigator = await _open(tester, '/safe-area-bleed', 390);
  if (direction == TextDirection.rtl) {
    navigator.push<void>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Directionality(
            textDirection: direction,
            child: buildScreenPage(
              'ActivitySafeAreaBleed',
              context,
              navigate: (_, {arguments}) {},
              goBack: navigator.pop,
            )!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

FocusNode _keyboardReorderNode(WidgetTester tester, Finder item) => tester
    .widget<Focus>(
      find
          .ancestor(
            of: item,
            matching: find.byWidgetPredicate(
              (widget) => widget is Focus && widget.onKeyEvent != null,
            ),
          )
          .first,
    )
    .focusNode!;

// Moves focus with real Tab key presses until [target] has primary focus.
Future<void> _tabUntilFocused(
  WidgetTester tester,
  FocusNode target, {
  int maxTabs = 200,
}) async {
  for (var i = 0; i < maxTabs && !target.hasPrimaryFocus; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
  }
  expect(target.hasPrimaryFocus, isTrue, reason: 'Tab reaches the item');
}

SemanticsNode _hintNode(WidgetTester tester, Finder item) {
  SemanticsNode? node = tester.getSemantics(item);
  while (node != null && node.hint.isEmpty) {
    node = node.parent;
  }
  expect(node, isNotNull, reason: 'item exposes a reorder hint');
  return node!;
}

// Flips the extendSafeAreaX switch at the top of the lazy page, then scrolls
// back to [target].
Future<void> _toggleExtend(
  WidgetTester tester,
  Finder scroll,
  Finder target,
) async {
  final toggle = find.text('extendSafeAreaX');
  await tester.scrollUntilVisible(toggle, -300, scrollable: scroll);
  await tester.pumpAndSettle();
  await tester.tap(toggle);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(target, 220, scrollable: scroll);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

String _semanticsText(SemanticsNode node) {
  final buffer = StringBuffer(node.label);
  node.visitChildren((child) {
    buffer.write(' ${_semanticsText(child)}');
    return true;
  });
  return buffer.toString();
}

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets(
      'article pull has selectable protected origin and separate plain outside $width',
      (tester) async {
        await _open(tester, '/article-prevent-pull', width);
        final protectedText = find.byType(SelectableText);
        expect(protectedText, findsOneWidget);
        expect(
          tester.widget<SelectableText>(protectedText).data,
          contains('Article 내부'),
        );
        expect(find.byType(SeedPullToRefreshPreventPull), findsOneWidget);
        final textOutside = find.textContaining('이 요소는 Article 외부에 있으므로');
        expect(textOutside, findsOneWidget);
        expect(
          tester.widget<Text>(textOutside).data,
          contains('PTR을 호출할 수 있습니다'),
        );
        expect(
          tester
              .widget<SeedPullToRefresh>(find.byType(SeedPullToRefresh))
              .enabled,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'protected Article gesture never arms PTR even when dragged into the outside area $width',
      (tester) async {
        await _open(tester, '/article-prevent-pull', width);
        final origin = tester.getCenter(find.byType(SelectableText));
        final gesture = await tester.startGesture(origin, pointer: 7);
        for (var i = 0; i < 5; i++) {
          await gesture.moveBy(const Offset(0, 36));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'outside Article downward gesture arms PTR and returns to idle $width',
      (tester) async {
        await _open(tester, '/article-prevent-pull', width);
        final outside = find.textContaining('이 요소는 Article 외부에 있으므로');
        final origin = tester.getCenter(outside);
        final gesture = await tester.startGesture(origin, pointer: 8);
        for (var i = 0; i < 7; i++) {
          await gesture.moveBy(const Offset(0, 35));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          1,
        );
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'swipe keyboard retains original draft and loses focus after child Back $width',
      (tester) async {
        final nav = await _open(tester, '/swipe-back-keyboard', width);
        final input = find.byType(TextField);
        expect(input, findsOneWidget);
        final semantics = tester.getSemantics(input);
        expect(semantics.label, contains('검색어'));
        await tester.enterText(input, 'semantic-2026');
        tester.testTextInput.hide();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        expect(find.text('입력 포커스: 없음'), findsOneWidget);
        await tester.tap(find.text('입력 화면 한 장 더 열기'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField, skipOffstage: false), findsNWidgets(2));
        nav.pop();
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
        expect(
          tester.widget<TextField>(input).controller?.text ??
              tester
                  .state<EditableTextState>(find.byType(EditableText))
                  .textEditingValue
                  .text,
          'semantic-2026',
        );
        expect(find.text('입력 포커스: 없음'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'swipe keyboard direct URL same-route PUSH then browser history Back retains parent draft $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
        addTearDown(tester.view.reset);
        final browserEntries = <Map<dynamic, dynamic>>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            if (call.method == 'routeInformationUpdated') {
              browserEntries.add(
                Map<dynamic, dynamic>.from(call.arguments as Map),
              );
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
        await _visitBrowserHistory(tester, '/swipe-back-keyboard', null);
        final input = find.byType(TextField);
        expect(input, findsOneWidget);
        await tester.enterText(input, 'semantic-2026');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('입력 화면 한 장 더 열기'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField, skipOffstage: false), findsNWidgets(2));
        expect(browserEntries.last['uri'], '/swipe-back-keyboard');
        final published = Map<dynamic, dynamic>.from(
          browserEntries.last['state'] as Map,
        );
        final stack = published['seedActivities'] as List;
        expect(stack.length, 2);
        // This is the preceding browser entry's serialized state, immediately
        // before the same-URI PUSH. The prefix identifies the retained parent.
        await _visitBrowserHistory(tester, '/swipe-back-keyboard', {
          'seedActivities': [stack.first],
        });
        expect(find.byType(TextField), findsOneWidget);
        expect(
          tester
              .state<EditableTextState>(find.byType(EditableText))
              .textEditingValue
              .text,
          'semantic-2026',
        );
        expect(find.text('입력 포커스: 없음'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'native Refresh states platform limit, keeps route and rechecks scale',
    (tester) async {
      await _openFontMultiplierLayout(tester);
      expect(find.text('scale: base'), findsOneWidget);
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      final button = find.widgetWithText(SeedButton, '새로고침');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(
        find.text('앱에서는 글꼴 배율 변경이 자동으로 반영됩니다.'),
        findsOneWidget,
        reason:
            'Native cannot perform a browser-document reload; no silent no-op',
      );
      expect(find.text('현재 폰트 배율'), findsOneWidget);
      expect(find.text('scale: base'), findsOneWidget);
      expect(navigator.canPop(), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(390, 844), const Size(800, 800)]) {
    testWidgets('native refresh preserves 2x layout and history at $size', (
      tester,
    ) async {
      await _openFontMultiplierLayout(tester, size: size, fontScale: 2);
      expect(find.text('scale: large'), findsOneWidget);
      final action = find.widgetWithText(SeedButton, '새로고침');
      await tester.scrollUntilVisible(
        action,
        280,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text('scale: large'), findsOneWidget);
      expect(find.text('앱에서는 글꼴 배율 변경이 자동으로 반영됩니다.'), findsOneWidget);
      expect(find.text('Font Multiplier Layout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('safe area sticky footer remains visible at the scroll end', (
    tester,
  ) async {
    await _openResponsive(tester, '/safe-area-bleed', width: 800, height: 600);
    final list = find.byType(ListView).first;
    final footer = find.widgetWithText(SeedButton, '확인');
    final initial = tester.getRect(footer);
    final position = tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        )
        .position;
    expect(position.maxScrollExtent, greaterThan(0));
    // A lazy ListView updates its estimate as the new demo sections lay out.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('safe-area-footer-space')),
      300,
      scrollable: find.descendant(of: list, matching: find.byType(Scrollable)).first,
    );
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(tester.getRect(list).bottom, closeTo(600, 1));
    expect(tester.getRect(footer), initial);
    expect(position.pixels, closeTo(position.maxScrollExtent, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('safe area updates insets and preserves the swiped tab', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(left: 38, right: 24);
    tester.view.viewPadding = tester.view.padding;
    await _openResponsive(tester, '/safe-area-bleed', width: 390, height: 960);
    expect(find.text('safe area: 왼쪽 38px · 오른쪽 24px'), findsOneWidget);
    final tabs = find.byType(SeedTabsView);
    final page = find.descendant(of: tabs, matching: find.byType(PageView));
    expect(tester.getRect(page).left, 0);
    expect(tester.getRect(page).right, 390);
    await tester.drag(page, const Offset(-300, 0));
    await tester.pumpAndSettle();
    final header = find.descendant(of: tabs, matching: find.byType(SeedTabs));
    expect(tester.widget<SeedTabs>(header).selectedIndex, 1);
    expect(tester.getRect(find.text('인기 패널')).left, greaterThanOrEqualTo(38));

    await tester.tap(find.text('extendSafeAreaX'));
    await tester.pumpAndSettle();
    expect(tester.getRect(page).left, 38);
    expect(tester.getRect(page).right, 366);
    expect(tester.widget<SeedTabs>(header).selectedIndex, 1);

    tester.view.physicalSize = const Size(800, 600);
    tester.view.padding = const FakeViewPadding(left: 24, right: 38);
    tester.view.viewPadding = tester.view.padding;
    await tester.pumpAndSettle();
    expect(find.text('safe area: 왼쪽 24px · 오른쪽 38px'), findsOneWidget);
    expect(tester.getRect(page).left, 24);
    expect(tester.getRect(page).right, 762);
    expect(tester.takeException(), isNull);
  });

  for (final direction in TextDirection.values) {
    final ltr = direction == TextDirection.ltr;
    // Asymmetric insets: left 38, right 24 on a 390-wide screen. The page
    // gutter is 16, so content starts at 54 (left) and ends at 350 (right).
    testWidgets('safe area attachment fields keep the gutter in $direction', (
      tester,
    ) async {
      await _openSafeAreaBleed(tester, direction);
      final scroll = find.byType(Scrollable).first;
      for (final dropzone in [false, true]) {
        final current = find.byWidgetPredicate(
          (widget) =>
              widget is SeedAttachmentField && widget.showDropzone == dropzone,
        );
        await tester.scrollUntilVisible(current, 220, scrollable: scroll);
        await tester.ensureVisible(current);
        await tester.pumpAndSettle();
        final label = find.descendant(of: current, matching: find.text('첨부파일'));
        final input = find.descendant(
          of: current,
          matching: find.byType(SeedAttachmentInput),
        );
        final viewport = find.descendant(
          of: input,
          matching: find.byType(CustomScrollView),
        );
        final first = find.descendant(
          of: input,
          matching: find.byKey(const ValueKey('safe-area-file-1')),
        );

        void expectGeometry({required bool extend}) {
          // The field header keeps its own x0_5 (2) inline padding inside
          // the gutter, as the official field header does.
          final labelRect = tester.getRect(label);
          expect(ltr ? labelRect.left : labelRect.right, ltr ? 56 : 348);
          if (dropzone) {
            final rect = tester.getRect(find.byType(SeedAttachmentDropzone));
            expect(rect.left, 54);
            expect(rect.right, 350);
          } else {
            // The trigger tile comes first and starts at the gutter.
            final trigger = find
                .ancestor(
                  of: find.descendant(
                    of: input,
                    matching: find.byIcon(Icons.attach_file),
                  ),
                  matching: find.byType(Container),
                )
                .first;
            final rect = tester.getRect(trigger);
            expect(ltr ? rect.left : rect.right, ltr ? 54 : 350);
          }
          final rect = tester.getRect(viewport);
          expect(rect.left, extend ? 0 : 38);
          expect(rect.right, extend ? 390 : 366);
          if (dropzone) {
            final tile = tester.getRect(first);
            expect(ltr ? tile.left : tile.right, ltr ? 54 : 350);
          }
        }

        expectGeometry(extend: true);
        // Scroll the list to its end; the last item stops at the gutter.
        ScrollPosition listPosition() => tester
            .state<ScrollableState>(
              find.descendant(of: viewport, matching: find.byType(Scrollable)),
            )
            .position;
        var position = listPosition();
        // A lazy list refines its extent as items build, so drag again
        // until the end is reached.
        for (var i = 0; i < 4 && position.pixels < position.maxScrollExtent; i++) {
          await tester.drag(viewport, Offset(ltr ? -2000 : 2000, 0));
          await tester.pumpAndSettle();
        }
        expect(position.pixels, position.maxScrollExtent);
        final lastItem = find.descendant(
          of: input,
          matching: find.byKey(const ValueKey('safe-area-file-8')),
        );
        // The keyed box also holds the gap before the item, on its start
        // side; the end edge is the item's.
        final last = tester.getRect(lastItem);
        expect(ltr ? last.right : last.left, ltr ? 350 : 54);
        await tester.drag(viewport, Offset(ltr ? 2000 : -2000, 0));
        await tester.pumpAndSettle();

        await _toggleExtend(tester, scroll, current);
        expectGeometry(extend: false);
        // The lazy page may rebuild the field while scrolling to the switch.
        position = listPosition();
        for (var i = 0; i < 4 && position.pixels < position.maxScrollExtent; i++) {
          await tester.drag(viewport, Offset(ltr ? -2000 : 2000, 0));
          await tester.pumpAndSettle();
        }
        expect(position.pixels, position.maxScrollExtent);
        final lastOff = tester.getRect(lastItem);
        expect(ltr ? lastOff.right : lastOff.left, ltr ? 350 : 54);
        await _toggleExtend(tester, scroll, current);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('safe area dropzone keyboard reorder stops at $direction inset', (
      tester,
    ) async {
      await _openSafeAreaBleed(tester, direction);
      final semantics = tester.ensureSemantics();
      final scroll = find.byType(Scrollable).first;
      final dropzone = find.byType(SeedAttachmentDropzone);
      await tester.scrollUntilVisible(dropzone, 220, scrollable: scroll);
      await tester.ensureVisible(dropzone);
      await tester.pumpAndSettle();
      final field = find.ancestor(
        of: dropzone,
        matching: find.byType(SeedAttachmentField),
      );
      final input = find.descendant(
        of: field,
        matching: find.byType(SeedAttachmentInput),
      );
      expect(Directionality.of(tester.element(input)), direction);
      final item = find.descendant(
        of: input,
        matching: find.byKey(const ValueKey('safe-area-file-1')),
      );
      final node = _keyboardReorderNode(tester, item);
      await _tabUntilFocused(tester, node);
      final start = SeedLocalizations.label(
        tester.element(item),
        SeedLabel.reorderStartHint,
      );
      expect(_hintNode(tester, item).hint, start);
      expect(_semanticsText(_hintNode(tester, item)), contains('file1.txt'));

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('1 / 8'), findsOneWidget);
      String moving(int position) => SeedLocalizations.label(
        tester.element(item),
        SeedLabel.reorderMovingHint,
      ).replaceAll('{position}', '$position');
      expect(_hintNode(tester, item).hint, moving(1));
      final forward = ltr
          ? LogicalKeyboardKey.arrowRight
          : LogicalKeyboardKey.arrowLeft;
      for (var i = 0; i < 7; i++) {
        await tester.sendKeyEvent(forward);
        await tester.pumpAndSettle();
        final rect = tester.getRect(item);
        expect(rect.left, greaterThanOrEqualTo(37.5));
        expect(rect.right, lessThanOrEqualTo(366.5));
      }
      expect(find.text('8 / 8'), findsOneWidget);
      expect(_hintNode(tester, item).hint, moving(8));
      expect(_semanticsText(_hintNode(tester, item)), contains('file1.txt'));
      // Keyboard reveal uses the insets as scroll padding (CSS
      // scroll-padding), so the moved item stops at the inset boundary.
      final last = tester.getRect(item);
      expect(ltr ? last.right : last.left, ltr ? 366 : 38);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedAttachmentInput>(input).items.last.name,
        'file1.txt',
      );
      expect(node.hasPrimaryFocus, isTrue);
      expect(_hintNode(tester, item).hint, start);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });

    testWidgets('safe area hug and chip tabs respect $direction insets', (
      tester,
    ) async {
      await _openSafeAreaBleed(tester, direction);
      final scroll = find.byType(Scrollable).first;
      SeedTabs tabsAt(int index) => tester.widget<SeedTabs>(
        find.byWidgetPredicate(
          (widget) => widget is SeedTabs && widget.items.length == 9,
        ).at(index),
      );
      final hug = find.byWidgetPredicate(
        (widget) =>
            widget is SeedTabs &&
            widget.items.length == 9 &&
            widget.variant != SeedTabsVariant.chipSolid,
      );
      await tester.scrollUntilVisible(hug, 200, scrollable: scroll);
      await tester.pumpAndSettle();
      final hugList = find.descendant(of: hug, matching: find.byType(Scrollable)).first;
      for (final extend in [true, false]) {
        if (!extend) await _toggleExtend(tester, scroll, hug);
        final listRect = tester.getRect(hugList);
        expect(listRect.left, extend ? 0 : 38);
        expect(listRect.right, extend ? 390 : 366);
        // Select the first tab that is cut by the safe-area end edge,
        // tapping its visible part as a user would.
        final endEdge = ltr ? 366.0 : 38.0;
        Finder? cut;
        for (final label in _categoriesForTest) {
          final finder = find.descendant(of: hug, matching: find.text(label));
          final rect = tester.getRect(finder);
          if (ltr ? rect.right > endEdge : rect.left < endEdge) {
            cut = finder;
            final x = ltr
                ? (rect.left + endEdge) / 2
                : (rect.right + endEdge) / 2;
            await tester.tapAt(Offset(x, rect.center.dy));
            await tester.pumpAndSettle();
            break;
          }
        }
        expect(cut, isNotNull, reason: 'some hug tab overflows the screen');
        final selected = tabsAt(0).selectedIndex;
        expect(selected, greaterThan(0));
        final revealed = tester.getRect(cut!);
        // Revealed inside the safe area, away from the inset boundary.
        expect(revealed.left, greaterThan(38));
        expect(revealed.right, lessThan(366));
        // Back to the first tab before the next pass.
        await tester.drag(hugList, Offset(ltr ? 2000 : -2000, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.descendant(of: hug, matching: find.text('전체')));
        await tester.pumpAndSettle();
      }
      await _toggleExtend(tester, scroll, hug);

      final chips = find.byWidgetPredicate(
        (widget) =>
            widget is SeedTabs && widget.variant == SeedTabsVariant.chipSolid,
      );
      await tester.scrollUntilVisible(chips, 200, scrollable: scroll);
      await tester.pumpAndSettle();
      for (final extend in [true, false]) {
        if (!extend) await _toggleExtend(tester, scroll, chips);
        final chipList = find
            .descendant(of: chips, matching: find.byType(Scrollable))
            .first;
        final listRect = tester.getRect(chipList);
        expect(listRect.left, extend ? 0 : 38);
        expect(listRect.right, extend ? 390 : 366);
        final firstChip = tester.getRect(
          find
              .ancestor(
                of: find.descendant(of: chips, matching: find.text('전체')),
                matching: find.byType(SeedPressable),
              )
              .first,
        );
        // inset + gutter, with the inset applied only once.
        expect(ltr ? firstChip.left : firstChip.right, ltr ? 54 : 350);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('safe area swiped Tabs panel follows the selected tab on toggle', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(left: 38, right: 24);
    tester.view.viewPadding = tester.view.padding;
    await _openResponsive(tester, '/safe-area-bleed', width: 390, height: 960);
    final tabs = find.byType(SeedTabsView);
    final page = find.descendant(of: tabs, matching: find.byType(PageView));
    final header = find.descendant(of: tabs, matching: find.byType(SeedTabs));
    await tester.drag(page, const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<SeedTabs>(header).selectedIndex, 1);

    void expectVisiblePanel(String label) {
      final pageRect = tester.getRect(page);
      for (final tab in ['추천', '인기', '최신']) {
        final panel = find.text('$tab 패널');
        final visible =
            panel.evaluate().isNotEmpty &&
            pageRect.overlaps(tester.getRect(panel));
        expect(visible, tab == label, reason: '$tab panel visibility');
      }
    }

    expectVisiblePanel('인기');
    for (final extend in [false, true, false, true]) {
      await tester.tap(find.text('extendSafeAreaX'));
      await tester.pumpAndSettle();
      expect(tester.widget<SeedTabs>(header).selectedIndex, 1);
      expect(tester.getRect(page).left, extend ? 0 : 38);
      expectVisiblePanel('인기');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('safe area Page Banner and Image Frame respond to taps', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(left: 38, right: 24);
    tester.view.viewPadding = tester.view.padding;
    await _openResponsive(tester, '/safe-area-bleed', width: 390, height: 844);
    final scroll = find.byType(Scrollable).first;
    final banner = find.byType(SeedPageBanner);
    await tester.scrollUntilVisible(banner, 200, scrollable: scroll);
    await tester.pumpAndSettle();
    await tester.tap(banner);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('안내 배너를 눌렀습니다'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    final frame = find.byType(SeedImageFrame);
    await tester.scrollUntilVisible(frame, 200, scrollable: scroll);
    await tester.pumpAndSettle();
    final rect = tester.getRect(frame);
    expect(rect.left, 0);
    expect(rect.right, 390);
    expect(rect.width / rect.height, closeTo(2, 0.01));
    expect(find.byType(SeedImageFrameReactionButton), findsOneWidget);
    expect(find.byType(SeedReactionButton), findsNothing);
    final like = find.descendant(
      of: find.byType(SeedImageFrameReactionButton),
      matching: find.byType(CustomPaint),
    );
    // The heart floater stays inside the safe area.
    expect(tester.getRect(like).right, lessThanOrEqualTo(366));
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(like),
      isSemantics(label: '좋아요', isSelected: false),
    );
    await tester.tap(like);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(like),
      isSemantics(label: '좋아요', isSelected: true),
    );
    await tester.tap(like);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(like),
      isSemantics(label: '좋아요', isSelected: false),
    );
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('safe area route renders in $brightness theme', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.view.padding = const FakeViewPadding(left: 38, right: 24);
      tester.view.viewPadding = tester.view.padding;
      await _openResponsive(tester, '/safe-area-bleed', width: 390);
      final context = tester.element(find.byType(SeedTabsView));
      expect(Theme.of(context).brightness, brightness);
      final scroll = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('safe-area-footer-space')),
        300,
        scrollable: scroll,
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SeedButton, '확인'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('transparent gradient switch controls the content overlay', (
    tester,
  ) async {
    await _openResponsive(tester, '/transparent-bar', width: 390);
    const gradient = ValueKey('transparent-bar-scroll-gradient');
    expect(find.byKey(gradient), findsOneWidget);
    await tester.ensureVisible(find.text('gradient'));
    await tester.tap(find.text('gradient'));
    await tester.pumpAndSettle();
    expect(find.byKey(gradient), findsNothing);
    // A focused control may scroll behind the overlay AppBar; move the
    // scroll content down before the second real pointer interaction.
    await tester.drag(find.byType(ListView).last, const Offset(0, 160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('gradient').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byKey(gradient), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android AppScreen customization keeps explicit Android bar', (
    tester,
  ) async {
    await _openResponsive(
      tester,
      '/app-screen-app-bar-customization',
      width: 800,
    );
    expect(
      tester
          .widget<SeedTopNavigation>(find.byType(SeedTopNavigation).last)
          .platform,
      SeedTopNavigationPlatform.android,
    );
  });
  group('TransparentBar', () {
    setUpAll(() async {
      await (FontLoader('WantedSans')
            ..addFont(rootBundle.load('assets/fonts/WantedSansVariable.ttf')))
          .load();
    });

    testWidgets(
      'transparent bar matches React segmented labels and switch tone',
      (tester) async {
        tester.view.physicalSize = const Size(500, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushNamed('/transparent-bar');
        await tester.pumpAndSettle();

        final segments = find.byType(SeedSegmentedControl<String>);
        expect(segments, findsOneWidget);
        for (final label in ['none', 'safeArea', 'appBar']) {
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(label),
          );
          expect(
            paragraph
                .getBoxesForSelection(
                  TextSelection(baseOffset: 0, extentOffset: label.length),
                )
                .length,
            1,
            reason: label,
          );
        }

        final toggle = find.byType(SeedSwitch);
        expect(tester.widget<SeedSwitch>(toggle).tone, SeedControlTone.neutral);
        expect(tester.widget<SeedSwitch>(toggle).checked, true);
        await tester.ensureVisible(find.text('safeArea'));
        await tester.tap(find.text('safeArea'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedSegmentedControl<String>>(segments).value,
          'safeArea',
        );

        await Scrollable.ensureVisible(
          tester.element(find.text('gradient')),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('gradient'));
        await tester.pumpAndSettle();
        expect(tester.widget<SeedSwitch>(toggle).checked, false);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('LayerBar and swipe back', () {
    testWidgets('LayerBar controls change the actual top navigation slots', (
      tester,
    ) async {
      await open(tester, '/layer-bar');
      final bar = find.byType(SeedTopNavigation).last;
      expect(
        find.descendant(
          of: bar,
          matching: find.byTooltip('Left notification 2'),
        ),
        findsNothing,
      );
      await tester.tap(find.text('Append Left'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: bar,
          matching: find.byTooltip('Left notification 2'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('LayerBar keeps appended icons visible as its title shrinks', (
      tester,
    ) async {
      await open(tester, '/layer-bar');
      tester.view.physicalSize = const Size(1024, 900);
      await tester.pumpAndSettle();

      for (var i = 1; i < 10; i++) {
        await tester.tap(find.text('Append Left'));
        await tester.pump();
      }
      for (var i = 1; i < 3; i++) {
        await tester.tap(find.text('Append Right'));
        await tester.pump();
      }

      final left = find.byTooltip('Left notification 10');
      final right = find.byTooltip('Right notification 3');
      expect(left, findsOneWidget);
      expect(right, findsOneWidget);
      expect(tester.getRect(left).right, lessThan(1024));
      expect(tester.getRect(right).right, lessThan(1024));
      expect(tester.getRect(left).right, lessThan(tester.getRect(right).left));
      expect(tester.takeException(), isNull);
    });

    testWidgets('native swipe back obeys the prevent toggle', (tester) async {
      final navigator = await open(tester, '/action-button');
      navigator.pushNamed(
        '/transition-style',
        arguments: {'transitionStyle': 'slideFromRightIOS'},
      );
      await tester.pumpAndSettle();
      final control = tester.widget<SeedSegmentedControl<bool>>(
        find.byType(SeedSegmentedControl<bool>),
      );
      control.onValueChange!(true);
      await tester.pumpAndSettle();
      await tester.timedDragFrom(
        const Offset(2, 200),
        const Offset(400, 0),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Prevent Swipe Back'), findsOneWidget);
      tester
          .widget<SeedSegmentedControl<bool>>(
            find.byType(SeedSegmentedControl<bool>),
          )
          .onValueChange!(false);
      await tester.pumpAndSettle();
      await tester.timedDragFrom(
        const Offset(2, 200),
        const Offset(400, 0),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Prevent Swipe Back'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('plugin-basic-ui root', () {
    testWidgets('plugin root title stays dark on its light bar in dark mode', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await _openHome(tester, width: 390, height: 844);
      await _replaceRootRoute(tester, '/plugin-basic-ui');
      final title = tester.widget<Text>(
        find.text('Random Long Title Hello World'),
      );
      final color =
          title.style?.color ??
          DefaultTextStyle.of(
            tester.element(find.text('Random Long Title Hello World')),
          ).style.color;
      expect(color, SeedThemeData.light().colorScheme.fg.neutral);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('transparent preview text follows its semantic foreground', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await _open(tester, '/app-screen-transparent', 390);
      final label = find
          .descendant(of: find.byType(Center), matching: find.text('Preview'))
          .last;
      expect(
        tester.widget<Text>(label).style?.color,
        SeedThemeData.dark().colorScheme.fg.onNeutralSolid,
      );
    });

    testWidgets('plugin-basic-ui direct iOS root hides plugin Back action', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await _openHome(tester, width: 390, height: 844);
        await _replaceRootRoute(tester, '/plugin-basic-ui');
        final appBar = find.byType(AppBar);
        expect(appBar, findsOneWidget);
        expect(
          tester
              .widget<Scaffold>(find.byType(Scaffold).last)
              .appBar!
              .preferredSize
              .height,
          44,
        );
        expect(ModalRoute.of(tester.element(appBar))?.isFirst, true);
        expect(find.byTooltip('Back'), findsNothing);
        expect(find.byTooltip('Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });

  group('plugin-basic-ui per platform', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      for (final root in [true, false]) {
        testWidgets(
          '$_route $platform ${root ? 'root' : 'PUSH'} bar height, Back and Home',
          (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            try {
              await _mount(tester, width: 390);
              if (root) {
                await _openAsRoot(tester);
              } else {
                await _openNested(tester);
              }

              final bar = find.byType(Scaffold).last;
              expect(ModalRoute.of(tester.element(bar))?.isFirst, root);
              _checkAppBar(tester, platform: platform, root: root);
              expect(tester.takeException(), isNull);

              await _tapHome(tester, platform: platform);
            } finally {
              debugDefaultTargetPlatformOverride = null;
            }
          },
        );
      }
    }
  });
}
