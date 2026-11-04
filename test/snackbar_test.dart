// Isolated PUBLIC Flutter Snackbar contract probes, post-927.
// No browser parity is inferred from these WidgetTester fake-clock results.
// To run a separately labelled expected React-strict RED probe:
// flutter test --dart-define=REACT_STRICT_RED=true --plain-name 'REACT_STRICT_RED' <this file>

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

const bool _reactStrictRed = bool.fromEnvironment('REACT_STRICT_RED');

Widget _host({
  required SeedSnackbarController controller,
  Widget? child,
  Key? providerKey,
}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: SeedSnackbarProvider(
    key: providerKey,
    controller: controller,
    child: Scaffold(body: child ?? const SizedBox.expand()),
  ),
);

Future<void> _show(
  WidgetTester tester,
  SeedSnackbarController controller,
  String payload, {
  Duration duration = const Duration(seconds: 4),
  SeedSnackbarStrategy? strategy,
  void Function()? onClose,
}) async {
  controller.show(
    child: SeedSnackbar(message: payload),
    duration: duration,
    strategy: strategy,
    onClose: onClose,
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 330));
}

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostStateParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('actual mouse hover holds timer; leave expires once', (
    tester,
  ) async {
    final controller = SeedSnackbarController();
    addTearDown(controller.dispose);
    var notifications = 0;
    var closed = 0;
    controller.addListener(() => notifications++);
    await tester.pumpWidget(_host(controller: controller));

    await _show(tester, controller, 'hover-public', onClose: () => closed++);
    expect(find.text('hover-public'), findsOneWidget);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    await mouse.moveTo(tester.getCenter(find.text('hover-public')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 7));
    await tester.pump();
    expect(find.text('hover-public'), findsOneWidget);
    expect(closed, 0);

    await mouse.moveTo(const Offset(1, 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('hover-public'), findsNothing);
    expect(closed, 1);
    expect(notifications, greaterThanOrEqualTo(2));
    // Capture observer count without relying on private queue/timer fields.
    // ignore: avoid_print
    print('hover: closed=$closed notifications=$notifications');
    await mouse.removePointer();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('focus holds; unfocus releases public controller timer', (
    tester,
  ) async {
    final controller = SeedSnackbarController();
    final focus = FocusNode(debugLabel: 'snackbar-action');
    addTearDown(() {
      focus.dispose();
      controller.dispose();
    });
    var closes = 0;
    await tester.pumpWidget(_host(controller: controller));
    controller.show(
      child: Focus(focusNode: focus, child: const Text('focus-public')),
      onClose: () => closes++,
      duration: const Duration(seconds: 2),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 330));
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();
    expect(find.text('focus-public'), findsOneWidget);
    expect(closes, 0);
    focus.unfocus();
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('focus-public'), findsNothing);
    expect(closes, 1);
    // ignore: avoid_print
    print('focus: closes=$closes focusHasFocus=${focus.hasFocus}');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('explicit queued vs immediate override: two real entries', (
    tester,
  ) async {
    final controller = SeedSnackbarController(
      strategy: SeedSnackbarStrategy.queued,
    );
    addTearDown(controller.dispose);
    final closed = <String>[];
    var updates = 0;
    controller.addListener(() => updates++);
    await tester.pumpWidget(_host(controller: controller));
    await _show(
      tester,
      controller,
      'queued-A',
      onClose: () => closed.add('queued-A'),
    );
    await _show(
      tester,
      controller,
      'queued-B',
      onClose: () => closed.add('queued-B'),
    );
    expect(find.text('queued-A'), findsOneWidget);
    expect(find.text('queued-B'), findsNothing);
    controller.close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 330));
    expect(find.text('queued-A'), findsNothing);
    expect(find.text('queued-B'), findsOneWidget);
    expect(closed, ['queued-A']);

    await _show(
      tester,
      controller,
      'immediate-C',
      strategy: SeedSnackbarStrategy.immediate,
      onClose: () => closed.add('immediate-C'),
    );
    expect(find.text('queued-B'), findsNothing);
    expect(find.text('immediate-C'), findsOneWidget);
    expect(closed, ['queued-A', 'queued-B']);
    controller.close();
    await tester.pump(const Duration(milliseconds: 200));
    expect(closed, ['queued-A', 'queued-B', 'immediate-C']);
    // ignore: avoid_print
    print('strategy: closeOrder=$closed notifications=$updates');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('root provider survives route change and new submission', (
    tester,
  ) async {
    final controller = SeedSnackbarController();
    addTearDown(controller.dispose);
    final routes = <String>[];
    final closed = <String>[];
    final navigator = GlobalKey<NavigatorState>();
    var notifications = 0;
    controller.addListener(() => notifications++);
    Widget route(String label) =>
        Scaffold(body: Center(child: Text('route-$label')));
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        navigatorKey: navigator,
        builder: (context, child) =>
            SeedSnackbarProvider(controller: controller, child: child!),
        onGenerateRoute: (settings) {
          final name = settings.name ?? '/';
          routes.add(name);
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => route(name == '/' ? 'form' : 'home'),
          );
        },
      ),
    );
    await _show(
      tester,
      controller,
      'route-A',
      duration: const Duration(seconds: 5),
      strategy: SeedSnackbarStrategy.immediate,
      onClose: () => closed.add('route-A'),
    );
    expect(find.text('route-A'), findsOneWidget);
    navigator.currentState!.pushReplacementNamed('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('route-home'), findsOneWidget);
    // Provider is above Navigator; route changes do NOT dispose it.
    expect(find.text('route-A'), findsOneWidget);
    await _show(
      tester,
      controller,
      'route-B',
      duration: const Duration(seconds: 5),
      strategy: SeedSnackbarStrategy.immediate,
      onClose: () => closed.add('route-B'),
    );
    expect(find.text('route-A'), findsNothing);
    expect(find.text('route-B'), findsOneWidget);
    expect(closed, ['route-A']);
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('route-B'), findsNothing);
    expect(closed, ['route-A', 'route-B']);
    // ignore: avoid_print
    print(
      'global provider routes=$routes closed=$closed notifications=$notifications',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disposing page-scoped provider detaches visible entry', (
    tester,
  ) async {
    final controller = SeedSnackbarController();
    addTearDown(controller.dispose);
    var closed = 0;
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        navigatorKey: nav,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => settings.name == '/away'
              ? const Scaffold(body: Text('away-page'))
              : SeedSnackbarProvider(
                  controller: controller,
                  child: const Scaffold(body: Text('form-page')),
                ),
        ),
      ),
    );
    await _show(
      tester,
      controller,
      'page-only',
      duration: const Duration(seconds: 5),
      onClose: () => closed++,
    );
    expect(find.text('page-only'), findsOneWidget);
    nav.currentState!.pushReplacementNamed('/away');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('away-page'), findsOneWidget);
    expect(find.text('page-only'), findsNothing);
    // Detaching provider is NOT equivalent to dismiss/onClose.
    expect(closed, 0);
    controller.close();
    await tester.pump(const Duration(milliseconds: 200));
    expect(closed, 1);
    // ignore: avoid_print
    print('page-dispose: visible=false closedAfterExplicitClose=$closed');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  // Historical React-strict probe. Flutter now uses the source-confirmed
  // default immediate strategy; keep this optional test for that contract.
  testWidgets('REACT_STRICT default-immediate expectation', (tester) async {
    final controller = SeedSnackbarController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(controller: controller));
    await _show(tester, controller, 'contract-A');
    await _show(tester, controller, 'contract-B');
    // React headless defaults to immediate, but first transitions through
    // the dismissing state before promoting the second entry (200ms exit
    // delay): use a 500ms observation instead of claiming instant paint.
    // Flutter's default now also promotes B (while callers may explicitly
    // request the legacy queued strategy).
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));
    // This is only a Flutter widget contract, not paired-browser parity.
    expect(find.text('contract-B'), findsOneWidget);
  }, skip: !_reactStrictRed);
  group('immediate queue', () {
    setUpAll(loadSeedTestFonts);
    testWidgets('immediate exits the current one before the next enters', (
      tester,
    ) async {
      final controller = SeedSnackbarController();
      addTearDown(controller.dispose);
      final closed = <String>[];
      await tester.pumpWidget(
        _app(
          SeedSnackbarProvider(
            controller: controller,
            child: const SizedBox.expand(),
          ),
        ),
      );
      controller.show(
        child: const SeedSnackbar(message: 'A'),
        onClose: () => closed.add('A'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 330));
      controller.show(
        child: const SeedSnackbar(message: 'B'),
        onClose: () => closed.add('B'),
      );
      await tester.pump();
      expect(closed, isEmpty, reason: 'onClose waits for removeDelay');
      await tester.pump(const Duration(milliseconds: 199));
      expect(find.text('B'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      expect(closed, ['A']);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 330));
      expect(find.text('B'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
  group('text style', () {
    for (final dark in [false, true]) {
      for (final variant in SeedSnackbarVariant.values) {
        testWidgets(
          'provider snackbar text dark=$dark variant=${variant.name}',
          (tester) async {
            final controller = SeedSnackbarController();
            addTearDown(controller.dispose);
            final seedTheme = dark
                ? SeedThemeData.dark()
                : SeedThemeData.light();
            await tester.pumpWidget(
              MaterialApp(
                theme: seedTheme.toThemeData(),
                // Match app-root placement, outside the page's Material surface.
                home: SeedSnackbarProvider(
                  controller: controller,
                  child: const Scaffold(body: SizedBox.shrink()),
                ),
              ),
            );
            var actions = 0;
            controller.show(
              child: SeedSnackbar(
                message: '키워드 알림이 설정되었습니다.',
                actionLabel: '설정확인',
                onAction: () => actions++,
                variant: variant,
              ),
            );
            await tester.pumpAndSettle();

            for (final (label, color) in [
              ('키워드 알림이 설정되었습니다.', seedTheme.colorScheme.fg.onNeutralSolid),
              ('설정확인', seedTheme.colorScheme.fg.brand),
            ]) {
              final paragraph = tester.renderObject<RenderParagraph>(
                find.descendant(
                  of: find.text(label),
                  matching: find.byType(RichText),
                ),
              );
              final style = paragraph.text.style!;
              expect(
                style.decoration ?? TextDecoration.none,
                TextDecoration.none,
              );
              expect(style.color, color);
            }

            await tester.tap(find.text('설정확인'));
            await tester.pumpAndSettle();
            expect(actions, 1);
            expect(find.byType(SeedSnackbar), findsNothing);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  });

  group('FIFO queue', () {
    testWidgets(
      'snackbars retain each message for its duration in FIFO order',
      (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          host(
            Builder(
              builder: (value) {
                context = value;
                return const SizedBox();
              },
            ),
          ),
        );
        final first = showSeedSnackbar(context: context, message: 'First');
        await tester.pumpAndSettle();
        showSeedSnackbar(context: context, message: 'Second');
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsNothing);
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        expect(await first.closed, SnackBarClosedReason.timeout);
        expect(find.text('Second'), findsOneWidget);
      },
    );
  });

  group('hover pause', () {
    testWidgets(
      'snackbar pauses while hovered and preserves explicit queued strategy',
      (tester) async {
        final controller = SeedSnackbarController(
          strategy: SeedSnackbarStrategy.queued,
        );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          hostStateParity(
            SeedSnackbarProvider(
              controller: controller,
              child: const SizedBox.expand(),
            ),
          ),
        );
        controller.show(
          child: const SeedSnackbar(message: 'One'),
          duration: const Duration(seconds: 1),
        );
        controller.show(child: const SeedSnackbar(message: 'Two'));
        await tester.pumpAndSettle();
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: tester.getCenter(find.text('One')));
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('One'), findsOneWidget);
        await mouse.moveTo(const Offset(0, 0));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(find.text('One'), findsNothing);
        expect(find.text('Two'), findsOneWidget);
        await mouse.removePointer();
      },
    );
  });
}
