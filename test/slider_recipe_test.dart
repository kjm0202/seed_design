import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _host(Widget child, {double width = 320}) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
group('Slider', () {
    testWidgets('min/max markers align to the track edges by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SeedSlider(
            values: const [5],
            min: 0,
            max: 10,
            markers: const [
              SeedSliderMarker(0, '별로'),
              SeedSliderMarker(10, '최고'),
            ],
            onValuesChange: (_) {},
          ),
        ),
      );
      final slider = tester.getRect(find.byType(SeedSlider));
      final start = tester.getRect(find.text('별로'));
      final end = tester.getRect(find.text('최고'));
      expect(start.left, greaterThanOrEqualTo(slider.left - 0.5));
      expect(end.right, lessThanOrEqualTo(slider.right + 0.5));
      expect(const SeedSliderMarker(5, 'mid').resolveAlign(0, 10),
          SeedSliderMarkerAlign.center);
      expect(
        const SeedSliderMarker(0, 'x', align: SeedSliderMarkerAlign.center)
            .resolveAlign(0, 10),
        SeedSliderMarkerAlign.center,
      );
    });

    testWidgets('a stepped range slider draws no Material step dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SeedSlider.range(
            values: const RangeValues(200000, 500000),
            min: 0,
            max: 1000000,
            step: 50000,
            onValuesChange: (_) {},
          ),
        ),
      );
      final theme = SliderTheme.of(tester.element(find.byType(RangeSlider)));
      expect(theme.rangeTickMarkShape, isNot(isA<RoundRangeSliderTickMarkShape>()));
      expect(
        theme.rangeTickMarkShape!.getPreferredSize(sliderTheme: theme),
        Size.zero,
      );
    });

    testWidgets('indicator renders the official indicator text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SeedSlider.range(
            values: const RangeValues(2, 5),
            min: 0,
            max: 10,
            fieldLabel: '예산 범위',
            indicator: '선택',
            onValuesChange: (_) {},
          ),
        ),
      );
      expect(find.text('선택'), findsOneWidget);
    });
  });
}
