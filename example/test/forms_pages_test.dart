import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> _open(
  WidgetTester tester,
  String route, {
  double width = 390,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pump();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

Future<void> openFormsRoute(
  WidgetTester tester, {
  required String route,
  required double width,
  double textScale = 1,
}) async {
  final size = Size(width, width == 390 ? 844 : 800);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    textScale == 1
        ? const StackflowSpaApp()
        : MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
            ),
            child: const StackflowSpaApp(),
          ),
  );
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushReplacementNamed(route);
  await tester.pumpAndSettle();
}

Future<void> openForm(WidgetTester tester, {required double width}) async {
  tester.view.physicalSize = Size(width, width == 800 ? 900 : 844);
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

// Flutter consumer-contract probes for the retained Form/Attachment INC cases.
// These do not certify a native OS IME, real file chooser or React browser run.
Future<void> openFormFormAttachmentContract(
  WidgetTester tester,
  Size size,
) async {
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

Future<void> _openRoute(
  WidgetTester tester, {
  required String route,
  required double width,
  required double scale,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, 900),
        textScaler: TextScaler.linear(scale),
      ),
      child: const StackflowSpaApp(),
    ),
  );
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushReplacementNamed(route);
  await tester.pumpAndSettle();
}

ScrollPosition _position(WidgetTester tester, Finder list) {
  final scrollable = find
      .descendant(of: list, matching: find.byType(Scrollable))
      .first;
  return tester.state<ScrollableState>(scrollable).position;
}

Future<void> _dragEdge(
  WidgetTester tester, {
  required String id,
  required double edgeX,
}) async {
  final center = tester.getCenter(find.byKey(ValueKey(id)));
  final gesture = await tester.startGesture(center);
  await tester.pump(const Duration(milliseconds: 650));
  await gesture.moveTo(Offset(edgeX, center.dy));
  await tester.pump(const Duration(milliseconds: 160));
  for (var frame = 0; frame < 75; ++frame) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<NavigatorState> _openScreenRoutes(
  WidgetTester tester,
  String path,
  double width,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final nav = tester.state<NavigatorState>(find.byType(Navigator));
  nav.pushNamed(path);
  await tester.pumpAndSettle();
  return nav;
}

Future<NavigatorState> open(WidgetTester tester, String route) async {
  tester.view.physicalSize = const Size(440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pumpAndSettle();
  return navigator;
}

Future<void> openStackflowSpaVisualFix(
  WidgetTester tester,
  String route, {
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

Future<void> _openDirect(WidgetTester tester, String path) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.binding.platformDispatcher.defaultRouteNameTestValue = path;
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
}

FocusNode _keyboardReorderNode(WidgetTester tester, Finder item) => tester
    .widget<Focus>(
      find
          .ancestor(
            of: item,
            matching: find.byWidgetPredicate(
              (widget) => widget is Focus && widget.onKeyEvent != null,
            ),
          )
          .first,
    )
    .focusNode!;

// Moves focus with real Tab key presses until [target] has primary focus.
Future<void> _tabUntilFocused(
  WidgetTester tester,
  FocusNode target, {
  int maxTabs = 300,
}) async {
  for (var i = 0; i < maxTabs && !target.hasPrimaryFocus; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
  }
  expect(target.hasPrimaryFocus, isTrue, reason: 'Tab reaches the item');
}

// The semantics node carrying the item's reorder hint.
SemanticsNode _reorderHint(WidgetTester tester, Finder item) {
  SemanticsNode? node = tester.getSemantics(item);
  while (node != null && node.hint.isEmpty) {
    node = node.parent;
  }
  expect(node, isNotNull, reason: 'item exposes a reorder hint');
  return node!;
}

String _semanticsText(SemanticsNode node) {
  final buffer = StringBuffer(node.label);
  node.visitChildren((child) {
    buffer.write(' ${_semanticsText(child)}');
    return true;
  });
  return buffer.toString();
}

void main() {
  group('Form, Select, Quantity and Attachment display', () {
    for (final width in [390.0, 800.0]) {
      testWidgets('shipping stays in two columns at ${width.toInt()}px', (
        tester,
      ) async {
        await _open(tester, '/form', width: width);
        final group = tester.widget<SeedSelectBoxGroup>(
          find.byType(SeedSelectBoxGroup),
        );
        expect(group.columns, 2);
        final boxes = find.descendant(
          of: find.byType(SeedSelectBoxGroup),
          matching: find.byType(SeedSelectBox),
        );
        expect(boxes, findsNWidgets(4));
        final first = tester.getTopLeft(boxes.at(0));
        final second = tester.getTopLeft(boxes.at(1));
        expect((first.dy - second.dy).abs(), lessThan(1));
        expect(second.dx, greaterThan(first.dx));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'Select paired fields shrink side-by-side within 390px viewport',
      (tester) async {
        await _open(tester, '/select', width: 390);
        final fields = find.byType(SeedSelect<String>);
        final first = tester.getRect(fields.at(0));
        final second = tester.getRect(fields.at(1));
        final third = tester.getRect(fields.at(2));
        final fourth = tester.getRect(fields.at(3));
        expect(first.width, inInclusiveRange(165, 180));
        expect(second.top, closeTo(first.top, 1));
        expect(second.right, lessThanOrEqualTo(375));
        expect(third.width, inInclusiveRange(160, 180));
        expect(fourth.top, closeTo(third.top, 1));
        expect(fourth.right, lessThanOrEqualTo(375));
        final firstMultiple = tester.getRect(fields.at(10));
        final secondMultiple = tester.getRect(fields.at(11));
        expect(firstMultiple.width, inInclusiveRange(160, 180));
        expect(secondMultiple.top, closeTo(firstMultiple.top, 1));
        expect(secondMultiple.right, lessThanOrEqualTo(375));
        expect(tester.takeException(), isNull);
      },
    );

    for (final width in [390.0, 800.0]) {
      testWidgets(
        'Select prefix examples retain official React explanations $width',
        (tester) async {
          await _open(tester, '/select', width: width);
          expect(
            find.text(
              '미선택: star · 사과/바나나: 각 item 아이콘이 star를 이김 · 체리(무아이콘): static star로 fallback',
            ),
            findsOneWidget,
          );
          expect(
            find.text('1개 선택: 그 item 아이콘 미러 · 2개 이상: static star로 복귀'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('Quantity Form owns FormField state', (tester) async {
      await _open(tester, '/quantity-picker');
      expect(find.byType(Form), findsWidgets);
      expect(find.byType(FormField<int>), findsOneWidget);
      final quantity = tester.state<FormFieldState<int>>(
        find.byType(FormField<int>),
      );
      quantity.didChange(5);
      await tester.pump();
      final submit = find.widgetWithText(SeedButton, '제출');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      expect(find.text('제출한 수량: 5개'), findsOneWidget);
    });

    testWidgets('Select sheet keeps the handle and puts Select in footer', (
      tester,
    ) async {
      await _open(tester, '/select');
      final button = find.widgetWithText(SeedButton, 'BottomSheet 열기');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 400));
      final sheet = tester.widget<SeedBottomSheet>(
        find.byType(SeedBottomSheet),
      );
      expect(sheet.showHandle, true);
      expect(sheet.title, 'Select in BottomSheet');
      expect(sheet.footer, isNotNull);
      expect(
        find.descendant(
          of: find.byType(SeedBottomSheet),
          matching: find.byType(SeedSelect<String>),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'Attachment display integration opts into invalid and required APIs',
      (tester) async {
        await _open(tester, '/attachment-display-field');
        final display = tester
            .widgetList<SeedAttachmentDisplayField>(
              find.byType(SeedAttachmentDisplayField),
            )
            .toList();
        final integration = display.singleWhere(
          (field) => field.label == 'Field Integration',
        );
        expect(integration.invalid, isTrue);
        expect(integration.showRequiredIndicator, isTrue);
        expect(integration.errorMessage, '사진을 1장 이상 등록해 주세요.');
        final field = tester
            .widgetList<SeedField>(find.byType(SeedField))
            .singleWhere((candidate) => candidate.label == 'Field Integration');
        expect(field.required, isTrue);
        expect(field.invalid, isTrue);
      },
    );
    group('short viewports and reorderable display', () {
      testWidgets('Display reorderable keeps add / reorder / remove at 390px', (
        tester,
      ) async {
        await openFormsRoute(
          tester,
          route: '/attachment-display-field',
          width: 390,
        );
        SeedAttachmentInput reorderable() => tester.widget<SeedAttachmentInput>(
          find.byType(SeedAttachmentInput).at(1),
        );
        expect(reorderable().onReorder, isNotNull);
        for (var i = 0; i < 5; i++) {
          reorderable().onAdd!();
        }
        await tester.pump();
        expect(reorderable().items.length, 5);
        final originalFirstId = reorderable().items.first.id;
        reorderable().onReorder!(0, 5);
        await tester.pump();
        expect(reorderable().items.last.id, originalFirstId);
        reorderable().onRemove!(reorderable().items.last);
        await tester.pump();
        expect(reorderable().items.length, 4);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Checkbox controls remain scrollable on a short viewport', (
        tester,
      ) async {
        await openFormsRoute(tester, route: '/checkbox', width: 390);
        tester.view.physicalSize = const Size(390, 260);
        await tester.pumpAndSettle();
        final panelScroll = find
            .ancestor(
              of: find.byType(DropdownButton<String>).first,
              matching: find.byType(SingleChildScrollView),
            )
            .first;
        expect(tester.getSize(panelScroll).height, lessThan(312));
        expect(find.text('disabled'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('scroll end and fixed submit', () {
      for (final width in [320.0, 390.0, 800.0]) {
        testWidgets(
          '/form ScrollFog preserves scroll end and fixed submit at $width',
          (tester) async {
            await openForm(tester, width: width);
            final mask = find.byType(SeedScrollFogMask);
            final scrollable = find
                .descendant(of: mask, matching: find.byType(Scrollable))
                .first;
            final position = tester.state<ScrollableState>(scrollable).position;
            expect(position.maxScrollExtent, greaterThan(0));

            final submit = find.widgetWithText(SeedButton, '제출');
            final pinnedY = tester.getRect(submit).top;
            position.jumpTo(position.maxScrollExtent);
            await tester.pumpAndSettle();
            expect(position.pixels, closeTo(position.maxScrollExtent, .01));
            expect(tester.getRect(submit).top, closeTo(pinnedY, .01));
            expect(find.text('마케팅 수신 동의 (선택)'), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    });
  });

  group('Form payloads and attachment fields', () {
    for (final size in [const Size(390, 844), const Size(800, 800)]) {
      testWidgets(
        'form phone then sms: both JSON payloads and fresh entry $size',
        (tester) async {
          await openFormFormAttachmentContract(tester, size);
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

      testWidgets(
        'form invalid draft blur then corrected email in JSON $size',
        (tester) async {
          await openFormFormAttachmentContract(tester, size);
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
        },
      );
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
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retries, 1);
      expect(find.text('Retry'), findsNothing);
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
    group('drag reorder on real routes', () {
      for (final (route, label) in [
        ('/attachment-field', 'AttachmentInputReorderable (all files)'),
        ('/attachment-field', 'AttachmentDropzoneReorderable (all files)'),
        ('/attachment-display-field', 'AttachmentDisplayReorderable'),
      ]) {
        testWidgets('$label keeps order and focus across keyboard cancel/drop', (
          tester,
        ) async {
          await _open(tester, route);
          final fieldFinder = find.byWidgetPredicate(
            (widget) =>
                widget is SeedAttachmentDisplayField && widget.label == label,
          );
          final field = tester.widget<SeedAttachmentDisplayField>(fieldFinder);
          final controller = field.controller!;
          controller.addEntries([
            for (var i = 0; i < 3; i++)
              SeedAttachmentItem(
                id: 'keyboard-$i',
                name: 'keyboard-$i.pdf',
                type: SeedAttachmentType.file,
              ),
          ]);
          await tester.pumpAndSettle();
          final item = find.byKey(const ValueKey('keyboard-0'));
          await tester.ensureVisible(item);
          await tester.pumpAndSettle();
          final node = _keyboardReorderNode(tester, item);
          await _tabUntilFocused(tester, node);
          final filename = find.bySemanticsLabel('keyboard-0.pdf');
          final semantics = tester.ensureSemantics();
          await tester.pump();
          expect(filename, findsOneWidget);
          final start = SeedLocalizations.label(
            tester.element(item),
            SeedLabel.reorderStartHint,
          );
          String moving(int position) => SeedLocalizations.label(
            tester.element(item),
            SeedLabel.reorderMovingHint,
          ).replaceAll('{position}', '$position');
          expect(_reorderHint(tester, item).hint, start);
          expect(
            _semanticsText(_reorderHint(tester, item)),
            contains('keyboard-0.pdf'),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pumpAndSettle();
          expect(_reorderHint(tester, item).hint, moving(1));
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          expect(find.text('2 / 3'), findsOneWidget);
          expect(_reorderHint(tester, item).hint, moving(2));
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(controller.items.first.id, 'keyboard-0');
          expect(find.text('2 / 3'), findsNothing);
          expect(node.hasPrimaryFocus, isTrue);
          expect(_reorderHint(tester, item).hint, start);

          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pumpAndSettle();
          expect(controller.items.map((item) => item.id), [
            'keyboard-1',
            'keyboard-0',
            'keyboard-2',
          ]);
          expect(node.hasPrimaryFocus, isTrue);
          expect(_reorderHint(tester, item).hint, start);
          semantics.dispose();
          expect(tester.takeException(), isNull);
        });

        testWidgets('$label skips disabled and readOnly items for keyboard reorder', (
          tester,
        ) async {
          await _open(tester, route);
          final fieldFinder = find.byWidgetPredicate(
            (widget) =>
                widget is SeedAttachmentDisplayField && widget.label == label,
          );
          final controller = tester
              .widget<SeedAttachmentDisplayField>(fieldFinder)
              .controller!;
          final before = controller.items.map((item) => item.id).toList();
          controller.addEntries([
            const SeedAttachmentItem(
              id: 'b1-movable',
              name: 'b1-movable.pdf',
              type: SeedAttachmentType.file,
              status: SeedAttachmentStatus.error,
            ),
            const SeedAttachmentItem(
              id: 'b1-disabled',
              name: 'b1-disabled.pdf',
              type: SeedAttachmentType.file,
              enabled: false,
            ),
            const SeedAttachmentItem(
              id: 'b1-readonly',
              name: 'b1-readonly.pdf',
              type: SeedAttachmentType.file,
              readOnly: true,
            ),
            const SeedAttachmentItem(
              id: 'b1-tail',
              name: 'b1-tail.pdf',
              type: SeedAttachmentType.file,
            ),
          ]);
          await tester.pumpAndSettle();
          List<String> ids() => controller.items.map((item) => item.id).toList();
          final added = ['b1-movable', 'b1-disabled', 'b1-readonly', 'b1-tail'];
          expect(ids(), [...before, ...added]);
          Finder item(String id) => find.descendant(
            of: fieldFinder,
            matching: find.byKey(ValueKey(id)),
          );
          await tester.ensureVisible(item('b1-movable'));
          await tester.pumpAndSettle();
          final keyboardHandle = find.byWidgetPredicate(
            (widget) => widget is Focus && widget.onKeyEvent != null,
          );
          // Locked items get no keyboard reorder handle and no hint.
          for (final id in ['b1-disabled', 'b1-readonly']) {
            final handle = find.ancestor(of: item(id), matching: keyboardHandle);
            expect(
              handle.evaluate().any(
                (element) => find
                    .descendant(
                      of: find.byElementPredicate((e) => e == element),
                      matching: item('b1-movable'),
                    )
                    .evaluate()
                    .isEmpty,
              ),
              isFalse,
              reason: '$id has its own keyboard handle',
            );
          }

          final movable = _keyboardReorderNode(tester, item('b1-movable'));
          // The lazy list builds the tail only once it scrolls into view.
          bool tailFocused() =>
              item('b1-tail').evaluate().isNotEmpty &&
              _keyboardReorderNode(tester, item('b1-tail')).hasPrimaryFocus;
          await _tabUntilFocused(tester, movable);
          // Real Tab presses from the movable item reach the tail without
          // stopping inside the locked items.
          for (var i = 0; i < 10 && !tailFocused(); i++) {
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            final focused = FocusManager.instance.primaryFocus!.context!;
            for (final id in ['b1-disabled', 'b1-readonly']) {
              var inside = false;
              focused.visitAncestorElements((element) {
                if (element.widget.key == ValueKey(id)) inside = true;
                return !inside;
              });
              expect(inside, isFalse, reason: 'Tab skips $id');
            }
          }
          expect(tailFocused(), isTrue);
          expect(ids(), [...before, ...added]);

          // The movable neighbour still reorders past the locked items.
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pumpAndSettle();
          expect(ids(), [
            ...before,
            'b1-movable',
            'b1-disabled',
            'b1-tail',
            'b1-readonly',
          ]);

          // Retry and removal still work on the movable item.
          await tester.scrollUntilVisible(
            item('b1-movable'),
            -100,
            scrollable: find
                .descendant(of: fieldFinder, matching: find.byType(Scrollable))
                .first,
          );
          await tester.pumpAndSettle();
          final retry = find.descendant(
            of: item('b1-movable'),
            matching: find.bySemanticsLabel(
              SeedLocalizations.label(
                tester.element(item('b1-movable')),
                SeedLabel.retryUpload,
              ),
            ),
          );
          final semantics = tester.ensureSemantics();
          await tester.pump();
          await tester.tap(retry);
          await tester.pump();
          expect(
            controller.items
                .firstWhere((entry) => entry.id == 'b1-movable')
                .status,
            SeedAttachmentStatus.uploading,
          );
          // Let the simulated upload finish.
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle();
          final remove = find.descendant(
            of: item('b1-movable'),
            matching: find.bySemanticsLabel(
              SeedLocalizations.label(
                tester.element(item('b1-movable')),
                SeedLabel.deleteFile,
              ),
            ),
          );
          await tester.tap(remove.first);
          await tester.pumpAndSettle();
          expect(ids(), [...before, 'b1-disabled', 'b1-tail', 'b1-readonly']);
          // Locked items keep no remove action.
          for (final id in ['b1-disabled', 'b1-readonly']) {
            expect(
              find.descendant(
                of: item(id),
                matching: find.bySemanticsLabel(
                  SeedLocalizations.label(
                    tester.element(item(id)),
                    SeedLabel.deleteFile,
                  ),
                ),
              ),
              findsNothing,
            );
          }
          semantics.dispose();
          expect(tester.takeException(), isNull);
        });
      }

      for (final width in [320.0, 390.0, 800.0]) {
        testWidgets(
          'real /attachment-field file list drag pans, reorders, keeps bleed at $width',
          (tester) async {
            await _openRoute(
              tester,
              route: '/attachment-field',
              width: width,
              scale: width == 320 ? 2 : 1,
            );
            final fieldFinder = find.byType(SeedAttachmentField).at(5);
            final field = tester.widget<SeedAttachmentField>(fieldFinder);
            final controller = field.controller!;
            controller.addEntries([
              for (var index = 0; index < 5; index++)
                SeedAttachmentItem(
                  id: 'round6-route-file-$index',
                  type: SeedAttachmentType.file,
                  name:
                      'Long filename that must preserve the document extension $index.pdf',
                  sizeText: '9.8 MB',
                ),
            ]);
            await tester.pumpAndSettle();
            await tester.ensureVisible(fieldFinder);
            await tester.pumpAndSettle();

            final input = find
                .ancestor(
                  of: find.byKey(const ValueKey('round6-route-file-0')),
                  matching: find.byType(SeedAttachmentInput),
                )
                .first;
            final list = find.descendant(
              of: input,
              matching: find.byType(CustomScrollView),
            );
            final rect = tester.getRect(list);
            expect(rect.left, closeTo(0, .01));
            expect(rect.right, closeTo(width, .01));

            final scroll = _position(tester, list);
            expect(scroll.maxScrollExtent, greaterThan(0));
            await _dragEdge(
              tester,
              id: 'round6-route-file-0',
              edgeX: width - 8,
            );
            expect(scroll.pixels, greaterThan(0));
            expect(controller.items.first.id, isNot('round6-route-file-0'));
            expect(controller.items.map((item) => item.id).toSet().length, 5);
            expect(tester.takeException(), isNull);
          },
        );
      }

      for (final width in [320.0, 390.0]) {
        testWidgets(
          'real /attachment-display-field image list pointer drag reorders at $width',
          (tester) async {
            await _openRoute(
              tester,
              route: '/attachment-display-field',
              width: width,
              scale: 1,
            );
            final fieldFinder = find.byType(SeedAttachmentDisplayField).at(1);
            final field = tester.widget<SeedAttachmentDisplayField>(
              fieldFinder,
            );
            final controller = field.controller!;
            controller.addEntries([
              for (var index = 0; index < 5; index++)
                SeedAttachmentItem(
                  id: 'round6-route-display-$index',
                  type: SeedAttachmentType.image,
                ),
            ]);
            await tester.pumpAndSettle();
            await tester.ensureVisible(fieldFinder);
            await tester.pumpAndSettle();

            final list = find.descendant(
              of: find
                  .ancestor(
                    of: find.byKey(const ValueKey('round6-route-display-0')),
                    matching: find.byType(SeedAttachmentInput),
                  )
                  .first,
              matching: find.byType(CustomScrollView),
            );
            final scroll = _position(tester, list);
            expect(scroll.maxScrollExtent, greaterThan(0));
            expect(tester.getRect(list).right, closeTo(width, .01));
            await _dragEdge(
              tester,
              id: 'round6-route-display-0',
              edgeX: width - 8,
            );
            expect(scroll.pixels, greaterThan(0));
            expect(controller.items.first.id, isNot('round6-route-display-0'));
            expect(controller.items.map((item) => item.id).toSet().length, 5);
            expect(tester.takeException(), isNull);
          },
        );
      }
    });
  });

  group('E2E textarea autoresize', () {
    for (final width in [390.0, 800.0]) {
      testWidgets(
        'E2E textarea autoresize scroll renders official React 40 lines $width',
        (tester) async {
          await _openScreenRoutes(
            tester,
            '/e2e/textarea-autoresize-scroll',
            width,
          );
          expect(find.text('E2E Textarea Autoresize Scroll'), findsOneWidget);
          expect(find.text('구현되지 않은 예제입니다.'), findsNothing);
          final field = tester.widget<SeedTextField>(
            find.byType(SeedTextField),
          );
          expect(field.autoResize, isTrue);
          expect(field.maxLines, isNull);
          expect(field.label, '본문');
          final input = tester.widget<EditableText>(find.byType(EditableText));
          expect(input.controller.text.split('\n'), hasLength(40));
          expect(input.controller.text, startsWith('1번째 줄'));
          expect(input.controller.text, endsWith('40번째 줄'));
          await tester.scrollUntilVisible(
            find.text('게시'),
            300,
            scrollable: find
                .descendant(
                  of: find.byType(ListView),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          expect(find.widgetWithText(SeedButton, '게시'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('WheelPicker and Checkbox', () {
    for (final width in [390.0, 800.0]) {
      for (final dismiss in ['done', 'close', 'escape', 'scrim']) {
        testWidgets(
          'WheelPicker deep-link root retains date after $dismiss at $width',
          (tester) async {
            tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(const StackflowSpaApp());
            await tester.pumpAndSettle();
            final done = Completer<void>();
            tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              SystemChannels.navigation.name,
              SystemChannels.navigation.codec.encodeMethodCall(
                const MethodCall('pushRouteInformation', {
                  'location': '/wheel-picker',
                  'state': null,
                }),
              ),
              (_) => done.complete(),
            );
            await tester.pump();
            await done.future;
            await tester.pumpAndSettle();
            expect(find.byType(SeedBottomSheet), findsOneWidget);
            final originalSheetRoute = ModalRoute.of(
              tester.element(find.byType(SeedWheelPicker)),
            );
            await tester.tap(find.text('다음 날로 변경'));
            await tester.pumpAndSettle();
            expect(find.text('2026년 8월 21일'), findsOneWidget);
            switch (dismiss) {
              case 'done':
                await tester.tap(find.text('완료'));
              case 'close':
                await tester.tap(find.byIcon(Icons.close_rounded).last);
              case 'escape':
                await tester.sendKeyEvent(LogicalKeyboardKey.escape);
              case 'scrim':
                await tester.tapAt(const Offset(8, 80));
            }
            await tester.pumpAndSettle();
            expect(find.byType(SeedBottomSheet), findsOneWidget);
            expect(find.text('2026년 8월 21일'), findsOneWidget);
            expect(
              ModalRoute.of(tester.element(find.byType(SeedWheelPicker))),
              same(originalSheetRoute),
              reason:
                  'React root pop() is a no-op: keep the existing sheet '
                  'route, not a dismissed/reopened replacement',
            );
          },
        );
      }
    }

    testWidgets('React ALL choices enumerate checkbox size variants', (
      tester,
    ) async {
      await tester.pumpWidget(const StackflowSpaApp());
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/checkbox');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('All').last);
      await tester.pumpAndSettle();

      expect(find.text('그리드 표시'), findsOneWidget);
      expect(find.text('ALL'), findsNothing);
    });

    for (final width in [390.0, 800.0]) {
      testWidgets(
        'WheelPicker sheet has no host AppBar at $width and advances day',
        (tester) async {
          final height = width == 390 ? 844.0 : 800.0;
          tester.view.physicalSize = Size(width, height);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(const StackflowSpaApp());
          tester
              .state<NavigatorState>(find.byType(Navigator))
              .pushNamed('/wheel-picker');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pumpAndSettle();

          // React ActivityWheelPicker is the sheet itself, with no AppBar behind
          // its scrim. The host must not insert its generic navigation bar.
          expect(find.byType(SeedTopNavigation), findsNothing);
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          expect(find.text('2026년 8월 20일'), findsOneWidget);

          // Official React <Text> defaults to t5Regular (16px/22px). The
          // summary's 22px line box determines the sheet's intrinsic height.
          final summary = tester.widget<Text>(find.text('2026년 8월 20일').first);
          expect(summary.style?.fontSize, 16);
          expect(summary.style?.height, closeTo(22 / 16, 0.001));

          // React WheelPicker CSS uses max-content column widths, not three
          // equally expanded thirds. CDP 390: year=118.73, month=83.09,
          // day=86.97, centered as a group in the 360px root.
          final datePicker = tester.widget<SeedWheelPicker>(
            find.byType(SeedWheelPicker),
          );
          final columnWidths = [
            for (final column in datePicker.columns) column.width,
          ];
          expect(columnWidths, everyElement(isNotNull));
          expect(columnWidths[0], closeTo(119, 10));
          expect(columnWidths[1], closeTo(83, 10));
          expect(columnWidths[2], closeTo(87, 10));

          // The official medium WheelPicker uses t10Medium (26px, w500) for
          // all three wheels, not the default 14px example body text.
          for (final label in ['2026년', '8월', '20일']) {
            final item = tester.widget<Text>(find.text(label).first);
            expect(item.style?.fontSize, 26, reason: '$label font size');
            expect(
              item.style?.fontWeight,
              FontWeight.w500,
              reason: '$label font weight',
            );
          }

          // The sheet component already applies its own footer x16 inset.
          final nextButton = find.widgetWithText(SeedButton, '다음 날로 변경');
          expect(
            tester.getTopLeft(nextButton).dx,
            closeTo(width == 390 ? 16 : 176, 1),
          );
          // React sheet begins y376 (390x844) / y332 (800x800), with its
          // 220px wheel 70px below the sheet's top edge.
          expect(
            tester.getTopLeft(find.byType(SeedWheelPicker)).dy,
            closeTo(width == 390 ? 446 : 402, 1),
          );
          await tester.tap(find.text('다음 날로 변경'));
          await tester.pumpAndSettle();
          expect(find.text('2026년 8월 21일'), findsOneWidget);

          await tester.tap(find.text('완료'));
          await tester.pumpAndSettle();
          expect(find.text('Home'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('Form, Select, TimePicker and attachment', () {
    for (final width in [390.0, 800.0]) {
      for (final route in ['/time-picker', '/wheel-picker']) {
        testWidgets(
          'Root $route initial Tab focuses first wheel column $width',
          (tester) async {
            tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(const StackflowSpaApp());
            await tester.pumpAndSettle();
            final done = Completer<void>();
            tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              SystemChannels.navigation.name,
              SystemChannels.navigation.codec.encodeMethodCall(
                MethodCall('pushRouteInformation', {
                  'location': route,
                  'state': null,
                }),
              ),
              (_) => done.complete(),
            );
            await tester.pump();
            await done.future;
            await tester.pumpAndSettle();
            expect(find.byType(SeedWheelPicker), findsOneWidget);

            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            expect(
              FocusManager.instance.primaryFocus?.context
                  ?.findAncestorWidgetOfExactType<SeedWheelPicker>(),
              isNotNull,
              reason: 'React first Tab targets picker rather than header close/Home',
            );
            await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
            await tester.pumpAndSettle();
            final reverseFocus = FocusManager.instance.primaryFocus?.context;
            if (route == '/time-picker') {
              expect(
                reverseFocus
                    ?.findAncestorWidgetOfExactType<
                      SeedTopNavigationIconButton
                    >(),
                isNotNull,
                reason: 'React first column reverse Tab returns to Home',
              );
            } else {
              var reverseClose = false;
              reverseFocus?.visitAncestorElements((element) {
                if (element.widget.runtimeType.toString() ==
                    '_SeedBottomSheetCloseButton') {
                  reverseClose = true;
                  return false;
                }
                return true;
              });
              expect(
                reverseClose,
                isTrue,
                reason: 'React first year column reverse Tab returns to Close',
              );
            }
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            expect(
              FocusManager.instance.primaryFocus?.context
                  ?.findAncestorWidgetOfExactType<SeedWheelPicker>(),
              isNotNull,
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
            await tester.pumpAndSettle();
            expect(
              find.text(
                route == '/time-picker' ? '선택한 시간: 13:00' : '2026년 8월 19일',
              ),
              findsOneWidget,
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pumpAndSettle();
            expect(
              find.text(
                route == '/time-picker' ? '선택한 시간: 13:10' : '2026년 8월 20일',
              ),
              findsOneWidget,
            );

            for (var i = 0; i < (route == '/time-picker' ? 1 : 3); i++) {
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            }
            await tester.pumpAndSettle();
            final focusedContext = FocusManager.instance.primaryFocus?.context;
            if (route == '/time-picker') {
              expect(
                focusedContext
                    ?.findAncestorWidgetOfExactType<
                      SeedTopNavigationIconButton
                    >(),
                isNotNull,
                reason:
                    'Header Home must remain reachable after picker columns',
              );
            } else {
              var closeButtonFocused = false;
              focusedContext?.visitAncestorElements((element) {
                if (element.widget.runtimeType.toString() ==
                    '_SeedBottomSheetCloseButton') {
                  closeButtonFocused = true;
                  return false;
                }
                return true;
              });
              expect(
                closeButtonFocused,
                isTrue,
                reason:
                    'Sheet Close must remain reachable after picker actions',
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('required Select blocks empty submit then accepts a fruit', (
      tester,
    ) async {
      await open(tester, '/select');
      final submit = find.widgetWithText(SeedButton, '제출');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.textContaining('제출됨:'), findsNothing);
      expect(find.text('과일을 선택해주세요.'), findsOneWidget);
      final select = find.descendant(
        of: find.byType(FormField<String>),
        matching: find.byType(SeedSelect<String>),
      );
      await tester.ensureVisible(select);
      await tester.tap(select);
      await tester.pumpAndSettle();
      await tester.tap(find.text('바나나').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('제출됨: banana'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Form submits default values as JSON without messenger errors',
      (tester) async {
        await open(tester, '/form');
        await tester.tap(find.widgetWithText(SeedButton, '제출'));
        await tester.pumpAndSettle();
        final snackbar = tester.widget<SeedSnackbar>(find.byType(SeedSnackbar));
        expect(jsonDecode(snackbar.message), containsPair('name', ['']));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'deleting the featured attachment promotes the current first entry',
      (tester) async {
        await open(tester, '/attachment-display-field');
        final field = find.byWidgetPredicate(
          (w) =>
              w is SeedAttachmentDisplayField &&
              w.label == 'Customizing Items (대표사진 배지)',
        );
        await tester.ensureVisible(field);
        await tester.tap(
          find
              .descendant(of: field, matching: find.bySemanticsLabel('파일 제거'))
              .first,
        );
        await tester.pumpAndSettle();
        final input = tester.widget<SeedAttachmentInput>(
          find.descendant(
            of: field,
            matching: find.byType(SeedAttachmentInput),
          ),
        );
        expect(input.items.length, 1);
        expect(input.items.single.isRepresentative, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Form layout and serialization', () {
    testWidgets(
      'Form keeps email and address side by side and serializes successful controls',
      (tester) async {
        await openStackflowSpaVisualFix(tester, '/form', width: 390);
        expect(find.text('Form Components'), findsOneWidget);
        expect(find.byIcon(Icons.home_outlined), findsNothing);
        final email = find.byWidgetPredicate(
          (w) => w is SeedTextField && w.label == '이메일',
        );
        final address = find.byWidgetPredicate(
          (w) => w is SeedTextField && w.label == '주소',
        );
        expect(tester.getTopLeft(email).dy, tester.getTopLeft(address).dy);
        expect(
          tester.getTopLeft(email).dx,
          lessThan(tester.getTopLeft(address).dx),
        );
        await tester.tap(find.widgetWithText(SeedButton, '제출'));
        await tester.pumpAndSettle();
        final data = jsonDecode(
          tester.widget<SeedSnackbar>(find.byType(SeedSnackbar)).message,
        ) as Map;
        expect(data['attachments'], [{}]);
        for (final key in ['category', 'extra', 'fruit', 'agreement']) {
          expect(data.containsKey(key), false);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  });

  group('category sheet over Form', () {
    testWidgets('the category sheet keeps its Form visible behind it', (
      tester,
    ) async {
      await _openDirect(tester, '/form');
      await tester.tap(find.text('카테고리를 선택해주세요'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      expect(find.text('Form Components'), findsOneWidget);
    });
  });

  group('category route result', () {
    testWidgets(
      'Form category uses Stackflow route and returns selected value',
      (tester) async {
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();

        tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/form');
        await tester.pumpAndSettle();

        final select = find.byType(SeedFieldButton);
        await tester.ensureVisible(select);
        await tester.tap(select);
        await tester.pumpAndSettle();

        expect(find.text('전자기기'), findsOneWidget);
        await tester.tap(find.text('전자기기'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('완료'));
        await tester.pumpAndSettle();

        expect(find.text('전자기기'), findsOneWidget);
        expect(find.text('카테고리 선택'), findsWidgets);
      },
    );
  });
}
