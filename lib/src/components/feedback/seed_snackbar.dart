import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/motion/seed_motion.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Visual emphasis of a snackbar message.
enum SeedSnackbarVariant {
  /// Informational message, without a default leading icon.
  neutral,

  /// Success message, with a check icon by default.
  positive,

  /// Error message, with an error icon by default.
  critical,
}

/// Standalone Snackbar content styled according to SEED Design.
///
/// Wrap with [SeedSnackbarProvider] for queued/controlled presentation, or
/// use [showSeedSnackbar] for Flutter's [ScaffoldMessenger] presentation.
class SeedSnackbar extends StatelessWidget {
  /// Text shown in the snackbar.
  final String message;

  /// Action text; renders an action only together with [onAction].
  final String? actionLabel;

  /// Called when the action is pressed; managed entries also dismiss after it.
  final VoidCallback? onAction;

  /// Optional leading widget; overrides the variant's built-in icon.
  final Widget? prefixIcon;

  /// Determines the default icon and message emphasis.
  final SeedSnackbarVariant variant;

  /// Creates snackbar content; the default [variant] is neutral.
  const SeedSnackbar({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.prefixIcon,
    this.variant = SeedSnackbarVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final prefixIcon =
        this.prefixIcon ??
        switch (variant) {
          SeedSnackbarVariant.neutral => null,
          SeedSnackbarVariant.positive => Icon(
            Icons.check_circle_rounded,
            color: colors.fg.positive,
          ),
          SeedSnackbarVariant.critical => Icon(
            Icons.error_rounded,
            color: colors.fg.critical,
          ),
        };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SeedDimension.x2_5,
        vertical: actionLabel != null && onAction != null
            ? 0
            : SeedDimension.x2_5,
      ),
      constraints: const BoxConstraints(minHeight: 44, maxWidth: 464),
      decoration: BoxDecoration(
        color: colors.bg.neutralSolid,
        borderRadius: SeedBorderRadius.r2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        size: 24,
                        color: colors.fg.onNeutralSolid,
                      ),
                      child: prefixIcon,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: typography.t4Regular.copyWith(
                        color: colors.fg.onNeutralSolid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            SeedPressable(
              semanticsLabel: actionLabel,
              onTap: () {
                final dismiss = _SeedSnackbarEntryScope.maybeOf(context);
                onAction!();
                dismiss?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Center(
                    child: Text(
                      actionLabel!,
                      style: typography.t4Bold.copyWith(color: colors.fg.brand),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows a SEED snackbar through the nearest [ScaffoldMessenger].
///
/// [context] supplies the messenger; [message] is required. An action is
/// interactive only when both [actionLabel] and [onAction] are present.
/// The [duration] defaults to four seconds. [persist] defaults to true
/// when an action is available, following Flutter's snackbar behavior.
/// [onVisible] runs when the scaffold reveals the snackbar, [prefixIcon]
/// overrides the [variant]'s icon, and [variant] defaults to neutral.
///
/// Returns Flutter's feature controller for dismissal and closed-state
/// observation. This helper uses [ScaffoldMessenger], independently of
/// [SeedSnackbarController] and [SeedSnackbarProvider].
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSeedSnackbar({
  required BuildContext context,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
  bool? persist,
  VoidCallback? onVisible,
  Widget? prefixIcon,
  SeedSnackbarVariant variant = SeedSnackbarVariant.neutral,
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  var actionInvoked = false;

  return scaffoldMessenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.all(SeedDimension.x2),
      padding: EdgeInsets.zero,
      duration: duration,
      persist: persist ?? (actionLabel != null && onAction != null),
      onVisible: onVisible,
      content: SeedSnackbar(
        message: message,
        actionLabel: actionLabel,
        prefixIcon: prefixIcon,
        variant: variant,
        onAction: onAction != null
            ? () {
                if (actionInvoked) return;
                actionInvoked = true;
                scaffoldMessenger.hideCurrentSnackBar(
                  reason: SnackBarClosedReason.action,
                );
                onAction();
              }
            : null,
      ),
    ),
  );
}

/// How an incoming snackbar relates to an already displayed entry.
enum SeedSnackbarStrategy {
  /// Show the next entry after the current one is removed.
  queued,

  /// Dismiss the current entry and display the incoming entry next.
  immediate,
}

class _SeedSnackbarEntry {
  _SeedSnackbarEntry(this.child, this.duration, this.removeDelay, this.onClose);
  final Widget child;
  final Duration duration, removeDelay;
  final VoidCallback? onClose;
}

/// Manages snackbar entries and their timers without [ScaffoldMessenger].
///
/// Attach it to a [SeedSnackbarProvider]. The provider may create and own a
/// controller if none is provided; externally created controllers must be
/// disposed by their owner after use.
class SeedSnackbarController extends ChangeNotifier {
  /// Creates a controller with immediate replacement and interaction pausing.
  ///
  /// [strategy] defaults to [SeedSnackbarStrategy.immediate], matching the
  /// React snackbar adapter. [pauseOnInteraction] defaults to true.
  SeedSnackbarController({
    this.strategy = SeedSnackbarStrategy.immediate,
    this.pauseOnInteraction = true,
  });
  /// Default strategy for new entries; individual [show] calls may override it.
  SeedSnackbarStrategy strategy;

  /// Whether hover, press or focus suspends the current entry's timeout.
  ///
  /// Resuming from interaction starts a fresh full-duration timeout.
  bool pauseOnInteraction;
  bool _disposed = false;
  bool _attached = false;
  final List<_SeedSnackbarEntry> _queue = [];
  final Map<Object, double> _avoidedHeights = {};
  Timer? _timer, _removeTimer;
  // The current entry is exiting: hidden, but not yet removed from the queue.
  bool _dismissing = false;
  final Stopwatch _elapsed = Stopwatch();
  Duration _remaining = Duration.zero;
  bool _hover = false, _pressed = false, _focused = false;
  bool get _paused => _hover || _pressed || _focused;
  double get _bottomOffset => _avoidedHeights.values.fold(0, math.max);
  _SeedSnackbarEntry? get _current => _dismissing ? null : _queue.firstOrNull;

  /// Returns a dismiss callback for this entry, including when it is queued.
  ///
  /// [removeDelay] keeps a dismissed snackbar alive for its exit transition.
  /// [onClose] runs once it has been removed, as in React.
  /// [child] is the displayed content, [duration] defaults to four seconds,
  /// and [strategy] overrides this controller's strategy for this entry.
  /// The callback is safe to call while the entry is waiting in the queue.
  VoidCallback show({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    Duration removeDelay = const Duration(milliseconds: 200),
    SeedSnackbarStrategy? strategy,
    VoidCallback? onClose,
  }) {
    final entry = _SeedSnackbarEntry(child, duration, removeDelay, onClose);
    if ((strategy ?? this.strategy) == SeedSnackbarStrategy.immediate &&
        _queue.isNotEmpty) {
      // React's immediate PUSH sets `queue: [option]`: everything waiting,
      // including an earlier immediate entry, is replaced. The current
      // snackbar exits first; this one enters when it is removed.
      final replaced = _queue.sublist(1);
      _queue
        ..removeRange(1, _queue.length)
        ..add(entry);
      for (final dropped in replaced) {
        dropped.onClose?.call();
      }
      _dismiss(_queue.first);
    } else {
      _queue.add(entry);
      if (_queue.length == 1) _start();
    }
    notifyListeners();
    return () => _dismiss(entry);
  }

  /// Begins dismissal of the currently visible snackbar, if any.
  void close() {
    if (_current != null) _dismiss(_current!);
  }

  void _dismiss(_SeedSnackbarEntry entry) {
    final index = _queue.indexOf(entry);
    if (index < 0) return;
    if (index > 0) {
      _queue.removeAt(index);
      entry.onClose?.call();
      notifyListeners();
      return;
    }
    if (_dismissing) return;
    _timer?.cancel();
    _elapsed.stop();
    _dismissing = true;
    notifyListeners();
    _removeTimer = Timer(entry.removeDelay, () {
      _dismissing = false;
      _queue.remove(entry);
      entry.onClose?.call();
      _start();
      notifyListeners();
    });
  }

  void _start() {
    _timer?.cancel();
    _elapsed
      ..reset()
      ..stop();
    _remaining = _current?.duration ?? Duration.zero;
    _resume();
  }

  void _resume() {
    if (!_attached ||
        _disposed ||
        _current == null ||
        (pauseOnInteraction && _paused)) {
      return;
    }
    _elapsed
      ..reset()
      ..start();
    _timer = Timer(_remaining, close);
  }

  void _attach() {
    _attached = true;
    _resume();
  }

  void _detach() {
    _attached = false;
    _timer?.cancel();
    if (_elapsed.isRunning) {
      _elapsed.stop();
      _remaining -= _elapsed.elapsed;
    }
    _hover = false;
    _pressed = false;
    _focused = false;
  }

  void _interaction({bool? hover, bool? pressed, bool? focused}) {
    final wasPaused = _paused;
    _hover = hover ?? _hover;
    _pressed = pressed ?? _pressed;
    _focused = focused ?? _focused;
    if (!pauseOnInteraction || wasPaused == _paused) return;
    if (_paused) {
      _timer?.cancel();
      _elapsed.stop();
      // React useSnackbar.ts:98–101,119–137 changes active -> persist on
      // pointer/focus pause, then persist -> active on resume. The active
      // effect schedules a NEW visibleDuration timeout; it does not continue
      // the original timer's remainder. Keep detach/reattach accounting
      // independent from this interaction-driven restart.
      _remaining = _current?.duration ?? Duration.zero;
    } else {
      _resume();
    }
  }

  void _avoid(Object key, double? height) {
    if (_disposed) return;
    if (height == null) {
      _avoidedHeights.remove(key);
    } else {
      _avoidedHeights[key] = height;
    }
    notifyListeners();
  }

  /// Cancels outstanding timers and releases notifier listeners.
  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _removeTimer?.cancel();
    super.dispose();
  }
}

class _SeedSnackbarScope extends InheritedWidget {
  const _SeedSnackbarScope({required this.controller, required super.child});
  final SeedSnackbarController controller;
  @override
  bool updateShouldNotify(_SeedSnackbarScope oldWidget) =>
      controller != oldWidget.controller;
}

class _SeedSnackbarEntryScope extends InheritedWidget {
  const _SeedSnackbarEntryScope({required this.dismiss, required super.child});
  final VoidCallback dismiss;
  static VoidCallback? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SeedSnackbarEntryScope>()
      ?.dismiss;
  @override
  bool updateShouldNotify(_SeedSnackbarEntryScope oldWidget) =>
      dismiss != oldWidget.dismiss;
}

/// Places a [SeedSnackbarController] in the widget tree and renders its entries.
///
/// Descendants retrieve the controller through [of] or [maybeOf].
/// If no [controller] is supplied, the provider owns and disposes one.
class SeedSnackbarProvider extends StatefulWidget {
  /// Wraps [child] with snackbar presentation and a controller scope.
  ///
  /// [strategy] and [pauseOnInteraction] configure the internally created
  /// controller; a supplied [controller] retains its own configuration.
  const SeedSnackbarProvider({
    super.key,
    required this.child,
    this.controller,
    this.strategy = SeedSnackbarStrategy.immediate,
    this.pauseOnInteraction = true,
  });
  /// Application subtree that may display snackbars.
  final Widget child;

  /// Optional externally owned snackbar controller.
  final SeedSnackbarController? controller;

  /// Default entry strategy when the provider creates its controller.
  final SeedSnackbarStrategy strategy;

  /// Whether interaction pauses timeouts on a provider-owned controller.
  final bool pauseOnInteraction;

  /// Looks up the nearest provider; requires one above [context].
  static SeedSnackbarController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SeedSnackbarScope>()!
      .controller;
  /// Returns the nearest controller, or null outside a provider.
  static SeedSnackbarController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SeedSnackbarScope>()
      ?.controller;
  /// Creates state that attaches and detaches the snackbar controller.
  @override
  State<SeedSnackbarProvider> createState() => _SeedSnackbarProviderState();
}

class _SeedSnackbarProviderState extends State<SeedSnackbarProvider> {
  late SeedSnackbarController _controller =
      widget.controller ??
      SeedSnackbarController(
        strategy: widget.strategy,
        pauseOnInteraction: widget.pauseOnInteraction,
      );
  @override
  void initState() {
    super.initState();
    _controller._attach();
  }

  @override
  void didUpdateWidget(SeedSnackbarProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller._detach();
      if (oldWidget.controller == null) _controller.dispose();
      _controller =
          widget.controller ??
          SeedSnackbarController(
            strategy: widget.strategy,
            pauseOnInteraction: widget.pauseOnInteraction,
          );
      _controller._attach();
    }
    if (widget.controller == null) {
      _controller.strategy = widget.strategy;
      _controller.pauseOnInteraction = widget.pauseOnInteraction;
    }
  }

  @override
  void dispose() {
    _controller._detach();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SeedSnackbarScope(
    controller: _controller,
    child: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final entry = _controller._current;
        final reduce = MediaQuery.disableAnimationsOf(context);
        return Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            AnimatedPositioned(
              duration: reduce ? Duration.zero : SeedDuration.d4,
              curve: SeedCurves.easing,
              left: 8,
              right: 8,
              bottom:
                  math.max(
                    MediaQuery.viewInsetsOf(context).bottom,
                    MediaQuery.paddingOf(context).bottom,
                  ) +
                  8 +
                  _controller._bottomOffset,
              child: Focus(
                canRequestFocus: false,
                onFocusChange: (v) => _controller._interaction(focused: v),
                child: MouseRegion(
                  onEnter: (_) => _controller._interaction(hover: true),
                  onExit: (_) => _controller._interaction(hover: false),
                  child: Listener(
                    onPointerDown: (_) =>
                        _controller._interaction(pressed: true),
                    onPointerUp: (_) =>
                        _controller._interaction(pressed: false),
                    onPointerCancel: (_) =>
                        _controller._interaction(pressed: false),
                    child: AnimatedSwitcher(
                      duration: reduce ? Duration.zero : SeedDuration.d3,
                      reverseDuration: reduce ? Duration.zero : SeedDuration.d2,
                      switchInCurve: SeedCurves.enter,
                      switchOutCurve: SeedCurves.exit,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.8,
                            end: 1.0,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: entry == null
                          ? const SizedBox.shrink()
                          : Semantics(
                              key: ObjectKey(entry),
                              liveRegion: true,
                              child: Center(
                                child: _SeedSnackbarEntryScope(
                                  dismiss: () => _controller._dismiss(entry),
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: entry.child,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// Reserves the measured height of a floating action region above the snackbar.
///
/// Must be inside [SeedSnackbarProvider], which receives size-change and
/// disposal notifications so the snackbar can avoid covering [child].
class SeedSnackbarAvoidOverlap extends StatefulWidget {
  /// Watches the size of the floating [child].
  const SeedSnackbarAvoidOverlap({super.key, required this.child});

  /// Floating region whose height the provider should avoid.
  final Widget child;

  /// Creates state that registers and unregisters the measured height.
  @override
  State<SeedSnackbarAvoidOverlap> createState() =>
      _SeedSnackbarAvoidOverlapState();
}

class _SeedSnackbarAvoidOverlapState extends State<SeedSnackbarAvoidOverlap> {
  final Object _id = Object();
  SeedSnackbarController? _controller;
  double? _height;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = SeedSnackbarProvider.of(context);
  }

  void _measure() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final height = context.size?.height;
    if (height != _height) {
      _height = height;
      _controller?._avoid(_id, height);
    }
  });
  @override
  void dispose() {
    final controller = _controller;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller?._avoid(_id, null),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _measure();
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _measure();
        return false;
      },
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }
}
