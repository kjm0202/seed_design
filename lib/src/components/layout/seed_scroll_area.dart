import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import 'seed_divider.dart';
import 'seed_scroll_fog.dart';

/// Scroll surface with reserved fog padding and a divider after leaving the top.
class SeedScrollArea extends StatefulWidget {
  /// Creates a scroll view with optional fog, a scrolled divider, and focus.
  const SeedScrollArea({
    super.key,
    required this.child,
    this.controller,
    this.direction = Axis.vertical,
    this.placements = const {SeedScrollFogPlacement.bottom},
    this.fogSize = 20,
    this.fogSizes,
    this.padding = EdgeInsets.zero,
    this.color,
    this.showScrolledDivider = false,
    this.hideScrollbar = true,
    this.showFog = true,
    this.fogOnlyWhenScrollable = false,
    this.focusableWhenScrollable = false,
  });

  /// Content of the single-child scroll view.
  final Widget child;

  /// Optional external scroll controller; retained and disposed by its owner.
  final ScrollController? controller;

  /// Scroll axis; defaults to [Axis.vertical].
  final Axis direction;

  /// Edges showing fog, initially the bottom edge.
  final Set<SeedScrollFogPlacement> placements;

  /// Default edge fade depth in logical pixels (20).
  final double fogSize;

  /// Per-edge fade depth overrides to [fogSize].
  final Map<SeedScrollFogPlacement, double>? fogSizes;

  /// Content padding, added to the reserved fog edge insets.
  final EdgeInsetsGeometry padding;

  /// Fog surface color; null uses the themed floating layer color.
  final Color? color;

  /// [showScrolledDivider] draws a top divider after scrolling;
  /// [hideScrollbar] (default true) hides the native scrollbar; [showFog]
  /// (default true) toggles edge fog.
  final bool showScrolledDivider, hideScrollbar, showFog;

  /// Show the fade and reserve its padding only when content exceeds the viewport.
  final bool fogOnlyWhenScrollable;

  /// Makes an overflowing area a keyboard stop, as browsers do for scrollers.
  /// Tracks overflow even when [fogOnlyWhenScrollable] is false.
  final bool focusableWhenScrollable;
  @override
  State<SeedScrollArea> createState() => _SeedScrollAreaState();
}

class _SeedScrollAreaState extends State<SeedScrollArea> {
  late ScrollController _controller = widget.controller ?? ScrollController();
  bool _scrolled = false;
  bool _overflow = false;
  bool _focused = false;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown => 40.0,
      LogicalKeyboardKey.arrowUp => -40.0,
      _ => null,
    };
    if (delta == null || !_controller.hasClients) return KeyEventResult.ignored;
    final position = _controller.position;
    _controller.jumpTo(
      (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
    return KeyEventResult.handled;
  }

  Set<SeedScrollFogPlacement> get _fog =>
      widget.showFog && (!widget.fogOnlyWhenScrollable || _overflow)
      ? widget.placements
      : <SeedScrollFogPlacement>{};

  double _sizeFor(SeedScrollFogPlacement placement) =>
      widget.fogSizes?[placement] ?? widget.fogSize;

  bool _metricsChanged(ScrollMetricsNotification notification) {
    if (notification.depth == 0 &&
        notification.metrics.axis == widget.direction) {
      _updateOverflow(notification.metrics);
    }
    return false;
  }

  void _updateOverflow(ScrollMetrics metrics) {
    if (!widget.fogOnlyWhenScrollable && !widget.focusableWhenScrollable) {
      return;
    }
    final axisPlacements = widget.direction == Axis.vertical
        ? {SeedScrollFogPlacement.top, SeedScrollFogPlacement.bottom}
        : {SeedScrollFogPlacement.left, SeedScrollFogPlacement.right};
    // Exclude the reserved fade band so adding padding cannot create overflow.
    final reserved = _fog
        .intersection(axisPlacements)
        .fold<double>(0.0, (sum, p) => sum + _sizeFor(p));
    final overflow =
        metrics.maxScrollExtent - metrics.minScrollExtent >
        (widget.fogOnlyWhenScrollable ? reserved + .01 : 0);
    if (_overflow != overflow) setState(() => _overflow = overflow);
  }

  void _update() {
    final next = _controller.hasClients && _controller.offset > 0;
    if (_scrolled != next && mounted) setState(() => _scrolled = next);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
  }

  @override
  void didUpdateWidget(SeedScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final old = _controller;
      old.removeListener(_update);
      _controller = widget.controller ?? ScrollController();
      _controller.addListener(_update);
      if (oldWidget.controller == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  // The first layout may report no metrics change, which would leave the area
  // out of the Tab order until it next resizes.
  void _syncOverflow() {
    if (!mounted || !_controller.hasClients) return;
    _updateOverflow(_controller.position);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focusableWhenScrollable || widget.fogOnlyWhenScrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverflow());
    }
    final fog = _fog;
    final pad =
        widget.padding.resolve(Directionality.of(context)) +
        EdgeInsets.fromLTRB(
          fog.contains(SeedScrollFogPlacement.left)
              ? _sizeFor(SeedScrollFogPlacement.left)
              : 0,
          fog.contains(SeedScrollFogPlacement.top)
              ? _sizeFor(SeedScrollFogPlacement.top)
              : 0,
          fog.contains(SeedScrollFogPlacement.right)
              ? _sizeFor(SeedScrollFogPlacement.right)
              : 0,
          fog.contains(SeedScrollFogPlacement.bottom)
              ? _sizeFor(SeedScrollFogPlacement.bottom)
              : 0,
        );
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _metricsChanged,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: !widget.hideScrollbar),
            child: Focus(
              canRequestFocus: widget.focusableWhenScrollable && _overflow,
              skipTraversal: !(widget.focusableWhenScrollable && _overflow),
              onFocusChange: (value) => setState(() => _focused = value),
              onKeyEvent: _handleKey,
              child: SingleChildScrollView(
                controller: _controller,
                primary: false,
                scrollDirection: widget.direction,
                padding: pad,
                child: widget.child,
              ),
            ),
          ),
          if (_focused &&
              FocusManager.instance.highlightMode ==
                  FocusHighlightMode.traditional)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.seedColor.stroke.focusRing,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          if (_scrolled && widget.showScrolledDivider)
            const Positioned(top: 0, left: 0, right: 0, child: SeedDivider()),
          for (final placement in fog)
            Positioned(
              top: placement == SeedScrollFogPlacement.bottom ? null : 0,
              bottom: placement == SeedScrollFogPlacement.top ? null : 0,
              left: placement == SeedScrollFogPlacement.right ? null : 0,
              right: placement == SeedScrollFogPlacement.left ? null : 0,
              height:
                  placement == SeedScrollFogPlacement.top ||
                      placement == SeedScrollFogPlacement.bottom
                  ? _sizeFor(placement)
                  : null,
              width:
                  placement == SeedScrollFogPlacement.left ||
                      placement == SeedScrollFogPlacement.right
                  ? _sizeFor(placement)
                  : null,
              child: SeedScrollFog(
                placement: placement,
                size: _sizeFor(placement),
                color: widget.color ?? context.seedColor.bg.layerFloating,
              ),
            ),
        ],
      ),
    );
  }
}
