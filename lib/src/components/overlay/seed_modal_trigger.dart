import 'dart:ui' show SemanticsRole;

import 'seed_sheet_drag.dart';
import 'seed_side_panel.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/motion/seed_motion.dart';
import 'seed_anchored_overlay.dart';
import 'seed_bottom_sheet.dart';
import 'seed_dialog.dart';

/// Route surface selected by [SeedModalTrigger]: `dialog` is centered,
/// `bottomSheet` opens from below, and `sidePanel` slides horizontally.
enum SeedModalType {
  /// Centered dialog route.
  dialog,

  /// Bottom sheet route.
  bottomSheet,

  /// Sliding edge panel.
  sidePanel,
}

/// The official `useResponsiveDialogContext` and
/// `useResponsiveSidePanelContext`: how the enclosing [SeedModalTrigger]
/// is currently presenting its content.
///
/// Available to the trigger's `builder` and everything below it.
class SeedModalScope extends InheritedWidget {
  /// Describes a modal presented as [type] that was requested as
  /// [requestedType].
  const SeedModalScope({
    super.key,
    required this.type,
    required this.requestedType,
    required super.child,
  });

  /// The presentation in use now.
  final SeedModalType type;

  /// The presentation the trigger was created for.
  final SeedModalType requestedType;

  /// The official `shouldUseBottomSheet`: true while a responsive dialog or
  /// side panel is shown as a bottom sheet because the viewport is narrow.
  bool get shouldUseBottomSheet =>
      type == SeedModalType.bottomSheet &&
      requestedType != SeedModalType.bottomSheet;

  /// The nearest modal presentation, or null outside modal content.
  static SeedModalScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedModalScope>();

  /// The nearest modal presentation. Throws outside modal content, like the
  /// official hooks.
  static SeedModalScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'SeedModalScope.of() was called outside the content of a '
      'SeedModalTrigger.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(SeedModalScope oldWidget) =>
      type != oldWidget.type || requestedType != oldWidget.requestedType;
}

/// Controlled modal lifecycle, shared by dialogs, sheets and panels.
///
/// `open` has precedence over [controller], followed by internal state
/// initialized by [defaultOpen]. [onOpenChange] reports user requests and
/// [SeedOverlayDismissReason]; controlled callers update `open` themselves.
/// Modal variants use a Flutter popup route. Non-modal side panels use a
/// persistent overlay and allow interaction with the background.
class SeedModalTrigger extends StatefulWidget {
  /// Creates a trigger whose [builder] supplies the modal content.
  ///
  /// [dismissible] controls default backdrop/Escape policies, independently
  /// overridable by [closeOnInteractOutside] and [closeOnEscape]. [canClose]
  /// may refuse an attempted dismissal. [responsive] uses a bottom sheet below
  /// 768 logical pixels. Sheet-only [snapPoints], [snapController],
  /// [initialSnapIndex], [fadeFromIndex], and [handleOnly] control snapping.
  const SeedModalTrigger({
    super.key,
    required this.triggerBuilder,
    required this.builder,
    this.type = SeedModalType.dialog,
    this.controller,
    this.open,
    this.defaultOpen = false,
    SeedOverlayOpenChanged? onOpenChange,
    @Deprecated('Use onOpenChange instead.')
    SeedOverlayOpenChanged? onOpenChanged,
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
  }) : onOpenChanged = onOpenChange ?? onOpenChanged,
       assert(onOpenChange == null || onOpenChanged == null);

  /// Builds the trigger from context, current open state, and toggle callback.
  final Widget Function(BuildContext, bool, VoidCallback) triggerBuilder;

  /// Builds the dialog, sheet or panel contents in the overlay context.
  final WidgetBuilder builder;

  /// Requested modal presentation type.
  final SeedModalType type;

  /// Imperative open-state owner when [open] is absent.
  final SeedOverlayController? controller;

  /// Parent-controlled open state, taking precedence over [controller].
  final bool? open;

  /// Initial visibility and presentation/dismissal options.
  ///
  /// [defaultOpen] is initially false. [dismissible] defaults true;
  /// [responsive] defaults false; [modal] defaults true; [fromRight] defaults
  /// true; [skipAnimation] and [handleOnly] default false.
  final bool defaultOpen,
      dismissible,
      responsive,
      modal,
      fromRight,
      skipAnimation,
      handleOnly;

  /// Deprecated compatibility spelling of [onOpenChange].
  @Deprecated('Use onOpenChange instead.')
  final SeedOverlayOpenChanged? onOpenChanged;

  /// Visibility request callback including the dismissal cause.
  SeedOverlayOpenChanged? get onOpenChange => onOpenChanged;

  /// Returns false to prevent dismissal for a particular reason.
  final bool Function(SeedOverlayDismissReason)? canClose;

  /// Independent overrides for outside-tap and Escape dismissal; null uses
  /// [dismissible].
  final bool? closeOnInteractOutside, closeOnEscape;

  /// Optional fractional or pixel snap stops for a bottom sheet.
  final List<SeedSheetSnapPoint>? snapPoints;

  /// Initial snap stop index, `0` by default.
  final int initialSnapIndex;

  /// Snap stop where the modal backdrop reaches full opacity.
  final int? fadeFromIndex;

  /// Programmatic snap controller, owned and disposed by its creator.
  final SeedSheetController? snapController;

  /// Notified when a bottom sheet selects a new snap index.
  final ValueChanged<int>? onSnapChanged;
  @override
  State<SeedModalTrigger> createState() => _SeedModalTriggerState();
}

/// Trigger for a dialog, responsive to a bottom sheet below 768px by default.
class SeedDialogTrigger extends SeedModalTrigger {
  /// Creates a dialog trigger with `responsive: true` by default.
  const SeedDialogTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChange,
    @Deprecated('Use onOpenChange instead.') super.onOpenChanged,
    super.canClose,
    super.dismissible,
    super.closeOnInteractOutside,
    super.closeOnEscape,
    super.responsive = true,
    super.skipAnimation,
  }) : super(type: SeedModalType.dialog);
}

/// Dialog trigger with an initially non-dismissible backdrop, suitable for alerts.
class SeedAlertDialogTrigger extends SeedModalTrigger {
  /// Creates an alert trigger (`dismissible: false`, `closeOnEscape: true`).
  const SeedAlertDialogTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChange,
    @Deprecated('Use onOpenChange instead.') super.onOpenChanged,
    super.canClose,
    super.dismissible = false,
    super.closeOnInteractOutside,
    super.closeOnEscape = true,
    super.skipAnimation,
  }) : super(type: SeedModalType.dialog);
}

/// Trigger for a bottom-sheet route with optional snap stops.
class SeedBottomSheetTrigger extends SeedModalTrigger {
  /// Creates a sheet trigger; snap behavior is enabled by [SeedModalTrigger.snapPoints].
  const SeedBottomSheetTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChange,
    @Deprecated('Use onOpenChange instead.') super.onOpenChanged,
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

/// Trigger for a side panel that adapts to a bottom sheet on narrow screens.
class SeedSidePanelTrigger extends SeedModalTrigger {
  /// Creates a panel trigger with `responsive: true` by default.
  ///
  /// Set `modal: false` to use a persistent panel without a backdrop.
  const SeedSidePanelTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChange,
    @Deprecated('Use onOpenChange instead.') super.onOpenChanged,
    super.canClose,
    super.dismissible,
    super.closeOnInteractOutside,
    super.closeOnEscape,
    super.responsive = true,
    super.modal,
    super.fromRight,
    super.skipAnimation,
  }) : super(type: SeedModalType.sidePanel);
}

/// Trigger for a menu-sheet surface using bottom-sheet presentation.
class SeedMenuSheetTrigger extends SeedModalTrigger {
  /// Creates a menu-sheet trigger with normal modal dismissal policies.
  const SeedMenuSheetTrigger({
    super.key,
    required super.triggerBuilder,
    required super.builder,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChange,
    @Deprecated('Use onOpenChange instead.') super.onOpenChanged,
    super.canClose,
    super.dismissible,
    super.skipAnimation,
  }) : super(type: SeedModalType.bottomSheet);
}

class _SeedModalTriggerState extends State<SeedModalTrigger>
    with SingleTickerProviderStateMixin {
  bool _open = false;

  SeedModalType _typeFor(BuildContext context) =>
      widget.responsive && MediaQuery.sizeOf(context).width < 768
      ? SeedModalType.bottomSheet
      : widget.type;

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

  // The scope sits above the builder so that the builder's own context can
  // read the resolved presentation.
  Widget _content(
    BuildContext context,
    SeedModalType type, {
    GlobalKey? bodyKey,
  }) => SeedModalScope(
    type: type,
    requestedType: widget.type,
    child: Builder(
      builder: (context) => _contentBody(context, type, bodyKey: bodyKey),
    ),
  );

  Widget _contentBody(
    BuildContext context,
    SeedModalType type, {
    GlobalKey? bodyKey,
  }) {
    Widget responsiveBody(Widget body) =>
        bodyKey == null ? body : KeyedSubtree(key: bodyKey, child: body);
    Widget child = widget.builder(context);
    String? responsiveSemanticsLabel;
    if (type == SeedModalType.bottomSheet &&
        widget.type == SeedModalType.dialog &&
        child is SeedDialog) {
      final source = child;
      child = SeedBottomSheet(
        title: source.title,
        description: source.description,
        header: source.header,
        content: responsiveBody(source.content),
        showCloseButton: source.showCloseButton,
        maxHeight: source.maxHeight,
        contentPadding: source.bodyPadding,
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
    } else if (widget.responsive &&
        widget.modal &&
        type == SeedModalType.dialog &&
        child is SeedDialog) {
      child = SeedDialog(
        key: child.key,
        title: child.title,
        description: child.description,
        header: child.header,
        content: responsiveBody(child.content),
        footer: child.footer,
        subAction: child.subAction,
        secondaryAction: child.secondaryAction,
        primaryAction: child.primaryAction,
        showCloseButton: child.showCloseButton,
        maxWidth: child.maxWidth,
        size: child.size,
        maxHeight: child.maxHeight,
        scrollBody: child.scrollBody,
        showScrollFog: child.showScrollFog,
        bodyPadding: child.bodyPadding,
      );
    }
    if (type == SeedModalType.bottomSheet && child is SeedSidePanel) {
      final source = child;
      responsiveSemanticsLabel = source.semanticsLabel ?? source.title;
      child = SeedBottomSheet(
        title: source.title,
        description: source.description,
        header: source.titleWidget != null || source.descriptionWidget != null
            ? Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  24,
                  source.showCloseButton ? 56 : 16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DefaultTextStyle(
                      style: context.seedTypography.t8Bold.copyWith(
                        color: context.seedColor.fg.neutral,
                      ),
                      child: source.titleWidget ?? Text(source.title),
                    ),
                    if (source.descriptionWidget != null ||
                        source.description != null) ...[
                      const SizedBox(height: 8),
                      DefaultTextStyle(
                        style: context.seedTypography.t5Regular.copyWith(
                          color: context.seedColor.fg.neutralMuted,
                        ),
                        child:
                            source.descriptionWidget ??
                            Text(source.description!),
                      ),
                    ],
                  ],
                ),
              )
            : null,
        content: responsiveBody(source.body),
        footer: source.footer,
        showCloseButton: source.showCloseButton,
        onClosePressed: source.onClose,
        contentPadding:
            source.bodyPadding ?? const EdgeInsets.symmetric(horizontal: 16),
      );
    } else if (widget.responsive &&
        widget.modal &&
        type == SeedModalType.sidePanel &&
        child is SeedSidePanel) {
      child = SeedSidePanel(
        key: child.key,
        title: child.title,
        semanticsLabel: child.semanticsLabel,
        titleWidget: child.titleWidget,
        description: child.description,
        descriptionWidget: child.descriptionWidget,
        body: responsiveBody(child.body),
        bodyPadding: child.bodyPadding,
        footer: child.footer,
        onClose: child.onClose,
        size: child.size,
        width: child.width,
        maxWidth: child.maxWidth,
        fromRight: child.fromRight,
        showCloseButton: child.showCloseButton,
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
    if (responsiveSemanticsLabel != null) {
      child = Semantics(
        container: true,
        explicitChildNodes: true,
        scopesRoute: true,
        namesRoute: true,
        role: SemanticsRole.dialog,
        label: responsiveSemanticsLabel,
        child: child,
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
    final type = _typeFor(context);
    final bodyKey = widget.responsive ? GlobalKey() : null;
    final navigator = Navigator.of(context);
    _route = _SeedManagedRoute(
      type: type,
      resolveType: _typeFor,
      fromRight: widget.fromRight,
      dismissible: widget.closeOnInteractOutside ?? widget.dismissible,
      enableDrag: widget.dismissible && widget.snapPoints == null,
      reduceMotion:
          widget.skipAnimation || MediaQuery.disableAnimationsOf(context),
      color: context.seedColor.bg.overlay,
      barrierLabelText: MaterialLocalizations.of(context)
          .modalBarrierDismissLabel,
      onDismissRequest: (reason) => _request(false, reason),
      builder: (routeContext, currentType) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && widget.dismissible) {
            _request(false, SeedOverlayDismissReason.programmatic);
          }
        },
        child: _content(routeContext, currentType, bodyKey: bodyKey),
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
    required this.resolveType,
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
  final SeedModalType Function(BuildContext) resolveType;
  final bool fromRight, dismissible, reduceMotion, enableDrag;
  final Color color;
  final String barrierLabelText;
  final ValueChanged<SeedOverlayDismissReason> onDismissRequest;
  final Widget Function(BuildContext, SeedModalType) builder;
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
    final type = resolveType(context);
    Widget buildContent(BuildContext context) => builder(context, type);
    Widget child = Builder(builder: buildContent);
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
          enableDrag: false,
          showDragHandle: false,
          onClosing: () => onDismissRequest(SeedOverlayDismissReason.drag),
          builder: (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: enableDrag
                ? SeedSheetDragDismiss(
                    restoreAfterDismissRequest: true,
                    onDismiss: () =>
                        onDismissRequest(SeedOverlayDismissReason.drag),
                    child: Builder(builder: buildContent),
                  )
                : Builder(builder: buildContent),
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
