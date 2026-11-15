import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

void main() {
  group('level boundaries', () {
    test('manner temperature boundaries follow pinned upstream source', () {
      const boundaries = [30.0, 36.0, 36.5, 37.0, 40.0, 45.0, 55.0, 65.0, 80.0];
      for (var i = 0; i < boundaries.length; i++) {
        expect(
          SeedMannerTempLevel.fromTemperature(boundaries[i] - 0.001),
          i + 1,
        );
        expect(SeedMannerTempLevel.fromTemperature(boundaries[i]), i + 2);
      }
      expect(
        () => SeedMannerTempLevel.fromTemperature(double.nan),
        throwsArgumentError,
      );
    });
  });

  group('Celsius precision', () {
    testWidgets(
      'manner temperatures preserve Celsius precision with an emote',
      (tester) async {
        await tester.pumpWidget(
          koreanAppCentered(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeedMannerTemp(temperature: 40, showEmoji: true),
                SeedMannerTemp(temperature: 36.55, showEmoji: true),
                SeedMannerTempBadge(temperature: 80),
              ],
            ),
          ),
        );
        expect(find.text('40°C'), findsOneWidget);
        expect(find.text('36.55°C'), findsOneWidget);
        expect(find.text('80°C'), findsOneWidget);
        expect(find.text(SeedMannerTempLevel.getEmoji(6)), findsOneWidget);
        expect(find.text(SeedMannerTempLevel.getEmoji(4)), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
