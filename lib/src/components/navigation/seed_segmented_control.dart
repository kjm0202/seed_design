import 'dart:math' as math;

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
  final int? notificationCount;
  final bool showNotificationDot;
  final bool enabled;

  const SeedSegment({
    required this.value,
    required this.label,
    this.notificationCount,
    this.showNotificationDot = false,
    this.enabled = true,
  });
}

/// Segmented Control component of SEED Design System.
///
/// Smoothly transitions between 2 to 4 mutually exclusive options
/// with animated floating pill indicator and SEED elevation shadow.
class SeedSegmentedControl<T> extends StatelessWidget {
  final List<SeedSegment<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final bool enabled;

  const SeedSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onValueChanged,
    this.enabled = true,
  }) : assert(
         segments.length >= 2 && segments.length <= 4,
         'Segmented control must have between 2 and 4 segments.',
       );

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    // LayoutBuilder needs a finite height, so derive the slot height from the
    // actual scaled line metrics. The 34px SEED item height is a *minimum*.
    var tallestLabel = 0.0;
    for (final segment in segments) {
      final painter = TextPainter(
        text: TextSpan(text: segment.label, style: typography.t5Bold),
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      tallestLabel = math.max(tallestLabel, painter.height);
      painter.dispose();
    }
    final itemHeight = math.max(34.0, math.max(tallestLabel, 18.0) + 12.0);

    final int selectedIndex = segments.indexWhere(
      (s) => s.value == selectedValue,
    );

    return SeedChoiceGroup(
      selectedIndex: selectedIndex,
      enabled: segments.map((s) => enabled && s.enabled).toList(),
      onSelected: (index) => onValueChanged(segments[index].value),
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
                          color: enabled
                              ? (colors.isDark
                                    ? SeedPalette.gray00Dark
                                    : SeedPalette.gray00Light)
                              : colors.bg.disabled,
                          borderRadius: SeedBorderRadius.full,
                          border: Border.all(color: colors.stroke.neutralMuted),
                        ),
                      ),
                    ),

                  // Segment Items
                  Row(
                    children: List.generate(segments.length, (index) {
                      final segment = segments[index];
                      final bool isSelected = index == selectedIndex;
                      final bool isSegmentEnabled = enabled && segment.enabled;

                      final TextStyle textStyle = typography.t5Bold.copyWith(
                        color: !isSegmentEnabled
                            ? colors.fg.disabled
                            : (isSelected
                                  ? colors.fg.neutral
                                  : colors.fg.neutralSubtle),
                      );

                      return Expanded(
                        child: SeedPressable(
                          enabled: isSegmentEnabled,
                          selected: isSelected,
                          focusNode: nodes[index],
                          enableScale: false,
                          onTap: () => onValueChanged(segment.value),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    segment.label,
                                    style: textStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (segment.notificationCount != null ||
                                    segment.showNotificationDot) ...[
                                  const SizedBox(width: SeedDimension.x1_5),
                                  SeedNotificationBadge(
                                    count: segment.notificationCount,
                                    showDot: segment.showNotificationDot,
                                  ),
                                ],
                              ],
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
    );
  }
}
