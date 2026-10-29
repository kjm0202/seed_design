import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  testWidgets(
    'transparent bar matches React segmented labels and switch tone',
    (tester) async {
      await (FontLoader('WantedSans')
            ..addFont(rootBundle.load('assets/fonts/WantedSansVariable.ttf')))
          .load();
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

      await tester.ensureVisible(find.text('gradient'));
      await tester.tap(find.text('gradient'));
      await tester.pumpAndSettle();
      expect(tester.widget<SeedSwitch>(toggle).checked, false);
      expect(tester.takeException(), isNull);
    },
  );
}
