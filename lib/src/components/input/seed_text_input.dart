import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Variant options for [SeedTextInput].
enum SeedTextInputVariant { outline, underline }

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
    final Color bgColor = !widget.enabled
        ? colors.bg.disabled
        : (widget.variant == SeedTextInputVariant.outline
              ? colors.bg.layerDefault
              : colors.bg.transparent);

    final TextStyle textStyle = typography.t4Regular.copyWith(
      color: widget.enabled ? colors.fg.neutral : colors.fg.disabled,
    );

    final TextStyle hintStyle = typography.t4Regular.copyWith(
      color: colors.fg.placeholder,
    );

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
      duration: SeedDuration.colorTransition,
      curve: SeedCurves.easing,
      constraints: BoxConstraints(
        minHeight: widget.maxLines == 1 ? 48.0 : 80.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: widget.variant == SeedTextInputVariant.outline
            ? SeedBorderRadius.r2_5
            : BorderRadius.zero,
        border: widget.variant == SeedTextInputVariant.outline
            ? Border.all(color: strokeColor, width: _isFocused ? 1.5 : 1.0)
            : Border(
                bottom: BorderSide(
                  color: strokeColor,
                  width: _isFocused ? 1.5 : 1.0,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: widget.maxLines == 1
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (widget.prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: widget.enabled
                    ? colors.fg.neutralSubtle
                    : colors.fg.disabled,
                size: 20.0,
              ),
              child: widget.prefixIcon!,
            ),
            const SizedBox(width: SeedDimension.x2),
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
                    width: 18.0,
                    height: 18.0,
                    decoration: BoxDecoration(
                      color: colors.fg.placeholder,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      size: 14.0,
                      color: colors.bg.layerDefault,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (widget.suffixIcon != null) ...[
            const SizedBox(width: SeedDimension.x2),
            IconTheme(
              data: IconThemeData(
                color: widget.enabled
                    ? colors.fg.neutralSubtle
                    : colors.fg.disabled,
                size: 20.0,
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
      return colors.stroke.focusRing;
    }
    return colors.stroke.neutralWeak;
  }
}
