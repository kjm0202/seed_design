import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

bool checkboxValue(WidgetTester tester) =>
    tester
        .widgetList<SeedPressable>(find.byType(SeedPressable))
        .where((w) => w.checked != null || w.mixed == true)
        .first
        .checked ==
    true;

void main() {
  testWidgets('checkbox defaults initialize once and callbacks report bool', (
    tester,
  ) async {
    final changes = <bool>[];
    Widget build(bool seed) =>
        host(SeedCheckbox(defaultChecked: seed, onCheckedChange: changes.add));
    await tester.pumpWidget(build(true));
    expect(checkboxValue(tester), isTrue);
    await tester.tap(find.byType(SeedCheckbox));
    await tester.pump();
    expect(checkboxValue(tester), isFalse);
    await tester.pumpWidget(build(true));
    expect(checkboxValue(tester), isFalse);
    expect(changes, [false]);
  });

  testWidgets('checkbox controlled checked and mixed state are independent', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        SeedCheckbox(
          checked: false,
          indeterminate: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byType(SeedCheckbox));
      await tester.pump();
    }
    expect(changes, [true, true]);
    expect(
      tester.widgetList<SeedPressable>(find.byType(SeedPressable)).single.mixed,
      isTrue,
    );
  });

  testWidgets(
    'legacy checkbox null, tristate cycle, and disabled state survive',
    (tester) async {
      // These deprecated inputs deliberately exercise the compatibility contract.
      // ignore: deprecated_member_use
      bool? value;
      final changes = <bool?>[];
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SeedCheckbox(
                // ignore: deprecated_member_use
                value: value,
                tristate: true,
                // ignore: deprecated_member_use
                onChanged: (next) {
                  changes.add(next);
                  setState(() => value = next);
                },
              );
            },
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(SeedCheckbox));
        await tester.pump();
      }
      expect(changes, [false, true, null]);
      update(() => value = null);
      await tester.pumpWidget(
        host(
          const SeedCheckbox(
            // ignore: deprecated_member_use
            value: null,
            // ignore: deprecated_member_use
            onChanged: null,
          ),
        ),
      );
      expect(
        tester
            .widgetList<SeedPressable>(find.byType(SeedPressable))
            .single
            .mixed,
        isTrue,
      );
      expect(
        tester
            .widgetList<SeedPressable>(find.byType(SeedPressable))
            .single
            .enabled,
        isFalse,
      );
    },
  );

  testWidgets('chip toggle owns its default and accepts controlled rejection', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        SeedChip(
          label: 'Toggle',
          defaultChecked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(changes, [false]);
    expect(checkboxValue(tester), isFalse);
    await tester.pumpWidget(
      host(
        SeedChip(
          key: const ValueKey('controlled'),
          label: 'Toggle',
          checked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(checkboxValue(tester), isTrue);
    expect(changes, [false, false]);
  });

  testWidgets(
    'icon-only chip toggles without observer and buttons still click',
    (tester) async {
      await tester.pumpWidget(
        host(
          const SeedChip.iconOnly(
            icon: Icon(Icons.star),
            semanticsLabel: 'Star',
            defaultChecked: false,
          ),
        ),
      );
      await tester.tap(find.byType(SeedChip));
      await tester.pump();
      expect(checkboxValue(tester), isTrue);
      var clicks = 0;
      await tester.pumpWidget(
        host(SeedChip(label: 'Button', onPressed: () => clicks++)),
      );
      await tester.tap(find.text('Button'));
      await tester.pump();
      expect(clicks, 1);
    },
  );

  testWidgets('select box checked API supports local and parent-owned values', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        SeedSelectBox(
          title: 'Box',
          defaultChecked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Box'));
    await tester.pumpAndSettle();
    expect(changes, [false]);
    await tester.pumpWidget(
      host(
        SeedSelectBox(
          key: const ValueKey('controlled'),
          title: 'Box',
          checked: true,
          onCheckedChange: changes.add,
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Box'));
      await tester.pumpAndSettle();
    }
    expect(changes, [false, false, false]);
  });

  testWidgets('radio select box group exposes onValueChange', (tester) async {
    final changes = <Object?>[];
    await tester.pumpWidget(
      host(
        SeedSelectBoxGroup(
          value: 'a',
          onValueChange: changes.add,
          children: const [
            SeedSelectBox(title: 'Alpha', value: 'a'),
            SeedSelectBox(title: 'Beta', value: 'b'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(changes, ['b', 'b']);
  });

  testWidgets('disabled checked controls do not mutate or notify', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SeedCheckbox(
              enabled: false,
              defaultChecked: true,
              onCheckedChange: changes.add,
            ),
            SeedChip(
              label: 'Disabled',
              enabled: false,
              defaultChecked: true,
              onCheckedChange: changes.add,
            ),
            SeedSelectBox(
              title: 'Readonly',
              readOnly: true,
              defaultChecked: true,
              onCheckedChange: changes.add,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(SeedCheckbox));
    await tester.tap(find.text('Disabled'));
    await tester.tap(find.text('Readonly'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });
}
