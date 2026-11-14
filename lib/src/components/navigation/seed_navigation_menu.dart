import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_help_bubble.dart';
import '../layout/seed_divider.dart';
import '../overlay/seed_anchored_overlay.dart';
import '../overlay/seed_menu.dart' show SeedMenuSize;

// React useNavigationMenu MIN_HEIGHT: size() never reports less than this.
const double _kMinAvailableHeight = 200;

/// Coordinates a set of hover-disclosure flyouts (React
/// `NavigationMenu.Provider`, `@seed-design/react` 3.3.0).
///
/// Tracks which [SeedNavigationMenuRoot] is open — at most one, identified by
/// its [SeedNavigationMenuRoot.value] — and wraps [child] in a shared
/// [SeedTooltipDelayGroup], so once a flyout is open its siblings (and any
/// [SeedHelpBubbleTooltip] rendered inside [child]) open without delay.
///
/// This is a disclosure pattern, not a menu: triggers report an expanded
/// state, the flyout is non-modal and has no menu role or arrow-key roving
/// focus. Mouse hover opens after [openDelay] and closes after [closeDelay];
/// touch and click toggle. Hover and pointer clicks never move focus into a
/// flyout; Enter/Space on a trigger opens it, focuses its first item, and
/// Escape or selection returns focus to the trigger.
///
/// ```dart
/// SeedNavigationMenu(
///   child: Row(children: [
///     SeedNavigationMenuRoot(
///       value: 'products',
///       trigger: const SeedNavigationMenuTrigger(child: Text('Products')),
///       content: SeedNavigationMenuContent(children: [
///         SeedNavigationMenuGroup(label: 'Apps', children: [
///           SeedNavigationMenuItem(label: 'Karrot', onTap: () {}),
///         ]),
///       ]),
///     ),
///   ]),
/// )
/// ```
class SeedNavigationMenu extends StatefulWidget {
  /// Creates a navigation menu provider around [child].
  ///
  /// [value] is the open item's value or null for none. A non-null [value],
  /// or [controlled] set to true, puts the open item under parent control:
  /// the parent must update [value] from [onValueChange], and may ignore a
  /// proposed open or close to reject it. Otherwise [defaultValue] (default
  /// null) seeds internal state. [side] defaults to bottom and [align] to
  /// center (React `placement="bottom"`); each root may override them.
  /// [openDelay] defaults to 200ms and [closeDelay] to 100ms. [size] defaults
  /// to [SeedMenuSize.medium].
  const SeedNavigationMenu({
    super.key,
    required this.child,
    this.value,
    this.defaultValue,
    this.controlled = false,
    this.onValueChange,
    this.side = SeedOverlaySide.bottom,
    this.align = SeedOverlayAlign.center,
    this.openDelay,
    this.closeDelay,
    this.size = SeedMenuSize.medium,
  });

  /// Subtree containing [SeedNavigationMenuRoot]s.
  final Widget child;

  /// Value of the open [SeedNavigationMenuRoot]; null means none is open.
  ///
  /// A non-null value is controlled. Use [controlled] to also control null.
  final String? value;

  /// Initially open value for uncontrolled use; null by default.
  final String? defaultValue;

  /// Keeps [value], including null, under parent control (Dart cannot tell an
  /// omitted `value` from an explicit null). False by default.
  final bool controlled;

  /// Reports the proposed open value, or null when the open flyout closes.
  final ValueChanged<String?>? onValueChange;

  /// Default flyout side for every root (React `placement` side), bottom.
  final SeedOverlaySide side;

  /// Default cross-axis alignment for every root (React `placement`
  /// alignment), center.
  final SeedOverlayAlign align;

  /// Hover open delay; null uses 200ms. Skipped while another flyout or
  /// grouped tooltip is open.
  final Duration? openDelay;

  /// Hover close delay after the pointer leaves; null uses 100ms.
  final Duration? closeDelay;

  /// Menu size of the flyout surfaces and items (React `size` variant of the
  /// `menu` recipe); medium by default.
  final SeedMenuSize size;

  @override
  State<SeedNavigationMenu> createState() => _SeedNavigationMenuState();
}

class _SeedNavigationMenuState extends State<SeedNavigationMenu> {
  late String? _uncontrolled = widget.defaultValue;

  bool get _isControlled => widget.controlled || widget.value != null;
  String? get _value => _isControlled ? widget.value : _uncontrolled;

  void _request(String? next) {
    if (!mounted || next == _value) return;
    widget.onValueChange?.call(next);
    if (!_isControlled) setState(() => _uncontrolled = next);
  }

  @override
  Widget build(BuildContext context) => SeedTooltipDelayGroup(
    openDelay: widget.openDelay ?? const Duration(milliseconds: 200),
    closeDelay: widget.closeDelay ?? const Duration(milliseconds: 100),
    // floating-ui's NextFloatingDelayGroup uses timeoutMs 0: only an open
    // member skips the delay, not a recently closed one.
    skipDelay: Duration.zero,
    child: _SeedNavigationMenuScope(
      state: this,
      value: _value,
      side: widget.side,
      align: widget.align,
      size: widget.size,
      child: widget.child,
    ),
  );
}

class _SeedNavigationMenuScope extends InheritedWidget {
  const _SeedNavigationMenuScope({
    required this.state,
    required this.value,
    required this.side,
    required this.align,
    required this.size,
    required super.child,
  });

  final _SeedNavigationMenuState state;
  final String? value;
  final SeedOverlaySide side;
  final SeedOverlayAlign align;
  final SeedMenuSize size;

  static _SeedNavigationMenuScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_SeedNavigationMenuScope>();
    assert(
      scope != null,
      'SeedNavigationMenuRoot must be placed inside a SeedNavigationMenu.',
    );
    return scope!;
  }

  SeedMenuSize resolvedSize(BuildContext context) =>
      size == SeedMenuSize.responsive
      ? (MediaQuery.sizeOf(context).width >= 1280
            ? SeedMenuSize.small
            : SeedMenuSize.medium)
      : size;

  @override
  bool updateShouldNotify(_SeedNavigationMenuScope oldWidget) =>
      state != oldWidget.state ||
      value != oldWidget.value ||
      side != oldWidget.side ||
      align != oldWidget.align ||
      size != oldWidget.size;
}

enum _OpenReason { hover, click, keyboard }

/// One disclosure flyout — a [trigger] and its [content] — inside a
/// [SeedNavigationMenu] (React `NavigationMenu.Root`).
class SeedNavigationMenuRoot extends StatefulWidget {
  /// Creates a flyout identified by [value], unique within its provider.
  ///
  /// [trigger] usually is a [SeedNavigationMenuTrigger]; [content] usually is
  /// a [SeedNavigationMenuContent]. [disabled] (default false) prevents
  /// opening. [side]/[align] override the provider's placement. [gutter]
  /// (default 8) separates trigger and flyout; [overflowPadding] (default 8)
  /// keeps the flyout that far inside the viewport's safe area.
  const SeedNavigationMenuRoot({
    super.key,
    required this.value,
    required this.trigger,
    required this.content,
    this.disabled = false,
    this.side,
    this.align,
    this.gutter = 8,
    this.overflowPadding = 8,
  });

  /// Identity of this flyout in [SeedNavigationMenu.value].
  final String value;

  /// Anchor widget, normally a [SeedNavigationMenuTrigger].
  final Widget trigger;

  /// Flyout body, normally a [SeedNavigationMenuContent].
  final Widget content;

  /// Whether the flyout refuses to open and its trigger is disabled.
  final bool disabled;

  /// Side override; null uses [SeedNavigationMenu.side].
  final SeedOverlaySide? side;

  /// Alignment override; null uses [SeedNavigationMenu.align].
  final SeedOverlayAlign? align;

  /// Distance between trigger and flyout in logical pixels (React `gutter`).
  final double gutter;

  /// Minimum distance from the viewport edge, added to the safe-area inset
  /// on each side (React `overflowPadding`).
  final double overflowPadding;

  @override
  State<SeedNavigationMenuRoot> createState() => _SeedNavigationMenuRootState();
}

class _SeedNavigationMenuRootState extends State<SeedNavigationMenuRoot> {
  final FocusNode _triggerGuard = FocusNode(
    debugLabel: 'SeedNavigationMenu trigger',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final FocusNode _contentGuard = FocusNode(
    debugLabel: 'SeedNavigationMenu content',
    canRequestFocus: false,
    skipTraversal: true,
  );
  late _SeedNavigationMenuScope _scope;
  SeedTooltipDelayGroupLink? _link;
  Timer? _openTimer, _closeTimer;
  _OpenReason _reason = _OpenReason.click;
  // Focus management only for keyboard activation, like React's
  // `focusManaged`; kept through the close so focus can return.
  bool _focusManaged = false;
  bool _pendingFocus = false;
  bool _instant = false;
  bool _openInstant = false;
  bool _closeInstant = false;
  bool _wasOpen = false;
  bool _keyHandlerAdded = false;

  bool get _isOpen => _scope.value == widget.value;
  bool get _enabled => !widget.disabled;

  Duration get _openDelay =>
      _link?.openDelay ?? const Duration(milliseconds: 200);
  Duration get _closeDelay =>
      _link?.closeDelay ?? const Duration(milliseconds: 100);

  bool get _anotherOpen =>
      (_scope.value != null && _scope.value != widget.value) ||
      (_link?.hasOpenMember ?? false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previousLink = _link;
    _scope = _SeedNavigationMenuScope.of(context);
    _link = SeedTooltipDelayGroupLink.maybeOf(context);
    if (previousLink != _link) previousLink?.close(this);
    _syncOpen();
  }

  @override
  void didUpdateWidget(SeedNavigationMenuRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disabled && !oldWidget.disabled) _cancelTimers();
    _syncOpen();
  }

  void _syncOpen() {
    final open = _isOpen;
    if (open == _wasOpen) return;
    _wasOpen = open;
    _cancelTimers();
    if (open) {
      // A parent can reopen the controlled value without an activation. Do
      // not reuse focus management from a previous keyboard-opened flyout.
      if (!_pendingFocus) _focusManaged = false;
      _instant = _openInstant;
      _openInstant = false;
      _setKeyHandler(true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isOpen) _link?.open(this, _closeFromGroup);
      });
    } else {
      _pendingFocus = false;
      // A sibling took over: swap without the exit animation, like React's
      // delay-group instant phase.
      _instant = _closeInstant || _scope.value != null;
      _closeInstant = false;
      _setKeyHandler(false);
      _link?.close(this);
    }
  }

  void _setKeyHandler(bool add) {
    if (add == _keyHandlerAdded) return;
    _keyHandlerAdded = add;
    add
        ? HardwareKeyboard.instance.addHandler(_handleKey)
        : HardwareKeyboard.instance.removeHandler(_handleKey);
  }

  // React's useDismiss listens for Escape on the document. Focus inside the
  // trigger or flyout is handled by the overlay's own shortcuts instead.
  bool _handleKey(KeyEvent event) {
    if (!mounted ||
        !_isOpen ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        _triggerGuard.hasFocus ||
        _contentGuard.hasFocus) {
      return false;
    }
    _requestClose();
    return true;
  }

  void _closeFromGroup() {
    if (!mounted || !_isOpen) return;
    _closeInstant = true;
    _requestClose();
  }

  void _cancelTimers() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _openTimer = null;
    _closeTimer = null;
  }

  void _requestOpen(_OpenReason reason) {
    _cancelTimers();
    if (!_enabled) return;
    _reason = reason;
    _focusManaged = reason == _OpenReason.keyboard;
    _pendingFocus = _focusManaged;
    if (_isOpen) {
      // Already open (e.g. hover, then Enter): only the focus policy changes.
      if (_pendingFocus) setState(() {});
      return;
    }
    _openInstant = _anotherOpen;
    _scope.state._request(widget.value);
  }

  void _requestClose() {
    _cancelTimers();
    if (_isOpen) _scope.state._request(null);
  }

  void _handleTriggerTap() {
    final keyboard = !seedLastInputWasPointer;
    if (_isOpen) {
      // floating-ui useClick keeps a hover-opened flyout open on click
      // (stickIfOpen); it then no longer closes when the pointer leaves.
      if (_reason == _OpenReason.hover) {
        _requestOpen(keyboard ? _OpenReason.keyboard : _OpenReason.click);
      } else {
        _requestClose();
      }
    } else {
      _requestOpen(keyboard ? _OpenReason.keyboard : _OpenReason.click);
    }
  }

  void _hoverEnter(PointerEnterEvent event) {
    if (event.kind != PointerDeviceKind.mouse || !_enabled) return;
    _closeTimer?.cancel();
    if (_isOpen) return;
    _openTimer?.cancel();
    if (_anotherOpen) {
      _requestOpen(_OpenReason.hover);
    } else {
      _openTimer = Timer(_openDelay, () {
        if (mounted) _requestOpen(_OpenReason.hover);
      });
    }
  }

  void _hoverExit(PointerExitEvent event) {
    if (event.kind != PointerDeviceKind.mouse) return;
    _openTimer?.cancel();
    if (!_isOpen || _reason != _OpenReason.hover) return;
    _closeTimer?.cancel();
    _closeTimer = Timer(_closeDelay, () {
      if (mounted && _reason == _OpenReason.hover) _requestClose();
    });
  }

  void _contentEnter(PointerEnterEvent event) {
    if (event.kind == PointerDeviceKind.mouse) _closeTimer?.cancel();
  }

  void _focusFirstItem() {
    _pendingFocus = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen) return;
      for (final node in _contentGuard.descendants) {
        if (node.canRequestFocus && node.context != null) {
          node.requestFocus();
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _cancelTimers();
    _setKeyHandler(false);
    _link?.close(this);
    _triggerGuard.dispose();
    _contentGuard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final open = _isOpen;
    final side = widget.side ?? _scope.side;
    final vertical =
        side == SeedOverlaySide.top || side == SeedOverlaySide.bottom;
    return _SeedNavigationMenuRootScope(
      state: this,
      open: open,
      disabled: widget.disabled,
      child: SeedAnchoredOverlay(
        open: open,
        side: side,
        align: widget.align ?? _scope.align,
        gap: widget.gutter,
        overflowPadding: widget.overflowPadding,
        // React size() before flip(): a vertical flyout shrinks to its side
        // until less than 200px remains, then flips.
        fitMinExtent: vertical ? _kMinAvailableHeight : null,
        autoFocus: _focusManaged,
        restoreFocus: _focusManaged,
        // React enables FloatingFocusManager, the source of focus-out
        // dismissal, only for keyboard-opened flyouts (`focusManaged`).
        // Hover and pointer flyouts close on leave, outside press, Escape
        // or selection instead.
        closeOnFocusOut: _focusManaged,
        skipAnimation: _instant,
        enterScale: 0.95,
        exitScale: 0.95,
        enterCurve: SeedCurves.enter,
        exitCurve: SeedCurves.exit,
        scaleFromAnchor: true,
        enterDuration: SeedDuration.d3,
        exitDuration: SeedDuration.d2,
        onOpenChange: (next, reason) {
          if (!next) _requestClose();
        },
        triggerBuilder: (context, _, _) => widget.trigger,
        overlayBuilder: (context) {
          if (_pendingFocus) _focusFirstItem();
          return Focus(
            focusNode: _contentGuard,
            canRequestFocus: false,
            skipTraversal: true,
            child: MouseRegion(
              onEnter: _contentEnter,
              onExit: _hoverExit,
              child: widget.content,
            ),
          );
        },
      ),
    );
  }
}

class _SeedNavigationMenuRootScope extends InheritedWidget {
  const _SeedNavigationMenuRootScope({
    required this.state,
    required this.open,
    required this.disabled,
    required super.child,
  });

  final _SeedNavigationMenuRootState state;
  final bool open, disabled;

  static _SeedNavigationMenuRootScope of(BuildContext context, String name) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_SeedNavigationMenuRootScope>();
    assert(
      scope != null,
      '$name must be placed inside a SeedNavigationMenuRoot.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(_SeedNavigationMenuRootScope oldWidget) =>
      state != oldWidget.state ||
      open != oldWidget.open ||
      disabled != oldWidget.disabled;
}

/// The button that discloses its [SeedNavigationMenuRoot]'s flyout (React
/// `NavigationMenu.Trigger`).
///
/// It exposes the expanded state, opens on mouse hover after the provider's
/// delay, and toggles on tap, click, Enter or Space. Like React's unstyled
/// trigger it paints nothing itself: supply [child] or [builder].
class SeedNavigationMenuTrigger extends StatelessWidget {
  /// Creates a trigger showing [child], or the result of [builder].
  ///
  /// [builder] receives whether the flyout is open and whether the trigger is
  /// pressed or hovered. [semanticsLabel] replaces the child's semantics.
  /// [selected] optionally marks the trigger as current. The focus ring is
  /// drawn outside by default ([focusRingInside] false) with a 4px radius.
  const SeedNavigationMenuTrigger({
    super.key,
    this.child,
    this.builder,
    this.semanticsLabel,
    this.selected,
    this.focusRingInside = false,
    this.focusBorderRadius = const BorderRadius.all(Radius.circular(4)),
  }) : assert(child != null || builder != null);

  /// Static trigger content.
  final Widget? child;

  /// Builds content from the open and engaged (pressed or hovered) states.
  final Widget Function(BuildContext context, bool open, bool engaged)? builder;

  /// Accessible name replacing the content's own semantics.
  final String? semanticsLabel;

  /// Optional selected/current state for assistive technologies.
  final bool? selected;

  /// Whether the keyboard focus ring is drawn inside the bounds.
  final bool focusRingInside;

  /// Corner radius of the keyboard focus ring.
  final BorderRadius focusBorderRadius;

  @override
  Widget build(BuildContext context) {
    final root = _SeedNavigationMenuRootScope.of(
      context,
      'SeedNavigationMenuTrigger',
    );
    final state = root.state;
    return MouseRegion(
      onEnter: state._hoverEnter,
      onExit: state._hoverExit,
      child: Focus(
        focusNode: state._triggerGuard,
        canRequestFocus: false,
        skipTraversal: true,
        child: SeedPressable(
          enabled: !root.disabled,
          enableScale: false,
          expanded: root.open,
          selected: selected,
          semanticsLabel: semanticsLabel,
          focusRingInside: focusRingInside,
          focusBorderRadius: focusBorderRadius,
          onTap: state._handleTriggerTap,
          builder: (context, engaged) =>
              builder?.call(context, root.open, engaged) ?? child!,
        ),
      ),
    );
  }
}

/// The flyout surface of a [SeedNavigationMenuRoot] (React
/// `NavigationMenu.Positioner` + `Content` + `ScrollArea`).
///
/// Uses the `menu` recipe: `bg.layerFloating`, radius r5, shadow s3, 8px
/// vertical padding and gap, width 240 (medium) or 200 (small), and scrolls
/// beyond [maxHeight] or the height available in the viewport.
/// Consecutive [SeedNavigationMenuGroup]s are separated by a divider.
class SeedNavigationMenuContent extends StatelessWidget {
  /// Creates a flyout listing [children], usually groups or items.
  ///
  /// [maxHeight] defaults to 480 (`menu` maxHeight). [semanticsLabel]
  /// optionally names the region, as React's `aria-labelledby` trigger.
  const SeedNavigationMenuContent({
    super.key,
    required this.children,
    this.maxHeight = 480,
    this.semanticsLabel,
  });

  /// Groups and items shown in order.
  final List<Widget> children;

  /// Cap on the scrolling height, 480 by default.
  final double maxHeight;

  /// Optional accessible name of the flyout.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final size = _SeedNavigationMenuScope.of(context).resolvedSize(context);
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(const SizedBox(height: SeedDimension.x2));
        if (children[i] is SeedNavigationMenuGroup &&
            children[i - 1] is SeedNavigationMenuGroup) {
          rows
            ..add(
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: SeedDimension.x4),
                child: SeedDivider(),
              ),
            )
            ..add(const SizedBox(height: SeedDimension.x2));
        }
      }
      rows.add(children[i]);
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticsLabel,
      child: Container(
        width: size == SeedMenuSize.small ? 200 : 240,
        constraints: BoxConstraints(maxHeight: maxHeight),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.bg.layerFloating,
          borderRadius: SeedBorderRadius.r5,
          boxShadow: context.seedShadows.s3,
        ),
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.symmetric(vertical: SeedDimension.x2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ),
    );
  }
}

/// A labelled group of items (React `NavigationMenu.Group` with its
/// optional `GroupLabel`).
class SeedNavigationMenuGroup extends StatelessWidget {
  /// Creates a group of [children] under an optional [label].
  const SeedNavigationMenuGroup({
    super.key,
    this.label,
    required this.children,
  });

  /// Optional group heading, also the group's accessible name.
  final String? label;

  /// Items in this group.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final small =
        _SeedNavigationMenuScope.of(context).resolvedSize(context) ==
        SeedMenuSize.small;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            ExcludeSemantics(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SeedDimension.x4,
                  vertical: small ? SeedDimension.x2 : SeedDimension.x2_5,
                ),
                child: Text(
                  label!,
                  style: (small ? typography.t3Regular : typography.t4Medium)
                      .copyWith(color: colors.fg.neutralSubtle),
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// A destination in a flyout (React `NavigationMenu.Item` with `ItemBody`,
/// `ItemLabel`, `ItemDescription` and prefix/suffix icons).
///
/// Selecting it runs [onTap] and closes the flyout. It stays enabled without
/// [onTap]; only [disabled] disables it.
class SeedNavigationMenuItem extends StatelessWidget {
  /// Creates an item labelled [label].
  ///
  /// [current] (default false) marks the current page (React
  /// `aria-current="page"`, exposed as selected). [disabled] defaults to
  /// false. [description], [prefixIcon] and [suffixIcon] are optional.
  const SeedNavigationMenuItem({
    super.key,
    required this.label,
    this.description,
    this.prefixIcon,
    this.suffixIcon,
    this.current = false,
    this.disabled = false,
    this.onTap,
  });

  /// Visible and accessible item text.
  final String label;

  /// Optional secondary line.
  final String? description;

  /// Optional leading icon (22px medium, 18px small).
  final Widget? prefixIcon;

  /// Optional trailing widget such as an icon or badge (18px/16px icons).
  final Widget? suffixIcon;

  /// Whether this item is the current page.
  final bool current;

  /// Whether the item is disabled.
  final bool disabled;

  /// Invoked on selection, before the flyout closes.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final root = _SeedNavigationMenuRootScope.of(
      context,
      'SeedNavigationMenuItem',
    );
    final small =
        _SeedNavigationMenuScope.of(context).resolvedSize(context) ==
        SeedMenuSize.small;
    final foreground = disabled ? colors.fg.disabled : colors.fg.neutral;
    return SeedPressable(
      enabled: !disabled,
      enableScale: false,
      selected: current ? true : null,
      focusRingInside: true,
      focusBorderRadius: SeedBorderRadius.r3,
      onTap: () {
        onTap?.call();
        if (root.state.mounted) root.state._requestClose();
      },
      builder: (context, engaged) => Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: SeedDuration.d3,
              curve: SeedCurves.easing,
              margin: EdgeInsets.symmetric(
                horizontal: engaged && !disabled ? SeedDimension.x2 : 0,
              ),
              decoration: BoxDecoration(
                color: engaged && !disabled
                    ? colors.bg.transparentPressed
                    : colors.bg.transparent,
                borderRadius: SeedBorderRadius.r3,
              ),
            ),
          ),
          SeedContentScale(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SeedDimension.x4,
                vertical: small ? SeedDimension.x2_5 : SeedDimension.x3,
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        size: small ? 18 : 22,
                        color: foreground,
                      ),
                      child: prefixIcon!,
                    ),
                    SizedBox(
                      width: small ? SeedDimension.x2 : SeedDimension.x3,
                    ),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style:
                              (small
                                      ? typography.t4Regular
                                      : typography.t5Regular)
                                  .copyWith(color: foreground),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: SeedDimension.x0_5),
                          Text(
                            description!,
                            style:
                                (small
                                        ? typography.t2Regular
                                        : typography.t3Regular)
                                    .copyWith(
                                      color: disabled
                                          ? colors.fg.disabled
                                          : colors.fg.neutralSubtle,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    SizedBox(
                      width: small ? SeedDimension.x2 : SeedDimension.x3,
                    ),
                    IconTheme(
                      data: IconThemeData(
                        size: small ? 16 : 18,
                        color: foreground,
                      ),
                      child: suffixIcon!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
