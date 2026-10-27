import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';

/// Variant of [SeedAccordionItem].
enum SeedAccordionVariant { inline, separated }

/// Size of [SeedAccordionItem].
enum SeedAccordionSize {
  medium,
  large,
  responsive;

  double get iconSize => this == SeedAccordionSize.medium ? 20.0 : 24.0;
  EdgeInsets get padding => this == SeedAccordionSize.medium
      ? const EdgeInsets.symmetric(
          horizontal: SeedDimension.x4,
          vertical: SeedDimension.x4,
        )
      : const EdgeInsets.symmetric(
          horizontal: SeedDimension.x4,
          vertical: SeedDimension.x5,
        );
}

/// Accordion item component of SEED Design System.
///
/// Features animated chevron rotation, trigger header with prefix/title/description,
/// and smooth content expand/collapse.
class SeedAccordionItem extends StatefulWidget {
  final String title;
  final String? description;
  final Widget? prefix;
  final Widget content;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final SeedAccordionVariant variant;
  final SeedAccordionSize size;
  final bool enabled;
  final String? value;
  final bool? expanded;
  final FocusNode? focusNode;
  final bool showDivider;
  final int headingLevel;

  const SeedAccordionItem({
    super.key,
    required this.title,
    this.description,
    this.prefix,
    required this.content,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.variant = SeedAccordionVariant.inline,
    this.size = SeedAccordionSize.medium,
    this.enabled = true,
    this.value,
    this.expanded,
    this.focusNode,
    this.showDivider = true,
    this.headingLevel = 3,
  }) : assert(headingLevel >= 1 && headingLevel <= 6);

  @override
  State<SeedAccordionItem> createState() => _SeedAccordionItemState();
}

class _SeedAccordionItemState extends State<SeedAccordionItem>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded ?? widget.initiallyExpanded;
    _controller = AnimationController(
      duration: SeedDuration.d6,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: SeedCurves.easing)),
    );
    _heightFactor = _controller.drive(CurveTween(curve: SeedCurves.easing));
  }

  @override
  void didUpdateWidget(SeedAccordionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != null && widget.expanded != _isExpanded) {
      _isExpanded = widget.expanded!;
      _isExpanded ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    if (widget.expanded != null) {
      widget.onExpansionChanged?.call(!_isExpanded);
      return;
    }
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size == SeedAccordionSize.responsive
        ? (MediaQuery.sizeOf(context).width < 768
              ? SeedAccordionSize.medium
              : SeedAccordionSize.large)
        : widget.size;
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle titleStyle =
        (size == SeedAccordionSize.medium
                ? typography.t5Medium
                : typography.t7Medium)
            .copyWith(
              color: widget.enabled ? colors.fg.neutral : colors.fg.disabled,
            );

    final TextStyle descStyle =
        (size == SeedAccordionSize.medium
                ? typography.t3Medium
                : typography.t5Medium)
            .copyWith(
              color: widget.enabled
                  ? colors.fg.neutralSubtle
                  : colors.fg.disabled,
            );

    final trigger = SeedPressable(
      focusNode: widget.focusNode,
      headingLevel: widget.headingLevel,
      enabled: widget.enabled,
      expanded: _isExpanded,
      enableScale: false,
      onTap: _handleTap,
      builder: (context, _) {
        final isPressed =
            SeedInteractionState.maybeOf(context)?.pressed ?? false;
        final insetPressed =
            isPressed && widget.variant == SeedAccordionVariant.inline;
        return AnimatedContainer(
          duration: SeedDuration.colorTransition,
          curve: SeedCurves.easing,
          margin: EdgeInsets.symmetric(
            horizontal: insetPressed ? SeedDimension.x1_5 : 0,
          ),
          padding: size.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              insetPressed ? SeedDimension.x2_5 : 0,
            ),
            color: isPressed
                ? colors.bg.transparentPressed
                : colors.bg.layerDefault,
          ),
          child: SeedContentScale(
            child: Row(
              children: [
                if (widget.prefix != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(
                      size: 22,
                      color: widget.enabled
                          ? colors.fg.neutral
                          : colors.fg.disabled,
                    ),
                    child: widget.prefix!,
                  ),
                  const SizedBox(width: SeedDimension.x3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.title, style: titleStyle),
                      if (widget.description != null) ...[
                        const SizedBox(height: SeedDimension.x0_5),
                        Text(widget.description!, style: descStyle),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: SeedDimension.x3),
                RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: size.iconSize,
                    color: widget.enabled
                        ? colors.fg.neutralSubtle
                        : colors.fg.disabled,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Widget contentBody = ClipRect(
      child: AnimatedBuilder(
        animation: _controller.view,
        builder: (context, child) {
          final hidden = _controller.isDismissed && !_isExpanded;
          return ExcludeFocus(
            excluding: hidden,
            child: ExcludeSemantics(
              excluding: hidden,
              child: IgnorePointer(
                ignoring: hidden,
                child: Opacity(
                  opacity: _heightFactor.value,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    heightFactor: _heightFactor.value,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: widget.title,
          child: Container(
            width: double.infinity,
            color: colors.bg.layerDefault,
            padding: EdgeInsets.fromLTRB(
              size.padding.horizontal / 2,
              0,
              size.padding.horizontal / 2,
              size.padding.vertical / 2,
            ),
            child: widget.content,
          ),
        ),
      ),
    );

    if (widget.variant == SeedAccordionVariant.separated) {
      return Container(
        decoration: BoxDecoration(
          color: colors.bg.layerDefault,
          borderRadius: SeedBorderRadius.r3,
          border: Border.all(color: colors.stroke.neutralWeak, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [trigger, contentBody],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        trigger,
        contentBody,
        if (widget.showDivider)
          SeedDivider(
            color: colors.stroke.neutralSubtle,
            indent: SeedDimension.x3,
            endIndent: SeedDimension.x3,
          ),
      ],
    );
  }
}

/// Controlled or uncontrolled single/multiple accordion group.
class SeedAccordion extends StatefulWidget {
  const SeedAccordion({
    super.key,
    required this.items,
    this.values,
    this.defaultValues = const {},
    ValueChanged<Set<String>>? onValuesChange,
    ValueChanged<Set<String>>? onValuesChanged,
    this.multiple = false,
    this.collapsible = true,
    this.enabled = true,
    this.variant = SeedAccordionVariant.inline,
    this.size = SeedAccordionSize.medium,
  }) : onValuesChanged = onValuesChange ?? onValuesChanged,
       assert(onValuesChange == null || onValuesChanged == null);
  final List<SeedAccordionItem> items;
  final Set<String>? values;
  final Set<String> defaultValues;
  final ValueChanged<Set<String>>? onValuesChanged;
  ValueChanged<Set<String>>? get onValuesChange => onValuesChanged;
  final bool multiple;
  final bool collapsible;
  final bool enabled;
  final SeedAccordionVariant variant;
  final SeedAccordionSize size;
  @override
  State<SeedAccordion> createState() => _SeedAccordionState();
}

class _SeedAccordionState extends State<SeedAccordion> {
  late Set<String> _values = Set.of(widget.defaultValues);
  final Map<String, FocusNode> _nodes = {};
  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawValues = widget.values ?? _values;
    final values = widget.multiple ? rawValues : rawValues.take(1).toSet();
    final size = widget.size == SeedAccordionSize.responsive
        ? (MediaQuery.sizeOf(context).width < 768
              ? SeedAccordionSize.medium
              : SeedAccordionSize.large)
        : widget.size;
    final ids = [
      for (var i = 0; i < widget.items.length; i++)
        widget.items[i].value ?? '$i',
    ];
    assert(ids.toSet().length == ids.length, 'Accordion values must be unique');
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final available = [
          for (var i = 0; i < ids.length; i++)
            if (widget.enabled && widget.items[i].enabled) ids[i],
        ];
        final current = available.indexWhere(
          (id) => _nodes[id]?.hasFocus ?? false,
        );
        if (current < 0) return KeyEventResult.ignored;
        final key = event.logicalKey;
        final next = key == LogicalKeyboardKey.home
            ? 0
            : key == LogicalKeyboardKey.end
            ? available.length - 1
            : key == LogicalKeyboardKey.arrowDown
            ? (current + 1) % available.length
            : key == LogicalKeyboardKey.arrowUp
            ? (current - 1) % available.length
            : -1;
        if (next < 0) return KeyEventResult.ignored;
        _nodes[available[next]]?.requestFocus();
        return KeyEventResult.handled;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (widget.variant == SeedAccordionVariant.separated && i > 0)
              SizedBox(
                height: size == SeedAccordionSize.medium
                    ? SeedDimension.x3
                    : SeedDimension.x4,
              ),
            SeedAccordionItem(
              key: ValueKey(ids[i]),
              value: ids[i],
              title: widget.items[i].title,
              description: widget.items[i].description,
              prefix: widget.items[i].prefix,
              headingLevel: widget.items[i].headingLevel,
              content: widget.items[i].content,
              variant: widget.variant,
              size: size,
              enabled: widget.enabled && widget.items[i].enabled,
              showDivider:
                  widget.items[i].showDivider &&
                  (widget.variant != SeedAccordionVariant.inline ||
                      i < widget.items.length - 1),
              expanded: values.contains(ids[i]),
              focusNode: _nodes.putIfAbsent(ids[i], FocusNode.new),
              onExpansionChanged: (expanded) {
                final next = widget.multiple
                    ? Set<String>.of(values)
                    : <String>{};
                if (expanded) {
                  next.add(ids[i]);
                } else {
                  next.remove(ids[i]);
                }
                if (!widget.collapsible && next.isEmpty) return;
                if (widget.values == null) setState(() => _values = next);
                widget.onValuesChanged?.call(Set.unmodifiable(next));
                widget.items[i].onExpansionChanged?.call(expanded);
              },
            ),
          ],
        ],
      ),
    );
  }
}
