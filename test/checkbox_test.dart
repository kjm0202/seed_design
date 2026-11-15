import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

void main() {
  group('tristate', () {
    testWidgets('tristate checkbox exposes mixed state', (tester) async {
      await tester.pumpWidget(
        koreanAppCentered(
          SeedCheckbox(
            value: null,
            tristate: true,
            label: '일부',
            onChanged: (_) {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(SeedCheckbox)),
        matchesSemantics(
          label: '일부',
          hasCheckedState: true,
          isCheckStateMixed: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });
  });

  group('semantics and target', () {
    testWidgets('checkbox exposes checked state and has a minimum target', (
      tester,
    ) async {
      var changes = 0;
      await tester.pumpWidget(
        themedApp(
          Padding(
            padding: const EdgeInsets.all(24),
            child: SeedCheckbox(value: true, onChanged: (_) => changes++),
          ),
        ),
      );
      // React keeps the 20px layout size and extends only the touch area.
      expect(tester.getSize(find.byType(SeedCheckbox)).shortestSide, 20);
      await tester.tapAt(
        tester.getCenter(find.byType(SeedCheckbox)) + const Offset(20, 0),
      );
      expect(changes, 1);
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(SeedCheckbox),
            matching: find.byType(SeedPressable),
          ),
        ),
        matchesSemantics(
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });
  });

  group('hover', () {
    testWidgets(
      'hover changes checkmark color without applying physical press scale',
      (tester) async {
        await tester.pumpWidget(
          koreanApp(
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
        expect(
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          1,
        );
        await mouse.removePointer();
      },
    );
  });

  group('label alignment', () {
    const longLabel =
        '새로운 메시지가 도착할 때마다 푸시 알림을 받을 수 있습니다. 언제든지 변경할 수 있어요. '
        '이 문장은 두 줄 이상으로 줄바꿈되어야 합니다.';
    group('Checkbox / Radio: recipe align-items flex-start', () {
      testWidgets('a wrapped checkbox label keeps the mark on its first line', (
        tester,
      ) async {
        await tester.pumpWidget(
          koreanAppTopLeft(
            SeedCheckbox(value: false, onChanged: (_) {}, label: longLabel),
          ),
        );
        final label = tester.getRect(find.text(longLabel));
        final root = tester.getRect(find.byType(SeedCheckbox));
        final mark = tester.getRect(find.byType(SeedControlFocusRing).first);
        expect(label.height, greaterThan(40), reason: 'label must wrap');
        // (32 - 20) / 2 = 6px from the root top, not centered on the label.
        expect(mark.top - root.top, moreOrLessEquals(6, epsilon: 0.5));
        expect(mark.center.dy, lessThan(label.center.dy - 8));
      });

      testWidgets('a wrapped radio label keeps the mark on its first line', (
        tester,
      ) async {
        await tester.pumpWidget(
          koreanAppTopLeft(
            SeedRadioGroup<String>(
              value: 'a',
              child: const SeedRadio<String>(value: 'a', label: longLabel),
            ),
          ),
        );
        final label = tester.getRect(find.text(longLabel));
        final root = tester.getRect(find.byType(SeedRadio<String>));
        final mark = tester.getRect(find.byType(SeedControlFocusRing).first);
        expect(label.height, greaterThan(40));
        expect(mark.top - root.top, moreOrLessEquals(6, epsilon: 0.5));
      });

      testWidgets('a single-line label is still centered within 32px', (
        tester,
      ) async {
        await tester.pumpWidget(
          koreanAppTopLeft(
            SeedCheckbox(value: true, onChanged: (_) {}, label: '사과'),
          ),
        );
        final root = tester.getRect(find.byType(SeedCheckbox));
        final mark = tester.getRect(find.byType(SeedControlFocusRing).first);
        final label = tester.getRect(find.text('사과'));
        expect(root.height, 32);
        expect(mark.center.dy, moreOrLessEquals(root.center.dy, epsilon: 0.5));
        expect(label.center.dy, moreOrLessEquals(root.center.dy, epsilon: 1));
      });
    });
  });

  group('checkbox group', () {
    Widget host(Widget child, {double width = 320}) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

    group('CheckboxGroup', () {
      testWidgets('stacks checkboxes with a 4px gap, start aligned', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            const SeedCheckboxGroup(
              children: [
                SeedCheckbox(label: 'Email'),
                SeedCheckbox(label: 'SMS'),
                SeedCheckbox(label: 'Phone call'),
              ],
            ),
          ),
        );
        final boxes = find.byType(SeedCheckbox);
        final first = tester.getRect(boxes.at(0));
        final second = tester.getRect(boxes.at(1));
        final third = tester.getRect(boxes.at(2));
        expect(second.top - first.bottom, 4);
        expect(third.top - second.bottom, 4);
        expect(second.left, first.left);
        expect(third.left, first.left);
      });
    });
  });
}
