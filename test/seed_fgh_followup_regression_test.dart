import 'dart:ui' show SemanticsAction, SemanticsActionEvent;

import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart'
    show SemanticsValidationResult, SemanticsNode;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

class CounterPanel extends StatefulWidget {
  const CounterPanel({super.key});
  @override
  State<CounterPanel> createState() => _CounterPanelState();
}

class _CounterPanelState extends State<CounterPanel> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => count++),
      child: Text('count=$count'),
    ),
  );
}

SemanticsNode? actionNode(SemanticsNode node, SemanticsAction action) {
  if (node.getSemanticsData().hasAction(action)) return node;
  SemanticsNode? found;
  node.visitChildren((child) {
    found = actionNode(child, action);
    return found == null;
  });
  return found;
}

void main() {
  testWidgets('controlled text field accepts external update inside Form', (
    tester,
  ) async {
    var value = 'first';
    final formKey = GlobalKey<FormState>();
    String? saved;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Form(
              key: formKey,
              child: SeedTextField(
                value: value,
                validator: (text) => text == value ? null : 'stale value',
                onSaved: (text) => saved = text,
              ),
            );
          },
        ),
      ),
    );
    update(() => value = 'second');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('second'), findsOneWidget);
    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();
    expect(saved, 'second');
    await tester.enterText(find.byType(TextField), 'unaccepted edit');
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('carousel tabs preserve state with default keepAlive', (
    tester,
  ) async {
    final controller = SeedTabsController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        SeedTabsView(
          controller: controller,
          carousel: true,
          height: 250,
          items: const [
            SeedTabItem(label: 'Tab A'),
            SeedTabItem(label: 'Tab B'),
            SeedTabItem(label: 'Tab C'),
          ],
          children: const [CounterPanel(), Text('second'), Text('third')],
        ),
      ),
    );
    await tester.tap(find.text('count=0'));
    await tester.pump();
    expect(find.text('count=1'), findsOneWidget);
    controller.animateTo(2);
    await tester.pumpAndSettle();
    controller.animateTo(0);
    await tester.pumpAndSettle();
    expect(find.text('count=1'), findsOneWidget);
  });

  testWidgets('slider invalid propagates validation semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(const SeedSlider(invalid: true, semanticsLabel: 'invalid slider')),
    );
    final node = tester.getSemantics(find.byType(Slider));
    expect(
      node.getSemanticsData().validationResult,
      SemanticsValidationResult.invalid,
    );
    semantics.dispose();
  });

  testWidgets(
    'radio group skips disabled wrapped cards and has one Tab entry',
    (tester) async {
      final changes = <Object?>[];
      await tester.pumpWidget(
        host(
          SeedSelectBoxGroup(
            defaultValue: 'a',
            onValueChanged: changes.add,
            children: const [
              Padding(
                padding: EdgeInsets.all(4),
                child: SeedSelectBox(title: 'First', value: 'a'),
              ),
              SeedSelectBox(title: 'Disabled', value: 'b', enabled: false),
              SeedSelectBox(title: 'Last', value: 'c'),
            ],
          ),
        ),
      );
      final nodes = tester
          .widgetList<FocusableActionDetector>(
            find.byType(FocusableActionDetector),
          )
          .map((detector) => detector.focusNode!)
          .toList();
      expect(nodes.map((node) => node.skipTraversal), [false, true, true]);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(nodes.first.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(nodes.last.hasPrimaryFocus, isTrue);
      expect(changes, ['c']);
      expect(nodes.map((node) => node.skipTraversal), [true, true, false]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(changes, ['c', 'a']);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(changes, ['c', 'a', 'c']);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(changes, ['c', 'a', 'c', 'a']);
    },
  );

  for (final unmount in [false, true]) {
    testWidgets('carousel keepAlive honors unmountOnExit=$unmount', (
      tester,
    ) async {
      final controller = SeedTabsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          SeedTabsView(
            controller: controller,
            carousel: true,
            height: 200,
            lazyMount: true,
            unmountOnExit: unmount,
            items: const [
              SeedTabItem(label: 'A'),
              SeedTabItem(label: 'B'),
              SeedTabItem(label: 'C'),
            ],
            children: const [CounterPanel(), Text('B page'), Text('C page')],
          ),
        ),
      );
      await tester.tap(find.text('count=0'));
      await tester.pump();
      controller.animateTo(2);
      await tester.pumpAndSettle();
      controller.animateTo(0);
      await tester.pumpAndSettle();
      expect(find.text('count=${unmount ? 0 : 1}'), findsOneWidget);
    });
  }

  testWidgets(
    'tag truncation remeasures resized separators and preserves fixed tags',
    (tester) async {
      var separatorWidth = 20.0;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SizedBox(
                width: 180,
                child: SeedTagGroup(
                  truncate: true,
                  separatorWidget: SizedBox(width: separatorWidth),
                  items: const [
                    SeedTagItem(label: 'Fixed', flexShrink: 0),
                    SeedTagItem(label: 'A long label to truncate'),
                  ],
                ),
              );
            },
          ),
        ),
      );
      final fixedWidth = tester.getSize(find.text('Fixed')).width;
      final longWidth = tester
          .getSize(find.text('A long label to truncate'))
          .width;
      update(() => separatorWidth = 70);
      await tester.pump();
      expect(tester.getSize(find.text('Fixed')).width, fixedWidth);
      expect(
        tester.getSize(find.text('A long label to truncate')).width,
        closeTo(longWidth - 50, .01),
      );
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position
            .maxScrollExtent,
        0,
      );
    },
  );

  testWidgets(
    'slider explicit step and range accessibility use matching increments',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const SeedSlider(min: 0, max: 10, defaultValue: 4, step: 2)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(tester.widget<Slider>(find.byType(Slider)).value, 6);
      final node = tester.getSemantics(find.byType(Slider));
      tester.binding.performSemanticsAction(
        SemanticsActionEvent(
          nodeId: actionNode(node, SemanticsAction.decrease)!.id,
          viewId: tester.view.viewId,
          type: SemanticsAction.decrease,
        ),
      );
      await tester.pump();
      expect(tester.widget<Slider>(find.byType(Slider)).value, 4);
      await tester.pumpWidget(
        host(
          const SeedSlider.range(
            min: 0,
            max: 10,
            defaultValues: RangeValues(3, 7),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(
        tester.widget<RangeSlider>(find.byType(RangeSlider)).values,
        const RangeValues(2, 7),
      );
      semantics.dispose();
    },
  );

  testWidgets('slider markers anchor to track positions in RTL', (
    tester,
  ) async {
    for (final align in SeedSliderMarkerAlign.values) {
      await tester.pumpWidget(
        host(
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 300,
              child: SeedSlider(
                markers: [SeedSliderMarker(25, 'marker', align: align)],
              ),
            ),
          ),
        ),
      );
      final bounds = tester.getRect(find.text('marker'));
      final origin = tester.getTopLeft(find.byType(SeedSlider));
      final expected = origin.dx + 24 + .75 * (300 - 48);
      final anchor = switch (align) {
        SeedSliderMarkerAlign.start => bounds.right,
        SeedSliderMarkerAlign.center => bounds.center.dx,
        SeedSliderMarkerAlign.end => bounds.left,
      };
      expect(anchor, closeTo(expected, .01));
    }
  });

  testWidgets('slider default step supports keyboard decrement', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const SeedSlider(min: 0, max: 10, defaultValue: 5)),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(tester.widget<Slider>(find.byType(Slider)).value, 4);
  });

  testWidgets('time picker keeps rounded AMPM when moving hour from 11 to 12', (
    tester,
  ) async {
    TimeOfDay? changed;
    await tester.pumpWidget(
      host(
        SeedTimePicker(
          initialTime: const TimeOfDay(hour: 11, minute: 0),
          locale: const Locale('en', 'US'),
          onChanged: (d) => changed = d,
        ),
      ),
    );
    final wheel = tester.widget<ListWheelScrollView>(
      find.byType(ListWheelScrollView).first,
    );
    final controller = wheel.controller as FixedExtentScrollController;
    controller.animateToItem(
      12,
      duration: const Duration(milliseconds: 50),
      curve: Curves.linear,
    );
    await tester.pumpAndSettle();
    expect(changed, const TimeOfDay(hour: 12, minute: 0));
    final pickers = tester
        .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
        .toList();
    expect(
      (pickers[2].controller as FixedExtentScrollController).selectedItem,
      1,
    );
  });
}
