import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('fade padding cannot make nearly fitting content overflow', (
    tester,
  ) async {
    var height = 120.0;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedDialog(
              title: 'Title',
              maxHeight: 300,
              content: SizedBox(height: height),
              footer: const SizedBox(height: 40),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SeedScrollFog), findsNothing);
    update(() => height = 170);
    await tester.pumpAndSettle();
    expect(find.byType(SeedScrollFog), findsOneWidget);
    update(() => height = 120);
    await tester.pumpAndSettle();
    expect(find.byType(SeedScrollFog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overflowing dialog bodies scroll while the footer stays fixed', (
    tester,
  ) async {
    var tall = true;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedDialog(
              title: 'Title',
              maxHeight: 400,
              content: SizedBox(
                key: const ValueKey('body'),
                height: tall ? 800 : 40,
              ),
              footer: const SizedBox(key: ValueKey('footer'), height: 40),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fog = find.byType(SeedScrollFog);
    expect(fog, findsOneWidget);
    expect(tester.getSize(fog).height, 48);
    final scroll = find.byType(SingleChildScrollView);
    final footer = tester.getRect(find.byKey(const ValueKey('footer')));
    await tester.drag(scroll, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const ValueKey('footer'))), footer);
    expect(find.byType(SeedDivider), findsOneWidget);
    update(() => tall = false);
    await tester.pumpAndSettle();
    expect(fog, findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('footer'))).dy -
          tester.getBottomLeft(find.byKey(const ValueKey('body'))).dy,
      16,
    );
    expect(tester.takeException(), isNull);
  });
}
