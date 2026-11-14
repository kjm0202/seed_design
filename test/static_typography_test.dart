import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/official_spec.dart';

Map<String, TextStyle> _staticStyles(SeedTypography typography) => {
  't1StaticRegular': typography.t1StaticRegular,
  't1StaticMedium': typography.t1StaticMedium,
  't1StaticBold': typography.t1StaticBold,
  't2StaticRegular': typography.t2StaticRegular,
  't2StaticMedium': typography.t2StaticMedium,
  't2StaticBold': typography.t2StaticBold,
  't3StaticRegular': typography.t3StaticRegular,
  't3StaticMedium': typography.t3StaticMedium,
  't3StaticBold': typography.t3StaticBold,
  't4StaticRegular': typography.t4StaticRegular,
  't4StaticMedium': typography.t4StaticMedium,
  't4StaticBold': typography.t4StaticBold,
  't5StaticRegular': typography.t5StaticRegular,
  't5StaticMedium': typography.t5StaticMedium,
  't5StaticBold': typography.t5StaticBold,
  't6StaticRegular': typography.t6StaticRegular,
  't6StaticMedium': typography.t6StaticMedium,
  't6StaticBold': typography.t6StaticBold,
  't7StaticRegular': typography.t7StaticRegular,
  't7StaticMedium': typography.t7StaticMedium,
  't7StaticBold': typography.t7StaticBold,
  't8StaticRegular': typography.t8StaticRegular,
  't8StaticMedium': typography.t8StaticMedium,
  't8StaticBold': typography.t8StaticBold,
  't9StaticRegular': typography.t9StaticRegular,
  't9StaticMedium': typography.t9StaticMedium,
  't9StaticBold': typography.t9StaticBold,
  't10StaticRegular': typography.t10StaticRegular,
  't10StaticMedium': typography.t10StaticMedium,
  't10StaticBold': typography.t10StaticBold,
  't11StaticRegular': typography.t11StaticRegular,
  't11StaticMedium': typography.t11StaticMedium,
  't11StaticBold': typography.t11StaticBold,
  't12StaticRegular': typography.t12StaticRegular,
  't12StaticMedium': typography.t12StaticMedium,
  't12StaticBold': typography.t12StaticBold,
  't13StaticRegular': typography.t13StaticRegular,
  't13StaticMedium': typography.t13StaticMedium,
  't13StaticBold': typography.t13StaticBold,
  't14StaticRegular': typography.t14StaticRegular,
  't14StaticMedium': typography.t14StaticMedium,
  't14StaticBold': typography.t14StaticBold,
};

Map<String, TextStyle> _ordinaryStyles(SeedTypography typography) => {
  't1Regular': typography.t1Regular,
  't1Medium': typography.t1Medium,
  't1Bold': typography.t1Bold,
  't2Regular': typography.t2Regular,
  't2Medium': typography.t2Medium,
  't2Bold': typography.t2Bold,
  't3Regular': typography.t3Regular,
  't3Medium': typography.t3Medium,
  't3Bold': typography.t3Bold,
  't4Regular': typography.t4Regular,
  't4Medium': typography.t4Medium,
  't4Bold': typography.t4Bold,
  't5Regular': typography.t5Regular,
  't5Medium': typography.t5Medium,
  't5Bold': typography.t5Bold,
  't6Regular': typography.t6Regular,
  't6Medium': typography.t6Medium,
  't6Bold': typography.t6Bold,
  't7Regular': typography.t7Regular,
  't7Medium': typography.t7Medium,
  't7Bold': typography.t7Bold,
  't8Regular': typography.t8Regular,
  't8Medium': typography.t8Medium,
  't8Bold': typography.t8Bold,
  't9Regular': typography.t9Regular,
  't9Medium': typography.t9Medium,
  't9Bold': typography.t9Bold,
  't10Regular': typography.t10Regular,
  't10Medium': typography.t10Medium,
  't10Bold': typography.t10Bold,
  't11Regular': typography.t11Regular,
  't11Medium': typography.t11Medium,
  't11Bold': typography.t11Bold,
  't12Regular': typography.t12Regular,
  't12Medium': typography.t12Medium,
  't12Bold': typography.t12Bold,
  't13Regular': typography.t13Regular,
  't13Medium': typography.t13Medium,
  't13Bold': typography.t13Bold,
  't14Regular': typography.t14Regular,
  't14Medium': typography.t14Medium,
  't14Bold': typography.t14Bold,
};

Widget _host(Widget child, {double textScale = 2}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: Scaffold(
      body: Align(alignment: Alignment.topLeft, child: child),
    ),
  ),
);

void main() {
  test('all 42 static text styles use the official static tokens', () {
    final styles = _staticStyles(SeedTypography.base());
    expect(styles, hasLength(42));
    for (final entry in styles.entries) {
      final variant = 'textStyle=${entry.key}';
      final fontSize = officialProp('typography', variant, 'root', 'fontSize');
      final lineHeight = (officialProp(
        'typography',
        variant,
        'root',
        'lineHeight',
      ) as num).toDouble();
      expect(entry.value.fontSize, fontSize, reason: entry.key);
      expect(
        entry.value.height! * entry.value.fontSize!,
        closeTo(lineHeight, 0.001),
        reason: entry.key,
      );
      expect(
        entry.value.fontWeight!.value,
        officialProp('typography', variant, 'root', 'fontWeight'),
        reason: entry.key,
      );
      expect(
        entry.value.leadingDistribution,
        TextLeadingDistribution.even,
        reason: entry.key,
      );
    }
  });

  test('static size constants match the -static rootage tokens', () {
    final constants = <int, (double, double)>{
      1: (SeedFontSize.t1Static, SeedLineHeight.t1Static),
      2: (SeedFontSize.t2Static, SeedLineHeight.t2Static),
      3: (SeedFontSize.t3Static, SeedLineHeight.t3Static),
      4: (SeedFontSize.t4Static, SeedLineHeight.t4Static),
      5: (SeedFontSize.t5Static, SeedLineHeight.t5Static),
      6: (SeedFontSize.t6Static, SeedLineHeight.t6Static),
      7: (SeedFontSize.t7Static, SeedLineHeight.t7Static),
      8: (SeedFontSize.t8Static, SeedLineHeight.t8Static),
      9: (SeedFontSize.t9Static, SeedLineHeight.t9Static),
      10: (SeedFontSize.t10Static, SeedLineHeight.t10Static),
      11: (SeedFontSize.t11Static, SeedLineHeight.t11Static),
      12: (SeedFontSize.t12Static, SeedLineHeight.t12Static),
      13: (SeedFontSize.t13Static, SeedLineHeight.t13Static),
      14: (SeedFontSize.t14Static, SeedLineHeight.t14Static),
    };
    for (final entry in constants.entries) {
      expect(
        entry.value.$1,
        resolveOfficial('\$font-size.t${entry.key}-static'),
        reason: 't${entry.key} font size',
      );
      expect(
        entry.value.$2,
        resolveOfficial('\$line-height.t${entry.key}-static'),
        reason: 't${entry.key} line height',
      );
    }
  });

  test('ordinary styles are unchanged and static styles ignore mapStyles '
      'size changes', () {
    final base = SeedTypography.base(fontFamily: 'Custom');
    final scaled = base.mapStyles(
      (style) => style.copyWith(fontSize: style.fontSize! * 1.5),
    );
    final ordinary = _ordinaryStyles(base);
    final staticStyles = _staticStyles(scaled);
    for (final entry in ordinary.entries) {
      final staticStyle =
          staticStyles[entry.key.replaceFirst(
            RegExp(r'(?=Regular|Medium|Bold)'),
            'Static',
          )]!;
      expect(staticStyle.fontSize, entry.value.fontSize, reason: entry.key);
      expect(staticStyle.height, entry.value.height, reason: entry.key);
      expect(staticStyle.fontFamily, 'Custom', reason: entry.key);
      expect(staticStyle.fontWeight, entry.value.fontWeight, reason: entry.key);
    }
    expect(base.t5Bold.fontSize, 16);
    expect(base.t5Bold.height! * 16, closeTo(22, 0.001));
  });

  testWidgets('static text keeps its size under textScale 2.0 while ordinary '
      'text grows', (tester) async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            final typography = context.seedTypography;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SeedStaticTextScope(
                  child: Text(
                    '가',
                    key: const ValueKey('static'),
                    style: typography.t5StaticBold,
                  ),
                ),
                Text(
                  '가',
                  key: const ValueKey('ordinary'),
                  style: typography.t5Bold,
                ),
                SeedStaticTextScope(
                  child: SeedText(
                    '가',
                    key: const ValueKey('seedText'),
                    style: typography.t14StaticRegular,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    final staticSize = tester.getSize(find.byKey(const ValueKey('static')));
    final ordinarySize = tester.getSize(find.byKey(const ValueKey('ordinary')));
    expect(staticSize.height, closeTo(22, 0.01));
    expect(ordinarySize.height, closeTo(44, 0.01));
    expect(ordinarySize.width, greaterThan(staticSize.width * 1.9));
    expect(
      tester.getSize(find.byKey(const ValueKey('seedText'))).height,
      closeTo(60, 0.01),
    );

    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byKey(const ValueKey('static')),
        matching: find.byType(RichText),
      ),
    );
    expect(paragraph.textScaler, TextScaler.noScaling);
  });

  testWidgets('the scope disables the scaling of a bare MediaQuery', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(3)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SeedStaticTextScope(
              child: Text('가', style: SeedTypography.base().t3StaticMedium),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Text)).height, closeTo(18, 0.01));
  });
}
