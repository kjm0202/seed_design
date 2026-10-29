import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(SeedThemeData theme, SeedButton button) => MaterialApp(
  theme: theme.toThemeData(),
  home: Scaffold(body: Center(child: button)),
);

Color _background(WidgetTester tester) =>
    (tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: find.byType(SeedButton),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration)
        .color!;

void main() {
  // Each variant's own action-button.css [data-loading] declaration is the
  // contract. In particular, outlines stay transparent; ghost uses an overlay.
  for (final dark in [false, true]) {
    final theme = dark ? SeedThemeData.dark() : SeedThemeData.light();
    final colors = theme.colorScheme;
    final backgrounds = <SeedButtonVariant, (Color, Color)>{
      SeedButtonVariant.brandSolid: (
        colors.bg.brandSolid,
        colors.bg.brandSolidPressed,
      ),
      SeedButtonVariant.neutralSolid: (
        colors.bg.neutralSolid,
        colors.bg.neutralSolidPressed,
      ),
      SeedButtonVariant.neutralWeak: (
        colors.bg.neutralWeak,
        colors.bg.neutralWeakPressed,
      ),
      SeedButtonVariant.criticalSolid: (
        colors.bg.criticalSolid,
        colors.bg.criticalSolidPressed,
      ),
      SeedButtonVariant.brandOutline: (
        colors.bg.transparent,
        colors.bg.transparent,
      ),
      SeedButtonVariant.neutralOutline: (
        colors.bg.transparent,
        colors.bg.transparent,
      ),
      SeedButtonVariant.ghost: (
        colors.bg.transparent,
        colors.bg.transparentPressed,
      ),
    };
    for (final entry in backgrounds.entries) {
      testWidgets(
        '${entry.key.name} enabled/disabled/loading CSS backgrounds dark=$dark',
        (tester) async {
          for (final enabled in [true, false]) {
            for (final loading in [false, true]) {
              var taps = 0;
              await tester.pumpWidget(
                _host(
                  theme,
                  SeedButton(
                    label: 'Retry',
                    variant: entry.key,
                    enabled: enabled,
                    loading: loading,
                    onPressed: () => taps++,
                  ),
                ),
              );
              await tester.pump(const Duration(milliseconds: 350));
              final transparentDisabled = {
                SeedButtonVariant.brandOutline,
                SeedButtonVariant.neutralOutline,
                SeedButtonVariant.ghost,
              }.contains(entry.key);
              final expected = loading
                  ? entry.value.$2
                  : enabled
                  ? entry.value.$1
                  : transparentDisabled
                  ? colors.bg.transparent
                  : colors.bg.disabled;
              expect(
                _background(tester),
                expected,
                reason: 'enabled=$enabled/loading=$loading',
              );
              final semantics = tester.ensureSemantics();
              expect(
                tester.getSemantics(find.byType(SeedButton)),
                matchesSemantics(
                  label: 'Retry',
                  isButton: true,
                  hasEnabledState: true,
                  isEnabled: enabled && !loading,
                  isFocusable: enabled && !loading,
                  hasTapAction: enabled && !loading,
                  hasFocusAction: enabled && !loading,
                ),
              );
              semantics.dispose();
              if (loading) {
                final spinner = tester.widget<SeedProgressCircle>(
                  find.byType(SeedProgressCircle),
                );
                if (!enabled) expect(spinner.color, colors.fg.disabled);
              } else {
                expect(find.byType(SeedProgressCircle), findsNothing);
              }
              await tester.tap(find.byType(SeedButton));
              await tester.pump(const Duration(milliseconds: 350));
              expect(taps, enabled && !loading ? 1 : 0);
            }
          }
        },
      );
    }
  }

  testWidgets(
    'Refund null callback retains loading background and blocks input',
    (tester) async {
      final theme = SeedThemeData.light();
      await tester.pumpWidget(
        _host(
          theme,
          const SeedButton(
            label: 'Retry',
            variant: SeedButtonVariant.neutralSolid,
            enabled: false,
            loading: true,
            onPressed: null,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(_background(tester), const Color(0xff555d6d));
      await tester.tap(find.byType(SeedButton));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disableOnLoading opt-out and normal pressed state stay usable', (
    tester,
  ) async {
    final theme = SeedThemeData.light();
    var taps = 0;
    for (final enabled in [true, false]) {
      await tester.pumpWidget(
        _host(
          theme,
          SeedButton(
            label: 'Retry',
            variant: SeedButtonVariant.neutralSolid,
            enabled: enabled,
            loading: true,
            disableOnLoading: false,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.byType(SeedButton));
      await tester.pump(const Duration(milliseconds: 350));
      expect(taps, 1);
      expect(_background(tester), theme.colorScheme.bg.neutralSolidPressed);
    }
    await tester.pumpWidget(
      _host(
        theme,
        SeedButton(
          label: 'Retry',
          variant: SeedButtonVariant.neutralSolid,
          onPressed: () => taps++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SeedButton)),
      kind: PointerDeviceKind.touch,
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(_background(tester), theme.colorScheme.bg.neutralSolidPressed);
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 350));
    expect(_background(tester), theme.colorScheme.bg.neutralSolid);
    expect(taps, 2);
  });
}
