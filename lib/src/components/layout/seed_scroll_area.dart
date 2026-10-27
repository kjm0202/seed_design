import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import 'seed_divider.dart';
import 'seed_scroll_fog.dart';

/// Scroll surface with reserved fog padding and a divider after leaving the top.
class SeedScrollArea extends StatefulWidget {
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
  });
  final Widget child;
  final ScrollController? controller;
  final Axis direction;
  final Set<SeedScrollFogPlacement> placements;
  final double fogSize;
  final Map<SeedScrollFogPlacement, double>? fogSizes;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool showScrolledDivider, hideScrollbar, showFog;

  /// Show the fade and reserve its padding only when content exceeds the viewport.
  final bool fogOnlyWhenScrollable;
  @override
  State<SeedScrollArea> createState() => _SeedScrollAreaState();
}

class _SeedScrollAreaState extends State<SeedScrollArea> {
  late ScrollController _controller = widget.controller ?? ScrollController();
  bool _scrolled = false;
  bool _overflow = false;
  Set<SeedScrollFogPlacement> get _fog =>
      widget.showFog && (!widget.fogOnlyWhenScrollable || _overflow)
      ? widget.placements
      : <SeedScrollFogPlacement>{};

  double _sizeFor(SeedScrollFogPlacement placement) =>
      widget.fogSizes?[placement] ?? widget.fogSize;

  bool _metricsChanged(ScrollMetricsNotification notification) {
    if (!widget.fogOnlyWhenScrollable ||
        notification.depth != 0 ||
        notification.metrics.axis != widget.direction) {
      return false;
    }
    final axisPlacements = widget.direction == Axis.vertical
        ? {SeedScrollFogPlacement.top, SeedScrollFogPlacement.bottom}
        : {SeedScrollFogPlacement.left, SeedScrollFogPlacement.right};
    // Exclude the reserved fade band so adding padding cannot create overflow.
    final reserved = _fog
        .intersection(axisPlacements)
        .fold<double>(0.0, (sum, p) => sum + _sizeFor(p));
    final metrics = notification.metrics;
    final overflow =
        metrics.maxScrollExtent - metrics.minScrollExtent > reserved + .01;
    if (_overflow != overflow) setState(() => _overflow = overflow);
    return false;
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

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              controller: _controller,
              primary: false,
              scrollDirection: widget.direction,
              padding: pad,
              child: widget.child,
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
