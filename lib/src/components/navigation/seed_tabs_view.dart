import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

import '../../foundations/motion/seed_motion.dart';
import 'seed_tabs.dart';

class SeedTabsController extends ChangeNotifier {
  SeedTabsController({int initialIndex = 0}) : _index = initialIndex;
  int _index;
  int get index => _index;
  void animateTo(int index) {
    if (index != _index) {
      _index = index;
      notifyListeners();
    }
  }
}

/// Tab headers with content, optional swipe carousel and measured dynamic height.
class SeedTabsView extends StatefulWidget {
  const SeedTabsView({
    super.key,
    required this.items,
    required this.children,
    this.selectedIndex,
    this.initialIndex = 0,
    this.onTabSelected,
    this.controller,
    this.variant = SeedTabsVariant.line,
    this.size,
    this.fill = true,
    this.carousel = false,
    this.swipeable = true,
    this.dynamicHeight = false,
    this.height,
    bool? keepAlive,
    this.lazyMount = false,
    this.unmountOnExit = false,
    this.duration = SeedDuration.d4,
    this.onSwipeStart,
    this.onSwipeEnd,
    this.onSettle,
    this.scrollToTopOnChange = false,
    this.contentScrollControllers = const [],
  }) : keepAlive = (keepAlive ?? true) && !unmountOnExit;
  final List<SeedTabItem> items;
  final List<Widget> children;
  final int? selectedIndex;
  final int initialIndex;
  final ValueChanged<int>? onTabSelected;
  final SeedTabsController? controller;
  final SeedTabsVariant variant;
  final SeedTabsSize? size;
  final bool fill,
      carousel,
      swipeable,
      dynamicHeight,
      keepAlive,
      lazyMount,
      unmountOnExit;

  /// Fixed carousel height, or its initial height when [dynamicHeight] is true.
  final double? height;
  final Duration duration;
  final VoidCallback? onSwipeStart, onSwipeEnd;
  final ValueChanged<int>? onSettle;
  final bool scrollToTopOnChange;
  final List<ScrollController?> contentScrollControllers;
  @override
  State<SeedTabsView> createState() => _SeedTabsViewState();
}

class SeedChipTabsView extends SeedTabsView {
  const SeedChipTabsView({
    super.key,
    required super.items,
    required super.children,
    super.selectedIndex,
    super.initialIndex,
    super.onTabSelected,
    super.controller,
    super.variant = SeedTabsVariant.chipSolid,
    super.size,
    super.fill = false,
    super.carousel,
    super.swipeable,
    super.dynamicHeight,
    super.height,
    super.keepAlive,
    super.lazyMount,
    super.unmountOnExit,
    super.duration,
    super.onSwipeStart,
    super.onSwipeEnd,
    super.onSettle,
    super.scrollToTopOnChange,
    super.contentScrollControllers,
  });
}

class _SeedTabsViewState extends State<SeedTabsView> {
  late int _index =
      (widget.selectedIndex ?? widget.controller?.index ?? widget.initialIndex)
          .clamp(0, widget.items.length - 1);
  late final PageController _pages = PageController(initialPage: _index);
  late final Set<int> _visited = {_index};
  final Map<int, double> _heights = {};
  double? _lastViewportHeight;
  bool _heightAnimationReady = false;
  bool _heightInitializationScheduled = false;
  bool _swiping = false, _syncingController = false;
  bool _animating = false;
  int _animationId = 0;
  bool _swipePageReported = false;
  @override
  void initState() {
    super.initState();
    assert(
      widget.items.length == widget.children.length && widget.items.isNotEmpty,
    );
    widget.controller?.addListener(_controllerChanged);
  }

  @override
  void didUpdateWidget(SeedTabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      widget.controller?.addListener(_controllerChanged);
    }
    final next = (widget.selectedIndex ?? widget.controller?.index ?? _index)
        .clamp(0, widget.items.length - 1);
    if (next != _index) {
      _index = next;
      _visited.add(_index);
      if (!_swiping) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && next == _index) _animate(next);
        });
      }
    }
  }

  void _controllerChanged() {
    if (_syncingController || !mounted || widget.selectedIndex != null) return;
    final next = widget.controller!.index.clamp(0, widget.items.length - 1);
    if (next != _index) {
      setState(() {
        _index = next;
        _visited.add(_index);
      });
      _animate(next);
    }
  }

  void _recordHeight(int index, double height) {
    if (!mounted || _heights[index] == height) return;
    setState(() => _heights[index] = height);
    if (index == _index &&
        !_heightAnimationReady &&
        !_heightInitializationScheduled) {
      _heightInitializationScheduled = true;
      // Lay out the first real height without animating from the fallback.
      // Enable transitions only after that layout has reached the screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _heightAnimationReady = true);
      });
    }
  }

  Future<void> _animate(int index) async {
    if (!mounted || !_pages.hasClients) return;
    if (!_animating && (_pages.page! - index).abs() < .001) return;
    final animationId = ++_animationId;
    _animating = true;
    final reduce = MediaQuery.disableAnimationsOf(context);
    try {
      await _pages.animateToPage(
        index,
        duration: reduce ? const Duration(milliseconds: 1) : widget.duration,
        curve: SeedCurves.easing,
      );
    } finally {
      if (animationId == _animationId) _animating = false;
    }
  }

  void _changed(int index, {bool fromPage = false}) {
    if (index == _index) return;
    if (!widget.items[index].enabled) {
      if (fromPage) _animate(_index);
      return;
    }
    widget.onTabSelected?.call(index);
    if (widget.selectedIndex != null) {
      if (fromPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.selectedIndex != index) {
            _animate(widget.selectedIndex!);
          }
        });
      }
      return;
    }
    setState(() {
      _index = index;
      _visited.add(_index);
    });
    _syncingController = true;
    widget.controller?.animateTo(index);
    _syncingController = false;
    if (!fromPage) _animate(index);
    if (widget.scrollToTopOnChange &&
        index < widget.contentScrollControllers.length) {
      final scroll = widget.contentScrollControllers[index];
      if (scroll?.hasClients ?? false) scroll!.jumpTo(0);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (!widget.carousel) {
      body = widget.keepAlive
          ? IndexedStack(
              index: _index,
              children: [
                for (var i = 0; i < widget.children.length; i++)
                  if (!widget.lazyMount || _visited.contains(i))
                    KeyedSubtree(
                      key: ValueKey<int>(i),
                      child: widget.children[i],
                    )
                  else
                    SizedBox.shrink(key: ValueKey<int>(i)),
              ],
            )
          : KeyedSubtree(
              key: ValueKey<int>(_index),
              child: widget.children[_index],
            );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final height = widget.dynamicHeight
              ? (_heights[_index] ??
                    _lastViewportHeight ??
                    widget.height ??
                    300)
              : widget.height ??
                    (constraints.hasBoundedHeight
                        ? constraints.maxHeight
                        : 300);
          _lastViewportHeight = height;
          return AnimatedContainer(
            duration:
                MediaQuery.disableAnimationsOf(context) ||
                    (widget.dynamicHeight && !_heightAnimationReady)
                ? Duration.zero
                : widget.duration,
            alignment: Alignment.topCenter,
            height: height,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth != 0 ||
                    notification.metrics.axis != Axis.horizontal) {
                  return false;
                }
                final userScroll =
                    (notification is ScrollStartNotification &&
                        notification.dragDetails != null) ||
                    (notification is UserScrollNotification &&
                        notification.direction != ScrollDirection.idle);
                if (userScroll && !_swiping) {
                  // A user drag takes over from an unfinished tab animation.
                  _animationId++;
                  _animating = false;
                  _swiping = true;
                  _swipePageReported = false;
                  widget.onSwipeStart?.call();
                }
                if (notification is ScrollEndNotification) {
                  if (_swiping) {
                    _swiping = false;
                    if (!_swipePageReported) {
                      _changed(_pages.page!.round(), fromPage: true);
                    }
                    widget.onSwipeEnd?.call();
                  }
                  if ((_pages.page! - _index).abs() < .001) {
                    widget.onSettle?.call(_index);
                  }
                  if (widget.selectedIndex != null &&
                      widget.selectedIndex != _index) {
                    _animate(widget.selectedIndex!);
                  }
                }
                return false;
              },
              child: PageView.builder(
                controller: _pages,
                physics: widget.swipeable
                    ? const PageScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: widget.children.length,
                onPageChanged: (index) {
                  // Passing intermediate pages is not a new tab selection.
                  if (!_animating) {
                    if (_swiping) _swipePageReported = true;
                    _changed(index, fromPage: true);
                  }
                },
                itemBuilder: (context, index) {
                  Widget child = widget.children[index];
                  if (widget.unmountOnExit && index != _index) {
                    child = const SizedBox.shrink();
                  }
                  if (widget.dynamicHeight &&
                      !(widget.unmountOnExit && index != _index)) {
                    child = OverflowBox(
                      minHeight: 0,
                      maxHeight: double.infinity,
                      alignment: Alignment.topCenter,
                      child: _SeedPageMeasurer(
                        onHeight: (height) => _recordHeight(index, height),
                        child: child,
                      ),
                    );
                  }
                  return _SeedKeptAliveTabPage(
                    keepAlive: widget.keepAlive,
                    child: child,
                  );
                },
              ),
            ),
          );
        },
      );
    }
    body = Semantics(
      role: SemanticsRole.tabPanel,
      container: true,
      child: body,
    );
    final header = SeedTabs(
      items: widget.items,
      selectedIndex: _index,
      onTabSelected: _changed,
      variant: widget.variant,
      size: widget.size,
      fill: widget.fill,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        if (widget.carousel && !widget.dynamicHeight && widget.height == null)
          Flexible(child: body)
        else
          body,
      ],
    );
  }
}

class _SeedKeptAliveTabPage extends StatefulWidget {
  const _SeedKeptAliveTabPage({required this.keepAlive, required this.child});
  final bool keepAlive;
  final Widget child;
  @override
  State<_SeedKeptAliveTabPage> createState() => _SeedKeptAliveTabPageState();
}

class _SeedKeptAliveTabPageState extends State<_SeedKeptAliveTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;
  @override
  void didUpdateWidget(_SeedKeptAliveTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keepAlive != widget.keepAlive) updateKeepAlive();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Stops a carousel's horizontal recognizer while allowing nested scrollables to win.
class SeedCarouselPreventDrag extends StatelessWidget {
  const SeedCarouselPreventDrag({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onHorizontalDragStart: (_) {},
    onHorizontalDragUpdate: (_) {},
    onHorizontalDragEnd: (_) {},
    child: child,
  );
}

class _SeedPageMeasurer extends SingleChildRenderObjectWidget {
  const _SeedPageMeasurer({required this.onHeight, required super.child});
  final ValueChanged<double> onHeight;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SeedPageMeasureRender(onHeight);
  @override
  void updateRenderObject(
    BuildContext context,
    _SeedPageMeasureRender renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _SeedPageMeasureRender extends RenderProxyBox {
  _SeedPageMeasureRender(this.onHeight);
  ValueChanged<double> onHeight;
  double? _height;
  @override
  void performLayout() {
    super.performLayout();
    if (_height != size.height) {
      _height = size.height;
      final value = size.height;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attached) onHeight(value);
      });
    }
  }
}

/// A pinned tab list for CustomScrollView/NestedScrollView's sliver headers.
class SeedStickyTabsHeader extends StatelessWidget {
  const SeedStickyTabsHeader({
    super.key,
    required this.child,
    this.height = 44,
    this.floating = false,
    this.pinned = true,
  });
  final Widget child;
  final double height;
  final bool floating, pinned;
  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
    floating: floating,
    pinned: pinned,
    delegate: _SeedTabHeaderDelegate(child, height),
  );
}

class _SeedTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SeedTabHeaderDelegate(this.child, this.height);
  final Widget child;
  final double height;
  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);
  @override
  bool shouldRebuild(_SeedTabHeaderDelegate oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}
