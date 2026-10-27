import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 480, child: child),
    ),
  ),
);

void main() {
  testWidgets('extended FABs use content width and can share a wrap row', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Wrap(
          spacing: 12,
          children: [
            SeedFloatingActionButton.extended(
              key: const ValueKey('write'),
              icon: const Icon(Icons.edit),
              label: 'Write',
              onPressed: () {},
            ),
            SeedFloatingActionButton.extended(
              key: const ValueKey('nearby'),
              icon: const Icon(Icons.near_me),
              label: 'Nearby',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final first = find.byKey(const ValueKey('write'));
    final second = find.byKey(const ValueKey('nearby'));
    final labelWidth = tester.getSize(find.text('Write')).width;
    // Icon, gap and horizontal padding surround the label, with no expansion.
    expect(tester.getSize(first).width, closeTo(labelWidth + 16 + 4 + 36, .01));
    expect(tester.getTopLeft(first).dy, tester.getTopLeft(second).dy);
    expect(
      tester.getTopLeft(second).dx,
      greaterThan(tester.getTopRight(first).dx),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'collapsing a FAB preserves the icon size and restores content width',
    (tester) async {
      var extended = true;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return SeedFloatingActionButton.extended(
                    icon: const Icon(Icons.add),
                    label: 'Create',
                    extended: extended,
                    onPressed: () {},
                  );
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final fab = find.byType(SeedFloatingActionButton);
      final original = tester.getSize(fab);
      expect(original.width, lessThan(240));
      update(() => extended = false);
      await tester.pumpAndSettle();
      expect(tester.getSize(fab), const Size(56, 56));
      update(() => extended = true);
      await tester.pumpAndSettle();
      expect(tester.getSize(fab), original);
      expect(tester.takeException(), isNull);
    },
  );
}
