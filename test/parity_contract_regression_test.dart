import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

void main() {
  for (final (key, item) in [
    (LogicalKeyboardKey.arrowDown, 'first'),
    (LogicalKeyboardKey.arrowUp, 'last'),
  ]) {
    testWidgets('menu opens with ${key.keyLabel} and activates $item', (
      tester,
    ) async {
      final selected = <String>[];
      await tester.pumpWidget(
        host(
          SeedMenuTrigger(
            triggerBuilder: (_, open, toggle) =>
                TextButton(onPressed: toggle, child: const Text('Open')),
            builder: (_) => SeedMenu(
              groups: [
                SeedMenuGroupData(
                  items: [
                    const SeedMenuItemData(label: 'Disabled', enabled: false),
                    SeedMenuItemData(
                      label: 'First',
                      onTap: () => selected.add('first'),
                    ),
                    SeedMenuItemData(
                      label: 'Last',
                      onTap: () => selected.add('last'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenu), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(selected, [item]);
      expect(find.byType(SeedMenu), findsNothing);
    });
  }

  testWidgets('select searches independent text and keeps unresolved values', (
    tester,
  ) async {
    final groups = ValueNotifier<List<SeedSelectGroup<String>>>([]);
    final selection = <List<String>>[];
    addTearDown(groups.dispose);
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 250,
          child: ValueListenableBuilder(
            valueListenable: groups,
            builder: (_, options, _) => SeedSelect<String>(
              groups: options,
              multiple: true,
              defaultValue: const ['missing'],
              formatSelectedValue: (items) => items
                  .map(
                    (entry) =>
                        entry.item?.textValue ?? 'Waiting for ${entry.value}',
                  )
                  .join(', '),
              onValueChange: selection.add,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Waiting for missing'), findsOneWidget);

    groups.value = const [
      SeedSelectGroup(
        items: [
          SeedSelectItem(
            value: 'missing',
            label: 'Loaded',
            textValue: 'Resolved',
          ),
          SeedSelectItem(
            value: 'pear',
            label: 'Pear',
            textValue: 'Fruit',
            typeaheadLabel: 'z',
          ),
        ],
      ),
    ];
    await tester.pumpAndSettle();
    expect(find.text('Resolved'), findsOneWidget);
    await tester.tap(find.byType(SeedInputButton));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selection, [
      ['missing', 'pear'],
    ]);
  });

  testWidgets('a resolved empty label does not display the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 250,
          child: SeedSelect<String>(
            placeholder: 'Choose',
            defaultValue: ['value'],
            groups: [
              SeedSelectGroup(
                items: [
                  SeedSelectItem(
                    value: 'value',
                    label: 'Visible option',
                    textValue: '',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Choose'), findsNothing);
    await tester.tap(find.byType(SeedInputButton));
    await tester.pumpAndSettle();
    expect(find.text('Visible option'), findsOneWidget);
  });

  testWidgets('callout can dismiss without requiring an observer', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const SeedCallout(description: 'Message', showCloseButton: true)),
    );
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('snackbar avoids a floating region after a controller swap', (
    tester,
  ) async {
    final first = SeedSnackbarController();
    final second = SeedSnackbarController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    const obstacle = Key('obstacle');
    const message = Key('message');
    Future<void> mount(SeedSnackbarController controller) => tester.pumpWidget(
      host(
        SeedSnackbarProvider(
          controller: controller,
          child: const Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: SeedSnackbarAvoidOverlap(
                  child: SizedBox(key: obstacle, height: 90),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await mount(first);
    first.show(child: const SizedBox(key: message, width: 120, height: 50));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(message)).bottom,
      lessThanOrEqualTo(tester.getRect(find.byKey(obstacle)).top),
    );
    await mount(second);
    second.show(child: const SizedBox(key: message, width: 120, height: 50));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(message)).bottom,
      lessThanOrEqualTo(tester.getRect(find.byKey(obstacle)).top),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('scroll focus responds when the viewport grows', (tester) async {
    final height = ValueNotifier<double>(100);
    addTearDown(height.dispose);
    await tester.pumpWidget(
      host(
        ValueListenableBuilder(
          valueListenable: height,
          builder: (_, value, _) => SizedBox(
            height: value,
            width: 200,
            child: const SeedScrollArea(
              focusableWhenScrollable: true,
              fogOnlyWhenScrollable: true,
              child: SizedBox(height: 140),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Focus focus() => tester.widget(
      find
          .descendant(
            of: find.byType(SeedScrollArea),
            matching: find.byType(Focus),
          )
          .first,
    );
    expect(focus().canRequestFocus, isTrue);
    height.value = 160;
    await tester.pumpAndSettle();
    expect(focus().canRequestFocus, isFalse);
  });

  testWidgets('grid honors end-only lines and full-span precedence', (
    tester,
  ) async {
    const grid = Key('grid');
    const end = Key('end');
    const full = Key('full');
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 300,
          child: SeedGrid(
            key: grid,
            columns: 3,
            children: [
              SeedGridItem(
                colEnd: 4,
                rowEnd: 2,
                child: SizedBox(key: end, height: 30),
              ),
              SeedGridItem(
                colSpan: SeedGridItem.full,
                colStart: 2,
                colEnd: 3,
                rowStart: 2,
                child: SizedBox(key: full, height: 30),
              ),
            ],
          ),
        ),
      ),
    );
    final gridRect = tester.getRect(find.byKey(grid));
    expect(tester.getRect(find.byKey(end)).right, gridRect.right);
    expect(tester.getRect(find.byKey(full)).width, gridRect.width);
  });

  testWidgets('sheet drag can dismiss independently of the backdrop', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showSeedBottomSheet<void>(
              context: context,
              isDismissible: false,
              dragDismissible: true,
              snapPoints: const [SeedSheetSnapPoint.fraction(.5)],
              handleOnly: true,
              child: const SeedBottomSheet(
                title: 'Snapping sheet',
                showHandle: true,
                content: Text('Body'),
              ),
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    final sheet = find.byType(SeedBottomSheet);
    expect(sheet, findsOneWidget);
    final handle = find
        .descendant(
          of: sheet,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is GestureDetector &&
                widget.onVerticalDragUpdate != null,
          ),
        )
        .first;
    await tester.drag(handle, const Offset(0, 140));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
  });
}
