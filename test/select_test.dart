import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _appTypeahead(Widget child, {bool scaffold = true}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: scaffold ? Scaffold(body: Center(child: child)) : Center(child: child),
);

Widget _host(Widget child, {double width = 300}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

const _items = [
  SeedSelectGroup<String>(
    items: [
      SeedSelectItem(value: 'apple', label: 'Apple'),
      SeedSelectItem(value: 'banana', label: 'Banana'),
    ],
  ),
];

Widget _hostSelectTimeContract(Widget child) => mui.MaterialApp(
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

Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

Widget hostInputOverlayRegression(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostReactParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

void main() {
  setUpAll(loadSeedTestFonts);

  group('Select default overlay', () {
    Future<void> pumpSelect(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: SeedSelect<int>(
                  placeholder: 'Pick',
                  groups: const [
                    SeedSelectGroup(
                      items: [
                        SeedSelectItem(value: 1, label: 'One'),
                        SeedSelectItem(value: 2, label: 'Two', enabled: false),
                        SeedSelectItem(value: 3, label: 'Three'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'closing returns focus to the trigger, not an earlier control',
      (tester) async {
        final earlier = FocusNode();
        addTearDown(earlier.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  TextField(focusNode: earlier),
                  SizedBox(
                    width: 200,
                    child: SeedSelect<int>(
                      placeholder: 'Pick',
                      groups: const [
                        SeedSelectGroup(
                          items: [SeedSelectItem(value: 1, label: 'One')],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        earlier.requestFocus();
        await tester.pump();
        await tester.tap(find.text('Pick'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('One'), findsNothing);
        expect(earlier.hasFocus, isFalse);
      },
    );

    // Measured on the official example: a 154px list flips below 170px of room.
    for (final (space, flipsUp) in [(169.0, true), (170.0, false)]) {
      testWidgets('with ${space}px below it opens ${flipsUp ? 'up' : 'down'}', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(390, 600 + 40 + space);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: 600,
                    left: 16,
                    width: 200,
                    child: SeedSelect<int>(
                      placeholder: 'Pick',
                      size: SeedInputButtonSize.large,
                      groups: const [
                        SeedSelectGroup(
                          items: [
                            SeedSelectItem(value: 1, label: 'One'),
                            SeedSelectItem(value: 2, label: 'Two'),
                            SeedSelectItem(value: 3, label: 'Three'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        final trigger = tester.getRect(find.byType(SeedInputButton));
        final view = tester.view.physicalSize.height;
        final room = view - trigger.bottom;
        tester.view.physicalSize = Size(390, view + space - room);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pick'));
        await tester.pumpAndSettle();
        final list = tester.getTopLeft(find.text('One'));
        final surface = tester.getRect(
          find
              .ancestor(
                of: find.text('One'),
                matching: find.byType(DecoratedBox),
              )
              .last,
        );
        expect(surface.height, 154, reason: 'the size this threshold assumes');
        expect(
          list.dy < tester.getRect(find.byType(SeedInputButton)).top,
          flipsUp,
        );
      });
    }

    testWidgets('closed trigger opens with vertical arrows', (tester) async {
      await pumpSelect(tester);
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget, reason: 'now the trigger value');
      expect(find.text('Three'), findsNothing);
    });

    for (final (name, show)
        in <(String, Future<void> Function(BuildContext, Widget))>[
          (
            'dialog',
            (context, child) => showSeedDialog<void>(
              context: context,
              builder: (_) => SeedDialog(title: 'Layer', content: child),
            ),
          ),
          (
            'bottom sheet',
            (context, child) => showSeedBottomSheet<void>(
              context: context,
              builder: (_) => SeedBottomSheet(title: 'Layer', content: child),
            ),
          ),
        ]) {
      testWidgets('works above a $name; Escape closes only the Select', (
        tester,
      ) async {
        final values = <List<int>>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => show(
                    context,
                    SizedBox(
                      width: 200,
                      child: SeedSelect<int>(
                        placeholder: 'Pick',
                        onValueChange: values.add,
                        groups: const [
                          SeedSelectGroup(
                            items: [
                              SeedSelectItem(value: 1, label: 'One'),
                              SeedSelectItem(value: 2, label: 'Two'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Launch'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Launch'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pick'));
        await tester.pumpAndSettle();
        expect(find.text('One'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('One'), findsNothing);
        expect(find.text('Layer'), findsOneWidget);

        await tester.tap(find.text('Pick'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Two'));
        await tester.pumpAndSettle();
        expect(values, [
          [2],
        ]);
        expect(find.text('Layer'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // One barrier tap closes only the list; the next closes the layer.
        await tester.tap(find.text('Two'));
        await tester.pumpAndSettle();
        expect(find.text('One'), findsOneWidget);
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(find.text('One'), findsNothing);
        expect(find.text('Layer'), findsOneWidget);
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(find.text('Layer'), findsNothing);
      });
    }

    testWidgets('highlight insets by marginX and skips disabled options', (
      tester,
    ) async {
      await pumpSelect(tester);
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      EdgeInsetsGeometry inset(String label) => tester
          .widget<AnimatedPadding>(
            find
                .descendant(
                  of: find.ancestor(
                    of: find.text(label),
                    matching: find.byType(MenuItemButton),
                  ),
                  matching: find.byType(AnimatedPadding),
                )
                .first,
          )
          .padding;
      expect(inset('One'), EdgeInsets.zero, reason: 'pointer open: none yet');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(inset('One'), const EdgeInsets.symmetric(horizontal: 8));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(inset('One'), EdgeInsets.zero);
      expect(inset('Three'), const EdgeInsets.symmetric(horizontal: 8));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(inset('One'), const EdgeInsets.symmetric(horizontal: 8));
    });
  });
  group('value formatting and typeahead', () {
    setUpAll(loadSeedTestFonts);

    const fruits = [
      SeedSelectGroup<String>(
        items: [
          SeedSelectItem(value: 'a', label: 'Apple'),
          SeedSelectItem(value: 'b', label: 'Banana'),
          SeedSelectItem(value: 'c', label: 'Cherry', enabled: false),
          SeedSelectItem(value: 'd', label: 'Durian'),
        ],
      ),
    ];

    testWidgets('Select applies formatValue to a single selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appTypeahead(
          SizedBox(
            width: 300,
            child: SeedSelect<String>(
              groups: fruits,
              value: const ['a'],
              formatValue: (items) => 'Picked ${items.single.label}',
            ),
          ),
        ),
      );
      expect(find.text('Picked Apple'), findsOneWidget);
    });

    testWidgets('closed Select typeahead commits without opening', (
      tester,
    ) async {
      final values = <List<String>>[];
      await tester.pumpWidget(
        _appTypeahead(
          SizedBox(
            width: 300,
            child: SeedSelect<String>(
              groups: fruits,
              onValueChange: values.add,
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump();
      expect(values, [
        ['b'],
      ]);
      expect(find.byType(MenuItemButton), findsNothing);
      // Disabled options are skipped.
      await tester.pump(const Duration(seconds: 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump();
      expect(values.length, 1);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('open Select typeahead moves focus to the match', (
      tester,
    ) async {
      final values = <List<String>>[];
      await tester.pumpWidget(
        _appTypeahead(
          SizedBox(
            width: 300,
            child: SeedSelect<String>(
              groups: fruits,
              onValueChange: values.add,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(SeedInputButton));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.pump();
      expect(values, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(values, [
        ['d'],
      ]);
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('pointer and keyboard isolation', () {
    testWidgets(
      'Select clear pointer cannot affect the next keyboard activation',
      (tester) async {
        final changes = <List<String>>[];
        await tester.pumpWidget(
          _host(
            SeedSelect<String>(
              defaultValue: const ['a'],
              showClear: true,
              groups: const [
                SeedSelectGroup(
                  items: [
                    SeedSelectItem(value: 'a', label: 'Apple'),
                    SeedSelectItem(value: 'b', label: 'Banana'),
                  ],
                ),
              ],
              onValueChange: changes.add,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Clear selection'));
        await tester.pumpAndSettle();
        expect(changes, [<String>[]]);
        tester
            .widget<SeedInputButton>(find.byType(SeedInputButton))
            .focusNode!
            .requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton), findsNWidgets(2));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(changes, [
          <String>[],
          ['a'],
        ]);
        expect(find.byType(MenuItemButton), findsNothing);
      },
    );

    testWidgets(
      'cancelled Select pointer gesture cannot contaminate keyboard open',
      (tester) async {
        final changes = <List<String>>[];
        await tester.pumpWidget(
          _host(
            SeedSelect<String>(
              groups: const [
                SeedSelectGroup(
                  items: [SeedSelectItem(value: 'a', label: 'Apple')],
                ),
              ],
              onValueChange: changes.add,
            ),
          ),
        );
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(SeedInputButton)),
        );
        await gesture.moveBy(const Offset(0, 100));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton), findsNothing);
        tester
            .widget<SeedInputButton>(find.byType(SeedInputButton))
            .focusNode!
            .requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(changes, [
          ['a'],
        ]);
      },
    );
  });
  group('keyboard and focus', () {
    setUpAll(loadSeedTestFonts);

    for (final width in [390.0, 800.0]) {
      testWidgets(
        'default Select keeps keyboard in menu and closes on Escape $width',
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
            bool isOpen() => find.byType(MenuItemButton).evaluate().isNotEmpty;
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
              options[0].focusNode!.hasFocus,
              isTrue,
              reason:
                  'React pointer open seeds no highlight; first ArrowDown '
                  'highlights the first enabled item',
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pumpAndSettle();
            expect(
              options[1].focusNode!.hasFocus,
              isTrue,
              reason: 'second ArrowDown advances to the next option',
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

    testWidgets('Tab beyond last option dismisses the non-modal listbox', (
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
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);
        final option = tester.widget<MenuItemButton>(
          find.byType(MenuItemButton),
        );
        expect(option.focusNode!.hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(
          find.byType(MenuItemButton).evaluate().isNotEmpty,
          isFalse,
          reason: 'React FloatingFocusManager closes Select when Tab leaves listbox',
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

    testWidgets('Shift+Tab keeps Select open on its trigger, then leaves', (
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
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);
        expect(before.hasFocus, isFalse);
        // The trigger's keys keep driving the open list, with focus unmoved.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<MenuItemButton>(find.byType(MenuItemButton).first)
              .focusNode!
              .hasFocus,
          isFalse,
        );
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isFalse);
        expect(before.hasFocus, isTrue);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        before.dispose();
      }
    });

    testWidgets(
      'controlled open emits focusOut proposal on Tab without closing',
      (tester) async {
        final proposals = <(bool, SeedOverlayDismissReason)>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  SeedSelect<String>(
                    open: true,
                    onOpenChange: (open, reason) =>
                        proposals.add((open, reason)),
                    groups: const [
                      SeedSelectGroup(
                        items: [SeedSelectItem(value: 'a', label: 'Apple')],
                      ),
                    ],
                  ),
                  const TextField(),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);
        final option = tester.widget<MenuItemButton>(
          find.byType(MenuItemButton),
        );
        expect(option.focusNode!.hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(proposals, [(false, SeedOverlayDismissReason.focusOut)]);
        expect(
          find.byType(MenuItemButton).evaluate().isNotEmpty,
          isTrue,
          reason: 'parent open=true remains authoritative',
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('readonly', () {
    for (final width in [390.0, 800.0]) {
      for (final side in [null, SeedOverlaySide.bottom]) {
        testWidgets('readonly focus and activation $width $side', (
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
            expect(
              after.hasFocus,
              isTrue,
              reason: 'disabled select is skipped',
            );
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
    testWidgets('readonly Field label and external focus stay connected', (
      tester,
    ) async {
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
    });
    testWidgets('built-in label focuses readonly Select', (tester) async {
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
    testWidgets('FieldButton readonly still disallows focus', (tester) async {
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
  });

  group('keyboard highlight', () {
    for (final width in [390.0, 800.0]) {
      testWidgets(
        'pointer-open Select ArrowDown seeds selected option on first key at $width',
        (tester) async {
          tester.view.physicalSize = mui.Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            _hostSelectTimeContract(
              const SeedSelect<String>(groups: _fruit, defaultValue: ['apple']),
            ),
          );
          await tester.tap(find.text('사과'));
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(
            tester.widget<SeedInputButton>(find.byType(SeedInputButton)).value,
            '사과',
            reason:
                'React useSelectHighlight pointer opens without highlight; '
                'first ArrowDown seeds the selected apple, rather than banana',
          );
        },
      );
    }

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
            _hostSelectTimeContract(
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
  });

  group('anchoring', () {
    testWidgets(
      'select can anchor above trigger and closes after single selection',
      (tester) async {
        int? selected;
        await tester.pumpWidget(
          host(
            Center(
              child: SizedBox(
                width: 220,
                child: SeedSelect<int>(
                  side: SeedOverlaySide.top,
                  onChanged: (value) => selected = value,
                  groups: const [
                    SeedSelectGroup(
                      items: [SeedSelectItem(value: 1, label: 'Choice')],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('선택해주세요'));
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.text('Choice')).dy,
          lessThan(tester.getTopLeft(find.text('선택해주세요')).dy),
        );
        await tester.tap(find.text('Choice'));
        await tester.pumpAndSettle();
        expect(selected, 1);
        expect(find.byType(MenuItemButton), findsNothing);
      },
    );
  });

  group('disabled while open', () {
    testWidgets(
      'disabling an open select closes its popup and prevents changes',
      (tester) async {
        bool enabled = true;
        late StateSetter updateParent;
        final selected = <int>[];
        await tester.pumpWidget(
          hostInputOverlayRegression(
            SizedBox(
              width: 260,
              child: StatefulBuilder(
                builder: (context, setState) {
                  updateParent = setState;
                  return SeedSelect<int>(
                    enabled: enabled,
                    groups: const [
                      SeedSelectGroup<int>(
                        items: [
                          SeedSelectItem(value: 1, label: 'First option'),
                          SeedSelectItem(value: 2, label: 'Second option'),
                        ],
                      ),
                    ],
                    onChanged: selected.add,
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('선택해주세요'));
        await tester.pumpAndSettle();
        expect(find.text('First option'), findsOneWidget);
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);

        updateParent(() => enabled = false);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isFalse);
        expect(find.text('First option'), findsNothing);
        expect(find.text('Second option'), findsNothing);

        // The disabled trigger cannot reopen with pointer or keyboard activation.
        await tester.tap(find.text('선택해주세요'));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isFalse);
        expect(selected, isEmpty);

        // Re-enabling must not resurrect the dismissed popup or commit a stale
        // option. Escape cancels the fresh popup, and only a later click selects.
        updateParent(() => enabled = true);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isFalse);
        expect(selected, isEmpty);

        await tester.tap(find.text('선택해주세요'));
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isFalse);
        expect(selected, isEmpty);

        await tester.tap(find.text('선택해주세요'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Second option'));
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isFalse);
        expect(selected, [2]);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('multiple selection', () {
    testWidgets('multiple select keeps menu open and toggles existing values', (
      tester,
    ) async {
      final changes = <Set<int>>[];
      await tester.pumpWidget(
        hostReactParity(
          SeedSelect<int>(
            multiple: true,
            onValuesChanged: changes.add,
            groups: const [
              SeedSelectGroup(
                items: [
                  SeedSelectItem(value: 1, label: 'Apple'),
                  SeedSelectItem(value: 2, label: 'Pear'),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('선택해주세요'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton).evaluate().isNotEmpty, isTrue);
      await tester.tap(find.text('Pear'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(MenuItemButton).first,
          matching: find.text('Apple'),
        ),
      );
      await tester.pumpAndSettle();
      expect(changes, [
        {1},
        {1, 2},
        {2},
      ]);
    });
  });
}
