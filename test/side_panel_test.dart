import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/official_spec.dart';
import 'support/seed_test_fonts.dart';

// Official packages/css/recipes/side-panel.css:133-201:
// Header min(70+safeTop), body flex:1 overflow-y:auto with pb48,
// footer outside body with x6 horizontal / top16 / bottom24 padding.
Future<void> _mount(
  WidgetTester tester, {
  required Size size,
  required double textScale,
  required bool showHeader,
  required bool showFooter,
  required int rows,
  VoidCallback? onClose,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: SeedSidePanel(
            title: showHeader ? '상세 정보' : '',
            description: showHeader ? '긴 설명과 본문' : null,
            showCloseButton: showHeader,
            semanticsLabel: '패널 테스트',
            onClose: onClose,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < rows; index++)
                  Text('본문 $index', style: const TextStyle(fontSize: 16)),
              ],
            ),
            footer: showFooter
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SeedButton(label: '닫기', onPressed: onClose ?? () {}),
                      const SizedBox(height: 8),
                      SeedButton(label: '확인', onPressed: () {}),
                    ],
                  )
                : null,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

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
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final viewport in [390.0, 800.0, 1024.0, 1440.0]) {
    for (final size in SeedSidePanelSize.values) {
      testWidgets('SidePanel $viewport ${size.name} respects 80% cap', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(viewport, 800);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Align(
              alignment: Alignment.centerRight,
              child: SeedSidePanel(
                title: 'Panel',
                size: size,
                body: const Text('Content'),
              ),
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(SeedSidePanel)).width,
          closeTo(math.min(size.width, viewport * .8), .01),
        );
        expect(tester.getRect(find.byType(SeedSidePanel)).right, viewport);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final fromRight in [true, false]) {
    testWidgets('SidePanel safe area and explicit maxWidth $fromRight', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 800);
      addTearDown(tester.view.reset);
      Future<void> mount(double? maxWidth) => tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 800),
              padding: EdgeInsets.only(left: 20, right: 40),
            ),
            child: Align(
              alignment: fromRight
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: SeedSidePanel(
                title: 'Panel',
                fromRight: fromRight,
                maxWidth: maxWidth,
                body: const Text('Content'),
              ),
            ),
          ),
        ),
      );
      await mount(null);
      expect(
        tester.getSize(find.byType(SeedSidePanel)).width,
        closeTo(740 * .8 + (fromRight ? 40 : 20), .01),
      );
      // A caller override retains the existing Flutter width contract.
      await mount(700);
      expect(
        tester.getSize(find.byType(SeedSidePanel)).width,
        closeTo(700 + (fromRight ? 40 : 20), .01),
      );
      expect(tester.takeException(), isNull);
    });
  }
  group('body scroll, close and focus', () {
    for (final width in [320.0, 390.0, 800.0]) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets('body is the only Scrollable, footer stays fixed '
            '$width × $scale', (tester) async {
          await _mount(
            tester,
            size: Size(width, 700),
            textScale: scale,
            showHeader: true,
            showFooter: true,
            rows: 80,
          );
          final panel = find.byType(SeedSidePanel);
          final scrolls = find.descendant(
            of: panel,
            matching: find.byType(Scrollable),
          );
          expect(scrolls, findsOneWidget);
          final position = tester.state<ScrollableState>(scrolls).position;
          expect(position.maxScrollExtent, greaterThan(0));
          expect(position.viewportDimension, lessThan(700));
          final footer = find.widgetWithText(SeedButton, '닫기');
          final beforeFooter = tester.getRect(footer);
          final header = tester.getRect(find.text('상세 정보'));
          position.jumpTo(position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(position.pixels, closeTo(position.maxScrollExtent, .01));
          expect(tester.getRect(footer), beforeFooter);
          expect(tester.getRect(find.text('상세 정보')), header);
          expect(find.text('본문 79').hitTestable(), findsOneWidget);
          final endRow = tester.getRect(find.text('본문 79'));
          expect(endRow.bottom, lessThanOrEqualTo(beforeFooter.top));
          expect(tester.takeException(), isNull);
        });

        testWidgets('header and footer may be absent, body fills their space '
            '$width × $scale', (tester) async {
          await _mount(
            tester,
            size: Size(width, 700),
            textScale: scale,
            showHeader: false,
            showFooter: false,
            rows: 80,
          );
          final panel = find.byType(SeedSidePanel);
          final scroll = find.descendant(
            of: panel,
            matching: find.byType(Scrollable),
          );
          expect(scroll, findsOneWidget);
          final position = tester.state<ScrollableState>(scroll).position;
          expect(position.viewportDimension, closeTo(700, 1));
          expect(tester.getTopLeft(find.text('본문 0')).dy, closeTo(0, .5));
          expect(find.widgetWithText(SeedButton, '닫기'), findsNothing);
          position.jumpTo(position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(find.text('본문 79').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('short panel high text scale keeps body scrollable and '
        'does not overflow its footer', (tester) async {
      await _mount(
        tester,
        size: const Size(320, 520),
        textScale: 2,
        showHeader: true,
        showFooter: true,
        rows: 80,
      );
      final scroll = find.descendant(
        of: find.byType(SeedSidePanel),
        matching: find.byType(Scrollable),
      );
      expect(scroll, findsOneWidget);
      final position = tester.state<ScrollableState>(scroll).position;
      expect(position.viewportDimension, greaterThan(0));
      expect(
        tester.getRect(find.widgetWithText(SeedButton, '닫기')).bottom,
        lessThanOrEqualTo(520),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'side panel close calls back and can open with fresh body focus',
      (tester) async {
        var closes = 0;
        Future<void> mount() => _mount(
          tester,
          size: const Size(390, 700),
          textScale: 1,
          showHeader: true,
          showFooter: true,
          rows: 80,
          onClose: () => closes++,
        );
        await mount();
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(closes, 1);
        await mount();
        final scroll = find.descendant(
          of: find.byType(SeedSidePanel),
          matching: find.byType(Scrollable),
        );
        expect(tester.state<ScrollableState>(scroll).position.pixels, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'modal SidePanel closes and background field remains focusable',
      (tester) async {
        tester.view.physicalSize = const Size(390, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final focus = FocusNode();
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  TextField(focusNode: focus),
                  Builder(
                    builder: (context) => SeedButton(
                      label: '패널 열기',
                      onPressed: () => showSeedSidePanel<void>(
                        context: context,
                        title: '상세 정보',
                        body: const Text('읽을 수 있는 본문'),
                        footer: const Text('고정 푸터'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        expect(focus.hasFocus, isTrue);
        await tester.tap(find.widgetWithText(SeedButton, '패널 열기'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedSidePanel), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(find.byType(SeedSidePanel), findsNothing);
        // The button used to launch the modal may itself take focus on tap.
        // React does not promise restoration to a different TextField.
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        expect(focus.hasFocus, isTrue);
        await tester.tap(find.widgetWithText(SeedButton, '패널 열기'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedSidePanel), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
  group('accessible name', () {
    testWidgets(
      'SidePanel keeps an accessible name when the title is visually hidden',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: Scaffold(
                body: SeedSidePanel(
                  title: '',
                  semanticsLabel: 'Side Panel',
                  body: const Text('Content'),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.getSemantics(find.byType(SeedSidePanel)).label,
            'Side Panel',
          );
          expect(find.text('Side Panel'), findsNothing);
          expect(find.text('Content'), findsOneWidget);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'SidePanel derives the default accessible name from its visible title',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: SeedThemeData.light().toThemeData(),
              home: const Scaffold(
                body: SeedSidePanel(title: '설정', body: Text('Content')),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.getSemantics(find.byType(SeedSidePanel)).label, '설정');
          expect(find.text('설정'), findsOneWidget);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  });

  group('width cap on resize', () {
    setUpAll(loadSeedTestFonts);

    for (final size in [const Size(390, 844), const Size(800, 800)]) {
      for (final fromRight in [true, false]) {
        testWidgets(
          'SidePanel official 80vw cap and edge at $size right=$fromRight',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = size;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(
              MaterialApp(
                theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
                    .toThemeData(),
                home: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => showSeedSidePanel<void>(
                        context: context,
                        title: 'Side Panel',
                        body: const SizedBox(height: 50),
                        size: SeedSidePanelSize.medium,
                        fromRight: fromRight,
                      ),
                      child: const Text('Open panel'),
                    ),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('Open panel'));
            await tester.pumpAndSettle();
            final surface = find
                .descendant(
                  of: find.byType(SeedSidePanel),
                  matching: find.byType(Material),
                )
                .first;
            final rect = tester.getRect(surface);
            final cap = size.width * .8;
            expect(rect.width, closeTo(cap, 1));
            expect(rect.left, closeTo(fromRight ? size.width - cap : 0, 1));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('layout and route', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('side panel uses official default width and header geometry', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      for (final size in [const Size(390, 800), const Size(1400, 900)]) {
        await mount(
          tester,
          Align(
            alignment: Alignment.centerRight,
            child: SeedSidePanel(
              title: '상세 정보',
              body: const Text('본문'),
              onClose: () {},
            ),
          ),
          size: size,
        );
        final panel = tester.getRect(find.byType(SeedSidePanel));
        expect(panel.width, (size.width * 0.8).clamp(0, 720));
        expect(panel.right, size.width);
        final title = tester.getRect(find.text('상세 정보'));
        expect(title.top - panel.top, 24);
        expect(title.left - panel.left, 24);
        expect(tester.getTopLeft(find.text('본문')).dy, 70);
        final closeIcon = tester.getRect(find.byIcon(Icons.close));
        expect(closeIcon.size, const Size(22, 22));
        expect(closeIcon.top, 28);
        expect(panel.right - closeIcon.right, 24);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('side panel shows a divider only after scrolling its body', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      for (final dark in [false, true]) {
        await mount(
          tester,
          SeedSidePanel(
            key: ValueKey(dark),
            title: '상세 정보',
            body: Column(children: List.generate(40, (i) => Text('본문 $i'))),
            footer: const Text('고정 액션'),
            onClose: () {},
          ),
          dark: dark,
        );
        final divider = find.byKey(
          const ValueKey('seed-side-panel-scroll-divider'),
        );
        expect(
          (tester.widget<AnimatedContainer>(divider).decoration
                  as BoxDecoration)
              .color,
          Colors.transparent,
        );
        expect(tester.getSize(find.byType(SeedScrollFog)).height, 48);
        final footer = tester.getRect(find.text('고정 액션'));
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();
        expect(
          (tester.widget<AnimatedContainer>(divider).decoration
                  as BoxDecoration)
              .color,
          officialColor(r'$color.stroke.neutral-muted', dark: dark),
        );
        expect(tester.getRect(find.text('고정 액션')), footer);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'side panel routes slide by their own width and honor safe areas',
      (tester) async {
        addTearDown(tester.view.reset);
        const size = Size(1400, 900);
        const padding = EdgeInsets.fromLTRB(30, 20, 70, 24);
        for (final fromRight in [false, true]) {
          await mount(
            tester,
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showSeedSidePanel<void>(
                  context: context,
                  title: '안전 영역',
                  body: const Text('본문'),
                  fromRight: fromRight,
                ),
                child: const Text('Open'),
              ),
            ),
            size: size,
            padding: padding,
          );
          await tester.tap(find.text('Open'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          final panel = find.byType(SeedSidePanel);
          final slide = tester.widget<SlideTransition>(
            find.ancestor(of: panel, matching: find.byType(SlideTransition)),
          );
          final bounds = tester.getRect(panel);
          final edgeInset = fromRight ? padding.right : padding.left;
          expect(bounds.width, 720 + edgeInset);
          final restingLeft = fromRight ? size.width - bounds.width : 0;
          expect(
            bounds.left,
            closeTo(restingLeft + slide.position.value.dx * bounds.width, 0.01),
          );
          await tester.pumpAndSettle();
          final title = tester.getRect(find.text('안전 영역'));
          expect(title.top, 24 + padding.top);
          final close = tester.getRect(find.byIcon(Icons.close));
          expect(close.top, 28 + padding.top);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(panel, findsNothing);
          expect(tester.takeException(), isNull);
        }
      },
    );
  });

  group('desktop cap', () {
    testWidgets('desktop side panel caps its preferred width at 80%', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        host(const SeedSidePanel(title: 'Panel', width: 720, body: SizedBox())),
      );
      expect(tester.getSize(find.byType(SeedSidePanel)).width, 640);
    });
  });
}
