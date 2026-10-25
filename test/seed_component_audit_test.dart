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
        data: MediaQueryData(
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
  test('all control size enums match official component dimensions', () {
    for (final size in SeedButtonSize.values) {
      final variant = 'size=${size.name}';
      final textVariant = '$variant, layout=withText';
      expect(
        size.height,
        officialProp('action-button', variant, 'root', 'minHeight'),
        reason: size.name,
      );
      expect(
        size.padding.left,
        officialProp('action-button', textVariant, 'root', 'paddingX'),
        reason: size.name,
      );
      expect(
        size.padding.top,
        officialProp('action-button', textVariant, 'root', 'paddingY'),
        reason: size.name,
      );
      expect(
        size.borderRadius,
        BorderRadius.circular(
          (officialProp(
            'action-button',
            variant,
            'root',
            'cornerRadius',
          ) as num).toDouble(),
        ),
        reason: size.name,
      );
    }
    for (final size in SeedChipSize.values) {
      expect(
        size.height,
        officialProp('chip', 'size=${size.name}', 'root', 'height'),
      );
      expect(
        size.iconSize,
        officialProp('chip', 'size=${size.name}', 'prefixIcon', 'size'),
      );
    }
    for (final size in SeedSwitchSize.values) {
      final variant = 'size=${size.name.substring(4)}';
      expect(
        size.trackWidth,
        officialProp('switchmark', variant, 'root', 'width'),
      );
      expect(
        size.trackHeight,
        officialProp('switchmark', variant, 'root', 'height'),
      );
      expect(
        size.thumbSize,
        officialProp('switchmark', variant, 'thumb', 'width'),
      );
    }
    for (final size in SeedQuantityPickerSize.values) {
      expect(
        size.height,
        officialProp('quantity-picker', 'size=${size.name}', 'root', 'height'),
      );
      expect(
        size.iconSize,
        officialProp(
          'quantity-picker-button',
          'size=${size.name}',
          'icon',
          'size',
        ),
      );
    }
    for (final size in SeedReactionButtonSize.values) {
      expect(
        size.height,
        officialProp(
          'reaction-button',
          'size=${size.name}',
          'root',
          'minHeight',
        ),
      );
      expect(
        size.iconSize,
        officialProp(
          'reaction-button',
          'size=${size.name}',
          'prefixIcon',
          'size',
        ),
      );
    }
    for (final size in SeedInputButtonSize.values) {
      final variant = size == SeedInputButtonSize.medium
          ? 'size=large'
          : 'size=medium';
      expect(
        size.height,
        officialProp('input-button', variant, 'root', 'height'),
      );
      expect(
        size.paddingX,
        officialProp('input-button', variant, 'root', 'paddingX'),
      );
    }
  });

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

  testWidgets('rendered component labels and surfaces follow official geometry', (
    tester,
  ) async {
    final cases = <(Widget, Type, String, String, String, String)>[
      (
        SeedFloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: 'Label',
          onPressed: () {},
        ),
        SeedFloatingActionButton,
        'floating-action-button',
        'extended=true',
        'label',
        'Label',
      ),
      (
        SeedContextualFloatingButton(label: 'Label', onPressed: () {}),
        SeedContextualFloatingButton,
        'contextual-floating-button',
        'layout=withText',
        'label',
        'Label',
      ),
      (
        SeedReactionButton(count: 3, onReactedChanged: (_) {}),
        SeedReactionButton,
        'reaction-button',
        'size=small',
        'count',
        '3',
      ),
      (
        SeedQuantityPicker(value: 3, onChanged: (_) {}),
        SeedQuantityPicker,
        'quantity-picker',
        'size=medium',
        'valueDisplay',
        '3',
      ),
      (
        const SeedCallout(description: 'Label'),
        SeedCallout,
        'callout',
        'base',
        'description',
        'Label',
      ),
      (
        const SeedPageBanner(title: 'Label'),
        SeedPageBanner,
        'page-banner',
        'base',
        'description',
        'Label',
      ),
      (
        const SeedSnackbar(message: 'Label'),
        SeedSnackbar,
        'snackbar',
        'base',
        'message',
        'Label',
      ),
      (
        const SeedHelpBubble(title: 'Title', description: 'Label'),
        SeedHelpBubble,
        'help-bubble',
        'base',
        'description',
        'Label',
      ),
      (
        const SeedListItem(titleText: 'Label'),
        SeedListItem,
        'list-item',
        'base',
        'title',
        'Label',
      ),
      (
        const SeedAccordionItem(title: 'Label', content: SizedBox()),
        SeedAccordionItem,
        'accordion-item',
        'size=medium',
        'title',
        'Label',
      ),
      (
        const SeedSelectBox(title: 'Label'),
        SeedSelectBox,
        'select-box',
        'base',
        'label',
        'Label',
      ),
      (
        const SeedAlertDialog(title: 'Label', description: 'Description'),
        SeedAlertDialog,
        'alert-dialog',
        'base',
        'title',
        'Label',
      ),
      (
        const SeedDialog(title: 'Label', content: Text('Body')),
        SeedDialog,
        'dialog',
        'base',
        'title',
        'Label',
      ),
      (
        const SeedBottomSheet(title: 'Label', content: Text('Body')),
        SeedBottomSheet,
        'bottom-sheet',
        'base',
        'title',
        'Label',
      ),
      (
        const SeedMenu(
          groups: [
            SeedMenuGroupData(items: [SeedMenuItemData(label: 'Label')]),
          ],
        ),
        SeedMenu,
        'menu-item',
        'size=medium',
        'label',
        'Label',
      ),
    ];
    for (final (widget, type, component, variant, slot, label) in cases) {
      await mount(tester, widget);
      final actualStyle = style(tester, label);
      expect(
        actualStyle.fontSize,
        officialProp(component, variant, slot, 'fontSize'),
        reason: '$component font size',
      );
      expect(
        actualStyle.height! * actualStyle.fontSize!,
        closeTo(
          (officialProp(component, variant, slot, 'lineHeight') as num)
              .toDouble(),
          0.001,
        ),
        reason: '$component line height',
      );
      final radiusSpec =
          officialSeed['components'][component][variant]['enabled']['root']?['cornerRadius'];
      if (radiusSpec != null) {
        expect(
          (decoration(tester, type).borderRadius as BorderRadius).topLeft.x,
          resolveOfficial(radiusSpec),
          reason: component,
        );
      }
    }
  });

  testWidgets(
    'official gradient stops, fog size and progress thickness are applied',
    (tester) async {
      for (final placement in SeedScrollFogPlacement.values) {
        await mount(
          tester,
          SizedBox(
            width: 100,
            height: 100,
            child: Align(child: SeedScrollFog(placement: placement)),
          ),
        );
        final fog = find
            .descendant(
              of: find.byType(SeedScrollFog),
              matching: find.byType(Container),
            )
            .first;
        final box = tester.widget<Container>(fog);
        final gradient =
            (box.decoration as BoxDecoration).gradient as LinearGradient;
        expect(gradient.colors.length, 16);
        expect(
          placement == SeedScrollFogPlacement.top ||
                  placement == SeedScrollFogPlacement.bottom
              ? tester.getSize(fog).height
              : tester.getSize(fog).width,
          20,
        );
      }
      for (final size in [24.0, 40.0]) {
        await mount(tester, SeedProgressCircle(size: size, value: 0.5));
        expect(
          tester
              .widget<CircularProgressIndicator>(
                find.byType(CircularProgressIndicator),
              )
              .strokeWidth,
          size == 24 ? 3 : 5,
        );
      }
    },
  );
  testWidgets(
    'every rendered action button size/variant keeps the official minimum height',
    (tester) async {
      for (final size in SeedButtonSize.values) {
        for (final variant in SeedButtonVariant.values) {
          await mount(
            tester,
            SeedButton(
              label: 'Label',
              size: size,
              variant: variant,
              onPressed: () {},
            ),
          );
          expect(
            tester.getSize(surface(SeedButton)).height,
            officialProp(
              'action-button',
              'size=${size.name}',
              'root',
              'minHeight',
            ),
            reason: '${size.name}/${variant.name}',
          );
          expect(
            style(tester, 'Label').fontSize,
            officialProp(
              'action-button',
              'size=${size.name}, layout=withText',
              'label',
              'fontSize',
            ),
            reason: '${size.name}/${variant.name}',
          );
        }
      }
    },
  );

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
                      ? r'$color.bg.neutral-solid'
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
                        ? r'$color.fg.on-neutral-solid'
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
                  selected && enabled
                      ? r'$color.bg.neutral-solid'
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
        r'$color.bg.layer-floating-pressed',
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

  testWidgets(
    'wheel, time, calendar, result and compact navigation typography match official sources',
    (tester) async {
      await mount(
        tester,
        SeedWheelPicker(
          columns: [
            SeedWheelColumn.typed(items: ['Label'], initialIndex: 0),
          ],
        ),
      );
      expect(
        style(tester, 'Label').fontSize,
        officialProp('wheel-picker', 'size=medium', 'itemLabel', 'fontSize'),
      );
      await mount(tester, const SeedTimePicker());
      expect(
        style(tester, '오전').fontSize,
        officialProp('time-picker', 'base', 'item', 'fontSize'),
      );
      await mount(tester, SeedDatePicker(initialDate: DateTime(2026, 10, 20)));
      expect(
        style(tester, '20').fontSize,
        officialProp('date-picker', 'base', 'dateContent', 'fontSize'),
      );
      expect(
        style(tester, '일').fontSize,
        officialProp('date-picker', 'base', 'weekday', 'fontSize'),
      );
      for (final size in SeedResultSectionSize.values) {
        await mount(
          tester,
          SeedResultSection(
            title: 'Title',
            description: 'Description',
            size: size,
          ),
        );
        // docs/registry/react/ui/result-section.tsx (same pinned upstream revision).
        expect(
          style(tester, 'Title').fontSize,
          size == SeedResultSectionSize.large ? 22 : 16,
        );
        expect(
          style(tester, 'Description').fontSize,
          size == SeedResultSectionSize.large ? 16 : 14,
        );
      }
      await mount(
        tester,
        SeedBottomNavigation(
          items: const [
            SeedBottomNavigationItem(icon: Icon(Icons.home), label: 'Home'),
            SeedBottomNavigationItem(icon: Icon(Icons.chat), label: 'Chat'),
          ],
          currentIndex: 0,
          onTap: (_) {},
        ),
        scale: 2,
      );
      expect(
        tester.widget<Text>(find.text('Home')).textScaler,
        TextScaler.noScaling,
      );
    },
  );
}
