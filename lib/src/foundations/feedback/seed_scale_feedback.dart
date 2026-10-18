import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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

class _SeedPressableState extends State<SeedPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Size _childSize = Size.zero;
  bool _isPressed = false;
  bool _hasFocus = false;
  bool _showFocus = false;
  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;
  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SeedDuration.pressedScale,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_interactive) return;
    setState(() => _isPressed = true);
    _controller.animateTo(1.0, curve: SeedCurves.pressedScale);
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
    final content = widget.builder != null
        ? widget.builder!(context, _isPressed)
        : widget.child!;

    return Semantics(
      container: true,
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
      child: FocusableActionDetector(
        enabled: _interactive,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        includeFocusSemantics: false,
        mouseCursor: _interactive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onFocusChange: (value) {
          if (mounted) setState(() => _hasFocus = value);
        },
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
            border: _showFocus && _interactive
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
            onTapCancel: _handleTapCancel,
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
