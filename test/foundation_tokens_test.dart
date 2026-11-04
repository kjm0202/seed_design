// Bindings cover every existing raw/semantic foundation token, with expectations
// loaded independently from the pinned official YAML snapshot.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/official_spec.dart';

void main() {
  test(
    'all exported dimension, radius, font and duration tokens match upstream',
    () {
      final numbers = <String, num>{
        r'$dimension.x0_5': SeedDimension.x0_5,
        r'$dimension.x1': SeedDimension.x1,
        r'$dimension.x1_5': SeedDimension.x1_5,
        r'$dimension.x2': SeedDimension.x2,
        r'$dimension.x2_5': SeedDimension.x2_5,
        r'$dimension.x3': SeedDimension.x3,
        r'$dimension.x3_5': SeedDimension.x3_5,
        r'$dimension.x4': SeedDimension.x4,
        r'$dimension.x4_5': SeedDimension.x4_5,
        r'$dimension.x5': SeedDimension.x5,
        r'$dimension.x6': SeedDimension.x6,
        r'$dimension.x7': SeedDimension.x7,
        r'$dimension.x8': SeedDimension.x8,
        r'$dimension.x9': SeedDimension.x9,
        r'$dimension.x10': SeedDimension.x10,
        r'$dimension.x12': SeedDimension.x12,
        r'$dimension.x13': SeedDimension.x13,
        r'$dimension.x14': SeedDimension.x14,
        r'$dimension.x16': SeedDimension.x16,
        r'$radius.r0_5': SeedRadius.r0_5,
        r'$radius.r1': SeedRadius.r1,
        r'$radius.r1_5': SeedRadius.r1_5,
        r'$radius.r2': SeedRadius.r2,
        r'$radius.r2_5': SeedRadius.r2_5,
        r'$radius.r3': SeedRadius.r3,
        r'$radius.r3_5': SeedRadius.r3_5,
        r'$radius.r4': SeedRadius.r4,
        r'$radius.r5': SeedRadius.r5,
        r'$radius.r6': SeedRadius.r6,
        r'$radius.full': SeedRadius.full,
        r'$font-size.t1': SeedFontSize.t1,
        r'$font-size.t2': SeedFontSize.t2,
        r'$font-size.t3': SeedFontSize.t3,
        r'$font-size.t4': SeedFontSize.t4,
        r'$font-size.t5': SeedFontSize.t5,
        r'$font-size.t6': SeedFontSize.t6,
        r'$font-size.t7': SeedFontSize.t7,
        r'$font-size.t8': SeedFontSize.t8,
        r'$font-size.t9': SeedFontSize.t9,
        r'$font-size.t10': SeedFontSize.t10,
        r'$font-size.t11': SeedFontSize.t11,
        r'$font-size.t12': SeedFontSize.t12,
        r'$font-size.t13': SeedFontSize.t13,
        r'$font-size.t14': SeedFontSize.t14,
        r'$line-height.t1': SeedLineHeight.t1,
        r'$line-height.t2': SeedLineHeight.t2,
        r'$line-height.t3': SeedLineHeight.t3,
        r'$line-height.t4': SeedLineHeight.t4,
        r'$line-height.t5': SeedLineHeight.t5,
        r'$line-height.t6': SeedLineHeight.t6,
        r'$line-height.t7': SeedLineHeight.t7,
        r'$line-height.t8': SeedLineHeight.t8,
        r'$line-height.t9': SeedLineHeight.t9,
        r'$line-height.t10': SeedLineHeight.t10,
        r'$line-height.t11': SeedLineHeight.t11,
        r'$line-height.t12': SeedLineHeight.t12,
        r'$line-height.t13': SeedLineHeight.t13,
        r'$line-height.t14': SeedLineHeight.t14,
        r'$duration.d1': SeedDuration.d1.inMilliseconds,
        r'$duration.d2': SeedDuration.d2.inMilliseconds,
        r'$duration.d3': SeedDuration.d3.inMilliseconds,
        r'$duration.d4': SeedDuration.d4.inMilliseconds,
        r'$duration.d5': SeedDuration.d5.inMilliseconds,
        r'$duration.d6': SeedDuration.d6.inMilliseconds,
        r'$duration.color-transition':
            SeedDuration.colorTransition.inMilliseconds,
        r'$duration.pressed-scale': SeedDuration.pressedScale.inMilliseconds,
        r'$dimension.spacing-x.between-chips': SeedSpacingX.betweenChips,
        r'$dimension.spacing-x.global-gutter': SeedSpacingX.globalGutter,
        r'$dimension.spacing-y.component-default':
            SeedSpacingY.componentDefault,
        r'$dimension.spacing-y.nav-to-title': SeedSpacingY.navToTitle,
        r'$dimension.spacing-y.screen-bottom': SeedSpacingY.screenBottom,
        r'$dimension.spacing-y.between-text': SeedSpacingY.betweenText,
      };
      for (final entry in numbers.entries) {
        expect(entry.value, resolveOfficial(entry.key), reason: entry.key);
      }
    },
  );
  test('all 45 text styles use official size, line height and weight', () {
    final typography = SeedTypography.base();
    final styles = <String, TextStyle>{
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
      'screenTitle': typography.screenTitle,
      'articleBody': typography.articleBody,
      'articleNote': typography.articleNote,
    };
    for (final entry in styles.entries) {
      final variant = 'textStyle=${entry.key}';
      expect(
        entry.value.fontSize,
        officialProp('typography', variant, 'root', 'fontSize'),
      );
      expect(
        entry.value.height! * entry.value.fontSize!,
        closeTo(
          (officialProp('typography', variant, 'root', 'lineHeight') as num)
              .toDouble(),
          0.001,
        ),
      );
      expect(
        entry.value.fontWeight!.value,
        officialProp('typography', variant, 'root', 'fontWeight'),
      );
    }
  });

  test('all elevation shadows, timing curves and gradients match the official stops', () {
    final curves = <String, Curve>{
      'linear': SeedCurves.linear,
      'easing': SeedCurves.easing,
      'enter': SeedCurves.enter,
      'exit': SeedCurves.exit,
      'enter-expressive': SeedCurves.enterExpressive,
      'exit-expressive': SeedCurves.exitExpressive,
      'pressed-scale': SeedCurves.pressedScale,
    };
    for (final entry in curves.entries) {
      final points =
          resolveOfficial(r'$timing-function.' + entry.key)['value'] as List;
      final expected = Cubic(
        (points[0] as num).toDouble(),
        (points[1] as num).toDouble(),
        (points[2] as num).toDouble(),
        (points[3] as num).toDouble(),
      );
      for (final t in [0.1, 0.25, 0.5, 0.75, 0.9]) {
        expect(
          entry.value.transform(t),
          closeTo(expected.transform(t), 0.001),
          reason: entry.key,
        );
      }
    }
    for (final dark in [false, true]) {
      final shadows = dark
          ? const SeedShadows.dark()
          : const SeedShadows.light();
      for (final entry in {
        's1': shadows.s1,
        's2': shadows.s2,
        's3': shadows.s3,
      }.entries) {
        final expected =
            resolveOfficial(r'$shadow.' + entry.key, dark: dark)['value']
                as List;
        expect(entry.value.length, expected.length);
        for (var i = 0; i < expected.length; i++) {
          final shadow = entry.value[i], spec = expected[i];
          expect(
            shadow.offset,
            Offset(
              resolveOfficial(spec['offsetX']),
              resolveOfficial(spec['offsetY']),
            ),
          );
          expect(shadow.blurRadius, resolveOfficial(spec['blur']));
          expect(shadow.spreadRadius, resolveOfficial(spec['spread']));
          expect(shadow.color, officialColor(spec['color']));
        }
      }
      final gradients = <String, LinearGradient>{
        'fade-mask': SeedGradients.fadeMask(isDark: dark),
        'glow-magic': SeedGradients.glowMagic(isDark: dark),
        'glow-magic-pressed': SeedGradients.glowMagicPressed(isDark: dark),
        'highlight-magic': SeedGradients.highlightMagic(isDark: dark),
        'highlight-magic-pressed': SeedGradients.highlightMagicPressed(
          isDark: dark,
        ),
        'shimmer-magic': SeedGradients.shimmerMagic(isDark: dark),
        'shimmer-neutral': SeedGradients.shimmerNeutral(isDark: dark),
      };
      for (final entry in gradients.entries) {
        final stops =
            resolveOfficial(r'$gradient.' + entry.key, dark: dark)['value']
                as List;
        expect(entry.value.stops, stops.map((s) => s['position']).toList());
        expect(
          entry.value.colors,
          stops.map((s) => officialColor(s['color'] as String)).toList(),
        );
      }
    }
  });
}
