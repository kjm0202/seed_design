import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';

/// Variant of [SeedAccordionItem].
enum SeedAccordionVariant {
  /// Flush rows with optional dividers.
  inline,

  /// Rounded bordered cards with spacing.
  separated,
}

/// Size of [SeedAccordionItem].
enum SeedAccordionSize {
  /// Compact header and 20 px chevron.
  medium,
  /// Spacious header and 24 px chevron.
  large,
  /// Resolves to medium below a 768 px viewport, large otherwise.
  responsive;

  /// Chevron icon size (20 px for medium, 24 px otherwise).
  double get iconSize => this == SeedAccordionSize.medium ? 20.0 : 24.0;
  /// Header insets (16 px or 20 px vertical, 16 px horizontal).
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

/// Internal focus policy for a collapsed Accordion content subtree. Hidden
/// controls remain excluded from pointer, semantics and sequential traversal,
/// but an already-open floating overlay can return focus to its trigger.
class SeedAccordionContentFocusScope extends InheritedWidget {
  /// Marks a collapsed Accordion subtree for overlay focus-return policy.
  const SeedAccordionContentFocusScope({
    super.key,
    required this.hidden,
    required super.child,
  });

  /// Whether the associated content subtree is currently fully hidden.
  final bool hidden;

  /// Returns the nearest Accordion content focus policy, or null outside one.
  static SeedAccordionContentFocusScope? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SeedAccordionContentFocusScope>();

  @override
  bool updateShouldNotify(SeedAccordionContentFocusScope oldWidget) =>
      oldWidget.hidden != hidden;
}

/// Accordion item component of SEED Design System.
///
/// Features animated chevron rotation, trigger header with prefix/title/description,
/// and smooth content expand/collapse.
class SeedAccordionItem extends StatefulWidget {
  /// Required header text.
  final String title;
  /// Optional smaller text beneath [title].
  final String? description;
  /// Optional leading header widget.
  final Widget? prefix;
  /// Panel body, shown or hidden by the expansion state.
  final Widget content;
  /// Initial expansion for standalone/uncontrolled use (default false).
  final bool initiallyExpanded;
  /// Receives the proposed expansion state after activating the header.
  final ValueChanged<bool>? onExpansionChanged;
  /// Row or card presentation, default [SeedAccordionVariant.inline].
  final SeedAccordionVariant variant;
  /// Header dimensions, default [SeedAccordionSize.medium].
  final SeedAccordionSize size;
  /// Whether users can expand/collapse this row (default true).
  final bool enabled;
  /// Optional identifier when used in [SeedAccordion]; index used if null.
  final String? value;
  /// Controlled expansion; null uses internally managed [initiallyExpanded].
  final bool? expanded;
  /// Optional externally owned header focus node.
  final FocusNode? focusNode;
  /// Displays a divider in inline mode when true (default true).
  final bool showDivider;
  /// Semantic header level, restricted to 1 through 6 (default 3).
  final int headingLevel;

  /// Creates one animated, keyboard-accessible Accordion row.
  ///
  /// [expanded] overrides internal expansion when non-null, so the parent
  /// must update it after [onExpansionChanged]. When uncontrolled, expansion
  /// starts at [initiallyExpanded] and toggles on activation.
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
  final GlobalKey _contentKey = GlobalKey();

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
    _controller.addStatusListener(_releaseHiddenFocus);
  }

  // React's collapsible applies `hidden` once the exit finishes, and browsers
  // drop focus from hidden elements. Excluding traversal alone would leave an
  // already focused control in the body able to receive Enter or Space.
  // Overlay portals render outside this subtree, so an open menu keeps focus.
  void _releaseHiddenFocus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || _isExpanded) return;
    final focus = FocusManager.instance.primaryFocus;
    final content = _contentKey.currentContext?.findRenderObject();
    for (
      RenderObject? node = focus?.context?.findRenderObject();
      node != null;
      node = node.parent
    ) {
      if (identical(node, content)) {
        focus!.unfocus();
        return;
      }
    }
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

    final trigger = Semantics(
      container: true,
      explicitChildNodes: true,
      header: true,
      headingLevel: widget.headingLevel,
      child: SeedPressable(
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        expanded: _isExpanded,
        enableScale: false,
        // The panel's clip would cut an outside ring.
        focusRingInside: true,
        onTap: _handleTap,
        builder: (context, _) {
          final interaction = SeedInteractionState.maybeOf(context);
          // The official surface uses `:--engaged`, which includes hover.
          final isPressed =
              (interaction?.pressed ?? false) ||
              (interaction?.hovered ?? false);
          final insetPressed =
              isPressed && widget.variant == SeedAccordionVariant.inline;
          // The official `::before` insets alone; the trigger content stays put.
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: SeedDuration.colorTransition,
                  curve: SeedCurves.easing,
                  margin: EdgeInsets.symmetric(
                    horizontal: insetPressed ? SeedDimension.x1_5 : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      insetPressed ? SeedDimension.x2_5 : 0,
                    ),
                    // Blend the overlay before animating so interpolation keeps
                    // an opaque surface instead of flashing toward translucent.
                    color: isPressed
                        ? Color.alphaBlend(
                            colors.bg.transparentPressed,
                            colors.bg.layerDefault,
                          )
                        : colors.bg.layerDefault,
                  ),
                ),
              ),
              Padding(
                padding: size.padding,
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
              ),
            ],
          );
        },
      ),
    );

    Widget contentBody = ClipRect(
      child: AnimatedBuilder(
        animation: _controller.view,
        builder: (context, child) {
          final hidden = _controller.isDismissed && !_isExpanded;
          // A floating Menu/Popover portal can remain open when a controlled
          // Accordion is externally collapsed. Keep its trigger eligible for
          // programmatic focus return, while excluding the entire hidden body
          // from sequential Tab traversal. Pointer and accessibility exclusion
          // below remain independently enforced.
          return SeedAccordionContentFocusScope(
            hidden: hidden,
            child: ExcludeFocusTraversal(
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
            ),
          );
        },
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: widget.title,
          child: Container(
            key: _contentKey,
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
        ),
        // Keep the existing content inset, but paint the stroke above the
        // opaque trigger/content so they cannot cover its rounded corners.
        padding: const EdgeInsets.all(1),
        foregroundDecoration: BoxDecoration(
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
  /// Creates a single- or multi-expansion Accordion group.
  ///
  /// [values] controls the open item identifiers when non-null. Otherwise
  /// internal state starts from [defaultValues]. [onValuesChange] receives an
  /// unmodifiable set of proposed IDs. [onValuesChanged] is the deprecated
  /// callback alias and cannot be specified alongside [onValuesChange].
  const SeedAccordion({
    super.key,
    required this.items,
    this.values,
    this.defaultValues = const {},
    ValueChanged<Set<String>>? onValuesChange,
    @Deprecated('Use onValuesChange instead.')
    ValueChanged<Set<String>>? onValuesChanged,
    this.multiple = false,
    this.collapsible = true,
    this.enabled = true,
    this.variant = SeedAccordionVariant.inline,
    this.size = SeedAccordionSize.medium,
  }) : onValuesChanged = onValuesChange ?? onValuesChanged,
       assert(onValuesChange == null || onValuesChanged == null);
  /// Ordered rows; each [SeedAccordionItem.value] must be unique when present.
  final List<SeedAccordionItem> items;
  /// Parent-controlled IDs of expanded items, or null for internal state.
  final Set<String>? values;
  /// Initial expanded IDs in uncontrolled mode (empty by default).
  final Set<String> defaultValues;
  /// Legacy alias of [onValuesChange].
  @Deprecated('Use onValuesChange instead.')
  final ValueChanged<Set<String>>? onValuesChanged;
  /// Reports the proposed expanded IDs as an unmodifiable set.
  ValueChanged<Set<String>>? get onValuesChange => onValuesChanged;
  /// Allows several items open at once when true (default false).
  final bool multiple;
  /// Allows all items to be closed when true (default true).
  final bool collapsible;
  /// Global interaction flag; combines with each item's [SeedAccordionItem.enabled].
  final bool enabled;
  /// Group-wide row or separated-card presentation.
  final SeedAccordionVariant variant;
  /// Group-wide dimension preset; responsive resolves at 768 px.
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
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
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
