import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design_example/main.dart' as app;
import 'package:seed_design_example/stackflow_spa/spa_routes.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  // Official app-screen.css: `seed-app-screen__dim` is part of the entering
  // AppScreen and sits under its layer. A modal Activity (BottomSheet) has no
  // AppScreen, so nothing may darken the page under its own backdrop.
  testWidgets('AppScreen dim belongs to the entering Activity', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/tabs');
    await tester.pumpAndSettle();
    navigator.pushNamed('/bottom-sheet');
    await tester.pumpAndSettle();

    final dims = find.byType(SpaActivityDim, skipOffstage: false);
    expect(dims, findsWidgets);
    for (final element in dims.evaluate()) {
      final dim = element.widget as SpaActivityDim;
      final route = ModalRoute.of(element)!;
      // Driven by its own entrance, not by the Activity pushed above it.
      expect(dim.animation, same(route.animation));
      // The page is painted over the dim, so a settled Activity hides it.
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byWidget(dim, skipOffstage: false),
              matching: find.byType(Stack, skipOffstage: false),
            )
            .first,
      );
      expect(stack.children.first, isA<Positioned>());
      expect(stack.children.last, isNot(isA<Positioned>()));
    }
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 800.0]) {
    testWidgets(
      'ordinary Activity scrollport respects both side safe insets $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(left: 24, right: 32);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
            .pushNamed('/list-item');
        await tester.pumpAndSettle();
        final list = tester.getRect(find.byType(ListView).last);
        expect(list.left, closeTo(24, 1));
        expect(list.right, closeTo(width - 32, 1));
        expect(tester.takeException(), isNull);
      },
    );
  }
  group('entrypoint', () {
    testWidgets('default entrypoint launches the Stackflow SPA', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(StackflowSpaApp), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('App Bar 슬롯과 긴 제목'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
