import 'package:material_ui/material_ui.dart';

import '../../foundations/feedback/seed_scale_feedback.dart';

/// The official `useCollapsibleContext` value: the open state of the nearest
/// [SeedCollapsible] and the means to change it.
class SeedCollapsibleContextValue {
  const SeedCollapsibleContextValue._(this.open, this.disabled, this._setOpen);

  /// Whether the content is shown.
  final bool open;

  /// Whether the trigger ignores input.
  final bool disabled;

  final ValueChanged<bool> _setOpen;

  /// Requests the given open state. A parent-controlled collapsible only
  /// reports the request through `onOpenChange`.
  void setOpen(bool open) => _setOpen(open);

  /// Requests the opposite of [open], as [SeedCollapsibleTrigger] does.
  void toggle() => _setOpen(!open);
}

class _SeedCollapsibleScope extends InheritedWidget {
  const _SeedCollapsibleScope({required this.value, required super.child});

  final SeedCollapsibleContextValue value;

  @override
  bool updateShouldNotify(_SeedCollapsibleScope oldWidget) =>
      value.open != oldWidget.value.open ||
      value.disabled != oldWidget.value.disabled;
}

/// The official headless `Collapsible.Root`: shows and hides a
/// [SeedCollapsibleContent] from a [SeedCollapsibleTrigger] anywhere below it.
///
/// Like the official primitive it has no appearance of its own; the trigger
/// and content take whatever widgets you give them.
///
/// ```dart
/// SeedCollapsible(
///   child: Column(children: [
///     SeedCollapsibleTrigger(child: Text('More')),
///     SeedCollapsibleContent(child: Text('Details')),
///   ]),
/// )
/// ```
class SeedCollapsible extends StatefulWidget {
  /// Creates a collapsible. [open] is parent-controlled when non-null;
  /// otherwise [defaultOpen] (false) seeds internal state. [onOpenChange]
  /// receives each requested state; [disabled] (false) blocks the trigger.
  const SeedCollapsible({
    super.key,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.disabled = false,
    required this.child,
  });

  /// Parent-controlled open state, or null when managed here.
  final bool? open;

  /// Initial open state when [open] is null.
  final bool defaultOpen;

  /// Receives the next open state when a change is requested.
  final ValueChanged<bool>? onOpenChange;

  /// Whether the trigger ignores input. The content keeps its state.
  final bool disabled;

  /// Subtree containing the trigger and the content.
  final Widget child;

  /// The nearest collapsible, or null outside one.
  static SeedCollapsibleContextValue? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SeedCollapsibleScope>()
      ?.value;

  /// The nearest collapsible. Throws outside one, like the official strict
  /// hook.
  static SeedCollapsibleContextValue of(BuildContext context) {
    final value = maybeOf(context);
    assert(
      value != null,
      'SeedCollapsible.of() was called outside a SeedCollapsible.',
    );
    return value!;
  }

  @override
  State<SeedCollapsible> createState() => _SeedCollapsibleState();
}

class _SeedCollapsibleState extends State<SeedCollapsible> {
  late bool _uncontrolled = widget.defaultOpen;

  bool get _open => widget.open ?? _uncontrolled;

  void _setOpen(bool next) {
    if (next == _open) return;
    if (widget.open == null) setState(() => _uncontrolled = next);
    widget.onOpenChange?.call(next);
  }

  @override
  Widget build(BuildContext context) => _SeedCollapsibleScope(
    value: SeedCollapsibleContextValue._(_open, widget.disabled, _setOpen),
    child: widget.child,
  );
}

/// The official `Collapsible.Trigger`: a button that toggles the nearest
/// [SeedCollapsible] and reports its expanded state to assistive technology.
///
/// It responds to taps, Enter and Space, and shows a focus ring for keyboard
/// focus. It does nothing while the collapsible is disabled.
class SeedCollapsibleTrigger extends StatelessWidget {
  /// Creates a trigger around [child].
  const SeedCollapsibleTrigger({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.focusNode,
  });

  /// The trigger's content. Read [SeedCollapsible.of] to vary it with the
  /// open state, for example to turn a chevron.
  final Widget child;

  /// Accessible name when [child] has no text.
  final String? semanticsLabel;

  /// Optional caller-owned focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final collapsible = SeedCollapsible.of(context);
    return SeedPressable(
      onTap: collapsible.toggle,
      enabled: !collapsible.disabled,
      enableScale: false,
      expanded: collapsible.open,
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      child: child,
    );
  }
}

/// The official `Collapsible.Content`: grows open and shrinks closed with the
/// nearest [SeedCollapsible].
///
/// Closed content stays mounted, like the official `hidden` content, so text
/// fields and scroll positions inside it survive. It is left out of layout,
/// focus traversal and the semantics tree while closed. With reduced motion
/// it opens and closes at once.
class SeedCollapsibleContent extends StatefulWidget {
  /// Creates the collapsible content.
  ///
  /// The official primitive leaves the transition to each recipe; this
  /// defaults to the 200ms ease-in-out of the official side navigation, its
  /// styled use. [duration] and [curve] change it.
  const SeedCollapsibleContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  /// The content shown while open.
  final Widget child;

  /// Length of the open and close transition.
  final Duration duration;

  /// Easing of the height and opacity transition.
  final Curve curve;

  @override
  State<SeedCollapsibleContent> createState() => _SeedCollapsibleContentState();
}

class _SeedCollapsibleContentState extends State<SeedCollapsibleContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late CurvedAnimation _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  bool? _open;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final open = SeedCollapsible.of(context).open;
    if (open == _open) return;
    final first = _open == null;
    _open = open;
    if (first || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = open ? 1 : 0;
    } else if (open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(SeedCollapsibleContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.curve != oldWidget.curve) {
      _animation.dispose();
      _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final hidden = _controller.isDismissed;
      return Visibility(
        visible: !hidden,
        maintainState: true,
        child: ClipRect(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: _animation.value,
            child: Opacity(opacity: _animation.value, child: child),
          ),
        ),
      );
    },
    child: widget.child,
  );
}
