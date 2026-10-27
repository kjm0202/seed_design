import 'seed_side_panel.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/motion/seed_motion.dart';
import 'seed_anchored_overlay.dart';
import 'seed_bottom_sheet.dart';
import 'seed_dialog.dart';

enum SeedModalType { dialog, bottomSheet, sidePanel }

/// Controlled modal lifecycle, shared by dialogs, sheets and panels.
class SeedModalTrigger extends StatefulWidget {
  const SeedModalTrigger({
    super.key,
    required this.triggerBuilder,
    required this.builder,
    this.type = SeedModalType.dialog,
    this.controller,
    this.open,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.canClose,
    this.dismissible = true,
    this.closeOnInteractOutside,
    this.closeOnEscape,
    this.responsive = false,
    this.modal = true,
    this.fromRight = true,
    this.skipAnimation = false,
    this.snapPoints,
    this.initialSnapIndex = 0,
    this.snapController,
    this.onSnapChanged,
    this.handleOnly = false,
    this.fadeFromIndex,
  });
  final Widget Function(BuildContext, bool, VoidCallback) triggerBuilder;
  final WidgetBuilder builder;
  final SeedModalType type;
  final SeedOverlayController? controller;
  final bool? open;
  final bool defaultOpen,
      dismissible,
      responsive,
      modal,
      fromRight,
      skipAnimation,
      handleOnly;
  final void Function(bool, SeedOverlayDismissReason)? onOpenChanged;
  final bool Function(SeedOverlayDismissReason)? canClose;
  final bool? closeOnInteractOutside, closeOnEscape;
  final List<SeedSheetSnapPoint>? snapPoints;
  final int initialSnapIndex;
  final int? fadeFromIndex;
  final SeedSheetController? snapController;
  final ValueChanged<int>? onSnapChanged;
  @override
  State<SeedModalTrigger> createState() => _SeedModalTriggerState();
}

class SeedDialogTrigger extends SeedModalTrigger {
  const SeedDialogTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChanged,
    super.canClose,
    super.dismissible,
    super.closeOnInteractOutside,
    super.closeOnEscape,
    super.responsive = true,
    super.skipAnimation,
  }) : super(type: SeedModalType.dialog);
}

class SeedAlertDialogTrigger extends SeedModalTrigger {
  const SeedAlertDialogTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChanged,
    super.canClose,
    super.dismissible = false,
    super.closeOnInteractOutside,
    super.closeOnEscape = true,
    super.skipAnimation,
  }) : super(type: SeedModalType.dialog);
}

class SeedBottomSheetTrigger extends SeedModalTrigger {
  const SeedBottomSheetTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChanged,
    super.canClose,
    super.dismissible,
    super.closeOnInteractOutside,
    super.closeOnEscape,
    super.skipAnimation,
    super.snapPoints,
    super.initialSnapIndex,
    super.snapController,
    super.onSnapChanged,
    super.handleOnly,
    super.fadeFromIndex,
  }) : super(type: SeedModalType.bottomSheet);
}

class SeedSidePanelTrigger extends SeedModalTrigger {
  const SeedSidePanelTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChanged,
    super.canClose,
    super.dismissible,
    super.responsive = true,
    super.modal,
    super.fromRight,
    super.skipAnimation,
  }) : super(type: SeedModalType.sidePanel);
}

class SeedMenuSheetTrigger extends SeedModalTrigger {
  const SeedMenuSheetTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChanged,
    super.canClose,
    super.dismissible,
    super.skipAnimation,
  }) : super(type: SeedModalType.bottomSheet);
}

class _SeedModalTriggerState extends State<SeedModalTrigger>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  _SeedManagedRoute? _route;
  FocusNode? _returnFocus;
  final OverlayPortalController _persistent = OverlayPortalController();
  late final AnimationController _persistentAnimation = AnimationController(
    vsync: this,
    duration: SeedDuration.d6,
    reverseDuration: SeedDuration.d4,
  );
  SeedOverlayDismissReason _reason = SeedOverlayDismissReason.programmatic;
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          (widget.open ?? widget.controller?.isOpen ?? widget.defaultOpen)) {
        _show();
      }
    });
  }

  @override
  void didUpdateWidget(SeedModalTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      widget.controller?.addListener(_controllerChanged);
    }
    final desired = widget.open ?? widget.controller?.isOpen ?? _open;
    if (desired != _open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) desired ? _show() : _hide();
      });
    }
  }

  void _controllerChanged() {
    if (mounted && widget.open == null) {
      widget.controller!.isOpen ? _show() : _hide();
    }
  }

  void _request(bool open, SeedOverlayDismissReason reason) {
    if (!open &&
        ((reason == SeedOverlayDismissReason.outside &&
                !(widget.closeOnInteractOutside ?? widget.dismissible)) ||
            (reason == SeedOverlayDismissReason.escapeKey &&
                !(widget.closeOnEscape ?? widget.dismissible)) ||
            (reason == SeedOverlayDismissReason.drag && !widget.dismissible))) {
      return;
    }
    if (!open && widget.canClose?.call(reason) == false) {
      _route?.restore();
      return;
    }
    _reason = reason;
    widget.onOpenChanged?.call(open, reason);
    if (widget.open != null) {
      if (!open) _route?.restore();
      return;
    }
    if (widget.controller != null) {
      open ? widget.controller!.open() : widget.controller!.close(reason);
    } else {
      open ? _show() : _hide();
    }
  }

  Widget _content(BuildContext context, SeedModalType type) {
    Widget child = widget.builder(context);
    if (type == SeedModalType.bottomSheet &&
        widget.type == SeedModalType.dialog &&
        child is SeedDialog) {
      final source = child;
      child = SeedBottomSheet(
        title: source.title,
        description: source.description,
        header: source.header,
        content: source.content,
        showCloseButton: source.showCloseButton,
        footer:
            source.footer ??
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ?source.subAction,
                ?source.secondaryAction,
                ?source.primaryAction,
              ],
            ),
      );
    }
    if (type == SeedModalType.bottomSheet && child is SeedSidePanel) {
      final source = child;
      child = SeedBottomSheet(
        title: source.title,
        description: source.description,
        content: source.body,
        footer: source.footer,
      );
    }
    if (type == SeedModalType.bottomSheet && widget.snapPoints != null) {
      child = SeedSnappingBottomSheet(
        sheet: child is SeedBottomSheet
            ? child
            : SeedBottomSheet(content: child),
        snapPoints: widget.snapPoints!,
        initialSnapIndex: widget.initialSnapIndex,
        controller: widget.snapController,
        onSnapChanged: widget.onSnapChanged,
        handleOnly: widget.handleOnly,
        fadeFromIndex: widget.fadeFromIndex,
        onFadeChanged: (value) => _route?.setFade(value),
        dismissible: widget.dismissible,
      );
    }
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (widget.closeOnEscape ?? widget.dismissible) {
            _request(false, SeedOverlayDismissReason.escapeKey);
          }
        },
      },
      child: Focus(
        autofocus: widget.modal,
        child: SeedOverlayScope(
          side: widget.fromRight ? SeedOverlaySide.right : SeedOverlaySide.left,
          close: (reason) => _request(false, reason),
          child: child,
        ),
      ),
    );
  }

  void _show() {
    if (_open) return;
    _returnFocus = FocusManager.instance.primaryFocus;
    setState(() => _open = true);
    if (!widget.modal && widget.type == SeedModalType.sidePanel) {
      _persistent.show();
      _persistentAnimation.duration =
          widget.skipAnimation || MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : SeedDuration.d6;
      _persistentAnimation.forward();
      return;
    }
    final type = widget.responsive && MediaQuery.sizeOf(context).width < 768
        ? SeedModalType.bottomSheet
        : widget.type;
    final navigator = Navigator.of(context);
    _route = _SeedManagedRoute(
      type: type,
      fromRight: widget.fromRight,
      dismissible: widget.closeOnInteractOutside ?? widget.dismissible,
      enableDrag: widget.snapPoints == null,
      reduceMotion:
          widget.skipAnimation || MediaQuery.disableAnimationsOf(context),
      color: context.seedColor.bg.overlay,
      barrierLabelText: MaterialLocalizations.of(context)
          .modalBarrierDismissLabel,
      onDismissRequest: (reason) => _request(false, reason),
      builder: (routeContext) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && widget.dismissible) {
            _request(false, SeedOverlayDismissReason.programmatic);
          }
        },
        child: _content(routeContext, type),
      ),
    );
    navigator.push(_route!).whenComplete(() {
      _route = null;
      if (!mounted) return;
      if (_open) {
        setState(() => _open = false);
        widget.onOpenChanged?.call(false, _reason);
        if (widget.controller?.isOpen ?? false) {
          widget.controller!.close(_reason);
        }
      }
      if (_returnFocus?.context != null) _returnFocus!.requestFocus();
    });
  }

  Future<void> _hide() async {
    if (!_open) return;
    setState(() => _open = false);
    if (!widget.modal && widget.type == SeedModalType.sidePanel) {
      _persistentAnimation.reverseDuration =
          widget.skipAnimation || MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : SeedDuration.d4;
      try {
        await _persistentAnimation.reverse().orCancel;
      } on TickerCanceled {
        return;
      }
      if (mounted && !_open) _persistent.hide();
    } else {
      final route = _route;
      if (route?.navigator != null) {
        if (route!.isCurrent) {
          route.navigator!.pop();
        } else {
          route.navigator!.removeRoute(route);
        }
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    final route = _route;
    if (route?.navigator != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route!.navigator != null) route.navigator!.removeRoute(route);
      });
    }
    _persistentAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _persistent,
    overlayChildBuilder: (context) => Positioned.fill(
      child: Align(
        alignment: widget.fromRight
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: SlideTransition(
          position:
              Tween(
                begin: Offset(widget.fromRight ? 1 : -1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _persistentAnimation,
                  curve: SeedCurves.easing,
                ),
              ),
          child: Material(
            type: MaterialType.transparency,
            child: _content(context, SeedModalType.sidePanel),
          ),
        ),
      ),
    ),
    child: Semantics(
      expanded: _open,
      child: widget.triggerBuilder(
        context,
        _open,
        () => _request(!_open, SeedOverlayDismissReason.trigger),
      ),
    ),
  );
}

class _SeedManagedRoute extends PopupRoute<Object?> {
  _SeedManagedRoute({
    required this.type,
    required this.fromRight,
    required this.dismissible,
    required this.enableDrag,
    required this.reduceMotion,
    required this.color,
    required this.barrierLabelText,
    required this.onDismissRequest,
    required this.builder,
  });
  final SeedModalType type;
  final bool fromRight, dismissible, reduceMotion, enableDrag;
  final Color color;
  final String barrierLabelText;
  final ValueChanged<SeedOverlayDismissReason> onDismissRequest;
  final WidgetBuilder builder;
  double _fade = 1;
  void setFade(double value) {
    if (_fade == value) return;
    _fade = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isActive) changedInternalState();
    });
  }

  @override
  Color get barrierColor => color.withValues(alpha: color.a * _fade);
  @override
  bool get barrierDismissible => dismissible;
  @override
  String get barrierLabel => barrierLabelText;
  @override
  Duration get transitionDuration => reduceMotion
      ? Duration.zero
      : type == SeedModalType.dialog
      ? SeedDuration.d4
      : SeedDuration.d6;
  @override
  Duration get reverseTransitionDuration => reduceMotion
      ? Duration.zero
      : type == SeedModalType.dialog
      ? SeedDuration.d2
      : SeedDuration.d4;
  void restore() => controller?.forward();
  @override
  Widget buildModalBarrier() => AnimatedModalBarrier(
    color: animation!.drive(
      ColorTween(begin: Colors.transparent, end: barrierColor),
    ),
    dismissible: dismissible,
    barrierSemanticsDismissible: dismissible,
    semanticsLabel: barrierLabel,
    onDismiss: () => onDismissRequest(SeedOverlayDismissReason.outside),
  );
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Widget child = Builder(builder: builder);
    if (type == SeedModalType.bottomSheet) {
      child = SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: BottomSheet(
          animationController: controller,
          backgroundColor: Colors.transparent,
          elevation: 0,
          enableDrag: dismissible && enableDrag,
          showDragHandle: false,
          onClosing: () => onDismissRequest(SeedOverlayDismissReason.drag),
          builder: (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Builder(builder: builder),
          ),
        ),
      );
    } else if (type == SeedModalType.dialog) {
      child = AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.status == AnimationStatus.reverse
                ? const AlwaysStoppedAnimation(1.0)
                : animation
                      .drive(CurveTween(curve: SeedCurves.enterExpressive))
                      .drive(Tween(begin: 1.3, end: 1.0)),
            child: child,
          ),
        ),
      );
    } else {
      child = SlideTransition(
        position: Tween(
          begin: Offset(fromRight ? 1 : -1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: SeedCurves.easing)),
        child: child,
      );
    }
    return SafeArea(
      top: type != SeedModalType.bottomSheet,
      bottom: false,
      child: Align(
        alignment: type == SeedModalType.bottomSheet
            ? Alignment.bottomCenter
            : type == SeedModalType.sidePanel
            ? (fromRight ? Alignment.centerRight : Alignment.centerLeft)
            : Alignment.center,
        child: child,
      ),
    );
  }
}
