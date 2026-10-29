import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

// Flutter consumer-contract probes for the retained Form/Attachment INC cases.
// These do not certify a native OS IME, real file chooser or React browser run.
Future<void> openForm(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushReplacementNamed('/form');
  await tester.pumpAndSettle();
}

Finder textInputAt(int index) => find.descendant(
  of: find.byType(SeedTextField).at(index),
  matching: find.byType(EditableText),
);

Map<String, dynamic> snackbarPayload(WidgetTester tester) {
  final snackbar = tester.widget<SeedSnackbar>(find.byType(SeedSnackbar));
  return jsonDecode(snackbar.message) as Map<String, dynamic>;
}

Future<void> selectContact(WidgetTester tester, String label) async {
  FocusManager.instance.primaryFocus?.unfocus();
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  final selected = find.descendant(
    of: find.byType(SeedRadioGroup<String>),
    matching: find.text(label),
  );
  final scroll = find
      .ancestor(of: selected, matching: find.byType(SingleChildScrollView))
      .first;
  // The whole form is mounted offscreen in a SingleChildScrollView; the generic
  // dragUntilVisible stops at `findsOneWidget` even when its hit target is below
  // the viewport. Scroll the real surface until the radio is in the hit region.
  for (var i = 0; i < 8 && tester.getCenter(selected).dy > 690; i++) {
    await tester.drag(scroll, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  expect(tester.getCenter(selected).dy, lessThan(690));
  await tester.pumpAndSettle();
  await tester.tap(selected);
  await tester.pumpAndSettle();
}

Future<void> submitForm(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(SeedButton, '제출'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  for (final size in [const Size(390, 844), const Size(800, 800)]) {
    testWidgets(
      'form phone then sms: both JSON payloads and fresh entry $size',
      (tester) async {
        await openForm(tester, size);
        final group = tester.widget<SeedRadioGroup<String>>(
          find.byType(SeedRadioGroup<String>),
        );
        expect(group.value, 'email');
        expect(
          tester
              .widget<SeedSelectBoxGroup>(find.byType(SeedSelectBoxGroup))
              .value,
          'standard',
        );

        await tester.enterText(textInputAt(0), 'First Ext');
        await tester.enterText(textInputAt(1), 'first.ext@example.test');
        await selectContact(tester, '전화');
        await submitForm(tester);
        final first = snackbarPayload(tester);
        expect(first['contact'], ['phone']);
        expect(first['name'], ['First Ext']);
        expect(first['email'], ['first.ext@example.test']);

        // Let the first snackbar expire before editing/submitting the second.
        await tester.pump(const Duration(seconds: 6));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.enterText(textInputAt(0), 'Second Ext');
        await tester.enterText(textInputAt(1), 'second.ext@example.test');
        await selectContact(tester, '문자');
        await submitForm(tester);
        final second = snackbarPayload(tester);
        expect(second['contact'], ['sms']);
        expect(second['name'], ['Second Ext']);
        expect(second['email'], ['second.ext@example.test']);

        final nav = tester.state<NavigatorState>(find.byType(Navigator));
        nav.pushReplacementNamed('/');
        await tester.pumpAndSettle();
        nav.pushNamed('/form');
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedRadioGroup<String>>(
                find.byType(SeedRadioGroup<String>),
              )
              .value,
          'email',
        );
        expect(
          tester
              .widget<SeedSelectBoxGroup>(find.byType(SeedSelectBoxGroup))
              .value,
          'standard',
        );
        expect(
          tester.widget<EditableText>(textInputAt(0)).controller.text,
          isEmpty,
        );
        expect(
          tester.widget<EditableText>(textInputAt(1)).controller.text,
          isEmpty,
        );
      },
    );

    testWidgets('form invalid draft blur then corrected email in JSON $size', (
      tester,
    ) async {
      await openForm(tester, size);
      await tester.enterText(textInputAt(0), '테스트 사용자');
      await tester.enterText(textInputAt(1), 'not-an-email');
      tester.testTextInput.hide();
      await tester.pump();
      expect(
        tester.widget<EditableText>(textInputAt(1)).controller.text,
        'not-an-email',
      );
      await tester.enterText(textInputAt(1), 'qa@example.test');
      expect(
        tester.widget<EditableText>(textInputAt(1)).controller.text,
        'qa@example.test',
      );
      await submitForm(tester);
      final payload = snackbarPayload(tester);
      expect(payload['name'], ['테스트 사용자']);
      expect(payload['email'], ['qa@example.test']);
    });
  }

  testWidgets('attachment failed entry retry resets only its upload state', (
    tester,
  ) async {
    final controller = SeedAttachmentController(
      maxCount: 5,
      items: [
        const SeedAttachmentItem(
          id: 'first',
          name: 'image_1.png',
          type: SeedAttachmentType.image,
          status: SeedAttachmentStatus.error,
        ),
        const SeedAttachmentItem(
          id: 'second',
          name: 'image_2.png',
          type: SeedAttachmentType.image,
          status: SeedAttachmentStatus.success,
        ),
        const SeedAttachmentItem(
          id: 'third',
          name: 'image_3.png',
          type: SeedAttachmentType.image,
          status: SeedAttachmentStatus.success,
        ),
      ],
    );
    addTearDown(controller.dispose);
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeedAttachmentField(
            controller: controller,
            maxCount: 5,
            label: 'AttachmentInput (image/*)',
            onRetry: (item, target) {
              retries++;
              target.updateStatus(
                item.id,
                SeedAttachmentStatus.uploading,
                progress: 0,
              );
            },
          ),
        ),
      ),
    );
    expect(find.text('재시도'), findsOneWidget);
    await tester.tap(find.text('재시도'));
    await tester.pump();
    expect(retries, 1);
    expect(find.text('재시도'), findsNothing);
    expect(controller.items.map((item) => item.id), [
      'first',
      'second',
      'third',
    ]);
    expect(controller.items.first.status, SeedAttachmentStatus.uploading);
    expect(
      controller.items
          .skip(1)
          .every((item) => item.status == SeedAttachmentStatus.success),
      isTrue,
    );
  });
}
