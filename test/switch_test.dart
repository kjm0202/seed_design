import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

import 'dart:ui' show Tristate;

Widget _host(
  Widget child, {
  double width = 800,
  Brightness brightness = Brightness.light,
}) {
  final theme = brightness == Brightness.dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  return MaterialApp(
    locale: const Locale('ko'),
    supportedLocales: const [Locale('en'), Locale('ko')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: theme.toThemeData(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

Color _trackColor(WidgetTester tester) {
  final findTrack = find.descendant(
    of: find.byType(SeedSwitchMark),
    matching: find.byType(AnimatedContainer),
  );
  return (tester.widget<AnimatedContainer>(findTrack).decoration!
          as BoxDecoration)
      .color!;
}

void main() {
  for (final size in [SeedSwitchSize.size16, SeedSwitchSize.size32]) {
    testWidgets('a stretched $size switch places its short label at the end', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(SeedSwitch(size: size, label: 'Alerts'), width: 300),
      );
      final root = tester.getRect(find.byType(SeedSwitch));
      final label = tester.getRect(find.text('Alerts'));
      expect(label.right, closeTo(root.right, 0.01));
    });
  }

  testWidgets('a wrapping switch label keeps the large mark at the top', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SeedSwitch(
          label: 'A long label that wraps over several lines in a narrow area',
        ),
        width: 160,
      ),
    );
    final root = tester.getRect(find.byType(SeedSwitch));
    final mark = tester.getRect(find.byType(SeedControlFocusRing));
    expect(mark.top, closeTo(root.top, 0.01));
  });

  group('checked colors and control', () {
    setUpAll(loadSeedTestFonts);

    for (final brightness in [Brightness.light, Brightness.dark]) {
      for (final size in SeedSwitchSize.values) {
        testWidgets(
          'Switch brand checked remains brand when disabled, $brightness $size',
          (tester) async {
            await tester.pumpWidget(
              _host(
                SeedSwitchMark(
                  checked: true,
                  enabled: true,
                  tone: SeedControlTone.brand,
                  onCheckedChange: (_) {},
                ),
                brightness: brightness,
              ),
            );
            await tester.pumpAndSettle();
            final active = _trackColor(tester);
            await tester.pumpWidget(
              _host(
                SeedSwitchMark(
                  checked: true,
                  enabled: false,
                  tone: SeedControlTone.brand,
                  size: size,
                  onCheckedChange: (_) {},
                ),
                brightness: brightness,
              ),
            );
            await tester.pumpAndSettle();
            final disabled = _trackColor(tester);
            expect(disabled, active);
            final opacity = tester.widget<Opacity>(
              find.descendant(
                of: find.byType(SeedSwitchMark),
                matching: find.byType(Opacity),
              ),
            );
            expect(opacity.opacity, 0.38);
          },
        );
      }
    }

    testWidgets('Switch neutral disabled checked remains gray and no toggle', (
      tester,
    ) async {
      final updates = <bool>[];
      await tester.pumpWidget(
        _host(
          SeedSwitchMark(
            checked: false,
            enabled: false,
            tone: SeedControlTone.neutral,
            onCheckedChange: updates.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gray = _trackColor(tester);
      await tester.pumpWidget(
        _host(
          SeedSwitchMark(
            checked: true,
            enabled: false,
            tone: SeedControlTone.neutral,
            onCheckedChange: updates.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_trackColor(tester), gray);
      await tester.tap(find.byType(SeedSwitchMark));
      await tester.pump();
      expect(updates, isEmpty);
    });

    testWidgets(
      'controlled checked switch without callback stays visually enabled',
      (tester) async {
        for (final labeled in [false, true]) {
          Widget buildSwitch({required bool callback}) => labeled
              ? SeedSwitch(
                  checked: true,
                  label: 'Alerts',
                  onCheckedChange: callback ? (_) {} : null,
                )
              : SeedSwitchMark(
                  checked: true,
                  onCheckedChange: callback ? (_) {} : null,
                );
          Finder track() => find.descendant(
            of: labeled ? find.byType(SeedSwitch) : find.byType(SeedSwitchMark),
            matching: find.byType(AnimatedContainer),
          );

          await tester.pumpWidget(_host(buildSwitch(callback: true)));
          await tester.pumpAndSettle();
          final withCallback =
              (tester.widget<AnimatedContainer>(track()).decoration!
                      as BoxDecoration)
                  .color;
          await tester.pumpWidget(_host(buildSwitch(callback: false)));
          await tester.pumpAndSettle();
          final withoutCallback =
              (tester.widget<AnimatedContainer>(track()).decoration!
                      as BoxDecoration)
                  .color;
          expect(withoutCallback, withCallback, reason: 'label=$labeled');
          expect(
            tester
                .widget<Opacity>(
                  find.descendant(
                    of: labeled
                        ? find.byType(SeedSwitch)
                        : find.byType(SeedSwitchMark),
                    matching: find.byType(Opacity),
                  ),
                )
                .opacity,
            1.0,
            reason: 'Missing onCheckedChange does not imply CSS disabled',
          );
        }
      },
    );
  });

  group('activation', () {
    testWidgets(
      'switch mark and label execute only once and expose toggle state',
      (tester) async {
        var count = 0;
        await tester.pumpWidget(
          koreanAppCentered(
            SeedSwitch(value: true, label: '알림', onChanged: (_) => count++),
          ),
        );
        expect(
          tester.getSemantics(find.byType(SeedSwitch)),
          matchesSemantics(
            label: '알림',
            hasToggledState: true,
            isToggled: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        await tester.tap(find.text('알림'));
        expect(count, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        expect(count, 2);
      },
    );
  });

  group('switch row', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('switch row uses the visual mark without an extra touch box', (
      tester,
    ) async {
      var value = false;
      await tester.pumpWidget(
        scaledApp(
          SeedSwitchListItem(
            title: 'Switch',
            value: value,
            onChanged: (next) => value = next,
            showDivider: false,
          ),
        ),
      );
      expect(tester.getSize(find.byType(SeedSwitchListItem)).height, 56);
      await tester.tap(find.text('Switch'));
      expect(value, isTrue);
    });
  });

  group('state across label changes', () {
    Widget host({
      required bool labeled,
      bool? checked,
      bool defaultChecked = false,
      ValueChanged<bool>? onCheckedChange,
    }) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(
          child: SeedSwitch(
            key: const ValueKey('switch'),
            label: labeled ? 'Alerts' : null,
            semanticsLabel: 'Alerts',
            checked: checked,
            defaultChecked: defaultChecked,
            onCheckedChange: onCheckedChange,
          ),
        ),
      ),
    );

    void expectChecked(WidgetTester tester, bool checked) {
      final toggle = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.toggled != null,
      );
      final node = tester.getSemantics(toggle);
      expect(
        node,
        matchesSemantics(
          label: 'Alerts',
          hasToggledState: true,
          isToggled: checked,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          isFocused:
              node.getSemanticsData().flagsCollection.isFocused ==
              Tristate.isTrue,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    }

    for (final startsLabeled in [false, true]) {
      testWidgets(
        'uncontrolled switch retains state when label changes from $startsLabeled',
        (tester) async {
          final updates = <bool>[];
          await tester.pumpWidget(
            host(labeled: startsLabeled, onCheckedChange: updates.add),
          );
          expectChecked(tester, false);
          await tester.tap(find.byType(SeedSwitch));
          await tester.pump();
          expectChecked(tester, true);
          expect(updates, [true]);

          await tester.pumpWidget(
            host(labeled: !startsLabeled, onCheckedChange: updates.add),
          );
          expectChecked(tester, true);
          expect(updates, [true]);
          await tester.tap(find.byType(SeedSwitch));
          await tester.pump();
          expectChecked(tester, false);
          expect(updates, [true, false]);

          await tester.pumpWidget(
            host(
              labeled: startsLabeled,
              defaultChecked: true,
              onCheckedChange: updates.add,
            ),
          );
          expectChecked(tester, false);
          expect(updates, [true, false]);
        },
      );

      testWidgets(
        'controlled switch retains parent value when label changes from $startsLabeled',
        (tester) async {
          final updates = <bool>[];
          await tester.pumpWidget(
            host(
              labeled: startsLabeled,
              checked: true,
              onCheckedChange: updates.add,
            ),
          );
          expectChecked(tester, true);
          await tester.tap(find.byType(SeedSwitch));
          await tester.pump();
          expectChecked(tester, true);
          expect(updates, [false]);

          await tester.pumpWidget(
            host(
              labeled: !startsLabeled,
              checked: true,
              onCheckedChange: updates.add,
            ),
          );
          expectChecked(tester, true);
          expect(updates, [false]);
          await tester.pumpWidget(
            host(
              labeled: !startsLabeled,
              checked: false,
              onCheckedChange: updates.add,
            ),
          );
          expectChecked(tester, false);
          await tester.tap(find.byType(SeedSwitch));
          await tester.pump();
          expectChecked(tester, false);
          expect(updates, [false, true]);
          await tester.pumpWidget(
            host(
              labeled: startsLabeled,
              checked: false,
              onCheckedChange: updates.add,
            ),
          );
          expectChecked(tester, false);
          expect(updates, [false, true]);
        },
      );
    }
  });
}
