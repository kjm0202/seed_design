import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

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
}
