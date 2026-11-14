import 'dart:ui' show SemanticsInputType;

import 'package:flutter/semantics.dart' show SemanticsValidationResult;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_control.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../localization/seed_localizations.dart';
import '../../theme/seed_theme.dart';
import 'seed_text_input.dart';

/// Search input of SEED Design System.
///
/// Mirrors the official React `SearchInput` (`SearchInput.Root`,
/// `SearchInput.Input` and `SearchInput.ClearButton`) as composed by the
/// registry `search-input` snippet: a filled 44px field whose keyboard shows a
/// search action and whose clear button appears only while there is a value.
///
/// Submitting with the keyboard calls [onSubmit] with the current value and,
/// unless [blurOnSubmit] is false, removes focus so the soft keyboard closes.
/// A focus request made in [onSubmit] takes priority over that blur.
/// The clear button empties the value, reports `''` through [onValueChange]
/// and leaves the input focus where it was: a focused input stays focused,
/// and activating the button with the keyboard moves focus back to the input.
class SeedSearchInput extends StatefulWidget {
  /// Optional externally owned editing controller.
  /// Cannot be combined with [value] or [defaultValue].
  final TextEditingController? controller;

  /// Controlled value; the parent stays authoritative after edits.
  final String? value;

  /// Uncontrolled initial value, read once when the input is created.
  final String? defaultValue;

  /// Called with the new text after user edits and after the clear button
  /// empties the input (with `''`). Official `onValueChange(value)`.
  final ValueChanged<String>? onValueChange;

  /// Called with the current value when the keyboard search action (or a
  /// hardware Enter) submits the input. Official `onSubmit(value)`.
  final ValueChanged<String>? onSubmit;

  /// Whether submitting removes focus from the input, which also dismisses
  /// the on-screen keyboard. Defaults to true, as in the official API.
  final bool blurOnSubmit;

  /// Placeholder shown while the input is empty.
  final String? placeholder;

  /// Accessible name of the input, the official `aria-label`.
  /// When null, the localized [SeedLabel.search] ("검색") is used.
  final String? semanticsLabel;

  /// Accessible name of the clear button. When null, the localized
  /// [SeedLabel.clearSearch] ("지우기") is used, as in the registry snippet.
  final String? clearButtonLabel;

  /// Whether editing is enabled (default true). The official `disabled` is
  /// `!enabled`. A disabled [SeedFieldset] also disables the input. The clear
  /// button is hidden while disabled.
  final bool enabled;

  /// Whether the text is read-only (default false). The clear button is
  /// hidden while read-only.
  final bool readOnly;

  /// Required accessibility state (default false); does not validate.
  final bool required;

  /// Invalid accessibility state (default false); has no visual effect, as
  /// the official search-input recipe defines no invalid style.
  final bool invalid;

  /// Optional externally owned focus node, otherwise one is created internally.
  final FocusNode? focusNode;

  /// Whether to request focus when first built (default false).
  final bool autofocus;

  /// Flutter character-length limit delegated to the underlying [TextField].
  final int? maxLength;

  /// Flutter input formatters applied to user edits.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether platform autocorrection is enabled (default true).
  final bool autocorrect;

  /// Whether platform suggestions are enabled (default true).
  final bool enableSuggestions;

  /// Called for a pointer down outside the input and its clear button.
  /// When null, Flutter's default text-field behavior applies.
  final TapRegionCallback? onTapOutside;

  /// Creates a search input.
  ///
  /// [value] makes the input controlled, [defaultValue] seeds an uncontrolled
  /// input and [controller] hands ownership of the text to the caller. A
  /// controller cannot be combined with either value; if [value] and
  /// [defaultValue] are both supplied, [value] takes precedence.
  /// [blurOnSubmit] and [enabled] default to true; [readOnly],
  /// [required], [invalid] and [autofocus] default to false. The labels
  /// default to the localized "검색" and "지우기".
  const SeedSearchInput({
    super.key,
    this.controller,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.onSubmit,
    this.blurOnSubmit = true,
    this.placeholder,
    this.semanticsLabel,
    this.clearButtonLabel,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.invalid = false,
    this.focusNode,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onTapOutside,
  }) : assert(
         controller == null || (value == null && defaultValue == null),
         'A controller cannot be combined with value or defaultValue.',
       );

  /// Root height from `search-input.yaml` (`root.height`, 44px).
  static const double height = 44;

  /// Creates the state that owns the default controller and focus nodes.
  @override
  State<SeedSearchInput> createState() => _SeedSearchInputState();
}

class _SeedSearchInputState extends State<SeedSearchInput> {
  late TextEditingController _controller;
  late bool _ownsController;
  FocusNode? _internalFocusNode;
  final FocusNode _clearFocusNode = FocusNode(
    debugLabel: 'SeedSearchInput clear',
  );
  bool _hasValue = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        TextEditingController(text: widget.value ?? widget.defaultValue);
    _hasValue = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(SeedSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final old = _controller;
      old.removeListener(_handleTextChange);
      final wasOwned = _ownsController;
      _ownsController = widget.controller == null;
      _controller =
          widget.controller ?? TextEditingController.fromValue(old.value);
      if (wasOwned) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
      _controller.addListener(_handleTextChange);
      _hasValue = _controller.text.isNotEmpty;
    }
    if (_ownsController &&
        widget.value != null &&
        _controller.text != widget.value) {
      _syncControlledValue(widget.value!);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (_ownsController) _controller.dispose();
    _internalFocusNode?.dispose();
    _clearFocusNode.dispose();
    super.dispose();
  }

  void _syncControlledValue(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _handleTextChange() {
    final hasValue = _controller.text.isNotEmpty;
    if (hasValue != _hasValue) setState(() => _hasValue = hasValue);
  }

  void _notifyChange(String value) {
    widget.onValueChange?.call(value);
    // A controlled parent that keeps its value rejects the edit.
    if (_ownsController && widget.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_ownsController || widget.value == null) return;
        if (_controller.text != widget.value) {
          _syncControlledValue(widget.value!);
        }
      });
    }
  }

  // Replaces EditableText's default finalization so focus follows
  // blurOnSubmit instead of always being dropped.
  void _handleEditingComplete() {
    _controller.clearComposing();
    final value = _controller.text;
    // Schedule the blur first so a focus request in onSubmit can take priority.
    if (widget.blurOnSubmit) _focusNode.unfocus();
    widget.onSubmit?.call(value);
  }

  void _handleClear() {
    // SeedPressable requests focus for the button before calling onTap, but
    // focus changes apply in a microtask, so primaryFocus is still the focus
    // from before the activation here.
    final previous = FocusManager.instance.primaryFocus;
    final activatedFromButton = previous == _clearFocusNode;
    final shouldFocusInput = activatedFromButton || _focusNode.hasFocus;

    _controller.clear();
    _notifyChange('');

    if (shouldFocusInput) {
      // The button is about to disappear; keep editing in the input.
      _focusNode.requestFocus();
    } else if (previous != null) {
      // Pointer activation of an unfocused input: cancel the button's own
      // focus request so focus stays where it was (React's mousedown
      // preventDefault).
      previous.requestFocus();
    } else {
      _clearFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && SeedControlScope.enabledOf(context);
    final readOnly = widget.readOnly;
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final valueStyle = typography.t6Regular.copyWith(color: colors.fg.neutral);
    final placeholderStyle = typography.t6Regular.copyWith(
      color: colors.fg.placeholder,
    );
    final showClear = _hasValue && enabled && !readOnly;

    final input = Semantics(
      label:
          widget.semanticsLabel ??
          SeedLocalizations.label(context, SeedLabel.search),
      inputType: SemanticsInputType.search,
      isRequired: widget.required ? true : null,
      validationResult: widget.invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: widget.autofocus,
        maxLines: 1,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        onTapOutside: widget.onTapOutside,
        contextMenuBuilder: SeedTextInput.defaultContextMenuBuilder,
        style: valueStyle,
        onChanged: _notifyChange,
        onEditingComplete: _handleEditingComplete,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.placeholder,
          hintStyle: placeholderStyle,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );

    return Container(
      height: SeedSearchInput.height,
      padding: const EdgeInsets.only(
        left: SeedDimension.x4,
        right: SeedDimension.x1,
      ),
      decoration: BoxDecoration(
        color: colors.bg.neutralWeak,
        borderRadius: SeedBorderRadius.r2_5,
      ),
      child: Row(
        children: [
          Expanded(child: input),
          if (showClear)
            // Groups the button with the text field so a pointer down on it
            // is not a tap outside that would unfocus the input.
            TextFieldTapRegion(
              child: SeedPressable(
                focusNode: _clearFocusNode,
                semanticsLabel:
                    widget.clearButtonLabel ??
                    SeedLocalizations.label(context, SeedLabel.clearSearch),
                focusBorderRadius: const BorderRadius.all(
                  Radius.circular(SeedRadius.full),
                ),
                focusRingInside: true,
                onTap: _handleClear,
                child: Padding(
                  padding: const EdgeInsets.all(SeedDimension.x3),
                  child: Icon(
                    Icons.cancel,
                    size: SeedDimension.x5,
                    color: colors.fg.neutralSubtle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
