import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

const _label = '최신순 Medium';

TextStyle _style(FontWeight weight) =>
    TextStyle(fontFamily: seedTestFontFamily, fontSize: 16, fontWeight: weight);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double? width,
}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(800, 600),
      textScaler: TextScaler.linear(textScale),
    ),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: width == null ? child : SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

Future<Size> _plainSize(
  WidgetTester tester,
  FontWeight weight, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _host(
      Text(_label, key: const ValueKey('plain'), style: _style(weight)),
      textScale: textScale,
    ),
  );
  return tester.getSize(find.byKey(const ValueKey('plain')));
}

void main() {
  setUpAll(loadSeedTestFonts);

  for (final direction in TextDirection.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('reserves the bold width ($direction, textScale $scale)', (
        tester,
      ) async {
        final regular = await _plainSize(
          tester,
          FontWeight.w400,
          textScale: scale,
        );
        final bold = await _plainSize(
          tester,
          FontWeight.w700,
          textScale: scale,
        );
        final reserved = regular.width > bold.width
            ? regular.width
            : bold.width;

        final sizes = <FontWeight, Size>{};
        for (final weight in [FontWeight.w400, FontWeight.w700]) {
          await tester.pumpWidget(
            _host(
              SeedConsistentWidth(
                _label,
                key: const ValueKey('cw'),
                style: _style(weight),
              ),
              direction: direction,
              textScale: scale,
            ),
          );
          sizes[weight] = tester.getSize(find.byKey(const ValueKey('cw')));
        }
        expect(sizes[FontWeight.w400]!.width, closeTo(reserved, 0.01));
        expect(sizes[FontWeight.w700]!.width, closeTo(reserved, 0.01));
        // The height is the visible text's, not doubled by the copies.
        expect(sizes[FontWeight.w400]!.height, closeTo(regular.height, 0.01));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the bold copy is really wider in the test font', (tester) async {
    // Guards the test above against a font whose weights share advances.
    final regular = await _plainSize(tester, FontWeight.w400);
    final bold = await _plainSize(tester, FontWeight.w700);
    expect(bold.width, greaterThan(regular.width));
  });

  testWidgets('visible text starts at the reading start in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SeedConsistentWidth(
          _label,
          key: const ValueKey('cw'),
          style: _style(FontWeight.w400),
        ),
        direction: TextDirection.rtl,
      ),
    );
    final box = tester.getRect(find.byKey(const ValueKey('cw')));
    final visible = tester.getRect(
      find
          .descendant(
            of: find.byKey(const ValueKey('cw')),
            matching: find.text(_label),
          )
          .last,
    );
    expect(visible.right, closeTo(box.right, 0.01));
  });

  testWidgets('tight constraints: no overflow and ellipsis is preserved', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SeedConsistentWidth(
          _label,
          key: const ValueKey('cw'),
          style: _style(FontWeight.w400),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        width: 40,
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const ValueKey('cw'))).width, 40);
    final visible = tester.widget<Text>(
      find
          .descendant(
            of: find.byKey(const ValueKey('cw')),
            matching: find.byType(Text),
          )
          .last,
    );
    expect(visible.overflow, TextOverflow.ellipsis);
    expect(visible.maxLines, 1);
  });

  testWidgets('the text is announced once', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(SeedConsistentWidth(_label, style: _style(FontWeight.w700))),
    );
    expect(find.bySemanticsLabel(_label), findsOneWidget);
    expect(find.text(_label), findsNWidgets(3));
    handle.dispose();
  });
}
