import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

void main() {
  testWidgets(
    'accordion group enforces one open item and disabled items do not activate',
    (tester) async {
      final changes = <Set<String>>[];
      await tester.pumpWidget(
        host(
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

  testWidgets('multiple select keeps menu open and toggles existing values', (
    tester,
  ) async {
    final changes = <Set<int>>[];
    await tester.pumpWidget(
      host(
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
    expect(
      tester.widget<MenuAnchor>(find.byType(MenuAnchor)).controller!.isOpen,
      isTrue,
    );
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

  testWidgets(
    'multiple dates sort values, enforce counts and still allow deselection',
    (tester) async {
      final changes = <List<DateTime>>[];
      await tester.pumpWidget(
        host(
          SeedDatePicker(
            mode: SeedDatePickerMode.multiple,
            initialDate: DateTime(2026, 4, 1),
            constraints: [seedMaxSelectionCount(2)],
            onDatesSelected: changes.add,
          ),
        ),
      );
      await tester.tap(find.text('20'));
      await tester.pump();
      await tester.tap(find.text('10'));
      await tester.pump();
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(changes.last, [DateTime(2026, 4, 10), DateTime(2026, 4, 20)]);
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(changes.last, [DateTime(2026, 4, 20)]);
    },
  );

  testWidgets('date range checks excluded days inside the interval', (
    tester,
  ) async {
    final changes = <SeedDateRange>[];
    await tester.pumpWidget(
      host(
        SeedDatePicker(
          mode: SeedDatePickerMode.range,
          initialDate: DateTime(2026, 4, 1),
          constraints: [
            seedExcludeDates((day) => day == DateTime(2026, 4, 12)),
          ],
          onRangeSelected: (start, end) =>
              changes.add(SeedDateRange(start: start!, end: end)),
        ),
      ),
    );
    await tester.tap(find.text('10'));
    await tester.pump();
    await tester.tap(find.text('15'));
    await tester.pump();
    expect(changes, hasLength(1));
    await tester.tap(find.text('11'));
    await tester.pump();
    expect(changes.last.end, DateTime(2026, 4, 11));
  });

  testWidgets('English week layout spans two months and advances by one week', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SeedDatePicker(
          layout: SeedDatePickerLayout.week,
          initialDate: DateTime(2026, 4, 30),
          locale: const Locale('en', 'US'),
          weekStartsOn: DateTime.monday,
        ),
      ),
    );
    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets(
    'range start readonly preserves start while choosing a later end',
    (tester) async {
      final changes = <SeedDateRange>[];
      await tester.pumpWidget(
        host(
          SeedDatePicker(
            mode: SeedDatePickerMode.range,
            initialStartDate: DateTime(2026, 4, 10),
            initialEndDate: DateTime(2026, 4, 15),
            rangeStartReadOnly: true,
            onRangeSelected: (start, end) =>
                changes.add(SeedDateRange(start: start!, end: end)),
          ),
        ),
      );
      await tester.tap(find.text('8'));
      await tester.pump();
      expect(changes, isEmpty);
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(changes.last.start, DateTime(2026, 4, 10));
      expect(changes.last.end, DateTime(2026, 4, 20));
    },
  );

  testWidgets(
    'wheel keyboard commits once and readonly preserves focus without edits',
    (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        host(
          SeedWheelPicker(
            columns: [
              SeedWheelColumn.typed(
                items: ['A', 'B', 'C'],
                initialIndex: 1,
                semanticsLabel: 'Letter',
                onChanged: changes.add,
              ),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(changes, [2]);
      await tester.pumpWidget(
        host(
          SeedWheelPicker(
            readOnly: true,
            columns: [
              SeedWheelColumn.typed(
                items: ['A', 'B', 'C'],
                initialIndex: 2,
                onChanged: changes.add,
              ),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(changes, [2]);
    },
  );

  testWidgets('quantity removable and independent loading guard actions', (
    tester,
  ) async {
    var removes = 0;
    final changes = <int>[];
    await tester.pumpWidget(
      host(
        SeedQuantityPicker(
          value: 1,
          onChanged: changes.add,
          removable: true,
          onRemove: () => removes++,
          incrementLoading: true,
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('상품 삭제'));
    await tester.pump();
    expect(removes, 1);
    expect(changes, isEmpty);
    expect(find.byType(SeedProgressCircle), findsOneWidget);
  });

  test('external media replacement and reorder honor readonly', () {
    final controller = SeedAttachmentController(maxCount: 1);
    addTearDown(controller.dispose);
    controller.addEntries(const [SeedAttachmentItem(id: 'one')]);
    controller.addEntries(const [SeedAttachmentItem(id: 'two')]);
    expect(controller.items.single.id, 'two');
    controller.maxCount = 3;
    controller.addEntries(const [
      SeedAttachmentItem(id: 'three'),
      SeedAttachmentItem(id: 'four'),
    ]);
    controller.reorder(0, 3);
    expect(controller.items.map((item) => item.id), ['three', 'four', 'two']);
  });
}
