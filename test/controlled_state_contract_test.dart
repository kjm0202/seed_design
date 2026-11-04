import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
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

void main() {

  testWidgets('controlled empty radio group rejects proposals', (tester) async {
    final proposals = <String?>[];
    await tester.pumpWidget(
      host(
        SeedRadioGroup<String>(
          controlled: true,
          defaultValue: 'a',
          onChanged: proposals.add,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedRadio(value: 'a', label: 'Alpha'),
              SeedRadio(value: 'b', label: 'Beta'),
            ],
          ),
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Beta'));
      await tester.pump();
      expect(
        tester
            .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
            .groupValue,
        isNull,
      );
    }
    expect(proposals, ['b', 'b']);
  });

  testWidgets('controlled empty card group accepts only parent updates', (
    tester,
  ) async {
    final proposals = <Object?>[];
    Object? value;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedSelectBoxGroup(
              controlled: true,
              value: value,
              defaultValue: 'a',
              onValueChanged: proposals.add,
              children: const [
                SeedSelectBox(value: 'a', title: 'Alpha'),
                SeedSelectBox(value: 'b', title: 'Beta'),
              ],
            );
          },
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
    }
    expect(proposals, ['b', 'b']);
    update(() => value = 'b');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    expect(proposals, hasLength(2));
    update(() => value = null);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(proposals, ['b', 'b', 'b']);
  });

  testWidgets('tooltip visibility uses the same reason-bearing callback', (
    tester,
  ) async {
    final events = <(bool, SeedOverlayDismissReason)>[];
    await tester.pumpWidget(
      host(
        SeedHelpBubbleTooltip(
          open: false,
          openDelay: Duration.zero,
          closeDelay: Duration.zero,
          title: 'Tooltip',
          onOpenChanged: (open, reason) => events.add((open, reason)),
          child: const Text('Hover me'),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Hover me')));
    await tester.pumpAndSettle();
    expect(events, [(true, SeedOverlayDismissReason.trigger)]);
    expect(find.text('Tooltip'), findsNothing);
    await mouse.removePointer();
    await tester.pumpAndSettle();
    expect(events, hasLength(1));
  });
}
