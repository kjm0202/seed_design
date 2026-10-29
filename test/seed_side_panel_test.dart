import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final viewport in [390.0, 800.0, 1024.0, 1440.0]) {
    for (final size in SeedSidePanelSize.values) {
      testWidgets('PACKAGE-03 $viewport ${size.name} respects 80% cap', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(viewport, 800);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Align(
              alignment: Alignment.centerRight,
              child: SeedSidePanel(
                title: 'Panel',
                size: size,
                body: const Text('Content'),
              ),
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(SeedSidePanel)).width,
          closeTo(math.min(size.width, viewport * .8), .01),
        );
        expect(tester.getRect(find.byType(SeedSidePanel)).right, viewport);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final fromRight in [true, false]) {
    testWidgets('PACKAGE-03 safe area and explicit maxWidth $fromRight', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 800);
      addTearDown(tester.view.reset);
      Future<void> mount(double? maxWidth) => tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 800),
              padding: EdgeInsets.only(left: 20, right: 40),
            ),
            child: Align(
              alignment: fromRight
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: SeedSidePanel(
                title: 'Panel',
                fromRight: fromRight,
                maxWidth: maxWidth,
                body: const Text('Content'),
              ),
            ),
          ),
        ),
      );
      await mount(null);
      expect(
        tester.getSize(find.byType(SeedSidePanel)).width,
        closeTo(740 * .8 + (fromRight ? 40 : 20), .01),
      );
      // A caller override retains the existing Flutter width contract.
      await mount(700);
      expect(
        tester.getSize(find.byType(SeedSidePanel)).width,
        closeTo(700 + (fromRight ? 40 : 20), .01),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
