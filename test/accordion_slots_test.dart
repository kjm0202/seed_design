import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

// React Accordion.Title / Description accept arbitrary children and
// Accordion.SuffixIcon replaces the chevron.

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

void main() {
  testWidgets('string title keeps the default chevron', (tester) async {
    await tester.pumpWidget(
      host(
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

  testWidgets('widget title, description and suffix icon replace the defaults', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var expanded = false;
    await tester.pumpWidget(
      host(
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
      find.descendant(of: find.text('NEW'), matching: find.byType(RichText)),
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
  });

  testWidgets('group forwards slots and keeps expansion across rebuilds', (
    tester,
  ) async {
    Widget build(String badge) => host(
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
}
