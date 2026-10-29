import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

Widget _tooltipApp({
  required ValueChanged<bool> onOpenChange,
  Duration? openDelay,
  Duration? closeDelay,
  bool? keepOpenOnContentHover,
  bool group = false,
  Duration? groupOpenDelay,
}) {
  const trigger = SizedBox(
    width: 120,
    height: 44,
    child: Center(child: Text('Hover here')),
  );
  final tooltip = keepOpenOnContentHover == null
      ? SeedHelpBubbleTooltip(
          title: 'Tooltip open',
          onOpenChange: onOpenChange,
          openDelay: openDelay,
          closeDelay: closeDelay,
          child: trigger,
        )
      : SeedHelpBubbleTooltip(
          title: 'Tooltip open',
          onOpenChange: onOpenChange,
          openDelay: openDelay,
          closeDelay: closeDelay,
          keepOpenOnContentHover: keepOpenOnContentHover,
          child: trigger,
        );
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: !group
            ? tooltip
            : groupOpenDelay == null
            ? SeedTooltipDelayGroup(child: tooltip)
            : SeedTooltipDelayGroup(openDelay: groupOpenDelay, child: tooltip),
      ),
    ),
  );
}

Future<TestGesture> _enterTrigger(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: const Offset(0, 0));
  await tester.pump();
  await mouse.moveTo(tester.getCenter(find.text('Hover here')));
  await tester.pump();
  return mouse;
}

void main() {
  testWidgets(
    'React Tooltip default opens exactly at 200ms and closes at 100ms',
    (tester) async {
      final events = <bool>[];
      await tester.pumpWidget(_tooltipApp(onOpenChange: events.add));
      final mouse = await _enterTrigger(tester);
      await tester.pump(const Duration(milliseconds: 199));
      expect(events, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(events, [true]);
      await mouse.moveTo(const Offset(0, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 99));
      expect(events, [true]);
      await tester.pump(const Duration(milliseconds: 1));
      expect(events, [true, false]);
      await mouse.removePointer();
    },
  );

  testWidgets(
    'React TooltipDelayGroup shares the 200ms default; overrides win',
    (tester) async {
      final events = <bool>[];
      await tester.pumpWidget(
        _tooltipApp(onOpenChange: events.add, group: true),
      );
      final mouse = await _enterTrigger(tester);
      await tester.pump(const Duration(milliseconds: 199));
      expect(events, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(events, [true]);
      await mouse.removePointer();
    },
  );

  testWidgets('explicit per-trigger 350ms open delay wins over group 200ms', (
    tester,
  ) async {
    final events = <bool>[];
    await tester.pumpWidget(
      _tooltipApp(
        onOpenChange: events.add,
        group: true,
        openDelay: const Duration(milliseconds: 350),
      ),
    );
    final mouse = await _enterTrigger(tester);
    await tester.pump(const Duration(milliseconds: 200));
    expect(events, isEmpty);
    await tester.pump(const Duration(milliseconds: 150));
    expect(events, [true]);
    await mouse.removePointer();
  });

  testWidgets('explicit group 350ms openDelay overrides the 200ms default', (
    tester,
  ) async {
    final events = <bool>[];
    await tester.pumpWidget(
      _tooltipApp(
        onOpenChange: events.add,
        group: true,
        groupOpenDelay: const Duration(milliseconds: 350),
      ),
    );
    final mouse = await _enterTrigger(tester);
    await tester.pump(const Duration(milliseconds: 200));
    expect(events, isEmpty);
    await tester.pump(const Duration(milliseconds: 150));
    expect(events, [true]);
    await mouse.removePointer();
  });

  testWidgets(
    'React Tooltip default does not keep floating content open on hover',
    (tester) async {
      final events = <bool>[];
      await tester.pumpWidget(_tooltipApp(onOpenChange: events.add));
      final widget = tester.widget<SeedHelpBubbleTooltip>(
        find.byType(SeedHelpBubbleTooltip),
      );
      expect(widget.keepOpenOnContentHover, false);
      final mouse = await _enterTrigger(tester);
      await tester.pump(const Duration(milliseconds: 200));
      expect(events, [true]);
      await tester.pump(const Duration(milliseconds: 300));
      final content = find.byType(SeedHelpBubble);
      expect(content, findsOneWidget);
      await mouse.moveTo(tester.getCenter(content));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(events, [true, false]);
      await mouse.removePointer();
    },
  );

  testWidgets(
    'explicit keepOpenOnContentHover=true still supports content hover',
    (tester) async {
      final events = <bool>[];
      await tester.pumpWidget(
        _tooltipApp(onOpenChange: events.add, keepOpenOnContentHover: true),
      );
      final mouse = await _enterTrigger(tester);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));
      final bubble = find.byType(SeedHelpBubble);
      await mouse.moveTo(tester.getCenter(bubble));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(events, [true]);
      await mouse.removePointer();
    },
  );

  testWidgets(
    'TooltipDelayGroup retains skip delay for quick successive hover',
    (tester) async {
      final events = <bool>[];
      await tester.pumpWidget(
        _tooltipApp(onOpenChange: events.add, group: true),
      );
      final mouse = await _enterTrigger(tester);
      await tester.pump(const Duration(milliseconds: 200));
      expect(events, [true]);
      await mouse.moveTo(const Offset(0, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(events, [true, false]);
      await mouse.moveTo(tester.getCenter(find.text('Hover here')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(events, [true, false, true]);
      await mouse.removePointer();
    },
  );
}
