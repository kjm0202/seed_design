import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

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

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

class Probe extends StatefulWidget {
  const Probe({super.key, required this.onMount, required this.onDispose});
  final VoidCallback onMount, onDispose;
  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SeedTextField(label: '메모');
}

void main() {
  group('layout', () {
    setUpAll(loadSeedTestFonts);
  });

  group('content lifetime', () {
    for (final lazy in [false, true]) {
      for (final unmount in [false, true]) {
        testWidgets(
          'Popover lazy=$lazy unmount=$unmount controls real content lifetime',
          (tester) async {
            var mounts = 0, disposals = 0;
            final controller = SeedOverlayController();
            addTearDown(controller.dispose);
            await tester.pumpWidget(
              host(
                SeedPopoverTrigger(
                  controller: controller,
                  lazyMount: lazy,
                  unmountOnExit: unmount,
                  triggerBuilder: (_, _, toggle) =>
                      TextButton(onPressed: toggle, child: const Text('open')),
                  builder: (ctx) => SeedPopover(
                    body: Probe(
                      onMount: () => mounts++,
                      onDispose: () => disposals++,
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(mounts, lazy ? 0 : 1);
            expect(find.text('메모'), findsNothing);
            controller.open();
            await tester.pumpAndSettle();
            expect(mounts, 1);
            await tester.tap(find.byType(EditableText));
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<EditableText>(find.byType(EditableText))
                  .focusNode
                  .canRequestFocus,
              isTrue,
              reason: 'eager content must become focusable when opened',
            );
            expect(
              tester
                  .widget<EditableText>(find.byType(EditableText))
                  .focusNode
                  .hasFocus,
              isTrue,
            );
            await tester.enterText(find.byType(EditableText), 'keep me');
            expect(
              tester
                  .widget<EditableText>(find.byType(EditableText))
                  .controller
                  .text,
              'keep me',
              reason: 'entered before close',
            );
            controller.close();
            await tester.pumpAndSettle();
            expect(disposals, unmount ? 1 : 0);
            expect(find.text('메모'), findsNothing);
            controller.open();
            await tester.pumpAndSettle();
            expect(mounts, unmount ? 2 : 1);
            expect(controller.isOpen, isTrue, reason: 'reopened');
            expect(find.text('메모'), findsOneWidget, reason: 'visible again');
            expect(
              find.text('keep me'),
              unmount ? findsNothing : findsOneWidget,
            );
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  });

  group('structure', () {
    Widget host(Widget child, {bool isDark = false}) {
      return MaterialApp(
        theme: (isDark ? SeedThemeData.dark() : SeedThemeData.light())
            .toThemeData(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets(
      'SeedPopover renders structured Header, Body, Footer, and 52px close button',
      (tester) async {
        var closed = false;
        await tester.pumpWidget(
          host(
            SeedPopover(
              titleText: '알림',
              descriptionText: '자세한 내용입니다.',
              body: const Text('본문 내용'),
              footer: const Text('하단 액션'),
              onClose: () => closed = true,
            ),
          ),
        );

        expect(find.text('알림'), findsOneWidget);
        expect(find.text('자세한 내용입니다.'), findsOneWidget);
        expect(find.text('본문 내용'), findsOneWidget);
        expect(find.text('하단 액션'), findsOneWidget);

        final closeFinder = find.byIcon(Icons.close_rounded);
        expect(closeFinder, findsOneWidget);
        await tester.tap(closeFinder);
        expect(closed, isTrue);

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: closeFinder,
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(animatedContainer.constraints?.maxWidth, 52.0);
        expect(animatedContainer.constraints?.maxHeight, 52.0);
      },
    );
  });

  group('focus-out', () {
    setUpAll(loadSeedTestFonts);

    // React headless Popover.tsx:174-189 uses
    // closeOnFocusOut={api.closeOnInteractOutside}, so an explicitly persistent
    // popover must not disappear merely because another control gains focus.
    for (final viewport in [const Size(390, 844), const Size(800, 800)]) {
      testWidgets(
        'Popover outside interaction opt-out preserves content on focus-out $viewport',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport;
          addTearDown(tester.view.reset);
          final outside = FocusNode(debugLabel: 'outside control');
          final controller = SeedOverlayController();
          addTearDown(outside.dispose);
          addTearDown(controller.dispose);
          final reasons = <SeedOverlayDismissReason>[];

          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    SeedPopoverTrigger(
                      controller: controller,
                      closeOnInteractOutside: false,
                      onOpenChange: (open, reason) {
                        if (!open) reasons.add(reason);
                      },
                      triggerBuilder: (context, open, toggle) => TextButton(
                        onPressed: toggle,
                        child: const Text('Toggle persistent popover'),
                      ),
                      builder: (context) => const SeedPopover(
                        titleText: 'Persistent popup',
                        body: SizedBox(
                          height: 90,
                          child: Text('Popover body remains mounted'),
                        ),
                      ),
                    ),
                    TextButton(
                      focusNode: outside,
                      onPressed: () {},
                      child: const Text('Outside focusable'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.tap(find.text('Toggle persistent popover'));
          await tester.pumpAndSettle();
          expect(controller.isOpen, isTrue);
          expect(find.text('Persistent popup'), findsOneWidget);

          outside.requestFocus();
          await tester.pumpAndSettle();
          expect(outside.hasFocus, isTrue);
          expect(controller.isOpen, isTrue);
          expect(find.text('Persistent popup'), findsOneWidget);
          expect(reasons, isEmpty);

          // The Escape path remains independently dismissible when focus returns
          // to the popup, without reusing the earlier Shift+Tab boundary fix.
          await tester.tap(find.text('Toggle persistent popover'));
          await tester.pumpAndSettle();
          expect(controller.isOpen, isFalse);
          expect(reasons.single, SeedOverlayDismissReason.trigger);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Popover explicit focus-out override remains effective $viewport',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport;
          addTearDown(tester.view.reset);
          final controller = SeedOverlayController();
          final outsider = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(outsider.dispose);
          final reasons = <SeedOverlayDismissReason>[];
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                  .toThemeData(),
              home: Scaffold(
                body: Column(
                  children: [
                    SeedPopoverTrigger(
                      controller: controller,
                      closeOnInteractOutside: false,
                      closeOnFocusOut: true,
                      onOpenChange: (open, reason) {
                        if (!open) reasons.add(reason);
                      },
                      triggerBuilder: (context, open, toggle) => TextButton(
                        onPressed: toggle,
                        child: const Text('Explicit focus policy'),
                      ),
                      builder: (context) => const SeedPopover(
                        titleText: 'Explicit focus popup',
                        body: SizedBox(
                          height: 70,
                          child: Text('Keyboard content'),
                        ),
                      ),
                    ),
                    TextButton(
                      focusNode: outsider,
                      onPressed: () {},
                      child: const Text('Next focus'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.tap(find.text('Explicit focus policy'));
          await tester.pumpAndSettle();
          expect(controller.isOpen, isTrue);
          outsider.requestFocus();
          await tester.pumpAndSettle();
          expect(controller.isOpen, isFalse);
          expect(reasons, [SeedOverlayDismissReason.focusOut]);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
