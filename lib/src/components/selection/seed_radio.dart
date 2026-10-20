import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Size of [SeedRadio].
enum SeedRadioSize {
  medium,
  large;

  double get diameter => this == SeedRadioSize.medium ? 20.0 : 24.0;
  double get innerDiameter => this == SeedRadioSize.medium ? 8.0 : 10.0;
}

/// Radio button component of SEED Design System.
class SeedRadio<T> extends StatefulWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final SeedRadioSize size;
  final bool enabled;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  const SeedRadio({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.label,
    this.size = SeedRadioSize.medium,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
  });

  @override
  State<SeedRadio<T>> createState() => _SeedRadioState<T>();
}

class _SeedRadioState<T> extends State<SeedRadio<T>> with RadioClient<T> {
  final FocusNode _internalFocusNode = FocusNode();
  @override
  FocusNode get focusNode => widget.focusNode ?? _internalFocusNode;
  @override
  T get radioValue => widget.value;
  @override
  bool get tristate => false;
  @override
  bool get enabled =>
      widget.enabled && (registry != null || widget.onChanged != null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registry = RadioGroup.maybeOf<T>(context);
  }

  @override
  void dispose() {
    registry = null;
    _internalFocusNode.dispose();
    super.dispose();
  }

  bool get _isSelected =>
      widget.value ==
      (registry != null ? registry!.groupValue : widget.groupValue);
  void _handleTap() {
    if (!enabled) return;
    (registry?.onChanged ?? widget.onChanged)?.call(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final gray300 = colors.isDark
        ? SeedPalette.gray300Dark
        : SeedPalette.gray300Light;
    final Color strokeColor = !enabled
        ? (_isSelected ? gray300 : colors.stroke.neutralWeak)
        : (_isSelected
              ? colors.stroke.neutralContrast
              : colors.stroke.neutralWeak);

    final Color innerColor = !enabled ? gray300 : colors.fg.onNeutralSolid;

    Widget mark(bool pressed) => AnimatedScale(
      scale: pressed
          ? SeedScaleCalculator.calculateScale(
              width: widget.size.diameter,
              height: widget.size.diameter,
              disableAnimations: MediaQuery.disableAnimationsOf(context),
            )
          : 1,
      duration: SeedDuration.pressedScale,
      curve: SeedCurves.pressedScale,
      child: Container(
        width: widget.size.diameter,
        height: widget.size.diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled && _isSelected
              ? (pressed
                    ? colors.bg.neutralSolidPressed
                    : colors.bg.neutralSolid)
              : pressed
              ? colors.bg.transparentPressed
              : !enabled && !_isSelected
              ? gray300
              : colors.bg.transparent,
          border: enabled && _isSelected
              ? null
              : Border.all(color: strokeColor),
        ),
        alignment: Alignment.center,
        child: _isSelected
            ? Container(
                width: widget.size.innerDiameter + (enabled ? 0 : 2),
                height: widget.size.innerDiameter + (enabled ? 0 : 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: innerColor,
                ),
              )
            : null,
      ),
    );

    if (widget.label == null) {
      return SeedPressable(
        enabled: enabled,
        enableScale: false,
        semanticButton: false,
        semanticsLabel: widget.semanticsLabel,
        focusNode: focusNode,
        checked: _isSelected,
        inMutuallyExclusiveGroup: true,
        onTap: _handleTap,
        builder: (context, pressed) => SizedBox(
          width: 44,
          height: 44,
          child: Center(child: mark(pressed)),
        ),
      );
    }

    final TextStyle textStyle =
        (widget.size == SeedRadioSize.medium
                ? typography.t4Regular
                : typography.t5Regular)
            .copyWith(color: enabled ? colors.fg.neutral : colors.fg.disabled);

    return SeedPressable(
      enabled: enabled,
      enableScale: false,
      semanticButton: false,
      semanticsLabel: widget.semanticsLabel,
      focusNode: focusNode,
      checked: _isSelected,
      inMutuallyExclusiveGroup: true,
      onTap: _handleTap,
      builder: (context, pressed) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mark(pressed),
            const SizedBox(width: SeedDimension.x2),
            Flexible(child: Text(widget.label!, style: textStyle)),
          ],
        ),
      ),
    );
  }
}

/// Provides native radio-group arrow navigation and a single Tab stop.
/// Existing SeedRadio(groupValue:, onChanged:) usage remains supported.
class SeedRadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;
  const SeedRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });
  @override
  Widget build(BuildContext context) =>
      RadioGroup<T>(groupValue: groupValue, onChanged: onChanged, child: child);
}
