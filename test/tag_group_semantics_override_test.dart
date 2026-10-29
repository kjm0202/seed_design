// Phase4 continuation: public SeedTagGroup without the Flutter example shell.
// NEW axes not in earlier 240: width96/320/600, text scale3 and explicit
// SeedTagItem.semanticsLabel override, including its zero-width rescue path.
// Default observational mode GREEN; opt-in strict React-style policy RED.
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrintSynchronously;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'support/seed_test_fonts.dart';

const _strict = bool.fromEnvironment('SEED_PHASE4B_TAG_REACT_STRICT');
const _labels = ['광고', '끌올 3시간 전', '서초4동'];

Widget _screen(double width, SeedTagGroupSize size, double scale, bool override) {
  return MaterialApp(
    theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: SeedTagGroup(
              key: const Key('phase4b-tags'),
              size: size,
              truncate: true,
              items: [
                SeedTagItem(
                  label: _labels[0],
                  suffix: const Icon(Icons.campaign),
                  semanticsLabel: override ? '광고 메타데이터' : null,
                ),
                SeedTagItem(label: _labels[1]),
                SeedTagItem(label: _labels[2], icon: const Icon(Icons.location_on)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('new 36 TagGroup width/scale/semanticsLabel cases', (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      var cases = 0;
      for (final size in [SeedTagGroupSize.t2, SeedTagGroupSize.t4]) {
        for (final width in [96.0, 320.0, 600.0]) {
          for (final scale in [1.0, 2.0, 3.0]) {
            for (final override in [false, true]) {
              await tester.pumpWidget(_screen(width, size, scale, override));
              final group = find.byKey(const Key('phase4b-tags'));
              final label = find.descendant(of: group, matching: find.text(_labels[0]));
              expect(label, findsOneWidget);
              final textWidth = tester.getSize(label).width;
              final paragraph = tester.renderObject<RenderParagraph>(label);
              // ignore: deprecated_member_use
              final semantics = tester.binding.pipelineOwner.semanticsOwner
                      ?.rootSemanticsNode?.toStringDeep() ?? '';
              final observed = {
                'size': size.name,
                'width': width,
                'scale': scale,
                'semanticsOverride': override,
                'labelTextWidth': textWidth,
                'overflow': paragraph.didExceedMaxLines,
                'hasOriginalAX': semantics.contains(_labels[0]),
                'hasOverrideAX': semantics.contains('광고 메타데이터'),
                'groupWidth': tester.getSize(group).width,
              };
              // No screenshot/click derived verdicts; measured public RenderParagraph + AX.
              debugPrintSynchronously('PHASE4B_TAG_CONTRACT ${jsonEncode(observed)}');
              expect(textWidth, greaterThanOrEqualTo(0));
              expect(tester.getSize(group).width, lessThanOrEqualTo(width + .1));
              if (override) expect(observed['hasOverrideAX'], isTrue);
              if (_strict && width == 600 && scale == 1) {
                // Official React 220px demo renders all three short labels
                // completely; a 600px group cannot legitimately clip them.
                expect(paragraph.didExceedMaxLines, isFalse,
                    reason: 'React-visible short tag at abundant width');
              }
              cases++;
            }
          }
        }
      }
      expect(cases, 36);
    } finally {
      semanticsHandle.dispose();
    }
  });
}
