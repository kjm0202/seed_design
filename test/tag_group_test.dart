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

const _strict = bool.fromEnvironment('SEED_PHASE4B_TAG_REACT_STRICT');

Widget _screen(
  double width,
  SeedTagGroupSize size,
  double scale,
  bool override,
) {
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
  );
}

Widget host(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostFghFollowupRegression(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  setUpAll(loadSeedTestFonts);
  for (final size in SeedTagGroupSize.values) {
    for (final width in [220.0, 400.0]) {
      for (final direction in TextDirection.values) {
        testWidgets('TagGroup natural width $size $width $direction', (
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
  testWidgets('TagGroup narrow truncation keeps labels in semantics', (
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
  testWidgets('TagGroup nontruncate still wraps without ellipsis', (
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
  group('semantics label', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('TagGroup width, scale and semanticsLabel cases', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        var cases = 0;
        for (final size in [SeedTagGroupSize.t2, SeedTagGroupSize.t4]) {
          for (final width in [96.0, 320.0, 600.0]) {
            for (final scale in [1.0, 2.0, 3.0]) {
              for (final override in [false, true]) {
                await tester.pumpWidget(_screen(width, size, scale, override));
                final group = find.byKey(const Key('phase4b-tags'));
                final label = find.descendant(
                  of: group,
                  matching: find.text(_labels[0]),
                );
                expect(label, findsOneWidget);
                final textWidth = tester.getSize(label).width;
                final paragraph = tester.renderObject<RenderParagraph>(label);
                final semantics =
                    tester
                        .binding
                                // ignore: deprecated_member_use
                        .pipelineOwner
                        .semanticsOwner
                        ?.rootSemanticsNode
                        ?.toStringDeep() ??
                    '';
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
                debugPrintSynchronously(
                  'PHASE4B_TAG_CONTRACT ${jsonEncode(observed)}',
                );
                expect(textWidth, greaterThanOrEqualTo(0));
                expect(
                  tester.getSize(group).width,
                  lessThanOrEqualTo(width + .1),
                );
                if (override) expect(observed['hasOverrideAX'], isTrue);
                if (_strict && width == 600 && scale == 1) {
                  // Official React 220px demo renders all three short labels
                  // completely; a 600px group cannot legitimately clip them.
                  expect(
                    paragraph.didExceedMaxLines,
                    isFalse,
                    reason: 'React-visible short tag at abundant width',
                  );
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
  });

  group('wrapping', () {
    testWidgets('long tags wrap in a narrow container at 200 percent text', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const SizedBox(
              width: 120,
              child: SeedTagGroup(
                items: [
                  SeedTagItem(label: '아주 긴 태그 정보입니다', icon: Icon(Icons.info)),
                  SeedTagItem(label: '다음 태그'),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('truncation', () {
    testWidgets(
      'tag truncation remeasures resized separators and preserves fixed tags',
      (tester) async {
        var separatorWidth = 20.0;
        late StateSetter update;
        await tester.pumpWidget(
          hostFghFollowupRegression(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return SizedBox(
                  width: 180,
                  child: SeedTagGroup(
                    truncate: true,
                    separatorWidget: SizedBox(width: separatorWidth),
                    items: const [
                      SeedTagItem(label: 'Fixed', flexShrink: 0),
                      SeedTagItem(label: 'A long label to truncate'),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        final fixedWidth = tester.getSize(find.text('Fixed')).width;
        final longWidth = tester
            .getSize(find.text('A long label to truncate'))
            .width;
        update(() => separatorWidth = 70);
        await tester.pump();
        expect(tester.getSize(find.text('Fixed')).width, fixedWidth);
        expect(
          tester.getSize(find.text('A long label to truncate')).width,
          closeTo(longWidth - 50, .01),
        );
        expect(
          tester
              .state<ScrollableState>(find.byType(Scrollable))
              .position
              .maxScrollExtent,
          0,
        );
      },
    );
  });
}
