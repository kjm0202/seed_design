import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  group('SEED Foundations - Scale Feedback Physics', () {
    test('Calculates exact scale as defined in SEED documentation', () {
      // 32 x 32 icon button: basis = 32, scale = (32 - 2)/32 = 0.9375
      final scale32 = SeedScaleCalculator.calculateScale(width: 32, height: 32);
      expect(scale32, closeTo(0.9375, 0.001));

      // 120 x 48 text button: basis = 48, scale = (48 - 2)/48 = 0.9583
      final scale120 = SeedScaleCalculator.calculateScale(
        width: 120,
        height: 48,
      );
      expect(scale120, closeTo(0.9583, 0.001));

      // 343 x 48 full-width button: basis = 343/4 = 85.75, scale = (85.75 - 2)/85.75 = 0.9766
      final scale343 = SeedScaleCalculator.calculateScale(
        width: 343,
        height: 48,
      );
      expect(scale343, closeTo(0.9766, 0.001));

      // 22 x 22 small button: basis = min 24, scale = (24 - 2)/24 = 0.9166
      final scale22 = SeedScaleCalculator.calculateScale(width: 22, height: 22);
      expect(scale22, closeTo(0.9166, 0.001));

      // Reduce Motion disabled animations
      final scaleReduceMotion = SeedScaleCalculator.calculateScale(
        width: 120,
        height: 48,
        disableAnimations: true,
      );
      expect(scaleReduceMotion, 1.0);
    });
  });

  group('SEED Components - Selection', () {
    testWidgets('SeedCheckbox toggles', (tester) async {
      bool checked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SeedCheckbox(
                  value: checked,
                  label: '약관에 동의합니다',
                  onChanged: (val) {
                    setState(() => checked = val ?? false);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(checked, isFalse);
      await tester.tap(find.text('약관에 동의합니다'));
      await tester.pumpAndSettle();
      expect(checked, isTrue);
    });
  });

  group('SEED Components - Media & Layout & Placeholders', () {
    testWidgets('SeedAttachmentInput displays count and trigger', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedAttachmentInput(items: [], maxCount: 10),
          ),
        ),
      );

      expect(find.text('0/10'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets(
      'SeedImageFrame renders fallback placeholder when image is absent',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: const Scaffold(body: SeedImageFrame(badge: '대표사진')),
          ),
        );

        expect(find.text('대표사진'), findsOneWidget);
        expect(find.byType(SeedContentPlaceholder), findsOneWidget);
      },
    );
  });
}
