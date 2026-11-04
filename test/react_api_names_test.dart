import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

const options = [
  SeedSelectGroup<int>(
    items: [
      SeedSelectItem(value: 1, label: 'Apple'),
      SeedSelectItem(value: 2, label: 'Pear'),
    ],
  ),
];

void main() {
  test('official time and attachment defaults come from the React hooks', () {
    const time = SeedTimePicker();
    expect(time.defaultValue, const TimeOfDay(hour: 0, minute: 0));
    expect(time.minuteStep, 5);
    const attachments = SeedAttachmentDisplayField();
    expect(attachments.maxEntries, 1);
    final controller = SeedAttachmentController();
    addTearDown(controller.dispose);
    controller.addEntries(const [
      SeedAttachmentItem(id: 'first'),
      SeedAttachmentItem(id: 'second'),
    ]);
    expect(controller.items.single.id, 'first');
  });

  testWidgets('React Select uses list value/defaultValue even in single mode', (
    tester,
  ) async {
    final changes = <List<int>>[];
    await tester.pumpWidget(
      host(
        SeedSelect<int>(
          groups: options,
          defaultValue: const [1],
          onValueChange: changes.add,
          showClear: true,
        ),
      ),
    );
    expect(
      tester.widget<SeedInputButton>(find.byType(SeedInputButton)).value,
      'Apple',
    );
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pear'));
    await tester.pumpAndSettle();
    expect(changes, [
      [2],
    ]);
    tester.widget<SeedInputButton>(find.byType(SeedInputButton)).onClear!();
    await tester.pump();
    expect(changes, [
      [2],
      [],
    ]);
    expect(() => changes.first.add(3), throwsUnsupportedError);
    expect(find.text('선택해주세요'), findsOneWidget);
  });

  testWidgets(
    'React multiple Select uses defaultValue, preserves order and toggles',
    (tester) async {
      final changes = <List<int>>[];
      await tester.pumpWidget(
        host(
          SeedSelect<int>(
            groups: options,
            multiple: true,
            defaultValue: const [1],
            onValueChange: changes.add,
          ),
        ),
      );
      final trigger = tester.widget<SeedInputButton>(
        find.byType(SeedInputButton),
      );
      // Official React SelectValue uses item text joined by ', ' even when
      // multiple=true. Unlike a tag editor, its trigger never adds Chips.
      expect(trigger.value, 'Apple');
      expect(trigger.valueChild, isNull);
      expect(find.byType(SeedChip), findsNothing);
      trigger.onPressed!();
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(MenuItemButton).last,
          matching: find.text('Pear'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedInputButton>(find.byType(SeedInputButton)).value,
        'Apple, Pear',
      );
      expect(find.byType(SeedChip), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(MenuItemButton).first,
          matching: find.text('Apple'),
        ),
      );
      await tester.pumpAndSettle();
      expect(changes, [
        [1, 2],
        [2],
      ]);
      expect(
        tester.widget<SeedInputButton>(find.byType(SeedInputButton)).value,
        'Pear',
      );
    },
  );

  testWidgets(
    'React empty Select value is controlled without a controlled flag',
    (tester) async {
      final changes = <List<int>>[];
      await tester.pumpWidget(
        host(
          SeedSelect<int>(
            groups: options,
            multiple: true,
            value: const [],
            defaultValue: const [2],
            onValueChange: changes.add,
          ),
        ),
      );
      await tester.tap(find.text('선택해주세요'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Apple'));
        await tester.pumpAndSettle();
      }
      expect(changes, [
        [1],
        [1],
      ]);
      expect(
        tester.widget<SeedInputButton>(find.byType(SeedInputButton)).value,
        '',
      );
    },
  );

  testWidgets(
    'React Switch checked/defaultChecked/onCheckedChange control ownership',
    (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        host(
          SeedSwitch(
            defaultChecked: true,
            onCheckedChange: changes.add,
            label: 'Toggle',
          ),
        ),
      );
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(changes, [false, true]);
      await tester.pumpWidget(
        host(
          SeedSwitch(
            key: const ValueKey('controlled'),
            checked: false,
            onCheckedChange: changes.add,
            label: 'Toggle',
          ),
        ),
      );
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();
      }
      expect(changes, [false, true, true, true]);
    },
  );

  testWidgets(
    'React ReactionButton uses pressed/defaultPressed/onPressedChange',
    (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        host(
          SeedReactionButton(
            defaultPressed: true,
            onPressedChange: changes.add,
          ),
        ),
      );
      await tester.tap(find.byType(SeedReactionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SeedReactionButton));
      await tester.pumpAndSettle();
      expect(changes, [false, true]);
    },
  );

  testWidgets(
    'typed date range constructor keeps official value/defaultValue names',
    (tester) async {
      final changes = <SeedDateRange?>[];
      await tester.pumpWidget(
        host(
          SeedDatePicker.range(
            defaultValue: SeedDateRange(start: DateTime(2026, 4, 10)),
            onValueChange: changes.add,
            showReset: true,
          ),
        ),
      );
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(changes.last!.start, DateTime(2026, 4, 10));
      expect(changes.last!.end, DateTime(2026, 4, 20));
      await tester.tap(find.text('초기화'));
      await tester.pump();
      expect(changes.last, isNull);
    },
  );

  testWidgets(
    'typed multiple calendar uses official defaultValue and onValueChange',
    (tester) async {
      final changes = <List<DateTime>>[];
      await tester.pumpWidget(
        host(
          SeedDatePicker.multiple(
            defaultValue: [DateTime(2026, 4, 20)],
            onValueChange: changes.add,
            showReset: true,
          ),
        ),
      );
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(changes.last, [DateTime(2026, 4, 10), DateTime(2026, 4, 20)]);
      await tester.tap(find.text('초기화'));
      await tester.pump();
      expect(changes.last, isEmpty);
      expect(() => changes.last.add(DateTime.now()), throwsUnsupportedError);
    },
  );

  testWidgets(
    'official Select and Tooltip onOpenChange callbacks retain their shapes',
    (tester) async {
      final opens = <(bool, SeedOverlayDismissReason)>[];
      await tester.pumpWidget(
        host(
          SeedSelect<int>(
            groups: options,
            onOpenChange: (open, reason) => opens.add((open, reason)),
          ),
        ),
      );
      await tester.tap(find.text('선택해주세요'));
      await tester.pumpAndSettle();
      expect(opens, [(true, SeedOverlayDismissReason.trigger)]);
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(opens.last, (false, SeedOverlayDismissReason.action));

      final tooltip = <bool>[];
      await tester.pumpWidget(
        host(
          SeedHelpBubbleTooltip(
            title: 'Tip',
            openDelay: Duration.zero,
            onOpenChange: tooltip.add,
            child: const Text('Hover'),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Hover')));
      await tester.pumpAndSettle();
      expect(tooltip, [true]);
      expect(find.text('Tip'), findsOneWidget);
      await mouse.removePointer();
      await tester.pumpAndSettle();
      expect(tooltip, [true, false]);
    },
  );
}
