import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget host(Widget child, {double scale = 1, bool dark = false}) => MaterialApp(
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

Finder get closeButton => find.byWidgetPredicate(
  (widget) => widget is SeedPressable && widget.semanticsLabel == '닫기',
);

Future<void> frames(WidgetTester tester, {int count = 400}) async {
  await tester.pump();
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
}

Future<void> openSheet(
  WidgetTester tester,
  SeedSheetController controller,
  List<int> changes, {
  List<double> points = const [.75, .25, .75],
  bool handleOnly = false,
}) async {
  await tester.pumpWidget(
    host(
      SeedBottomSheetTrigger(
        snapController: controller,
        snapPoints: [
          for (final point in points) SeedSheetSnapPoint.fraction(point),
        ],
        onSnapChanged: changes.add,
        handleOnly: handleOnly,
        triggerBuilder: (_, open, toggle) =>
            TextButton(onPressed: toggle, child: const Text('Open')),
        builder: (_) => const SeedBottomSheet(
          title: 'Sheet',
          showHandle: true,
          content: SizedBox(height: 1000, child: Text('Scroll body')),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Finder get sheetHandle => find
    .descendant(
      of: find.byType(SeedSnappingBottomSheet),
      matching: find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onTap != null,
      ),
    )
    .first;

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('avatar clips empty and custom placeholders in both themes', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      for (final custom in [false, true]) {
        await tester.pumpWidget(
          host(
            RepaintBoundary(
              key: const Key('avatar'),
              child: SeedAvatar(
                placeholder: custom
                    ? const ColoredBox(color: Colors.red)
                    : null,
              ),
            ),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        final alpha = await tester.runAsync(() async {
          final image = await tester
              .renderObject<RenderRepaintBoundary>(
                find.byKey(const Key('avatar')),
              )
              .toImage(pixelRatio: 1);
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          image.dispose();
          return bytes!.getUint8(3);
        });
        expect(
          alpha,
          0,
          reason: 'The circular avatar corner must be transparent.',
        );
      }
    }
  });

  testWidgets('attachment previews and reorder lanes grow with enlarged text', (
    tester,
  ) async {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final reorder in [false, true]) {
        await tester.pumpWidget(
          host(
            SeedAttachmentInput(
              items: const [
                SeedAttachmentItem(
                  id: 'file',
                  type: SeedAttachmentType.file,
                  name: 'sample.pdf',
                  sizeText: '2.4 MB',
                ),
              ],
              onReorder: reorder ? (_, _) {} : null,
            ),
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'scale=$scale, reorder=$reorder',
        );
        final name = tester.getRect(
          find.byWidgetPredicate(
            (widget) => widget is Text && widget.semanticsLabel == 'sample.pdf',
          ),
        );
        final size = tester.getRect(find.text('2.4 MB'));
        expect(name.overlaps(size), isFalse);
        expect(
          size.bottom - name.top,
          lessThanOrEqualTo(
            tester.getSize(find.byType(SeedAttachmentInput)).height,
          ),
        );
      }
    }
  });

  testWidgets('attachment truncation preserves just the extension at the end', (
    tester,
  ) async {
    for (final name in [
      'a_very_long_readable_document_filename.pdf',
      'a_very_long_readable_document_filename',
    ]) {
      await tester.pumpWidget(
        host(
          SeedAttachmentInput(
            items: [
              SeedAttachmentItem(
                id: name,
                name: name,
                type: SeedAttachmentType.file,
              ),
            ],
          ),
        ),
      );
      final text = tester
          .widgetList<Text>(find.byType(Text))
          .singleWhere((widget) => widget.semanticsLabel == name);
      expect(text.data, contains('…'));
      expect(text.data!.split('…').last, name.endsWith('.pdf') ? '.pdf' : '');
    }
  });

  testWidgets('accordion exposes a heading containing one named button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 300,
          child: SeedAccordionItem(
            title: 'Details',
            headingLevel: 4,
            content: Text('Hidden body'),
          ),
        ),
      ),
    );
    final node = tester.getSemantics(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.headingLevel == 4,
      ),
    );
    final data = node.getSemanticsData();
    expect(data.headingLevel, 4);
    expect(data.flagsCollection.isButton, isFalse);
    final children = <SemanticsNode>[];
    node.visitChildren((child) {
      children.add(child);
      return true;
    });
    expect(children, hasLength(1));
    final button = children.single.getSemanticsData();
    expect(button.label, 'Details');
    expect(button.flagsCollection.isButton, isTrue);
    expect(button.hasAction(ui.SemanticsAction.tap), isTrue);
    semantics.dispose();
  });

  testWidgets(
    'alert actions are equal width and fold primary above secondary',
    (tester) async {
      for (final long in [false, true]) {
        final confirm = long ? 'Continue with this operation' : 'OK';
        await tester.pumpWidget(
          host(
            SeedAlertDialog(
              title: 'Alert',
              cancelText: 'Cancel',
              confirmText: confirm,
            ),
          ),
        );
        final cancelRect = tester.getRect(
          find.widgetWithText(SeedButton, 'Cancel'),
        );
        final confirmRect = tester.getRect(
          find.widgetWithText(SeedButton, confirm),
        );
        expect(cancelRect.width, closeTo(confirmRect.width, .01));
        if (long) {
          expect(confirmRect.bottom + 8, closeTo(cancelRect.top, .01));
        } else {
          expect(cancelRect.center.dy, closeTo(confirmRect.center.dy, .01));
          expect(cancelRect.right + 8, closeTo(confirmRect.left, .01));
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  for (final managed in [false, true]) {
    testWidgets('dialog fades out at unit scale ($managed)', (tester) async {
      final overlay = SeedOverlayController();
      await tester.pumpWidget(
        host(
          managed
              ? SeedDialogTrigger(
                  controller: overlay,
                  triggerBuilder: (_, _, toggle) =>
                      TextButton(onPressed: toggle, child: const Text('Open')),
                  builder: (_) =>
                      const SeedDialog(title: 'Dialog', content: Text('Body')),
                )
              : Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showSeedDialog<void>(
                      context: context,
                      child: const SeedDialog(
                        title: 'Dialog',
                        content: Text('Body'),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(closeButton);
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        final scales = tester.widgetList<ScaleTransition>(
          find.ancestor(
            of: find.byType(SeedDialog),
            matching: find.byType(ScaleTransition),
          ),
        );
        for (final scale in scales) {
          expect(scale.scale.value, 1);
        }
      }
      await tester.pumpAndSettle();
      expect(find.byType(SeedDialog), findsNothing);
      overlay.dispose();
    });
  }

  testWidgets('headerless dialog reserves space for close button', (
    tester,
  ) async {
    for (final scroll in [false, true]) {
      await tester.pumpWidget(
        host(
          SeedDialog(
            scrollBody: scroll,
            content: const SizedBox(
              key: Key('body'),
              width: double.infinity,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .getRect(find.byKey(const Key('body')))
            .overlaps(tester.getRect(closeButton)),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('alert Escape policy is independent of outside dismissal', (
    tester,
  ) async {
    for (final escape in [false, true]) {
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showSeedAlertDialog(
                context: context,
                title: 'Alert',
                closeOnEscape: escape,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        find.byType(SeedAlertDialog),
        escape ? findsNothing : findsOneWidget,
      );
      if (!escape) {
        await tester.tap(find.text('확인'));
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('sheet keeps requested duplicate index throughout animation', (
    tester,
  ) async {
    final controller = SeedSheetController();
    final changes = <int>[];
    await openSheet(tester, controller, changes);
    controller.snapTo(1);
    await frames(tester);
    expect(changes, [1]);
    changes.clear();
    controller.snapTo(2);
    await frames(tester);
    expect(changes, [2]);
    expect(controller.index, 2);
    expect(
      tester
          .widget<DraggableScrollableSheet>(
            find.byType(DraggableScrollableSheet),
          )
          .controller!
          .size,
      closeTo(.75, .001),
    );
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('superseded snaps do not emit intermediate indices', (
    tester,
  ) async {
    final controller = SeedSheetController();
    final changes = <int>[];
    await openSheet(tester, controller, changes, points: const [.25, .5, .75]);
    controller.snapTo(2);
    await frames(tester, count: 25);
    controller.snapTo(1);
    await frames(tester);
    expect(changes, [2, 1]);
    expect(controller.index, 1);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  for (final handleOnly in [false, true]) {
    testWidgets('sheet handle and drag synchronize controller ($handleOnly)', (
      tester,
    ) async {
      final controller = SeedSheetController();
      final changes = <int>[];
      await openSheet(
        tester,
        controller,
        changes,
        points: const [.25, .75],
        handleOnly: handleOnly,
      );
      await tester.tap(sheetHandle);
      await tester.pumpAndSettle();
      expect(changes, [1]);
      expect(controller.index, 1);
      await tester.drag(sheetHandle, const Offset(0, 260));
      await tester.pumpAndSettle();
      expect(controller.index, 0);
      expect(changes.last, 0);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });
  }

  testWidgets(
    'sheet body drag reports only the final snap and synchronizes controller',
    (tester) async {
      final controller = SeedSheetController();
      final changes = <int>[];
      await openSheet(
        tester,
        controller,
        changes,
        points: const [.25, .5, .75],
      );
      final sheet = tester.getRect(find.byType(DraggableScrollableSheet));
      await tester.dragFrom(
        Offset(sheet.center.dx, sheet.bottom - 30),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(controller.index, 2);
      expect(changes, [2]);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets('sheet trigger exposes independent outside and Escape policies', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SeedBottomSheetTrigger(
          closeOnInteractOutside: false,
          closeOnEscape: true,
          triggerBuilder: (_, _, toggle) =>
              TextButton(onPressed: toggle, child: const Text('Open')),
          builder: (_) => const SeedBottomSheet(content: Text('Sheet body')),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Sheet body'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Sheet body'), findsNothing);
  });

  testWidgets(
    'help bubble close target fits the 38px body and works at its edges',
    (tester) async {
      var closed = 0;
      for (final dark in [false, true]) {
        await tester.pumpWidget(
          host(
            SeedHelpBubble(
              title: 'Tip',
              onClose: () => closed++,
              arrowPlacement: SeedHelpBubbleArrowPlacement.none,
            ),
            dark: dark,
          ),
        );
        final body = tester.getRect(find.byType(SeedHelpBubble));
        final close = tester.getRect(closeButton);
        expect(body.height, 38);
        expect(close.size, const Size(38, 38));
        expect(close.top, body.top);
        expect(close.right, body.right);
        await tester.tapAt(close.topRight + const Offset(-1, 1));
        await tester.pumpAndSettle();
      }
      expect(closed, 2);
      await tester.pumpWidget(
        host(
          SeedHelpBubble(
            title: 'A long title that wraps on a narrow screen',
            description: 'A longer description',
            maxWidth: 140,
            onClose: () {},
          ),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('composed field labels focus implicit and explicit input nodes', (
    tester,
  ) async {
    final external = FocusNode();
    for (final explicit in [false, true]) {
      await tester.pumpWidget(
        host(
          SeedField(
            label: 'Name',
            child: SeedTextInput(focusNode: explicit ? external : null),
          ),
        ),
      );
      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        isTrue,
      );
      if (explicit) expect(external.hasFocus, isTrue);
    }
    await tester.pumpWidget(
      host(
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
  });

  testWidgets(
    'reaction icon keeps a 24px layout with a working 40px touch target',
    (tester) async {
      var changes = 0;
      await tester.pumpWidget(
        host(SeedImageFrameReactionButton(onChanged: (_) => changes++)),
      );
      final rect = tester.getRect(find.byType(SeedImageFrameReactionButton));
      expect(rect.size, const Size(24, 24));
      await tester.tapAt(rect.topLeft - const Offset(7, 7));
      await tester.pumpAndSettle();
      expect(changes, 1);
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 200,
            child: SeedImageFrame(
              overlay: SeedImageFrameFloater(
                alignment: Alignment.topRight,
                child: SeedImageFrameReactionButton(
                  onChanged: (_) => changes++,
                ),
              ),
            ),
          ),
        ),
      );
      final frame = tester.getRect(find.byType(SeedImageFrame));
      final heart = tester.getRect(find.byType(SeedImageFrameReactionButton));
      expect(frame.right - heart.right, 6);
      expect(heart.top - frame.top, 6);
      await tester.tapAt(heart.topLeft - const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(changes, 2);
    },
  );

  testWidgets('switch row uses the visual mark without an extra touch box', (
    tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      host(
        SeedSwitchListItem(
          title: 'Switch',
          value: value,
          onChanged: (next) => value = next,
          showDivider: false,
        ),
      ),
    );
    expect(tester.getSize(find.byType(SeedSwitchListItem)).height, 56);
    await tester.tap(find.text('Switch'));
    expect(value, isTrue);
  });

  testWidgets('radio row receives its parent radio press feedback', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      host(
        SeedRadioListItem<int>(
          title: 'Radio',
          value: 1,
          onChanged: (value) => selected = value,
          showDivider: false,
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Radio')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final row = find.descendant(
      of: find.byType(SeedListItem),
      matching: find.byType(AnimatedContainer),
    );
    expect(
      tester.widget<AnimatedContainer>(row).margin,
      const EdgeInsets.symmetric(horizontal: 6),
    );
    final scale = find.descendant(
      of: find.byType(SeedContentScale),
      matching: find.byType(AnimatedScale),
    );
    expect(tester.widget<AnimatedScale>(scale).scale, lessThan(1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selected, 1);
    expect(tester.takeException(), isNull);
  });
}
