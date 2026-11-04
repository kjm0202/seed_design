import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';

import 'seed_field.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Size of [SeedInputButton].
enum SeedInputButtonSize {
  /// 52px, the official default.
  large(height: 52.0, paddingX: 16.0),

  /// 40px, intended for desktop use.
  medium(height: 40.0, paddingX: 14.0),

  /// Deprecated alias for [medium], also 40 logical pixels high.
  @Deprecated('Use medium instead. Note that medium is now 40px.')
  small(height: 40.0, paddingX: 14.0),

  /// Large below the official 1280px breakpoint, medium at and above it.
  responsive(height: 52.0, paddingX: 16.0);

  /// Defines size metrics [height] and [paddingX] in logical pixels.
  const SeedInputButtonSize({required this.height, required this.paddingX});
  /// Minimum height of this size variant in logical pixels.
  final double height;
  /// Horizontal padding of this size variant in logical pixels.
  final double paddingX;
}

/// A SEED Design Input Button component.
///
/// Looks like an input field but functions as an interactive button that opens
/// pickers, sheets, or modal selections.
class SeedInputButton extends StatelessWidget {
  /// Creates a button styled as an input for opening selection surfaces.
  /// [value] or [valueChild] supplies visible content; [placeholder] is the
  /// fallback. [prefixIcon], [suffixIcon], [prefixText] and [suffixText]
  /// decorate it. [showDefaultSuffix] defaults to true, [showClear] to false
  /// and [onClear] handles clearing. [onPressed] handles activation.
  /// [size] defaults to large (52px). [invalid] styles errors, while [isError]
  /// is a compatibility alias. [enabled] defaults to true, [readOnly] false.
  /// [expanded], [focusNode] and [semanticsLabel] configure Flutter semantics
  /// and focus; [contentScale] is a Flutter-only press effect (default false).
  const SeedInputButton({
    super.key,
    this.value,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.showDefaultSuffix = true,
    this.showClear = false,
    this.onClear,
    this.onPressed,
    this.size = SeedInputButtonSize.large,
    bool? invalid,
    @Deprecated('Use invalid instead.') bool? isError,
    this.enabled = true,
    this.readOnly = false,
    this.expanded,
    this.prefixText,
    this.suffixText,
    this.valueChild,
    this.focusNode,
    this.contentScale = false,
    this.semanticsLabel,
  }) : isError = invalid ?? isError ?? false,
       assert(invalid == null || isError == null);

  /// Currently selected or displayed value.
  final String? value;

  /// Accessible name, like the official trigger `aria-label`. Defaults to the
  /// surrounding [SeedField] label; the shown text stays the value.
  final String? semanticsLabel;

  /// Placeholder text when [value] is null or empty.
  final String? placeholder;

  /// Optional prefix icon widget.
  final Widget? prefixIcon;

  /// Optional suffix icon widget. Defaults to a down chevron.
  final Widget? suffixIcon;

  /// Whether to display a clear button when [value] is not empty.
  final bool showClear;

  /// Callback when the clear button is pressed.
  final VoidCallback? onClear;

  /// Callback when the button is tapped.
  final VoidCallback? onPressed;

  /// The size variant of the input button.
  final SeedInputButtonSize size;

  /// False when the button has no affordance of its own, as in FieldButton.
  final bool showDefaultSuffix;
  /// Legacy stored invalid-state flag; prefer [invalid].
  @Deprecated('Use invalid instead.')
  final bool isError;
  /// React-aligned invalid state, default false.
  bool get invalid => isError;

  /// Whether the button is enabled for interaction.
  final bool enabled;
  /// When true, blocks activation and clearing while showing content.
  final bool readOnly;
  /// Optional [SeedPressable] expansion behavior.
  final bool? expanded;
  /// Text prefix placed before the selected value.
  final String? prefixText;
  /// Text suffix placed after the selected value.
  final String? suffixText;
  /// Custom displayed value widget instead of ordinary text.
  final Widget? valueChild;
  /// Optional focus node; defaults to an enclosing Field focus node.
  final FocusNode? focusNode;

  /// Scales the content while pressed, as React's Select trigger does.
  /// React's FieldButton keeps its content at rest, which is the default.
  final bool contentScale;

  // The official trigger is named by its <label>, with the shown text as its
  // value, instead of being named by the value alone.
  static Widget _labelled(String? label, String? shown, Widget child) =>
      label == null
      ? child
      : Semantics(
          label: label,
          value: shown,
          excludeSemantics: true,
          child: child,
        );

  @override
  Widget build(BuildContext context) {
    final field = SeedFieldScope.maybeOf(context);
    final enabled = this.enabled && !(field?.disabled ?? false);
    final readOnly = this.readOnly || (field?.readOnly ?? false);
    final isError = this.isError || (field?.isInvalid ?? false);
    final size = this.size == SeedInputButtonSize.responsive
        ? (MediaQuery.sizeOf(context).width >= 1280
              ? SeedInputButtonSize.medium
              : SeedInputButtonSize.large)
        : this.size;
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final hasValue = valueChild != null || (value != null && value!.isNotEmpty);

    Color borderColor;
    if (!enabled) {
      borderColor = colors.stroke.neutralWeak;
    } else if (isError) {
      borderColor = colors.stroke.criticalSolid;
    } else {
      borderColor = colors.stroke.neutralWeak;
    }

    final effectiveBg = enabled && !readOnly
        ? colors.bg.transparent
        : colors.bg.disabled;

    final effectiveTextColor = !enabled
        ? colors.fg.disabled
        : (hasValue ? colors.fg.neutral : colors.fg.placeholder);

    final isLarge = size == SeedInputButtonSize.large;
    final double gap = isLarge ? 10 : 8;
    final affixStyle = (isLarge ? typography.t5Regular : typography.t4Regular)
        .copyWith(
          color: enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
        );
    // The official stroke is an overlay and never moves the content.
    final double strokeWidth = isError ? 2 : 1;

    return Semantics(
      readOnly: readOnly ? true : null,
      child: SeedPressable(
        focusNode: focusNode ?? field?.focusNode,
        enabled: enabled && !readOnly,
        enableScale: false,
        expanded: expanded,
        onTap: enabled && !readOnly ? onPressed : null,
        builder: (context, isPressed) {
          final content = Row(
            children: [
              if (prefixText != null) ...[
                Text(prefixText!, style: affixStyle),
                SizedBox(width: gap),
              ],
              if (prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: size == SeedInputButtonSize.large ? 20 : 16,
                    color: enabled
                        ? colors.fg.neutralMuted
                        : colors.fg.disabled,
                  ),
                  child: prefixIcon!,
                ),
                SizedBox(width: size == SeedInputButtonSize.large ? 10 : 8),
              ],
              Expanded(
                child: _labelled(
                  semanticsLabel ?? field?.label,
                  hasValue ? value : placeholder,
                  valueChild ??
                      Text(
                        hasValue ? value! : (placeholder ?? ''),
                        style:
                            (size == SeedInputButtonSize.large
                                    ? typography.t5Regular
                                    : typography.t4Regular)
                                .copyWith(color: effectiveTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ),
              if (showClear &&
                  hasValue &&
                  enabled &&
                  !readOnly &&
                  onClear != null) ...[
                SeedPressable(
                  semanticsLabel: SeedLocalizations.label(
                    context,
                    SeedLabel.clearSelection,
                  ),
                  onTap: onClear,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Icon(
                        Icons.cancel,
                        size: size == SeedInputButtonSize.large ? 22.0 : 18.0,
                        color: colors.fg.neutralSubtle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SeedDimension.x1),
              ],
              if (suffixText != null) ...[
                SizedBox(width: gap),
                Text(suffixText!, style: affixStyle),
              ],
              IconTheme(
                data: IconThemeData(
                  size: size == SeedInputButtonSize.large ? 20 : 16,
                  color: enabled ? colors.fg.neutralMuted : colors.fg.disabled,
                ),
                child:
                    suffixIcon ??
                    (showDefaultSuffix
                        ? const Icon(Icons.keyboard_arrow_down)
                        : const SizedBox.shrink()),
              ),
            ],
          );
          return AnimatedContainer(
            duration: SeedDuration.colorTransition,
            curve: SeedCurves.easing,
            constraints: BoxConstraints(minHeight: size.height),
            padding: EdgeInsets.symmetric(
              horizontal: size.paddingX - strokeWidth,
            ),
            decoration: BoxDecoration(
              color: isPressed ? colors.bg.transparentPressed : effectiveBg,
              borderRadius: isLarge ? SeedBorderRadius.r3 : SeedBorderRadius.r2,
              border: Border.all(color: borderColor, width: strokeWidth),
            ),
            child: contentScale ? SeedContentScale(child: content) : content,
          );
        },
      ),
    );
  }
}
