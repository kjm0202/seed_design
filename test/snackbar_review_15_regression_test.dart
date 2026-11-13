import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(SeedSnackbarController controller, Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: SeedSnackbarProvider(controller: controller, child: child),
);

void main() {
  testWidgets('tracks an obstacle moved without rebuilding or resizing it', (
    tester,
  ) async {
    final controller = SeedSnackbarController();
    addTearDown(controller.dispose);
    final bottom = ValueNotifier<double>(300);
    addTearDown(bottom.dispose);
    const obstacle = SeedSnackbarAvoidOverlap(
      child: SizedBox(key: ValueKey('obstacle'), width: 200, height: 80),
    );
    await tester.pumpWidget(
      _host(
        controller,
        Scaffold(
          body: ValueListenableBuilder<double>(
            valueListenable: bottom,
            child: obstacle,
            builder: (context, value, child) => Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: 0,
                  right: 0,
                  bottom: value,
                  child: child!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    bottom.value = 0;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    controller.show(child: const SeedSnackbar(message: 'moved obstacle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester
          .getRect(find.byType(SeedSnackbar))
          .overlaps(tester.getRect(find.byKey(const ValueKey('obstacle')))),
      isFalse,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final attachFirst in [false, true]) {
    testWidgets('discard first unseen entry (attached=$attachFirst)', (
      tester,
    ) async {
      final controller = SeedSnackbarController();
      addTearDown(controller.dispose);
      final callbacks = <String>[];
      if (attachFirst) {
        await tester.pumpWidget(_host(controller, const SizedBox.expand()));
      }
      controller.show(
        child: const Text('first'),
        onDiscard: () => callbacks.add('discard'),
        onClose: () => callbacks.add('close'),
      );
      controller.show(child: const Text('second'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(callbacks, ['discard', 'close']);
      if (!attachFirst) {
        await tester.pumpWidget(_host(controller, const SizedBox.expand()));
      }
      await tester.pump();
      expect(find.text('second'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('a displayed entry closes without discard', (tester) async {
    final controller = SeedSnackbarController();
    addTearDown(controller.dispose);
    final callbacks = <String>[];
    await tester.pumpWidget(_host(controller, const SizedBox.expand()));
    controller.show(
      child: const Text('shown'),
      onDiscard: () => callbacks.add('discard'),
      onClose: () => callbacks.add('close'),
    );
    await tester.pump();
    controller.show(child: const Text('next'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(callbacks, ['close']);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
