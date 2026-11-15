import 'dart:ui' show SemanticsInputType;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _host(Widget child, {double textScale = 1}) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  ),
);

Finder get _editable => find.byType(EditableText);
Finder get _clearButton => find.bySemanticsLabel('지우기');

FocusNode _inputFocus(WidgetTester tester) =>
    tester.widget<EditableText>(_editable).focusNode;

String _text(WidgetTester tester) =>
    tester.widget<EditableText>(_editable).controller.text;

void main() {
  group('SeedPressable focus (why the clear button needs extra handling)', () {
    testWidgets('a plain SeedPressable takes focus from a text field', (
      tester,
    ) async {
      final inputFocus = FocusNode();
      addTearDown(inputFocus.dispose);
      await tester.pumpWidget(
        _host(
          Row(
            children: [
              Expanded(child: TextField(focusNode: inputFocus)),
              SeedPressable(
                semanticsLabel: 'plain',
                onTap: () {},
                child: const SizedBox(width: 44, height: 44),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(inputFocus.hasFocus, isTrue);

      await tester.tap(find.bySemanticsLabel('plain'));
      await tester.pump();
      expect(inputFocus.hasFocus, isFalse);
    });
  });

  group('SeedSearchInput rendering', () {
    testWidgets('uses the search-input.yaml tokens', (tester) async {
      await tester.pumpWidget(
        _host(const SeedSearchInput(placeholder: '검색어를 입력하세요')),
      );
      final root = find.byType(SeedSearchInput);
      expect(tester.getSize(root).height, 44);

      final container = tester.widget<Container>(
        find.descendant(of: root, matching: find.byType(Container)).first,
      );
      final decoration = container.decoration! as BoxDecoration;
      final theme = SeedThemeData.light(fontFamily: seedTestFontFamily);
      expect(decoration.color, theme.colorScheme.bg.neutralWeak);
      expect(decoration.borderRadius, SeedBorderRadius.r2_5);
      expect(
        container.padding,
        const EdgeInsets.only(left: SeedDimension.x4, right: SeedDimension.x1),
      );

      final editable = tester.widget<EditableText>(_editable);
      expect(editable.style.fontSize, theme.typography.t6Regular.fontSize);
      expect(editable.style.fontWeight, theme.typography.t6Regular.fontWeight);
      expect(editable.style.color, theme.colorScheme.fg.neutral);
      expect(editable.textInputAction, TextInputAction.search);

      final hint = tester.widget<Text>(find.text('검색어를 입력하세요'));
      expect(hint.style?.color, theme.colorScheme.fg.placeholder);
      expect(hint.style?.fontSize, theme.typography.t6Regular.fontSize);
    });

    testWidgets('clear button is 44px with a 20px neutral-subtle icon', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const SeedSearchInput(defaultValue: '당근')));
      expect(tester.getSize(_clearButton), const Size(44, 44));
      final icon = tester.widget<Icon>(
        find.descendant(of: _clearButton, matching: find.byType(Icon)),
      );
      expect(icon.size, SeedDimension.x5);
      expect(
        icon.color,
        SeedThemeData.light(fontFamily: seedTestFontFamily)
            .colorScheme
            .fg
            .neutralSubtle,
      );
      // The button sits flush with the 4px right padding of the root.
      final rootRect = tester.getRect(find.byType(SeedSearchInput));
      expect(tester.getRect(_clearButton).right, rootRect.right - 4);
    });

    testWidgets('keeps the 44px height with a large text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const SeedSearchInput(defaultValue: '당근'), textScale: 2),
      );
      expect(tester.getSize(find.byType(SeedSearchInput)).height, 44);
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes search semantics with localized labels', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const SeedSearchInput(defaultValue: '당근')));

      final data = tester.getSemantics(_editable).getSemanticsData();
      expect(data.label, contains('검색'));
      expect(data.flagsCollection.isTextField, isTrue);
      expect(data.inputType, SemanticsInputType.search);
      expect(
        tester
            .getSemantics(_clearButton)
            .getSemanticsData()
            .flagsCollection
            .isButton,
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('label overrides and SeedLocalizations apply', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const SeedSearchInput(
            defaultValue: '당근',
            semanticsLabel: '동네 검색',
            clearButtonLabel: '검색어 지우기',
          ),
        ),
      );
      expect(
        tester.getSemantics(_editable).getSemanticsData().label,
        contains('동네 검색'),
      );
      expect(find.bySemanticsLabel('검색어 지우기'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(body: SeedSearchInput(defaultValue: 'a')),
        ),
      );
      expect(
        tester.getSemantics(_editable).getSemanticsData().label,
        contains('Search'),
      );
      expect(find.bySemanticsLabel('Clear'), findsOneWidget);
      handle.dispose();
    });
  });

  group('SeedSearchInput submit', () {
    testWidgets('onSubmit can move focus to another control', (tester) async {
      final nextFocus = FocusNode();
      addTearDown(nextFocus.dispose);
      await tester.pumpWidget(
        _host(
          Column(
            children: [
              SeedSearchInput(onSubmit: (_) => nextFocus.requestFocus()),
              Focus(focusNode: nextFocus, child: const SizedBox(height: 10)),
            ],
          ),
        ),
      );
      await tester.showKeyboard(_editable);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(_inputFocus(tester).hasFocus, isFalse);
      expect(nextFocus.hasFocus, isTrue);
    });

    testWidgets('calls onSubmit with the value and blurs by default', (
      tester,
    ) async {
      final submitted = <String>[];
      await tester.pumpWidget(_host(SeedSearchInput(onSubmit: submitted.add)));
      await tester.showKeyboard(_editable);
      await tester.enterText(_editable, '당근');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submitted, ['당근']);
      expect(_inputFocus(tester).hasFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('keeps focus when blurOnSubmit is false', (tester) async {
      final submitted = <String>[];
      await tester.pumpWidget(
        _host(SeedSearchInput(onSubmit: submitted.add, blurOnSubmit: false)),
      );
      await tester.showKeyboard(_editable);
      await tester.enterText(_editable, '당근');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submitted, ['당근']);
      expect(_inputFocus(tester).hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('blurs on submit without onSubmit', (tester) async {
      await tester.pumpWidget(_host(const SeedSearchInput()));
      await tester.showKeyboard(_editable);
      await tester.enterText(_editable, '당근');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(_inputFocus(tester).hasFocus, isFalse);
    });

    testWidgets('submits committed Korean text when the action arrives '
        'during composition', (tester) async {
      final submitted = <String>[];
      final changes = <String>[];
      await tester.pumpWidget(
        _host(
          SeedSearchInput(
            onSubmit: submitted.add,
            onValueChange: changes.add,
            blurOnSubmit: false,
          ),
        ),
      );
      await tester.showKeyboard(_editable);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '당그',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 1, end: 2),
        ),
      );
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '당근',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 1, end: 2),
        ),
      );
      await tester.pump();
      // Composing updates do not submit.
      expect(submitted, isEmpty);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      // One action submits once, with the composed syllable included.
      expect(submitted, ['당근']);
      final controller = tester.widget<EditableText>(_editable).controller;
      expect(controller.value.composing, TextRange.empty);
      expect(changes.last, '당근');
    });
  });

  group('SeedSearchInput clear button', () {
    testWidgets('appears only with a value, clears and keeps focus (touch)', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _host(SeedSearchInput(onValueChange: changes.add)),
      );
      expect(_clearButton, findsNothing);

      await tester.showKeyboard(_editable);
      await tester.enterText(_editable, '당근');
      await tester.pump();
      expect(_clearButton, findsOneWidget);

      await tester.tap(_clearButton);
      await tester.pump();

      expect(_text(tester), '');
      expect(changes.last, '');
      expect(_clearButton, findsNothing);
      expect(_inputFocus(tester).hasFocus, isTrue);

      // Typing continues right away.
      await tester.enterText(_editable, '오이');
      await tester.pump();
      expect(_text(tester), '오이');
      expect(changes.last, '오이');
    });

    testWidgets('keeps focus when clicked with a mouse', (tester) async {
      await tester.pumpWidget(_host(const SeedSearchInput()));
      await tester.showKeyboard(_editable);
      await tester.enterText(_editable, '당근');
      await tester.pump();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: tester.getCenter(_clearButton));
      await gesture.down(tester.getCenter(_clearButton));
      await tester.pump();
      expect(_inputFocus(tester).hasFocus, isTrue);
      await gesture.up();
      await tester.pump();

      expect(_text(tester), '');
      expect(_inputFocus(tester).hasFocus, isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('keyboard activation clears and returns focus to the input', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _host(SeedSearchInput(onValueChange: changes.add)),
      );
      await tester.showKeyboard(_editable);
      await tester.enterText(_editable, '당근');
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_inputFocus(tester).hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(_text(tester), '');
      expect(changes.last, '');
      expect(_clearButton, findsNothing);
      expect(_inputFocus(tester).hasFocus, isTrue);

      await tester.enterText(_editable, '오이');
      expect(_text(tester), '오이');
    });

    testWidgets('leaves an unfocused input unfocused', (tester) async {
      final other = FocusNode();
      addTearDown(other.dispose);
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Focus(focusNode: other, child: const SizedBox(height: 10)),
              const SeedSearchInput(defaultValue: '당근'),
            ],
          ),
        ),
      );
      other.requestFocus();
      await tester.pump();

      await tester.tap(_clearButton);
      await tester.pump();

      expect(_text(tester), '');
      expect(_inputFocus(tester).hasFocus, isFalse);
      expect(other.hasFocus, isTrue);
    });

    testWidgets('is hidden while disabled or read-only', (tester) async {
      await tester.pumpWidget(
        _host(const SeedSearchInput(defaultValue: '당근', enabled: false)),
      );
      expect(_clearButton, findsNothing);

      await tester.pumpWidget(
        _host(const SeedSearchInput(defaultValue: '당근', readOnly: true)),
      );
      expect(_clearButton, findsNothing);
      expect(tester.widget<EditableText>(_editable).readOnly, isTrue);

      await tester.pumpWidget(
        _host(
          const SeedFieldset(
            enabled: false,
            child: SeedSearchInput(defaultValue: '당근'),
          ),
        ),
      );
      expect(_clearButton, findsNothing);
    });
  });

  group('SeedSearchInput value ownership', () {
    testWidgets('controlled value follows the parent', (tester) async {
      var value = '당근';
      final changes = <String>[];
      late StateSetter setOuter;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return SeedSearchInput(
                value: value,
                onValueChange: (next) {
                  changes.add(next);
                  setState(() => value = next);
                },
              );
            },
          ),
        ),
      );
      await tester.tap(_clearButton);
      await tester.pumpAndSettle();
      expect(changes, ['']);
      expect(_text(tester), '');

      setOuter(() => value = '오이');
      await tester.pump();
      expect(_text(tester), '오이');
      expect(_clearButton, findsOneWidget);
    });

    testWidgets('a controlled parent that keeps its value rejects the clear', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _host(SeedSearchInput(value: '당근', onValueChange: changes.add)),
      );
      await tester.tap(_clearButton);
      await tester.pumpAndSettle();
      expect(changes, ['']);
      expect(_text(tester), '당근');
    });

    testWidgets('controller drives the text and the clear button', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_host(SeedSearchInput(controller: controller)));
      expect(_clearButton, findsNothing);

      controller.text = '당근';
      await tester.pump();
      expect(_clearButton, findsOneWidget);

      await tester.tap(_clearButton);
      await tester.pump();
      expect(controller.text, '');
    });

    testWidgets('defaultValue seeds an uncontrolled input', (tester) async {
      await tester.pumpWidget(_host(const SeedSearchInput(defaultValue: '당근')));
      expect(_text(tester), '당근');
      await tester.showKeyboard(_editable);
      await tester.enterText(_editable, '오이');
      await tester.pump();
      expect(_text(tester), '오이');
    });
  });
}
