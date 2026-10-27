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

bool checkboxValue(WidgetTester tester) =>
    tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .where((w) => w.checked != null || w.mixed == true)
        .first
        .checked ==
    true;

void main() {
  testWidgets('checkbox defaults initialize once and callbacks report bool', (
    tester,
  ) async {
    final changes = <bool>[];
    Widget build(bool seed) =>
        host(SeedCheckbox(defaultChecked: seed, onCheckedChange: changes.add));
    await tester.pumpWidget(build(true));
    expect(checkboxValue(tester), isTrue);
    await tester.tap(find.byType(SeedCheckbox));
    await tester.pump();
    expect(checkboxValue(tester), isFalse);
    await tester.pumpWidget(build(true));
    expect(checkboxValue(tester), isFalse);
    expect(changes, [false]);
  });

  testWidgets('checkbox controlled checked and mixed state are independent', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        SeedCheckbox(
          checked: false,
          indeterminate: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byType(SeedCheckbox));
      await tester.pump();
    }
    expect(changes, [true, true]);
    expect(
      tester.widgetList<SeedPressable>(find.byType(SeedPressable)).single.mixed,
      isTrue,
    );
  });

  testWidgets(
    'legacy checkbox null, tristate cycle, and disabled state survive',
    (tester) async {
      // These deprecated inputs deliberately exercise the compatibility contract.
      // ignore: deprecated_member_use
      bool? value;
      final changes = <bool?>[];
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SeedCheckbox(
                // ignore: deprecated_member_use
                value: value,
                tristate: true,
                // ignore: deprecated_member_use
                onChanged: (next) {
                  changes.add(next);
                  setState(() => value = next);
                },
              );
            },
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(SeedCheckbox));
        await tester.pump();
      }
      expect(changes, [false, true, null]);
      update(() => value = null);
      await tester.pumpWidget(
        host(
          const SeedCheckbox(
            // ignore: deprecated_member_use
            value: null,
            // ignore: deprecated_member_use
            onChanged: null,
          ),
        ),
      );
      expect(
        tester
            .widgetList<SeedPressable>(find.byType(SeedPressable))
            .single
            .mixed,
        isTrue,
      );
      expect(
        tester
            .widgetList<SeedPressable>(find.byType(SeedPressable))
            .single
            .enabled,
        isFalse,
      );
    },
  );

  testWidgets('chip toggle owns its default and accepts controlled rejection', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        SeedChip(
          label: 'Toggle',
          defaultChecked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(changes, [false]);
    expect(checkboxValue(tester), isFalse);
    await tester.pumpWidget(
      host(
        SeedChip(
          key: const ValueKey('controlled'),
          label: 'Toggle',
          checked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(checkboxValue(tester), isTrue);
    expect(changes, [false, false]);
  });

  testWidgets(
    'icon-only chip toggles without observer and buttons still click',
    (tester) async {
      await tester.pumpWidget(
        host(
          const SeedChip.iconOnly(
            icon: Icon(Icons.star),
            semanticsLabel: 'Star',
            defaultChecked: false,
          ),
        ),
      );
      await tester.tap(find.byType(SeedChip));
      await tester.pump();
      expect(checkboxValue(tester), isTrue);
      var clicks = 0;
      await tester.pumpWidget(
        host(SeedChip(label: 'Button', onPressed: () => clicks++)),
      );
      await tester.tap(find.text('Button'));
      await tester.pump();
      expect(clicks, 1);
    },
  );

  testWidgets('image reaction uses pressed defaults and controlled proposals', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        SeedImageFrameReactionButton(
          defaultPressed: true,
          onPressedChange: changes.add,
        ),
      ),
    );
    await tester.tap(find.byType(SeedImageFrameReactionButton));
    await tester.pump();
    expect(changes, [false]);
    await tester.pumpWidget(
      host(
        SeedImageFrameReactionButton(
          key: const ValueKey('controlled'),
          pressed: true,
          onPressedChange: changes.add,
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byType(SeedImageFrameReactionButton));
      await tester.pump();
    }
    expect(changes, [false, false, false]);
  });

  testWidgets('select box checked API supports local and parent-owned values', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        SeedSelectBox(
          title: 'Box',
          defaultChecked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Box'));
    await tester.pumpAndSettle();
    expect(changes, [false]);
    await tester.pumpWidget(
      host(
        SeedSelectBox(
          key: const ValueKey('controlled'),
          title: 'Box',
          checked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Box'));
      await tester.pumpAndSettle();
    }
    expect(changes, [false, false, false]);
  });

  testWidgets('radio select box group exposes onValueChange', (tester) async {
    final changes = <Object?>[];
    await tester.pumpWidget(
      host(
        SeedSelectBoxGroup(
          value: 'a',
          onValueChange: changes.add,
          children: const [
            SeedSelectBox(title: 'Alpha', value: 'a'),
            SeedSelectBox(title: 'Beta', value: 'b'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(changes, ['b', 'b']);
  });

  testWidgets('pagination page remains owned by a rejecting parent', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(
      host(
        SeedPagination(
          page: 2,
          totalPages: 10,
          onPageChange: (change) => changes.add(change.page),
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.bySemanticsLabel('다음 페이지'));
      await tester.pumpAndSettle();
    }
    expect(changes, [3, 3]);
  });

  testWidgets('side navigation item and provider expose canonical callbacks', (
    tester,
  ) async {
    final opened = <bool>[];
    final collapsed = <bool>[];
    await tester.pumpWidget(
      host(
        SeedSideNavigation(
          collapsed: false,
          onCollapsedChange: collapsed.add,
          groups: [
            SeedSideNavGroup(
              items: [
                SeedSideNavItem(
                  id: 'parent',
                  label: 'Parent',
                  open: false,
                  onOpenChange: opened.add,
                  subItems: const [
                    SeedSideNavSubItem(id: 'child', label: 'Child'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(opened, [true, true]);
    final trigger = find.byIcon(Icons.menu_open);
    expect(trigger, findsOneWidget);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(collapsed, [true]);
  });

  testWidgets(
    'slider array callbacks report immutable changes and commit once',
    (tester) async {
      final changes = <List<double>>[];
      final commits = <List<double>>[];
      await tester.pumpWidget(
        host(
          SeedSlider(
            defaultValues: const [20],
            onValuesChange: changes.add,
            onValuesCommit: commits.add,
          ),
        ),
      );
      await tester.drag(find.byType(Slider), const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(changes, isNotEmpty);
      expect(commits, hasLength(1));
      expect(commits.single, changes.last);
      expect(() => changes.first.add(0), throwsUnsupportedError);
      expect(() => commits.single.add(0), throwsUnsupportedError);
    },
  );

  testWidgets(
    'slider array range and controlled refusal preserve both thumbs',
    (tester) async {
      final proposals = <List<double>>[];
      await tester.pumpWidget(
        host(SeedSlider(values: const [20, 80], onValuesChange: proposals.add)),
      );
      final slider = find.byType(RangeSlider);
      await tester.drag(slider, const Offset(60, 0));
      await tester.pumpAndSettle();
      expect(proposals, isNotEmpty);
      expect(proposals.last, hasLength(2));
      expect(
        tester.widget<RangeSlider>(slider).values,
        const RangeValues(20, 80),
      );
    },
  );

  testWidgets(
    'wheel defaultValue is one-time and reports value with step details',
    (tester) async {
      final values = <String>[];
      final steps = <int>[];
      final indices = <int>[];
      Widget build(String seed) => host(
        SeedWheelPicker(
          columns: [
            SeedWheelColumn.value(
              items: const ['a', 'b', 'c', 'd'],
              defaultValue: seed,
              onValueChange: (value, details) {
                values.add(value);
                steps.add(details.stepDelta);
              },
              onIndexChange: (index, value) => indices.add(index),
            ),
          ],
        ),
      );
      await tester.pumpWidget(build('b'));
      final wheel = find.byType(ListWheelScrollView);
      final controller =
          tester.widget<ListWheelScrollView>(wheel).controller!
              as FixedExtentScrollController;
      expect(controller.selectedItem, 1);
      await tester.tap(wheel);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(values, ['c']);
      expect(steps, [1]);
      expect(indices.last, 2);
      await tester.pumpWidget(build('a'));
      await tester.pumpAndSettle();
      final current =
          tester.widget<ListWheelScrollView>(wheel).controller!
              as FixedExtentScrollController;
      expect(current.selectedItem, 2);
      expect(values, ['c']);
    },
  );

  testWidgets(
    'slider keyboard changes commit and default props remain one-time',
    (tester) async {
      final changes = <List<double>>[];
      final commits = <List<double>>[];
      Widget build(double seed) => host(
        SeedSlider(
          defaultValues: [seed],
          onValuesChange: changes.add,
          onValuesCommit: commits.add,
        ),
      );
      await tester.pumpWidget(build(20));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(changes, [
        [21.0],
      ]);
      expect(commits, [
        [21.0],
      ]);
      await tester.pumpWidget(build(90));
      expect(tester.widget<Slider>(find.byType(Slider)).value, 21);
      expect(changes, hasLength(1));
      expect(commits, hasLength(1));
    },
  );

  testWidgets('wheel controlled values can reject repeated proposals', (
    tester,
  ) async {
    final changes = <String>[];
    final steps = <int>[];
    await tester.pumpWidget(
      host(
        SeedWheelPicker(
          columns: [
            SeedWheelColumn.value(
              items: const ['a', 'b', 'c'],
              value: 'b',
              onValueChange: (value, details) {
                changes.add(value);
                steps.add(details.stepDelta);
              },
            ),
          ],
        ),
      ),
    );
    final wheel = find.byType(ListWheelScrollView);
    await tester.tap(wheel);
    for (var i = 0; i < 2; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }
    expect(changes, ['c', 'c']);
    expect(steps, [1, 1]);
    final controller =
        tester.widget<ListWheelScrollView>(wheel).controller!
            as FixedExtentScrollController;
    expect(controller.selectedItem, 1);
  });

  testWidgets(
    'wheel looping across a full cycle keeps value notifications distinct',
    (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        host(
          SeedWheelPicker(
            columns: [
              SeedWheelColumn.value(
                items: const ['a', 'b', 'c'],
                defaultValue: 'b',
                loop: true,
                onValueChange: (value, details) => changes.add(value),
              ),
            ],
          ),
        ),
      );
      final wheel = find.byType(ListWheelScrollView);
      final controller =
          tester.widget<ListWheelScrollView>(wheel).controller!
              as FixedExtentScrollController;
      controller.animateToItem(
        4,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    },
  );

  testWidgets('disabled checked controls do not mutate or notify', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SeedCheckbox(
              enabled: false,
              defaultChecked: true,
              onCheckedChange: changes.add,
            ),
            SeedChip(
              label: 'Disabled',
              enabled: false,
              defaultChecked: true,
              onCheckedChange: changes.add,
            ),
            SeedSelectBox(
              title: 'Readonly',
              readOnly: true,
              defaultChecked: true,
              onCheckedChange: changes.add,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(SeedCheckbox));
    await tester.tap(find.text('Disabled'));
    await tester.tap(find.text('Readonly'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  testWidgets(
    'wheel preserves selected values through option reorder and removal',
    (tester) async {
      final changes = <String>[];
      Widget build(List<String> items, String seed) => host(
        SeedWheelPicker(
          columns: [
            SeedWheelColumn.value(
              items: items,
              defaultValue: seed,
              onValueChange: (value, details) => changes.add(value),
            ),
          ],
        ),
      );
      int selected() =>
          (tester
                      .widget<ListWheelScrollView>(
                        find.byType(ListWheelScrollView),
                      )
                      .controller!
                  as FixedExtentScrollController)
              .selectedItem;
      await tester.pumpWidget(build(['a', 'b', 'c'], 'b'));
      expect(selected(), 1);
      await tester.pumpWidget(build(['b', 'c', 'a'], 'a'));
      await tester.pumpAndSettle();
      expect(selected(), 0);
      await tester.pumpWidget(build(['x', 'b', 'c', 'a'], 'x'));
      await tester.pumpAndSettle();
      expect(selected(), 1);
      await tester.pumpWidget(build(['a', 'c'], 'c'));
      await tester.pumpAndSettle();
      expect(selected(), 0);
      expect(changes, isEmpty);
    },
  );

  test(
    'deprecated callbacks and RangeValues retain canonical getter adapters',
    () {
      void opened(bool open, SeedOverlayDismissReason reason) {}
      final trigger = SeedDialogTrigger(
        triggerBuilder: (context, open, toggle) => const SizedBox(),
        builder: (_) => const SizedBox(),
        // ignore: deprecated_member_use
        onOpenChanged: opened,
      );
      expect(trigger.onOpenChange, same(opened));
      const slider = SeedSlider.range(
        values: RangeValues(20, 80),
        defaultValues: RangeValues(10, 90),
      );
      expect(slider.values, [20.0, 80.0]);
      expect(slider.defaultValues, [10.0, 90.0]);
      expect(() => slider.values!.add(0), throwsUnsupportedError);
    },
  );

  test('duplicate canonical and legacy names fail explicitly', () {
    void changed(bool value) {}
    expect(
      () => SeedSideNavItem(
        id: 'a',
        label: 'A',
        onOpenChange: changed,
        // ignore: deprecated_member_use
        onOpenChanged: changed,
      ),
      throwsAssertionError,
    );
    expect(
      () => SeedPagination(
        page: 1,
        // ignore: deprecated_member_use
        currentPage: 2,
        totalPages: 10,
      ),
      throwsAssertionError,
    );
    expect(
      () => SeedCheckbox(
        checked: true,
        // ignore: deprecated_member_use
        value: null,
      ),
      throwsAssertionError,
    );
    expect(
      () => SeedSelectBox(
        title: 'Box',
        checked: true,
        // ignore: deprecated_member_use
        selected: false,
      ),
      throwsAssertionError,
    );
  });
}
