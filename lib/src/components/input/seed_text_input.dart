import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Variant options for [SeedTextInput].
enum SeedTextInputVariant { outline, underline }

/// Size options for [SeedTextInput].
enum SeedTextInputSize { medium, large }

/// Text input component of SEED Design System.
///
/// Supports single-line and multi-line modes, outline/underline styles,
/// clear button, prefix/suffix items, and stateful focus & error highlights.
class SeedTextInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool clearable;
  final bool hasError;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final SeedTextInputVariant variant;
  final SeedTextInputSize size;

  const SeedTextInput({
    super.key,
    this.controller,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.clearable = true,
    this.hasError = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = SeedTextInputVariant.outline,
    this.size = SeedTextInputSize.medium,
  });

  @override
  State<SeedTextInput> createState() => _SeedTextInputState();
}

class _SeedTextInputState extends State<SeedTextInput> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _isFocused = false;
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _hasValue = _controller.text.isNotEmpty;
    _isFocused = _focusNode.hasFocus;

    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(SeedTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final oldController = _controller;
      final owned = _ownsController;
      oldController.removeListener(_handleTextChange);
      _ownsController = widget.controller == null;
      _controller =
          widget.controller ??
          TextEditingController.fromValue(oldController.value);
      _controller.addListener(_handleTextChange);
      _hasValue = _controller.text.isNotEmpty;
      // The old TextField remains attached until this frame finishes rebuilding.
      if (owned) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => oldController.dispose(),
        );
      }
    }
    if (oldWidget.focusNode != widget.focusNode) {
      final oldFocusNode = _focusNode;
      final owned = _ownsFocusNode;
      final hadFocus = oldFocusNode.hasFocus;
      oldFocusNode.removeListener(_handleFocusChange);
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
      _isFocused = _focusNode.hasFocus;
      if (hadFocus && widget.enabled) _focusNode.requestFocus();
      if (owned) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => oldFocusNode.dispose(),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final bool hasVal = _controller.text.isNotEmpty;
    if (hasVal != _hasValue) {
      setState(() => _hasValue = hasVal);
    }
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = _resolveStrokeColor(colors);
    final Color bgColor =
        !widget.enabled ||
            (widget.readOnly && widget.variant == SeedTextInputVariant.outline)
        ? colors.bg.disabled
        : colors.bg.transparent;

    final bool isLarge = widget.size == SeedTextInputSize.large;
    final bool isOutline = widget.variant == SeedTextInputVariant.outline;
    final bool isSingleLine = widget.maxLines == 1;

    final inputStyle = isOutline
        ? (isLarge ? typography.t5Regular : typography.t4Regular)
        : (isLarge ? typography.t6Regular : typography.t5Regular);

    final TextStyle textStyle = inputStyle.copyWith(
      color: !widget.enabled
          ? colors.fg.disabled
          : widget.readOnly && !isOutline
          ? colors.fg.neutralMuted
          : colors.fg.neutral,
    );

    final TextStyle hintStyle = inputStyle.copyWith(
      color: !widget.enabled
          ? colors.fg.disabled
          : widget.readOnly && !isOutline
          ? colors.fg.neutralMuted
          : colors.fg.placeholder,
    );

    final double minHeight = isSingleLine
        ? (isOutline ? (isLarge ? 52.0 : 40.0) : (isLarge ? 40.0 : 34.0))
        : (isLarge ? 94.0 : 82.0);

    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: isOutline ? (isLarge ? 16.0 : 14.0) : 0.0,
      vertical: isSingleLine
          ? (isOutline ? 6.0 : (isLarge ? 8.0 : 6.0))
          : (isLarge ? 14.0 : 12.0),
    );

    final double gap = isLarge ? 10.0 : 8.0;

    final double iconSize = isOutline
        ? (isLarge ? 20.0 : 16.0)
        : (isLarge ? 24.0 : 20.0);

    final double clearButtonSize = isLarge ? 22.0 : 18.0;

    Widget fieldWidget = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      style: textStyle,
      onChanged: widget.onChanged,
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

    return AnimatedContainer(
      duration: SeedDuration.d2,
      curve: SeedCurves.easing,
      constraints: BoxConstraints(
        minHeight: minHeight,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isOutline
            ? (isLarge ? SeedBorderRadius.r3 : SeedBorderRadius.r2)
            : BorderRadius.zero,
        border: isOutline
            ? Border.all(
                color: strokeColor,
                width: _isFocused || widget.hasError ? 2 : 1,
              )
            : Border(
                bottom: BorderSide(
                  color: strokeColor,
                  width: _isFocused || widget.hasError ? 2 : 1,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: isSingleLine
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (widget.prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: widget.enabled
                    ? colors.fg.neutralMuted
                    : colors.fg.disabled,
                size: iconSize,
              ),
              child: widget.prefixIcon!,
            ),
            SizedBox(width: gap),
          ],
          Expanded(child: fieldWidget),
          if (widget.clearable &&
              _hasValue &&
              widget.enabled &&
              !widget.readOnly) ...[
            const SizedBox(width: SeedDimension.x1),
            SeedPressable(
              semanticsLabel: '입력 내용 지우기',
              enableScale: false,
              onTap: () {
                _controller.clear();
                widget.onChanged?.call('');
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
          if (widget.suffixIcon != null) ...[
            SizedBox(width: gap),
            IconTheme(
              data: IconThemeData(
                color: widget.enabled
                    ? colors.fg.neutralMuted
                    : colors.fg.disabled,
                size: iconSize,
              ),
              child: widget.suffixIcon!,
            ),
          ],
        ],
      ),
    );
  }

  Color _resolveStrokeColor(SeedColorScheme colors) {
    if (!widget.enabled) return colors.stroke.neutralWeak;
    if (widget.hasError) {
      return colors.stroke.criticalSolid;
    }
    if (_isFocused) {
      return colors.stroke.neutralContrast;
    }
    return colors.stroke.neutralWeak;
  }
}
