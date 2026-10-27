import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);
void main() {
  testWidgets(
    'grid spans and intrinsic rows place children without overlaps in RTL',
    (tester) async {
      await tester.pumpWidget(
        host(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 320,
                child: SeedGrid(
                  columns: 3,
                  gap: 10,
                  children: const [
                    SeedGridItem(
                      columnSpan: 2,
                      child: SizedBox(key: ValueKey('wide'), height: 30),
                    ),
                    SizedBox(key: ValueKey('short'), height: 50),
                    SeedGridItem(
                      columnSpan: 3,
                      child: SizedBox(key: ValueKey('full'), height: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const ValueKey('wide'))).width, 210);
      expect(tester.getSize(find.byKey(const ValueKey('wide'))).height, 50);
      expect(tester.getTopLeft(find.byKey(const ValueKey('wide'))).dx, 110);
      expect(tester.getTopLeft(find.byKey(const ValueKey('full'))).dy, 60);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('sticky tab header stays at viewport top after content scroll', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 200)),
            const SeedStickyTabsHeader(child: Text('Sticky tabs')),
            const SliverToBoxAdapter(child: SizedBox(height: 1000)),
          ],
        ),
      ),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Sticky tabs')).dy, closeTo(0, 1));
  });
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
  testWidgets('tooltip honors delay and closes after pointer exit', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: SeedHelpBubbleTooltip(
            title: 'Tooltip content',
            openDelay: Duration(milliseconds: 300),
            child: Text('Hover here'),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(0, 0));
    await mouse.moveTo(tester.getCenter(find.text('Hover here')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Tooltip content'), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('Tooltip content'), findsOneWidget);
    await mouse.moveTo(const Offset(0, 0));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('Tooltip content'), findsNothing);
    await mouse.removePointer();
  });
  test('overlay controller can start open through its public constructor', () {
    final controller = SeedOverlayController(open: true);
    expect(controller.isOpen, isTrue);
    controller.dispose();
  });
  testWidgets('chip radio group skips disabled options with keyboard', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(
      host(
        SeedChipRadioGroup<int>(
          defaultValue: 1,
          onChanged: changes.add,
          options: const [
            SeedChipOption(value: 1, label: 'One'),
            SeedChipOption(value: 2, label: 'Off', enabled: false),
            SeedChipOption(value: 3, label: 'Three'),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(changes, [3]);
    expect(
      tester
          .widgetList<SeedChip>(find.byType(SeedChip))
          .map((chip) => chip.selected),
      [false, false, true],
    );
  });
  testWidgets(
    'hover changes checkmark color without applying physical press scale',
    (tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: SeedCheckbox(
              value: false,
              onChanged: (_) {},
              label: 'Check',
            ),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(0, 0));
      await mouse.moveTo(tester.getCenter(find.text('Check')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedCheckmark>(find.byType(SeedCheckmark)).pressed,
        isTrue,
      );
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
      await mouse.removePointer();
    },
  );
  testWidgets(
    'radio default selection can update without a controlled parent',
    (tester) async {
      await tester.pumpWidget(
        host(
          const SeedRadioGroup<int>(
            defaultValue: 1,
            child: Column(
              children: [
                SeedRadio(value: 1, label: 'First'),
                SeedRadio(value: 2, label: 'Second'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      final selected = tester
          .widgetList<SeedPressable>(find.byType(SeedPressable))
          .map((button) => button.checked);
      expect(selected, [false, true]);
    },
  );
}
