import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<NavigatorState> _open(
  WidgetTester tester,
  String route, {
  Size size = const Size(440, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pumpAndSettle();
  return navigator;
}

void main() {
  testWidgets('MenuSheet Simple is swipeable and selection notifies parent', (
    tester,
  ) async {
    final navigator = await _open(tester, '/menu-sheet-activity');
    navigator.pushNamed('/menu-sheet-activity/simple');
    await tester.pumpAndSettle();
    final route = ModalRoute.of(tester.element(find.byType(SeedMenuSheet)))!;
    expect(route, isA<mui.ModalBottomSheetRoute>());
    expect((route as mui.ModalBottomSheetRoute).enableDrag, isTrue);
    final widget = tester.widget<SeedMenuSheet>(find.byType(SeedMenuSheet));
    expect(widget.showCancelButton, isFalse);
    expect(find.text('닫기'), findsNothing);
    await tester.tap(find.text('수정'));
    await tester.pumpAndSettle();
    expect(find.byType(SeedMenuSheet), findsNothing);
    expect(find.textContaining('선택한 액션: edit'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MenuSheet Simple handle drag dismisses its activity', (
    tester,
  ) async {
    final navigator = await _open(tester, '/menu-sheet-activity');
    navigator.pushNamed('/menu-sheet-activity/simple');
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byType(SeedMenuSheet));
    await tester.timedDragFrom(
      Offset(rect.center.dx, rect.top + 8),
      const Offset(0, 400),
      const Duration(milliseconds: 320),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SeedMenuSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Nested AlertDialog ignores outside tap but confirms close', (
    tester,
  ) async {
    await _open(tester, '/nested-bottom-sheet');
    await tester.tap(find.widgetWithText(SeedButton, 'Open AlertDialog'));
    await tester.pumpAndSettle();
    expect(find.byType(SeedAlertDialog), findsOneWidget);
    await tester.tapAt(const Offset(10, 380));
    await tester.pumpAndSettle();
    expect(find.byType(SeedAlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(SeedButton, '확인').last);
    await tester.pumpAndSettle();
    expect(find.byType(SeedAlertDialog), findsNothing);
    expect(find.byType(SeedBottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1000.0]) {
    testWidgets('Responsive SidePanel confirm preserves layer at $width', (
      tester,
    ) async {
      await _open(tester, '/responsive-side-panel', size: Size(width, 900));
      expect(
        width < 768 ? find.byType(SeedBottomSheet) : find.byType(SeedSidePanel),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(SeedButton, '확인').last);
      await tester.pumpAndSettle();
      expect(
        width < 768 ? find.byType(SeedBottomSheet) : find.byType(SeedSidePanel),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Popover remains open while placement changes', (tester) async {
    await _open(tester, '/popover', size: const Size(800, 800));
    final trigger = find.widgetWithText(SeedButton, 'placement=bottom');
    await tester.ensureVisible(trigger);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(find.text('요청 placement: bottom'), findsOneWidget);

    final left = find.widgetWithText(SeedButton, 'left');
    // Exercising the same onPressed callback avoids an offscreen hit-test in
    // the widget harness while the floating popover remains open.
    tester.widget<SeedButton>(left).onPressed?.call();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SeedButton, 'placement=left'), findsOneWidget);
    expect(find.text('요청 placement: left'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Keyboard playground uses pixel snap and fixed is anchoring', (
    tester,
  ) async {
    await _open(tester, '/bottom-sheet-keyboard-playground');
    await tester.tap(find.text('fixed: off'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeedBottomSheet>(find.byType(SeedBottomSheet)).expand,
      isFalse,
    );
    final snapToggle = find.text('snapPoints: off');
    await tester.ensureVisible(snapToggle);
    await tester.tap(snapToggle);
    await tester.pumpAndSettle();
    final sheet = tester.widget<SeedSnappingBottomSheet>(
      find.byType(SeedSnappingBottomSheet),
    );
    expect(sheet.snapPoints.first.pixels, 360);
    expect(sheet.snapPoints.last.fraction, 1);
    expect(tester.takeException(), isNull);
  });
}
