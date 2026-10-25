import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/main.dart';
import 'package:seed_design_example/tabs/components_tab.dart';
import 'package:seed_design_example/tabs/navigation_tab.dart';

import '../../test/support/seed_test_fonts.dart';

const _captureImages = bool.fromEnvironment('CAPTURE_SHOWCASE');
const _captureKey = ValueKey<String>('showcase-capture-root');

void _assertNoOverflow(WidgetTester tester) {
  final exception = tester.takeException();
  if (exception != null) {
    if (exception is FlutterError) {
      // Keep diagnostics for the exact RenderFlex and parent chain.
      // ignore: avoid_print
      print(exception.toStringDeep());
    }
    fail('$exception');
  }
}

void _setViewport(WidgetTester tester, double width, {double height = 800}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
}

Future<void> _mount(WidgetTester tester) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: SeedDesignCatalogApp(key: UniqueKey()),
    ),
  );
  await tester.pumpAndSettle();
  _assertNoOverflow(tester);
}

Future<void> _show(WidgetTester tester, Finder target) async {
  expect(target, findsWidgets);
  await tester.ensureVisible(target.first);
  await tester.pumpAndSettle();
  _assertNoOverflow(tester);
}

Future<void> _snapshot(WidgetTester tester, String name) async {
  if (!_captureImages) return;
  await tester.pump();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('Screenshot encoding failed: $name');
      final file = File('../screenshots/showcase-audit/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

void main() {
  setUpAll(() async {
    await loadSeedTestFonts(fontDirectory: '../test/assets/fonts');
    // The test engine has no installed host CJK fonts. Register the bundled
    // Korean test font under the theme/system fallback families for legible
    // screenshots, without changing the production catalog's ThemeData.
    final bytes = await File('../test/assets/fonts/WantedSansVariable.ttf')
        .readAsBytes();
    for (final family in ['Pretendard', 'Roboto']) {
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  });

  testWidgets('form inputs use the official large default across viewports', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final width in [320.0, 390.0, 1024.0]) {
      for (final scale in [1.0, 2.0]) {
        _setViewport(tester, width, height: 900);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await _mount(tester);
        await tester.tap(find.text('입력 & 피커'));
        await tester.pumpAndSettle();
        _assertNoOverflow(tester);
        for (final field in tester.widgetList<SeedTextInput>(
          find.byType(SeedTextInput),
        )) {
          expect(field.size, SeedTextInputSize.large);
        }
        expect(
          tester.getSize(find.byType(SeedTextInput).first).height,
          greaterThanOrEqualTo(52),
        );
        if (width == 390) {
          await _snapshot(tester, 'inputs-large-390-scale-${scale.toInt()}');
        }
      }
    }
  });

  testWidgets(
    'scroll fog keeps endpoint cards clear and readable in both themes',
    (tester) async {
      _setViewport(tester, 390, height: 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final dark in [false, true]) {
        await _mount(tester);
        await tester.tap(find.text('입력 & 피커'));
        await tester.pumpAndSettle();
        final list = find.byWidgetPredicate(
          (widget) =>
              widget is ListView && widget.scrollDirection == Axis.horizontal,
        );
        await _show(tester, list);
        if (dark) {
          await tester.tap(find.byIcon(Icons.dark_mode_rounded));
          await tester.pumpAndSettle();
        }
        final viewport = tester.getRect(list);
        final colors = dark
            ? SeedThemeData.dark().colorScheme
            : SeedThemeData.light().colorScheme;
        Finder card(String label) => find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first;
        void expectReadable(String label) {
          final text = tester.widget<Text>(find.text(label));
          final background =
              (tester.widget<Container>(card(label)).decoration
                      as BoxDecoration)
                  .color!;
          expect(text.style!.color, colors.fg.neutral);
          expect(background, colors.bg.layerDefault);
          final luminances = [
            text.style!.color!.computeLuminance(),
            background.computeLuminance(),
          ]..sort();
          expect(
            (luminances.last + 0.05) / (luminances.first + 0.05),
            greaterThanOrEqualTo(4.5),
          );
        }

        expect(
          tester.getRect(card('Item 0')).left - viewport.left,
          closeTo(20, 0.01),
        );
        expectReadable('Item 0');
        final fogs = find.byWidgetPredicate(
          (widget) =>
              widget is SeedScrollFog &&
              (widget.placement == SeedScrollFogPlacement.left ||
                  widget.placement == SeedScrollFogPlacement.right),
        );
        expect(fogs, findsNWidgets(2));
        for (final fog in tester.widgetList<SeedScrollFog>(fogs)) {
          expect(fog.color, colors.bg.layerBasement);
        }
        await _snapshot(tester, 'scroll-fog-start-${dark ? 'dark' : 'light'}');
        final scroll = tester.state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)),
        );
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(
          viewport.right - tester.getRect(card('Item 19')).right,
          closeTo(20, 0.01),
        );
        expectReadable('Item 19');
        expect(fogs, findsNWidgets(2));
        _assertNoOverflow(tester);
        await _snapshot(tester, 'scroll-fog-end-${dark ? 'dark' : 'light'}');
      }
    },
  );

  testWidgets('new buttons toggle separately and select box values change', (
    tester,
  ) async {
    _setViewport(tester, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _mount(tester);
    expect(find.byType(ComponentsTab), findsOneWidget);
    expect(find.text('관심 설정'), findsNothing);
    expect(find.text('Action Button'), findsOneWidget);
    expect(find.text('Text Button'), findsOneWidget);
    expect(find.text('Toggle Button'), findsOneWidget);
    await _snapshot(tester, 'components-action-buttons-360-light');
    await _show(tester, find.text('Toggle Button'));
    expect(find.byType(SeedTextButton), findsOneWidget);
    expect(find.byType(SeedToggleButton), findsNWidgets(3));
    await _snapshot(tester, 'components-buttons-360-light');
    await _show(tester, find.text('이용 안내'));
    await _snapshot(tester, 'components-text-button-360-light');
    await tester.tap(find.text('이용 안내'));
    await tester.pump();
    expect(find.text('이용 안내를 확인했어요'), findsOneWidget);
    // The snackbar lasts four seconds. Let the notification and its exit
    // animation complete before capturing the selection cards.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('이용 안내를 확인했어요'), findsNothing);

    await _show(tester, find.text('키워드 알림 켜짐'));
    await tester.tap(find.text('키워드 알림 켜짐'));
    await tester.pumpAndSettle();
    expect(find.text('키워드 알림 꺼짐'), findsOneWidget);
    expect(find.text('동네 소식 꺼짐'), findsOneWidget);
    await _show(tester, find.text('동네 소식 꺼짐'));
    await tester.tap(find.text('동네 소식 꺼짐'));
    await tester.pumpAndSettle();
    expect(find.text('동네 소식 켜짐'), findsOneWidget);
    expect(find.text('키워드 알림 꺼짐'), findsOneWidget);

    await _show(tester, find.text('직거래 희망'));
    final group = find.byType(SeedSelectBoxGroup);
    expect(group, findsOneWidget);
    final choice = find
        .descendant(of: group, matching: find.byType(SeedSelectBox))
        .last;
    expect(tester.widget<SeedSelectBox>(choice).selected, isFalse);
    await tester.tap(find.text('직거래 희망'));
    await tester.pumpAndSettle();
    expect(tester.widget<SeedSelectBox>(choice).selected, isTrue);
    await Scrollable.ensureVisible(
      tester.element(group),
      alignment: 0.2,
      duration: Duration.zero,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
    await tester.pumpAndSettle();
    final cards = tester.getRect(group);
    expect(cards.top, greaterThanOrEqualTo(56));
    expect(cards.bottom, lessThanOrEqualTo(744));
    await _snapshot(tester, 'components-selection-360-light');
    expect(tester.takeException(), isNull);
  });

  testWidgets('real header actions and contextual avatar stack are reachable', (
    tester,
  ) async {
    _setViewport(tester, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _mount(tester);
    await tester.tap(find.text('탐색 & 레이아웃'));
    await tester.pumpAndSettle();
    await _show(tester, find.text('상단 내비게이션'));
    final demoHeader = find.descendant(
      of: find.byType(NavigationTab),
      matching: find.byType(SeedTopNavigation),
    );
    expect(demoHeader, findsOneWidget);
    expect(
      find.descendant(
        of: demoHeader,
        matching: find.byType(SeedTopNavigationIconButton),
      ),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: demoHeader,
        matching: find.byType(SeedTopNavigationTextButton),
      ),
      findsOneWidget,
    );
    await _snapshot(tester, 'navigation-header-360-light');
    final share = find.bySemanticsLabel('모임 공유하기');
    await tester.tap(share);
    await tester.pump();
    expect(find.text('모임 링크를 공유할 수 있어요'), findsOneWidget);
    await tester.tap(find.text('완료'));
    await tester.pump();
    expect(find.text('모임 설정을 저장했어요'), findsOneWidget);

    await _show(tester, find.text('주말 러닝 모임'));
    expect(find.byType(SeedAvatarStack), findsOneWidget);
    expect(find.text('참여 이웃 5명'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
    await _show(tester, find.text('아바타와 참여자'));
    await _snapshot(tester, 'navigation-avatars-360-light');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'popover opens only from its trigger and closes via both actions',
    (tester) async {
      _setViewport(tester, 360);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _mount(tester);
      await tester.tap(find.text('오버레이'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedPopover), findsNothing);
      await _show(tester, find.text('키워드 알림이란?'));
      await _snapshot(tester, 'overlays-trigger-360-light');
      await tester.tap(find.text('키워드 알림이란?'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedPopover), findsOneWidget);
      expect(find.text('찾고 있는 물건을 놓치지 마세요'), findsOneWidget);
      final rect = tester.getRect(find.byType(SeedPopover));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(360));
      await _snapshot(tester, 'overlays-popover-360-light');
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(find.byType(SeedPopover), findsNothing);

      await tester.tap(find.text('키워드 알림이란?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedPopover), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mobile and wide catalog supports representative sections', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 1024.0]) {
      _setViewport(tester, width);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _mount(tester);
      await _show(tester, find.text('Toggle Button'));
      expect(tester.takeException(), isNull, reason: 'buttons width=$width');
      await tester.tap(find.text('탐색 & 레이아웃'));
      await tester.pumpAndSettle();
      await _show(tester, find.text('모임 설정'));
      await _show(tester, find.text('주말 러닝 모임'));
      expect(tester.takeException(), isNull, reason: 'navigation width=$width');
      await _show(tester, find.text('아바타와 참여자'));
      if (width == 320) {
        await _snapshot(tester, 'navigation-avatars-320-light');
      }
      if (width == 1024) {
        await _snapshot(tester, 'navigation-avatars-1024-light');
      }
      await tester.tap(find.text('오버레이'));
      await tester.pumpAndSettle();
      await _show(tester, find.text('키워드 알림이란?'));
      await tester.tap(find.text('키워드 알림이란?'));
      await tester.pumpAndSettle();
      final popup = tester.getRect(find.byType(SeedPopover));
      expect(popup.left, greaterThanOrEqualTo(0));
      expect(popup.right, lessThanOrEqualTo(width));
      expect(popup.width, lessThanOrEqualTo(480));
      if (width == 320) {
        await _snapshot(tester, 'overlays-popover-320-light');
      }
      if (width == 1024) {
        await _snapshot(tester, 'overlays-popover-1024-light');
      }
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'popover width=$width');
    }
  });

  testWidgets('dark mode and 200% text keep entry points usable', (
    tester,
  ) async {
    _setViewport(tester, 390, height: 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _mount(tester);
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    await _show(tester, find.text('Toggle Button'));
    await _snapshot(tester, 'components-buttons-390-dark-200pct');
    await tester.tap(find.text('탐색 & 레이아웃'));
    await tester.pumpAndSettle();
    await _show(tester, find.text('모임 설정'));
    await _snapshot(tester, 'navigation-header-390-dark-200pct');
    await _show(tester, find.text('주말 러닝 모임'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('오버레이'));
    await tester.pumpAndSettle();
    await _show(tester, find.text('키워드 알림이란?'));
    await tester.tap(find.text('키워드 알림이란?'));
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byType(SeedPopover));
    expect(rect.right, lessThanOrEqualTo(390));
    await _snapshot(tester, 'overlays-popover-390-dark-200pct');
    expect(tester.takeException(), isNull);
  });
}
