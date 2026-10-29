import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

class Probe extends StatefulWidget {
  const Probe({super.key, required this.onMount, required this.onDispose});
  final VoidCallback onMount, onDispose;
  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SeedTextField(label: '메모');
}

void main() {
  for (final lazy in [false, true]) {
    for (final unmount in [false, true]) {
      testWidgets(
        'Popover lazy=$lazy unmount=$unmount controls real content lifetime',
        (tester) async {
          var mounts = 0, disposals = 0;
          final controller = SeedOverlayController();
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            host(
              SeedPopoverTrigger(
                controller: controller,
                lazyMount: lazy,
                unmountOnExit: unmount,
                triggerBuilder: (_, _, toggle) =>
                    TextButton(onPressed: toggle, child: const Text('open')),
                builder: (ctx) => SeedPopover(
                  body: Probe(
                    onMount: () => mounts++,
                    onDispose: () => disposals++,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(mounts, lazy ? 0 : 1);
          expect(find.text('메모'), findsNothing);
          controller.open();
          await tester.pumpAndSettle();
          expect(mounts, 1);
          await tester.tap(find.byType(EditableText));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText))
                .focusNode
                .canRequestFocus,
            isTrue,
            reason: 'eager content must become focusable when opened',
          );
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText))
                .focusNode
                .hasFocus,
            isTrue,
          );
          await tester.enterText(find.byType(EditableText), 'keep me');
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText))
                .controller
                .text,
            'keep me',
            reason: 'entered before close',
          );
          controller.close();
          await tester.pumpAndSettle();
          expect(disposals, unmount ? 1 : 0);
          expect(find.text('메모'), findsNothing);
          controller.open();
          await tester.pumpAndSettle();
          expect(mounts, unmount ? 2 : 1);
          expect(controller.isOpen, isTrue, reason: 'reopened');
          expect(find.text('메모'), findsOneWidget, reason: 'visible again');
          expect(find.text('keep me'), unmount ? findsNothing : findsOneWidget);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  testWidgets(
    'BottomSheet modal changes remove barrier without remounting sheet',
    (tester) async {
      final modal = ValueNotifier(true);
      addTearDown(modal.dispose);
      var backgroundTaps = 0;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => backgroundTaps++,
                  child: const Text('background'),
                ),
                TextButton(
                  onPressed: () => showSeedBottomSheet<void>(
                    context: context,
                    modalListenable: modal,
                    child: const SeedBottomSheet(
                      title: 'sheet',
                      content: SeedTextField(label: 'value'),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ],
            ),
          ),
        ),
      );
      final baselineBarriers = find
          .byWidgetPredicate(
            (w) => w is ModalBarrier || w is AnimatedModalBarrier,
          )
          .evaluate()
          .length;
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'retained');
      final barriers = find.byWidgetPredicate(
        (w) => w is ModalBarrier || w is AnimatedModalBarrier,
      );
      expect(barriers, findsWidgets);
      modal.value = false;
      await tester.pumpAndSettle();
      expect(barriers, findsNWidgets(baselineBarriers));
      expect(find.text('retained'), findsOneWidget);
      await tester.tapAt(const Offset(65, 24));
      await tester.pumpAndSettle();
      expect(backgroundTaps, 1);
      expect(find.text('sheet'), findsOneWidget);
      modal.value = true;
      await tester.pumpAndSettle();
      expect(barriers, findsWidgets);
      expect(find.text('retained'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
