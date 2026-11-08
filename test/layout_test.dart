import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget _appFlow(Widget child, {bool scaffold = true}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: scaffold ? Scaffold(body: Center(child: child)) : Center(child: child),
);

Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

Widget hostComponentBehaviorRegress(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('layout API', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('Footer has no default copyright and uses link text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SeedFooter(
            policyLinks: [SeedFooterLink(label: 'Terms', uri: null)],
          ),
        ),
      );
      expect(find.textContaining('Danggeun'), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(SeedFooterLinkText), findsOneWidget);
    });
    testWidgets('AspectRatio defaults to 4 / 3', (tester) async {
      await tester.pumpWidget(
        _app(const SizedBox(width: 400, child: SeedAspectRatio())),
      );
      expect(tester.getSize(find.byType(SeedAspectRatio)).height, 300);
    });

    testWidgets('LayoutContent follows official density widths', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1;
      Future<double> widthAt(double viewport, SeedLayoutDensity density) async {
        tester.view.physicalSize = Size(viewport, 800);
        await tester.pumpWidget(
          _app(
            SeedLayoutContent(
              density: density,
              child: const SizedBox(key: Key('c'), width: 5000, height: 1),
            ),
          ),
        );
        return tester.getSize(find.byKey(const Key('c'))).width;
      }

      expect(await widthAt(500, SeedLayoutDensity.medium), 500);
      expect(await widthAt(800, SeedLayoutDensity.medium), 720);
      expect(await widthAt(1300, SeedLayoutDensity.medium), 1040);
      expect(await widthAt(1300, SeedLayoutDensity.low), 720);
      expect(await widthAt(1300, SeedLayoutDensity.high), 1300);
    });

    testWidgets('GridItem takes official one-based lines and full span', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 300,
            child: SeedGrid(
              columns: 3,
              children: [
                SeedGridItem(
                  colStart: 2,
                  colEnd: 4,
                  child: SizedBox(key: Key('lines'), height: 10),
                ),
                SeedGridItem(
                  colSpan: SeedGridItem.full,
                  child: SizedBox(key: Key('full'), height: 10),
                ),
              ],
            ),
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(SeedGrid)).dx;
      expect(
        tester.getTopLeft(find.byKey(const Key('lines'))).dx - origin,
        100,
      );
      expect(tester.getSize(find.byKey(const Key('lines'))).width, 200);
      expect(tester.getSize(find.byKey(const Key('full'))).width, 300);
    });

    testWidgets('ScrollFogMask masks its child without a surface color', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SeedScrollFogMask(
            placement: {SeedScrollFogPlacement.bottom},
            sizes: {SeedScrollFogPlacement.bottom: 40},
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      expect(
        tester.widget<ShaderMask>(find.byType(ShaderMask)).blendMode,
        BlendMode.dstIn,
      );
    });
  });

  group('Grid, ResponsivePair and Flex', () {
    setUpAll(loadSeedTestFonts);
    Widget cell(String label, {int span = 1}) => SeedGridItem(
      columnSpan: span,
      child: SizedBox(height: 20, child: Text(label)),
    );

    Future<Offset Function(String)> grid(
      WidgetTester tester,
      SeedGrid child,
    ) async {
      await tester.pumpWidget(_appFlow(SizedBox(width: 300, child: child)));
      return (label) =>
          tester.getTopLeft(find.text(label)) -
          tester.getTopLeft(find.byType(SeedGrid));
    }

    testWidgets('Grid auto-placement does not go back to fill holes', (
      tester,
    ) async {
      final at = await grid(
        tester,
        SeedGrid(
          columns: 3,
          children: [cell('A'), cell('B', span: 3), cell('C')],
        ),
      );
      expect(at('A'), Offset.zero);
      expect(at('B'), const Offset(0, 20));
      expect(at('C'), const Offset(0, 40));
    });

    testWidgets('Grid keeps auto items flowing after explicit items', (
      tester,
    ) async {
      final at = await grid(
        tester,
        SeedGrid(
          columns: 2,
          children: [
            cell('A'),
            const SeedGridItem(
              row: 0,
              column: 0,
              child: SizedBox(height: 20, child: Text('X')),
            ),
            cell('B'),
          ],
        ),
      );
      expect(at('X'), Offset.zero);
      expect(at('A'), const Offset(150, 0));
      expect(at('B'), const Offset(0, 20));
    });

    testWidgets('Grid with only rows in row flow uses one column', (
      tester,
    ) async {
      final at = await grid(
        tester,
        SeedGrid(
          rows: 2,
          children: [cell('A'), cell('B'), cell('C'), cell('D')],
        ),
      );
      expect(at('A'), Offset.zero);
      expect(at('B'), const Offset(0, 20));
      expect(at('D'), const Offset(0, 60));
    });

    testWidgets('Grid column flow fills rows first', (tester) async {
      final at = await grid(
        tester,
        SeedGrid(
          rows: 2,
          autoFlow: Axis.vertical,
          children: [cell('A'), cell('B'), cell('C'), cell('D')],
        ),
      );
      expect(at('B'), const Offset(0, 20));
      expect(at('C'), const Offset(150, 0));
      expect(at('D'), const Offset(150, 20));
    });

    testWidgets('Grid column flow keeps an item on its given row', (
      tester,
    ) async {
      final at = await grid(
        tester,
        SeedGrid(
          rows: 2,
          autoFlow: Axis.vertical,
          children: [
            cell('A'),
            const SeedGridItem(
              row: 0,
              child: SizedBox(height: 20, child: Text('B')),
            ),
            cell('C'),
          ],
        ),
      );
      expect(at('A'), Offset.zero);
      expect(at('B'), const Offset(150, 0));
      expect(at('C'), const Offset(150, 20));
    });

    testWidgets('ResponsivePair shares the row equally', (tester) async {
      await tester.pumpWidget(
        _appFlow(
          SizedBox(
            width: 300,
            child: SeedResponsivePair(
              children: [
                SeedButton(label: 'A', onPressed: () {}),
                SeedButton(label: 'B', onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      final first = tester.getRect(find.byType(SeedButton).first);
      final second = tester.getRect(find.byType(SeedButton).last);
      expect(first.width, 146);
      expect(second.width, 146);
      expect(second.left - first.right, 8);
    });

    testWidgets('ResponsivePair stacks in reverse at full width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appFlow(
          SizedBox(
            width: 200,
            child: SeedResponsivePair(
              children: [
                SeedButton(label: 'A long first label', onPressed: () {}),
                SeedButton(label: 'B', onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      final first = tester.getRect(find.byType(SeedButton).first);
      final second = tester.getRect(find.byType(SeedButton).last);
      expect(first.top, greaterThan(second.top));
      expect(first.width, 200);
      expect(second.width, 200);
    });

    testWidgets('SeedFlex applies its alignment when wrapping', (tester) async {
      await tester.pumpWidget(
        _appFlow(
          const SizedBox(
            width: 300,
            child: SeedFlex(
              wrap: true,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [SizedBox(key: ValueKey('box'), width: 50, height: 50)],
            ),
          ),
        ),
      );
      expect(
        tester.getTopRight(find.byKey(const ValueKey('box'))).dx,
        tester.getTopRight(find.byType(SeedFlex)).dx,
      );
    });
  });
  group('grid RTL', () {
    testWidgets(
      'grid spans and intrinsic rows place children without overlaps in RTL',
      (tester) async {
        await tester.pumpWidget(
          host(
            Directionality(
              textDirection: TextDirection.rtl,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 320,
                  child: SeedGrid(
                    columns: 3,
                    gap: 10,
                    children: const [
                      SeedGridItem(
                        columnSpan: 2,
                        child: SizedBox(key: ValueKey('wide'), height: 30),
                      ),
                      SizedBox(key: ValueKey('short'), height: 50),
                      SeedGridItem(
                        columnSpan: 3,
                        child: SizedBox(key: ValueKey('full'), height: 40),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.getSize(find.byKey(const ValueKey('wide'))).width, 210);
        expect(tester.getSize(find.byKey(const ValueKey('wide'))).height, 50);
        expect(tester.getTopLeft(find.byKey(const ValueKey('wide'))).dx, 110);
        expect(tester.getTopLeft(find.byKey(const ValueKey('full'))).dy, 60);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('footer', () {
    testWidgets('footer fits a phone with long branding and social links', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        hostComponentBehaviorRegress(
          SeedFooter(
            brandName: 'A long service brand name',
            sitemapColumns: const [
              SeedFooterColumn(title: 'Company', links: []),
            ],
            socialLinks: List.generate(
              5,
              (_) => const SizedBox(width: 48, height: 48),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('ImageFrame', () {
    testWidgets(
      'SeedImageFrame renders fallback placeholder when image is absent',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: const Scaffold(body: SeedImageFrame(badge: '대표사진')),
          ),
        );

        expect(find.text('대표사진'), findsOneWidget);
        expect(find.byType(SeedContentPlaceholder), findsOneWidget);
      },
    );
  });
}
