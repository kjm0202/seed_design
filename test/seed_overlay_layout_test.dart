import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/official_spec.dart';
import 'support/seed_test_fonts.dart';

Future<void> mount(
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

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets(
    'popover uses actual dimensions and global anchor coordinates within safe areas',
    (tester) async {
      addTearDown(tester.view.reset);
      const triggerKey = ValueKey('popover-trigger');
      const contentKey = ValueKey('popover-content');
      for (final (screen, padding, anchorOffset, contentSize) in [
        (
          const Size(390, 844),
          const EdgeInsets.only(top: 59, bottom: 34),
          const Offset(20, 150),
          const Size(320, 120),
        ),
        (
          const Size(390, 844),
          const EdgeInsets.only(top: 59, bottom: 34),
          const Offset(240, 650),
          const Size(320, 180),
        ),
        (
          const Size(900, 700),
          const EdgeInsets.only(left: 18, right: 74, top: 24),
          const Offset(700, 200),
          const Size(480, 260),
        ),
        (
          const Size(320, 700),
          const EdgeInsets.only(top: 44, bottom: 24),
          const Offset(20, 300),
          const Size(480, 450),
        ),
      ]) {
        await mount(
          tester,
          Builder(
            builder: (context) => Stack(
              children: [
                Positioned(
                  left: anchorOffset.dx,
                  top: anchorOffset.dy,
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: TextButton(
                      key: triggerKey,
                      onPressed: () {
                        final box = tester.renderObject<RenderBox>(
                          find.byKey(triggerKey),
                        );
                        showSeedPopover<void>(
                          context: context,
                          anchorRect: box.localToGlobal(Offset.zero) & box.size,
                          builder: (_) => SizedBox(
                            key: contentKey,
                            width: contentSize.width,
                            height: contentSize.height,
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          size: screen,
          padding: padding,
        );
        final anchor = tester.getRect(find.byKey(triggerKey));
        await tester.tap(find.byKey(triggerKey));
        await tester.pumpAndSettle();
        final popup = tester.getRect(find.byKey(contentKey));
        final safeBounds = Rect.fromLTRB(
          padding.left + 16,
          padding.top + 16,
          screen.width - padding.right - 16,
          screen.height - padding.bottom - 16,
        );
        final below = safeBounds.bottom - anchor.bottom - 8;
        final above = anchor.top - safeBounds.top - 8;
        if (popup.height <= below || below >= above) {
          expect(popup.top - anchor.bottom, closeTo(8, 0.01));
        } else {
          expect(anchor.top - popup.bottom, closeTo(8, 0.01));
        }
        expect(popup.left, greaterThanOrEqualTo(safeBounds.left));
        expect(popup.right, lessThanOrEqualTo(safeBounds.right));
        expect(popup.top, greaterThanOrEqualTo(safeBounds.top));
        expect(popup.bottom, lessThanOrEqualTo(safeBounds.bottom));
        expect(
          popup.center.dx,
          closeTo(
            anchor.center.dx.clamp(
              safeBounds.left + popup.width / 2,
              safeBounds.right - popup.width / 2,
            ),
            0.01,
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byKey(contentKey), findsNothing);
      }
    },
  );

  testWidgets('alert titles wrap naturally inside the official 272px surface', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    for (final scale in [1.0, 2.0]) {
      await mount(
        tester,
        const SeedAlertDialog(
          title: '알림 설정을 저장하시겠습니까?',
          description: '설정하신 키워드에 대한 푸시 알림이 즉시 활성화됩니다.',
        ),
        scale: scale,
      );
      final title = find.text('알림 설정을 저장하시겠습니까?');
      expect(tester.getSize(title).width, 272 - 2 * 20);
      expect(tester.getSize(title).height, greaterThan(SeedLineHeight.t7));
      final paragraph = tester.renderObject<RenderParagraph>(title);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('menu sheet stays centered within safe areas on wide devices', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    for (final size in [const Size(390, 800), const Size(900, 700)]) {
      const padding = EdgeInsets.only(left: 18, right: 74, bottom: 24);
      await mount(
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

  testWidgets('long menu groups scroll while the cancel action stays visible', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await mount(
      tester,
      SeedMenuSheet(
        title: '메뉴',
        groups: [
          SeedMenuGroupData(
            items: List.generate(30, (i) => SeedMenuItemData(label: '항목 $i')),
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
  });

  testWidgets('side panel uses official default width and header geometry', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    for (final size in [const Size(390, 800), const Size(1400, 900)]) {
      await mount(
        tester,
        Align(
          alignment: Alignment.centerRight,
          child: SeedSidePanel(
            title: '상세 정보',
            body: const Text('본문'),
            onClose: () {},
          ),
        ),
        size: size,
      );
      final panel = tester.getRect(find.byType(SeedSidePanel));
      expect(panel.width, (size.width * 0.8).clamp(0, 720));
      expect(panel.right, size.width);
      final title = tester.getRect(find.text('상세 정보'));
      expect(title.top - panel.top, 24);
      expect(title.left - panel.left, 24);
      expect(tester.getTopLeft(find.text('본문')).dy, 70);
      final closeIcon = tester.getRect(find.byIcon(Icons.close));
      expect(closeIcon.size, const Size(22, 22));
      expect(closeIcon.top, 28);
      expect(panel.right - closeIcon.right, 24);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('side panel shows a divider only after scrolling its body', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    for (final dark in [false, true]) {
      await mount(
        tester,
        SeedSidePanel(
          key: ValueKey(dark),
          title: '상세 정보',
          body: Column(children: List.generate(40, (i) => Text('본문 $i'))),
          footer: const Text('고정 액션'),
          onClose: () {},
        ),
        dark: dark,
      );
      final divider = find.byKey(
        const ValueKey('seed-side-panel-scroll-divider'),
      );
      expect(
        (tester.widget<AnimatedContainer>(divider).decoration as BoxDecoration)
            .color,
        Colors.transparent,
      );
      expect(tester.getSize(find.byType(SeedScrollFog)).height, 48);
      final footer = tester.getRect(find.text('고정 액션'));
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(
        (tester.widget<AnimatedContainer>(divider).decoration as BoxDecoration)
            .color,
        officialColor(r'$color.stroke.neutral-muted', dark: dark),
      );
      expect(tester.getRect(find.text('고정 액션')), footer);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'side panel routes slide by their own width and honor safe areas',
    (tester) async {
      addTearDown(tester.view.reset);
      const size = Size(1400, 900);
      const padding = EdgeInsets.fromLTRB(30, 20, 70, 24);
      for (final fromRight in [false, true]) {
        await mount(
          tester,
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showSeedSidePanel<void>(
                context: context,
                title: '안전 영역',
                body: const Text('본문'),
                fromRight: fromRight,
              ),
              child: const Text('Open'),
            ),
          ),
          size: size,
          padding: padding,
        );
        await tester.tap(find.text('Open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        final panel = find.byType(SeedSidePanel);
        final slide = tester.widget<SlideTransition>(
          find.ancestor(of: panel, matching: find.byType(SlideTransition)),
        );
        final bounds = tester.getRect(panel);
        final edgeInset = fromRight ? padding.right : padding.left;
        expect(bounds.width, 720 + edgeInset);
        final restingLeft = fromRight ? size.width - bounds.width : 0;
        expect(
          bounds.left,
          closeTo(restingLeft + slide.position.value.dx * bounds.width, 0.01),
        );
        await tester.pumpAndSettle();
        final title = tester.getRect(find.text('안전 영역'));
        expect(title.top, 24 + padding.top);
        final close = tester.getRect(find.byIcon(Icons.close));
        expect(close.top, 28 + padding.top);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(panel, findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
