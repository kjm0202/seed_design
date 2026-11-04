import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget _appBehavior(Widget child, {bool scaffold = true}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: scaffold ? Scaffold(body: Center(child: child)) : Center(child: child),
);

Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: theme ?? SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostFghFollowupRegression(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

Widget hostInteractionParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

Widget hostInteraction(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostComponentAccessibilityOv(
  Widget child, {
  double scale = 1,
  bool dark = false,
}) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme:
      (dark
              ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
              : SeedThemeData.light(fontFamily: seedTestFontFamily))
          .toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

Widget hostStateParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  group('field API', () {
    setUpAll(loadSeedTestFonts);
    testWidgets('invalid, description and placeholder drive the input', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SeedField(
            description: 'help',
            invalid: true,
            errorMessage: 'wrong',
            indicatorText: 'optional',
            child: SeedTextInput(placeholder: 'hint', invalid: true),
          ),
        ),
      );
      expect(find.text('hint'), findsOneWidget);
      expect(find.text('wrong'), findsOneWidget);
      expect(
        tester.widget<SeedField>(find.byType(SeedField)).isInvalid,
        isTrue,
      );
    });

    test('compatibility names report through the official getters', () {
      expect(const SeedInputButton(invalid: true).invalid, isTrue);
      expect(const SeedQuantityPicker(invalid: true).invalid, isTrue);
      expect(const SeedTextInput(placeholder: 'a').hintText, 'a');
    });

    testWidgets('AttachmentDisplayField shows its indicator text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SeedAttachmentDisplayField(label: 'Files', indicator: '(선택)'),
        ),
      );
      expect(find.text('(선택)'), findsOneWidget);
    });

    testWidgets('Space toggles a checkbox and Enter does not', (tester) async {
      var value = false;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => SeedCheckbox(
              label: 'Terms',
              value: value,
              onChanged: (next) => setState(() => value = next ?? false),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets(
      'FieldButton has no default chevron and can show plain values',
      (tester) async {
        await tester.pumpWidget(
          _app(const SeedFieldButton(values: ['Value'], showValueChips: false)),
        );
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
        expect(find.byType(SeedChip), findsNothing);
        expect(find.text('Value'), findsOneWidget);
      },
    );
    TextStyle labelStyle(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style!;

    testWidgets('labelWeight reaches every field composition', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SeedTextField(
                  label: 'Text',
                  labelWeight: SeedFieldLabelWeight.bold,
                ),
                SeedFieldButton(
                  label: 'Button',
                  labelWeight: SeedFieldLabelWeight.bold,
                  onPressed: () {},
                ),
                const SeedSelect<int>(
                  label: 'Select',
                  labelWeight: SeedFieldLabelWeight.bold,
                  groups: [],
                ),
                SeedRadioGroup<int>(
                  label: 'Radio',
                  labelWeight: SeedFieldLabelWeight.bold,
                  child: const SizedBox.shrink(),
                ),
                SeedRadioGroup<int>(
                  label: 'Plain',
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );
      for (final label in ['Text', 'Button', 'Select', 'Radio']) {
        expect(labelStyle(tester, label).fontWeight, FontWeight.w700);
      }
      expect(labelStyle(tester, 'Plain').fontWeight, FontWeight.w500);
      expect(labelStyle(tester, 'Plain').fontSize, SeedFontSize.t5);
    });
  });

  group('input behavior', () {
    setUpAll(loadSeedTestFonts);
    testWidgets('TextInput has no clear button by default', (tester) async {
      await tester.pumpWidget(
        _appBehavior(
          const SizedBox(width: 300, child: SeedTextInput(defaultValue: 'abc')),
        ),
      );
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('QuantityPicker starts at min and keeps its width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appBehavior(const SeedQuantityPicker(min: 0, max: 100)),
      );
      expect(find.text('0'), findsOneWidget);
      final uncontrolled = tester.getSize(find.byType(Row).first).width;
      await tester.pumpWidget(
        _appBehavior(const SeedQuantityPicker(min: 0, max: 100, value: 100)),
      );
      expect(tester.getSize(find.byType(Row).first).width, uncontrolled);
    });

    for (final (input, step, output) in [
      (const TimeOfDay(hour: 10, minute: 5), 10, const ['오전', '10', '10']),
      (const TimeOfDay(hour: 10, minute: 45), 30, const ['오전', '11', '00']),
      (const TimeOfDay(hour: 23, minute: 45), 30, const ['오전', '12', '00']),
    ]) {
      testWidgets(
        'TimePicker rounds ${input.hour}:${input.minute} ties up at step $step',
        (tester) async {
          await tester.pumpWidget(
            _appBehavior(
              SizedBox(
                width: 320,
                child: SeedTimePicker(defaultValue: input, minuteStep: step),
              ),
            ),
          );
          await tester.pump();
          final neutral = tester
              .element(find.byType(SeedTimePicker))
              .seedColor
              .fg
              .neutral;
          final selected = tester
              .widgetList<Text>(find.byType(Text))
              .where((text) => text.style?.color == neutral)
              .map((text) => text.data)
              .toSet();
          expect(selected, output.toSet());
        },
      );
    }

    testWidgets('DatePicker does not report reselecting the same date', (
      tester,
    ) async {
      var changes = 0;
      await tester.pumpWidget(
        _appBehavior(
          SizedBox(
            width: 360,
            height: 600,
            child: SingleChildScrollView(
              child: SeedDatePicker(
                defaultValue: DateTime(2026, 11, 10),
                today: DateTime(2026, 11, 2),
                onValueChange: (_) => changes++,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(changes, 0);
      await tester.tap(find.text('11'));
      await tester.pump();
      expect(changes, 1);
    });

    testWidgets('error messages show the official icon', (tester) async {
      await tester.pumpWidget(
        _appBehavior(
          const SizedBox(width: 300, child: SeedTextField(errorMessage: 'E')),
        ),
      );
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    test('AttachmentController status updates replace progress', () {
      final controller = SeedAttachmentController(
        items: const [
          SeedAttachmentItem(
            id: '1',
            name: 'x',
            status: SeedAttachmentStatus.uploading,
            progress: .5,
          ),
        ],
        maxCount: 3,
      );
      addTearDown(controller.dispose);
      controller.updateStatus('1', SeedAttachmentStatus.error);
      expect(controller.items.single.progress, isNull);
      controller.updateStatus(
        '1',
        SeedAttachmentStatus.uploading,
        progress: .2,
      );
      expect(controller.items.single.progress, .2);
    });
  });
  group('controller ownership', () {
    testWidgets('replaces external controllers and detaches old listeners', (
      tester,
    ) async {
      final first = TextEditingController(text: 'first');
      final second = TextEditingController(text: 'second');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await tester.pumpWidget(host(SeedTextInput(controller: first)));
      await tester.pumpWidget(host(SeedTextInput(controller: second)));
      expect(find.text('second'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller,
        same(second),
      );
      first.text = 'detached';
      await tester.pump();
      expect(find.text('detached'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      second.text = 'still owned by caller';
    });

    testWidgets(
      'external to internal preserves editing value without disposing caller',
      (tester) async {
        final controller = TextEditingController(text: 'keep me');
        addTearDown(controller.dispose);
        controller.selection = const TextSelection.collapsed(offset: 3);
        await tester.pumpWidget(host(SeedTextInput(controller: controller)));
        await tester.pumpWidget(host(const SeedTextInput()));
        final current = tester
            .widget<TextField>(find.byType(TextField))
            .controller!;
        expect(current, isNot(same(controller)));
        expect(current.value, controller.value);
        await tester.pumpWidget(const SizedBox());
        controller.text = 'caller can still use it';
      },
    );

    testWidgets('internal to external and focus node replacement', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'replacement');
      final first = FocusNode();
      final second = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await tester.pumpWidget(
        host(SeedTextInput(initialValue: 'initial', focusNode: first)),
      );
      await tester.pumpWidget(
        host(SeedTextInput(controller: controller, focusNode: second)),
      );
      expect(find.text('replacement'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode,
        same(second),
      );
      second.requestFocus();
      await tester.pump();
      expect(second.hasFocus, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('controlled text in Form', () {
    testWidgets('controlled text field accepts external update inside Form', (
      tester,
    ) async {
      var value = 'first';
      final formKey = GlobalKey<FormState>();
      String? saved;
      late StateSetter update;
      await tester.pumpWidget(
        hostFghFollowupRegression(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Form(
                key: formKey,
                child: SeedTextField(
                  value: value,
                  validator: (text) => text == value ? null : 'stale value',
                  onSaved: (text) => saved = text,
                ),
              );
            },
          ),
        ),
      );
      update(() => value = 'second');
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('second'), findsOneWidget);
      expect(formKey.currentState!.validate(), isTrue);
      formKey.currentState!.save();
      expect(saved, 'second');
      await tester.enterText(find.byType(TextField), 'unaccepted edit');
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group('grapheme counting', () {
    testWidgets(
      'text field counts graphemes and exposes sliced input without truncating',
      (tester) async {
        SeedTextValueChange? change;
        await tester.pumpWidget(
          hostInteractionParity(
            SeedTextField(
              maxGraphemeCount: 2,
              onValueChanged: (value) => change = value,
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), '🇰🇷👨‍👩‍👧‍👦가');
        await tester.pump();
        expect(change!.graphemes, hasLength(3));
        expect(change!.slicedValue, '🇰🇷👨‍👩‍👧‍👦');
        expect(find.text('🇰🇷👨‍👩‍👧‍👦가'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('InputButton clear', () {
    testWidgets('nested clear action does not open input button', (
      tester,
    ) async {
      var opened = 0;
      var cleared = 0;
      await tester.pumpWidget(
        hostInteraction(
          SizedBox(
            width: 280,
            child: SeedInputButton(
              value: '선택됨',
              showClear: true,
              onClear: () => cleared++,
              onPressed: () => opened++,
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('선택 내용 지우기'));
      expect(cleared, 1);
      expect(opened, 0);
    });
  });

  group('label focus', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'composed field labels focus implicit and explicit input nodes',
      (tester) async {
        final external = FocusNode();
        for (final explicit in [false, true]) {
          await tester.pumpWidget(
            hostComponentAccessibilityOv(
              SeedField(
                label: 'Name',
                child: SeedTextInput(focusNode: explicit ? external : null),
              ),
            ),
          );
          await tester.tap(find.text('Name'));
          await tester.pump();
          expect(
            tester
                .widget<TextField>(find.byType(TextField))
                .focusNode!
                .hasFocus,
            isTrue,
          );
          if (explicit) expect(external.hasFocus, isTrue);
        }
        await tester.pumpWidget(
          hostComponentAccessibilityOv(
            const SeedField(
              label: 'Disabled',
              disabled: true,
              child: SeedTextInput(),
            ),
          ),
        );
        await tester.tap(find.text('Disabled'));
        await tester.pump();
        expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isFalse,
        );
        await tester.pumpWidget(const SizedBox());
        external.dispose();
      },
    );
  });

  group('form reset', () {
    testWidgets('form reset restores text and grapheme counter', (
      tester,
    ) async {
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        hostStateParity(
          Form(
            key: form,
            child: const SeedTextField(
              defaultValue: 'Original',
              maxGraphemeCount: 20,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Changed');
      form.currentState!.reset();
      await tester.pump();
      expect(find.text('Original'), findsOneWidget);
    });
  });
}
