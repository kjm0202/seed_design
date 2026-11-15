import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

Future<void> mount(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(900, 700),
  EdgeInsets padding = EdgeInsets.zero,
  bool dark = false,
  double scale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final theme = dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      supportedLocales: const [Locale('en'), Locale('ko')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: theme.toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: padding,
          viewPadding: padding,
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get closeButton => find.byWidgetPredicate(
  (widget) => widget is SeedPressable && widget.semanticsLabel == '닫기',
);

void main() {
  testWidgets('fade padding cannot make nearly fitting content overflow', (
    tester,
  ) async {
    var height = 120.0;
    late StateSetter update;
    await tester.pumpWidget(
      seedApp(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedDialog(
              title: 'Title',
              maxHeight: 300,
              content: SizedBox(height: height),
              footer: const SizedBox(height: 40),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SeedScrollFog), findsNothing);
    update(() => height = 170);
    await tester.pumpAndSettle();
    expect(find.byType(SeedScrollFog), findsOneWidget);
    update(() => height = 120);
    await tester.pumpAndSettle();
    expect(find.byType(SeedScrollFog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overflowing dialog bodies scroll while the footer stays fixed', (
    tester,
  ) async {
    var tall = true;
    late StateSetter update;
    await tester.pumpWidget(
      seedApp(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedDialog(
              title: 'Title',
              maxHeight: 400,
              content: SizedBox(
                key: const ValueKey('body'),
                height: tall ? 800 : 40,
              ),
              footer: const SizedBox(key: ValueKey('footer'), height: 40),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fog = find.byType(SeedScrollFog);
    expect(fog, findsOneWidget);
    expect(tester.getSize(fog).height, 48);
    final scroll = find.byType(SingleChildScrollView);
    final footer = tester.getRect(find.byKey(const ValueKey('footer')));
    await tester.drag(scroll, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const ValueKey('footer'))), footer);
    expect(find.byType(SeedDivider), findsOneWidget);
    update(() => tall = false);
    await tester.pumpAndSettle();
    expect(fog, findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('footer'))).dy -
          tester.getBottomLeft(find.byKey(const ValueKey('body'))).dy,
      16,
    );
    expect(tester.takeException(), isNull);
  });
  group('backdrop and focus', () {
    setUpAll(loadSeedTestFonts);
    testWidgets('showSeedDialog closes on the backdrop unless told not to', (
      tester,
    ) async {
      Widget app(bool? dismissible) => fontApp(
        Builder(
          builder: (context) => SeedButton(
            label: 'Open',
            onPressed: () => dismissible == null
                ? showSeedDialog<void>(
                    context: context,
                    child: const SeedDialog(
                      title: 'Body',
                      content: SizedBox.shrink(),
                    ),
                  )
                : showSeedDialog<void>(
                    context: context,
                    barrierDismissible: dismissible,
                    child: const SeedDialog(
                      title: 'Body',
                      content: SizedBox.shrink(),
                    ),
                  ),
          ),
        ),
      );
      await tester.pumpWidget(app(null));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);

      await tester.pumpWidget(app(false));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('a scrolling dialog body takes keyboard focus', (tester) async {
      await tester.pumpWidget(
        fontApp(
          Builder(
            builder: (context) => SeedButton(
              label: 'Open',
              onPressed: () => showSeedDialog<void>(
                context: context,
                child: SeedDialog(
                  title: 'Title',
                  content: Text(List.filled(800, 'Long body').join(' ')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(SeedDialog),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      await tester.pump();
      final body = tester.widget<Focus>(
        find
            .descendant(
              of: find.byType(SeedScrollArea),
              matching: find.byType(Focus),
            )
            .first,
      );
      expect(body.canRequestFocus, isTrue);
      Focus.of(tester.element(find.byType(SingleChildScrollView).last))
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(scroll.position.pixels, greaterThan(0));
    });
  });
  group('alert title', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'alert titles wrap naturally inside the official 272px surface',
      (tester) async {
        addTearDown(tester.view.reset);
        for (final scale in [1.0, 2.0]) {
          await mount(
            tester,
            const SeedAlertDialog(
              title: '알림 설정을 저장하시겠습니까?',
              description: '설정하신 키워드에 대한 푸시 알림이 즉시 활성화됩니다.',
            ),
            scale: scale,
          );
          final title = find.text('알림 설정을 저장하시겠습니까?');
          expect(tester.getSize(title).width, 272 - 2 * 20);
          expect(tester.getSize(title).height, greaterThan(SeedLineHeight.t7));
          final paragraph = tester.renderObject<RenderParagraph>(title);
          expect(paragraph.didExceedMaxLines, isFalse);
          expect(tester.takeException(), isNull);
        }
      },
    );
  });

  group('actions, fade and dismissal', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'alert actions are equal width and fold primary above secondary',
      (tester) async {
        for (final long in [false, true]) {
          final confirm = long ? 'Continue with this operation' : 'OK';
          await tester.pumpWidget(
            scaledApp(
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
          scaledApp(
            managed
                ? SeedDialogTrigger(
                    controller: overlay,
                    triggerBuilder: (_, _, toggle) => TextButton(
                      onPressed: toggle,
                      child: const Text('Open'),
                    ),
                    builder: (_) => const SeedDialog(
                      title: 'Dialog',
                      content: Text('Body'),
                    ),
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
          scaledApp(
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
          scaledApp(
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
  });

  group('close prevention', () {
    testWidgets('dialog close respects prevention and closes with reason', (
      tester,
    ) async {
      var prevent = true;
      final reasons = <SeedOverlayDismissReason>[];
      await tester.pumpWidget(
        koreanApp(
          Center(
            child: SeedDialogTrigger(
              responsive: false,
              canClose: (_) => !prevent,
              onOpenChanged: (_, reason) => reasons.add(reason),
              triggerBuilder: (_, open, toggle) => TextButton(
                onPressed: toggle,
                child: const Text('Dialog open'),
              ),
              builder: (_) => const SeedDialog(
                title: 'Dialog title',
                content: Text('Dialog body'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Dialog open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('닫기'));
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsOneWidget);
      prevent = false;
      await tester.tap(find.byTooltip('닫기'));
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsNothing);
      expect(reasons.last, SeedOverlayDismissReason.closeButton);
      expect(tester.takeException(), isNull);
    });
  });

  group('custom header', () {
    testWidgets(
      'custom header dialog exposes dismiss action and Escape dismisses route',
      (tester) async {
        await tester.pumpWidget(
          koreanAppCentered(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedDialog<void>(
                  context: context,
                  child: const SeedDialog(
                    header: Text('Custom header'),
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
        expect(find.byTooltip('닫기'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(SeedDialog), findsNothing);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('닫기'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedDialog), findsNothing);
      },
    );
  });

  group('responsive dialog', () {
    Future<void> mount(
      WidgetTester tester,
      Widget child, {
      double width = 390,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(body: child),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('responsive dialog resizes without losing its editor state', (
      tester,
    ) async {
      final visibility = <bool>[];
      await mount(
        tester,
        SeedDialogTrigger(
          responsive: true,
          onOpenChange: (open, _) => visibility.add(open),
          triggerBuilder: (_, open, toggle) =>
              TextButton(onPressed: toggle, child: const Text('Open')),
          builder: (_) => const SeedDialog(
            title: 'Title',
            content: SeedTextInput(defaultValue: 'Original'),
          ),
        ),
        width: 800,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final editor = find.byType(EditableText);
      await tester.enterText(editor, 'Edited');
      final editorState = tester.state(editor);
      for (final width in [390.0, 800.0]) {
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpAndSettle();
        expect(
          find.byType(SeedBottomSheet),
          width < 768 ? findsOneWidget : findsNothing,
        );
        expect(tester.state(editor), same(editorState));
        expect(tester.widget<EditableText>(editor).controller.text, 'Edited');
        expect(tester.widget<EditableText>(editor).focusNode.hasFocus, isTrue);
      }
      expect(visibility, [true]);
    });
  });

  group('surface', () {
    testWidgets('dialogs have no drop shadow (official recipe has none)', (
      tester,
    ) async {
      await tester.pumpWidget(
        koreanAppTopLeft(
          const SeedDialog(title: 'Body', content: SizedBox.shrink()),
          width: 390,
        ),
      );
      final shadows = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(SeedDialog),
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);
      expect(shadows, isEmpty);
    });
  });
}
