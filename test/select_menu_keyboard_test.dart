import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'PKG-06 default Select keeps keyboard in menu and closes on Escape $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 844);
        addTearDown(tester.view.reset);
        final triggerHost = FocusNode(debugLabel: 'select-host');
        final background = FocusNode(debugLabel: 'background');
        final openEvents = <(bool, SeedOverlayDismissReason)>[];
        final values = <List<int>>[];
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Column(
                  children: [
                    Focus(
                      focusNode: triggerHost,
                      child: SizedBox(
                        width: 280,
                        child: SeedSelect<int>(
                          groups: const [
                            SeedSelectGroup(
                              items: [
                                SeedSelectItem(value: 1, label: 'Apple'),
                                SeedSelectItem(value: 2, label: 'Banana'),
                              ],
                            ),
                          ],
                          placeholder: 'Choose fruit',
                          onOpenChange: (open, reason) =>
                              openEvents.add((open, reason)),
                          onValueChange: values.add,
                        ),
                      ),
                    ),
                    TextField(
                      focusNode: background,
                      decoration: const InputDecoration(
                        labelText: 'Background',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.tap(find.text('Choose fruit'));
          await tester.pumpAndSettle();
          bool isOpen() => tester
              .widget<MenuAnchor>(find.byType(MenuAnchor))
              .controller!
              .isOpen;
          expect(isOpen(), isTrue);
          final options = tester
              .widgetList<MenuItemButton>(find.byType(MenuItemButton))
              .toList();
          expect(options, hasLength(2));
          expect(
            options[0].focusNode!.hasFocus,
            isTrue,
            reason: 'Opening Select puts keyboard focus on the first option',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(
            options[1].focusNode!.hasFocus,
            isTrue,
            reason: 'ArrowDown should move highlight to the next option',
          );
          expect(
            background.hasFocus,
            isFalse,
            reason: 'ArrowDown highlights menu option, never the page input',
          );
          expect(isOpen(), isTrue);
          expect(values, isEmpty);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(
            isOpen(),
            isFalse,
            reason: 'Escape closes the Select after ArrowDown',
          );
          expect(
            triggerHost.hasFocus,
            isTrue,
            reason: 'Keyboard dismiss returns to the trigger',
          );
          expect(openEvents.last.$1, isFalse);
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          triggerHost.dispose();
          background.dispose();
        }
      },
    );
  }

  testWidgets('PKG-06 Tab beyond last option dismisses the non-modal listbox', (
    tester,
  ) async {
    final background = FocusNode();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                const SeedSelect<String>(
                  groups: [
                    SeedSelectGroup(
                      items: [SeedSelectItem(value: 'a', label: 'Apple')],
                    ),
                  ],
                  placeholder: 'Choose fruit',
                ),
                TextField(focusNode: background),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Choose fruit'));
      await tester.pumpAndSettle();
      final menu = tester
          .widget<MenuAnchor>(find.byType(MenuAnchor))
          .controller!;
      expect(menu.isOpen, isTrue);
      final option = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
      expect(option.focusNode!.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        menu.isOpen,
        isFalse,
        reason:
            'React FloatingFocusManager closes Select when Tab leaves listbox',
      );
      expect(
        background.hasFocus,
        isTrue,
        reason: 'Tab should advance to the next field',
      );
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      background.dispose();
    }
  });

  testWidgets('PKG-06 Shift+Tab closes Select and visits previous control', (
    tester,
  ) async {
    final before = FocusNode();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                TextButton(
                  focusNode: before,
                  onPressed: () {},
                  child: const Text('Before'),
                ),
                const SeedSelect<String>(
                  groups: [
                    SeedSelectGroup(
                      items: [SeedSelectItem(value: 'a', label: 'Apple')],
                    ),
                  ],
                  placeholder: 'Choose fruit',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Choose fruit'));
      await tester.pumpAndSettle();
      final menu = tester
          .widget<MenuAnchor>(find.byType(MenuAnchor))
          .controller!;
      expect(menu.isOpen, isTrue);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(menu.isOpen, isFalse);
      expect(before.hasFocus, isTrue);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      before.dispose();
    }
  });

  testWidgets('PKG-06 controlled open emits focusOut proposal on Tab without closing', (tester) async {
    final proposals = <(bool, SeedOverlayDismissReason)>[];
    await tester.pumpWidget(MaterialApp(
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: Scaffold(body: Column(children: [
        SeedSelect<String>(
          open: true,
          onOpenChange: (open, reason) => proposals.add((open, reason)),
          groups: const [SeedSelectGroup(items: [SeedSelectItem(value: 'a', label: 'Apple')])],
        ),
        const TextField(),
      ])),
    ));
    await tester.pumpAndSettle();
    final controller = tester.widget<MenuAnchor>(find.byType(MenuAnchor)).controller!;
    expect(controller.isOpen, isTrue);
    final option = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
    expect(option.focusNode!.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(proposals, [(false, SeedOverlayDismissReason.focusOut)]);
    expect(controller.isOpen, isTrue, reason: 'parent open=true remains authoritative');
    expect(tester.takeException(), isNull);
  });
}
