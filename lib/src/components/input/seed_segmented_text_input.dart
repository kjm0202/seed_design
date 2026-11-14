import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_control.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import 'seed_field.dart';
import 'seed_text_field.dart';

/// Size options for [SeedSegmentedTextInput] (React `size`).
///
/// [large] is the default for every viewport. [medium] is the compact
/// desktop size (breakpoint `lg` and above).
enum SeedSegmentedTextInputSize {
  /// Compact desktop size: 40 px min height, r2 corners, t4 text.
  medium,

  /// Default size: 52 px min height, r3 corners, t5 text.
  large,
}

/// How a [SeedSegmentedTextInputSegment] shares the root width
/// (React `sizing`).
enum SeedSegmentedTextInputSizing {
  /// The segment is as wide as its content (default).
  fit,

  /// The segment divides the remaining width with other `fill` segments.
  fill,
}

/// How the content of a [SeedSegmentedTextInputSegment] is aligned inside
/// the segment (React `align`). This aligns the input and its static text as
/// a group; it is not the text alignment inside the input.
enum SeedSegmentedTextInputAlign {
  /// Content starts at the leading edge (default).
  start,

  /// Content is centered in the segment.
  center,
}

// An empty segment holds this zero-width character so that a soft keyboard
// always has something to delete. Deleting it is the only way Flutter can
// observe "Backspace in an empty segment" on Android and iOS, where no key
// event reaches an empty text field. It never appears in the value list.
const String _kEmptySentinel = '​';

String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String _identity(String value) => value;

final RegExp _separatedDate = RegExp(
  r'^\s*(\d{4})\D+(\d{1,2})\D+(\d{1,2})\D*$',
);
final RegExp _compactDate = RegExp(r'^\s*(\d{4})(\d{2})(\d{2})\s*$');

/// Port of the official headless `normalizeBirthDate` (internal, not public).
///
/// Fits an OS-provided date (`yyyy-MM-dd`, `yyyy. MM. dd.`, `yyyyMMdd`) to
/// a 6 (`yyMMdd`) or 8 (`yyyyMMdd`) digit segment; null when not a date.
String? _normalizeBirthDate(
  String value,
  int length, {
  bool allowCompact = true,
}) {
  if (length != 6 && length != 8) return null;
  final match =
      _separatedDate.firstMatch(value) ??
      (allowCompact ? _compactDate.firstMatch(value) : null);
  if (match == null) return null;
  final date =
      '${match[1]}${match[2]!.padLeft(2, '0')}${match[3]!.padLeft(2, '0')}';
  return length == 6 ? date.substring(2) : date;
}

/// Segmented text input component of SEED Design System
/// (React `SegmentedTextInput.Root`).
///
/// Splits one value into fixed-length segments, such as a resident
/// registration number (`6 - 1`) or a card number (`4 - 4 - 4 - 4`).
/// [children] lists [SeedSegmentedTextInputSegment]s,
/// [SeedSegmentedTextInputSeparator]s and an optional
/// [SeedSegmentedTextInputSuffix] in visual order. Segments must be direct
/// children: the order of editable segments in [children] is the order of
/// the value list (React uses DOM order).
///
/// The value is a `List<String>` containing one entry per editable segment,
/// in order. Static segments, separators, prefixes and suffixes are not part
/// of it. With [value] the parent owns the value: a proposed change that the
/// parent does not apply is reverted to the previous [value]. Without it,
/// [defaultValue] seeds internal state. A paste or an autofill that spans
/// several segments calls [onValueChange] exactly once.
///
/// Behavior follows the official headless hook: typing that fills a segment
/// at its end moves to the next segment; multi-character input (paste,
/// autofill) is distributed over following segments and stops before a
/// masked, read-only or disabled segment; Backspace in an empty segment
/// moves to the previous segment and deletes its last character; arrow keys
/// at a segment edge move between segments. Korean IME composition is never
/// rewritten while it is composing; it is normalized when committed.
///
/// Inside a [SeedField] the field label names the group, and the field's
/// disabled, read-only, invalid and required states apply as in
/// [SeedTextInput]. The first segment receives label-tap focus.
///
/// Each segment is its own [TextField], so platform autofill, obscuring,
/// accessibility labels, caret, selection handles and focus traversal stay
/// native per segment. See `doc/PUBLIC_API_CONTRACT.md` for why this
/// structure was chosen over a single hidden editor.
class SeedSegmentedTextInput extends StatefulWidget {
  /// Creates a segmented input from [children].
  ///
  /// [value] is the controlled value list (one entry per editable segment);
  /// [defaultValue] (default empty) seeds the uncontrolled value.
  /// [onValueChange] receives every proposed value as an unmodifiable list.
  /// [disabled], [readOnly], [invalid] and [required] default to false and
  /// combine with an enclosing [SeedField], [SeedFieldset] or
  /// [SeedControlScope]. [size] defaults to large. [semanticsLabel] names
  /// the group (React `aria-label`); inside a Field the field label is used
  /// when it is null.
  const SeedSegmentedTextInput({
    super.key,
    required this.children,
    this.value,
    this.defaultValue = const [],
    this.onValueChange,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.required = false,
    this.size = SeedSegmentedTextInputSize.large,
    this.semanticsLabel,
  });

  /// Segments, separators and suffix in visual order.
  final List<Widget> children;

  /// Controlled value: one string per editable segment, in order.
  final List<String>? value;

  /// Initial uncontrolled value (React `defaultValue`, default empty).
  final List<String> defaultValue;

  /// Called with each proposed value (React `onValueChange`).
  final ValueChanged<List<String>>? onValueChange;

  /// Whether every segment is disabled (default false).
  final bool disabled;

  /// Whether every segment is read-only (default false). Navigation and
  /// selection keep working; the value never changes.
  final bool readOnly;

  /// Whether to paint the invalid stroke and expose invalid semantics.
  final bool invalid;

  /// Required semantics on each segment; no validation is installed.
  final bool required;

  /// Visual size (default [SeedSegmentedTextInputSize.large]).
  final SeedSegmentedTextInputSize size;

  /// Accessible name of the group (React `aria-label`).
  final String? semanticsLabel;

  @override
  State<SeedSegmentedTextInput> createState() => _SeedSegmentedTextInputState();
}

/// One segment of a [SeedSegmentedTextInput] (React
/// `SegmentedTextInput.Segment`).
///
/// The default constructor creates an editable segment of [length]
/// characters. [SeedSegmentedTextInputSegment.staticText] creates a segment
/// that only shows fixed content and is not part of the value.
///
/// This widget is a configuration: it must be a direct child of
/// [SeedSegmentedTextInput], which builds it.
class SeedSegmentedTextInputSegment extends StatelessWidget {
  /// Creates an editable segment.
  ///
  /// [length] is the number of characters (enforced by the component, not a
  /// native max length, so autofill is never truncated). [masked] paints
  /// dots instead of characters and keeps the caret at the end (default
  /// false). [inputMode] defaults to [TextInputType.number] (React
  /// `inputMode="numeric"`), which also makes the default [normalize] drop
  /// every non-digit; other input modes keep input as is unless [normalize]
  /// is given. [autofillHints] is React `autoComplete`: it defaults to
  /// participating without a hint, a masked segment treats an empty list as
  /// autofill off, and [AutofillHints.birthday] (`bday`) normalizes pasted or
  /// autofilled dates to `yyMMdd`/`yyyyMMdd`. [semanticsLabel] is React
  /// `aria-label`; give every segment one so segments can be told apart.
  ///
  /// [placeholder] (text) or [placeholderWidget] (for example
  /// [SeedSegmentedTextInputDots]) shows while the segment is empty; masked
  /// segments ignore both and show placeholder dots. [staticPrefix] and
  /// [staticSuffix] show fixed content around the input and are hidden from
  /// assistive technologies. [sizing] (default fit) and [align] (default
  /// start) lay out the segment. [disabled] and [readOnly] apply to this
  /// segment only, like the native input attributes in React.
  const SeedSegmentedTextInputSegment({
    super.key,
    required this.length,
    this.masked = false,
    this.inputMode = TextInputType.number,
    this.autofillHints = const <String>[],
    this.normalize,
    this.semanticsLabel,
    this.placeholder,
    this.placeholderWidget,
    this.staticPrefix,
    this.staticSuffix,
    this.sizing = SeedSegmentedTextInputSizing.fit,
    this.align = SeedSegmentedTextInputAlign.start,
    this.disabled = false,
    this.readOnly = false,
  }) : staticText = null,
       assert(length > 0),
       assert(placeholder == null || placeholderWidget == null);

  /// Creates a static segment that shows [staticText] (React `staticText`).
  ///
  /// It is not part of the value and is hidden from assistive technologies.
  /// [sizing] defaults to fit and [align] to start.
  const SeedSegmentedTextInputSegment.staticText({
    super.key,
    required Widget this.staticText,
    this.sizing = SeedSegmentedTextInputSizing.fit,
    this.align = SeedSegmentedTextInputAlign.start,
  }) : length = 0,
       masked = false,
       inputMode = TextInputType.number,
       autofillHints = null,
       normalize = null,
       semanticsLabel = null,
       placeholder = null,
       placeholderWidget = null,
       staticPrefix = null,
       staticSuffix = null,
       disabled = false,
       readOnly = false;

  /// Number of characters in this segment (0 for a static segment).
  final int length;

  /// Whether characters are painted as dots (default false).
  final bool masked;

  /// Keyboard type (React `inputMode`, default numeric).
  final TextInputType inputMode;

  /// Platform autofill hints (React `autoComplete`).
  final Iterable<String>? autofillHints;

  /// Custom input normalization; defaults to digits only for numeric input.
  final String Function(String value)? normalize;

  /// Accessible name of this segment (React `aria-label`).
  final String? semanticsLabel;

  /// Text shown while the segment is empty.
  final String? placeholder;

  /// Widget shown while the segment is empty, painted over the input.
  final Widget? placeholderWidget;

  /// Fixed content before the input, hidden from assistive technologies.
  final Widget? staticPrefix;

  /// Fixed content after the input, hidden from assistive technologies.
  final Widget? staticSuffix;

  /// Content of a static segment; null for an editable segment.
  final Widget? staticText;

  /// How the segment shares the root width (default fit).
  final SeedSegmentedTextInputSizing sizing;

  /// Alignment of the segment content (default start).
  final SeedSegmentedTextInputAlign align;

  /// Whether this segment alone is disabled.
  final bool disabled;

  /// Whether this segment alone is read-only.
  final bool readOnly;

  bool get _isStatic => staticText != null;

  @override
  Widget build(BuildContext context) {
    assert(
      false,
      'SeedSegmentedTextInputSegment must be a direct child of '
      'SeedSegmentedTextInput.',
    );
    return const SizedBox.shrink();
  }
}

/// Decorative separator between segments (React
/// `SegmentedTextInput.Separator`), for example `Text(' - ')`.
///
/// Painted with the separator token style and hidden from assistive
/// technologies. Must be a direct child of [SeedSegmentedTextInput].
class SeedSegmentedTextInputSeparator extends StatelessWidget {
  /// Creates a separator showing [child].
  const SeedSegmentedTextInputSeparator({super.key, required this.child});

  /// Separator content, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: child);
}

/// Trailing accessory such as a card brand logo (React
/// `SegmentedTextInput.Suffix`), pinned to the end of the root.
///
/// Must be a direct child of [SeedSegmentedTextInput].
class SeedSegmentedTextInputSuffix extends StatelessWidget {
  /// Creates a suffix showing [child]; its size comes from [child].
  const SeedSegmentedTextInputSuffix({super.key, required this.child});

  /// Suffix content.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Row of 7 px dots for hidden digits (React `SegmentedTextInput.Dots`),
/// such as the last six digits of a resident registration number.
///
/// Use it in `staticText`, `staticPrefix`, `staticSuffix` or
/// `placeholderWidget`. Dots take the ambient text color and are hidden
/// from assistive technologies.
class SeedSegmentedTextInputDots extends StatelessWidget {
  /// Creates [count] dots.
  const SeedSegmentedTextInputDots({super.key, required this.count});

  /// Number of dots.
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: SeedDimension.x2),
            _Dot(color: color),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Flutter [Form] adapter for [SeedSegmentedTextInput] inside a [SeedField].
///
/// The value is the official `List<String>` of editable segments. With
/// [value] (or [controlled]) the parent stays authoritative on reset.
class SeedSegmentedTextInputFormField extends SeedFormField<List<String>> {
  /// Creates a [Form]-registered segmented input.
  ///
  /// [children] are the segments as in [SeedSegmentedTextInput]. A non-null
  /// [value] controls the value; [controlled] also makes null an explicitly
  /// controlled empty value. Otherwise [defaultValue] (default empty) seeds
  /// the form value and form reset restores it. [onValueChange] receives an
  /// unmodifiable list after changes. [validator], [onSaved], [onReset],
  /// [autovalidateMode] and [restorationId] have their [FormField] meanings;
  /// [errorMessage] overrides the validation error text. [enabled],
  /// [readOnly] and [required] apply to the field; [label] and [description]
  /// render the field text. [size] defaults to large and [semanticsLabel]
  /// names the group when [label] is absent.
  SeedSegmentedTextInputFormField({
    super.key,
    required List<Widget> children,
    List<String>? value,
    List<String> defaultValue = const [],
    super.controlled,
    ValueChanged<List<String>>? onValueChange,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.restorationId,
    String? errorMessage,
    super.enabled,
    bool readOnly = false,
    bool required = false,
    String? label,
    String? description,
    SeedSegmentedTextInputSize size = SeedSegmentedTextInputSize.large,
    String? semanticsLabel,
  }) : super(
         value: value == null ? null : List<String>.unmodifiable(value),
         initialValue: List<String>.unmodifiable(defaultValue),
         forceErrorText: errorMessage,
         onValueChanged: (next) => onValueChange?.call(
           List<String>.unmodifiable(next ?? const <String>[]),
         ),
         builder: (field) => SeedField(
           label: label,
           description: description,
           required: required,
           errorMessage: field.errorText,
           invalid: field.hasError,
           disabled: !enabled,
           readOnly: readOnly,
           child: SeedSegmentedTextInput(
             value: field.value ?? const <String>[],
             onValueChange: field.didChange,
             size: size,
             semanticsLabel: semanticsLabel,
             children: children,
           ),
         ),
       );
}

class _Snapshot {
  const _Snapshot(this.start, this.end, this.value);

  final int start;
  final int end;
  final String value;
}

class _SegmentFormatter extends TextInputFormatter {
  _SegmentFormatter(this.state, this.index);

  final _SeedSegmentedTextInputState state;
  final int index;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => state._format(index, oldValue, newValue);
}

class _Editor {
  _Editor(_SeedSegmentedTextInputState state, this.index, String body)
    : controller = TextEditingController.fromValue(_displayValue(body)),
      focusNode = FocusNode(debugLabel: 'SeedSegmentedTextInput[$index]') {
    formatter = _SegmentFormatter(state, index);
  }

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  late final _SegmentFormatter formatter;
  _Snapshot? composition;
  bool adjusting = false;

  bool get composing {
    final composingRange = controller.value.composing;
    return composingRange.isValid && !composingRange.isCollapsed;
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

String _strip(String text) =>
    text.startsWith(_kEmptySentinel) ? text.substring(1) : text;

/// Editing value shown for [body]; [selection] is in body offsets.
TextEditingValue _displayValue(String body, {TextSelection? selection}) {
  if (body.isEmpty) {
    return const TextEditingValue(
      text: _kEmptySentinel,
      selection: TextSelection.collapsed(offset: 1),
    );
  }
  final sel = selection ?? TextSelection.collapsed(offset: body.length);
  return TextEditingValue(
    text: body,
    selection: TextSelection(
      baseOffset: sel.baseOffset.clamp(0, body.length),
      extentOffset: sel.extentOffset.clamp(0, body.length),
    ),
  );
}

/// The body value and selection (in body offsets) of an editing value.
_Snapshot _snapshotOf(TextEditingValue value) {
  if (value.text == _kEmptySentinel || value.text.isEmpty) {
    return const _Snapshot(0, 0, '');
  }
  final body = value.text;
  final sel = value.selection;
  if (!sel.isValid) return _Snapshot(body.length, body.length, body);
  return _Snapshot(
    sel.start.clamp(0, body.length),
    sel.end.clamp(0, body.length),
    body,
  );
}

class _SeedSegmentedTextInputState extends State<SeedSegmentedTextInput> {
  late List<String> _uncontrolled = List<String>.of(widget.defaultValue);
  final List<_Editor> _editors = [];
  List<SeedSegmentedTextInputSegment> _configs = const [];
  bool _rootDisabled = false;
  bool _rootReadOnly = false;
  TextDirection _textDirection = TextDirection.ltr;
  bool _focused = false;
  bool _resyncScheduled = false;
  SeedFieldScope? _fieldScope;
  FocusNode? _registeredNode;

  List<String> get _values => widget.value ?? _uncontrolled;

  String _valueAt(int index) => index < _values.length ? _values[index] : '';

  bool _segDisabled(int index) =>
      _rootDisabled || (index < _configs.length && _configs[index].disabled);

  bool _segReadOnly(int index) =>
      _rootReadOnly || (index < _configs.length && _configs[index].readOnly);

  String Function(String) _normalizer(SeedSegmentedTextInputSegment config) =>
      config.normalize ??
      (config.inputMode == TextInputType.number ? _digitsOnly : _identity);

  bool _isBirthDate(SeedSegmentedTextInputSegment config) =>
      config.autofillHints?.any(
        (hint) => hint == AutofillHints.birthday || hint == 'bday',
      ) ??
      false;

  @override
  void didUpdateWidget(SeedSegmentedTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && !listEquals(widget.value, oldWidget.value)) {
      _syncEditors();
    }
  }

  @override
  void dispose() {
    if (_registeredNode != null) {
      _fieldScope?.unregisterFocusNode?.call(_registeredNode!);
    }
    for (final editor in _editors) {
      editor.dispose();
    }
    super.dispose();
  }

  void _ensureEditors() {
    while (_editors.length < _configs.length) {
      final index = _editors.length;
      final editor = _Editor(this, index, _valueAt(index));
      editor.controller.addListener(() => _adjustSelection(editor));
      _editors.add(editor);
    }
    if (_editors.length > _configs.length) {
      final removed = _editors.sublist(_configs.length);
      _editors.removeRange(_configs.length, _editors.length);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final editor in removed) {
          editor.dispose();
        }
      });
    }
  }

  void _syncFieldRegistration(SeedFieldScope? field) {
    final node = _editors.isEmpty ? null : _editors.first.focusNode;
    if (identical(field, _fieldScope) && node == _registeredNode) return;
    if (_registeredNode != null) {
      _fieldScope?.unregisterFocusNode?.call(_registeredNode!);
    }
    _fieldScope = field;
    _registeredNode = node;
    if (node != null) field?.registerFocusNode?.call(node);
  }

  /// Sets every non-composing editor to the effective value.
  void _syncEditors() {
    for (var i = 0; i < _editors.length; i++) {
      final editor = _editors[i];
      if (editor.composing) continue;
      final body = _valueAt(i);
      final text = editor.controller.text;
      if (body.isEmpty ? text != _kEmptySentinel : text != body) {
        editor.controller.value = _displayValue(body);
      }
    }
  }

  // A controlled parent that rejects a change does not rebuild, so the
  // optimistic display is corrected after the frame.
  void _scheduleResync() {
    if (_resyncScheduled) return;
    _resyncScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _resyncScheduled = false;
      if (mounted) _syncEditors();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// React `setSegmentValues`: one proposal for several segments.
  void _propose(Map<int, String> updates) {
    final values = _values;
    final count = math.max(_configs.length, values.length);
    final next = List<String>.generate(
      count,
      (i) => updates[i] ?? (i < values.length ? values[i] : ''),
    );
    var same = true;
    for (var i = 0; i < count; i++) {
      if (i >= values.length || next[i] != values[i]) {
        same = false;
        break;
      }
    }
    if (same) return;
    if (widget.value == null) setState(() => _uncontrolled = next);
    widget.onValueChange?.call(List<String>.unmodifiable(next));
    if (widget.value != null) _scheduleResync();
  }

  void _setEditorBody(int index, String body, {int? caret}) {
    if (index >= _editors.length) return;
    final editor = _editors[index];
    if (editor.composing) return;
    editor.controller.value = _displayValue(
      body,
      selection: caret == null ? null : TextSelection.collapsed(offset: caret),
    );
  }

  /// React `focusSegment`; [caret] null means the end.
  void _focusSegment(int index, {int? caret}) {
    if (index < 0 || index >= _editors.length) return;
    final editor = _editors[index];
    final body = _strip(editor.controller.text);
    final offset = body.isEmpty
        ? 1
        : (_configs[index].masked ? body.length : (caret ?? body.length));
    editor.adjusting = true;
    editor.controller.selection = TextSelection.collapsed(offset: offset);
    editor.adjusting = false;
    editor.focusNode.requestFocus();
  }

  // Keeps the caret off the sentinel and at the end of a masked segment.
  void _adjustSelection(_Editor editor) {
    if (editor.adjusting || !mounted || editor.composing) return;
    final index = editor.index;
    if (index >= _configs.length) return;
    final value = editor.controller.value;
    final sel = value.selection;
    if (!sel.isValid) return;
    TextSelection? fix;
    if (value.text == _kEmptySentinel) {
      if (!sel.isCollapsed || sel.baseOffset != 1) {
        fix = const TextSelection.collapsed(offset: 1);
      }
    } else if (_configs[index].masked) {
      final end = value.text.length;
      final atEnd = sel.isCollapsed && sel.baseOffset == end;
      final selectsAll = sel.start == 0 && sel.end == end;
      if (!atEnd && !selectsAll) fix = TextSelection.collapsed(offset: end);
    }
    if (fix == null) return;
    editor.adjusting = true;
    editor.controller.selection = fix;
    editor.adjusting = false;
  }

  TextEditingValue _format(
    int index,
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (index >= _editors.length || index >= _configs.length) return newValue;
    final editor = _editors[index];
    final config = _configs[index];

    // Never rewrite text or selection while an IME is composing.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      editor.composition ??= _snapshotOf(oldValue);
      return newValue;
    }
    final composition = editor.composition;
    if (composition != null) {
      editor.composition = null;
      return _commitComposition(index, composition, _strip(newValue.text));
    }
    if (_segReadOnly(index) || _segDisabled(index)) return oldValue;

    final wasEmpty = oldValue.text == _kEmptySentinel || oldValue.text.isEmpty;
    if (wasEmpty && newValue.text.isEmpty) return _backspaceAtStart(index);

    final snapshot = _snapshotOf(oldValue);
    final String raw;
    final TextSelection selection;
    if (wasEmpty) {
      if (!newValue.text.startsWith(_kEmptySentinel)) {
        // The whole value was replaced (autofill, select-all + type).
        return _replaceAll(index, newValue.text);
      }
      raw = newValue.text.substring(1);
      selection = TextSelection(
        baseOffset: math.max(0, newValue.selection.baseOffset - 1),
        extentOffset: math.max(0, newValue.selection.extentOffset - 1),
      );
    } else {
      raw = newValue.text;
      selection = newValue.selection;
    }

    final normalize = _normalizer(config);
    final oldBody = snapshot.value;
    final prefix = oldBody.substring(0, snapshot.start);
    final suffix = oldBody.substring(snapshot.end);
    final keepsSuffix = snapshot.end < oldBody.length;

    if (raw.length >= prefix.length + suffix.length &&
        raw.startsWith(prefix) &&
        raw.endsWith(suffix)) {
      final inserted = raw.substring(prefix.length, raw.length - suffix.length);
      if (inserted.length == 1) {
        // React blocks a single-character insertion in `beforeinput`.
        final data = normalize(inserted);
        final remaining = oldBody.length - (snapshot.end - snapshot.start);
        if (data.isEmpty || remaining + data.length > config.length) {
          return _displayValue(
            oldBody,
            selection: TextSelection(
              baseOffset: snapshot.start,
              extentOffset: snapshot.end,
            ),
          );
        }
        return _commitTyping(index, raw, selection, snapshot);
      }
      if (inserted.length > 1 && !keepsSuffix) {
        final text =
            (_isBirthDate(config)
                ? _normalizeBirthDate(raw, config.length)
                : null) ??
            normalize(raw);
        return _distribute(index, text, inFormatter: true);
      }
      return _commitTyping(index, raw, selection, snapshot);
    }
    if (raw.length < oldBody.length && _isRangeRemoval(oldBody, raw)) {
      return _commitTyping(index, raw, selection, snapshot);
    }
    return _replaceAll(index, raw);
  }

  static bool _isRangeRemoval(String oldText, String newText) {
    var prefix = 0;
    while (prefix < newText.length && newText[prefix] == oldText[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < newText.length - prefix &&
        newText[newText.length - 1 - suffix] ==
            oldText[oldText.length - 1 - suffix]) {
      suffix++;
    }
    return prefix + suffix == newText.length;
  }

  TextEditingValue _replaceAll(int index, String raw) {
    final config = _configs[index];
    final text =
        (_isBirthDate(config)
            ? _normalizeBirthDate(raw, config.length)
            : null) ??
        _normalizer(config)(raw);
    return _distribute(index, text, inFormatter: true);
  }

  TextEditingValue _commitTyping(
    int index,
    String raw,
    TextSelection selection,
    _Snapshot snapshot,
  ) {
    final config = _configs[index];
    final next = _normalizer(config)(raw);
    if (next.length > config.length) {
      return _displayValue(
        snapshot.value,
        selection: TextSelection(
          baseOffset: snapshot.start,
          extentOffset: snapshot.end,
        ),
      );
    }
    _propose({index: next});

    final typedAtEnd =
        snapshot.start == snapshot.end &&
        snapshot.end == snapshot.value.length &&
        next.length > snapshot.value.length;
    if (typedAtEnd &&
        next.length == config.length &&
        index + 1 < _configs.length &&
        !_segDisabled(index + 1)) {
      _focusSegment(index + 1, caret: 0);
      return _displayValue(next);
    }
    return _displayValue(
      next,
      selection: next == raw
          ? selection
          : TextSelection.collapsed(
              offset: math.min(selection.extentOffset, next.length),
            ),
    );
  }

  /// React `distribute`: fills segments from [start] and moves focus.
  TextEditingValue _distribute(
    int start,
    String text, {
    required bool inFormatter,
  }) {
    final updates = <int, String>{};
    var rest = text;
    var target = start;
    var targetAtStart = false;
    for (var i = start; i < _configs.length; i++) {
      final length = _configs[i].length;
      final chunk = rest.substring(0, math.min(length, rest.length));
      rest = rest.substring(chunk.length);
      updates[i] = chunk;

      final next = i + 1 < _configs.length ? i + 1 : null;
      final isFull = chunk.length == length;
      if (isFull && next != null && !_segDisabled(next)) {
        target = next;
        targetAtStart = true;
      } else {
        target = i;
        targetAtStart = false;
      }
      final canFillNext =
          next != null &&
          !_configs[next].masked &&
          !_segReadOnly(next) &&
          !_segDisabled(next);
      if (!isFull || rest.isEmpty || !canFillNext) break;
    }

    _propose(updates);
    for (final entry in updates.entries) {
      if (entry.key != start || !inFormatter) {
        _setEditorBody(entry.key, entry.value);
      }
    }
    if (target != start || !inFormatter) {
      _focusSegment(target, caret: targetAtStart ? 0 : null);
    }
    return _displayValue(updates[start] ?? '');
  }

  TextEditingValue _backspaceAtStart(int index) {
    final prev = index - 1;
    if (_segReadOnly(index) || prev < 0 || _segDisabled(prev)) {
      return _displayValue('');
    }
    if (!_segReadOnly(prev)) {
      final value = _valueAt(prev);
      if (value.isNotEmpty) {
        final next = value.substring(0, value.length - 1);
        _propose({prev: next});
        _setEditorBody(prev, next);
      }
    }
    _focusSegment(prev);
    return _displayValue('');
  }

  TextEditingValue _commitComposition(
    int index,
    _Snapshot snapshot,
    String raw,
  ) {
    final config = _configs[index];
    final normalize = _normalizer(config);
    final prefix = snapshot.value.substring(0, snapshot.start);
    final suffix = snapshot.value.substring(snapshot.end);
    final keepsSurroundings =
        raw.length >= prefix.length + suffix.length &&
        raw.startsWith(prefix) &&
        raw.endsWith(suffix);
    final inserted = keepsSurroundings
        ? normalize(raw.substring(prefix.length, raw.length - suffix.length))
        : null;
    final next = inserted != null ? '$prefix$inserted$suffix' : normalize(raw);

    if (next.length > config.length) {
      return _displayValue(
        snapshot.value,
        selection: TextSelection(
          baseOffset: snapshot.start,
          extentOffset: snapshot.end,
        ),
      );
    }
    _propose({index: next});

    final typedAtEnd =
        snapshot.start == snapshot.end &&
        snapshot.end == snapshot.value.length &&
        next.length > snapshot.value.length;
    if (typedAtEnd &&
        next.length == config.length &&
        index + 1 < _configs.length &&
        !_segDisabled(index + 1)) {
      _focusSegment(index + 1, caret: 0);
      return _displayValue(next);
    }
    return _displayValue(
      next,
      selection: TextSelection.collapsed(
        offset: inserted != null
            ? prefix.length + inserted.length
            : next.length,
      ),
    );
  }

  /// React `onPaste` for keyboard and toolbar paste.
  Future<void> _paste(int index) async {
    if (_segReadOnly(index) || _segDisabled(index)) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted || index >= _configs.length) return;
    final config = _configs[index];

    var pasted = _normalizer(config)(text);
    var replaceAll = false;
    if (_isBirthDate(config)) {
      final date = _normalizeBirthDate(
        text,
        config.length,
        allowCompact: false,
      );
      if (date != null) {
        pasted = date;
        replaceAll = true;
      }
    }
    if (pasted.isEmpty) return;

    final value = _valueAt(index);
    final snapshot = _snapshotOf(_editors[index].controller.value);
    final start = replaceAll ? 0 : math.min(snapshot.start, value.length);
    final end = replaceAll
        ? value.length
        : math.min(snapshot.end, value.length);

    if (end < value.length) {
      final next = value.substring(0, start) + pasted + value.substring(end);
      if (next.length > config.length) return;
      _propose({index: next});
      _setEditorBody(index, next, caret: start + pasted.length);
      return;
    }
    _distribute(index, value.substring(0, start) + pasted, inFormatter: false);
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (index >= _editors.length) return KeyEventResult.ignored;
    final editor = _editors[index];
    if (editor.composing) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isAltPressed ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    final rtl = _textDirection == TextDirection.rtl;
    final forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final backward = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final masked = _configs[index].masked;
    final snapshot = _snapshotOf(editor.controller.value);
    final collapsed = snapshot.start == snapshot.end;

    if (event.logicalKey == forward) {
      final next = index + 1;
      if (next >= _editors.length || _segDisabled(next)) {
        return KeyEventResult.ignored;
      }
      if (!masked && (!collapsed || snapshot.end != snapshot.value.length)) {
        return KeyEventResult.ignored;
      }
      _focusSegment(next, caret: 0);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == backward) {
      final prev = index - 1;
      if (prev < 0 || _segDisabled(prev)) return KeyEventResult.ignored;
      if (!masked && (!collapsed || snapshot.start != 0)) {
        return KeyEventResult.ignored;
      }
      _focusSegment(prev);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _contextMenu(int index, EditableTextState state) {
    if (SystemContextMenu.isSupportedByField(state)) {
      // Native paste arrives as a text insertion and is distributed then.
      return SystemContextMenu.editableText(editableTextState: state);
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: state.contextMenuAnchors,
      buttonItems: [
        for (final item in state.contextMenuButtonItems)
          item.type == ContextMenuButtonType.paste
              ? item.copyWith(
                  onPressed: () {
                    state.hideToolbar();
                    _paste(index);
                  },
                )
              : item,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = SeedFieldScope.maybeOf(context);
    _rootDisabled =
        widget.disabled ||
        (field?.disabled ?? false) ||
        !SeedControlScope.enabledOf(context);
    _rootReadOnly = widget.readOnly || (field?.readOnly ?? false);
    final invalid = widget.invalid || (field?.isInvalid ?? false);
    final required = widget.required || (field?.required ?? false);
    _textDirection = Directionality.of(context);
    _configs = [
      for (final child in widget.children)
        if (child is SeedSegmentedTextInputSegment && !child._isStatic) child,
    ];
    _ensureEditors();
    _syncFieldRegistration(field);

    final colors = context.seedColor;
    final typography = context.seedTypography;
    final isLarge = widget.size == SeedSegmentedTextInputSize.large;
    final baseStyle = (isLarge ? typography.t5Regular : typography.t4Regular)
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final styles = _Styles(
      value: baseStyle.copyWith(
        color: _rootDisabled ? colors.fg.disabled : colors.fg.neutral,
      ),
      placeholder: baseStyle.copyWith(
        color: _rootDisabled ? colors.fg.disabled : colors.fg.placeholder,
      ),
      separator: baseStyle.copyWith(
        color: _rootDisabled ? colors.fg.disabled : colors.fg.placeholder,
      ),
      staticText: baseStyle.copyWith(
        color: _rootDisabled ? colors.fg.disabled : colors.fg.neutral,
      ),
      caretWidth: isLarge ? 1.5 : 1.0,
      caretHeight: isLarge ? 20.0 : 17.0,
      contentMinHeight: (isLarge ? SeedDimension.x13 : SeedDimension.x10) - 4,
      required: required,
      invalid: invalid,
    );

    final hasFill = widget.children.any(
      (child) =>
          child is SeedSegmentedTextInputSegment &&
          child.sizing == SeedSegmentedTextInputSizing.fill,
    );
    final gap = isLarge ? SeedDimension.x2_5 : SeedDimension.x2;
    final items = <Widget>[];
    final suffixes = <Widget>[];
    var editableIndex = 0;
    for (final child in widget.children) {
      if (child is SeedSegmentedTextInputSegment) {
        items.add(
          child._isStatic
              ? _buildStaticSegment(child, styles)
              : _buildSegment(child, editableIndex++, styles),
        );
      } else if (child is SeedSegmentedTextInputSeparator) {
        items.add(DefaultTextStyle(style: styles.separator, child: child));
      } else if (child is SeedSegmentedTextInputSuffix) {
        suffixes.add(
          Padding(
            padding: EdgeInsetsDirectional.only(start: gap),
            child: child,
          ),
        );
      } else {
        items.add(child);
      }
    }

    // Without `fill` segments the content is scaled down instead of
    // overflowing (large text scales); React clips it.
    final Widget content = hasFill
        ? Row(children: items)
        : Align(
            alignment: AlignmentDirectional.centerStart,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(mainAxisSize: MainAxisSize.min, children: items),
            ),
          );

    final showFocus = _focused && !_rootReadOnly;
    final strokeWidth = showFocus || invalid ? 2.0 : 1.0;
    final strokeColor = invalid
        ? colors.stroke.criticalSolid
        : showFocus
        ? colors.stroke.neutralContrast
        : colors.stroke.neutralWeak;
    final paddingX = isLarge ? SeedDimension.x4 : SeedDimension.x3_5;

    final Widget root = AnimatedContainer(
      duration: SeedDuration.d2,
      curve: SeedCurves.easing,
      constraints: BoxConstraints(
        minHeight: isLarge ? SeedDimension.x13 : SeedDimension.x10,
      ),
      // React paints the stroke as an overlay; keep content in place.
      padding: EdgeInsets.symmetric(horizontal: paddingX - strokeWidth),
      decoration: BoxDecoration(
        color: _rootDisabled || _rootReadOnly
            ? colors.bg.disabled
            : colors.bg.transparent,
        borderRadius: isLarge ? SeedBorderRadius.r3 : SeedBorderRadius.r2,
        border: Border.all(color: strokeColor, width: strokeWidth),
      ),
      child: Row(
        children: [
          Expanded(child: content),
          ...suffixes,
        ],
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticsLabel ?? field?.label,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (focused) {
          if (_focused != focused) setState(() => _focused = focused);
        },
        child: FocusTraversalGroup(child: root),
      ),
    );
  }

  Widget _buildStaticSegment(
    SeedSegmentedTextInputSegment config,
    _Styles styles,
  ) {
    Widget content = DefaultTextStyle(
      style: styles.staticText,
      child: ExcludeSemantics(child: config.staticText!),
    );
    if (config.sizing == SeedSegmentedTextInputSizing.fill) {
      content = Expanded(
        child: Align(
          alignment: config.align == SeedSegmentedTextInputAlign.center
              ? Alignment.center
              : AlignmentDirectional.centerStart,
          child: content,
        ),
      );
    }
    return KeyedSubtree(key: config.key, child: content);
  }

  Widget _buildStaticAffix(Widget child, _Styles styles, {required bool end}) {
    Widget content = child;
    if (child is SeedSegmentedTextInputDots) {
      content = Padding(
        padding: end
            ? const EdgeInsetsDirectional.only(start: SeedDimension.x2)
            : const EdgeInsetsDirectional.only(end: SeedDimension.x2),
        child: child,
      );
    }
    return DefaultTextStyle(
      style: styles.staticText,
      child: ExcludeSemantics(child: content),
    );
  }

  Widget _buildSegment(
    SeedSegmentedTextInputSegment config,
    int index,
    _Styles styles,
  ) {
    final editor = _editors[index];
    final disabled = _segDisabled(index);
    final readOnly = _segReadOnly(index);
    final colors = context.seedColor;
    final valueStyle = disabled
        ? styles.value.copyWith(color: colors.fg.disabled)
        : styles.value;
    final placeholderStyle = disabled
        ? styles.placeholder.copyWith(color: colors.fg.disabled)
        : styles.placeholder;
    final hints = config.masked && (config.autofillHints?.isEmpty ?? true)
        ? null
        : config.autofillHints;

    Widget input = TextField(
      controller: editor.controller,
      focusNode: editor.focusNode,
      enabled: !disabled,
      readOnly: readOnly,
      obscureText: config.masked,
      keyboardType: config.inputMode,
      autofillHints: hints,
      autocorrect: false,
      enableSuggestions: false,
      maxLines: 1,
      inputFormatters: [editor.formatter],
      style: config.masked
          ? valueStyle.copyWith(color: Colors.transparent)
          : valueStyle,
      cursorColor: config.masked ? Colors.transparent : valueStyle.color,
      cursorWidth: styles.caretWidth,
      cursorHeight: styles.caretHeight,
      contextMenuBuilder: (context, state) => _contextMenu(index, state),
      // The app's InputDecorationTheme (including the Seed one) may style
      // enabled/focused borders; a segment never draws its own frame.
      decoration: const InputDecoration.collapsed(hintText: null).copyWith(
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
    if (config.masked) {
      input = TextSelectionTheme(
        data: const TextSelectionThemeData(selectionColor: Colors.transparent),
        child: input,
      );
    }
    input = Actions(
      actions: <Type, Action<Intent>>{
        PasteTextIntent: CallbackAction<PasteTextIntent>(
          onInvoke: (_) {
            _paste(index);
            return null;
          },
        ),
      },
      child: input,
    );
    input = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) => _handleKey(index, event),
      child: input,
    );
    input = Semantics(
      label: config.semanticsLabel,
      isRequired: styles.required ? true : null,
      validationResult: styles.invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      child: input,
    );

    final fill = config.sizing == SeedSegmentedTextInputSizing.fill;
    final stretchValue =
        fill &&
        config.align == SeedSegmentedTextInputAlign.start &&
        config.staticSuffix == null;
    final Widget visual = ListenableBuilder(
      listenable: Listenable.merge([editor.controller, editor.focusNode]),
      builder: (context, _) {
        final body = _strip(editor.controller.text);
        if (config.masked) {
          return _MaskedDots(
            length: config.length,
            filled: body.length,
            showCaret: editor.focusNode.hasFocus && !readOnly,
            filledColor: valueStyle.color!,
            emptyColor: placeholderStyle.color!,
            caretWidth: styles.caretWidth,
            caretHeight: styles.caretHeight,
            lineStyle: valueStyle,
          );
        }
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: 1 + styles.caretWidth),
                child: Text(
                  '0' * config.length,
                  style: valueStyle,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
            if (body.isEmpty && config.placeholder != null)
              PositionedDirectional(
                start: 0,
                end: 0,
                child: ExcludeSemantics(
                  child: Text(
                    config.placeholder!,
                    style: placeholderStyle,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            if (body.isEmpty && config.placeholderWidget != null)
              PositionedDirectional(
                start: 0,
                end: 0,
                child: Align(
                  alignment: config.staticSuffix != null
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: DefaultTextStyle(
                    style: placeholderStyle,
                    child: ExcludeSemantics(child: config.placeholderWidget!),
                  ),
                ),
              ),
          ],
        );
      },
    );

    Widget valueContainer = GestureDetector(
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      onTap: disabled ? null : () => _focusSegment(index),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: styles.contentMinHeight),
        child: Stack(
          // Give the placeholder the same width as the editor in a fill slot.
          fit: stretchValue ? StackFit.passthrough : StackFit.loose,
          alignment: AlignmentDirectional.centerStart,
          children: [
            visual,
            PositionedDirectional(start: 0, end: 0, child: input),
          ],
        ),
      ),
    );

    if (fill) {
      valueContainer = stretchValue
          ? Expanded(child: valueContainer)
          : Flexible(child: valueContainer);
    }
    Widget segment = Row(
      mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: config.align == SeedSegmentedTextInputAlign.center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        if (config.staticPrefix != null)
          _buildStaticAffix(config.staticPrefix!, styles, end: false),
        valueContainer,
        if (config.staticSuffix != null)
          _buildStaticAffix(config.staticSuffix!, styles, end: true),
      ],
    );
    if (fill) segment = Expanded(child: segment);
    return KeyedSubtree(key: config.key, child: segment);
  }
}

class _Styles {
  const _Styles({
    required this.value,
    required this.placeholder,
    required this.separator,
    required this.staticText,
    required this.caretWidth,
    required this.caretHeight,
    required this.contentMinHeight,
    required this.required,
    required this.invalid,
  });

  final TextStyle value, placeholder, separator, staticText;
  final double caretWidth, caretHeight, contentMinHeight;
  final bool required, invalid;
}

/// Masked segment: one dot per position, filled dots for entered
/// characters and a caret after the last entered character.
class _MaskedDots extends StatelessWidget {
  const _MaskedDots({
    required this.length,
    required this.filled,
    required this.showCaret,
    required this.filledColor,
    required this.emptyColor,
    required this.caretWidth,
    required this.caretHeight,
    required this.lineStyle,
  });

  final int length, filled;
  final bool showCaret;
  final Color filledColor, emptyColor;
  final double caretWidth, caretHeight;
  final TextStyle lineStyle;

  Widget _caret(bool visible) => SizedBox(
    width: 0,
    height: caretHeight,
    child: visible
        ? OverflowBox(
            minWidth: caretWidth,
            maxWidth: caretWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: filledColor,
                borderRadius: BorderRadius.circular(caretWidth),
              ),
              child: SizedBox(width: caretWidth, height: caretHeight),
            ),
          )
        : null,
  );

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zero-width line box keeps the row at the text line height.
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: SizedBox(width: 0, child: Text('0', style: lineStyle)),
            ),
            for (var i = 0; i < length; i++) ...[
              if (i > 0) const SizedBox(width: SeedDimension.x1),
              _caret(showCaret && i == filled),
              if (i > 0) const SizedBox(width: SeedDimension.x1),
              _Dot(color: i < filled ? filledColor : emptyColor),
            ],
            _caret(showCaret && filled >= length),
          ],
        ),
      ),
    );
  }
}
