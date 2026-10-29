import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_choice_group.dart';
import '../badge/seed_notification_badge.dart';
import '../layout/seed_scroll_fog.dart';

/// Style variants of [SeedTabs].
enum SeedTabsVariant { line, chipSolid, chipOutline }

/// Sizing options for [SeedTabs].
enum SeedTabsSize {
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case SeedTabsSize.small:
        return 40.0;
      case SeedTabsSize.medium:
        return 44.0;
      case SeedTabsSize.large:
        return 44.0;
    }
  }
}

/// Represents an item in [SeedTabs].
class SeedTabItem {
  final String label;

  /// React tab value. When omitted, the tab view uses the index as a string.
  final String? value;
  final int? notificationCount;
  final bool showNotificationDot;
  final bool enabled;

  const SeedTabItem({
    required this.label,
    this.value,
    this.notificationCount,
    this.showNotificationDot = false,
    this.enabled = true,
  });
}

/// Tabs component of SEED Design System.
///
/// Supports Line type (with Fill and Hug layouts) and Chip type (Solid & Outline),
/// with built-in notification badges and physical scale interactions.
class SeedTabs extends StatefulWidget {
  final List<SeedTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final SeedTabsVariant variant;
  final SeedTabsSize size;
  final bool fill;
  final bool showScrollFog;
  final Axis orientation;

  /// Optional list inset for chip variants. The default remains 16px on both
  /// sides; this corresponds to ChipTabsList's customizable CSS padding.
  final EdgeInsetsGeometry? chipListPadding;

  const SeedTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.variant = SeedTabsVariant.line,
    SeedTabsSize? size,
    this.fill = false,
    this.showScrollFog = false,
    this.orientation = Axis.horizontal,
    this.chipListPadding,
  }) : size =
           size ??
           (variant == SeedTabsVariant.line
               ? SeedTabsSize.small
               : SeedTabsSize.medium);

  @override
  State<SeedTabs> createState() => _SeedTabsState();
}

class _SeedTabsState extends State<SeedTabs> {
  final GlobalKey _hugRowKey = GlobalKey();
  late List<GlobalKey> _hugItemKeys = List.generate(
    widget.items.length,
    (_) => GlobalKey(),
  );
  late List<GlobalKey> _chipItemKeys = List.generate(
    widget.items.length,
    (_) => GlobalKey(),
  );
  double? _hugIndicatorLeft;
  double? _hugIndicatorWidth;
  bool _measureScheduled = false;
  bool _lineRevealScheduled = false;
  bool _chipRevealScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleHugMeasure();
    _scheduleLineReveal();
    _scheduleChipReveal();
  }

  @override
  void didUpdateWidget(SeedTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _hugItemKeys = List.generate(widget.items.length, (_) => GlobalKey());
      _chipItemKeys = List.generate(widget.items.length, (_) => GlobalKey());
      _hugIndicatorLeft = null;
      _hugIndicatorWidth = null;
    }
    if (widget.variant == SeedTabsVariant.line && !widget.fill) {
      _measureHugIndicatorSync();
      _scheduleHugMeasure();
    }
    if (widget.variant == SeedTabsVariant.line &&
        (oldWidget.selectedIndex != widget.selectedIndex ||
            oldWidget.variant != widget.variant ||
            oldWidget.fill != widget.fill ||
            oldWidget.items.length != widget.items.length)) {
      _scheduleLineReveal();
    }
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.variant != widget.variant ||
        oldWidget.items.length != widget.items.length) {
      _scheduleChipReveal();
    }
  }

  void _scheduleLineReveal() {
    if (widget.variant != SeedTabsVariant.line ||
        widget.items.isEmpty ||
        _lineRevealScheduled) {
      return;
    }
    _lineRevealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lineRevealScheduled = false;
      if (!mounted ||
          widget.variant != SeedTabsVariant.line ||
          widget.selectedIndex < 0 ||
          widget.selectedIndex >= _hugItemKeys.length) {
        return;
      }
      _revealSelectedTab(_hugItemKeys[widget.selectedIndex]);
    });
  }

  void _scheduleChipReveal() {
    if (widget.variant == SeedTabsVariant.line ||
        widget.items.isEmpty ||
        _chipRevealScheduled) {
      return;
    }
    _chipRevealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chipRevealScheduled = false;
      if (!mounted ||
          widget.variant == SeedTabsVariant.line ||
          widget.selectedIndex < 0 ||
          widget.selectedIndex >= _chipItemKeys.length) {
        return;
      }
      _revealSelectedTab(_chipItemKeys[widget.selectedIndex]);
    });
  }

  void _revealSelectedTab(GlobalKey itemKey) {
    final itemContext = itemKey.currentContext;
    final itemBox = itemContext?.findRenderObject();
    final scrollable = itemContext == null
        ? null
        : Scrollable.maybeOf(itemContext);
    if (itemBox is! RenderBox || scrollable == null) return;

    final position = scrollable.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    final viewport = RenderAbstractViewport.of(itemBox);
    final leading = viewport.getOffsetToReveal(itemBox, 0).offset;
    final trailing = viewport.getOffsetToReveal(itemBox, 1).offset;

    // Match React useTabs scrollTabIntoView's 16px reveal buffer. Offsets
    // from the viewport are axis-direction aware (LTR and RTL); scroll only
    // when a selected trigger is actually outside the visible viewport.
    var target = position.pixels;
    if (position.pixels < trailing) {
      target = trailing + SeedDimension.x4;
    } else if (position.pixels > leading) {
      target = leading - SeedDimension.x4;
    }
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() > 0.5) {
      position.animateTo(
        target,
        duration: SeedDuration.d4,
        curve: SeedCurves.easing,
      );
    }
  }

  void _measureHugIndicatorSync() {
    if (widget.items.isEmpty ||
        widget.selectedIndex < 0 ||
        widget.selectedIndex >= _hugItemKeys.length) {
      return;
    }
    final rowBox = _hugRowKey.currentContext?.findRenderObject();
    final itemBox = _hugItemKeys[widget.selectedIndex].currentContext
        ?.findRenderObject();
    if (rowBox is RenderBox &&
        rowBox.hasSize &&
        itemBox is RenderBox &&
        itemBox.hasSize) {
      final offset = itemBox.localToGlobal(Offset.zero, ancestor: rowBox);
      _hugIndicatorLeft = offset.dx;
      _hugIndicatorWidth = itemBox.size.width;
    }
  }

  void _scheduleHugMeasure() {
    if (widget.variant != SeedTabsVariant.line ||
        widget.fill ||
        widget.items.isEmpty) {
      return;
    }
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (!mounted ||
          widget.variant != SeedTabsVariant.line ||
          widget.fill ||
          widget.items.isEmpty ||
          widget.selectedIndex < 0 ||
          widget.selectedIndex >= _hugItemKeys.length) {
        return;
      }
      final rowBox = _hugRowKey.currentContext?.findRenderObject();
      final itemCtx = _hugItemKeys[widget.selectedIndex].currentContext;
      final itemBox = itemCtx?.findRenderObject();
      if (rowBox is RenderBox &&
          rowBox.hasSize &&
          itemBox is RenderBox &&
          itemBox.hasSize) {
        final offset = itemBox.localToGlobal(Offset.zero, ancestor: rowBox);
        final nextLeft = offset.dx;
        final nextWidth = itemBox.size.width;
        if ((_hugIndicatorLeft == null ||
                (_hugIndicatorLeft! - nextLeft).abs() > 0.1) ||
            (_hugIndicatorWidth == null ||
                (_hugIndicatorWidth! - nextWidth).abs() > 0.1)) {
          setState(() {
            _hugIndicatorLeft = nextLeft;
            _hugIndicatorWidth = nextWidth;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SeedChoiceGroup(
      selectedIndex: widget.selectedIndex,
      enabled: widget.items.map((item) => item.enabled).toList(),
      axis: widget.orientation,
      onSelected: widget.onTabSelected,
      builder: (context, nodes) => widget.variant == SeedTabsVariant.line
          ? _buildLineTabs(context, nodes)
          : widget.showScrollFog
          ? Stack(
              children: [
                _buildChipTabs(context, nodes),
                const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: SeedScrollFog(placement: SeedScrollFogPlacement.left),
                ),
                const Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: SeedScrollFog(placement: SeedScrollFogPlacement.right),
                ),
              ],
            )
          : _buildChipTabs(context, nodes),
    );
  }

  Widget _buildLineTabs(BuildContext context, List<FocusNode> nodes) {
    final colors = context.seedColor;
    final items = widget.items;

    if (items.isEmpty) {
      return Container(
        height: widget.size.height,
        decoration: BoxDecoration(
          color: colors.bg.layerDefault,
          border: Border(
            bottom: BorderSide(color: colors.stroke.neutralMuted, width: 1.0),
          ),
        ),
      );
    }

    final int clampedIndex = widget.selectedIndex.clamp(0, items.length - 1);
    final bool hasMeasuredHugIndicator =
        _hugIndicatorLeft != null && _hugIndicatorWidth != null;
    final labelSizes = _lineLabelSizes(context);
    final height = labelSizes.fold(widget.size.height, (height, label) {
      final required = label.height + SeedDimension.x2_5 * 2;
      return required > height ? required : height;
    });

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.bg.layerDefault,
        border: Border(
          bottom: BorderSide(color: colors.stroke.neutralMuted, width: 1.0),
        ),
      ),
      child: widget.fill
          ? LayoutBuilder(
              builder: (context, constraints) {
                final widths = _fillWidths(constraints.maxWidth, labelSizes);
                final totalWidth = widths.fold(
                  0.0,
                  (sum, width) => sum + width,
                );
                final indicatorOffset = widths
                    .take(clampedIndex)
                    .fold(0.0, (sum, width) => sum + width);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    child: Stack(
                      children: [
                        Semantics(
                          role: SemanticsRole.tabBar,
                          explicitChildNodes: true,
                          child: Row(
                            children: List.generate(items.length, (index) {
                              return KeyedSubtree(
                                key: _hugItemKeys[index],
                                child: SizedBox(
                                  width: widths[index],
                                  child: _buildLineTabItem(
                                    context,
                                    index,
                                    nodes[index],
                                    showBottomIndicator: false,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: SeedDuration.d4,
                          curve: SeedCurves.easing,
                          left: Directionality.of(context) == TextDirection.rtl
                              ? null
                              : indicatorOffset,
                          right: Directionality.of(context) == TextDirection.rtl
                              ? indicatorOffset
                              : null,
                          bottom: 0,
                          width: widths[clampedIndex],
                          height: 2.0,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: SeedSpacingX.globalGutter,
                            ),
                            color: colors.fg.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: SeedSpacingX.globalGutter,
              ),
              child: Stack(
                children: [
                  Semantics(
                    role: SemanticsRole.tabBar,
                    explicitChildNodes: true,
                    child: Row(
                      key: _hugRowKey,
                      children: List.generate(items.length, (index) {
                        return KeyedSubtree(
                          key: _hugItemKeys[index],
                          child: _buildLineTabItem(
                            context,
                            index,
                            nodes[index],
                            showBottomIndicator: !hasMeasuredHugIndicator,
                          ),
                        );
                      }),
                    ),
                  ),
                  if (hasMeasuredHugIndicator)
                    AnimatedPositioned(
                      duration: SeedDuration.d4,
                      curve: SeedCurves.easing,
                      left: _hugIndicatorLeft!,
                      bottom: 0,
                      width: _hugIndicatorWidth!,
                      height: 2.0,
                      child: IgnorePointer(
                        child: ColoredBox(color: colors.fg.neutral),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  List<Size> _lineLabelSizes(BuildContext context) {
    final typography = context.seedTypography;
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: 1,
    );
    final style = DefaultTextStyle.of(context).style.merge(
      widget.size == SeedTabsSize.small ? typography.t4Bold : typography.t5Bold,
    );
    final sizes = widget.items.map((item) {
      painter.text = TextSpan(text: item.label, style: style);
      painter.layout();
      return painter.size;
    }).toList();
    painter.dispose();
    return sizes;
  }

  // CSS flex items keep their min-content width. Distribute the remaining
  // space equally, and scroll when the labels together exceed the viewport.
  List<double> _fillWidths(double available, List<Size> labels) {
    final minimums = [
      for (final label in labels) label.width + SeedDimension.x2_5 * 2,
    ];
    final widths = List<double>.filled(minimums.length, 0);
    final pending = List<int>.generate(minimums.length, (index) => index);
    var remaining = available;
    while (pending.isNotEmpty) {
      final share = remaining / pending.length;
      final fixed = pending.where((index) => minimums[index] > share).toList();
      if (fixed.isEmpty) {
        for (final index in pending) {
          widths[index] = share;
        }
        break;
      }
      for (final index in fixed) {
        widths[index] = minimums[index];
        remaining -= minimums[index];
        pending.remove(index);
      }
    }
    return widths;
  }

  Widget _buildLineTabItem(
    BuildContext context,
    int index,
    FocusNode node, {
    bool showBottomIndicator = true,
  }) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final item = widget.items[index];
    final bool isSelected = index == widget.selectedIndex;

    final TextStyle textStyle =
        (widget.size == SeedTabsSize.small
                ? typography.t4Bold
                : typography.t5Bold)
            .copyWith(
              color: !item.enabled
                  ? colors.fg.disabled
                  : (isSelected ? colors.fg.neutral : colors.fg.neutralSubtle),
            );

    return SeedPressable(
      enabled: item.enabled,
      selected: isSelected,
      semanticsRole: SemanticsRole.tab,
      semanticButton: false,
      focusNode: node,
      onTap: () => widget.onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SeedDimension.x2_5,
          vertical: SeedDimension.x2_5,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SeedNotificationBadgePositioner(
                      attach: SeedNotificationBadgeAttach.text,
                      badge: SeedNotificationBadge(
                        count: item.notificationCount,
                        showDot: item.showNotificationDot,
                      ),
                      child: Text(item.label, style: textStyle),
                    ),
                  ],
                ),
              ),
            ),
            if (showBottomIndicator)
              AnimatedContainer(
                duration: SeedDuration.d4,
                curve: SeedCurves.easing,
                height: 2.0,
                color: isSelected ? colors.fg.neutral : Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipTabs(BuildContext context, List<FocusNode> nodes) {
    final items = widget.items;
    if (items.isEmpty) {
      return SizedBox(
        height: switch (widget.size) {
          SeedTabsSize.small => 32.0,
          SeedTabsSize.medium => 36.0,
          SeedTabsSize.large => 40.0,
        },
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          widget.chipListPadding ??
          const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
      child: Semantics(
        role: SemanticsRole.tabBar,
        explicitChildNodes: true,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final bool isLast = index == items.length - 1;
            return KeyedSubtree(
              key: _chipItemKeys[index],
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: isLast ? 0 : SeedDimension.x2,
                ),
                child: _buildChipTabItem(
                  context,
                  index,
                  item,
                  index == widget.selectedIndex,
                  nodes[index],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChipTabItem(
    BuildContext context,
    int index,
    SeedTabItem item,
    bool isSelected,
    FocusNode node,
  ) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    return Opacity(
      opacity: item.enabled ? 1.0 : 0.5,
      child: SeedPressable(
        enabled: item.enabled,
        selected: isSelected,
        semanticsRole: SemanticsRole.tab,
        semanticButton: false,
        focusNode: node,
        onTap: () => widget.onTabSelected(index),
        builder: (context, isPressed) {
          final bool activePress = item.enabled && isPressed;
          Color bgColor;
          Color fgColor;
          Color? strokeColor;

          if (widget.variant == SeedTabsVariant.chipSolid) {
            if (isSelected) {
              bgColor = activePress
                  ? colors.bg.neutralSolidPressed
                  : colors.bg.neutralSolid;
              fgColor = colors.fg.onNeutralSolid;
            } else {
              bgColor = activePress
                  ? colors.bg.neutralWeakAlphaPressed
                  : colors.bg.neutralWeakAlpha;
              fgColor = colors.fg.neutral;
            }
          } else {
            // chipOutline (neutralOutline in official spec)
            if (isSelected) {
              bgColor = activePress
                  ? colors.bg.neutralSolidPressed
                  : colors.bg.neutralSolid;
              fgColor = colors.fg.onNeutralSolid;
              strokeColor = Colors.transparent;
            } else {
              bgColor = activePress
                  ? colors.bg.transparentPressed
                  : colors.bg.transparent;
              fgColor = colors.fg.neutral;
              strokeColor = colors.stroke.neutralMuted;
            }
          }

          final TextStyle textStyle = typography.t4Medium.copyWith(
            color: fgColor,
          );

          return AnimatedContainer(
            duration: SeedDuration.colorTransition,
            curve: SeedCurves.easing,
            height: switch (widget.size) {
              SeedTabsSize.small => 32.0,
              SeedTabsSize.medium => 36.0,
              SeedTabsSize.large => 40.0,
            },
            constraints: BoxConstraints(
              minWidth: switch (widget.size) {
                SeedTabsSize.small => 44.0,
                SeedTabsSize.medium => 48.0,
                SeedTabsSize.large => 52.0,
              },
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: widget.size == SeedTabsSize.large ? 16.0 : 14.0,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: SeedBorderRadius.full,
              border: strokeColor != null
                  ? Border.all(color: strokeColor, width: 1.0)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(item.label, style: textStyle),
                if (item.notificationCount != null ||
                    item.showNotificationDot) ...[
                  const SizedBox(width: SeedDimension.x1),
                  SeedNotificationBadge(
                    count: item.notificationCount,
                    showDot: item.showNotificationDot,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
