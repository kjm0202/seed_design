import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsRole;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_control.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';
import '../selection/seed_radio.dart';
import '../selection/seed_switch.dart';

/// Vertical alignment for prefix and suffix in [SeedListItem].
/// [SeedListItemAlign.center] centers row content and
/// [SeedListItemAlign.top] aligns it at the top.
enum SeedListItemAlign {
  /// Center items vertically.
  center,
  /// Align items to the top.
  top,
}

/// List Item component of SEED Design System.
///
/// Features prefix slot (avatar/icon), title, detail (subtitle),
/// suffix slot (chevron, switch, badge), highlighted state,
/// and pressed feedback with margin/radius motion.
class SeedListItem extends StatelessWidget {
  /// Custom title widget, mutually exclusive with [titleText].
  final Widget? title;
  /// Plain title rendered with SEED typography when [title] is null.
  final String? titleText;
  /// Custom supporting content, taking precedence over [detailText].
  final Widget? detail;
  /// Optional supporting text below the title.
  final String? detailText;
  /// Leading avatar, icon, or widget at the beginning of the row.
  final Widget? prefix;
  /// Trailing icon, badge, or control at the end of the row.
  final Widget? suffix;
  /// Optional trailing text before [suffix].
  final String? suffixText;
  /// Vertical alignment of row parts; defaults to [SeedListItemAlign.center].
  final SeedListItemAlign align;
  /// Highlights the row with a themed brand background when true.
  final bool highlighted;
  /// Controls tap and pressed feedback, and disabled text color.
  final bool enabled;

  /// Null follows the enclosing [SeedList]; React lists have no divider by default.
  final bool? showDivider;
  /// Optional checked accessibility state for checkbox-like rows.
  final bool? checked;
  /// Optional toggled accessibility state for switch-like rows.
  final bool? toggled;
  /// Called on row activation when [enabled] is true.
  final VoidCallback? onTap;

  /// URI exposed to accessibility services for a navigable link row. The
  /// caller remains responsible for opening the destination in [onTap].
  final Uri? linkUrl;
  /// Internal row padding; defaults to 16 horizontal and 12 vertical pixels.
  final EdgeInsetsGeometry padding;

  /// Creates an interactive or informational list item.
  ///
  /// Passing both [title] and [titleText] is invalid. [showDivider] can
  /// override an enclosing [SeedList.showDividers].
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
    this.showDivider,
    this.checked,
    this.toggled,
    this.onTap,
    this.linkUrl,
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
            semanticsLinkUrl: linkUrl,
            onTap: onTap,
            enableScale: false,
            // Rows touch their neighbours, so an outside ring would be cut.
            focusRingInside: true,
            semanticButton:
                checked == null &&
                toggled == null &&
                onTap != null &&
                linkUrl == null,
            activateOnEnter: checked == null && toggled == null,
            unfocusOnDisabledTap:
                !enabled && (checked != null || toggled != null),
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
          if (showDivider ??
              _SeedListDividers.maybeOf(context)?.showDividers ??
              false)
            const SeedDivider(),
        ],
      ),
    );
  }
}

/// A link row with the same visual layout as [SeedListItem].
///
/// The URI is part of its semantics. [onTap] opens the destination in the
/// application, allowing consumers to choose their navigation integration.
class SeedListLinkItem extends StatelessWidget {
  /// Creates a link-semantics list row; [onTap] performs actual navigation.
  const SeedListLinkItem({
    super.key,
    required this.uri,
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
    this.showDivider,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SeedDimension.x4,
      vertical: SeedDimension.x3,
    ),
  }) : assert(title == null || titleText == null);

  /// Destination URI announced to assistive technologies.
  final Uri uri;
  /// Optional custom [title] and [detail] content, plus [prefix] and [suffix]
  /// adornments. [title] cannot be combined with [titleText].
  final Widget? title, detail, prefix, suffix;
  /// Plain-text [titleText], [detailText], and [suffixText] alternatives.
  final String? titleText, detailText, suffixText;
  /// Position of leading and trailing content, defaulting to center.
  final SeedListItemAlign align;
  /// [highlighted] gives a brand background; [enabled] gates interactions.
  final bool highlighted, enabled;
  /// Optional divider override; null inherits [SeedList.showDividers].
  final bool? showDivider;
  /// Invoked for navigation; a URI by itself does not open its destination.
  final VoidCallback? onTap;
  /// Row inset; defaults to 16 horizontal and 12 vertical pixels.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SeedListItem(
    title: title,
    titleText: titleText,
    detail: detail,
    detailText: detailText,
    prefix: prefix,
    suffix: suffix,
    suffixText: suffixText,
    align: align,
    highlighted: highlighted,
    enabled: enabled,
    showDivider: showDivider,
    onTap: onTap,
    linkUrl: uri,
    padding: padding,
  );
}

/// Container that groups multiple [SeedListItem] items with optional dividers.
class SeedList extends StatelessWidget {
  /// Rows or other list content in display order.
  final List<Widget> children;
  /// Controls default dividers within [SeedListItem] descendants (false).
  final bool showDividers;

  /// Creates a semantic list with inherited divider behavior.
  const SeedList({
    super.key,
    required this.children,
    this.showDividers = false,
  });

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

/// Header presentation variants: [SeedListHeaderVariant.mediumWeak] is
/// muted medium text, [SeedListHeaderVariant.boldSolid] is bold neutral text.
enum SeedListHeaderVariant {
  /// Muted medium-weight heading.
  mediumWeak,
  /// Bold neutral heading.
  boldSolid,
}

/// Accessible section heading with optional trailing content.
class SeedListHeader extends StatelessWidget {
  /// Creates a list header using themed spacing and typography.
  const SeedListHeader({
    super.key,
    required this.title,
    this.suffix,
    this.variant = SeedListHeaderVariant.mediumWeak,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SeedSpacingX.globalGutter,
      vertical: SeedDimension.x2,
    ),
  });
  /// Heading text.
  final String title;
  /// Optional trailing widget displayed beside [title].
  final Widget? suffix;
  /// Typography variant, defaulting to [SeedListHeaderVariant.mediumWeak].
  final SeedListHeaderVariant variant;
  /// Insets around the heading; defaults to the global gutter horizontally.
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
                  ? context.seedTypography.t4Bold.copyWith(
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
  /// Creates a checkbox row with one semantics and tap target.
  const SeedCheckListItem({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.detail,
    this.prefix,
    this.enabled = true,
    this.showDivider,
  });
  /// Label displayed in the row.
  final String title;
  /// Optional supporting text below [title].
  final String? detail;
  /// Optional leading element before [title].
  final Widget? prefix;
  /// [value] is the checked state; [enabled] gates interaction.
  final bool value, enabled;
  /// Divider override; null inherits from [SeedList].
  final bool? showDivider;
  /// Notified of the inverted checked value after activation.
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

/// A generic radio selection row backed by [SeedRadio].
///
/// The entire row uses the radio control's selected state and callback.
class SeedRadioListItem<T> extends StatelessWidget {
  /// Creates a radio row whose item identity is [value].
  const SeedRadioListItem({
    super.key,
    required this.title,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.detail,
    this.prefix,
    this.enabled = true,
    this.showDivider,
    this.tone = SeedControlTone.brand,
  });
  /// Radio mark color tone, defaulting to [SeedControlTone.brand].
  final SeedControlTone tone;
  /// Text shown beside the radio mark.
  final String title;
  /// Supporting text shown below the title.
  final String? detail;
  /// This row's radio option value.
  final T value;
  /// Selected value shared with other options; null indicates no selection.
  final T? groupValue;
  /// Optional leading widget after the radio mark.
  final Widget? prefix;
  /// Disables radio interaction when false.
  final bool enabled;
  /// Divider override; null inherits from [SeedList].
  final bool? showDivider;
  /// Receives the option value after user selection.
  final ValueChanged<T?>? onChanged;
  @override
  Widget build(BuildContext context) => SeedRadio<T>(
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
    enabled: enabled,
    tone: tone,
    size: SeedRadioSize.large,
    // The row hosts the mark so it shares the row's padding and pressed surface.
    rowBuilder: (context, mark) => SeedListItem(
      titleText: title,
      detailText: detail,
      prefix: prefix == null
          ? mark
          : Row(mainAxisSize: MainAxisSize.min, children: [mark, prefix!]),
      enabled: enabled,
      showDivider: showDivider,
    ),
  );
}

/// A switch row with a single focus and accessibility target.
class SeedSwitchListItem extends StatelessWidget {
  /// Creates a switch row with one focus and semantics target.
  const SeedSwitchListItem({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.detail,
    this.prefix,
    this.enabled = true,
    this.showDivider,
  });
  /// Visible row label.
  final String title;
  /// Optional supporting text below [title].
  final String? detail;
  /// Optional leading widget.
  final Widget? prefix;
  /// [value] is the toggled state; [enabled] gates interactions.
  final bool value, enabled;
  /// Divider override; null inherits from [SeedList].
  final bool? showDivider;
  /// Receives the inverted toggled state after row activation.
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
