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
}
