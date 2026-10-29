import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => mui.MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: mui.Scaffold(
    body: mui.Center(child: mui.SizedBox(width: 240, child: child)),
  ),
);

const _fruit = [
  SeedSelectGroup<String>(
    items: [
      SeedSelectItem(value: 'apple', label: '사과'),
      SeedSelectItem(value: 'banana', label: '바나나'),
      SeedSelectItem(value: 'cherry', label: '체리'),
    ],
  ),
];

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets(
      'keyboard-open controlled Select highlights selected item at $width',
      (tester) async {
        tester.view.physicalSize = mui.Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final proposed = <List<String>>[];
        await tester.pumpWidget(
          _host(
            SeedSelect<String>(
              groups: _fruit,
              value: const ['banana'],
              onValueChange: proposed.add,
            ),
          ),
        );
        final input = tester.widget<SeedInputButton>(
          find.byType(SeedInputButton),
        );
        expect(input.focusNode, isNotNull);
        input.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        final options = find.byType(mui.MenuItemButton);
        expect(options, findsNWidgets(3));
        final focus = tester
            .widget<mui.MenuItemButton>(options.at(1))
            .focusNode;
        expect(
          focus?.hasFocus,
          true,
          reason: 'React useSelectHighlight.ts seeds keyboard focus/highlight on selected banana',
        );
        expect(proposed, isEmpty);
      },
    );
  }

  testWidgets(
    'TimePicker defaultValue/initialTime seed three wheel columns; dynamic step count',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const SeedTimePicker(
            initialTime: mui.TimeOfDay(hour: 13, minute: 10),
            minuteStep: 10,
          ),
        ),
      );
      final wheel = tester.widget<SeedWheelPicker>(
        find.byType(SeedWheelPicker),
      );
      expect(wheel.columns.map((c) => c.itemCount).toList(), [2, 12, 6]);
      expect(wheel.columns.map((c) => c.initialIndex).toList(), [1, 1, 1]);
      await tester.pumpWidget(
        _host(
          const SeedTimePicker(
            defaultValue: mui.TimeOfDay(hour: 13, minute: 10),
            minuteStep: 15,
          ),
        ),
      );
      final next = tester.widget<SeedWheelPicker>(find.byType(SeedWheelPicker));
      expect(next.columns.map((c) => c.itemCount).toList(), [2, 12, 4]);
    },
  );

  testWidgets(
    'uncontrolled initialTime is a one-time seed, not an external controlled update',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const SeedTimePicker(
            initialTime: mui.TimeOfDay(hour: 11, minute: 20),
            minuteStep: 10,
          ),
        ),
      );
      final old = tester.widget<SeedWheelPicker>(find.byType(SeedWheelPicker));
      expect(old.columns.map((c) => c.initialIndex).toList(), [0, 11, 2]);
      await tester.pumpWidget(
        _host(
          const SeedTimePicker(
            initialTime: mui.TimeOfDay(hour: 7, minute: 40),
            minuteStep: 10,
          ),
        ),
      );
      final updated = tester.widget<SeedWheelPicker>(
        find.byType(SeedWheelPicker),
      );
      expect(updated.columns.map((c) => c.initialIndex).toList(), [0, 11, 2]);
    },
  );

  testWidgets(
    'controlled TimePicker value updates selected indexes without changing wheel item counts',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const SeedTimePicker(
            value: mui.TimeOfDay(hour: 13, minute: 10),
            minuteStep: 10,
          ),
        ),
      );
      await tester.pumpWidget(
        _host(
          const SeedTimePicker(
            value: mui.TimeOfDay(hour: 15, minute: 20),
            minuteStep: 10,
          ),
        ),
      );
      final wheel = tester.widget<SeedWheelPicker>(
        find.byType(SeedWheelPicker),
      );
      expect(wheel.columns.map((c) => c.itemCount).toList(), [2, 12, 6]);
      expect(wheel.columns.map((c) => c.index).toList(), [1, 3, 2]);
    },
  );
}
