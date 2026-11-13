import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart'
    show GestureBinding, PointerDeviceKind, PointerDownEvent, PointerEvent;

import '../motion/seed_motion.dart';
import '../../theme/seed_theme.dart';

/// Calculates the target scale for SEED scale feedback.
///
/// Formula from SEED Design System:
/// ```
/// basis = max(height, width / 4, 24)
/// scale = (basis - 2) / basis
/// ```
class SeedScaleCalculator {
  const SeedScaleCalculator._();

  /// Calculates pressed scale from [width] and [height] using max(height, width / 4, 24).
  ///
  /// [disableAnimations] defaults to false; when true the scale is exactly 1.
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
  /// Shares [pressed], [hovered], and [focused] interaction state with descendants.
  ///
  /// [focusVisible] defaults to false and follows keyboard focus visibility rather than pointer focus.
  const SeedInteractionState({
    super.key,
    required this.pressed,
    required this.hovered,
    required this.focused,
    this.focusVisible = false,
    this.surfaceSize,
    required super.child,
  });

  /// True during pointer or keyboard press; hover does not imply press.
  final bool pressed, hovered, focused;

  /// Keyboard focus, as CSS `:focus-visible`.
  final bool focusVisible;

  /// Measured size of the enclosing pressable surface, when available.
  final Size? surfaceSize;

  /// Returns the nearest inherited interaction state or null if outside a [SeedPressable].
  static SeedInteractionState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedInteractionState>();

  /// Notifies dependents when press, hover, focus, or focus visibility changes.
  @override
  bool updateShouldNotify(SeedInteractionState oldWidget) =>
      pressed != oldWidget.pressed ||
      hovered != oldWidget.hovered ||
      focused != oldWidget.focused ||
      focusVisible != oldWidget.focusVisible ||
      surfaceSize != oldWidget.surfaceSize;
}

/// Draws the official outside focus ring around a control inside a
/// [SeedPressable] whose own ring is disabled with `paintFocusRing: false`.
class SeedControlFocusRing extends StatelessWidget {
  /// Draws an outer 2 px focus ring around [child], clipped to [borderRadius], while the nearest
  /// [SeedInteractionState] indicates visible focus.
  const SeedControlFocusRing({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  /// Corner shape of the focus ring, matching the control surface.
  final BorderRadius borderRadius;

  /// Control subtree that receives the focus decoration.
  final Widget child;

  /// Paints the focus ring for keyboard focus using the SEED stroke.focusRing token.
  @override
  Widget build(BuildContext context) {
    final visible =
        SeedInteractionState.maybeOf(context)?.focusVisible ?? false;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: visible
            ? Border.all(
                color: context.seedColor.stroke.focusRing,
                width: 2,
                strokeAlign: 3,
              )
            : null,
      ),
      child: child,
    );
  }
}

/// Scales just the content of a SeedPressable, leaving its surface fixed.
class SeedContentScale extends StatefulWidget {
  /// Scales [child] according to [SeedScaleCalculator] on press.
  ///
  /// Null [pressed] reads the nearest [SeedInteractionState]; a specified value overrides it.
  const SeedContentScale({super.key, required this.child, this.pressed});

  /// Content to scale independently from the pressable surface.
  final Widget child;

  /// Optional controlled pressed state; null follows the closest [SeedInteractionState].
  final bool? pressed;

  /// Creates the state that measures child size and animates content scale.
  @override
  State<SeedContentScale> createState() => _SeedContentScaleState();
}

class _SeedContentScaleState extends State<SeedContentScale> {
  Size _size = Size.zero;
  @override
  Widget build(BuildContext context) {
    final interaction = SeedInteractionState.maybeOf(context);
    final size = interaction?.surfaceSize ?? _size;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return _SizeReporter(
      onSizeChanged: (size) {
        if (mounted && _size != size) setState(() => _size = size);
      },
      child: AnimatedScale(
        scale:
            (widget.pressed ?? interaction?.pressed) == true &&
                size != Size.zero
            ? SeedScaleCalculator.calculateScale(
                width: size.width,
                height: size.height,
                disableAnimations: disableAnimations,
              )
            : 1,
        duration: disableAnimations ? Duration.zero : SeedDuration.pressedScale,
        curve: SeedCurves.pressedScale,
        child: widget.child,
      ),
    );
  }
}

/// A widget that applies SEED Design System physical scale feedback when pressed.
///
/// Automatically measures the child dimensions and applies the standard SEED formula:
/// `basis = max(height, width / 4, 24)` and `scale = (basis - 2) / basis`.
class SeedPressable extends StatefulWidget {
  /// Optional fixed content. Either [child] or [builder] must be non-null.
  final Widget? child;

  /// Optional content callback receiving context and the pressed-or-hovered visual state.
  final Widget Function(BuildContext context, bool isPressed)? builder;

  /// Activation callback for taps and supported keyboard/semantics actions; null disables tap activation.
  final VoidCallback? onTap;

  /// Callback for long press when enabled; null disables long-press activation.
  final VoidCallback? onLongPress;

  /// Master interaction switch. Defaults to true; callbacks must also be present for an interactive target.
  final bool enabled;

  /// Whether press feedback scales the child.
  ///
  /// Defaults to true; reduced-motion settings still suppress scaling.
  final bool enableScale;

  /// GestureDetector hit-testing behavior. Defaults to [HitTestBehavior.opaque].
  final HitTestBehavior behavior;

  /// Optional externally owned focus node. A private node is used when null.
  final FocusNode? focusNode;

  /// Whether to request initial keyboard focus. Defaults to false.
  final bool autofocus;

  /// Accessible name for the composite control; when specified, descendant semantics are excluded.
  final String? semanticsLabel;

  /// Optional accessible value announced for the control.
  final String? semanticsValue;

  /// Validation status on the same semantics node as the control's role.
  final SemanticsValidationResult semanticsValidationResult;

  /// Exposes a focusable control as read-only and omits its semantic tap.
  final bool semanticsReadOnly;

  /// Optional [SemanticsRole] override; null uses the generic role.
  final SemanticsRole? semanticsRole;

  /// Optional accessible heading level; a non-null value exposes header semantics.
  final int? headingLevel;

  /// Whether to expose button semantics. Defaults to true; link targets can customize it.
  final bool semanticButton;

  /// Exposes this target as a single link node instead of a button.
  final Uri? semanticsLinkUrl;

  /// Retain Enter for button-like targets, but allow native checkbox/switch
  /// parity (Space-only) for controls built on this pressable.
  final bool activateOnEnter;

  /// Disabled native selection rows blur the previously focused input on a
  /// physical pointer tap, without enabling the disabled control itself.
  final bool unfocusOnDisabledTap;

  /// Optional checked semantics state for checkbox-like controls.
  final bool? checked;

  /// Optional indeterminate/mixed semantics state for checkable controls.
  final bool? mixed;

  /// Optional toggled state for switch-like controls.
  final bool? toggled;

  /// Optional selected state of this accessible choice.
  final bool? selected;

  /// Optional expanded/collapsed state of expandable controls.
  final bool? expanded;

  /// Whether this is a mutually exclusive option such as a radio choice.
  final bool? inMutuallyExclusiveGroup;

  /// Focus ring corners. Defaults to a uniform 4 px radius.
  final BorderRadius focusBorderRadius;

  /// Draws the focus ring inside the bounds, for targets whose official recipe
  /// uses `position: "inside"` or that sit against a clipping edge. Otherwise
  /// the ring sits outside the bounds with the official 2px offset.
  final bool focusRingInside;

  /// False when the builder places a [SeedControlFocusRing] itself.
  final bool paintFocusRing;

  /// Creates a pressable control.
  ///
  /// Supply [child] or [builder]; both may be supplied but [builder] takes precedence.
  /// [onTap]/[onLongPress] enable activation when [enabled] is true.
  ///
  /// [enableScale], [semanticButton], and [activateOnEnter] default to true.
  /// [behavior] defaults to opaque; [autofocus] and [unfocusOnDisabledTap] default to false.
  /// [focusBorderRadius] defaults to a 4 px radius; [focusRingInside] defaults to false and
  /// [paintFocusRing] to true.
  ///
  /// Additional semantics flags expose the corresponding control state.
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
    this.semanticsValidationResult = SemanticsValidationResult.none,
    this.semanticsReadOnly = false,
    this.semanticsRole,
    this.headingLevel,
    this.semanticButton = true,
    this.semanticsLinkUrl,
    this.activateOnEnter = true,
    this.unfocusOnDisabledTap = false,
    this.checked,
    this.mixed,
    this.toggled,
    this.selected,
    this.expanded,
    this.inMutuallyExclusiveGroup,
    this.focusBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.focusRingInside = false,
    this.paintFocusRing = true,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided.',
       );

  /// Creates the state that handles tap, keyboard, focus, hover, and press-scale animation.
  @override
  State<SeedPressable> createState() => _SeedPressableState();
}

// Focus can be restored after a route or overlay closes. Track input modality
// across controls so restoring focus does not turn a mouse click into a ring.
/// Whether the most recent input was a pointer rather than a key.
bool get seedLastInputWasPointer => _SeedFocusHighlight.instance.usingPointer;

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
  LogicalKeyboardKey? _pressedKey;
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
    // A configuration change can disable Enter while it is still held. Its
    // matching release must still clear the press started under the old setting.
    if (event is KeyUpEvent && event.logicalKey == _pressedKey) {
      _release();
      return false;
    }
    if (_interactive &&
        _focusNode.hasPrimaryFocus &&
        ((widget.activateOnEnter &&
                event.logicalKey == LogicalKeyboardKey.enter) ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      if (event is KeyDownEvent) {
        _pressedKey = event.logicalKey;
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
    _pressedKey = null;
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.animateBack(0.0, curve: SeedCurves.pressedScale);
    }
  }

  @override
  void didUpdateWidget(SeedPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isPressed &&
        (!_interactive ||
            oldWidget.activateOnEnter != widget.activateOnEnter)) {
      _pressedKey = null;
      _isPressed = false;
      _controller.value = 0;
    }
  }

  void _activate() {
    if (!_interactive || widget.onTap == null) return;
    // Web accessibility activation reaches Semantics.onTap, bypassing the
    // GestureDetector. Both paths must establish the same keyboard actor.
    _focusNode.requestFocus();
    widget.onTap!();
  }

  void _activateSemantically() {
    // A web accessibility click bypasses pointer dispatch. Like a React click
    // without a preceding keydown, it must not seed a keyboard-open menu.
    // ActivateIntent still uses _activate and preserves keyboard modality.
    _SeedFocusHighlight.instance._setUsingPointer(true);
    _activate();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final content = SeedInteractionState(
      pressed: _isPressed,
      hovered: _interactive && _isHovered,
      focused: _hasFocus,
      surfaceSize: _childSize,
      focusVisible:
          _showFocus &&
          !_SeedFocusHighlight.instance.usingPointer &&
          _interactive,
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
      link: widget.semanticsLinkUrl != null,
      linkUrl: widget.semanticsLinkUrl,
      enabled: _interactive,
      focusable: _interactive,
      focused: _interactive ? _hasFocus : null,
      onFocus: _interactive && defaultTargetPlatform != TargetPlatform.iOS
          ? _focusNode.requestFocus
          : null,
      label: widget.semanticsLabel,
      value: widget.semanticsValue,
      validationResult: widget.semanticsValidationResult,
      readOnly: widget.semanticsReadOnly ? true : null,
      excludeSemantics: widget.semanticsLabel != null,
      checked: widget.checked,
      mixed: widget.mixed,
      toggled: widget.toggled,
      selected: widget.selected,
      expanded: widget.expanded,
      inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup,
      onTap: _interactive && !widget.semanticsReadOnly && widget.onTap != null
          ? _activateSemantically
          : null,
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
          shortcuts: widget.activateOnEnter
              ? const {
                  SingleActivator(
                    LogicalKeyboardKey.enter,
                    includeRepeats: false,
                  ): ActivateIntent(),
                  SingleActivator(
                    LogicalKeyboardKey.space,
                    includeRepeats: false,
                  ): ActivateIntent(),
                }
              : const {
                  SingleActivator(
                    LogicalKeyboardKey.enter,
                    includeRepeats: false,
                  ): DoNothingIntent(),
                  SingleActivator(
                    LogicalKeyboardKey.space,
                    includeRepeats: false,
                  ): ActivateIntent(),
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
                  widget.paintFocusRing &&
                      _showFocus &&
                      !_SeedFocusHighlight.instance.usingPointer &&
                      _interactive
                  ? Border.all(
                      color: context.seedColor.stroke.focusRing,
                      width: 2,
                      // A 2px stroke with align 3 spans 2..4px outside the bounds.
                      strokeAlign: widget.focusRingInside
                          ? BorderSide.strokeAlignInside
                          : 3,
                    )
                  : null,
            ),
            child: GestureDetector(
              excludeFromSemantics: true,
              behavior: widget.behavior,
              onTapDown: _interactive
                  ? _handleTapDown
                  : widget.unfocusOnDisabledTap
                  ? (_) => FocusManager.instance.primaryFocus?.unfocus()
                  : null,
              onTapUp: _interactive ? _handleTapUp : null,
              onTapCancel: _interactive ? _handleTapCancel : null,
              onTap: _interactive && widget.onTap != null ? _activate : null,
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
