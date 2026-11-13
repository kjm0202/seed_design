import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    double width = 390,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('outside and drag policies are independent', (tester) async {
    final reasons = <SeedOverlayDismissReason>[];
    await mount(
      tester,
      SeedBottomSheetTrigger(
        closeOnInteractOutside: false,
        onOpenChange: (open, reason) {
          if (!open) reasons.add(reason);
        },
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => const SeedBottomSheet(
          title: 'Sheet title',
          content: SizedBox(height: 300),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 30));
    await tester.pumpAndSettle();
    expect(find.text('Sheet title'), findsOneWidget);
    await tester.fling(find.text('Sheet title'), const Offset(0, 250), 1200);
    await tester.pumpAndSettle();
    expect(find.text('Sheet title'), findsNothing);
    expect(reasons, [SeedOverlayDismissReason.drag]);
  });

  testWidgets('a rejected drag restores the open sheet position', (
    tester,
  ) async {
    await mount(
      tester,
      SeedBottomSheetTrigger(
        canClose: (reason) => reason != SeedOverlayDismissReason.drag,
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => const SeedBottomSheet(
          title: 'Sheet title',
          content: SizedBox(height: 300),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final title = find.text('Sheet title');
    final position = tester.getTopLeft(title);
    await tester.fling(title, const Offset(0, 250), 1200);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(title), position);
  });

  testWidgets('responsive dialog resizes without losing its editor state', (
    tester,
  ) async {
    final visibility = <bool>[];
    await mount(
      tester,
      SeedDialogTrigger(
        responsive: true,
        onOpenChange: (open, _) => visibility.add(open),
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => const SeedDialog(
          title: 'Title',
          content: SeedTextInput(defaultValue: 'Original'),
        ),
      ),
      width: 800,
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final editor = find.byType(EditableText);
    await tester.enterText(editor, 'Edited');
    final editorState = tester.state(editor);
    for (final width in [390.0, 800.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpAndSettle();
      expect(
        find.byType(SeedBottomSheet),
        width < 768 ? findsOneWidget : findsNothing,
      );
      expect(tester.state(editor), same(editorState));
      expect(tester.widget<EditableText>(editor).controller.text, 'Edited');
      expect(tester.widget<EditableText>(editor).focusNode.hasFocus, isTrue);
    }
    expect(visibility, [true]);
  });

  testWidgets('snapping sheet forwards close and handle callbacks', (
    tester,
  ) async {
    var closes = 0, taps = 0, updates = 0, ends = 0;
    await mount(
      tester,
      SeedBottomSheetTrigger(
        snapPoints: const [
          SeedSheetSnapPoint.fraction(.4),
          SeedSheetSnapPoint.fraction(.8),
        ],
        handleOnly: true,
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => SeedBottomSheet(
          title: 'Snap sheet',
          showHandle: true,
          onClosePressed: () => closes++,
          onHandleTap: () => taps++,
          onHandleDrag: (_) => updates++,
          onHandleDragEnd: () => ends++,
          content: const SizedBox(height: 100),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final sheet = find.byType(SeedBottomSheet);
    final handle = find
        .descendant(
          of: sheet,
          matching: find.byWidgetPredicate(
            (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
          ),
        )
        .first;
    await tester.tap(handle);
    await tester.pumpAndSettle();
    await tester.drag(handle, const Offset(0, 100));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect((closes, taps, ends), (1, 1, 1));
    expect(updates, greaterThan(0));
    expect(find.text('Snap sheet'), findsOneWidget);
  });

  testWidgets('responsive panel keeps custom content and close configuration', (
    tester,
  ) async {
    var closes = 0;
    await mount(
      tester,
      SeedSidePanelTrigger(
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => SeedSidePanel(
          title: 'Fallback',
          titleWidget: const Text('Custom title'),
          descriptionWidget: const Text('Custom description'),
          bodyPadding: const EdgeInsets.all(30),
          showCloseButton: true,
          onClose: () => closes++,
          body: const Text('Panel body'),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Custom title'), findsOneWidget);
    expect(find.text('Custom description'), findsOneWidget);
    expect(
      tester
          .widget<SeedBottomSheet>(find.byType(SeedBottomSheet))
          .contentPadding,
      const EdgeInsets.all(30),
    );
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(closes, 1);
    expect(find.text('Panel body'), findsOneWidget);
  });

  testWidgets('panel swipe uses drag policy and escape remains independent', (
    tester,
  ) async {
    final reasons = <SeedOverlayDismissReason>[];
    await mount(
      tester,
      SeedSidePanelTrigger(
        responsive: false,
        closeOnInteractOutside: false,
        closeOnEscape: false,
        onOpenChange: (open, reason) {
          if (!open) reasons.add(reason);
        },
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) =>
            const SeedSidePanel(title: 'Panel', body: SizedBox(height: 150)),
      ),
      width: 1000,
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Panel'), findsOneWidget);
    await tester.fling(find.text('Panel'), const Offset(180, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Panel'), findsNothing);
    expect(reasons, [SeedOverlayDismissReason.drag]);
  });
}
