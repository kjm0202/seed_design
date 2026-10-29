import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'MIX-06 Menu item activation closes with React itemClick reason $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 844);
        addTearDown(tester.view.reset);
        final events = <(bool, String)>[];
        var activations = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                .toThemeData(),
            home: Scaffold(
              body: SeedMenuTrigger(
                onOpenChange: (open, reason) => events.add((open, reason.name)),
                triggerBuilder: (_, open, toggle) => TextButton(
                  onPressed: toggle,
                  child: const Text('Open menu'),
                ),
                builder: (_) => SeedMenu(
                  groups: [
                    SeedMenuGroupData(
                      items: [
                        const SeedMenuItemData(
                          label: 'Disabled',
                          enabled: false,
                        ),
                        SeedMenuItemData(
                          label: 'Action',
                          onTap: () => activations++,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open menu'));
        await tester.pumpAndSettle();
        expect(events.last, (true, 'trigger'));
        await tester.tap(find.text('Action'));
        await tester.pumpAndSettle();
        expect(activations, 1);
        expect(find.text('Action'), findsNothing);
        expect(events.last, (
          false,
          'itemClick',
        ), reason: 'React useMenu.ts reports item activation as itemClick');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'MIX-06 closeOnSelect false keeps menu open and does not report itemClick',
    (tester) async {
      final events = <(bool, String)>[];
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
              .toThemeData(),
          home: Scaffold(
            body: SeedMenuTrigger(
              onOpenChange: (open, reason) => events.add((open, reason.name)),
              triggerBuilder: (_, open, toggle) =>
                  TextButton(onPressed: toggle, child: const Text('Open menu')),
              builder: (_) => SeedMenu(
                closeOnSelect: false,
                groups: [
                  SeedMenuGroupData(
                    items: [
                      SeedMenuItemData(label: 'Stay', onTap: () => taps++),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(find.text('Stay'), findsOneWidget);
      expect(events, [(true, 'trigger')]);
      expect(tester.takeException(), isNull);
    },
  );
}
