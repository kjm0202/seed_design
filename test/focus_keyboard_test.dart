import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';





Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  setUpAll(loadSeedTestFonts);
  group('focus visibility and disabled controls', () {
    for (final keyboardReturn in [false, true]) {
      testWidgets(
        'restored focus follows the last input method (keyboard=$keyboardReturn)',
        (tester) async {
          final manager = FocusManager.instance;
          final previousStrategy = manager.highlightStrategy;
          manager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
          addTearDown(() => manager.highlightStrategy = previousStrategy);
          final launchFocus = FocusNode();
          final backFocus = FocusNode();
          addTearDown(launchFocus.dispose);
          addTearDown(backFocus.dispose);
          await tester.pumpWidget(
            MaterialApp(
              supportedLocales: const [Locale('en'), Locale('ko')],
              locale: const Locale('ko'),
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: Builder(
                  builder: (context) => SeedPressable(
                    focusNode: launchFocus,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => Scaffold(
                          body: TextButton(
                            focusNode: backFocus,
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back'),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Open page'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.text('Open page'),
            kind: PointerDeviceKind.mouse,
          );
          await tester.pumpAndSettle();
          if (keyboardReturn) {
            backFocus.requestFocus();
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          } else {
            await tester.tap(find.text('Back'), kind: PointerDeviceKind.mouse);
          }
          await tester.pumpAndSettle();

          expect(launchFocus.hasFocus, isTrue);
          final box = tester.widget<DecoratedBox>(
            find.descendant(
              of: find.byType(SeedPressable),
              matching: find.byType(DecoratedBox),
            ),
          );
          final border = (box.decoration as BoxDecoration).border;
          expect(border, keyboardReturn ? isNotNull : isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }

    testWidgets('pointer focus stays hidden until keyboard interaction', (
      tester,
    ) async {
      final manager = FocusManager.instance;
      final previousStrategy = manager.highlightStrategy;
      manager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => manager.highlightStrategy = previousStrategy);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var activations = 0;
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedPressable(
                focusNode: focusNode,
                onTap: () => activations++,
                child: const SizedBox(
                  width: 100,
                  height: 48,
                  child: Text('Action'),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('After')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      Border? focusBorder() {
        final box = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(SeedPressable),
            matching: find.byType(DecoratedBox),
          ),
        );
        return (box.decoration as BoxDecoration).border as Border?;
      }

      await tester.tap(find.text('Action'), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue);
      expect(activations, 1);
      expect(focusBorder(), isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(activations, 2);
      expect(focusBorder()?.top.width, 2);

      await tester.tap(find.text('Action'), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(activations, 3);
      expect(focusBorder(), isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(activations, 4);
      expect(focusBorder()?.top.width, 2);

      await tester.tap(find.text('Action'), kind: PointerDeviceKind.mouse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isFalse);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue);
      expect(focusBorder()?.top.width, 2);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'disabled controls ignore semantic, pointer and keyboard activation',
      (tester) async {
        var calls = 0;
        await tester.pumpWidget(
          host(
            SeedButton(
              label: 'Disabled',
              enabled: false,
              onPressed: () => calls++,
            ),
          ),
        );
        await tester.tap(find.text('Disabled'));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(calls, 0);
      },
    );
  });
}
