import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final kind in ['toggle', 'reaction', 'contextual', 'contextual icon']) {
    for (final loading in [false, true]) {
      for (final enabled in [false, true]) {
        for (final disableOnLoading in [true, false]) {
          testWidgets(
            '$kind loading=$loading enabled=$enabled disableOnLoading=$disableOnLoading',
            (tester) async {
              var calls = 0;
              final values = <bool>[];
              final key = GlobalKey();
              Widget button() => switch (kind) {
                'toggle' => SeedToggleButton(
                  key: key,
                  label: 'Action',
                  loading: loading,
                  enabled: enabled,
                  disableOnLoading: disableOnLoading,
                  onPressedChange: (value) {
                    calls++;
                    values.add(value);
                  },
                ),
                'reaction' => SeedReactionButton(
                  key: key,
                  label: 'Action',
                  loading: loading,
                  enabled: enabled,
                  disableOnLoading: disableOnLoading,
                  onPressedChange: (value) {
                    calls++;
                    values.add(value);
                  },
                ),
                'contextual' => SeedContextualFloatingButton(
                  key: key,
                  label: 'Action',
                  loading: loading,
                  enabled: enabled,
                  disableOnLoading: disableOnLoading,
                  onPressed: () => calls++,
                ),
                _ => SeedContextualFloatingButton.iconOnly(
                  key: key,
                  icon: const Icon(Icons.add),
                  semanticsLabel: 'Action',
                  loading: loading,
                  enabled: enabled,
                  disableOnLoading: disableOnLoading,
                  onPressed: () => calls++,
                ),
              };
              await tester.pumpWidget(_host(button()));
              final expectedInteractive =
                  enabled && (!loading || !disableOnLoading);
              final semantics = tester.ensureSemantics();
              final data = tester
                  .getSemantics(find.byKey(key))
                  .getSemanticsData();
              expect(data.label, 'Action');
              expect(
                data.flagsCollection.isEnabled,
                expectedInteractive ? Tristate.isTrue : Tristate.isFalse,
              );
              expect(data.hasAction(SemanticsAction.tap), expectedInteractive);
              expect(
                find.byType(SeedProgressCircle),
                loading ? findsOneWidget : findsNothing,
              );
              await tester.tap(find.byKey(key));
              await tester.pump();
              expect(calls, expectedInteractive ? 1 : 0);
              if (expectedInteractive) {
                await tester.sendKeyEvent(LogicalKeyboardKey.tab);
                await tester.pump();
                await tester.sendKeyEvent(LogicalKeyboardKey.enter);
                await tester.pump();
                await tester.sendKeyEvent(LogicalKeyboardKey.space);
                await tester.pump();
                expect(calls, 3);
                if (kind == 'toggle' || kind == 'reaction') {
                  expect(values, [true, false, true]);
                }
              }
              semantics.dispose();
            },
          );
        }
      }
    }
  }

  testWidgets('new controls block loading by default', (tester) async {
    var calls = 0;
    for (final button in <Widget>[
      SeedToggleButton(
        label: 'Action',
        loading: true,
        onPressedChange: (_) => calls++,
      ),
      SeedReactionButton(
        label: 'Action',
        loading: true,
        onPressedChange: (_) => calls++,
      ),
      SeedContextualFloatingButton(
        label: 'Action',
        loading: true,
        onPressed: () => calls++,
      ),
      SeedContextualFloatingButton.iconOnly(
        icon: const Icon(Icons.add),
        semanticsLabel: 'Action',
        loading: true,
        onPressed: () => calls++,
      ),
    ]) {
      await tester.pumpWidget(_host(button));
      await tester.tap(find.byWidget(button));
      await tester.pump();
      expect(calls, 0);
      expect(
        tester
            .getSemantics(find.byWidget(button))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
    }
  });

  testWidgets(
    'controlled loading toggles report proposed value without mutating state',
    (tester) async {
      final values = <bool>[];
      for (final button in <Widget>[
        SeedToggleButton(
          label: 'Action',
          pressed: false,
          loading: true,
          disableOnLoading: false,
          onPressedChange: values.add,
        ),
        SeedReactionButton(
          label: 'Action',
          pressed: false,
          loading: true,
          disableOnLoading: false,
          onPressedChange: values.add,
        ),
      ]) {
        await tester.pumpWidget(_host(button));
        await tester.tap(find.byWidget(button));
        await tester.pump();
        await tester.tap(find.byWidget(button));
        await tester.pump();
      }
      expect(values, [true, true, true, true]);
    },
  );
}
