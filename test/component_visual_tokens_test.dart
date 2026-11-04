import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

import 'support/official_spec.dart';

Future<void> mount(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: (dark ? SeedThemeData.dark() : SeedThemeData.light())
          .toThemeData(),
      home: MediaQuery(
        data: MediaQueryData.fromView(tester.view).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: Center(
            child: SizedBox(width: 400, child: Align(child: child)),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
  expect(tester.takeException(), isNull);
}

Finder surface(Type type) => find
    .descendant(
      of: find.byType(type),
      matching: find.byWidgetPredicate(
        (w) =>
            (w is Container && w.decoration is BoxDecoration) ||
            (w is AnimatedContainer && w.decoration is BoxDecoration),
      ),
    )
    .first;
BoxDecoration decoration(WidgetTester tester, Type type) {
  final widget = tester.widget(surface(type));
  return (widget is Container
          ? widget.decoration
          : (widget as AnimatedContainer).decoration)
      as BoxDecoration;
}

TextStyle style(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label).first).style!;

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'every badge tone/variant/size uses official typography and color (dark=$dark)',
      (tester) async {
        for (final size in SeedBadgeSize.values) {
          for (final variant in SeedBadgeVariant.values) {
            for (final tone in SeedBadgeTone.values) {
              await mount(
                tester,
                SeedBadge(
                  label: 'Badge',
                  size: size,
                  tone: tone,
                  variant: variant,
                ),
                dark: dark,
              );
              final def = 'tone=${tone.name}, variant=${variant.name}';
              final root = decoration(tester, SeedBadge);
              final spec = officialSeed['components']['badge'][def]['enabled'];
              if (spec['root']['color'] != null) {
                expect(
                  root.color,
                  officialColor(spec['root']['color'], dark: dark),
                  reason: def,
                );
              }
              if (spec['root']['strokeColor'] != null) {
                expect(
                  root.border!.top.color,
                  officialColor(spec['root']['strokeColor'], dark: dark),
                  reason: def,
                );
              }
              expect(
                style(tester, 'Badge').color,
                officialColor(spec['label']['color'], dark: dark),
                reason: def,
              );
              expect(
                style(tester, 'Badge').fontWeight!.value,
                officialProp(
                  'badge',
                  'variant=${variant.name}',
                  'label',
                  'fontWeight',
                ),
              );
              expect(
                style(tester, 'Badge').fontSize,
                officialProp('badge', 'size=${size.name}', 'label', 'fontSize'),
              );
              expect(
                tester.getSize(surface(SeedBadge)).height,
                officialProp('badge', 'size=${size.name}', 'root', 'minHeight'),
              );
            }
          }
        }
      },
    );

    testWidgets(
      'chip variants retain official selected/disabled colors and medium weight (dark=$dark)',
      (tester) async {
        for (final variant in SeedChipVariant.values) {
          for (final selected in [false, true]) {
            for (final enabled in [false, true]) {
              await mount(
                tester,
                SeedChip(
                  label: 'Chip',
                  variant: variant,
                  selected: selected,
                  enabled: enabled,
                  onSelected: (_) {},
                ),
                dark: dark,
              );
              final state = selected ? 'selected' : 'enabled';
              final spec =
                  officialSeed['components']['chip']['variant=${variant.name}'];
              final expectedRoot = <String, dynamic>{
                ...spec['enabled']['root'],
                ...?spec[state]?['root'],
              };
              expect(
                decoration(tester, SeedChip).color,
                officialColor(expectedRoot['color'], dark: dark),
              );
              expect(style(tester, 'Chip').fontSize, 14);
              expect(style(tester, 'Chip').fontWeight, FontWeight.w500);
              expect(
                tester
                    .widget<Opacity>(
                      find
                          .descendant(
                            of: find.byType(SeedChip),
                            matching: find.byType(Opacity),
                          )
                          .first,
                    )
                    .opacity,
                enabled ? 1 : 0.5,
              );
            }
          }
        }
      },
    );

    testWidgets(
      'notification badges remain 18px with static text at 2x (dark=$dark)',
      (tester) async {
        await mount(
          tester,
          const SeedNotificationBadge(count: 5),
          dark: dark,
          scale: 2,
        );
        expect(
          tester.getSize(surface(SeedNotificationBadge)).height,
          officialProp('notification-badge', 'size=large', 'root', 'minHeight'),
        );
        expect(
          decoration(tester, SeedNotificationBadge).color,
          officialColor(r'$color.bg.brand-solid', dark: dark),
        );
        expect(
          tester.widget<Text>(find.text('5')).textScaler,
          TextScaler.noScaling,
        );
      },
    );

    testWidgets(
      'input outline/underline normal, focus, error, disabled and readonly (dark=$dark)',
      (tester) async {
        for (final variant in SeedTextInputVariant.values) {
          for (final state in [
            'normal',
            'focused',
            'invalid',
            'disabled',
            'readonly',
          ]) {
            await mount(
              tester,
              SeedTextInput(
                hintText: 'Input',
                variant: variant,
                hasError: state == 'invalid',
                enabled: state != 'disabled',
                readOnly: state == 'readonly',
                clearable: false,
              ),
              dark: dark,
            );
            if (state == 'focused') {
              await tester.tap(find.byType(TextField));
              await tester.pumpAndSettle();
            }
            final root = decoration(tester, SeedTextInput);
            final border = root.border!.bottom;
            expect(
              border.width,
              state == 'focused' || state == 'invalid' ? 2 : 1,
            );
            expect(
              border.color,
              officialColor(
                state == 'invalid'
                    ? r'$color.stroke.critical-solid'
                    : state == 'focused'
                    ? r'$color.stroke.neutral-contrast'
                    : r'$color.stroke.neutral-weak',
                dark: dark,
              ),
            );
            final minHeight = officialProp(
              'text-input',
              'variant=${variant.name},size=large',
              'root',
              'minHeight',
            ) as num;
            // Flutter may expand a field for platform font metrics or accessibility.
            expect(
              tester.getSize(surface(SeedTextInput)).height,
              greaterThanOrEqualTo(minHeight),
            );
            if (variant == SeedTextInputVariant.outline) {
              expect((root.borderRadius as BorderRadius).topLeft.x, 12);
            }
          }
        }
      },
    );
  }

  testWidgets(
    'radio and switch visuals retain official size, selected and disabled colors',
    (tester) async {
      for (final dark in [false, true]) {
        for (final enabled in [false, true]) {
          for (final selected in [false, true]) {
            for (final size in SeedRadioSize.values) {
              await mount(
                tester,
                SeedRadio<int>(
                  value: 1,
                  groupValue: selected ? 1 : 2,
                  enabled: enabled,
                  size: size,
                  onChanged: (_) {},
                ),
                dark: dark,
              );
              final radio = find
                  .descendant(
                    of: find.byType(SeedRadio<int>),
                    matching: find.byType(Container),
                  )
                  .first;
              expect(
                tester.getSize(radio).width,
                officialProp('radiomark', 'size=${size.name}', 'root', 'size'),
              );
              final root =
                  tester.widget<Container>(radio).decoration as BoxDecoration;
              expect(
                root.color,
                officialColor(
                  enabled && selected
                      ? r'$color.bg.brand-solid'
                      : !enabled && !selected
                      ? r'$color.palette.gray-300'
                      : r'$color.bg.transparent',
                  dark: dark,
                ),
              );
              if (selected) {
                final dot = find
                    .descendant(of: radio, matching: find.byType(Container))
                    .first;
                expect(
                  tester.getSize(dot).width,
                  officialProp(
                    'radiomark',
                    'size=${size.name}',
                    'icon',
                    'size',
                    state: enabled ? 'enabled' : 'disabled',
                  ),
                );
                expect(
                  (tester.widget<Container>(dot).decoration as BoxDecoration)
                      .color,
                  officialColor(
                    enabled
                        ? r'$color.fg.on-brand-solid'
                        : r'$color.palette.gray-300',
                    dark: dark,
                  ),
                );
              }
            }
            for (final size in SeedSwitchSize.values) {
              await mount(
                tester,
                SeedSwitchMark(
                  value: selected,
                  enabled: enabled,
                  size: size,
                  onChanged: (_) {},
                ),
                dark: dark,
              );
              final graphic = find
                  .descendant(
                    of: find.byType(SeedSwitchMark),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first;
              expect(
                tester.getSize(graphic),
                Size(size.trackWidth, size.trackHeight),
              );
              expect(
                (tester.widget<AnimatedContainer>(graphic).decoration
                        as BoxDecoration)
                    .color,
                officialColor(
                  selected
                      ? r'$color.bg.brand-solid'
                      : r'$color.palette.gray-600',
                  dark: dark,
                ),
              );
            }
          }
        }
      }
    },
  );

  testWidgets('floating buttons and callouts apply official pressed colors', (
    tester,
  ) async {
    final cases = <(Widget, Type, String)>[
      (
        SeedFloatingActionButton(icon: const Icon(Icons.add), onPressed: () {}),
        SeedFloatingActionButton,
        r'$color.bg.brand-solid-pressed',
      ),
      (
        SeedContextualFloatingButton(label: 'Label', onPressed: () {}),
        SeedContextualFloatingButton,
        r'$color.bg.neutral-solid-pressed',
      ),
      (
        SeedReactionButton(count: 2, onReactedChanged: (_) {}),
        SeedReactionButton,
        r'$color.bg.transparent-pressed',
      ),
      (
        SeedCallout(description: 'Label', onTap: () {}),
        SeedCallout,
        r'$color.bg.neutral-weak-pressed',
      ),
      (
        SeedPageBanner(title: 'Label', onTap: () {}),
        SeedPageBanner,
        r'$color.bg.neutral-weak-pressed',
      ),
      (
        SeedSelectBox(title: 'Label', onSelected: (_) {}),
        SeedSelectBox,
        r'$color.bg.transparent-pressed',
      ),
    ];
    for (final (widget, type, token) in cases) {
      await mount(tester, widget);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(type)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        decoration(tester, type).color,
        officialColor(token),
        reason: '$type pressed',
      );
      await gesture.up();
      await tester.pumpAndSettle();
    }
  });
}
