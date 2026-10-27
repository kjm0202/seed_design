import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsRole;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';
import '../selection/seed_radio.dart';
import '../selection/seed_switch.dart';

/// Vertical alignment for prefix and suffix in [SeedListItem].
enum SeedListItemAlign { center, top }

/// List Item component of SEED Design System.
///
/// Features prefix slot (avatar/icon), title, detail (subtitle),
/// suffix slot (chevron, switch, badge), highlighted state,
/// and pressed feedback with margin/radius motion.
class SeedListItem extends StatelessWidget {
  final Widget? title;
  final String? titleText;
  final Widget? detail;
  final String? detailText;
  final Widget? prefix;
  final Widget? suffix;
  final String? suffixText;
  final SeedListItemAlign align;
  final bool highlighted;
  final bool enabled;
  final bool showDivider;
  final bool? checked;
  final bool? toggled;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const SeedListItem({
    super.key,
    this.title,
    this.titleText,
    this.detail,
    this.detailText,
    this.prefix,
    this.suffix,
    this.suffixText,
    this.align = SeedListItemAlign.center,
    this.highlighted = false,
    this.enabled = true,
    this.showDivider = true,
    this.checked,
    this.toggled,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SeedDimension.x4,
      vertical: SeedDimension.x3,
    ),
  }) : assert(
         title == null || titleText == null,
         'Cannot provide both title and titleText',
       );

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final parentInteraction = onTap == null
        ? SeedInteractionState.maybeOf(context)
        : null;

    final Widget titleWidget =
        title ??
        Text(
          titleText ?? '',
          style: typography.t5Regular.copyWith(
            color: enabled ? colors.fg.neutral : colors.fg.disabled,
          ),
        );

    final Widget? detailWidget =
        detail ??
        (detailText != null
            ? Text(
                detailText!,
                style: typography.t3Regular.copyWith(
                  color: enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
                ),
              )
            : null);

    final Widget? suffixTextWidget = suffixText != null
        ? Text(
            suffixText!,
            style: typography.t5Regular.copyWith(
              color: enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
            ),
          )
        : null;

    return Semantics(
      role: _SeedListDividers.maybeOf(context) == null
          ? null
          : SemanticsRole.listItem,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeedPressable(
            enabled: enabled && onTap != null,
            onTap: onTap,
            enableScale: false,
            semanticButton: checked == null && toggled == null && onTap != null,
            checked: checked,
            toggled: toggled,
            builder: (context, isPressed) {
              isPressed =
                  enabled &&
                  (isPressed ||
                      parentInteraction?.pressed == true ||
                      parentInteraction?.hovered == true);
              Color bgColor = colors.bg.transparent;
              if (highlighted) {
                bgColor = colors.bg.brandWeak;
              }
              if (isPressed) {
                bgColor = highlighted
                    ? colors.bg.brandWeakPressed
                    : colors.bg.transparentPressed;
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: SeedDuration.d3,
                      curve: SeedCurves.easing,
                      margin: EdgeInsets.symmetric(
                        horizontal: isPressed ? SeedDimension.x1_5 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(
                          isPressed ? SeedDimension.x2_5 : 0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: padding,
                    child: SeedContentScale(
                      pressed: parentInteraction?.pressed,
                      child: Row(
                        crossAxisAlignment: align == SeedListItemAlign.center
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          if (prefix != null) ...[
                            IconTheme(
                              data: IconThemeData(
                                size: 22.0,
                                color: enabled
                                    ? colors.fg.neutral
                                    : colors.fg.disabled,
                              ),
                              child: prefix!,
                            ),
                            const SizedBox(width: SeedDimension.x3),
                          ],
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: SeedDimension.x2_5,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  titleWidget,
                                  if (detailWidget != null) ...[
                                    const SizedBox(height: SeedDimension.x0_5),
                                    detailWidget,
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (suffixTextWidget != null || suffix != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ?suffixTextWidget,
                                if (suffixTextWidget != null && suffix != null)
                                  const SizedBox(width: SeedDimension.x1),
                                if (suffix != null)
                                  IconTheme(
                                    data: IconThemeData(
                                      size: 18.0,
                                      color: enabled
                                          ? colors.fg.neutralSubtle
                                          : colors.fg.disabled,
                                    ),
                                    child: suffix!,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (showDivider &&
              (_SeedListDividers.maybeOf(context)?.showDividers ?? true))
            const SeedDivider(),
        ],
      ),
    );
  }
}

/// Container that groups multiple [SeedListItem] items with optional dividers.
class SeedList extends StatelessWidget {
  final List<Widget> children;
  final bool showDividers;

  const SeedList({super.key, required this.children, this.showDividers = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;

    return Semantics(
      role: SemanticsRole.list,
      child: Container(
        color: colors.bg.layerDefault,
        child: _SeedListDividers(
          showDividers: showDividers,
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

class _SeedListDividers extends InheritedWidget {
  const _SeedListDividers({required this.showDividers, required super.child});

  final bool showDividers;

  static _SeedListDividers? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SeedListDividers>();

  @override
  bool updateShouldNotify(_SeedListDividers oldWidget) =>
      showDividers != oldWidget.showDividers;
}

enum SeedListHeaderVariant { mediumWeak, boldSolid }

class SeedListHeader extends StatelessWidget {
  const SeedListHeader({
    super.key,
    required this.title,
    this.suffix,
    this.variant = SeedListHeaderVariant.mediumWeak,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
  });
  final String title;
  final Widget? suffix;
  final SeedListHeaderVariant variant;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: variant == SeedListHeaderVariant.boldSolid
                  ? context.seedTypography.t5Bold.copyWith(
                      color: context.seedColor.fg.neutral,
                    )
                  : context.seedTypography.t4Medium.copyWith(
                      color: context.seedColor.fg.neutralSubtle,
                    ),
            ),
          ),
          ?suffix,
        ],
      ),
    ),
  );
}

/// One accessible selection target for the whole row, including its visual mark.
class SeedCheckListItem extends StatelessWidget {
  const SeedCheckListItem({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.detail,
    this.prefix,
    this.enabled = true,
    this.showDivider = true,
  });
  final String title;
  final String? detail;
  final Widget? prefix;
  final bool value, enabled, showDivider;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => SeedListItem(
    checked: value,
    titleText: title,
    detailText: detail,
    prefix: prefix,
    enabled: enabled,
    showDivider: showDivider,
    onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
    suffix: ExcludeSemantics(
      child: Icon(
        value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
      ),
    ),
  );
}

class SeedRadioListItem<T> extends StatelessWidget {
  const SeedRadioListItem({
    super.key,
    required this.title,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.detail,
    this.prefix,
    this.enabled = true,
    this.showDivider = true,
  });
  final String title;
  final String? detail;
  final T value;
  final T? groupValue;
  final Widget? prefix;
  final bool enabled, showDivider;
  final ValueChanged<T?>? onChanged;
  @override
  Widget build(BuildContext context) => SeedRadio<T>(
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
    enabled: enabled,
    customLabel: SeedListItem(
      titleText: title,
      detailText: detail,
      prefix: prefix,
      enabled: enabled,
      showDivider: showDivider,
    ),
  );
}

/// A switch row with a single focus and accessibility target.
class SeedSwitchListItem extends StatelessWidget {
  const SeedSwitchListItem({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.detail,
    this.prefix,
    this.enabled = true,
    this.showDivider = true,
  });
  final String title;
  final String? detail;
  final Widget? prefix;
  final bool value, enabled, showDivider;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SeedListItem(
    titleText: title,
    detailText: detail,
    prefix: prefix,
    enabled: enabled,
    showDivider: showDivider,
    toggled: value,
    onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
    suffix: ExcludeFocus(
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: SeedSwitchMark(
            value: value,
            interactive: false,
            enabled: enabled,
          ),
        ),
      ),
    ),
  );
}
