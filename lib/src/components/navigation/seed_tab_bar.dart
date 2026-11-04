import 'package:material_ui/material_ui.dart';

import 'seed_tabs.dart';

/// SEED tab headers connected to a Material TabController and TabBarView.
///
/// Uses [DefaultTabController] when [controller] is omitted. Both header taps
/// and content swipes update the same controller. Use `SeedTabsView` when the
/// content should be managed by SEED instead.
class SeedTabBar extends StatefulWidget implements PreferredSizeWidget {
  /// Adapts [items] to a Material [TabController] and a sibling TabBarView.
  ///
  /// Uses the ambient [DefaultTabController] if [controller] is null; its
  /// length must match [items]. [onTabSelected] reports tapped indices.
  /// [variant], [size], [fill], [showScrollFog], and [chipListPadding] configure
  /// the SEED tab strip without taking ownership of the controller.
  /// An optional `key` preserves Flutter widget identity.
  const SeedTabBar({
    super.key,
    required this.items,
    this.controller,
    this.onTabSelected,
    this.variant = SeedTabsVariant.line,
    this.size,
    this.fill = true,
    this.showScrollFog = false,
    this.chipListPadding,
  });
  /// Tab labels, values, enabled states, and badges.
  final List<SeedTabItem> items;
  /// Material tab selection owner; otherwise uses [DefaultTabController].
  final TabController? controller;
  /// Called with the zero-based index after a header tap.
  final ValueChanged<int>? onTabSelected;
  /// Header appearance; defaults to [SeedTabsVariant.line].
  final SeedTabsVariant variant;
  /// Header height; defaults to small for line and medium for chip tabs.
  final SeedTabsSize? size;
  /// Whether headers fill the available extent; defaults to true.
  /// [showScrollFog] adds a faded scroll edge to a chip strip when true.
  final bool fill, showScrollFog;
  /// Optional chip-strip inset; otherwise uses the standard 16-pixel inset.
  final EdgeInsetsGeometry? chipListPadding;

  @override
  /// Height of the selected SEED tab size for use as a preferred-size header.
  Size get preferredSize => Size.fromHeight(
    (size ??
            (variant == SeedTabsVariant.line
                ? SeedTabsSize.small
                : SeedTabsSize.medium))
        .height,
  );
  @override
  /// Creates state that subscribes to the effective [TabController].
  State<SeedTabBar> createState() => _SeedTabBarState();
}

class _SeedTabBarState extends State<SeedTabBar> {
  TabController? _controller;
  void _changed() {
    if (mounted) setState(() {});
  }

  void _attach() {
    final next = widget.controller ?? DefaultTabController.maybeOf(context);
    if (next == null) {
      throw FlutterError(
        'SeedTabBar requires a controller or a DefaultTabController ancestor.',
      );
    }
    if (next.length != widget.items.length) {
      throw FlutterError(
        'SeedTabBar items and TabController.length must match.',
      );
    }
    if (next == _controller) return;
    _controller?.removeListener(_changed);
    _controller = next..addListener(_changed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach();
  }

  @override
  void didUpdateWidget(SeedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach();
  }

  @override
  void dispose() {
    _controller?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SeedTabs(
    items: widget.items,
    selectedIndex: _controller!.index,
    onTabSelected: (index) {
      _controller!.animateTo(index);
      widget.onTabSelected?.call(index);
    },
    variant: widget.variant,
    size: widget.size,
    fill: widget.fill,
    showScrollFog: widget.showScrollFog,
    chipListPadding: widget.chipListPadding,
  );
}
