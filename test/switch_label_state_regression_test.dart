import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host({
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

void _expectChecked(WidgetTester tester, bool checked) {
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
          node.getSemanticsData().flagsCollection.isFocused == Tristate.isTrue,
      hasTapAction: true,
      hasFocusAction: true,
    ),
  );
}

void main() {
  for (final startsLabeled in [false, true]) {
    testWidgets(
      'uncontrolled switch retains state when label changes from $startsLabeled',
      (tester) async {
        final updates = <bool>[];
        await tester.pumpWidget(
          _host(labeled: startsLabeled, onCheckedChange: updates.add),
        );
        _expectChecked(tester, false);
        await tester.tap(find.byType(SeedSwitch));
        await tester.pump();
        _expectChecked(tester, true);
        expect(updates, [true]);

        await tester.pumpWidget(
          _host(labeled: !startsLabeled, onCheckedChange: updates.add),
        );
        _expectChecked(tester, true);
        expect(updates, [true]);
        await tester.tap(find.byType(SeedSwitch));
        await tester.pump();
        _expectChecked(tester, false);
        expect(updates, [true, false]);

        await tester.pumpWidget(
          _host(
            labeled: startsLabeled,
            defaultChecked: true,
            onCheckedChange: updates.add,
          ),
        );
        _expectChecked(tester, false);
        expect(updates, [true, false]);
      },
    );

    testWidgets(
      'controlled switch retains parent value when label changes from $startsLabeled',
      (tester) async {
        final updates = <bool>[];
        await tester.pumpWidget(
          _host(
            labeled: startsLabeled,
            checked: true,
            onCheckedChange: updates.add,
          ),
        );
        _expectChecked(tester, true);
        await tester.tap(find.byType(SeedSwitch));
        await tester.pump();
        _expectChecked(tester, true);
        expect(updates, [false]);

        await tester.pumpWidget(
          _host(
            labeled: !startsLabeled,
            checked: true,
            onCheckedChange: updates.add,
          ),
        );
        _expectChecked(tester, true);
        expect(updates, [false]);
        await tester.pumpWidget(
          _host(
            labeled: !startsLabeled,
            checked: false,
            onCheckedChange: updates.add,
          ),
        );
        _expectChecked(tester, false);
        await tester.tap(find.byType(SeedSwitch));
        await tester.pump();
        _expectChecked(tester, false);
        expect(updates, [false, true]);
        await tester.pumpWidget(
          _host(
            labeled: startsLabeled,
            checked: false,
            onCheckedChange: updates.add,
          ),
        );
        _expectChecked(tester, false);
        expect(updates, [false, true]);
      },
    );
  }
}
