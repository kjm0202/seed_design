import 'dart:async';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:seed_design/seed_design.dart';
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
  final scaffold = tester.widget<mui.Scaffold>(find.byType(mui.Scaffold).last);
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
          find.descendant(of: list, matching: find.byType(Scrollable)),
        )
        .position;
    expect(position.maxScrollExtent, greaterThan(0));
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(tester.getRect(list).bottom, closeTo(600, 1));
    expect(tester.getRect(footer), initial);
    expect(position.pixels, closeTo(position.maxScrollExtent, 1));
    expect(tester.takeException(), isNull);
  });

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
              .widget<mui.Scaffold>(find.byType(mui.Scaffold).last)
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

              final bar = find.byType(mui.Scaffold).last;
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
