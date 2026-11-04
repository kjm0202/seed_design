import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

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

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 480, child: child),
    ),
  ),
);

Widget hostRegression(Widget child, {ThemeData? theme}) => MaterialApp(
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: theme ?? SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostInteraction(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostComponentAccessibilityOv(
  Widget child, {
  double scale = 1,
  bool dark = false,
}) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme:
      (dark
              ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
              : SeedThemeData.light(fontFamily: seedTestFontFamily))
          .toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

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
  group('floating action button width', () {
    testWidgets('extended FABs use content width and can share a wrap row', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Wrap(
            spacing: 12,
            children: [
              SeedFloatingActionButton.extended(
                key: const ValueKey('write'),
                icon: const Icon(Icons.edit),
                label: 'Write',
                onPressed: () {},
              ),
              SeedFloatingActionButton.extended(
                key: const ValueKey('nearby'),
                icon: const Icon(Icons.near_me),
                label: 'Nearby',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final first = find.byKey(const ValueKey('write'));
      final second = find.byKey(const ValueKey('nearby'));
      final labelWidth = tester.getSize(find.text('Write')).width;
      // Icon, gap and horizontal padding surround the label, with no expansion.
      expect(
        tester.getSize(first).width,
        closeTo(labelWidth + 16 + 4 + 36, .01),
      );
      expect(tester.getTopLeft(first).dy, tester.getTopLeft(second).dy);
      expect(
        tester.getTopLeft(second).dx,
        greaterThan(tester.getTopRight(first).dx),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'collapsing a FAB preserves the icon size and restores content width',
      (tester) async {
        var extended = true;
        late StateSetter update;
        await tester.pumpWidget(
          host(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    return SeedFloatingActionButton.extended(
                      icon: const Icon(Icons.add),
                      label: 'Create',
                      extended: extended,
                      onPressed: () {},
                    );
                  },
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fab = find.byType(SeedFloatingActionButton);
        final original = tester.getSize(fab);
        expect(original.width, lessThan(240));
        update(() => extended = false);
        await tester.pumpAndSettle();
        expect(tester.getSize(fab), const Size(56, 56));
        update(() => extended = true);
        await tester.pumpAndSettle();
        expect(tester.getSize(fab), original);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Button and ToggleButton', () {
    Widget host(Widget child, {bool isDark = false}) {
      return MaterialApp(
        theme: (isDark ? SeedThemeData.dark() : SeedThemeData.light())
            .toThemeData(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets(
      'SeedButton supports withTextIconSize, bleed, and custom text styles',
      (tester) async {
        expect(SeedButtonSize.small.withTextIconSize, 14.0);
        expect(SeedButtonSize.medium.withTextIconSize, 16.0);
        expect(SeedButtonSize.small.iconOnlySize, 16.0);

        await tester.pumpWidget(
          host(
            SeedButton(
              label: 'Ghost Button',
              variant: SeedButtonVariant.ghost,
              bleed: true,
              textColor: Colors.blue,
              fontWeight: FontWeight.w400,
              onPressed: () {},
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Ghost Button'));
        expect(text.style?.color, Colors.blue);
        expect(text.style?.fontWeight, FontWeight.w400);
      },
    );

    testWidgets(
      'SeedToggleButton toggles state and responds to onPressedChange',
      (tester) async {
        bool isSelected = false;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return host(
                SeedToggleButton(
                  label: '즐겨찾기',
                  selected: isSelected,
                  onSelectedChanged: (val) => setState(() => isSelected = val),
                ),
              );
            },
          ),
        );

        expect(isSelected, isFalse);
        await tester.tap(find.text('즐겨찾기'));
        await tester.pumpAndSettle();
        expect(isSelected, isTrue);
      },
    );

    for (final width in [390.0, 800.0]) {
      testWidgets('ToggleButton React pill focus ring matches shape $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          host(
            SeedToggleButton(
              label: 'Like',
              selected: false,
              onSelectedChanged: (_) {},
            ),
          ),
        );
        final pressable = tester.widget<SeedPressable>(
          find.descendant(
            of: find.byType(SeedToggleButton),
            matching: find.byType(SeedPressable),
          ),
        );
        expect(
          pressable.focusBorderRadius,
          SeedBorderRadius.full,
          reason: 'React toggle-button.css uses --seed-radius-full',
        );
      });
    }
  });

  group('sizing and activation', () {
    testWidgets('hug, fill and long labels respect available width', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostRegression(SeedButton(label: 'OK', onPressed: () {})),
      );
      expect(tester.getSize(find.byType(SeedButton)).width, lessThan(100));
      await tester.pumpWidget(
        hostRegression(
          SizedBox(
            width: 180,
            child: SeedButton(
              label: '아주 긴 버튼 레이블을 표시하는 테스트',
              prefixIcon: const Icon(Icons.add),
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SeedButton)).width, 180);
      expect(tester.takeException(), isNull);
    });

    testWidgets('null callbacks use disabled colors and semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostRegression(const SeedButton(label: 'Disabled', onPressed: null)),
      );
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(SeedButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        const SeedColorScheme.light().bg.disabled,
      );
      expect(
        tester.getSemantics(find.byType(SeedButton)),
        matchesSemantics(
          label: 'Disabled',
          isButton: true,
          hasEnabledState: true,
        ),
      );
    });

    testWidgets('large text increases height without clipping', (tester) async {
      await tester.pumpWidget(
        hostRegression(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: SeedButton(label: '확인', onPressed: () {}),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SeedButton)).height, greaterThan(40));
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'Tab then Enter and Space activate a button exactly once each',
      (tester) async {
        var count = 0;
        await tester.pumpWidget(
          hostRegression(SeedButton(label: 'Run', onPressed: () => count++)),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(count, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(count, 2);
      },
    );
  });

  group('loading', () {
    testWidgets('loading preserves label width and prevents activation', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        hostInteraction(
          SeedButton(label: '저장하고 계속하기', onPressed: () => calls++),
        ),
      );
      final width = tester.getSize(find.byType(SeedButton)).width;
      await tester.pumpWidget(
        hostInteraction(
          SeedButton(
            label: '저장하고 계속하기',
            loading: true,
            onPressed: () => calls++,
          ),
        ),
      );
      expect(tester.getSize(find.byType(SeedButton)).width, width);
      await tester.tap(find.byType(SeedButton));
      expect(calls, 0);
      expect(
        tester.getSemantics(find.byType(SeedButton)),
        matchesSemantics(
          label: '저장하고 계속하기',
          isButton: true,
          hasEnabledState: true,
        ),
      );
    });
  });

  group('ReactionButton target', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'reaction icon keeps a 24px layout with a working 40px touch target',
      (tester) async {
        var changes = 0;
        await tester.pumpWidget(
          hostComponentAccessibilityOv(
            SeedImageFrameReactionButton(onChanged: (_) => changes++),
          ),
        );
        final rect = tester.getRect(find.byType(SeedImageFrameReactionButton));
        expect(rect.size, const Size(24, 24));
        await tester.tapAt(rect.topLeft - const Offset(7, 7));
        await tester.pumpAndSettle();
        expect(changes, 1);
        await tester.pumpWidget(
          hostComponentAccessibilityOv(
            SizedBox(
              width: 200,
              child: SeedImageFrame(
                overlay: SeedImageFrameFloater(
                  alignment: Alignment.topRight,
                  child: SeedImageFrameReactionButton(
                    onChanged: (_) => changes++,
                  ),
                ),
              ),
            ),
          ),
        );
        final frame = tester.getRect(find.byType(SeedImageFrame));
        final heart = tester.getRect(find.byType(SeedImageFrameReactionButton));
        expect(frame.right - heart.right, 6);
        expect(heart.top - frame.top, 6);
        await tester.tapAt(heart.topLeft - const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(changes, 2);
      },
    );
  });
}
