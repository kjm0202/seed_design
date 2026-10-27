import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets(
    'a section inside a screen gutter can use the available text width',
    (tester) async {
      const title = '주변에 등록된 매물이 없습니다';
      const description = '동네 범위를 넓혀서 검색하거나 키워드 알림을 설정해보세요.';
      const sectionKey = Key('result');
      final seed = SeedThemeData.light(fontFamily: seedTestFontFamily);

      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final width in [360.0, 400.0]) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 640);
        await tester.pumpWidget(
          MaterialApp(
            theme: seed.toThemeData(),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(SeedDimension.x4),
                child: SeedResultSection(
                  key: sectionKey,
                  padding: EdgeInsets.symmetric(vertical: SeedDimension.x4),
                  title: title,
                  description: description,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final text = find.text(title);
        // Real Korean glyphs must fit one line when the screen has enough width.
        expect(
          tester.getSize(text).height,
          closeTo(SeedLineHeight.t8, 0.01),
          reason: 'viewport $width',
        );
        expect(tester.getRect(text).left, greaterThanOrEqualTo(16));
        expect(tester.getRect(text).right, lessThanOrEqualTo(width - 16));
        expect(tester.takeException(), isNull);
      }
    },
  );
}
