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
}
