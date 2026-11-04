import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Finder get surface => find.descendant(
  of: find.byType(SeedBottomSheet),
  matching: find.byWidgetPredicate(
    (widget) => widget is Material && widget.clipBehavior == Clip.antiAlias,
  ),
);

Finder get closeButton => find.descendant(
  of: find.byType(SeedBottomSheet),
  matching: find.byWidgetPredicate(
    (widget) => widget is SeedPressable && widget.semanticsLabel == '닫기',
  ),
);

Finder get handle => find.descendant(
  of: find.byType(SeedBottomSheet),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is AnimatedContainer && widget.constraints?.maxWidth == 36,
  ),
);

Future<void> mount(
  WidgetTester tester,
  SeedBottomSheet sheet, {
  Size size = const Size(360, 800),
  EdgeInsets padding = EdgeInsets.zero,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final seed = SeedThemeData.light(fontFamily: seedTestFontFamily);
  await tester.pumpWidget(
    MaterialApp(
      supportedLocales: const [Locale('en'), Locale('ko')],
      locale: const Locale('ko'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: seed.toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          padding: padding,
          viewPadding: padding,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: KeyedSubtree(key: UniqueKey(), child: sheet),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openSheet(
  WidgetTester tester, {
  Widget? sheet,
  bool isDismissible = true,
  bool enableDrag = true,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      supportedLocales: const [Locale('en'), Locale('ko')],
      locale: const Locale('ko'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSeedBottomSheet<void>(
              context: context,
              isDismissible: isDismissible,
              enableDrag: enableDrag,
              child:
                  sheet ??
                  const SeedBottomSheet(
                    title: '제목',
                    content: SizedBox(height: 200),
                  ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

// React bottom-sheet.css:28-45 sets max-height 90%; :64-86 the title and
// description keep their font tokens; :88-130 body alone scrolls ordinarily
// and footer remains a separate fixed region.
const _description =
    'md 이상에서는 Side Panel, sm 이하에서는 Bottom Sheet로 표시됩니다. '
    '뷰포트를 줄여서 자동 전환을 확인해보세요.';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget host(Widget child, {double scale = 1, bool dark = false}) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme:
      (dark
              ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
              : SeedThemeData.light(fontFamily: seedTestFontFamily))
          .toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

Future<void> frames(WidgetTester tester, {int count = 400}) async {
  await tester.pump();
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
}

Future<void> openSheetComponentAccessibilityOv(
  WidgetTester tester,
  SeedSheetController controller,
  List<int> changes, {
  List<double> points = const [.75, .25, .75],
  bool handleOnly = false,
}) async {
  await tester.pumpWidget(
    host(
      SeedBottomSheetTrigger(
        snapController: controller,
        snapPoints: [
          for (final point in points) SeedSheetSnapPoint.fraction(point),
        ],
        onSnapChanged: changes.add,
        handleOnly: handleOnly,
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => const SeedBottomSheet(
          title: 'Sheet',
          showHandle: true,
          content: SizedBox(height: 1000, child: Text('Scroll body')),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Finder get sheetHandle => find
    .descendant(
      of: find.byType(SeedSnappingBottomSheet),
      matching: find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onTap != null,
      ),
    )
    .first;

Widget hostInteractionParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

Future<void> mountOverlayLayout(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(900, 700),
  EdgeInsets padding = EdgeInsets.zero,
  bool dark = false,
  double scale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final theme = dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      supportedLocales: const [Locale('en'), Locale('ko')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: theme.toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: padding,
          viewPadding: padding,
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

final menuGroups = [
  SeedMenuGroupData(
    items: [
      SeedMenuItemData(
        label: '끌어올리기',
        prefixIcon: const Icon(Icons.arrow_upward),
      ),
      SeedMenuItemData(
        label: '숨기기',
        prefixIcon: const Icon(Icons.visibility_off),
      ),
      SeedMenuItemData(label: '삭제하기', isDestructive: true),
    ],
  ),
];

Widget hostOverlayAuditRegression(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('width, height and insets follow the available safe area', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    for (final (size, padding) in [
      (const Size(360, 800), const EdgeInsets.only(top: 40, bottom: 34)),
      (const Size(1024, 800), const EdgeInsets.fromLTRB(50, 0, 100, 34)),
      (const Size(360, 800), const EdgeInsets.only(top: 150)),
    ]) {
      await mount(
        tester,
        const SeedBottomSheet(
          title: '제목',
          content: SizedBox(height: 1500),
          footer: SizedBox(key: Key('footer'), height: 52),
        ),
        size: size,
        padding: padding,
      );
      final rect = tester.getRect(surface);
      final availableWidth = size.width - padding.horizontal;
      final expectedWidth = availableWidth < 480 ? availableWidth : 480.0;
      final availableHeight = size.height - padding.top;
      final expectedHeight = availableHeight < size.height * .9
          ? availableHeight
          : size.height * .9;
      expect(rect.width, expectedWidth);
      expect(rect.left, padding.left + (availableWidth - expectedWidth) / 2);
      expect(rect.height, expectedHeight);
      expect(rect.bottom, size.height);
      expect(
        rect.bottom - tester.getRect(find.byKey(const Key('footer'))).bottom,
        16 + padding.bottom,
      );
      final material = tester.widget<Material>(surface);
      expect(
        material.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(24)),
      );
      expect(
        material.color,
        SeedThemeData.light().colorScheme.bg.layerFloating,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('only the body scrolls and the fog clears at its bottom', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    for (final width in [320.0, 480.0]) {
      for (final scale in [1.0, 2.0]) {
        await mount(
          tester,
          const SeedBottomSheet(
            title: '긴 제목도 줄바꿈하여 표시해요',
            description: '설명은 제목과 구분해서 표시해요.',
            showHandle: true,
            content: SizedBox(
              height: 1600,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Last'),
              ),
            ),
            footer: SizedBox(key: Key('footer'), height: 52),
          ),
          size: Size(width, 800),
          textScale: scale,
        );
        final titleBefore = tester.getRect(find.text('긴 제목도 줄바꿈하여 표시해요'));
        final footerBefore = tester.getRect(find.byKey(const Key('footer')));
        expect(find.byType(SeedScrollFog), findsOneWidget);
        final scroll = tester.widget<SingleChildScrollView>(
          find.descendant(
            of: find.byType(SeedBottomSheet),
            matching: find.byType(SingleChildScrollView),
          ),
        );
        scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(find.byType(SeedScrollFog), findsNothing);
        expect(tester.getRect(find.text('긴 제목도 줄바꿈하여 표시해요')), titleBefore);
        expect(tester.getRect(find.byKey(const Key('footer'))), footerBefore);
        expect(
          tester.getRect(find.text('Last')).bottom,
          lessThanOrEqualTo(footerBefore.top),
        );
        expect(tester.takeException(), isNull);
      }
    }
    await mount(
      tester,
      const SeedBottomSheet(title: '제목', content: Text('Short')),
    );
    expect(find.byType(SeedScrollFog), findsNothing);
  });

  testWidgets('route keeps the sheet above the keyboard with fixed actions', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    await openSheet(
      tester,
      sheet: const SeedBottomSheet(
        title: '입력',
        content: SizedBox(height: 1000, child: TextField()),
        footer: SizedBox(key: Key('footer'), height: 52),
      ),
    );
    expect(tester.getRect(surface).height, 720);
    expect(
      tester.getRect(surface).bottom -
          tester.getRect(find.byKey(const Key('footer'))).bottom,
      50,
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    tester.view.padding = const FakeViewPadding(top: 44);
    await tester.pumpAndSettle();
    final rect = tester.getRect(surface);
    expect(rect.bottom, 480);
    expect(rect.top, greaterThanOrEqualTo(44));
    expect(
      rect.bottom - tester.getRect(find.byKey(const Key('footer'))).bottom,
      16,
    );
    expect(find.byType(SeedScrollFog), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.viewInsets = const FakeViewPadding();
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.viewPadding = const FakeViewPadding(
      left: 50,
      top: 150,
      right: 100,
      bottom: 34,
    );
    tester.view.padding = const FakeViewPadding(
      left: 50,
      top: 150,
      right: 100,
      bottom: 34,
    );
    await tester.pumpAndSettle();
    final wide = tester.getRect(surface);
    expect(wide.width, 480);
    expect(wide.left, 247);
    expect(wide.top, 150);
    expect(wide.bottom, 800);
    expect(tester.takeException(), isNull);
  });

  testWidgets('close, outside tap, escape and drag honor dismissal options', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    for (final method in ['close', 'outside', 'escape', 'drag']) {
      await openSheet(tester);
      switch (method) {
        case 'close':
          await tester.tap(closeButton);
        case 'outside':
          await tester.tapAt(const Offset(180, 100));
        case 'escape':
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        case 'drag':
          await tester.fling(find.text('제목'), const Offset(0, 400), 1200);
      }
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsNothing, reason: method);
      expect(tester.takeException(), isNull);
    }
    await openSheet(tester, isDismissible: false, enableDrag: false);
    await tester.tapAt(const Offset(180, 100));
    await tester.fling(find.text('제목'), const Offset(0, 400), 1200);
    await tester.pumpAndSettle();
    expect(find.byType(SeedBottomSheet), findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(find.byType(SeedBottomSheet), findsNothing);
  });

  testWidgets('custom close callback overrides default route dismissal', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    var closeRequests = 0;
    await openSheet(
      tester,
      sheet: SeedBottomSheet(
        title: 'Keep open',
        content: const SizedBox(height: 100),
        onClosePressed: () => closeRequests++,
      ),
    );
    final route = ModalRoute.of(tester.element(find.byType(SeedBottomSheet)));
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(closeRequests, 1);
    expect(find.byType(SeedBottomSheet), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(SeedBottomSheet))),
      same(route),
    );
  });

  testWidgets('route uses SEED transition timing and React snippet defaults', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await openSheet(tester);
    final route =
        ModalRoute.of(tester.element(find.byType(SeedBottomSheet)))!
            as ModalBottomSheetRoute<void>;
    expect(route.transitionDuration, SeedDuration.d6);
    expect(route.reverseTransitionDuration, SeedDuration.d4);
    expect(route.sheetAnimationStyle!.curve, SeedCurves.enterExpressive);
    expect(
      route.sheetAnimationStyle!.reverseCurve!.transform(.4),
      SeedCurves.exit.flipped.transform(.4),
    );
    expect(route.barrierCurve.transform(.4), SeedCurves.enter.transform(.4));
    expect(route.barrierColor, SeedThemeData.light().colorScheme.bg.overlay);
    expect(handle, findsNothing);
    expect(closeButton, findsOneWidget);
    Navigator.of(tester.element(find.byType(SeedBottomSheet))).pop();
    await tester.pump();
    expect(
      route.barrierCurve.transform(.4),
      SeedCurves.exit.flipped.transform(.4),
    );
    await tester.pumpAndSettle();
    await openSheet(tester, disableAnimations: true);
    final reducedRoute = ModalRoute.of(
      tester.element(find.byType(SeedBottomSheet)),
    )!;
    expect(reducedRoute.transitionDuration, Duration.zero);
    expect(reducedRoute.reverseTransitionDuration, Duration.zero);
  });

  testWidgets('bottom and custom headers retain independent close controls', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await mount(
      tester,
      const SeedBottomSheet(
        title: '아래 제목',
        description: '아래 설명',
        headerPosition: SeedBottomSheetHeaderPosition.bottom,
        headerAlign: SeedBottomSheetHeaderAlign.center,
        showCloseButton: false,
        contentPadding: EdgeInsets.zero,
        content: SizedBox(key: Key('body'), height: 120),
        footer: SizedBox(key: Key('footer'), height: 52),
      ),
    );
    final body = tester.getRect(find.byKey(const Key('body')));
    final rect = tester.getRect(surface);
    expect(body.top, rect.top);
    expect(body.width, rect.width);
    expect(tester.getRect(find.text('아래 제목')).top - body.bottom, 24);
    expect(
      tester.getRect(find.byKey(const Key('footer'))).top -
          tester.getRect(find.text('아래 설명')).bottom,
      28,
    );
    expect(closeButton, findsNothing);

    await mount(
      tester,
      const SeedBottomSheet(
        header: SizedBox(key: Key('custom-header'), height: 100),
        content: SizedBox(height: 80),
        showHandle: true,
      ),
    );
    expect(
      tester.getRect(find.byKey(const Key('custom-header'))).top,
      tester.getRect(surface).top,
    );
    expect(closeButton, findsOneWidget);
    expect(handle, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  group('compact screens and large text', () {
    for (final width in [320.0, 390.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'compact sheet description fully accessible with fixed footer '
          '$width × $scale',
          (tester) async {
            tester.view.physicalSize = Size(width, 700);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(
              MaterialApp(
                theme: SeedThemeData.light().toThemeData(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, 700),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SeedBottomSheet(
                      title: 'Responsive Side Panel',
                      description: _description,
                      showHandle: false,
                      content: const Text('Small / Medium / Large'),
                      footer: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SeedButton(label: '닫기', onPressed: () {}),
                          const SizedBox(height: 8),
                          SeedButton(label: '확인', onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.text(_description), findsOneWidget);
            expect(find.text('Responsive Side Panel'), findsOneWidget);
            final sheet = tester.getRect(find.byType(SeedBottomSheet));
            expect(sheet.height, lessThanOrEqualTo(630.1));
            final footer = tester.getRect(
              find.widgetWithText(SeedButton, '닫기'),
            );
            expect(footer.bottom, lessThanOrEqualTo(sheet.bottom + .1));
            expect(footer.top, greaterThanOrEqualTo(sheet.top));
            final headerScroll = find.ancestor(
              of: find.text(_description),
              matching: find.byType(CustomScrollView),
            );
            expect(headerScroll, findsOneWidget);
            final headerPosition = tester
                .state<ScrollableState>(
                  find
                      .descendant(
                        of: headerScroll,
                        matching: find.byType(Scrollable),
                      )
                      .first,
                )
                .position;
            if (scale == 2) {
              expect(headerPosition.maxScrollExtent, greaterThan(0));
              final stableFooter = tester.getRect(
                find.widgetWithText(SeedButton, '닫기'),
              );
              headerPosition.jumpTo(headerPosition.maxScrollExtent);
              await tester.pumpAndSettle();
              expect(
                headerPosition.pixels,
                closeTo(headerPosition.maxScrollExtent, .1),
              );
              expect(
                tester.getRect(find.widgetWithText(SeedButton, '닫기')),
                stableFooter,
              );
            } else {
              expect(headerPosition.maxScrollExtent, 0);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    for (final scale in [2.5, 3.0]) {
      testWidgets(
        '320x568 at scale $scale: oversized footer and complete header '
        'stay reachable with a readable body viewport',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: const Size(320, 568),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SeedBottomSheet(
                    title: 'Responsive Side Panel',
                    description: _description,
                    content: const Text('내용은 여기에서도 읽을 수 있습니다.'),
                    footer: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 24; i++) Text('긴 고정 푸터 설명 $i'),
                        SeedButton(label: '마지막 동작', onPressed: () {}),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(_description), findsOneWidget);
          expect(find.text('내용은 여기에서도 읽을 수 있습니다.'), findsOneWidget);
          expect(find.text('마지막 동작'), findsOneWidget);
          final rect = tester.getRect(find.byType(SeedBottomSheet));
          expect(rect.height, lessThanOrEqualTo(568 * .9 + .1));
          final body = find.descendant(
            of: find.byType(SeedBottomSheet),
            matching: find.byType(SingleChildScrollView),
          );
          expect(body, findsOneWidget);
          final bodyPosition = tester
              .state<ScrollableState>(
                find.descendant(of: body, matching: find.byType(Scrollable)),
              )
              .position;
          expect(bodyPosition.viewportDimension, greaterThan(0));
          final footerScroll = find.ancestor(
            of: find.text('마지막 동작'),
            matching: find.byType(CustomScrollView),
          );
          expect(footerScroll, findsOneWidget);
          final footerPosition = tester
              .state<ScrollableState>(
                find
                    .descendant(
                      of: footerScroll,
                      matching: find.byType(Scrollable),
                    )
                    .first,
              )
              .position;
          expect(footerPosition.maxScrollExtent, greaterThan(0));
          footerPosition.jumpTo(footerPosition.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(
            find.widgetWithText(SeedButton, '마지막 동작').hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
  group('drag dismissal', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('return animation tolerates a pending sheet layout', (
      tester,
    ) async {
      await openSheet(tester);
      final sheet = find.byType(SeedBottomSheet);
      final initialTop = tester.getTopLeft(surface).dy;
      final route = ModalRoute.of(tester.element(sheet))!;
      final initialAlpha = route.barrierColor!.a;

      await tester.timedDrag(
        find.text('제목'),
        const Offset(0, 60),
        const Duration(milliseconds: 500),
      );
      await tester.pump();
      expect(tester.getTopLeft(surface).dy, greaterThan(initialTop));
      expect(route.barrierColor!.a, lessThan(initialAlpha));

      // Reproduce a layout invalidation before the next animation tick.
      tester.renderObject<RenderBox>(sheet).markNeedsLayout();
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();

      expect(sheet, findsOneWidget);
      expect(tester.getTopLeft(surface).dy, closeTo(initialTop, .001));
      expect(route.barrierColor!.a, closeTo(initialAlpha, .001));
    });

    testWidgets('a bottom sheet closes past 25% and returns below it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => SeedButton(
              label: 'Open',
              onPressed: () => showSeedBottomSheet<void>(
                context: context,
                child: const SeedBottomSheet(
                  title: 'Title',
                  content: SizedBox(height: 400),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final height = tester.getSize(find.byType(SeedBottomSheet)).height;
      await tester.drag(find.text('Title'), Offset(0, height * .2 + 20));
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      await tester.drag(find.text('Title'), Offset(0, height * .3 + 20));
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsNothing);
    });

    testWidgets('drag progress and dismissal use the resized sheet height', (
      tester,
    ) async {
      final height = ValueNotifier(400.0);
      addTearDown(height.dispose);
      const contentKey = Key('resizable-sheet');
      await openSheet(
        tester,
        sheet: ValueListenableBuilder<double>(
          valueListenable: height,
          builder: (_, value, _) => SizedBox(
            key: contentKey,
            width: 300,
            height: value,
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      );
      final content = find.byKey(contentKey);
      final route = ModalRoute.of(tester.element(content))!;
      final initialAlpha = route.barrierColor!.a;
      height.value = 160;
      await tester.pumpAndSettle();
      final initialTop = tester.getTopLeft(content).dy;

      final gesture = await tester.startGesture(tester.getCenter(content));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 250));
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump(const Duration(milliseconds: 250));
      final distance = tester.getTopLeft(content).dy - initialTop;
      expect(distance, greaterThanOrEqualTo(160 * .25));
      expect(distance, lessThan(400 * .25));
      expect(
        route.barrierColor!.a,
        closeTo(initialAlpha * (1 - distance / 160), .001),
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(content, findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
  group('snap drag', () {
    testWidgets('a collapsed snap sheet expands again by its handle and body', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final snap = SeedSheetController(initialIndex: 1);
      addTearDown(snap.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedBottomSheetTrigger(
              snapController: snap,
              snapPoints: const [
                SeedSheetSnapPoint.fraction(.2),
                SeedSheetSnapPoint.fraction(.5),
                SeedSheetSnapPoint.fraction(.9),
              ],
              triggerBuilder: (_, open, toggle) => TextButton(
                onPressed: toggle,
                child: const Text('Open sheet'),
              ),
              builder: (_) => SeedBottomSheet(
                title: 'Sheet title',
                showHandle: true,
                content: Column(
                  children: List.generate(
                    20,
                    (i) => SeedListItem(titleText: 'Item $i'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      final handle = find.descendant(
        of: find.byType(SeedSnappingBottomSheet),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is GestureDetector && widget.onVerticalDragUpdate != null,
        ),
      );
      DraggableScrollableController drag() => tester
          .widget<DraggableScrollableSheet>(
            find.byType(DraggableScrollableSheet),
          )
          .controller!;
      expect(drag().size, closeTo(.5, .01));
      await tester.drag(handle, const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(drag().size, closeTo(.2, .01));
      await tester.drag(handle, const Offset(0, -280));
      await tester.pumpAndSettle();
      expect(drag().size, greaterThan(.4));
      await tester.drag(handle, const Offset(0, 220));
      await tester.pumpAndSettle();
      expect(drag().size, closeTo(.2, .01));
      final body = find.descendant(
        of: find.byType(SeedSnappingBottomSheet),
        matching: find.byType(SingleChildScrollView),
      );
      await tester.drag(body, const Offset(0, -280));
      await tester.pumpAndSettle();
      expect(drag().size, greaterThan(.4));
      expect(tester.takeException(), isNull);
    });
  });

  group('snap points, MenuSheet and keyboard', () {
    setUpAll(loadSeedTestFonts);

    for (final size in [const Size(800, 800), const Size(390, 844)]) {
      testWidgets('90vh snap point and default fade at $size', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        final snap = SeedSheetController();
        addTearDown(snap.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSeedBottomSheet<void>(
                    context: context,
                    skipAnimation: true,
                    snapPoints: const [
                      SeedSheetSnapPoint.fraction(.5),
                      SeedSheetSnapPoint.fraction(.85),
                    ],
                    snapController: snap,
                    child: const SeedBottomSheet(
                      title: 'React capped sheet',
                      content: SizedBox(height: 1200),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.pump();
        final material = find.descendant(
          of: find.byType(SeedBottomSheet),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material && widget.clipBehavior == Clip.antiAlias,
          ),
        );
        final route =
            ModalRoute.of(tester.element(material))! as ModalBottomSheetRoute;
        final baseAlpha = SeedThemeData.light().colorScheme.bg.overlay.a;
        final first = tester.getRect(material);
        expect(first.top, closeTo(size.height * .6, 1.5));
        expect(first.height, closeTo(size.height * .4, 1.5));
        expect(first.width, closeTo(math.min(size.width, 480), 1));
        expect(route.barrierColor.a, closeTo(0, .0001));

        snap.snapTo(1);
        await tester.pumpAndSettle();
        await tester.pump();
        final last = tester.getRect(material);
        expect(last.top, closeTo(size.height * .25, 1.5));
        expect(last.height, closeTo(size.height * .75, 1.5));
        expect(route.barrierColor.a, closeTo(baseAlpha, .0001));
        expect(snap.index, 1);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('MenuSheet retains group-local label alignment', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedMenuSheet<void>(
                  context: context,
                  title: 'Actions',
                  showHandle: false,
                  showCancelButton: false,
                  groupLabelAlignments: const [
                    TextAlign.start,
                    TextAlign.center,
                  ],
                  groups: const [
                    SeedMenuGroupData(items: [SeedMenuItemData(label: 'Add')]),
                    SeedMenuGroupData(
                      items: [SeedMenuItemData(label: 'Test1')],
                    ),
                  ],
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Add')).textAlign, TextAlign.start);
      expect(
        tester.widget<Text>(find.text('Test1')).textAlign,
        TextAlign.center,
      );
      expect(find.text('닫기'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    for (final configuration in <(bool, bool, double)>[
      (false, true, 600),
      (false, false, 800),
      (true, true, 800),
      (true, false, 800),
    ]) {
      final (fixed, repositionInputs, expectedBottom) = configuration;
      testWidgets('Keyboard inset fixed=$fixed reposition=$repositionInputs', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(440, 800);
        tester.view.viewInsets = const FakeViewPadding(bottom: 200);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSeedBottomSheet<void>(
                    context: context,
                    fixed: fixed,
                    repositionInputs: repositionInputs,
                    skipAnimation: true,
                    child: const SeedBottomSheet(
                      title: 'Keyboard layout',
                      content: SizedBox(height: 200),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final surface = find.descendant(
          of: find.byType(SeedBottomSheet),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material && widget.clipBehavior == Clip.antiAlias,
          ),
        );
        expect(tester.getRect(surface).bottom, closeTo(expectedBottom, 1));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('snap points on resize', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'pixel snap points re-resolve on resize at 390x844 → 800x800 → 390x844',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        final snap = SeedSheetController();
        addTearDown(snap.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: SeedSnappingBottomSheet(
                handleOnly: true,
                contentHeightFraction: .9,
                controller: snap,
                snapPoints: const [
                  SeedSheetSnapPoint.pixels(360),
                  SeedSheetSnapPoint.fraction(.85),
                ],
                sheet: const SeedBottomSheet(
                  title: 'Resize snap',
                  content: SizedBox(height: 1200),
                ),
              ),
            ),
          ),
        );
        final surface = find.descendant(
          of: find.byType(SeedSnappingBottomSheet),
          matching: find.byType(AnimatedContainer),
        );

        await tester.pumpAndSettle();
        // The React max-height=90vh surface exposes 360px - 10vh at a pixel snap.
        expect(tester.getSize(surface).height, closeTo(360 - 84.4, 1));
        tester.view.physicalSize = const Size(800, 800);
        await tester.pumpAndSettle();
        expect(tester.getSize(surface).height, closeTo(360 - 80, 1));

        snap.snapTo(1);
        await tester.pumpAndSettle();
        expect(snap.index, 1);
        expect(tester.getSize(surface).height, closeTo(800 * .75, 1));
        tester.view.physicalSize = const Size(390, 844);
        await tester.pumpAndSettle();
        expect(tester.getSize(surface).height, closeTo(844 * .75, 1));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('drag-enabled modal preserves physical pixel snap on resize', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final snap = SeedSheetController();
      addTearDown(snap.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedBottomSheet<void>(
                  context: context,
                  skipAnimation: true,
                  snapController: snap,
                  snapPoints: const [
                    SeedSheetSnapPoint.pixels(360),
                    SeedSheetSnapPoint.fraction(.85),
                  ],
                  child: const SeedBottomSheet(
                    title: 'Pixel snap',
                    content: SizedBox(height: 1200),
                  ),
                ),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      DraggableScrollableController drag() => tester
          .widget<DraggableScrollableSheet>(
            find.byType(DraggableScrollableSheet),
          )
          .controller!;
      expect(drag().size, closeTo(360 / 844 - .1, .005));
      tester.view.physicalSize = const Size(800, 800);
      await tester.pumpAndSettle();
      expect(drag().size, closeTo(360 / 800 - .1, .005));
      expect(snap.index, 0);
      expect(tester.takeException(), isNull);
    });

    for (final size in [const Size(390, 844), const Size(800, 800)]) {
      for (final swipeable in [false, true]) {
        testWidgets('MenuSheet drawer=$swipeable top spacing at $size', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showSeedMenuSheet<void>(
                      context: context,
                      title: 'Actions',
                      enableDrag: swipeable,
                      showHandle: false,
                      showCancelButton: false,
                      groups: const [
                        SeedMenuGroupData(
                          items: [SeedMenuItemData(label: 'Add')],
                        ),
                      ],
                    ),
                    child: const Text('Open menu'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open menu'));
          await tester.pumpAndSettle();
          final root = find
              .descendant(
                of: find.byType(SeedMenuSheet),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Material &&
                      widget.clipBehavior == Clip.antiAlias &&
                      widget.borderRadius is BorderRadius,
                ),
              )
              .first;
          expect(
            tester.getTopLeft(find.text('Actions')).dy -
                tester.getTopLeft(root).dy,
            closeTo(swipeable ? 24 : 16, .5),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('snap controller', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('sheet keeps requested duplicate index throughout animation', (
      tester,
    ) async {
      final controller = SeedSheetController();
      final changes = <int>[];
      await openSheetComponentAccessibilityOv(tester, controller, changes);
      controller.snapTo(1);
      await frames(tester);
      expect(changes, [1]);
      changes.clear();
      controller.snapTo(2);
      await frames(tester);
      expect(changes, [2]);
      expect(controller.index, 2);
      expect(
        tester
            .widget<DraggableScrollableSheet>(
              find.byType(DraggableScrollableSheet),
            )
            .controller!
            .size,
        closeTo(.75, .001),
      );
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });

    testWidgets('superseded snaps do not emit intermediate indices', (
      tester,
    ) async {
      final controller = SeedSheetController();
      final changes = <int>[];
      await openSheetComponentAccessibilityOv(
        tester,
        controller,
        changes,
        points: const [.25, .5, .75],
      );
      controller.snapTo(2);
      await frames(tester, count: 25);
      controller.snapTo(1);
      await frames(tester);
      expect(changes, [2, 1]);
      expect(controller.index, 1);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });

    for (final handleOnly in [false, true]) {
      testWidgets(
        'sheet handle and drag synchronize controller ($handleOnly)',
        (tester) async {
          final controller = SeedSheetController();
          final changes = <int>[];
          await openSheetComponentAccessibilityOv(
            tester,
            controller,
            changes,
            points: const [.25, .75],
            handleOnly: handleOnly,
          );
          await tester.tap(sheetHandle);
          await tester.pumpAndSettle();
          expect(changes, [1]);
          expect(controller.index, 1);
          await tester.drag(sheetHandle, const Offset(0, 260));
          await tester.pumpAndSettle();
          expect(controller.index, 0);
          expect(changes.last, 0);
          await tester.pumpWidget(const SizedBox());
          controller.dispose();
        },
      );
    }

    testWidgets(
      'sheet body drag reports only the final snap and synchronizes controller',
      (tester) async {
        final controller = SeedSheetController();
        final changes = <int>[];
        await openSheetComponentAccessibilityOv(
          tester,
          controller,
          changes,
          points: const [.25, .5, .75],
        );
        final sheet = tester.getRect(find.byType(DraggableScrollableSheet));
        await tester.dragFrom(
          Offset(sheet.center.dx, sheet.bottom - 30),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        expect(controller.index, 2);
        expect(changes, [2]);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );

    testWidgets(
      'sheet trigger exposes independent outside and Escape policies',
      (tester) async {
        await tester.pumpWidget(
          host(
            SeedBottomSheetTrigger(
              closeOnInteractOutside: false,
              closeOnEscape: true,
              triggerBuilder: (_, _, toggle) =>
                  TextButton(onPressed: toggle, child: const Text('Open')),
              builder: (_) =>
                  const SeedBottomSheet(content: Text('Sheet body')),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(find.text('Sheet body'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Sheet body'), findsNothing);
      },
    );
  });

  group('programmatic snap', () {
    testWidgets(
      'sheet supports min and max programmatic snap without overflow',
      (tester) async {
        final controller = SeedSheetController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          hostInteractionParity(
            SeedSnappingBottomSheet(
              controller: controller,
              sheet: SeedBottomSheet(
                title: 'A sheet title',
                description: 'Some description',
                footer: const Text('Footer'),
                content: Column(
                  children: List.generate(30, (i) => Text('Line $i')),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        controller.snapTo(0);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        controller.snapTo(2);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('MenuSheet layout', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('menu sheet stays centered within safe areas on wide devices', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      for (final size in [const Size(390, 800), const Size(900, 700)]) {
        const padding = EdgeInsets.only(left: 18, right: 74, bottom: 24);
        await mountOverlayLayout(
          tester,
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showSeedMenuSheet<void>(
                context: context,
                title: '게시글 추가 옵션',
                groups: menuGroups,
              ),
              child: const Text('Open'),
            ),
          ),
          size: size,
          padding: padding,
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final sheet = tester.getRect(find.byType(SeedMenuSheet));
        final material = find.descendant(
          of: find.byType(SeedMenuSheet),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Material &&
                w.borderRadius ==
                    const BorderRadius.vertical(top: Radius.circular(20)),
          ),
        );
        final surface = tester.getRect(material);
        expect(surface.width, (size.width - 92).clamp(0, 480));
        expect(surface.center.dx, (18 + size.width - 74) / 2);
        final close = tester.getRect(find.text('닫기'));
        expect(close.center.dx, surface.center.dx);
        final group = tester.getRect(
          find.descendant(
            of: find.byType(SeedMenuSheet),
            matching: find.byWidgetPredicate(
              (w) => w is Material && w.borderRadius == SeedBorderRadius.r4,
            ),
          ),
        );
        expect(group.left - surface.left, 16);
        expect(surface.right - group.right, 16);
        expect(sheet.bottom, lessThanOrEqualTo(size.height));
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('닫기'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets(
      'long menu groups scroll while the cancel action stays visible',
      (tester) async {
        addTearDown(tester.view.reset);
        await mountOverlayLayout(
          tester,
          SeedMenuSheet(
            title: '메뉴',
            groups: [
              SeedMenuGroupData(
                items: List.generate(
                  30,
                  (i) => SeedMenuItemData(label: '항목 $i'),
                ),
              ),
            ],
          ),
          size: const Size(390, 480),
          scale: 2,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('닫기').hitTestable(), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('항목 29'),
          250,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('항목 29').hitTestable(), findsOneWidget);
        expect(find.text('닫기').hitTestable(), findsOneWidget);
      },
    );
  });
}
