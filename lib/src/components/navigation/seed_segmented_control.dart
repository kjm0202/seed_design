import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_choice_group.dart';
import '../badge/seed_notification_badge.dart';

/// Item definition for [SeedSegmentedControl].
class SeedSegment<T> {
  final T value;
  final String label;
  final Widget? child;
  final int? notificationCount;
  final bool showNotificationDot;
  final bool enabled;
  final bool invalid;

  const SeedSegment({
    required this.value,
    this.label = '',
    this.child,
    this.notificationCount,
    this.showNotificationDot = false,
    this.enabled = true,
    this.invalid = false,
  });
}

/// Segmented Control component of SEED Design System.
///
/// Smoothly transitions between 2 to 4 mutually exclusive options
/// with animated floating pill indicator and SEED elevation shadow.
class SeedSegmentedControl<T> extends StatefulWidget {
  final List<SeedSegment<T>> segments;
  @Deprecated('Use value instead.')
  final T? selectedValue;
  T? get value => selectedValue;
  final T? defaultValue;
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<T>? onValueChanged;
  ValueChanged<T>? get onValueChange => onValueChanged;
  final bool enabled;

  /// Keeps [selectedValue], including null, under parent control.
  final bool controlled;

  const SeedSegmentedControl({
    super.key,
    required this.segments,
    T? value,
    @Deprecated('Use value instead.') T? selectedValue,
    this.defaultValue,
    ValueChanged<T>? onValueChange,
    @Deprecated('Use onValueChange instead.') ValueChanged<T>? onValueChanged,
    this.enabled = true,
    this.controlled = false,
  }) : selectedValue = value ?? selectedValue,
       assert(value == null || selectedValue == null),
       onValueChanged = onValueChange ?? onValueChanged,
       assert(onValueChange == null || onValueChanged == null),
       assert(
         segments.length >= 2 && segments.length <= 4,
         'Segmented control must have between 2 and 4 segments.',
       );

  @override
  State<SeedSegmentedControl<T>> createState() =>
      _SeedSegmentedControlState<T>();
}

class _SeedSegmentedControlState<T> extends State<SeedSegmentedControl<T>> {
  late T? _uncontrolledValue =
      widget.defaultValue ?? widget.segments.first.value;

  bool get _isControlled => widget.controlled || widget.selectedValue != null;
  T? get _effectiveValue =>
      _isControlled ? widget.selectedValue : _uncontrolledValue;

  void _handleSelect(T value) {
    final prev = _effectiveValue;
    if (!_isControlled && _uncontrolledValue != value) {
      setState(() => _uncontrolledValue = value);
    }
    if (prev != value) {
      widget.onValueChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final segments = widget.segments;
    final enabled = widget.enabled;
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final effectiveValue = _effectiveValue;
    final int selectedIndex = segments.indexWhere(
      (s) => s.value == effectiveValue,
    );

    return LayoutBuilder(
      builder: (context, slotConstraints) {
        final minWidth = 86.0 * segments.length;
        final width = slotConstraints.hasBoundedWidth
            ? math.max(slotConstraints.maxWidth - 8, minWidth)
            : minWidth;
        final labelWidth = math.max(1.0, width / segments.length - 48);
        var tallestLabel = 18.0;
        for (final segment in segments) {
          final badgeWidth =
              segment.notificationCount != null || segment.showNotificationDot
              ? 24.0
              : 0.0;
          final painter = TextPainter(
            text: TextSpan(text: segment.label, style: typography.t5Bold),
            textDirection: textDirection,
            textScaler: textScaler,
            textAlign: TextAlign.center,
          )..layout(maxWidth: math.max(1, labelWidth - badgeWidth));
          tallestLabel = math.max(tallestLabel, painter.height);
          painter.dispose();
        }
        final itemHeight = math.max(34.0, tallestLabel + 12);
        return Semantics(
          container: true,
          role: SemanticsRole.radioGroup,
          child: SeedChoiceGroup(
            selectedIndex: selectedIndex,
            enabled: segments.map((s) => enabled && s.enabled).toList(),
            onSelected: (index) => _handleSelect(segments[index].value),
            builder: (context, nodes) => Container(
              height: itemHeight + 2 * SeedDimension.x1,
              padding: const EdgeInsets.all(SeedDimension.x1),
              decoration: BoxDecoration(
                color: colors.bg.neutralWeakAlpha,
                borderRadius: SeedBorderRadius.full,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Every SEED segment requires at least 86px. On narrow viewports,
                  // retain the specified target size and allow horizontal scrolling.
                  final minWidth = 86.0 * segments.length;
                  final width = constraints.hasBoundedWidth
                      ? math.max(constraints.maxWidth, minWidth)
                      : minWidth;
                  final segmentWidth = width / segments.length;
                  final rtl = Directionality.of(context) == TextDirection.rtl;

                  final content = SizedBox(
                    width: width,
                    height: itemHeight,
                    child: Stack(
                      children: [
                        // Animated Floating Pill Indicator
                        if (selectedIndex != -1)
                          AnimatedPositioned(
                            duration: SeedDuration.d4,
                            curve: SeedCurves.easing,
                            left: rtl ? null : selectedIndex * segmentWidth,
                            right: rtl ? selectedIndex * segmentWidth : null,
                            top: 0,
                            bottom: 0,
                            width: segmentWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    enabled && segments[selectedIndex].enabled
                                    ? (colors.isDark
                                          ? SeedPalette.gray00Dark
                                          : SeedPalette.gray00Light)
                                    : colors.bg.disabled,
                                borderRadius: SeedBorderRadius.full,
                                border: Border.all(
                                  color: colors.stroke.neutralMuted,
                                ),
                              ),
                            ),
                          ),

                        // Segment Items
                        Row(
                          children: List.generate(segments.length, (index) {
                            final segment = segments[index];
                            final bool isSelected = index == selectedIndex;
                            final bool isSegmentEnabled =
                                enabled && segment.enabled;

                            final TextStyle textStyle = typography.t5Bold
                                .copyWith(
                                  color: !isSegmentEnabled
                                      ? colors.fg.disabled
                                      : (isSelected
                                            ? colors.fg.neutral
                                            : colors.fg.neutralSubtle),
                                );

                            return Expanded(
                              child: SeedPressable(
                                enabled: isSegmentEnabled,
                                checked: isSelected,
                                selected: isSelected,
                                inMutuallyExclusiveGroup: true,
                                focusBorderRadius: SeedBorderRadius.full,
                                focusNode: nodes[index],
                                enableScale: false,
                                onTap: () => _handleSelect(segment.value),
                                builder: (context, pressed) => Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 86.0,
                                    minHeight: 34.0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SeedDimension.x6,
                                    vertical: SeedDimension.x1_5,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: pressed
                                      ? BoxDecoration(
                                          color: isSelected
                                              ? (colors.isDark
                                                    ? SeedPalette.gray100Dark
                                                    : SeedPalette.gray100Light)
                                              : colors.bg.neutralWeakPressed,
                                          borderRadius: SeedBorderRadius.full,
                                          border: Border.all(
                                            color: colors.stroke.neutralMuted,
                                          ),
                                        )
                                      : null,
                                  child: SeedContentScale(
                                    child: DefaultTextStyle(
                                      style: textStyle,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child:
                                                segment.child ??
                                                Text(
                                                  segment.label,
                                                  style: textStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                          ),
                                          if (segment.notificationCount !=
                                                  null ||
                                              segment.showNotificationDot) ...[
                                            const SizedBox(
                                              width: SeedDimension.x1_5,
                                            ),
                                            SeedNotificationBadge(
                                              count: segment.notificationCount,
                                              showDot:
                                                  segment.showNotificationDot,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                  return constraints.hasBoundedWidth &&
                          constraints.maxWidth < minWidth
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: content,
                        )
                      : content;
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
