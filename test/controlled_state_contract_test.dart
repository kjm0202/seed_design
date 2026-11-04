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

  testWidgets(
    'controlled FormField preserves null, accepted updates and reset',
    (tester) async {
      final field = GlobalKey<FormFieldState<String>>();
      final form = GlobalKey<FormState>();
      final proposals = <String?>[];
      String? value;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Form(
                key: form,
                child: SeedFormField<String>(
                  key: field,
                  controlled: true,
                  value: value,
                  initialValue: 'ignored seed',
                  onValueChanged: proposals.add,
                  builder: (state) => Text(state.value ?? 'empty'),
                ),
              );
            },
          ),
        ),
      );
      expect(field.currentState!.value, isNull);
      field.currentState!.didChange('proposal');
      await tester.pump();
      expect(proposals, ['proposal']);
      expect(field.currentState!.value, isNull);
      update(() => value = 'accepted');
      await tester.pump();
      expect(field.currentState!.value, 'accepted');
      field.currentState!.didChange('rejected');
      form.currentState!.reset();
      await tester.pump();
      expect(field.currentState!.value, 'accepted');
      update(() => value = null);
      await tester.pump();
      expect(field.currentState!.value, isNull);
      expect(proposals, ['proposal', 'rejected']);
    },
  );

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

  testWidgets(
    'external text controller updates validation and reset without edit callbacks',
    (tester) async {
      final controller = TextEditingController(text: 'initial');
      addTearDown(controller.dispose);
      final form = GlobalKey<FormState>();
      final edits = <String>[];
      String? saved;
      await tester.pumpWidget(
        host(
          Form(
            key: form,
            child: SeedTextField(
              controller: controller,
              validator: (value) => value == controller.text ? null : 'stale',
              onChanged: edits.add,
              onSaved: (value) => saved = value,
            ),
          ),
        ),
      );
      controller.text = 'external';
      await tester.pump();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, 'external');
      expect(edits, isEmpty);
      form.currentState!.reset();
      await tester.pump();
      expect(controller.text, 'initial');
      expect(form.currentState!.validate(), isTrue);
      await tester.pumpWidget(host(const SizedBox()));
      // The widget does not dispose a caller-owned controller.
      controller.text = 'still usable';
    },
  );

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
