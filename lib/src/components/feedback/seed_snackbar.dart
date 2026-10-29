import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/motion/seed_motion.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

enum SeedSnackbarVariant { neutral, positive, critical }

/// Standalone Snackbar component of SEED Design System.
class SeedSnackbar extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? prefixIcon;
  final SeedSnackbarVariant variant;

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

/// Shows a standard SEED Snackbar at the bottom of the screen.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSeedSnackbar({
  required BuildContext context,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
  Widget? prefixIcon,
  SeedSnackbarVariant variant = SeedSnackbarVariant.neutral,
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  return scaffoldMessenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.all(SeedDimension.x2),
      padding: EdgeInsets.zero,
      duration: duration,
      content: SeedSnackbar(
        message: message,
        actionLabel: actionLabel,
        prefixIcon: prefixIcon,
        variant: variant,
        onAction: onAction != null
            ? () {
                scaffoldMessenger.hideCurrentSnackBar();
                onAction();
              }
            : null,
      ),
    ),
  );
}

enum SeedSnackbarStrategy { queued, immediate }

class _SeedSnackbarEntry {
  _SeedSnackbarEntry(this.child, this.duration, this.onClose);
  final Widget child;
  final Duration duration;
  final VoidCallback? onClose;
}

/// Queue and timeout state independent of a page's ScaffoldMessenger.
class SeedSnackbarController extends ChangeNotifier {
  SeedSnackbarController({
    this.strategy = SeedSnackbarStrategy.immediate,
    this.pauseOnInteraction = true,
  });
  SeedSnackbarStrategy strategy;
  bool pauseOnInteraction;
  bool _disposed = false;
  bool _attached = false;
  final List<_SeedSnackbarEntry> _queue = [];
  final Map<Object, double> _avoidedHeights = {};
  Timer? _timer;
  final Stopwatch _elapsed = Stopwatch();
  Duration _remaining = Duration.zero;
  bool _hover = false, _pressed = false, _focused = false;
  bool get _paused => _hover || _pressed || _focused;
  double get _bottomOffset => _avoidedHeights.values.fold(0, math.max);
  _SeedSnackbarEntry? get _current => _queue.firstOrNull;

  /// Returns a dismiss callback for this entry, including when it is queued.
  VoidCallback show({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    SeedSnackbarStrategy? strategy,
    VoidCallback? onClose,
  }) {
    final entry = _SeedSnackbarEntry(child, duration, onClose);
    if ((strategy ?? this.strategy) == SeedSnackbarStrategy.immediate &&
        _queue.isNotEmpty) {
      _timer?.cancel();
      final old = _queue.removeAt(0);
      old.onClose?.call();
      _queue.insert(0, entry);
      _start();
    } else {
      _queue.add(entry);
      if (_queue.length == 1) _start();
    }
    notifyListeners();
    return () => _dismiss(entry);
  }

  void close() {
    if (_current != null) _dismiss(_current!);
  }

  void _dismiss(_SeedSnackbarEntry entry) {
    final index = _queue.indexOf(entry);
    if (index < 0) return;
    _queue.removeAt(index);
    if (index == 0) {
      _timer?.cancel();
      _start();
    }
    entry.onClose?.call();
    notifyListeners();
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

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
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

class SeedSnackbarProvider extends StatefulWidget {
  const SeedSnackbarProvider({
    super.key,
    required this.child,
    this.controller,
    this.strategy = SeedSnackbarStrategy.immediate,
    this.pauseOnInteraction = true,
  });
  final Widget child;
  final SeedSnackbarController? controller;
  final SeedSnackbarStrategy strategy;
  final bool pauseOnInteraction;
  static SeedSnackbarController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SeedSnackbarScope>()!
      .controller;
  static SeedSnackbarController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SeedSnackbarScope>()
      ?.controller;
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
class SeedSnackbarAvoidOverlap extends StatefulWidget {
  const SeedSnackbarAvoidOverlap({super.key, required this.child});
  final Widget child;
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
