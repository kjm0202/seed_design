import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

void main() {
  testWidgets('separated accordion keeps its border visible at every corner', (
    tester,
  ) async {
    final theme = SeedThemeData.dark();
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme.toThemeData(),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: const SizedBox(
                width: 200,
                child: SeedAccordionItem(
                  variant: SeedAccordionVariant.separated,
                  title: 'Corners',
                  content: SizedBox(height: 40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> expectCornerBorders() async {
      final pixels = await tester.runAsync(() async {
        final image = await tester
            .renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey))
            .toImage(pixelRatio: 3);
        try {
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          // Midpoint of the 1px stroke on each 12px radius corner.
          // At 45 degrees this lies 12 - 11.5 / sqrt(2) pixels inward.
          const inset = 11;
          return [
            for (final x in [inset, image.width - 1 - inset])
              for (final y in [inset, image.height - 1 - inset])
                bytes.getUint8((y * image.width + x) * 4),
          ];
        } finally {
          image.dispose();
        }
      });
      // stroke.neutral-weak is translucent since SEED 3.3.0, so the visible
      // color is the stroke composited over the item surface.
      final stroke = Color.alphaBlend(
        theme.colorScheme.stroke.neutralWeak,
        theme.colorScheme.bg.layerDefault,
      );
      final strokeRed = (stroke.toARGB32() >> 16) & 0xff;
      for (final pixel in pixels!) {
        expect(
          pixel,
          closeTo(strokeRed, 2),
          reason: 'The rounded border must not be covered by the item surface',
        );
      }
    }

    await expectCornerBorders();
    await tester.tap(find.text('Corners'));
    await tester.pumpAndSettle();
    await expectCornerBorders();
  });

  for (final variant in SeedAccordionVariant.values) {
    testWidgets(
      'dark $variant background stays dark throughout expand and collapse',
      (tester) async {
        final theme = SeedThemeData.dark();
        final background = theme.colorScheme.bg.layerDefault;
        final pressed = Color.alphaBlend(
          theme.colorScheme.bg.transparentPressed,
          background,
        );
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme.toThemeData(),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: ColoredBox(
                    color: background,
                    child: SizedBox(
                      width: 360,
                      height: 240,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SeedAccordion(
                          variant: variant,
                          items: const [
                            SeedAccordionItem(
                              value: 'a',
                              title: 'Toggle',
                              content: SizedBox(height: 80),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        Future<void> expectDarkFrame() async {
          final pixel = await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(boundaryKey),
            );
            final image = await boundary.toImage(pixelRatio: 1);
            try {
              final bytes = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              // Sample the trigger background above its text and icons.
              final offset = (8 * image.width + 180) * 4;
              return List.generate(3, (i) => bytes.getUint8(offset + i));
            } finally {
              image.dispose();
            }
          });
          final lower = background.toARGB32();
          final upper = pressed.toARGB32();
          for (var i = 0; i < 3; i++) {
            final shift = (2 - i) * 8;
            expect(
              pixel![i],
              inInclusiveRange(
                ((lower >> shift) & 0xff) - 1,
                ((upper >> shift) & 0xff) + 1,
              ),
              reason:
                  'Press feedback must stay between the dark surface '
                  'and its composited pressed color',
            );
          }
        }

        await expectDarkFrame();
        for (final expanded in [true, false]) {
          final gesture = await tester.startGesture(
            tester.getCenter(find.text('Toggle')),
          );
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump();
          // Cover both a held press and release before feedback finishes.
          for (var frame = 0; frame < (expanded ? 5 : 1); frame++) {
            await tester.pump(const Duration(milliseconds: 30));
            await expectDarkFrame();
          }
          await gesture.up();
          await tester.pump();
          for (var frame = 0; frame < 5; frame++) {
            await tester.pump(const Duration(milliseconds: 30));
            await expectDarkFrame();
          }
          await tester.pumpAndSettle();
          expect(
            tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
            expanded,
          );
          await expectDarkFrame();
        }
      },
    );
  }

  testWidgets('group keyboard navigation skips disabled items', (tester) async {
    await tester.pumpWidget(
      seedAppNarrow(
        const SeedAccordion(
          items: [
            SeedAccordionItem(value: 'a', title: 'A', content: SizedBox()),
            SeedAccordionItem(
              value: 'b',
              title: 'B',
              content: SizedBox(),
              enabled: false,
            ),
            SeedAccordionItem(value: 'c', title: 'C', content: SizedBox()),
          ],
        ),
      ),
    );
    final nodes = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .map((button) => button.focusNode!)
        .toList();

    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
    expect(nodes[1].hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
  });

  testWidgets(
    'group retains item identity and navigates with supplied focus nodes',
    (tester) async {
      final a = FocusNode();
      final b = FocusNode();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      Widget group(List<String> order) => seedAppNarrow(
        SeedAccordion(
          defaultValues: const {'a'},
          items: [
            for (final id in order)
              SeedAccordionItem(
                value: id,
                title: id.toUpperCase(),
                content: Text('Body $id'),
                focusNode: id == 'a' ? a : b,
              ),
          ],
        ),
      );

      await tester.pumpWidget(group(['a', 'b']));
      a.requestFocus();
      await tester.pump();
      await tester.pumpWidget(group(['b', 'a']));
      await tester.pumpAndSettle();
      final buttons = tester.widgetList<SeedPressable>(
        find.byType(SeedPressable),
      );
      expect(buttons.map((button) => button.expanded), [false, true]);
      expect(a.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(b.hasPrimaryFocus, isTrue);

      await tester.pumpWidget(group(['a']));
      await tester.pumpAndSettle();
      // Removing a row must not dispose the consumer-owned focus node.
      void listener() {}
      b.addListener(listener);
      b.removeListener(listener);
    },
  );

  testWidgets('group disposes its own focus node after removing an item', (
    tester,
  ) async {
    Widget group(bool includeB) => seedAppNarrow(
      SeedAccordion(
        items: [
          const SeedAccordionItem(value: 'a', title: 'A', content: SizedBox()),
          if (includeB)
            const SeedAccordionItem(
              value: 'b',
              title: 'B',
              content: SizedBox(),
            ),
        ],
      ),
    );
    await tester.pumpWidget(group(true));
    final removed = tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .last
        .focusNode!;
    await tester.pumpWidget(group(false));
    await tester.pump();
    expect(() => removed.addListener(() {}), throwsFlutterError);
  });

  testWidgets(
    'controlled item requests an expansion without mutating its state',
    (tester) async {
      final requested = <bool>[];
      Widget item(bool expanded) => seedAppNarrow(
        SeedAccordionItem(
          title: 'Controlled',
          content: const Text('Details'),
          expanded: expanded,
          onExpansionChanged: requested.add,
        ),
      );

      await tester.pumpWidget(item(false));
      await tester.tap(find.text('Controlled'));
      await tester.pumpAndSettle();
      expect(requested, [true]);
      expect(
        tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
        false,
      );

      await tester.pumpWidget(item(true));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedPressable>(find.byType(SeedPressable)).expanded,
        true,
      );
      expect(requested, [true]);
    },
  );
  group('heading semantics', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('accordion exposes a heading containing one named button', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        scaledApp(
          const SizedBox(
            width: 300,
            child: SeedAccordionItem(
              title: 'Details',
              headingLevel: 4,
              content: Text('Hidden body'),
            ),
          ),
        ),
      );
      final node = tester.getSemantics(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.headingLevel == 4,
        ),
      );
      final data = node.getSemanticsData();
      expect(data.headingLevel, 4);
      expect(data.flagsCollection.isButton, isFalse);
      final children = <SemanticsNode>[];
      node.visitChildren((child) {
        children.add(child);
        return true;
      });
      expect(children, hasLength(1));
      final button = children.single.getSemanticsData();
      expect(button.label, 'Details');
      expect(button.flagsCollection.isButton, isTrue);
      expect(button.hasAction(ui.SemanticsAction.tap), isTrue);
      semantics.dispose();
    });
  });

  group('single open item', () {
    testWidgets(
      'accordion group enforces one open item and disabled items do not activate',
      (tester) async {
        final changes = <Set<String>>[];
        await tester.pumpWidget(
          koreanAppNarrow(
            SeedAccordion(
              onValuesChanged: changes.add,
              items: const [
                SeedAccordionItem(
                  value: 'one',
                  title: 'One',
                  content: Text('Body one'),
                ),
                SeedAccordionItem(
                  value: 'two',
                  title: 'Two',
                  content: Text('Body two'),
                ),
                SeedAccordionItem(
                  value: 'off',
                  title: 'Off',
                  enabled: false,
                  content: Text('Off body'),
                ),
              ],
            ),
          ),
        );
        await tester.tap(find.text('One'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Two'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Off'));
        await tester.pumpAndSettle();
        expect(changes, [
          {'one'},
          {'two'},
        ]);
        final buttons = tester
            .widgetList<SeedPressable>(find.byType(SeedPressable))
            .toList();
        expect(buttons.map((b) => b.expanded), [false, true, false]);
      },
    );
  });
  testWidgets('collapsing an item releases focus held inside its content', (
    tester,
  ) async {
    var presses = 0;
    final buttonFocus = FocusNode();
    addTearDown(buttonFocus.dispose);
    Widget build(bool expanded) => seedAppNarrow(
      SeedAccordionItem(
        title: 'Details',
        expanded: expanded,
        content: SeedButton(
          label: 'Inside',
          focusNode: buttonFocus,
          onPressed: () => presses++,
        ),
      ),
    );
    await tester.pumpWidget(build(true));
    buttonFocus.requestFocus();
    await tester.pump();
    expect(buttonFocus.hasPrimaryFocus, isTrue);

    // The parent collapses the item while the inner button is focused.
    await tester.pumpWidget(build(false));
    await tester.pumpAndSettle();
    expect(buttonFocus.hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(presses, 0);
  });

  group('title, description and suffix icon slots', () {
    testWidgets('string title keeps the default chevron', (tester) async {
      await tester.pumpWidget(
        seedAppNarrow(
          const SeedAccordionItem(
            title: 'Plain',
            description: 'Detail',
            content: Text('Body'),
          ),
        ),
      );
      expect(find.text('Plain'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets(
      'widget title, description and suffix icon replace the defaults',
      (tester) async {
        final semantics = tester.ensureSemantics();
        var expanded = false;
        await tester.pumpWidget(
          seedAppNarrow(
            SeedAccordionItem(
              title: 'Shipping',
              titleWidget: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('Shipping'), SizedBox(width: 4), Text('NEW')],
              ),
              description: 'ignored',
              descriptionWidget: const Text('Arrives tomorrow'),
              suffixIcon: const Icon(Icons.add),
              content: const Text('Body'),
              onExpansionChanged: (value) => expanded = value,
            ),
          ),
        );
        expect(find.text('NEW'), findsOneWidget);
        expect(find.text('Arrives tomorrow'), findsOneWidget);
        expect(find.text('ignored'), findsNothing);
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

        // The slots inherit the header text styles and icon theme.
        final theme = SeedThemeData.light();
        final title = tester.widget<RichText>(
          find.descendant(
            of: find.text('NEW'),
            matching: find.byType(RichText),
          ),
        );
        final plain = tester.widget<RichText>(
          find.descendant(
            of: find.text('Shipping'),
            matching: find.byType(RichText),
          ),
        );
        expect(title.text.style!.fontSize, plain.text.style!.fontSize);
        expect(title.text.style!.fontWeight, plain.text.style!.fontWeight);
        final icon = tester.widget<RichText>(
          find.descendant(
            of: find.byIcon(Icons.add),
            matching: find.byType(RichText),
          ),
        );
        expect(icon.text.style!.color, theme.colorScheme.fg.neutralSubtle);

        // The header still toggles from pointer and keyboard.
        await tester.tap(find.text('NEW'));
        await tester.pumpAndSettle();
        expect(expanded, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(expanded, isFalse);
        semantics.dispose();
      },
    );

    testWidgets('group forwards slots and keeps expansion across rebuilds', (
      tester,
    ) async {
      Widget build(String badge) => seedAppNarrow(
        SeedAccordion(
          defaultValues: const {'a'},
          items: [
            SeedAccordionItem(
              value: 'a',
              title: 'A',
              titleWidget: Text('A $badge'),
              suffixIcon: const Icon(Icons.add),
              content: const Text('Body A'),
            ),
            const SeedAccordionItem(
              value: 'b',
              title: 'B',
              content: Text('Body B'),
            ),
          ],
        ),
      );
      await tester.pumpWidget(build('1'));
      await tester.pumpAndSettle();
      expect(find.text('A 1'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.text('Body A').hitTestable(), findsOneWidget);

      await tester.pumpWidget(build('2'));
      await tester.pumpAndSettle();
      expect(find.text('A 2'), findsOneWidget);
      expect(find.text('Body A').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
