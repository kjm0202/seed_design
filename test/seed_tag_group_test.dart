import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

const _labels = ['광고', '끌올 3시간 전', '서초4동'];

Widget _host({
  required double width,
  SeedTagGroupSize size = SeedTagGroupSize.t2,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
  bool truncate = true,
  String? semanticsLabel,
}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Directionality(
        textDirection: direction,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: SeedTagGroup(
              size: size,
              truncate: truncate,
              items: [
                SeedTagItem(
                  label: _labels[0],
                  suffix: const Icon(Icons.campaign),
                  semanticsLabel: semanticsLabel,
                ),
                SeedTagItem(label: _labels[1]),
                SeedTagItem(
                  label: _labels[2],
                  icon: const Icon(Icons.location_on),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  setUpAll(loadSeedTestFonts);
  for (final size in SeedTagGroupSize.values) {
    for (final width in [220.0, 400.0]) {
      for (final direction in TextDirection.values) {
        testWidgets('PACKAGE-07 natural width $size $width $direction', (
          tester,
        ) async {
          await tester.pumpWidget(
            _host(width: width, size: size, direction: direction),
          );
          for (final label in _labels) {
            expect(
              tester
                  .renderObject<RenderParagraph>(find.text(label))
                  .didExceedMaxLines,
              isFalse,
              reason:
                  'The complete label fits inside the available group width.',
            );
          }
          expect(
            tester.getSize(find.byType(SeedTagGroup)).width,
            lessThanOrEqualTo(width),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('PACKAGE-07 narrow truncation keeps labels in semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          _host(width: 90, scale: 2, direction: direction),
        );
        expect(
          tester.getSize(find.byType(SeedTagGroup)).width,
          lessThanOrEqualTo(90),
        );
        expect(
          _labels.any(
            (label) => tester
                .renderObject<RenderParagraph>(find.text(label))
                .didExceedMaxLines,
          ),
          isTrue,
          reason: 'Insufficient width still legitimately truncates.',
        );
        // Inspect the emitted tree: a zero-width RenderParagraph may still
        // have a local semantics node that is absent from this accessible tree.
        // The test binding exposes the pumped render view's semantics under
        // pipelineOwner; rootPipelineOwner owns no active semantics tree here.
        // Keep this actual accessibility-tree assertion instead of replacing
        // it with a detached, always-empty root.
        final tree =
            // ignore: deprecated_member_use
            tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode
                ?.toStringDeep() ??
            '';
        for (final label in _labels) {
          expect(tree, contains(label));
        }
        expect(find.bySemanticsLabel('·'), findsNothing);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(
        _host(width: 90, scale: 2, semanticsLabel: '광고 메타데이터'),
      );
      expect(find.bySemanticsLabel('광고 메타데이터'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });
  testWidgets('PACKAGE-07 nontruncate still wraps without ellipsis', (
    tester,
  ) async {
    await tester.pumpWidget(_host(width: 90, scale: 2, truncate: false));
    for (final label in _labels) {
      expect(
        tester
            .renderObject<RenderParagraph>(find.text(label))
            .didExceedMaxLines,
        isFalse,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
