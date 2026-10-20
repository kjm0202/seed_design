import 'package:material_ui/material_ui.dart';

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
  large;

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
  });

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
    _isExpanded = widget.initiallyExpanded;
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
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
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle titleStyle =
        (widget.size == SeedAccordionSize.medium
                ? typography.t5Medium
                : typography.t7Medium)
            .copyWith(
              color: widget.enabled ? colors.fg.neutral : colors.fg.disabled,
            );

    final TextStyle descStyle =
        (widget.size == SeedAccordionSize.medium
                ? typography.t3Medium
                : typography.t5Medium)
            .copyWith(
              color: widget.enabled
                  ? colors.fg.neutralSubtle
                  : colors.fg.disabled,
            );

    Widget trigger = SeedPressable(
      enabled: widget.enabled,
      expanded: _isExpanded,
      enableScale: false,
      onTap: _handleTap,
      builder: (context, isPressed) {
        return Container(
          padding: widget.size.padding,
          color: isPressed
              ? colors.bg.layerDefaultPressed
              : colors.bg.layerDefault,
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
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
                  size: widget.size.iconSize,
                  color: widget.enabled
                      ? colors.fg.neutralSubtle
                      : colors.fg.disabled,
                ),
              ),
            ],
          ),
        );
      },
    );

    Widget contentBody = ClipRect(
      child: AnimatedBuilder(
        animation: _controller.view,
        builder: (context, child) {
          return Align(
            alignment: Alignment.centerLeft,
            heightFactor: _heightFactor.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          color: colors.bg.layerDefault,
          padding: EdgeInsets.fromLTRB(
            widget.size.padding.horizontal / 2,
            0,
            widget.size.padding.horizontal / 2,
            widget.size.padding.vertical / 2,
          ),
          child: widget.content,
        ),
      ),
    );

    if (widget.variant == SeedAccordionVariant.separated) {
      return Container(
        margin: EdgeInsets.only(
          bottom: widget.size == SeedAccordionSize.medium ? 12 : 16,
        ),
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
      children: [trigger, contentBody, const SeedDivider()],
    );
  }
}
