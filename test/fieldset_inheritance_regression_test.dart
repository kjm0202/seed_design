import 'dart:ui' show Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets(
    'disabled fieldset blocks action buttons and custom text editors',
    (tester) async {
      final node = FocusNode();
      var actions = 0;
      await tester.pumpWidget(
        _host(
          SeedFieldset(
            enabled: false,
            child: Column(
              children: [
                SeedButton(label: 'Submit', onPressed: () => actions++),
                SeedTextInput(
                  focusNode: node,
                  inputBuilder: (_, controller, focusNode) =>
                      TextField(controller: controller, focusNode: focusNode),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      node.requestFocus();
      await tester.pump();
      expect(actions, 0);
      expect(node.hasFocus, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      node.dispose();
    },
  );

  testWidgets('fieldset disabled state reaches inputs, updates and semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController(text: 'initial');
    final textFocus = FocusNode();
    final buttonFocus = FocusNode();
    var presses = 0;
    var changes = 0;
    Widget app(bool enabled) => _host(
      SeedFieldset(
        enabled: enabled,
        label: 'Group',
        child: Column(
          children: [
            SeedTextInput(
              controller: controller,
              focusNode: textFocus,
              semanticsLabel: 'Editor',
              onChanged: (_) => changes++,
            ),
            SeedInputButton(
              value: 'Choice',
              focusNode: buttonFocus,
              onPressed: () => presses++,
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(app(true));
    await tester.enterText(find.byType(TextField), 'edited');
    await tester.tap(find.text('Choice'));
    expect(controller.text, 'edited');
    expect(presses, 1);
    expect(changes, 1);

    await tester.pumpWidget(app(false));
    await tester.pumpAndSettle();
    final text = tester.widget<TextField>(find.byType(TextField));
    expect(text.enabled, isFalse);
    final textNode = tester.getSemantics(find.byType(TextField));
    expect(
      textNode.getSemanticsData().flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    final buttonNode = tester.getSemantics(find.text('Choice'));
    expect(
      buttonNode.getSemanticsData().flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    await tester.tap(find.text('Choice'));
    buttonFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(textFocus.hasFocus, isFalse);
    expect(presses, 1);
    expect(controller.text, 'edited');
    expect(changes, 1);

    await tester.pumpWidget(app(true));
    await tester.enterText(find.byType(TextField), 'restored');
    expect(controller.text, 'restored');
    expect(changes, 2);
    await tester.tap(find.text('Choice'));
    expect(presses, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    textFocus.dispose();
    buttonFocus.dispose();
    controller.dispose();
    semantics.dispose();
  });

  testWidgets('inner enabled scope cannot override disabled ancestor', (
    tester,
  ) async {
    var presses = 0;
    Widget app(bool outerEnabled) => _host(
      SeedControlScope(
        enabled: outerEnabled,
        child: SeedControlScope(
          enabled: true,
          child: Column(
            children: [
              const SeedTextInput(),
              SeedInputButton(value: 'Open', onPressed: () => presses++),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(app(false));
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.tap(find.text('Open'));
    expect(presses, 0);
    await tester.pumpWidget(app(true));
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    await tester.tap(find.text('Open'));
    expect(presses, 1);
  });

  testWidgets('ancestor changes notify a stable nested subtree', (
    tester,
  ) async {
    const child = SeedControlScope(enabled: true, child: SeedTextInput());
    Widget app(bool enabled) =>
        _host(SeedControlScope(enabled: enabled, child: child));

    await tester.pumpWidget(app(true));
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    await tester.pumpWidget(app(false));
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.pumpWidget(app(true));
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
  });

  testWidgets(
    'read-only text remains focusable and disabled clear actions vanish',
    (tester) async {
      final focus = FocusNode();
      final controller = TextEditingController(text: 'value');
      var clears = 0;
      Widget app(bool enabled) => _host(
        SeedFieldset(
          enabled: enabled,
          child: Column(
            children: [
              SeedTextInput(
                controller: controller,
                focusNode: focus,
                readOnly: true,
                clearable: true,
              ),
              SeedInputButton(
                value: 'Choice',
                showClear: true,
                onClear: () => clears++,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(app(true));
      final text = tester.widget<TextField>(find.byType(TextField));
      expect(text.enabled, isTrue);
      expect(text.readOnly, isTrue);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      await tester.pumpWidget(app(false));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(focus.hasFocus, isFalse);
      expect(find.byIcon(Icons.cancel), findsNothing);
      expect(clears, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      focus.dispose();
      controller.dispose();
    },
  );
}
