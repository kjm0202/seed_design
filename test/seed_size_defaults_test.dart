import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/official_spec.dart';

void main() {
  final defaults =
      jsonDecode(
            File('test/fixtures/seed_size_defaults_reference.json')
                .readAsStringSync(),
          )['components']
          as Map<String, dynamic>;

  test('omitted sizes match official recipe and snippet defaults', () {
    final actual = <String, Object>{
      'accordion': const SeedAccordionItem(
        title: '',
        content: SizedBox(),
      ).size.name,
      'action-button': const SeedButton(label: '', onPressed: null).size.name,
      'avatar': const SeedAvatar().size.dimension.toInt(),
      'avatar-stack': const SeedAvatarStack(children: []).size.dimension
          .toInt(),
      'badge': const SeedBadge(label: '').size.name,
      'checkbox': const SeedCheckbox(value: false, onChanged: null).size.name,
      'chip': const SeedChip(label: '').size.name,
      'chip-tabs': SeedTabs(
        items: const [SeedTabItem(label: 'Tab')],
        selectedIndex: 0,
        variant: SeedTabsVariant.chipSolid,
        onTabSelected: (_) {},
      ).size.name,
      // The legacy Flutter name `medium` represents official `large` (52px).
      'input-button': const SeedInputButton().size.height == 52
          ? 'large'
          : 'medium',
      'progress-circle': const SeedProgressCircle().size.toInt(),
      'quantity-picker': const SeedQuantityPicker(
        value: 1,
        onChanged: null,
      ).size.name,
      'radio': const SeedRadio<int>(value: 1, groupValue: 1).size.name,
      'reaction-button': const SeedReactionButton().size.name,
      'switch': const SeedSwitch(
        value: false,
        onChanged: null,
      ).size.trackHeight.toInt(),
      'switchmark': const SeedSwitchMark(
        value: false,
        onChanged: null,
      ).size.trackHeight.toInt(),
      'tabs': SeedTabs(
        items: const [SeedTabItem(label: 'Tab')],
        selectedIndex: 0,
        onTabSelected: (_) {},
      ).size.name,
      'tag-group': const SeedTagGroup(items: []).size.name,
      'text-input': const SeedTextInput().size.name,
      'toggle-button': const SeedToggleButton(
        label: 'Toggle',
        selected: false,
        onSelectedChanged: null,
      ).size.name,
      'wheel-picker': const SeedWheelPicker(columns: []).size.name,
      'result-section': const SeedResultSection(title: '').size.name,
    };
    for (final entry in actual.entries) {
      expect(entry.value, defaults[entry.key]['size'], reason: entry.key);
    }
    expect(
      const SeedDialog(title: '', content: SizedBox()).maxWidth,
      officialProp(
        'dialog',
        'size=${defaults['dialog']['size']}',
        'content',
        'maxWidth',
      ),
    );
    expect(
      const SeedSidePanel(title: '', body: SizedBox()).width,
      officialProp(
        'side-panel',
        'size=${defaults['side-panel']['size']}',
        'content',
        'width',
      ),
    );
    expect(
      const SeedSelect<int>(groups: []).size.height,
      officialProp(
        'select-trigger',
        'size=${defaults['select']['size']}',
        'root',
        'height',
      ),
    );
  });

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: Center(
              child: SizedBox(width: 320, child: Align(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('all input sizes and variants retain official minimum heights', (
    tester,
  ) async {
    for (final scale in [1.0, 2.0]) {
      for (final size in SeedTextInputSize.values) {
        for (final variant in SeedTextInputVariant.values) {
          for (final lines in [1, 3]) {
            await mount(
              tester,
              SeedTextInput(
                key: ValueKey('$scale/$size/$variant/$lines'),
                size: size,
                variant: variant,
                maxLines: lines,
                hintText: '상품명',
              ),
              scale: scale,
            );
            final spec = lines == 1
                ? 'variant=${variant.name},size=${size.name}'
                : 'type=multiline,size=${size.name}';
            expect(
              tester.getSize(find.byType(SeedTextInput)).height,
              greaterThanOrEqualTo(
                officialProp('text-input', spec, 'root', 'minHeight'),
              ),
              reason: '$spec, text scale $scale',
            );
          }
        }
      }
    }
    await mount(tester, const SeedTextInput(hintText: '상품명'));
    expect(tester.getSize(find.byType(SeedTextInput)).height, 52);
    expect(
      tester.widget<TextField>(find.byType(TextField)).style!.fontSize,
      16,
    );
    await mount(tester, const SeedInputButton(placeholder: '선택'));
    expect(tester.getSize(find.byType(SeedInputButton)).height, 52);
    await mount(tester, const SeedSelect<int>(groups: []));
    expect(tester.getSize(find.byType(SeedInputButton)).height, 52);
  });

  testWidgets('corrected defaults render at their official dimensions', (
    tester,
  ) async {
    await mount(tester, const SeedAvatar());
    expect(tester.getSize(find.byType(SeedAvatar)), const Size(48, 48));
    await mount(tester, const SeedAvatarStack(children: [SeedAvatar()]));
    expect(tester.getSize(find.byType(SeedAvatarStack)).height, 48);
    await mount(tester, const SeedProgressCircle(value: 0.5));
    expect(tester.getSize(find.byType(SeedProgressCircle)), const Size(40, 40));
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .strokeWidth,
      5,
    );
    for (final widget in [
      SeedSwitch(value: false, onChanged: (_) {}),
      SeedSwitchMark(value: false, onChanged: (_) {}),
    ]) {
      await mount(tester, widget);
      expect(
        tester.getSize(find.byType(AnimatedContainer)),
        const Size(52, 32),
      );
    }
    for (final size in SeedToggleButtonSize.values) {
      await mount(
        tester,
        SeedToggleButton(
          label: 'Toggle',
          prefixIcon: const Icon(Icons.add),
          size: size,
          selected: false,
          onSelectedChanged: (_) {},
        ),
      );
      expect(
        tester.getSize(find.byType(SeedToggleButton)).height,
        officialProp('toggle-button', 'size=${size.name}', 'root', 'minHeight'),
      );
      final iconContext = tester.element(find.byIcon(Icons.add));
      expect(
        IconTheme.of(iconContext).size,
        officialProp(
          'toggle-button',
          'size=${size.name}',
          'prefixIcon',
          'size',
        ),
      );
    }
    for (final variant in SeedTabsVariant.values) {
      await mount(
        tester,
        SeedTabs(
          items: const [SeedTabItem(label: 'Tab')],
          selectedIndex: 0,
          variant: variant,
          onTabSelected: (_) {},
        ),
      );
      expect(
        tester.getSize(find.byType(SeedTabs)).height,
        variant == SeedTabsVariant.line ? 40 : 36,
      );
    }
  });

  testWidgets('required marks scale with labels and retain the top offset', (
    tester,
  ) async {
    for (final scale in [1.0, 2.0]) {
      await mount(
        tester,
        const SeedField(label: '상품명', required: true, child: SizedBox()),
        scale: scale,
      );
      final mark = find.descendant(
        of: find.byType(SeedField),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      final labelRect = tester.getRect(find.text('상품명'));
      final markRect = tester.getRect(mark);
      expect(markRect.size, Size(6 * scale, 6 * scale));
      expect(markRect.top - labelRect.top, 4 * scale);
      expect(markRect.left - labelRect.right, 2 * scale);
    }
  });
}
