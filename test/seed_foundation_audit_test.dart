// Bindings cover every existing raw/semantic foundation token, with expectations
// loaded independently from the pinned official YAML snapshot.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
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
  for (final dark in [false, true]) {
    test('all palette and semantic colors match upstream (dark=$dark)', () {
      final colors = dark
          ? const SeedColorScheme.dark()
          : const SeedColorScheme.light();
      final actual = <String, Color>{
        r'$color.palette.gray-00': dark
            ? SeedPalette.gray00Dark
            : SeedPalette.gray00Light,
        r'$color.palette.gray-100': dark
            ? SeedPalette.gray100Dark
            : SeedPalette.gray100Light,
        r'$color.palette.gray-200': dark
            ? SeedPalette.gray200Dark
            : SeedPalette.gray200Light,
        r'$color.palette.gray-300': dark
            ? SeedPalette.gray300Dark
            : SeedPalette.gray300Light,
        r'$color.palette.gray-400': dark
            ? SeedPalette.gray400Dark
            : SeedPalette.gray400Light,
        r'$color.palette.gray-500': dark
            ? SeedPalette.gray500Dark
            : SeedPalette.gray500Light,
        r'$color.palette.gray-600': dark
            ? SeedPalette.gray600Dark
            : SeedPalette.gray600Light,
        r'$color.palette.gray-700': dark
            ? SeedPalette.gray700Dark
            : SeedPalette.gray700Light,
        r'$color.palette.gray-800': dark
            ? SeedPalette.gray800Dark
            : SeedPalette.gray800Light,
        r'$color.palette.gray-900': dark
            ? SeedPalette.gray900Dark
            : SeedPalette.gray900Light,
        r'$color.palette.gray-1000': dark
            ? SeedPalette.gray1000Dark
            : SeedPalette.gray1000Light,
        r'$color.palette.carrot-100': dark
            ? SeedPalette.carrot100Dark
            : SeedPalette.carrot100Light,
        r'$color.palette.carrot-200': dark
            ? SeedPalette.carrot200Dark
            : SeedPalette.carrot200Light,
        r'$color.palette.carrot-300': dark
            ? SeedPalette.carrot300Dark
            : SeedPalette.carrot300Light,
        r'$color.palette.carrot-400': dark
            ? SeedPalette.carrot400Dark
            : SeedPalette.carrot400Light,
        r'$color.palette.carrot-500': dark
            ? SeedPalette.carrot500Dark
            : SeedPalette.carrot500Light,
        r'$color.palette.carrot-600': dark
            ? SeedPalette.carrot600Dark
            : SeedPalette.carrot600Light,
        r'$color.palette.carrot-700': dark
            ? SeedPalette.carrot700Dark
            : SeedPalette.carrot700Light,
        r'$color.palette.carrot-800': dark
            ? SeedPalette.carrot800Dark
            : SeedPalette.carrot800Light,
        r'$color.palette.carrot-900': dark
            ? SeedPalette.carrot900Dark
            : SeedPalette.carrot900Light,
        r'$color.palette.carrot-1000': dark
            ? SeedPalette.carrot1000Dark
            : SeedPalette.carrot1000Light,
        r'$color.palette.blue-100': dark
            ? SeedPalette.blue100Dark
            : SeedPalette.blue100Light,
        r'$color.palette.blue-200': dark
            ? SeedPalette.blue200Dark
            : SeedPalette.blue200Light,
        r'$color.palette.blue-300': dark
            ? SeedPalette.blue300Dark
            : SeedPalette.blue300Light,
        r'$color.palette.blue-400': dark
            ? SeedPalette.blue400Dark
            : SeedPalette.blue400Light,
        r'$color.palette.blue-500': dark
            ? SeedPalette.blue500Dark
            : SeedPalette.blue500Light,
        r'$color.palette.blue-600': dark
            ? SeedPalette.blue600Dark
            : SeedPalette.blue600Light,
        r'$color.palette.blue-700': dark
            ? SeedPalette.blue700Dark
            : SeedPalette.blue700Light,
        r'$color.palette.blue-800': dark
            ? SeedPalette.blue800Dark
            : SeedPalette.blue800Light,
        r'$color.palette.blue-900': dark
            ? SeedPalette.blue900Dark
            : SeedPalette.blue900Light,
        r'$color.palette.blue-1000': dark
            ? SeedPalette.blue1000Dark
            : SeedPalette.blue1000Light,
        r'$color.palette.red-100': dark
            ? SeedPalette.red100Dark
            : SeedPalette.red100Light,
        r'$color.palette.red-200': dark
            ? SeedPalette.red200Dark
            : SeedPalette.red200Light,
        r'$color.palette.red-300': dark
            ? SeedPalette.red300Dark
            : SeedPalette.red300Light,
        r'$color.palette.red-400': dark
            ? SeedPalette.red400Dark
            : SeedPalette.red400Light,
        r'$color.palette.red-500': dark
            ? SeedPalette.red500Dark
            : SeedPalette.red500Light,
        r'$color.palette.red-600': dark
            ? SeedPalette.red600Dark
            : SeedPalette.red600Light,
        r'$color.palette.red-700': dark
            ? SeedPalette.red700Dark
            : SeedPalette.red700Light,
        r'$color.palette.red-800': dark
            ? SeedPalette.red800Dark
            : SeedPalette.red800Light,
        r'$color.palette.red-900': dark
            ? SeedPalette.red900Dark
            : SeedPalette.red900Light,
        r'$color.palette.red-1000': dark
            ? SeedPalette.red1000Dark
            : SeedPalette.red1000Light,
        r'$color.palette.green-100': dark
            ? SeedPalette.green100Dark
            : SeedPalette.green100Light,
        r'$color.palette.green-200': dark
            ? SeedPalette.green200Dark
            : SeedPalette.green200Light,
        r'$color.palette.green-300': dark
            ? SeedPalette.green300Dark
            : SeedPalette.green300Light,
        r'$color.palette.green-400': dark
            ? SeedPalette.green400Dark
            : SeedPalette.green400Light,
        r'$color.palette.green-500': dark
            ? SeedPalette.green500Dark
            : SeedPalette.green500Light,
        r'$color.palette.green-600': dark
            ? SeedPalette.green600Dark
            : SeedPalette.green600Light,
        r'$color.palette.green-700': dark
            ? SeedPalette.green700Dark
            : SeedPalette.green700Light,
        r'$color.palette.green-800': dark
            ? SeedPalette.green800Dark
            : SeedPalette.green800Light,
        r'$color.palette.green-900': dark
            ? SeedPalette.green900Dark
            : SeedPalette.green900Light,
        r'$color.palette.green-1000': dark
            ? SeedPalette.green1000Dark
            : SeedPalette.green1000Light,
        r'$color.palette.yellow-100': dark
            ? SeedPalette.yellow100Dark
            : SeedPalette.yellow100Light,
        r'$color.palette.yellow-200': dark
            ? SeedPalette.yellow200Dark
            : SeedPalette.yellow200Light,
        r'$color.palette.yellow-300': dark
            ? SeedPalette.yellow300Dark
            : SeedPalette.yellow300Light,
        r'$color.palette.yellow-400': dark
            ? SeedPalette.yellow400Dark
            : SeedPalette.yellow400Light,
        r'$color.palette.yellow-500': dark
            ? SeedPalette.yellow500Dark
            : SeedPalette.yellow500Light,
        r'$color.palette.yellow-600': dark
            ? SeedPalette.yellow600Dark
            : SeedPalette.yellow600Light,
        r'$color.palette.yellow-700': dark
            ? SeedPalette.yellow700Dark
            : SeedPalette.yellow700Light,
        r'$color.palette.yellow-800': dark
            ? SeedPalette.yellow800Dark
            : SeedPalette.yellow800Light,
        r'$color.palette.yellow-900': dark
            ? SeedPalette.yellow900Dark
            : SeedPalette.yellow900Light,
        r'$color.palette.yellow-1000': dark
            ? SeedPalette.yellow1000Dark
            : SeedPalette.yellow1000Light,
        r'$color.palette.purple-100': dark
            ? SeedPalette.purple100Dark
            : SeedPalette.purple100Light,
        r'$color.palette.purple-200': dark
            ? SeedPalette.purple200Dark
            : SeedPalette.purple200Light,
        r'$color.palette.purple-300': dark
            ? SeedPalette.purple300Dark
            : SeedPalette.purple300Light,
        r'$color.palette.purple-400': dark
            ? SeedPalette.purple400Dark
            : SeedPalette.purple400Light,
        r'$color.palette.purple-500': dark
            ? SeedPalette.purple500Dark
            : SeedPalette.purple500Light,
        r'$color.palette.purple-600': dark
            ? SeedPalette.purple600Dark
            : SeedPalette.purple600Light,
        r'$color.palette.purple-700': dark
            ? SeedPalette.purple700Dark
            : SeedPalette.purple700Light,
        r'$color.palette.purple-800': dark
            ? SeedPalette.purple800Dark
            : SeedPalette.purple800Light,
        r'$color.palette.purple-900': dark
            ? SeedPalette.purple900Dark
            : SeedPalette.purple900Light,
        r'$color.palette.purple-1000': dark
            ? SeedPalette.purple1000Dark
            : SeedPalette.purple1000Light,
        r'$color.palette.static-black': SeedPalette.staticBlack,
        r'$color.palette.static-black-alpha-100':
            SeedPalette.staticBlackAlpha100,
        r'$color.palette.static-black-alpha-200':
            SeedPalette.staticBlackAlpha200,
        r'$color.palette.static-black-alpha-300':
            SeedPalette.staticBlackAlpha300,
        r'$color.palette.static-black-alpha-400':
            SeedPalette.staticBlackAlpha400,
        r'$color.palette.static-black-alpha-500':
            SeedPalette.staticBlackAlpha500,
        r'$color.palette.static-black-alpha-600':
            SeedPalette.staticBlackAlpha600,
        r'$color.palette.static-black-alpha-700':
            SeedPalette.staticBlackAlpha700,
        r'$color.palette.static-black-alpha-800':
            SeedPalette.staticBlackAlpha800,
        r'$color.palette.static-black-alpha-900':
            SeedPalette.staticBlackAlpha900,
        r'$color.palette.static-black-alpha-1000':
            SeedPalette.staticBlackAlpha1000,
        r'$color.palette.static-white': SeedPalette.staticWhite,
        r'$color.palette.static-white-alpha-50': SeedPalette.staticWhiteAlpha50,
        r'$color.palette.static-white-alpha-100':
            SeedPalette.staticWhiteAlpha100,
        r'$color.palette.static-white-alpha-200':
            SeedPalette.staticWhiteAlpha200,
        r'$color.palette.static-white-alpha-300':
            SeedPalette.staticWhiteAlpha300,
        r'$color.palette.static-white-alpha-400':
            SeedPalette.staticWhiteAlpha400,
        r'$color.palette.static-white-alpha-500':
            SeedPalette.staticWhiteAlpha500,
        r'$color.palette.static-white-alpha-600':
            SeedPalette.staticWhiteAlpha600,
        r'$color.palette.static-white-alpha-700':
            SeedPalette.staticWhiteAlpha700,
        r'$color.palette.static-white-alpha-800':
            SeedPalette.staticWhiteAlpha800,
        r'$color.palette.static-white-alpha-900':
            SeedPalette.staticWhiteAlpha900,
        r'$color.palette.static-white-alpha-1000':
            SeedPalette.staticWhiteAlpha1000,
        r'$color.fg.brand': colors.fg.brand,
        r'$color.fg.brand-contrast': colors.fg.brandContrast,
        r'$color.fg.critical': colors.fg.critical,
        r'$color.fg.critical-contrast': colors.fg.criticalContrast,
        r'$color.fg.disabled': colors.fg.disabled,
        r'$color.fg.informative': colors.fg.informative,
        r'$color.fg.informative-contrast': colors.fg.informativeContrast,
        r'$color.fg.neutral': colors.fg.neutral,
        r'$color.fg.neutral-inverted': colors.fg.neutralInverted,
        r'$color.fg.neutral-muted': colors.fg.neutralMuted,
        r'$color.fg.neutral-subtle': colors.fg.neutralSubtle,
        r'$color.fg.on-brand-solid': colors.fg.onBrandSolid,
        r'$color.fg.on-critical-solid': colors.fg.onCriticalSolid,
        r'$color.fg.on-informative-solid': colors.fg.onInformativeSolid,
        r'$color.fg.on-neutral-solid': colors.fg.onNeutralSolid,
        r'$color.fg.on-positive-solid': colors.fg.onPositiveSolid,
        r'$color.fg.on-warning-solid': colors.fg.onWarningSolid,
        r'$color.fg.placeholder': colors.fg.placeholder,
        r'$color.fg.positive': colors.fg.positive,
        r'$color.fg.positive-contrast': colors.fg.positiveContrast,
        r'$color.fg.warning': colors.fg.warning,
        r'$color.fg.warning-contrast': colors.fg.warningContrast,
        r'$color.bg.brand-solid': colors.bg.brandSolid,
        r'$color.bg.brand-solid-pressed': colors.bg.brandSolidPressed,
        r'$color.bg.brand-weak': colors.bg.brandWeak,
        r'$color.bg.brand-weak-pressed': colors.bg.brandWeakPressed,
        r'$color.bg.critical-solid': colors.bg.criticalSolid,
        r'$color.bg.critical-solid-pressed': colors.bg.criticalSolidPressed,
        r'$color.bg.critical-weak': colors.bg.criticalWeak,
        r'$color.bg.critical-weak-pressed': colors.bg.criticalWeakPressed,
        r'$color.bg.disabled': colors.bg.disabled,
        r'$color.bg.informative-solid': colors.bg.informativeSolid,
        r'$color.bg.informative-solid-pressed':
            colors.bg.informativeSolidPressed,
        r'$color.bg.informative-weak': colors.bg.informativeWeak,
        r'$color.bg.informative-weak-pressed': colors.bg.informativeWeakPressed,
        r'$color.bg.layer-basement': colors.bg.layerBasement,
        r'$color.bg.layer-default': colors.bg.layerDefault,
        r'$color.bg.layer-default-pressed': colors.bg.layerDefaultPressed,
        r'$color.bg.layer-floating': colors.bg.layerFloating,
        r'$color.bg.layer-floating-pressed': colors.bg.layerFloatingPressed,
        r'$color.bg.magic-weak': colors.bg.magicWeak,
        r'$color.bg.neutral-inverted': colors.bg.neutralInverted,
        r'$color.bg.neutral-inverted-pressed': colors.bg.neutralInvertedPressed,
        r'$color.bg.neutral-muted': colors.bg.neutralMuted,
        r'$color.bg.neutral-solid': colors.bg.neutralSolid,
        r'$color.bg.neutral-solid-pressed': colors.bg.neutralSolidPressed,
        r'$color.bg.neutral-subtle': colors.bg.neutralSubtle,
        r'$color.bg.neutral-weak': colors.bg.neutralWeak,
        r'$color.bg.neutral-weak-alpha': colors.bg.neutralWeakAlpha,
        r'$color.bg.neutral-weak-alpha-pressed':
            colors.bg.neutralWeakAlphaPressed,
        r'$color.bg.neutral-weak-pressed': colors.bg.neutralWeakPressed,
        r'$color.bg.overlay': colors.bg.overlay,
        r'$color.bg.overlay-muted': colors.bg.overlayMuted,
        r'$color.bg.positive-solid': colors.bg.positiveSolid,
        r'$color.bg.positive-solid-pressed': colors.bg.positiveSolidPressed,
        r'$color.bg.positive-weak': colors.bg.positiveWeak,
        r'$color.bg.positive-weak-pressed': colors.bg.positiveWeakPressed,
        r'$color.bg.transparent': colors.bg.transparent,
        r'$color.bg.transparent-pressed': colors.bg.transparentPressed,
        r'$color.bg.transparent-selected': colors.bg.transparentSelected,
        r'$color.bg.transparent-selected-pressed':
            colors.bg.transparentSelectedPressed,
        r'$color.bg.warning-solid': colors.bg.warningSolid,
        r'$color.bg.warning-solid-pressed': colors.bg.warningSolidPressed,
        r'$color.bg.warning-weak': colors.bg.warningWeak,
        r'$color.bg.warning-weak-pressed': colors.bg.warningWeakPressed,
        r'$color.stroke.brand-solid': colors.stroke.brandSolid,
        r'$color.stroke.brand-weak': colors.stroke.brandWeak,
        r'$color.stroke.critical-solid': colors.stroke.criticalSolid,
        r'$color.stroke.critical-weak': colors.stroke.criticalWeak,
        r'$color.stroke.focus-ring': colors.stroke.focusRing,
        r'$color.stroke.informative-solid': colors.stroke.informativeSolid,
        r'$color.stroke.informative-weak': colors.stroke.informativeWeak,
        r'$color.stroke.neutral-contrast': colors.stroke.neutralContrast,
        r'$color.stroke.neutral-muted': colors.stroke.neutralMuted,
        r'$color.stroke.neutral-solid': colors.stroke.neutralSolid,
        r'$color.stroke.neutral-subtle': colors.stroke.neutralSubtle,
        r'$color.stroke.neutral-weak': colors.stroke.neutralWeak,
        r'$color.stroke.positive-solid': colors.stroke.positiveSolid,
        r'$color.stroke.positive-weak': colors.stroke.positiveWeak,
        r'$color.stroke.warning-solid': colors.stroke.warningSolid,
        r'$color.stroke.warning-weak': colors.stroke.warningWeak,
        r'$color.manner-temp.l1.bg': colors.mannerTemp.l1.bg,
        r'$color.manner-temp.l1.text': colors.mannerTemp.l1.text,
        r'$color.manner-temp.l2.bg': colors.mannerTemp.l2.bg,
        r'$color.manner-temp.l2.text': colors.mannerTemp.l2.text,
        r'$color.manner-temp.l3.bg': colors.mannerTemp.l3.bg,
        r'$color.manner-temp.l3.text': colors.mannerTemp.l3.text,
        r'$color.manner-temp.l4.bg': colors.mannerTemp.l4.bg,
        r'$color.manner-temp.l4.text': colors.mannerTemp.l4.text,
        r'$color.manner-temp.l5.bg': colors.mannerTemp.l5.bg,
        r'$color.manner-temp.l5.text': colors.mannerTemp.l5.text,
        r'$color.manner-temp.l6.bg': colors.mannerTemp.l6.bg,
        r'$color.manner-temp.l6.text': colors.mannerTemp.l6.text,
        r'$color.manner-temp.l7.bg': colors.mannerTemp.l7.bg,
        r'$color.manner-temp.l7.text': colors.mannerTemp.l7.text,
        r'$color.manner-temp.l8.bg': colors.mannerTemp.l8.bg,
        r'$color.manner-temp.l8.text': colors.mannerTemp.l8.text,
        r'$color.manner-temp.l9.bg': colors.mannerTemp.l9.bg,
        r'$color.manner-temp.l9.text': colors.mannerTemp.l9.text,
        r'$color.manner-temp.l10.bg': colors.mannerTemp.l10.bg,
        r'$color.manner-temp.l10.text': colors.mannerTemp.l10.text,
      };
      for (final entry in actual.entries) {
        expect(
          entry.value,
          officialColor(entry.key, dark: dark),
          reason: entry.key,
        );
      }
    });
  }
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
