import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;
import 'package:flutter/services.dart';

import 'seed_field.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Variant options for [SeedTextInput].
enum SeedTextInputVariant {
  outline,

  underline,
}

/// Size options for [SeedTextInput].
///
/// [large] is the default for all viewports. [medium] is a compact desktop size.
enum SeedTextInputSize {
  medium,

  large,
}

class SeedTextValueChange {
  SeedTextValueChange(this.value, {int? maxGraphemeCount})
    : graphemes = List.unmodifiable(value.characters),
      slicedGraphemes = List.unmodifiable(
        maxGraphemeCount == null
            ? value.characters
            : value.characters.take(maxGraphemeCount),
      );
  final String value;
  final List<String> graphemes;
  final List<String> slicedGraphemes;
  String get slicedValue => slicedGraphemes.join();
}

/// Text input component of SEED Design System.
///
/// Supports single-line and multi-line modes, outline/underline styles,
/// clear button, prefix/suffix items, and stateful focus & error highlights.
class SeedTextInput extends StatefulWidget {
  static Widget defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState state,
  ) {
    if (SystemContextMenu.isSupportedByField(state)) {
      return SystemContextMenu.editableText(editableTextState: state);
    }
    return AdaptiveTextSelectionToolbar.editableText(editableTextState: state);
  }

  final TextEditingController? controller;
  final String? value;

  final String? hintText;
  String? get placeholder => hintText;

  /// One-time seed; prefer [defaultValue] in new code.
  @Deprecated('Use defaultValue instead.')
  final String? initialValue;
  String? get defaultValue => initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final bool autofocus;
  final bool obscureText;
  final bool clearable;
  @Deprecated('Use invalid instead.')
  final bool hasError;
  bool get invalid => hasError;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final SeedTextInputVariant variant;
  final SeedTextInputSize size;
  final bool responsive;
  final String? prefixText;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget Function(BuildContext, TextEditingController, FocusNode)?
  inputBuilder;
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<SeedTextValueChange>? onValueChanged;
  ValueChanged<SeedTextValueChange>? get onValueChange => onValueChanged;
  final int? maxGraphemeCount;
  final bool autoResize;
  final double? maxHeight;
  final String? semanticsLabel;
  // Flutter input extensions, independent of React value ownership.
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;
  final String? restorationId;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final EdgeInsets scrollPadding;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final Color? cursorColor;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final UndoHistoryController? undoController;
  final bool canRequestFocus;
  final MaxLengthEnforcement? maxLengthEnforcement;

  const SeedTextInput({
    super.key,
    this.controller,
    this.value,
    String? placeholder,
    String? hintText,
    @Deprecated('Use defaultValue instead.') String? initialValue,
    String? defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.autofocus = false,
    this.obscureText = false,
    this.clearable = false,
    bool? invalid,
    @Deprecated('Use invalid instead.') bool? hasError,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.restorationId,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20),
    this.onTapOutside,
    this.onTap,
    this.onEditingComplete,
    this.cursorColor,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.contextMenuBuilder = SeedTextInput.defaultContextMenuBuilder,
    this.smartDashesType,
    this.smartQuotesType,
    this.undoController,
    this.canRequestFocus = true,
    this.maxLengthEnforcement,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = SeedTextInputVariant.outline,
    this.size = SeedTextInputSize.large,
    this.responsive = false,
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
    this.inputBuilder,
    ValueChanged<SeedTextValueChange>? onValueChange,
    @Deprecated('Use onValueChange instead.')
    ValueChanged<SeedTextValueChange>? onValueChanged,
    this.maxGraphemeCount,
    this.autoResize = false,
    this.maxHeight,
    this.semanticsLabel,
  }) : hasError = invalid ?? hasError ?? false,
       assert(invalid == null || hasError == null),
       hintText = placeholder ?? hintText,
       assert(placeholder == null || hintText == null),
       onValueChanged = onValueChange ?? onValueChanged,
       assert(onValueChange == null || onValueChanged == null),
       initialValue = defaultValue ?? initialValue,
       assert(defaultValue == null || initialValue == null),
       assert(
         controller == null ||
             (value == null && defaultValue == null && initialValue == null),
         'A controller cannot be combined with value or an initial seed.',
       );

  /// Creates a multiline textarea input that auto-resizes by default,
  /// matching React's `<TextFieldTextarea>`.
  const SeedTextInput.textarea({
    super.key,
    this.controller,
    this.value,
    String? placeholder,
    String? hintText,
    @Deprecated('Use defaultValue instead.') String? initialValue,
    String? defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.autofocus = false,
    this.obscureText = false,
    this.clearable = false,
    bool? invalid,
    @Deprecated('Use invalid instead.') bool? hasError,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.keyboardType = TextInputType.multiline,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.restorationId,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20),
    this.onTapOutside,
    this.onTap,
    this.onEditingComplete,
    this.cursorColor,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.contextMenuBuilder = SeedTextInput.defaultContextMenuBuilder,
    this.smartDashesType,
    this.smartQuotesType,
    this.undoController,
    this.canRequestFocus = true,
    this.maxLengthEnforcement,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = SeedTextInputVariant.outline,
    this.size = SeedTextInputSize.large,
    this.responsive = false,
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
    this.inputBuilder,
    ValueChanged<SeedTextValueChange>? onValueChange,
    @Deprecated('Use onValueChange instead.')
    ValueChanged<SeedTextValueChange>? onValueChanged,
    this.maxGraphemeCount,
    this.autoResize = true,
    this.maxHeight,
    this.semanticsLabel,
  }) : hasError = invalid ?? hasError ?? false,
       assert(invalid == null || hasError == null),
       hintText = placeholder ?? hintText,
       assert(placeholder == null || hintText == null),
       onValueChanged = onValueChange ?? onValueChanged,
       assert(onValueChange == null || onValueChanged == null),
       initialValue = defaultValue ?? initialValue,
       assert(defaultValue == null || initialValue == null),
       assert(
         controller == null ||
             (value == null && defaultValue == null && initialValue == null),
         'A controller cannot be combined with value or an initial seed.',
       );

  @override
  State<SeedTextInput> createState() => _SeedTextInputState();
}

class _SeedTextInputState extends State<SeedTextInput> with RestorationMixin {
  late final RestorableTextEditingController _restorableController;
  bool _controllerRegistered = false;
  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    _controller.removeListener(_handleTextChange);
    if (_ownsController && !_controllerRegistered) _controller.dispose();
    registerForRestoration(_restorableController, 'text');
    _controllerRegistered = true;
    if (_ownsController) {
      _controller = _restorableController.value;
      if (widget.value != null) _controller.text = widget.value!;
    }
    _hasValue = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _isFocused = false;
  bool _hasValue = false;
  SeedFieldScope? _fieldScope;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _restorableController = RestorableTextEditingController(
      text: widget.value ?? widget.initialValue,
    );
    _controller =
        widget.controller ??
        TextEditingController(text: widget.value ?? widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _hasValue = _controller.text.isNotEmpty;
    _isFocused = _focusNode.hasFocus;

    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fieldScope?.unregisterFocusNode?.call(_focusNode);
    _fieldScope = SeedFieldScope.maybeOf(context);
    _updateFocusNode(widget.focusNode ?? _fieldScope?.focusNode);
    _fieldScope?.registerFocusNode?.call(_focusNode);
  }

  void _updateFocusNode(FocusNode? node) {
    if (node == _focusNode || (node == null && _ownsFocusNode)) return;
    final old = _focusNode;
    final owned = _ownsFocusNode;
    final hadFocus = old.hasFocus;
    _fieldScope?.unregisterFocusNode?.call(old);
    old.removeListener(_handleFocusChange);
    _focusNode = node ?? FocusNode();
    _ownsFocusNode = node == null;
    _focusNode.addListener(_handleFocusChange);
    _isFocused = _focusNode.hasFocus;
    _fieldScope?.registerFocusNode?.call(_focusNode);
    if (hadFocus && widget.enabled) _focusNode.requestFocus();
    if (owned) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  void _syncControlledValue(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  void didUpdateWidget(SeedTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final oldController = _controller;
      oldController.removeListener(_handleTextChange);
      _ownsController = widget.controller == null;
      if (_ownsController) {
        _restorableController.value.value = oldController.value;
      }
      _controller = widget.controller ?? _restorableController.value;
      _controller.addListener(_handleTextChange);
      _hasValue = _controller.text.isNotEmpty;
    }
    if (_ownsController &&
        widget.value != null &&
        _controller.text != widget.value) {
      _syncControlledValue(widget.value!);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _updateFocusNode(widget.focusNode ?? _fieldScope?.focusNode);
    }
  }

  @override
  void dispose() {
    _fieldScope?.unregisterFocusNode?.call(_focusNode);
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    _restorableController.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final bool hasVal = _controller.text.isNotEmpty;
    if (hasVal != _hasValue) {
      setState(() => _hasValue = hasVal);
    }
  }

  void _notifyChange(String value) {
    widget.onChanged?.call(value);
    widget.onValueChanged?.call(
      SeedTextValueChange(value, maxGraphemeCount: widget.maxGraphemeCount),
    );
    if (_ownsController && widget.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_ownsController || widget.value == null) return;
        if (_controller.text != widget.value) {
          _syncControlledValue(widget.value!);
        }
      });
    }
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) =>
      UnmanagedRestorationScope(bucket: bucket, child: _buildInput(context));

  Widget _buildInput(BuildContext context) {
    final field = SeedFieldScope.maybeOf(context);
    final enabled = widget.enabled && !(field?.disabled ?? false);
    final readOnly = widget.readOnly || (field?.readOnly ?? false);
    final hasError = widget.hasError || (field?.isInvalid ?? false);
    final effectiveSize = widget.responsive
        ? (MediaQuery.sizeOf(context).width >= 1280
              ? SeedTextInputSize.medium
              : SeedTextInputSize.large)
        : widget.size;
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = _resolveStrokeColor(
      colors,
      enabled: enabled,
      readOnly: readOnly,
      hasError: hasError,
    );
    final Color bgColor =
        !enabled || (readOnly && widget.variant == SeedTextInputVariant.outline)
        ? colors.bg.disabled
        : colors.bg.transparent;

    final bool isLarge = effectiveSize == SeedTextInputSize.large;
    final bool isOutline = widget.variant == SeedTextInputVariant.outline;
    final bool isSingleLine = !widget.autoResize && widget.maxLines == 1;
    final bool showFocusStroke = _isFocused && !readOnly;

    final inputStyle = isOutline
        ? (isLarge ? typography.t5Regular : typography.t4Regular)
        : (isLarge ? typography.t6Regular : typography.t5Regular);

    final TextStyle textStyle = inputStyle.copyWith(
      color: !enabled
          ? colors.fg.disabled
          : readOnly && !isOutline
          ? colors.fg.neutralMuted
          : colors.fg.neutral,
    );

    final TextStyle affixTextStyle = inputStyle.copyWith(
      color: enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
    );

    final TextStyle hintStyle = inputStyle.copyWith(
      color: !enabled
          ? colors.fg.disabled
          : readOnly && !isOutline
          ? colors.fg.neutralMuted
          : colors.fg.placeholder,
    );

    final double minHeight = isSingleLine
        ? (isOutline ? (isLarge ? 52.0 : 40.0) : (isLarge ? 40.0 : 34.0))
        : (isLarge ? 94.0 : 82.0);

    // React paints the stroke as an overlay, so stroke changes never move the
    // content. A Container border is added to its padding; subtract it here.
    final double strokeWidth = showFocusStroke || hasError ? 2 : 1;
    final double paddingY = isSingleLine
        ? (isOutline ? 6.0 : (isLarge ? 8.0 : 6.0))
        : (isLarge ? 14.0 : 12.0);
    final EdgeInsets padding = isOutline
        ? EdgeInsets.symmetric(
            horizontal: (isLarge ? 16.0 : 14.0) - strokeWidth,
            vertical: paddingY - strokeWidth,
          )
        : EdgeInsets.only(top: paddingY, bottom: paddingY - strokeWidth);

    final double gap = isLarge ? 10.0 : 8.0;

    final double iconSize = isOutline
        ? (isLarge ? 20.0 : 16.0)
        : (isLarge ? 24.0 : 20.0);

    final double clearButtonSize = isLarge ? 22.0 : 18.0;

    Widget fieldWidget =
        widget.inputBuilder?.call(context, _controller, _focusNode) ??
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: widget.autofocus,
          obscureText: widget.obscureText,
          maxLines: widget.autoResize ? null : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          textCapitalization: widget.textCapitalization,
          restorationId: widget.restorationId,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          scrollPadding: widget.scrollPadding,
          onTapOutside: widget.onTapOutside,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          cursorColor: widget.cursorColor,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          selectionControls: widget.selectionControls,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          undoController: widget.undoController,
          canRequestFocus: widget.canRequestFocus,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          contextMenuBuilder: widget.contextMenuBuilder,
          style: textStyle,
          onChanged: _notifyChange,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            hintStyle: hintStyle,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            filled: false,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            counterText: '',
          ),
        );
    if (widget.maxHeight != null) {
      fieldWidget = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: fieldWidget,
      );
    }

    Widget container = AnimatedContainer(
      duration: SeedDuration.d2,
      curve: SeedCurves.easing,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isOutline
            ? (isLarge ? SeedBorderRadius.r3 : SeedBorderRadius.r2)
            : BorderRadius.zero,
        border: isOutline
            ? Border.all(color: strokeColor, width: strokeWidth)
            : Border(
                bottom: BorderSide(color: strokeColor, width: strokeWidth),
              ),
      ),
      child: Row(
        crossAxisAlignment: isSingleLine
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (widget.prefixText != null) ...[
            Text(widget.prefixText!, style: affixTextStyle),
            SizedBox(width: gap),
          ],
          if (widget.prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: enabled ? colors.fg.neutralMuted : colors.fg.disabled,
                size: iconSize,
              ),
              child: widget.prefixIcon!,
            ),
            SizedBox(width: gap),
          ],
          Expanded(child: fieldWidget),
          if (widget.clearable && _hasValue && enabled && !readOnly) ...[
            const SizedBox(width: SeedDimension.x1),
            SeedPressable(
              semanticsLabel: SeedLocalizations.label(
                context,
                SeedLabel.clearInput,
              ),
              enableScale: false,
              onTap: () {
                _controller.clear();
                _notifyChange('');
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: Container(
                    width: clearButtonSize,
                    height: clearButtonSize,
                    decoration: BoxDecoration(
                      color: colors.fg.placeholder,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      size: clearButtonSize * 0.7,
                      color: colors.bg.layerDefault,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (widget.suffixText != null) ...[
            SizedBox(width: gap),
            Text(widget.suffixText!, style: affixTextStyle),
          ],
          if (widget.suffixIcon != null) ...[
            SizedBox(width: gap),
            IconTheme(
              data: IconThemeData(
                color: enabled ? colors.fg.neutralMuted : colors.fg.disabled,
                size: iconSize,
              ),
              child: widget.suffixIcon!,
            ),
          ],
        ],
      ),
    );

    if (field == null &&
        (widget.semanticsLabel != null || widget.required || widget.hasError)) {
      container = Semantics(
        label: widget.semanticsLabel,
        isRequired: widget.required ? true : null,
        validationResult: widget.hasError
            ? SemanticsValidationResult.invalid
            : SemanticsValidationResult.none,
        child: container,
      );
    }

    return container;
  }

  Color _resolveStrokeColor(
    SeedColorScheme colors, {
    required bool enabled,
    required bool readOnly,
    required bool hasError,
  }) {
    if (!enabled) return colors.stroke.neutralWeak;
    if (hasError) {
      return colors.stroke.criticalSolid;
    }
    if (_isFocused && !readOnly) {
      return colors.stroke.neutralContrast;
    }
    return colors.stroke.neutralWeak;
  }
}
