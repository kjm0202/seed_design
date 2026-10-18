import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Size of [SeedSwitch].
enum SeedSwitchSize {
  size16,
  size24,
  size32;

  double get trackHeight {
    switch (this) {
      case SeedSwitchSize.size16:
        return 16.0;
      case SeedSwitchSize.size24:
        return 24.0;
      case SeedSwitchSize.size32:
        return 32.0;
    }
  }

  double get trackWidth {
    switch (this) {
      case SeedSwitchSize.size16:
        return 28.0;
      case SeedSwitchSize.size24:
        return 42.0;
      case SeedSwitchSize.size32:
        return 54.0;
    }
  }

  double get thumbSize {
    switch (this) {
      case SeedSwitchSize.size16:
        return 12.0;
      case SeedSwitchSize.size24:
        return 20.0;
      case SeedSwitchSize.size32:
        return 28.0;
    }
  }

  double get minTouchHeight =>
      this == SeedSwitchSize.size16 ? 24.0 : trackHeight;
}

/// Standalone interactive switch with a separate visual and touch target.
class SeedSwitchMark extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final SeedSwitchSize size;
  final bool enabled;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  const SeedSwitchMark({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = SeedSwitchSize.size24,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) => SeedPressable(
    enabled: enabled && onChanged != null,
    semanticButton: false,
    toggled: value,
    semanticsLabel: semanticsLabel,
    focusNode: focusNode,
    enableScale: false,
    onTap: () => onChanged?.call(!value),
    child: SizedBox(
      width: size.trackWidth < 44 ? 44 : size.trackWidth,
      height: 44,
      child: Center(
        child: _SeedSwitchGraphic(
          value: value,
          size: size,
          enabled: enabled && onChanged != null,
        ),
      ),
    ),
  );
}

class _SeedSwitchGraphic extends StatelessWidget {
  final bool value;
  final SeedSwitchSize size;
  final bool enabled;
  const _SeedSwitchGraphic({
    required this.value,
    required this.size,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : SeedDuration.d3;
    return AnimatedContainer(
      duration: duration,
      curve: SeedCurves.easing,
      width: size.trackWidth,
      height: size.trackHeight,
      padding: EdgeInsets.all((size.trackHeight - size.thumbSize) / 2),
      decoration: BoxDecoration(
        color: !enabled
            ? colors.bg.disabled
            : value
            ? colors.bg.neutralSolid
            : colors.bg.neutralWeak,
        borderRadius: SeedBorderRadius.full,
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: SeedCurves.easing,
        alignment: value
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: size.thumbSize,
          height: size.thumbSize,
          decoration: BoxDecoration(
            color: enabled ? SeedPalette.staticWhite : colors.fg.disabled,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Switch whose label and mark form one focusable, accessible toggle.
class SeedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final SeedSwitchSize size;
  final bool enabled;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  const SeedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = SeedSwitchSize.size24,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return SeedSwitchMark(
        value: value,
        onChanged: onChanged,
        size: size,
        enabled: enabled,
        semanticsLabel: semanticsLabel,
        focusNode: focusNode,
      );
    }
    final typography = context.seedTypography;
    final style = switch (size) {
      SeedSwitchSize.size16 => typography.t3Regular,
      SeedSwitchSize.size24 => typography.t4Regular,
      SeedSwitchSize.size32 => typography.t5Regular,
    };
    final interactive = enabled && onChanged != null;
    return SeedPressable(
      enabled: interactive,
      semanticButton: false,
      toggled: value,
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      enableScale: false,
      onTap: () => onChanged?.call(!value),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SeedSwitchGraphic(value: value, size: size, enabled: interactive),
            const SizedBox(width: SeedDimension.x3),
            Flexible(
              child: Text(
                label!,
                style: style.copyWith(
                  color: interactive
                      ? context.seedColor.fg.neutral
                      : context.seedColor.fg.disabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
