import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  testWidgets('a collapsed snap sheet expands again by its handle and body', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final snap = SeedSheetController(initialIndex: 1);
    addTearDown(snap.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(
          body: SeedBottomSheetTrigger(
            snapController: snap,
            snapPoints: const [
              SeedSheetSnapPoint.fraction(.2),
              SeedSheetSnapPoint.fraction(.5),
              SeedSheetSnapPoint.fraction(.9),
            ],
            triggerBuilder: (_, open, toggle) =>
                TextButton(onPressed: toggle, child: const Text('Open sheet')),
            builder: (_) => SeedBottomSheet(
              title: 'Sheet title',
              showHandle: true,
              content: Column(
                children: List.generate(
                  20,
                  (i) => SeedListItem(titleText: 'Item $i'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    final handle = find.descendant(
      of: find.byType(SeedSnappingBottomSheet),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector && widget.onVerticalDragUpdate != null,
      ),
    );
    DraggableScrollableController drag() => tester
        .widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet))
        .controller!;
    expect(drag().size, closeTo(.5, .01));
    await tester.drag(handle, const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(drag().size, closeTo(.2, .01));
    await tester.drag(handle, const Offset(0, -280));
    await tester.pumpAndSettle();
    expect(drag().size, greaterThan(.4));
    await tester.drag(handle, const Offset(0, 220));
    await tester.pumpAndSettle();
    expect(drag().size, closeTo(.2, .01));
    final body = find.descendant(
      of: find.byType(SeedSnappingBottomSheet),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(body, const Offset(0, -280));
    await tester.pumpAndSettle();
    expect(drag().size, greaterThan(.4));
    expect(tester.takeException(), isNull);
  });
}
