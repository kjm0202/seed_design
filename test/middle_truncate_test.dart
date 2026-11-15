import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

const _style = TextStyle(fontSize: 14, height: 1.4);

String _shown(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text)).data!;

Widget _at(double width, Widget child) =>
    fontApp(SizedBox(width: width, child: child));

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('text that fits is unchanged and reported as not truncated', (
    tester,
  ) async {
    final reports = <bool>[];
    await tester.pumpWidget(
      _at(
        400,
        SeedMiddleTruncate('short.pdf', style: _style, onTruncate: reports.add),
      ),
    );
    await tester.pump();
    expect(_shown(tester), 'short.pdf');
    expect(reports, [false]);
  });

  testWidgets('long text keeps its start and the last end characters', (
    tester,
  ) async {
    const name = 'quarterly-business-review-final-version-2026.pdf';
    final reports = <bool>[];
    await tester.pumpWidget(
      _at(
        160,
        SeedMiddleTruncate(
          name,
          end: 4,
          style: _style,
          onTruncate: reports.add,
        ),
      ),
    );
    await tester.pump();
    final shown = _shown(tester);
    expect(shown, contains('…'));
    expect(shown, endsWith('….pdf'));
    expect(name.startsWith(shown.substring(0, shown.indexOf('…'))), isTrue);
    expect(shown.length, lessThan(name.length));
    expect(reports, [true]);
    // Fits on the single line it is allowed.
    final paragraph = tester.renderObject<RenderParagraph>(
      find.byType(RichText),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
    // The full text is still spoken.
    expect(find.bySemanticsLabel(name), findsOneWidget);
  });

  testWidgets('the longest start that fits is kept', (tester) async {
    const name = 'abcdefghijklmnopqrstuvwxyz.txt';
    await tester.pumpWidget(
      _at(120, const SeedMiddleTruncate(name, end: 4, style: _style)),
    );
    final shown = _shown(tester);
    final start = shown.substring(0, shown.indexOf('…'));
    // One more start character would overflow, measured with the style the
    // widget actually painted.
    final paragraph = tester.renderObject<RenderParagraph>(
      find.byType(RichText),
    );
    final painter = TextPainter(
      text: TextSpan(
        text: '${name.substring(0, start.length + 1)}….txt',
        style: paragraph.text.style,
      ),
      textDirection: TextDirection.ltr,
      textScaler: paragraph.textScaler,
      maxLines: 1,
    )..layout(maxWidth: 120);
    expect(painter.didExceedMaxLines, isTrue);
    painter.dispose();
  });

  testWidgets('maxLines lets the text use more lines before shortening', (
    tester,
  ) async {
    const name = 'quarterly-business-review-final-version-2026.pdf';
    await tester.pumpWidget(
      _at(160, const SeedMiddleTruncate(name, end: 4, style: _style)),
    );
    final oneLine = _shown(tester);
    await tester.pumpWidget(
      _at(
        160,
        const SeedMiddleTruncate(name, end: 4, maxLines: 2, style: _style),
      ),
    );
    final twoLines = _shown(tester);
    expect(twoLines.length, greaterThan(oneLine.length));
    expect(twoLines, endsWith('.pdf'));
  });

  testWidgets('a kept end that alone overflows is shortened from its start', (
    tester,
  ) async {
    await tester.pumpWidget(
      _at(
        40,
        const SeedMiddleTruncate(
          'name.verylongextension',
          end: 18,
          style: _style,
        ),
      ),
    );
    final shown = _shown(tester);
    expect(shown, startsWith('…'));
    expect('.verylongextension'.endsWith(shown.substring(1)), isTrue);
  });

  testWidgets('refits when the width grows and reports the change', (
    tester,
  ) async {
    const name = 'quarterly-business-review.pdf';
    final reports = <bool>[];
    Widget at(double width) => _at(
      width,
      SeedMiddleTruncate(name, end: 4, style: _style, onTruncate: reports.add),
    );
    await tester.pumpWidget(at(100));
    await tester.pump();
    expect(_shown(tester), contains('…'));
    await tester.pumpWidget(at(600));
    await tester.pump();
    expect(_shown(tester), name);
    expect(reports, [true, false]);
  });

  testWidgets('emoji and Hangul are not split', (tester) async {
    const name = '가나다라마바사아자차카타파하👨‍👩‍👧‍👦가나다라마바사.png';
    await tester.pumpWidget(
      _at(120, const SeedMiddleTruncate(name, end: 4, style: _style)),
    );
    final shown = _shown(tester).characters;
    for (final character in shown) {
      expect(
        name.characters.contains(character) || character == '…',
        isTrue,
        reason: character,
      );
    }
  });

  testWidgets('attachment names keep their extension over two lines', (
    tester,
  ) async {
    const name = 'a-very-long-attachment-file-name-for-the-report.pdf';
    await tester.pumpWidget(
      koreanAppCentered(
        const SeedAttachmentInput(
          items: [
            SeedAttachmentItem(
              id: '1',
              name: name,
              type: SeedAttachmentType.file,
            ),
          ],
        ),
      ),
    );
    final truncate = tester.widget<SeedMiddleTruncate>(
      find.byType(SeedMiddleTruncate),
    );
    expect(truncate.text, name);
    expect(truncate.end, 4);
    expect(truncate.maxLines, 2);
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byType(SeedMiddleTruncate),
              matching: find.byType(Text),
            ),
          )
          .data,
      endsWith('….pdf'),
    );
  });
}
