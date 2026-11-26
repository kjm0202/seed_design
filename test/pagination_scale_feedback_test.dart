import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

// SEED 3.4.0 (PR #2684) replaced the fixed `scale.s97` press of the pagination
// recipes with the shared size-based Scale Feedback
// (`pressed.root.scaleScope: self`). A control is 40 x 40 px, so
// `basis = max(height, width / 4, 24) = 40` and the pressed scale is
// `(40 - 2) / 40 = 0.95`; the depth is always 2 px, so the rendered box shrinks
// by exactly 2 px to 38 px rather than by 3% of 40 px.
const double _controlSize = 40;
const double _pressedScale = (_controlSize - 2) / _controlSize;

/// The [SeedPressable] that draws [content], for reading its press scale.
Finder _pressableAround(Finder content) =>
    find.ancestor(of: content, matching: find.byType(SeedPressable));

/// The scale that [pressable] paints right now.
///
/// [SeedPressable] applies its scale with a [Transform]; it emits no transform
/// at all while scaling is suppressed (reduced motion, or before the control
/// was measured), which paints the same as a scale of one. The x axis of the
/// matrix carries the scale, because `Transform.scale` leaves z untouched and
/// [Matrix4.getMaxScaleOnAxis] would therefore always report at least 1.
double _paintedScale(WidgetTester tester, Finder pressable) {
  final transform = find.descendant(
    of: pressable,
    matching: find.byType(Transform),
  );
  if (transform.evaluate().isEmpty) return 1;
  final matrix = tester.widget<Transform>(transform).transform;
  return matrix.getRow(0).xyz.length;
}

/// Presses and holds [target] until the press feedback settles.
///
/// The first pump passes `kPressTimeout`, after which the tap recognizer
/// reports the press even while a scroll recognizer still competes for the
/// pointer. The ticker only starts its clock on that frame, so a second pump
/// past `SeedDuration.pressedScale` (150 ms) drives the scale to its pressed
/// value.
Future<TestGesture> _pressAndHold(WidgetTester tester, Finder target) async {
  final gesture = await tester.startGesture(
    tester.getCenter(target),
    kind: PointerDeviceKind.touch,
  );
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 300));
  return gesture;
}

Widget _reducedMotionApp(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

void main() {
  testWidgets('page item presses with the size-based scale feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      seedAppCentered(const SeedPagination(totalPages: 10)),
    );
    await tester.pumpAndSettle();

    final item = _pressableAround(find.text('1'));
    final box = find.descendant(of: item, matching: find.byType(Container));
    expect(_paintedScale(tester, item), 1);
    expect(tester.getRect(box).height, closeTo(_controlSize, .01));

    final gesture = await _pressAndHold(tester, find.text('1'));
    expect(_paintedScale(tester, item), closeTo(_pressedScale, .001));
    expect(
      tester.getRect(box).height,
      closeTo(_controlSize - 2, .01),
      reason: 'the 2 px depth shortens the 40 px control to 38 px',
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_paintedScale(tester, item), 1);
    expect(tester.getRect(box).height, closeTo(_controlSize, .01));
  });

  testWidgets('previous and next buttons press with the size-based scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      seedAppCentered(const SeedPagination(defaultPage: 2, totalPages: 10)),
    );
    await tester.pumpAndSettle();

    // The first press moves to page 3 and the second back to page 2, so each
    // arrow is enabled when it is pressed.
    for (final icon in [Icons.chevron_right, Icons.chevron_left]) {
      final button = _pressableAround(find.byIcon(icon));
      final box = find.descendant(
        of: button,
        matching: find.byType(AnimatedContainer),
      );
      expect(tester.getRect(box).height, closeTo(_controlSize, .01));

      final gesture = await _pressAndHold(tester, find.byIcon(icon));
      expect(_paintedScale(tester, button), closeTo(_pressedScale, .001));
      expect(tester.getRect(box).height, closeTo(_controlSize - 2, .01));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_paintedScale(tester, button), 1);
      expect(tester.getRect(box).height, closeTo(_controlSize, .01));
    }
  });

  testWidgets('table pagination arrows press with the size-based scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      seedAppCentered(
        const SeedTablePagination(
          totalItems: 237,
          value: SeedTablePaginationValue(page: 3, pageSize: 25),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final icon in [Icons.chevron_left, Icons.chevron_right]) {
      final button = _pressableAround(find.byIcon(icon));
      final box = find.descendant(
        of: button,
        matching: find.byType(AnimatedContainer),
      );
      expect(tester.getRect(box).height, closeTo(_controlSize, .01));

      final gesture = await _pressAndHold(tester, find.byIcon(icon));
      expect(_paintedScale(tester, button), closeTo(_pressedScale, .001));
      expect(tester.getRect(box).height, closeTo(_controlSize - 2, .01));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_paintedScale(tester, button), 1);
      expect(tester.getRect(box).height, closeTo(_controlSize, .01));
    }
  });

  testWidgets(
    'disabled pagination controls keep the rest scale while pressed',
    (tester) async {
      await tester.pumpWidget(
        seedAppCentered(const SeedPagination(totalPages: 10, disabled: true)),
      );
      await tester.pumpAndSettle();

      final item = _pressableAround(find.text('1'));
      final itemGesture = await _pressAndHold(tester, find.text('1'));
      expect(_paintedScale(tester, item), 1);
      await itemGesture.up();
      await tester.pumpAndSettle();

      final next = _pressableAround(find.byIcon(Icons.chevron_right));
      final nextGesture = await _pressAndHold(
        tester,
        find.byIcon(Icons.chevron_right),
      );
      expect(_paintedScale(tester, next), 1);
      await nextGesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'disabled table pagination arrows keep the rest scale while pressed',
    (tester) async {
      await tester.pumpWidget(
        seedAppCentered(
          const SeedTablePagination(
            totalItems: 237,
            disabled: true,
            value: SeedTablePaginationValue(page: 3, pageSize: 25),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final next = _pressableAround(find.byIcon(Icons.chevron_right));
      final gesture = await _pressAndHold(
        tester,
        find.byIcon(Icons.chevron_right),
      );
      expect(_paintedScale(tester, next), 1);
      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('reduced motion keeps controls at rest while pressed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _reducedMotionApp(const SeedPagination(totalPages: 10)),
    );
    await tester.pumpAndSettle();

    // The current page is 1, so item 2 uses the plain pressed background. It
    // must still respond to the press; only the physical scale is suppressed.
    final item = _pressableAround(find.text('2'));
    final box = find.descendant(of: item, matching: find.byType(Container));
    final gesture = await _pressAndHold(tester, find.text('2'));
    expect(_paintedScale(tester, item), 1);
    expect(tester.getRect(box).height, closeTo(_controlSize, .01));
    expect(
      (tester.widget<Container>(box).decoration! as BoxDecoration).color,
      SeedThemeData.light().colorScheme.bg.transparentPressed,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    final next = _pressableAround(find.byIcon(Icons.chevron_right));
    final nextGesture = await _pressAndHold(
      tester,
      find.byIcon(Icons.chevron_right),
    );
    expect(_paintedScale(tester, next), 1);
    await nextGesture.up();
    await tester.pumpAndSettle();
  });
}
