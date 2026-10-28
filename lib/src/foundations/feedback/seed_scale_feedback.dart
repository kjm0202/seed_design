import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart'
    show GestureBinding, PointerDeviceKind, PointerDownEvent, PointerEvent;

import '../motion/seed_motion.dart';
import '../colors/seed_color_scheme.dart';

/// Calculates the target scale for SEED scale feedback.
///
/// Formula from SEED Design System:
/// ```
/// basis = max(height, width / 4, 24)
/// scale = (basis - 2) / basis
/// ```
class SeedScaleCalculator {
  const SeedScaleCalculator._();

  static double calculateScale({
    required double width,
    required double height,
    bool disableAnimations = false,
  }) {
    if (disableAnimations) return 1.0;
    final double basis = math.max(math.max(height, width / 4.0), 24.0);
    return (basis - 2.0) / basis;
  }
}

/// Actual press and hover are separate so hover changes colors without scaling.
class SeedInteractionState extends InheritedWidget {
  const SeedInteractionState({
    super.key,
    required this.pressed,
    required this.hovered,
    required this.focused,
    required super.child,
  });
  final bool pressed, hovered, focused;
  static SeedInteractionState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedInteractionState>();
  @override
  bool updateShouldNotify(SeedInteractionState oldWidget) =>
      pressed != oldWidget.pressed ||
      hovered != oldWidget.hovered ||
      focused != oldWidget.focused;
}

/// Scales just the content of a SeedPressable, leaving its surface fixed.
class SeedContentScale extends StatefulWidget {
  const SeedContentScale({super.key, required this.child, this.pressed});
  final Widget child;
  final bool? pressed;
  @override
  State<SeedContentScale> createState() => _SeedContentScaleState();
}

class _SeedContentScaleState extends State<SeedContentScale> {
  Size _size = Size.zero;
  @override
  Widget build(BuildContext context) => _SizeReporter(
    onSizeChanged: (size) {
      if (mounted && _size != size) setState(() => _size = size);
    },
    child: AnimatedScale(
      scale:
          (widget.pressed ?? SeedInteractionState.maybeOf(context)?.pressed) ==
              true
          ? SeedScaleCalculator.calculateScale(
              width: _size.width,
              height: _size.height,
              disableAnimations: MediaQuery.disableAnimationsOf(context),
            )
          : 1,
      duration: SeedDuration.pressedScale,
      curve: SeedCurves.pressedScale,
      child: widget.child,
    ),
  );
}

/// A widget that applies SEED Design System physical scale feedback when pressed.
///
/// Automatically measures the child dimensions and applies the standard SEED formula:
/// `basis = max(height, width / 4, 24)` and `scale = (basis - 2) / basis`.
class SeedPressable extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, bool isPressed)? builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool enableScale;
  final HitTestBehavior behavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticsLabel;
  final String? semanticsValue;
  final SemanticsRole? semanticsRole;
  final int? headingLevel;
  final bool semanticButton;
  final bool? checked;
  final bool? mixed;
  final bool? toggled;
  final bool? selected;
  final bool? expanded;
  final bool? inMutuallyExclusiveGroup;
  final BorderRadius focusBorderRadius;

  const SeedPressable({
    super.key,
    this.child,
    this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.enableScale = true,
    this.behavior = HitTestBehavior.opaque,
    this.focusNode,
    this.autofocus = false,
    this.semanticsLabel,
    this.semanticsValue,
    this.semanticsRole,
    this.headingLevel,
    this.semanticButton = true,
    this.checked,
    this.mixed,
    this.toggled,
    this.selected,
    this.expanded,
    this.inMutuallyExclusiveGroup,
    this.focusBorderRadius = const BorderRadius.all(Radius.circular(4)),
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided.',
       );

  @override
  State<SeedPressable> createState() => _SeedPressableState();
}

// Focus can be restored after a route or overlay closes. Track input modality
// across controls so restoring focus does not turn a mouse click into a ring.
class _SeedFocusHighlight extends ChangeNotifier {
  static final instance = _SeedFocusHighlight();
  bool usingPointer = false;

  void _setUsingPointer(bool value) {
    if (usingPointer == value) return;
    usingPointer = value;
    notifyListeners();
  }

  void _handlePointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) _setUsingPointer(true);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _setUsingPointer(false);
    }
    return false;
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(
        _handlePointerEvent,
      );
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
      usingPointer = false;
    }
  }
}

class _SeedPressableState extends State<SeedPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Size _childSize = Size.zero;
  bool _isPressed = false;
  bool _isHovered = false;
  bool _hasFocus = false;
  bool _showFocus = false;
  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;
  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  @override
  void initState() {
    super.initState();
    _SeedFocusHighlight.instance.addListener(_handleFocusHighlightChange);
    _controller = AnimationController(
      vsync: this,
      duration: SeedDuration.pressedScale,
    );
  }

  @override
  void dispose() {
    _SeedFocusHighlight.instance.removeListener(_handleFocusHighlightChange);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _controller.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_interactive) return;
    setState(() {
      _isPressed = true;
    });
    _controller.animateTo(1.0, curve: SeedCurves.pressedScale);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (_interactive &&
        _focusNode.hasPrimaryFocus &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      if (event is KeyDownEvent) {
        setState(() => _isPressed = true);
        _controller.animateTo(1, curve: SeedCurves.pressedScale);
      }
      if (event is KeyUpEvent) _release();
    }
    return false;
  }

  void _handleFocusChange(bool value) {
    if (!mounted) return;
    if (!value) _release();
    // Listen while focused so keyboard use restores the ring after a click,
    // even when a shortcut handles the key before it reaches the focus node.
    if (value) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    setState(() {
      _hasFocus = value;
    });
  }

  void _handleFocusHighlightChange() {
    if (mounted && _hasFocus) setState(() {});
  }

  void _handleTapUp(TapUpDetails details) {
    _release();
  }

  void _handleTapCancel() {
    _release();
  }

  void _release() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.animateBack(0.0, curve: SeedCurves.pressedScale);
    }
  }

  @override
  void didUpdateWidget(SeedPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_interactive && _isPressed) {
      _isPressed = false;
      _controller.value = 0;
    }
  }

  void _activate() {
    if (!_interactive || widget.onTap == null) return;
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final content = SeedInteractionState(
      pressed: _isPressed,
      hovered: _interactive && _isHovered,
      focused: _hasFocus,
      child: Builder(
        builder: (context) => widget.builder != null
            ? widget.builder!(
                context,
                _isPressed || (_interactive && _isHovered),
              )
            : widget.child!,
      ),
    );

    return Semantics(
      container: true,
      role: widget.semanticsRole ?? SemanticsRole.none,
      header: widget.headingLevel != null,
      headingLevel: widget.headingLevel,
      button: widget.semanticButton,
      enabled: _interactive,
      focusable: _interactive,
      focused: _interactive ? _hasFocus : null,
      label: widget.semanticsLabel,
      value: widget.semanticsValue,
      excludeSemantics: widget.semanticsLabel != null,
      checked: widget.checked,
      mixed: widget.mixed,
      toggled: widget.toggled,
      selected: widget.selected,
      expanded: widget.expanded,
      inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup,
      onTap: _interactive && widget.onTap != null ? _activate : null,
      onLongPress: _interactive ? widget.onLongPress : null,
      child: MouseRegion(
        onEnter: (event) {
          if (_interactive &&
              event.kind != PointerDeviceKind.touch &&
              event.kind != PointerDeviceKind.unknown) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (_isHovered) setState(() => _isHovered = false);
        },
        child: FocusableActionDetector(
          enabled: _interactive,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          includeFocusSemantics: false,
          mouseCursor: _interactive
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onFocusChange: _handleFocusChange,

          onShowFocusHighlight: (value) {
            if (mounted) setState(() => _showFocus = value);
          },
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter, includeRepeats: false):
                ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space, includeRepeats: false):
                ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _activate();
                return null;
              },
            ),
          },
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: widget.focusBorderRadius,
              border:
                  _showFocus &&
                      !_SeedFocusHighlight.instance.usingPointer &&
                      _interactive
                  ? Border.all(
                      color:
                          Theme.of(context)
                              .extension<SeedColorScheme>()
                              ?.stroke
                              .focusRing ??
                          Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: GestureDetector(
              excludeFromSemantics: true,
              behavior: widget.behavior,
              onTapDown: _interactive ? _handleTapDown : null,
              onTapUp: _interactive ? _handleTapUp : null,
              onTapCancel: _interactive ? _handleTapCancel : null,
              onTap: _interactive && widget.onTap != null
                  ? () {
                      _focusNode.requestFocus();
                      _activate();
                    }
                  : null,
              onLongPress: _interactive ? widget.onLongPress : null,
              child: _SizeReporter(
                onSizeChanged: (newSize) {
                  if (mounted && _childSize != newSize) {
                    setState(() => _childSize = newSize);
                  }
                },
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    if (!widget.enableScale ||
                        disableAnimations ||
                        _childSize == Size.zero) {
                      return child!;
                    }
                    final targetScale = SeedScaleCalculator.calculateScale(
                      width: _childSize.width,
                      height: _childSize.height,
                    );
                    return Transform.scale(
                      scale: 1 - (1 - targetScale) * _controller.value,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeReporter extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onSizeChanged;

  const _SizeReporter({required this.onSizeChanged, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeReporter(onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderSizeReporter renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  ValueChanged<Size> onSizeChanged;
  Size _lastReportedSize = Size.zero;

  _RenderSizeReporter(this.onSizeChanged);

  @override
  void performLayout() {
    super.performLayout();
    if (size != _lastReportedSize) {
      _lastReportedSize = size;
      final measuredSize = size;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attached) onSizeChanged(measuredSize);
      });
    }
  }
}
