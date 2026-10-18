import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  final spec = jsonDecode(
    File('test/fixtures/seed_reference.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  test('button dimensions match the pinned official reference', () {
    for (final size in SeedButtonSize.values) {
      final expected = spec['buttons'][size.name] as Map<String, dynamic>;
      expect(size.height, expected['minHeight'], reason: size.name);
      expect(size.padding.left, expected['paddingX'], reason: size.name);
      expect(size.padding.top, expected['paddingY'], reason: size.name);
      if (size != SeedButtonSize.xsmall) {
        expect(
          size.borderRadius.topLeft.x,
          expected['radius'],
          reason: size.name,
        );
      }
    }
  });
  testWidgets('rendered button labels use the official size for each variant', (
    tester,
  ) async {
    for (final size in SeedButtonSize.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: Center(
              child: SeedButton(label: '확인', size: size, onPressed: () {}),
            ),
          ),
        ),
      );
      final expected = spec['buttons'][size.name] as Map<String, dynamic>;
      expect(
        tester.widget<Text>(find.text('확인')).style!.fontSize,
        expected['fontSize'],
      );
    }
  });
  test(
    'semantic typography and corrected palette match the official reference',
    () {
      final typography = SeedTypography.base();
      for (final entry in {
        'screenTitle': typography.screenTitle,
        'articleBody': typography.articleBody,
      }.entries) {
        final expected = spec['typography'][entry.key] as Map<String, dynamic>;
        expect(entry.value.fontSize, expected['fontSize']);
        expect(
          entry.value.height! * entry.value.fontSize!,
          expected['lineHeight'],
        );
      }
      expect(
        SeedPalette.red800Dark.toARGB32(),
        int.parse(spec['palette']['red800Dark'] as String, radix: 16),
      );
    },
  );
}
