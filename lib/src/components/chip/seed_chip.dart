import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_choice_group.dart';
import '../../foundations/feedback/seed_control.dart';

/// Variant options for [SeedChip].
enum SeedChipVariant { solid, outlineStrong, outlineWeak }

/// Size options for [SeedChip].
enum SeedChipSize {
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case SeedChipSize.small:
        return 32.0;
      case SeedChipSize.medium:
        return 36.0;
      case SeedChipSize.large:
        return 40.0;
    }
  }

  double get iconSize {
    switch (this) {
      case SeedChipSize.small:
        return 14.0;
      case SeedChipSize.medium:
        return 16.0;
      case SeedChipSize.large:
        return 16.0;
    }
  }

  double get suffixIconSize {
    switch (this) {
      case SeedChipSize.small:
        return 14.0;
      case SeedChipSize.medium:
        return 14.0;
      case SeedChipSize.large:
        return 16.0;
    }
  }

  double get rootPaddingX {
    switch (this) {
      case SeedChipSize.small:
        return SeedDimension.x1_5;
      case SeedChipSize.medium:
        return SeedDimension.x2;
      case SeedChipSize.large:
        return SeedDimension.x2_5;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case SeedChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case SeedChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 14.0);
      case SeedChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  BorderRadius get borderRadius => SeedBorderRadius.full;
}

/// Chip component of SEED Design System.
///
/// Used for filtering, suggestions, selections, and user input tags.
class SeedChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Widget? prefix;
  final Widget? suffix;
  final SeedChipVariant variant;
  final SeedChipSize size;
  final bool enabled;
  final bool _iconOnly;
  final String? semanticsLabel;
  final FocusNode? focusNode;
  final Widget? prefixAvatar, prefixImage;

  const SeedChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.prefix,
    this.suffix,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
    this.prefixAvatar,
    this.prefixImage,
  }) : _iconOnly = false;

  const SeedChip.iconOnly({
    super.key,
    required Widget icon,
    required String this.semanticsLabel,
    this.focusNode,
    this.selected = false,
    this.onSelected,
    this.onPressed,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    this.enabled = true,
  }) : prefix = icon,
       label = '',
       suffix = null,
       onDeleted = null,
       prefixAvatar = null,
       prefixImage = null,
       _iconOnly = true;

  bool get _isClickable => enabled && (onSelected != null || onPressed != null);

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    TextStyle textStyle;
    switch (size) {
      case SeedChipSize.small:
        textStyle = typography.t4Medium;
        break;
      case SeedChipSize.medium:
        textStyle = typography.t4Medium;
        break;
      case SeedChipSize.large:
        textStyle = typography.t4Medium;
        break;
    }

    final prefix = prefixAvatar ?? prefixImage ?? this.prefix;
    return SeedPressable(
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      enabled: _isClickable,
      selected: onSelected != null ? selected : null,
      onTap: () {
        if (onSelected != null) {
          onSelected!(!selected);
        } else if (onPressed != null) {
          onPressed!();
        }
      },
      builder: (context, isPressed) {
        final (bgColor, fgColor, strokeColor) = _resolveColors(
          colors: colors,
          isPressed: isPressed,
        );

        return Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: SeedDuration.colorTransition,
            curve: SeedCurves.easing,
            constraints: BoxConstraints(
              minHeight: size.height,
              minWidth: _iconOnly
                  ? size.height
                  : switch (size) {
                      SeedChipSize.small => 44,
                      SeedChipSize.medium => 48,
                      SeedChipSize.large => 52,
                    },
            ),
            padding: EdgeInsets.only(
              left: _iconOnly
                  ? size.rootPaddingX
                  : prefix != null
                  ? size.rootPaddingX
                  : size.rootPaddingX + SeedDimension.x1_5,
              right: _iconOnly
                  ? size.rootPaddingX
                  : (suffix != null || onDeleted != null)
                  ? size.rootPaddingX
                  : size.rootPaddingX + SeedDimension.x1_5,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: size.borderRadius,
              border: strokeColor != null
                  ? Border.all(color: strokeColor, width: 1.0)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefix != null) ...[
                  IconTheme(
                    data: IconThemeData(color: fgColor, size: size.iconSize),
                    child: prefixAvatar != null || prefixImage != null
                        ? ClipRRect(
                            borderRadius: prefixAvatar != null
                                ? SeedBorderRadius.full
                                : SeedBorderRadius.r1,
                            child: SizedBox.square(
                              dimension: size == SeedChipSize.small
                                  ? 20
                                  : size == SeedChipSize.medium
                                  ? 24
                                  : 28,
                              child: prefix,
                            ),
                          )
                        : prefix,
                  ),
                  if (!_iconOnly) const SizedBox(width: SeedDimension.x1_5),
                ],
                if (!_iconOnly)
                  Text(
                    label,
                    style: textStyle.copyWith(color: fgColor),
                    maxLines: 1,
                  ),
                if (onDeleted != null) ...[
                  const SizedBox(width: SeedDimension.x1_5),
                  SeedPressable(
                    semanticsLabel: '$label 삭제',
                    enableScale: false,
                    behavior: HitTestBehavior.opaque,
                    onTap: enabled ? onDeleted : null,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Icon(
                          Icons.close_rounded,
                          size: size.suffixIconSize,
                          color: fgColor,
                        ),
                      ),
                    ),
                  ),
                ] else if (suffix != null) ...[
                  const SizedBox(width: SeedDimension.x1_5),
                  IconTheme(
                    data: IconThemeData(
                      color: fgColor,
                      size: size.suffixIconSize,
                    ),
                    child: suffix!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  (Color bg, Color fg, Color? stroke) _resolveColors({
    required SeedColorScheme colors,
    required bool isPressed,
  }) {
    switch (variant) {
      case SeedChipVariant.solid:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            null,
          );
        } else {
          return (
            isPressed
                ? colors.bg.neutralWeakAlphaPressed
                : colors.bg.neutralWeakAlpha,
            colors.fg.neutral,
            null,
          );
        }

      case SeedChipVariant.outlineStrong:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            colors.stroke.neutralMuted,
          );
        } else {
          return (
            isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralMuted,
          );
        }

      case SeedChipVariant.outlineWeak:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralWeakPressed : colors.bg.neutralWeak,
            colors.fg.neutral,
            colors.stroke.neutralContrast,
          );
        } else {
          return (
            isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralMuted,
          );
        }
    }
  }
}

class SeedChipOption<T> {
  const SeedChipOption({
    required this.value,
    required this.label,
    this.prefix,
    this.enabled = true,
  });
  final T value;
  final String label;
  final Widget? prefix;
  final bool enabled;
}

/// Single-selection chip group with roving Tab focus and arrow navigation.
class SeedChipRadioGroup<T> extends StatefulWidget {
  const SeedChipRadioGroup({
    super.key,
    required this.options,
    this.value,
    this.defaultValue,
    ValueChanged<T>? onValueChange,
    ValueChanged<T>? onChanged,
    this.enabled = true,
    this.controlled = false,
    this.label,
    this.description,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
  }) : onChanged = onValueChange ?? onChanged,
       assert(onValueChange == null || onChanged == null);
  final List<SeedChipOption<T>> options;
  final T? value, defaultValue;
  final ValueChanged<T>? onChanged;
  ValueChanged<T>? get onValueChange => onChanged;
  final bool enabled, controlled;
  final String? label, description;
  final SeedChipVariant variant;
  final SeedChipSize size;
  @override
  State<SeedChipRadioGroup<T>> createState() => _SeedChipRadioGroupState<T>();
}

class _SeedChipRadioGroupState<T> extends State<SeedChipRadioGroup<T>> {
  late T? _value = widget.defaultValue;
  T? get value => widget.controlled ? widget.value : widget.value ?? _value;
  void _change(T next) {
    if (value == next) return;
    if (!widget.controlled && widget.value == null) {
      setState(() => _value = next);
    }
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) => SeedFieldset(
    label: widget.label,
    description: widget.description,
    enabled: widget.enabled,
    child: SeedChoiceGroup(
      selectedIndex: widget.options.indexWhere((item) => item.value == value),
      enabled: widget.options
          .map((item) => widget.enabled && item.enabled)
          .toList(),
      onSelected: (index) => _change(widget.options[index].value),
      builder: (context, nodes) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < widget.options.length; i++)
            Semantics(
              inMutuallyExclusiveGroup: true,
              checked: widget.options[i].value == value,
              child: SeedChip(
                label: widget.options[i].label,
                prefix: widget.options[i].prefix,
                enabled: widget.enabled && widget.options[i].enabled,
                focusNode: nodes[i],
                selected: widget.options[i].value == value,
                onSelected: (_) => _change(widget.options[i].value),
                variant: widget.variant,
                size: widget.size,
              ),
            ),
        ],
      ),
    ),
  );
}
