import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/semantics.dart' show SemanticsValidationResult;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

// Consumer-level behavior tests for SeedSegmentedTextInput, mirroring the
// official headless `SegmentedTextInput.test.tsx`. Soft-keyboard input is
// simulated with `testTextInput.updateEditingValue`, the path Android and
// iOS keyboards use, and not only with hardware key events.

Widget _app(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double width = 343,
}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Directionality(
          textDirection: direction,
          child: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  ),
);

Widget _resident({
  List<String>? value,
  List<String> defaultValue = const [],
  ValueChanged<List<String>>? onValueChange,
  bool readOnly = false,
}) => SeedSegmentedTextInput(
  semanticsLabel: '주민등록번호',
  value: value,
  defaultValue: defaultValue,
  onValueChange: onValueChange,
  readOnly: readOnly,
  children: const [
    SeedSegmentedTextInputSegment(
      semanticsLabel: '앞 6자리',
      length: 6,
      autofillHints: [AutofillHints.birthday],
      placeholder: '생년월일 6자리',
      sizing: SeedSegmentedTextInputSizing.fill,
    ),
    SeedSegmentedTextInputSeparator(child: Text(' - ')),
    SeedSegmentedTextInputSegment(
      semanticsLabel: '뒤 첫 번째 자리',
      length: 1,
      placeholderWidget: SeedSegmentedTextInputDots(count: 1),
      staticSuffix: SeedSegmentedTextInputDots(count: 6),
      sizing: SeedSegmentedTextInputSizing.fill,
      align: SeedSegmentedTextInputAlign.center,
    ),
  ],
);

Widget _card({
  List<String> defaultValue = const [],
  ValueChanged<List<String>>? onValueChange,
}) => SeedSegmentedTextInput(
  semanticsLabel: '카드번호',
  defaultValue: defaultValue,
  onValueChange: onValueChange,
  children: [
    for (var i = 0; i < 4; i++) ...[
      if (i > 0) const SeedSegmentedTextInputSeparator(child: Text(' - ')),
      SeedSegmentedTextInputSegment(
        semanticsLabel: '${i + 1}',
        length: 4,
        masked: i >= 2,
        placeholder: i >= 2 ? null : '0000',
        autofillHints: i == 0
            ? const [AutofillHints.creditCardNumber]
            : const <String>[],
      ),
    ],
    const SeedSegmentedTextInputSuffix(child: Icon(Icons.credit_card)),
  ],
);

Finder _segment(int index) => find.byType(EditableText).at(index);

List<EditableTextState> _states(WidgetTester tester) =>
    tester.stateList<EditableTextState>(find.byType(EditableText)).toList();

/// Index of the focused segment, or -1.
int _focusedIndex(WidgetTester tester) =>
    _states(tester).indexWhere((s) => s.widget.focusNode.hasFocus);

/// Text shown by a segment; empty segments hold a zero-width placeholder.
String _shown(WidgetTester tester, int index) => tester
    .widget<EditableText>(_segment(index))
    .controller
    .text
    .replaceAll('​', '');

TextEditingValue _editing(WidgetTester tester) =>
    _states(tester)[_focusedIndex(tester)].textEditingValue;

/// Types [text] one character at a time like a soft keyboard.
Future<void> _type(WidgetTester tester, String text) async {
  for (final char in text.split('')) {
    final value = _editing(tester);
    final sel = value.selection;
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: value.text.replaceRange(sel.start, sel.end, char),
        selection: TextSelection.collapsed(offset: sel.start + 1),
      ),
    );
    await tester.pump();
  }
}

/// Inserts [text] at once (IME clipboard paste, keyboard suggestion).
Future<void> _insert(WidgetTester tester, String text) async {
  final value = _editing(tester);
  final sel = value.selection;
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: value.text.replaceRange(sel.start, sel.end, text),
      selection: TextSelection.collapsed(offset: sel.start + text.length),
    ),
  );
  await tester.pump();
}

/// Soft-keyboard Backspace: deletes the character before the caret of the
/// current editing state, as an IME `deleteSurroundingText` does.
Future<void> _softBackspace(WidgetTester tester) async {
  final value = _editing(tester);
  final sel = value.selection;
  if (sel.isCollapsed && sel.start == 0) return; // IME has nothing to delete
  final start = sel.isCollapsed ? sel.start - 1 : sel.start;
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: value.text.replaceRange(start, sel.end, ''),
      selection: TextSelection.collapsed(offset: start),
    ),
  );
  await tester.pump();
}

Future<void> _focus(WidgetTester tester, int index) async {
  await tester.showKeyboard(_segment(index));
  await tester.pump();
}

void _setCaret(WidgetTester tester, int index, int base, [int? extent]) {
  tester.widget<EditableText>(_segment(index)).controller.selection =
      TextSelection(baseOffset: base, extentOffset: extent ?? base);
}

void _mockClipboard(WidgetTester tester, String text) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.getData') return {'text': text};
      if (call.method == 'Clipboard.hasStrings') return {'value': true};
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}

Future<void> _keyboardPaste(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadSeedTestFonts);

  // The Seed Material theme styles TextField with an outlined border. Segments
  // sit inside the group's own frame and must not draw a second one.
  testWidgets('segments draw no Material input border of their own', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_card()));
    final decorators = find.byType(InputDecorator);
    expect(decorators, findsWidgets);
    for (final element in decorators.evaluate()) {
      expect(find.byWidget(element.widget), isNot(paints..rrect()));
    }

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    for (final element in decorators.evaluate()) {
      expect(find.byWidget(element.widget), isNot(paints..rrect()));
    }
  });

  testWidgets('renders a group whose values follow segment order', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(_resident(defaultValue: ['931205', '1'])));

    expect(find.bySemanticsLabel('주민등록번호'), findsOneWidget);
    expect(find.bySemanticsLabel('앞 6자리'), findsOneWidget);
    expect(find.bySemanticsLabel('뒤 첫 번째 자리'), findsOneWidget);
    expect(_shown(tester, 0), '931205');
    expect(_shown(tester, 1), '1');
    // Separators and static dots are hidden from assistive technologies.
    expect(find.bySemanticsLabel(' - '), findsNothing);
    final first = tester.widget<EditableText>(_segment(0));
    expect(first.keyboardType, TextInputType.number);
    expect(first.autofillHints, [AutofillHints.birthday]);
    handle.dispose();
  });

  testWidgets('typing fills a segment and moves to the next at its end', (
    tester,
  ) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(_app(_resident(onValueChange: changes.add)));

    await _focus(tester, 0);
    await _type(tester, '9312051');

    expect(changes.last, ['931205', '1']);
    expect(_focusedIndex(tester), 1);
    expect(() => changes.last.add('x'), throwsUnsupportedError);
  });

  testWidgets('drops non-digit characters', (tester) async {
    await tester.pumpWidget(_app(_resident()));
    await _focus(tester, 0);
    await _type(tester, '9a3-1');
    expect(_shown(tester, 0), '931');
  });

  testWidgets('rejects an insertion in the middle of a full segment', (
    tester,
  ) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(_resident(defaultValue: ['931205', ''], onValueChange: changes.add)),
    );
    await _focus(tester, 0);
    _setCaret(tester, 0, 2);
    await _type(tester, '0');

    expect(_shown(tester, 0), '931205');
    expect(_focusedIndex(tester), 0);
    expect(changes, isEmpty);
  });

  testWidgets('soft-keyboard Backspace in an empty segment deletes the '
      "previous segment's last character", (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(_resident(defaultValue: ['931205', ''], onValueChange: changes.add)),
    );
    await _focus(tester, 1);
    await _softBackspace(tester);
    await tester.pump();

    expect(changes.single, ['93120', '']);
    expect(_shown(tester, 0), '93120');
    expect(_focusedIndex(tester), 0);

    // Keeps deleting from the previous segment's end.
    await _softBackspace(tester);
    expect(_shown(tester, 0), '9312');
  });

  testWidgets('hardware Backspace in an empty segment behaves the same', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_resident(defaultValue: ['931205', ''])));
    await _focus(tester, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(_shown(tester, 0), '93120');
    expect(_focusedIndex(tester), 0);
  });

  testWidgets('stays in the segment when Backspace empties it', (tester) async {
    await tester.pumpWidget(_app(_resident(defaultValue: ['931205', '1'])));
    await _focus(tester, 1);
    _setCaret(tester, 1, 1);
    await _softBackspace(tester);
    await tester.pump();

    expect(_shown(tester, 1), '');
    expect(_focusedIndex(tester), 1);
    expect(_shown(tester, 0), '931205');
  });

  testWidgets('moves between segments with arrow keys at the edges', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_resident(defaultValue: ['931205', ''])));
    await _focus(tester, 0);
    _setCaret(tester, 0, 3);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedIndex(tester), 0, reason: 'caret not at the edge yet');

    _setCaret(tester, 0, 6);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedIndex(tester), 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(_focusedIndex(tester), 0);
    expect(_editing(tester).selection.baseOffset, 6);
  });

  testWidgets('mirrors arrow keys in RTL', (tester) async {
    await tester.pumpWidget(
      _app(
        _resident(defaultValue: ['931205', '']),
        direction: TextDirection.rtl,
      ),
    );
    // The first segment is laid out on the right.
    expect(
      tester.getCenter(_segment(0)).dx,
      greaterThan(tester.getCenter(_segment(1)).dx),
    );
    await _focus(tester, 0);
    _setCaret(tester, 0, 6);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(_focusedIndex(tester), 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedIndex(tester), 0);
  });

  testWidgets('card number: masked segments paint dots, keep the caret at '
      'the end and move to neighbors with arrow keys', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(_card(defaultValue: ['1234', '5678', '12', ''])),
    );

    final third = tester.widget<EditableText>(_segment(2));
    expect(third.obscureText, isTrue);
    expect(third.autofillHints, isNull, reason: 'masked defaults to off');
    expect(tester.widget<EditableText>(_segment(1)).obscureText, isFalse);
    // 4 dots per masked segment, none for the visible segments.
    final dots = find.descendant(
      of: find.byType(SeedSegmentedTextInput),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 7 &&
            w.constraints?.maxHeight == 7,
      ),
    );
    expect(dots, findsNWidgets(8));

    await _focus(tester, 2);
    _setCaret(tester, 2, 0);
    await tester.pump();
    expect(
      _editing(tester).selection,
      const TextSelection.collapsed(offset: 2),
    );

    // Selecting everything stays possible so it can be replaced.
    _setCaret(tester, 2, 0, 2);
    await tester.pump();
    expect(_editing(tester).selection.start, 0);
    expect(_editing(tester).selection.end, 2);
    _setCaret(tester, 2, 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedIndex(tester), 3);

    await _focus(tester, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(_focusedIndex(tester), 1);

    // Each segment is its own labelled, obscured text field node.
    final node = tester.getSemantics(_segment(2));
    expect(node.label, contains('3'));
    expect(node.flagsCollection.isObscured, isTrue);
    handle.dispose();
  });

  testWidgets('entering a filled masked segment keeps its caret at the end', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_card(defaultValue: ['1234', '5678', '12', ''])),
    );
    await _focus(tester, 1);
    _setCaret(tester, 1, 4);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(_focusedIndex(tester), 2);
    expect(
      _editing(tester).selection,
      const TextSelection.collapsed(offset: 2),
    );
    await _type(tester, '3');
    expect(_shown(tester, 2), '123');
  });

  testWidgets('soft-keyboard deletion crosses into a masked segment', (
    tester,
  ) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(
        _card(
          defaultValue: ['1234', '5678', '12', ''],
          onValueChange: changes.add,
        ),
      ),
    );
    await _focus(tester, 3);
    await _softBackspace(tester);
    await tester.pump();
    expect(changes.single, ['1234', '5678', '1', '']);
    expect(_focusedIndex(tester), 2);
  });

  testWidgets('a multi-character insertion distributes a resident number '
      'with one change', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(_app(_resident(onValueChange: changes.add)));
    await _focus(tester, 0);
    await _insert(tester, '931205-1234567');
    await tester.pump();

    expect(changes, [
      ['931205', '1'],
    ]);
    expect(_shown(tester, 0), '931205');
    expect(_shown(tester, 1), '1');
  });

  testWidgets('keyboard paste distributes with one change', (tester) async {
    final changes = <List<String>>[];
    _mockClipboard(tester, '931205-1234567');
    await tester.pumpWidget(_app(_resident(onValueChange: changes.add)));
    await _focus(tester, 0);
    await _keyboardPaste(tester);

    expect(changes, [
      ['931205', '1'],
    ]);
    expect(_focusedIndex(tester), 1);
  });

  testWidgets('paste stops before masked segments and focuses the first '
      'masked segment', (tester) async {
    final changes = <List<String>>[];
    _mockClipboard(tester, '1234-5678-9012-3456');
    await tester.pumpWidget(_app(_card(onValueChange: changes.add)));
    await _focus(tester, 0);
    await _keyboardPaste(tester);

    expect(changes, [
      ['1234', '5678', '', ''],
    ]);
    expect(_shown(tester, 2), '');
    expect(_focusedIndex(tester), 2);
  });

  testWidgets('autofill of the whole card number stops before masked '
      'segments with one change', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(_app(_card(onValueChange: changes.add)));
    await _focus(tester, 0);
    // Android autofill replaces the whole field value.
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '1234567890123456',
        selection: TextSelection.collapsed(offset: 16),
      ),
    );
    await tester.pump();
    expect(changes, [
      ['1234', '5678', '', ''],
    ]);
  });

  testWidgets('rejects a paste that overflows while characters remain after '
      'the caret', (tester) async {
    final changes = <List<String>>[];
    _mockClipboard(tester, '99');
    await tester.pumpWidget(
      _app(
        _card(defaultValue: ['1234', '', '', ''], onValueChange: changes.add),
      ),
    );
    await _focus(tester, 0);
    _setCaret(tester, 0, 2);
    await _keyboardPaste(tester);
    expect(_shown(tester, 0), '1234');
    expect(_shown(tester, 1), '');
    expect(changes, isEmpty);

    // The same through an IME insertion.
    _setCaret(tester, 0, 2);
    await _insert(tester, '99');
    await tester.pump();
    expect(_shown(tester, 0), '1234');
    expect(changes, isEmpty);
  });

  testWidgets('normalizes a birth date autofill and moves to the next '
      'segment', (tester) async {
    await tester.pumpWidget(_app(_resident(defaultValue: ['9312', '1'])));
    await _focus(tester, 0);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '2000-01-01',
        selection: TextSelection.collapsed(offset: 10),
      ),
    );
    await tester.pump();

    expect(_shown(tester, 0), '000101');
    expect(_shown(tester, 1), '1');
    expect(_focusedIndex(tester), 1);
  });

  testWidgets('does not change read-only segments', (tester) async {
    final changes = <List<String>>[];
    _mockClipboard(tester, '1234');
    await tester.pumpWidget(
      _app(
        _resident(
          readOnly: true,
          defaultValue: ['9312', ''],
          onValueChange: changes.add,
        ),
      ),
    );
    await tester.tap(_segment(0));
    await tester.pump();
    await _keyboardPaste(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(_shown(tester, 0), '9312');
    expect(changes, isEmpty);
  });

  testWidgets('a controlled parent that rejects a change keeps the previous '
      'value', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(_resident(value: ['9312', ''], onValueChange: changes.add)),
    );
    await _focus(tester, 0);
    await _type(tester, '0');
    await tester.pumpAndSettle();

    expect(changes, [
      ['93120', ''],
    ]);
    expect(_shown(tester, 0), '9312');

    // A rejected multi-segment paste also restores every segment.
    await _insert(tester, '051');
    await tester.pumpAndSettle();
    expect(changes.last, ['931205', '1']);
    expect(_shown(tester, 0), '9312');
    expect(_shown(tester, 1), '');
  });

  testWidgets('a controlled parent that applies changes stays in sync', (
    tester,
  ) async {
    var value = <String>['', ''];
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _app(
          _resident(
            value: value,
            onValueChange: (next) => setState(() => value = next),
          ),
        ),
      ),
    );
    await _focus(tester, 0);
    await _type(tester, '9312051');
    await tester.pumpAndSettle();
    expect(value, ['931205', '1']);
    expect(_shown(tester, 1), '1');
  });

  group('IME composition', () {
    testWidgets('is not rewritten while composing and moves on commit', (
      tester,
    ) async {
      final changes = <List<String>>[];
      var value = <String>['93120', ''];
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            _resident(
              value: value,
              onValueChange: (next) {
                changes.add(next);
                setState(() => value = next);
              },
            ),
          ),
        ),
      );
      await _focus(tester, 0);
      const composing = TextEditingValue(
        text: '93120ㄱ',
        selection: TextSelection.collapsed(offset: 6),
        composing: TextRange(start: 5, end: 6),
      );
      tester.testTextInput.updateEditingValue(composing);
      await tester.pump();

      // Neither the text, the selection nor the composing range changes.
      expect(_editing(tester), composing);
      expect(changes, isEmpty);

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '931205',
          selection: TextSelection.collapsed(offset: 6),
          composing: TextRange(start: 5, end: 6),
        ),
      );
      await tester.pump();
      expect(changes, isEmpty);

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '931205',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      await tester.pumpAndSettle();
      expect(changes, [
        ['931205', ''],
      ]);
      expect(_focusedIndex(tester), 1);
    });

    testWidgets('rejects a composed insertion that overflows a full segment', (
      tester,
    ) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(
          _resident(defaultValue: ['931205', ''], onValueChange: changes.add),
        ),
      );
      await _focus(tester, 0);
      _setCaret(tester, 0, 2);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '9302120',
          selection: TextSelection.collapsed(offset: 3),
          composing: TextRange(start: 2, end: 3),
        ),
      );
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '9302120',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      await tester.pump();
      expect(_shown(tester, 0), '931205');
      expect(_editing(tester).selection.baseOffset, 2);
      expect(changes, isEmpty);
    });

    testWidgets('composes Korean text in a text segment', (tester) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(
          SeedSegmentedTextInput(
            semanticsLabel: '이름',
            onValueChange: changes.add,
            children: const [
              SeedSegmentedTextInputSegment(
                semanticsLabel: '성',
                length: 1,
                inputMode: TextInputType.text,
              ),
              SeedSegmentedTextInputSegment(
                semanticsLabel: '이름',
                length: 2,
                inputMode: TextInputType.text,
              ),
            ],
          ),
        ),
      );
      await _focus(tester, 0);
      // Composition starts in an empty segment.
      final start = _editing(tester);
      for (final syllable in ['ㄱ', '기', '김']) {
        final composing = TextEditingValue(
          text: start.text + syllable,
          selection: TextSelection.collapsed(offset: start.text.length + 1),
          composing: TextRange(
            start: start.text.length,
            end: start.text.length + 1,
          ),
        );
        tester.testTextInput.updateEditingValue(composing);
        await tester.pump();
        expect(_editing(tester), composing);
      }
      expect(changes, isEmpty);
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: '${start.text}김',
          selection: TextSelection.collapsed(offset: start.text.length + 1),
        ),
      );
      await tester.pump();
      expect(changes, [
        ['김', ''],
      ]);
      expect(_shown(tester, 0), '김');
      expect(_focusedIndex(tester), 1);
    });
  });

  testWidgets('keeps segment order when keyed segments are reordered', (
    tester,
  ) async {
    final changes = <List<String>>[];
    Widget build(List<String> order) => _app(
      SeedSegmentedTextInput(
        semanticsLabel: 'reorder',
        onValueChange: changes.add,
        children: [
          for (final key in order)
            SeedSegmentedTextInputSegment(
              key: ValueKey(key),
              semanticsLabel: key,
              length: 2,
            ),
        ],
      ),
    );
    await tester.pumpWidget(build(['a', 'b']));
    await tester.pumpWidget(build(['b', 'a']));
    await _focus(tester, 0);
    await _insert(tester, '5678');
    expect(changes.last, ['56', '78']);
  });

  testWidgets('fill placeholder can use the full editable width', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_resident(), width: 358));
    final placeholder = find.text('생년월일 6자리');
    final paragraph = tester.renderObject<RenderParagraph>(placeholder);
    expect(
      paragraph.size.width,
      greaterThanOrEqualTo(paragraph.getMaxIntrinsicWidth(double.infinity)),
    );
  });

  testWidgets('stays inside its width at a large text scale', (tester) async {
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _card(defaultValue: ['1234', '5678', '12', '']),
            const SizedBox(height: 8),
            _resident(defaultValue: ['931205', '1']),
          ],
        ),
        textScale: 2,
        width: 320,
      ),
    );
    expect(tester.takeException(), isNull);
    for (final root in find.byType(SeedSegmentedTextInput).evaluate()) {
      final box = root.renderObject! as RenderBox;
      expect(box.size.width, lessThanOrEqualTo(320));
      expect(box.size.height, greaterThanOrEqualTo(52));
    }
  });

  testWidgets('uses large tokens by default and medium tokens on request', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _card(),
            const SeedSegmentedTextInput(
              size: SeedSegmentedTextInputSize.medium,
              children: [SeedSegmentedTextInputSegment(length: 4)],
            ),
          ],
        ),
      ),
    );
    final roots = find.byType(SeedSegmentedTextInput);
    expect(tester.getSize(roots.at(0)).height, 52);
    expect(tester.getSize(roots.at(1)).height, 40);
  });

  testWidgets('a Field names the group and passes its states', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const SeedField(
          label: '카드번호',
          errorMessage: '카드번호를 확인해 주세요',
          required: true,
          child: SeedSegmentedTextInput(
            children: [
              SeedSegmentedTextInputSegment(semanticsLabel: '앞', length: 4),
              SeedSegmentedTextInputSegment(semanticsLabel: '뒤', length: 4),
            ],
          ),
        ),
      ),
    );
    final group = tester.getSemantics(find.byType(SeedSegmentedTextInput));
    expect(group.label, contains('카드번호'));
    final segment = tester.getSemantics(_segment(1));
    expect(segment.label, contains('뒤'));
    expect(segment.validationResult, SemanticsValidationResult.invalid);
    expect(segment.flagsCollection.isRequired, Tristate.isTrue);

    // Tapping the label focuses the first segment.
    await tester.tap(find.text('카드번호').first);
    await tester.pump();
    expect(_focusedIndex(tester), 0);
    handle.dispose();
  });

  testWidgets('a disabled Field disables every segment', (tester) async {
    await tester.pumpWidget(
      _app(
        const SeedField(
          disabled: true,
          child: SeedSegmentedTextInput(
            children: [
              SeedSegmentedTextInputSegment(length: 4),
              SeedSegmentedTextInputSegment(length: 4),
            ],
          ),
        ),
      ),
    );
    for (final state in _states(tester)) {
      expect(state.widget.focusNode.canRequestFocus, isFalse);
    }
  });

  testWidgets('keeps the group focused while moving between segments', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_resident()));
    await _focus(tester, 0);
    BoxDecoration decoration() =>
        tester
                .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                .decoration!
            as BoxDecoration;
    expect((decoration().border! as Border).top.width, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_focusedIndex(tester), 1);
    expect((decoration().border! as Border).top.width, 2);
  });

  testWidgets('Form adapter validates, saves and resets the value list', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    List<String>? saved;
    await tester.pumpWidget(
      _app(
        Form(
          key: formKey,
          child: SeedSegmentedTextInputFormField(
            label: '생년월일',
            defaultValue: const ['', ''],
            validator: (value) =>
                (value ?? const []).join().length == 7 ? null : '7자리를 입력하세요',
            onSaved: (value) => saved = value,
            children: const [
              SeedSegmentedTextInputSegment(semanticsLabel: '앞', length: 6),
              SeedSegmentedTextInputSegment(semanticsLabel: '뒤', length: 1),
            ],
          ),
        ),
      ),
    );
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('7자리를 입력하세요'), findsOneWidget);

    await _focus(tester, 0);
    await _insert(tester, '9312051');
    await tester.pumpAndSettle();
    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();
    expect(saved, ['931205', '1']);

    formKey.currentState!.reset();
    await tester.pumpAndSettle();
    expect(_shown(tester, 0), '');
  });
}
