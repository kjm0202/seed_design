import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

const _items = [
  SeedSelectGroup<String>(
    items: [
      SeedSelectItem(value: 'apple', label: 'Apple'),
      SeedSelectItem(value: 'banana', label: 'Banana'),
    ],
  ),
];

void main() {
  for (final width in [390.0, 800.0]) {
    for (final side in [null, SeedOverlaySide.bottom]) {
      testWidgets('PACKAGE-08 readonly focus and activation $width $side', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 844);
        addTearDown(tester.view.reset);
        final before = FocusNode();
        final after = FocusNode();
        final semantics = tester.ensureSemantics();
        var changes = 0;
        final opened = <bool>[];
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      focusNode: before,
                      onPressed: () {},
                      child: const Text('Before'),
                    ),
                    SeedSelect<String>(
                      key: const Key('readonly'),
                      groups: _items,
                      defaultValue: const ['banana'],
                      readOnly: true,
                      side: side,
                      onValueChange: (_) => changes++,
                      onOpenStateChanged: opened.add,
                    ),
                    const SeedSelect<String>(
                      groups: _items,
                      enabled: false,
                      defaultValue: ['apple'],
                    ),
                    TextButton(
                      focusNode: after,
                      onPressed: () {},
                      child: const Text('After'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final readonly = find.byKey(const Key('readonly'));
          final detector = tester.widget<FocusableActionDetector>(
            find
                .descendant(
                  of: readonly,
                  matching: find.byType(FocusableActionDetector),
                )
                .first,
          );
          before.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          expect(
            detector.focusNode!.hasFocus,
            isTrue,
            reason: 'readonly remains a Tab stop',
          );
          final node = tester.getSemantics(
            find
                .descendant(
                  of: readonly,
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is Semantics &&
                        widget.properties.readOnly == true &&
                        widget.properties.enabled == true,
                  ),
                )
                .first,
          );
          expect(node.flagsCollection.isReadOnly, isTrue);
          expect(node.flagsCollection.isEnabled, ui.Tristate.isTrue);

          for (final key in [
            LogicalKeyboardKey.arrowDown,
            LogicalKeyboardKey.enter,
            LogicalKeyboardKey.space,
          ]) {
            await tester.sendKeyEvent(key);
            await tester.pumpAndSettle();
          }
          await tester.tap(find.text('Banana'));
          await tester.pumpAndSettle();
          expect(opened, isEmpty);
          expect(changes, 0);
          expect(find.text('Banana'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          expect(after.hasFocus, isTrue, reason: 'disabled select is skipped');
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
          await tester.pumpWidget(const SizedBox.shrink());
          before.dispose();
          after.dispose();
        }
      });
    }
  }
  testWidgets(
    'PACKAGE-08 readonly Field label and external focus stay connected',
    (tester) async {
      final external = FocusNode();
      try {
        Future<void> mount() => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SeedField(
                label: 'Field label',
                focusNode: external,
                child: SeedSelect<String>(
                  groups: _items,
                  defaultValue: const ['banana'],
                  readOnly: true,
                ),
              ),
            ),
          ),
        );
        await mount();
        await tester.tap(find.text('Field label'));
        await tester.pumpAndSettle();
        expect(external.hasPrimaryFocus, isTrue);
        external.unfocus();
        await tester.pumpAndSettle();
        external.requestFocus();
        await tester.pumpAndSettle();
        expect(external.hasPrimaryFocus, isTrue);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        external.dispose();
      }
    },
  );
  testWidgets('PACKAGE-08 built-in label focuses readonly Select', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeedSelect<String>(
            groups: _items,
            defaultValue: ['banana'],
            readOnly: true,
            label: 'Select label',
          ),
        ),
      ),
    );
    await tester.tap(find.text('Select label'));
    await tester.pumpAndSettle();
    final detector = tester.widget<FocusableActionDetector>(
      find.byType(FocusableActionDetector).first,
    );
    expect(detector.focusNode!.hasPrimaryFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('PACKAGE-08 FieldButton readonly still disallows focus', (
    tester,
  ) async {
    final focus = FocusNode();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedInputButton(
              value: 'Field',
              readOnly: true,
              focusNode: focus,
              onPressed: () {},
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      expect(focus.canRequestFocus, isFalse);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      focus.dispose();
    }
  });
}
