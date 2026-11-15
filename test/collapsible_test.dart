import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

Widget _collapsible({
  bool? open,
  bool defaultOpen = false,
  ValueChanged<bool>? onOpenChange,
  bool disabled = false,
  Widget content = const SizedBox(height: 120, child: Text('Details')),
}) => seedApp(
  SeedCollapsible(
    open: open,
    defaultOpen: defaultOpen,
    onOpenChange: onOpenChange,
    disabled: disabled,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeedCollapsibleTrigger(
          child: Builder(
            builder: (context) =>
                Text(SeedCollapsible.of(context).open ? 'Less' : 'More'),
          ),
        ),
        SeedCollapsibleContent(child: content),
        const Text('After'),
      ],
    ),
  ),
);

double _contentHeight(WidgetTester tester) =>
    tester.getSize(find.byType(SeedCollapsibleContent)).height;

void main() {
  testWidgets('closed by default; the trigger opens and closes it', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(_collapsible(onOpenChange: changes.add));
    expect(_contentHeight(tester), 0);
    expect(find.text('Details'), findsNothing);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(find.text('Less'), findsOneWidget);
    expect(_contentHeight(tester), 120);
    expect(
      tester.getTopLeft(find.text('After')).dy,
      tester.getBottomLeft(find.byType(SeedCollapsibleContent)).dy,
    );

    await tester.tap(find.text('Less'));
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
    expect(_contentHeight(tester), 0);
  });

  testWidgets('the height animates over 200ms', (tester) async {
    await tester.pumpWidget(_collapsible());
    await tester.tap(find.text('More'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final midway = _contentHeight(tester);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(120));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_contentHeight(tester), 120);
  });

  testWidgets('reduced motion opens at once', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _collapsible(),
      ),
    );
    await tester.tap(find.text('More'));
    await tester.pump();
    expect(_contentHeight(tester), 120);
  });

  testWidgets('defaultOpen starts open without a transition', (tester) async {
    await tester.pumpWidget(_collapsible(defaultOpen: true));
    expect(_contentHeight(tester), 120);
  });

  testWidgets('a controlled collapsible only reports the request', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _collapsible(open: false, onOpenChange: changes.add),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(_contentHeight(tester), 0);

    await tester.pumpWidget(
      _collapsible(open: true, onOpenChange: changes.add),
    );
    await tester.pumpAndSettle();
    expect(_contentHeight(tester), 120);
  });

  testWidgets('disabled ignores taps', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _collapsible(disabled: true, onOpenChange: changes.add),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(_contentHeight(tester), 0);
  });

  testWidgets('the trigger exposes its expanded state and toggles by key', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_collapsible());
    final trigger = find.byType(SeedCollapsibleTrigger);
    expect(
      tester.getSemantics(trigger),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(trigger),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: true),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_contentHeight(tester), 0);
    semantics.dispose();
  });

  testWidgets('closed content keeps its state and leaves semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _collapsible(
        defaultOpen: true,
        content: const SizedBox(width: 200, child: TextField()),
      ),
    );
    await tester.enterText(find.byType(TextField), 'typed');
    await tester.tap(find.text('Less'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('typed'), findsNothing);
    expect(find.byType(TextField, skipOffstage: false), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('typed'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('maybeOf is null outside a collapsible', (tester) async {
    await tester.pumpWidget(
      seedApp(
        Builder(
          builder: (context) =>
              Text('${SeedCollapsible.maybeOf(context) == null}'),
        ),
      ),
    );
    expect(find.text('true'), findsOneWidget);
  });
}
