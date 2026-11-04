import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_control.dart';
import '../../foundations/motion/seed_motion.dart';
import 'seed_select_box_group.dart';

/// Type of selection glyph displayed in a select box.
enum SeedSelectBoxControl {
  /// Checkbox-style tick mark.
  checkmark,

  /// Radio-style circle mark.
  radiomark,

  /// Omit the selection mark.
  none,
}

/// Arrangement of a select box's content.
enum SeedSelectBoxLayout {
  /// Content arranged left to right.
  horizontal,

  /// Content arranged top to bottom.
  vertical,
}

/// Visibility policy for the footer of a [SeedSelectBox].
enum SeedSelectBoxFooterVisibility {
  /// Show only when selected.
  whenSelected,

  /// Show only when not selected.
  whenNotSelected,

  /// Show regardless of selection.
  always,
}

/// Select Box component of SEED Design System.
///
/// An explicit bordered card container for selecting single or multiple options.
class SeedSelectBox extends StatefulWidget {
  /// Primary text of the selection card.
  final String title;

  /// Optional supporting text below [title].
  final String? description;

  /// Optional leading graphic.
  final Widget? prefix;

  /// Custom content region within the card.
  final Widget? customContent;
  final bool? _selected;
  /// Deprecated spelling of [defaultChecked].
  @Deprecated('Use defaultChecked instead.')
  final bool defaultSelected;

  /// Parent-controlled selection state, null for internal state.
  bool? get checked => _selected;

  /// Initial selection for uncontrolled use, false by default.
  bool get defaultChecked => defaultSelected;

  /// Callback for a proposed change of selection.
  ValueChanged<bool>? get onCheckedChange => onSelected;

  /// Identifier for radio-mode selection within [SeedSelectBoxGroup].
  final Object? value;

  /// Deprecated spelling of [onCheckedChange].
  @Deprecated('Use onCheckedChange instead.')
  final ValueChanged<bool>? onSelected;
  final SeedSelectBoxControl? _control;
  final SeedSelectBoxLayout? _layout;
  /// Whether the card accepts input; defaults to true.
  final bool enabled;

  /// Allows focus while suppressing changes to selection; defaults to false.
  final bool readOnly;

  /// Displays an indeterminate selection mark.
  final bool indeterminate;

  /// Marks the control invalid for accessible form semantics.
  final bool invalid;

  /// Additional leading label, trailing decoration, and expandable footer.
  final Widget? label, suffix, footer;

  /// Whether a hidden footer is removed from layout, true by default.
  final bool collapseFooter;

  /// Conditional visibility of [footer], independent of [collapseFooter].
  final SeedSelectBoxFooterVisibility? footerVisibility;

  /// Creates a selection card that can be standalone or grouped.
  ///
  /// [checked], [defaultChecked] and [onCheckedChange] use React's checkbox
  /// ownership model. [selected], [defaultSelected] and [onSelected] are
  /// deprecated compatibility spellings and cannot coexist with their
  /// matching official parameter. In a radio [SeedSelectBoxGroup], [value]
  /// identifies this option and the group controls selection.
  ///
  /// [control] defaults to a checkmark outside a radio group and a radio mark
  /// inside one; [layout] defaults to horizontal.
  const SeedSelectBox({
    super.key,
    required this.title,
    this.description,
    this.prefix,
    this.customContent,
    bool? checked,
    @Deprecated('Use checked instead.') bool? selected,
    bool? defaultChecked,
    @Deprecated('Use defaultChecked instead.') bool? defaultSelected,
    this.value,
    ValueChanged<bool>? onCheckedChange,
    @Deprecated('Use onCheckedChange instead.') ValueChanged<bool>? onSelected,
    SeedSelectBoxControl? control,
    SeedSelectBoxLayout? layout,
    this.enabled = true,
    this.readOnly = false,
    this.indeterminate = false,
    this.invalid = false,
    this.label,
    this.suffix,
    this.footer,
    this.collapseFooter = true,
    this.footerVisibility,
    // ignore: prefer_initializing_formals
  }) : _selected = checked ?? selected,
       defaultSelected = defaultChecked ?? defaultSelected ?? false,
       onSelected = onCheckedChange ?? onSelected,
       assert(checked == null || selected == null),
       assert(defaultChecked == null || defaultSelected == null),
       assert(onCheckedChange == null || onSelected == null),
       // ignore: prefer_initializing_formals
       _control = control,
       // ignore: prefer_initializing_formals
       _layout = layout;

  /// Legacy effective selection, using initial state when uncontrolled.
  @Deprecated('Use checked or defaultChecked instead.')
  bool get selected => _selected ?? defaultSelected;

  /// Effective icon type, default [SeedSelectBoxControl.checkmark].
  SeedSelectBoxControl get control =>
      _control ?? SeedSelectBoxControl.checkmark;

  /// Effective layout, default [SeedSelectBoxLayout.horizontal].
  SeedSelectBoxLayout get layout => _layout ?? SeedSelectBoxLayout.horizontal;

  /// Creates state for uncontrolled card selection and group focus.
  @override
  State<SeedSelectBox> createState() => _SeedSelectBoxState();
}

class _SeedSelectBoxState extends State<SeedSelectBox> {
  late bool _uncontrolledSelected = widget.defaultSelected;
  final FocusNode _radioFocusNode = FocusNode();
  SeedSelectBoxFocusCoordinator? _focusCoordinator;

  @override
  void dispose() {
    _focusCoordinator?.unregister(_radioFocusNode);
    _radioFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = SeedSelectBoxGroupScope.maybeOf(context);
    final inRadioGroup =
        group != null && group.isRadioGroup && widget.value != null;
    final effectiveControl =
        widget._control ??
        (inRadioGroup
            ? SeedSelectBoxControl.radiomark
            : SeedSelectBoxControl.checkmark);
    final effectiveLayout =
        widget._layout ??
        group?.defaultLayout ??
        SeedSelectBoxLayout.horizontal;
    final effectiveSelected =
        widget._selected ??
        (inRadioGroup
            ? group.selectedValue == widget.value
            : _uncontrolledSelected);
    final enabled =
        widget.enabled &&
        (group?.enabled ?? true) &&
        SeedControlScope.enabledOf(context);
    final readOnly = widget.readOnly || (group?.readOnly ?? false);
    final canInteract =
        enabled &&
        !readOnly &&
        (widget.onSelected != null || inRadioGroup || widget._selected == null);

    void selectRadio() {
      if (!canInteract || !inRadioGroup || effectiveSelected) return;
      group.onSelect(widget.value);
      widget.onSelected?.call(true);
    }

    final coordinator = inRadioGroup ? group.focusCoordinator : null;
    if (_focusCoordinator != coordinator) {
      _focusCoordinator?.unregister(_radioFocusNode);
      _focusCoordinator = coordinator;
    }
    coordinator?.register(
      _radioFocusNode,
      widget.value!,
      canInteract,
      selectRadio,
    );

    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = !enabled
        ? colors.stroke.neutralWeak
        : (effectiveSelected
              ? colors.stroke.neutralContrast
              : colors.stroke.neutralWeak);

    final Color bgColor = colors.bg.transparent;

    final TextStyle titleStyle = typography.t5Medium.copyWith(
      color: enabled ? colors.fg.neutral : colors.fg.disabled,
    );

    final TextStyle descStyle = typography.t3Regular.copyWith(
      color: enabled ? colors.fg.neutralMuted : colors.fg.disabled,
    );

    final effectiveFooterVisibility =
        widget.footerVisibility ??
        (widget.collapseFooter
            ? SeedSelectBoxFooterVisibility.whenSelected
            : SeedSelectBoxFooterVisibility.always);
    final isFooterOpen = switch (effectiveFooterVisibility) {
      SeedSelectBoxFooterVisibility.whenSelected => effectiveSelected,
      SeedSelectBoxFooterVisibility.whenNotSelected => !effectiveSelected,
      SeedSelectBoxFooterVisibility.always => true,
    };
    final isFooterCollapsible =
        widget.footer != null &&
        effectiveFooterVisibility != SeedSelectBoxFooterVisibility.always;

    // React's stroke is an overlay; the padding is measured from the outer edge.
    final strokeWidth = effectiveSelected ? 2.0 : 1.0;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final prefixWidget = widget.prefix != null
        ? IconTheme(
            data: IconThemeData(
              size: 22.0,
              color: enabled ? colors.fg.neutral : colors.fg.disabled,
            ),
            child: widget.prefix!,
          )
        : null;

    final bodyColumn = Padding(
      padding: const EdgeInsets.only(right: SeedDimension.x1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label ?? Text(widget.title, style: titleStyle),
          if (widget.description != null) ...[
            const SizedBox(height: SeedDimension.x0_5),
            Text(widget.description!, style: descStyle),
          ],
        ],
      ),
    );

    return SeedPressable(
      enabled: canInteract,
      focusNode: inRadioGroup ? _radioFocusNode : null,
      checked: effectiveControl == SeedSelectBoxControl.none
          ? null
          : (widget.indeterminate &&
                    effectiveControl == SeedSelectBoxControl.checkmark
                ? null
                : effectiveSelected),
      mixed:
          widget.indeterminate &&
              effectiveControl == SeedSelectBoxControl.checkmark
          ? true
          : null,
      selected: effectiveSelected,
      inMutuallyExclusiveGroup:
          effectiveControl == SeedSelectBoxControl.radiomark ? true : null,
      expanded: isFooterCollapsible ? isFooterOpen : null,
      focusBorderRadius: SeedBorderRadius.r3,
      enableScale: false,
      onTap: () {
        if (inRadioGroup) {
          selectRadio();
          return;
        }
        final next = !effectiveSelected;
        if (widget._selected == null) {
          setState(() => _uncontrolledSelected = next);
        }
        widget.onSelected?.call(next);
      },
      builder: (context, isPressed) => Container(
        padding: effectiveLayout == SeedSelectBoxLayout.horizontal
            ? EdgeInsets.fromLTRB(
                20 - strokeWidth,
                16 - strokeWidth,
                16 - strokeWidth,
                16 - strokeWidth,
              )
            : EdgeInsets.symmetric(
                horizontal: 16 - strokeWidth,
                vertical: 20 - strokeWidth,
              ),
        decoration: BoxDecoration(
          color: isPressed ? colors.bg.transparentPressed : bgColor,
          borderRadius: SeedBorderRadius.r3,
          border: Border.all(color: strokeColor, width: strokeWidth),
        ),
        child: SeedContentScale(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment:
                    effectiveLayout == SeedSelectBoxLayout.horizontal
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (effectiveLayout == SeedSelectBoxLayout.horizontal) ...[
                    if (prefixWidget != null) ...[
                      prefixWidget,
                      const SizedBox(width: SeedDimension.x3),
                    ],
                    Expanded(child: bodyColumn),
                  ] else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (prefixWidget != null) ...[
                            prefixWidget,
                            const SizedBox(height: SeedDimension.x2_5),
                          ],
                          bodyColumn,
                        ],
                      ),
                    ),
                  if (widget.suffix != null) ...[
                    widget.suffix!,
                    const SizedBox(width: 8),
                  ],
                  if (effectiveControl != SeedSelectBoxControl.none) ...[
                    const SizedBox(width: SeedDimension.x1_5),
                    _buildControlMark(
                      colors,
                      enabled: enabled,
                      selected: effectiveSelected,
                      isPressed: isPressed,
                      control: effectiveControl,
                    ),
                  ],
                ],
              ),
              if (widget.footer != null)
                if (effectiveFooterVisibility ==
                    SeedSelectBoxFooterVisibility.always)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: widget.footer,
                  )
                else
                  AnimatedSize(
                    duration: disableAnimations
                        ? Duration.zero
                        : (isFooterOpen
                              ? const Duration(milliseconds: 400)
                              : SeedDuration.d6),
                    curve: SeedCurves.easing,
                    alignment: Alignment.topCenter,
                    child: AnimatedOpacity(
                      opacity: isFooterOpen ? 1.0 : 0.0,
                      duration: disableAnimations
                          ? Duration.zero
                          : (isFooterOpen
                                ? SeedDuration.d6
                                : const Duration(milliseconds: 400)),
                      curve: SeedCurves.easing,
                      child: isFooterOpen
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: widget.footer,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              if (widget.customContent != null) ...[
                const SizedBox(height: SeedDimension.x3),
                widget.customContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlMark(
    dynamic colors, {
    required bool enabled,
    required bool selected,
    required bool isPressed,
    required SeedSelectBoxControl control,
  }) {
    if (control == SeedSelectBoxControl.checkmark) {
      final Color iconColor = !enabled
          ? colors.fg.disabled
          : (selected
                ? colors.fg.neutral
                : (isPressed
                      ? colors.fg.neutralSubtle
                      : colors.fg.placeholder));
      return SizedBox.square(
        dimension: 20,
        child: Center(
          child: Icon(Icons.check_rounded, size: 15.0, color: iconColor),
        ),
      );
    } else {
      // radiomark
      return Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected && enabled
              ? colors.bg.neutralSolid
              : colors.bg.transparent,
          border: Border.all(
            color: !enabled
                ? colors.stroke.neutralWeak
                : (selected
                      ? colors.stroke.neutralContrast
                      : colors.stroke.neutralWeak),
            width: selected && enabled ? 0 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? Container(
                width: enabled ? 8 : 10,
                height: enabled ? 8 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled
                      ? colors.fg.onNeutralSolid
                      : colors.fg.disabled,
                ),
              )
            : null,
      );
    }
  }
}
