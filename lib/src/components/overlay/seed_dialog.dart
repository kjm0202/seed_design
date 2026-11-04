import '../../localization/seed_localizations.dart';

import 'dart:ui' show SemanticsRole;

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/motion/seed_motion.dart';

import '../../foundations/feedback/seed_scale_feedback.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../button/seed_button.dart';
import 'seed_anchored_overlay.dart';
import '../layout/seed_scroll_area.dart';

void _closeSeedDialog(
  BuildContext context,
  SeedOverlayDismissReason reason, [
  Object? result,
]) {
  final scope = SeedOverlayScope.maybeOf(context);
  if (scope != null) {
    scope.close(reason);
  } else if (ModalRoute.of(context) case final _SeedDialogRoute route) {
    route.dismiss(reason, result);
  } else {
    Navigator.of(context).pop(result);
  }
}

/// Pushes a modal SEED dialog route and completes with its Navigator result.
///
/// Supply exactly one of [child] or [builder]. [useRootNavigator] defaults to
/// true; [routeSettings], [requestFocus], [anchorPoint],
/// [traversalEdgeBehavior], and [useSafeArea] configure the Flutter route.
/// [barrierDismissible] and [closeOnEscape] independently control outside-tap
/// and Escape dismissal, both enabled by default. [barrierLabel] provides an
/// accessible scrim label; [barrierColor] defaults to the theme overlay color.
/// [onDismissed] receives the recorded [SeedOverlayDismissReason] after exit.
Future<T?> showSeedDialog<T>({
  required BuildContext context,
  Widget? child,
  WidgetBuilder? builder,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  bool useSafeArea = true,
  bool? requestFocus,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  String? barrierLabel,
  Color? barrierColor,
  bool barrierDismissible = true,
  bool closeOnEscape = true,
  ValueChanged<SeedOverlayDismissReason>? onDismissed,
}) {
  assert(
    (child == null) != (builder == null),
    'Provide exactly one of child or builder.',
  );
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final route = _SeedDialogRoute<T>(
    context: context,
    contentBuilder: builder ?? (_) => child!,
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    settings: routeSettings,
    useSafeArea: useSafeArea,
    requestFocus: requestFocus ?? navigator.widget.requestFocus,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior: traversalEdgeBehavior,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor ?? context.seedColor.bg.overlay,
    dismissible: barrierDismissible,
    closeOnEscape: closeOnEscape,
  );
  return navigator
      .push<T>(route)
      .whenComplete(() => onDismissed?.call(route.reason));
}

class _SeedDialogRoute<T> extends DialogRoute<T> {
  _SeedDialogRoute({
    required super.context,
    required WidgetBuilder contentBuilder,
    required CapturedThemes themes,
    super.settings,
    super.useSafeArea,
    super.requestFocus,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    super.barrierLabel,
    required Color barrierColor,
    required bool dismissible,
    required bool closeOnEscape,
  }) : reduceMotion = MediaQuery.disableAnimationsOf(context),
       super(
         barrierDismissible: dismissible,
         barrierColor: barrierColor,
         themes: themes,
         builder: (routeContext) => CallbackShortcuts(
           bindings: {
             const SingleActivator(LogicalKeyboardKey.escape): () {
               if (closeOnEscape) {
                 (ModalRoute.of(routeContext)! as _SeedDialogRoute<T>).dismiss(
                   SeedOverlayDismissReason.escapeKey,
                 );
               }
             },
           },
           child: Focus(
             // Holds initial focus without being a Tab stop of its own.
             skipTraversal: true,
             autofocus: requestFocus ?? true,
             child: Builder(builder: contentBuilder),
           ),
         ),
       );
  final bool reduceMotion;
  SeedOverlayDismissReason reason = SeedOverlayDismissReason.programmatic;
  // The official backdrop enters in d2 while the content takes d4.
  late final CurvedAnimation _barrierAnimation = CurvedAnimation(
    parent: animation!,
    curve: const Interval(0, 0.5),
    reverseCurve: Curves.linear,
  );

  @override
  void dispose() {
    _barrierAnimation.dispose();
    super.dispose();
  }

  void dismiss(SeedOverlayDismissReason reason, [Object? result]) {
    this.reason = reason;
    navigator?.pop(result);
  }

  @override
  Duration get transitionDuration =>
      reduceMotion ? Duration.zero : SeedDuration.d4;
  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : SeedDuration.d2;
  @override
  Widget buildModalBarrier() => AnimatedModalBarrier(
    color: _barrierAnimation.drive(
      ColorTween(begin: Colors.transparent, end: barrierColor),
    ),
    dismissible: barrierDismissible,
    barrierSemanticsDismissible: barrierDismissible,
    semanticsLabel: barrierLabel,
    onDismiss: () => dismiss(SeedOverlayDismissReason.outside),
  );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: animation.status == AnimationStatus.reverse
          ? const AlwaysStoppedAnimation(1.0)
          : animation
                .drive(CurveTween(curve: SeedCurves.enterExpressive))
                .drive(Tween(begin: 1.3, end: 1.0)),
      child: child,
    ),
  );
}

const _automaticCancelText = '\u0000seed.cancel';

/// Pushes a SEED alert dialog and completes with the user's action result.
///
/// [title] is required; [description] is optional. [confirmText] defaults to
/// `확인`, while omitted [cancelText] defaults to `취소`; passing null to
/// [cancelText] omits the cancel action. [isCritical] applies critical action
/// styling. The modal backdrop is not dismissible by default, while Escape
/// closes unless [closeOnEscape] is false. Route ownership is chosen by
/// [useRootNavigator] (true by default); [routeSettings] and [requestFocus]
/// are Flutter Navigator options.
Future<bool?> showSeedAlertDialog({
  required BuildContext context,
  required String title,
  String? description,
  String? confirmText,
  String? cancelText = _automaticCancelText,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  bool? requestFocus,
  bool isCritical = false,
  bool barrierDismissible = false,
  bool closeOnEscape = true,
}) {
  return showSeedDialog<bool>(
    context: context,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    requestFocus: requestFocus,
    barrierDismissible: barrierDismissible,
    closeOnEscape: closeOnEscape,
    child: SeedAlertDialog(
      title: title,
      description: description,
      confirmText: confirmText,
      cancelText: cancelText,
      isCritical: isCritical,
    ),
  );
}

/// Composable confirmation/alert dialog content, with optional action slots.
///
/// Use [showSeedAlertDialog] or `SeedAlertDialogTrigger` for route lifecycle.
/// This widget renders content only; [onConfirm] and [onCancel] customize
/// the corresponding actions. Default labels are localized Korean fallbacks.
class SeedAlertDialog extends StatelessWidget {
  /// Visible alert heading.
  final String title;
  /// Optional supporting message under [title].
  final String? description;
  final String? _confirmText;
  final String? _cancelText;
  /// Confirm button label, `확인` when unspecified.
  String get confirmText => _confirmText ?? '확인';
  /// Cancel label, `취소` when omitted and null when explicitly suppressed.
  String? get cancelText =>
      _cancelText == _automaticCancelText ? '취소' : _cancelText;
  /// Whether the confirmation action has critical/destructive emphasis.
  final bool isCritical;
  /// Optional confirmation callback, invoked when the user confirms.
  final VoidCallback? onConfirm;
  /// Optional cancellation callback, invoked when the user cancels.
  final VoidCallback? onCancel;
  /// Optional replacement header, content, and footer composition slots.
  final Widget? header, body, footer;

  /// Creates alert content, allowing explicit null [cancelText] to hide cancel.
  const SeedAlertDialog({
    super.key,
    required this.title,
    this.description,
    String? confirmText,
    String? cancelText = _automaticCancelText,
    this.isCritical = false,
    this.onConfirm,
    this.onCancel,
    this.header,
    this.body,
    this.footer,
    // Keep public named parameters and non-nullable getters compatible.
    // ignore: prefer_initializing_formals
  }) : _confirmText = confirmText,
       // Preserve the public named parameter.
       // ignore: prefer_initializing_formals
       _cancelText = cancelText;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final confirmText =
        _confirmText ?? SeedLocalizations.label(context, SeedLabel.confirm);
    final cancelText = _cancelText == _automaticCancelText
        ? SeedLocalizations.label(context, SeedLabel.cancel)
        : _cancelText;

    return Semantics(
      role: SemanticsRole.alertDialog,
      scopesRoute: true,
      explicitChildNodes: true,
      child: Center(
        child: Padding(
          padding:
              MediaQuery.viewInsetsOf(context) +
              const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
          child: Container(
            width: 272,
            decoration: BoxDecoration(
              color: colors.bg.layerFloating,
              borderRadius: SeedBorderRadius.r5,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: SeedBorderRadius.r5,
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SeedDimension.x5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      namesRoute: true,
                      headingLevel: 2,
                      child:
                          header ??
                          Text(
                            title,
                            style: typography.t7Bold.copyWith(
                              color: colors.fg.neutral,
                            ),
                            textAlign: TextAlign.start,
                          ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: SeedDimension.x1_5),
                      Text(
                        description!,
                        style: typography.t5Regular.copyWith(
                          color: colors.fg.neutral,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                    if (body != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: body,
                      ),
                    const SizedBox(height: SeedDimension.x4),
                    if (footer != null)
                      footer!
                    else
                      _SeedAlertActions(
                        cancelText: cancelText,
                        confirmText: confirmText,
                        children: [
                          if (cancelText != null)
                            SeedButton(
                              label: cancelText,
                              variant: SeedButtonVariant.neutralWeak,
                              onPressed: () {
                                if (onCancel != null) {
                                  onCancel!();
                                } else {
                                  _closeSeedDialog(
                                    context,
                                    SeedOverlayDismissReason.action,
                                    false,
                                  );
                                }
                              },
                            ),
                          SeedButton(
                            label: confirmText,
                            variant: isCritical
                                ? SeedButtonVariant.criticalSolid
                                : SeedButtonVariant.brandSolid,
                            onPressed: () {
                              if (onConfirm != null) {
                                onConfirm!();
                              } else {
                                _closeSeedDialog(
                                  context,
                                  SeedOverlayDismissReason.action,
                                  true,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog width presets: `medium` is 480px, `large` is 800px.
enum SeedDialogSize {
  /// Maximum width 480px.
  medium,
  /// Maximum width 800px.
  large,
}

/// Equal-width actions, folding the primary action above the secondary action.
class _SeedAlertActions extends StatelessWidget {
  const _SeedAlertActions({
    required this.cancelText,
    required this.confirmText,
    required this.children,
  });
  final String? cancelText;
  final String confirmText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (children.length == 1) return children.single;
      final painter = TextPainter(
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.maybeLocaleOf(context),
        maxLines: 1,
      );
      final available =
          (constraints.maxWidth - 8) / 2 -
          SeedButtonSize.medium.padding.horizontal;
      final style = DefaultTextStyle.of(context).style
          .merge(context.seedTypography.t4Bold);
      bool fits(String text) {
        painter.text = TextSpan(text: text, style: style);
        painter.layout();
        return painter.width <= available;
      }

      final horizontal = fits(cancelText!) && fits(confirmText);
      painter.dispose();
      if (horizontal) {
        return Row(
          children: [
            Expanded(child: children.first),
            const SizedBox(width: 8),
            Expanded(child: children.last),
          ],
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [children.last, const SizedBox(height: 8), children.first],
      );
    },
  );
}

/// Composable SEED dialog surface with header, body, and footer.
///
/// [size] chooses a default maximum width of 480px (`medium`) or 800px
/// (`large`); explicit [maxWidth] overrides it. The body scrolls by default,
/// while footer actions remain outside the scroll region. Route behavior,
/// focus trapping, backdrop dismissal, and Escape are provided by
/// [showSeedDialog] or `SeedDialogTrigger`, not by this surface itself.
class SeedDialog extends StatelessWidget {
  /// Optional custom header that replaces automatic heading composition.
  final Widget? header;
  /// Optional heading text if [header] is absent.
  final String? title;
  /// Optional explanatory text below [title].
  final String? description;
  /// Required main dialog content.
  final Widget content;
  /// Optional custom footer, overriding auto-composed actions.
  final Widget? footer;
  /// Optional leading footer action in the auto-composed footer.
  final Widget? subAction;
  /// Optional secondary footer action.
  final Widget? secondaryAction;
  /// Optional primary footer action.
  final Widget? primaryAction;
  /// Displays the title-area close button; true by default.
  final bool showCloseButton;
  /// Effective maximum width, based on [size] unless explicitly overridden.
  final double maxWidth;
  final bool _hasCustomMaxWidth;
  /// Default width preset used when [maxWidth] is omitted.
  final SeedDialogSize size;
  /// Optional body height cap; defaults to 80% of the viewport height.
  final double? maxHeight;
  /// Body scrolling and scroll-fog visibility policies (both true by default).
  final bool scrollBody, showScrollFog;
  /// Content padding; horizontal 24px by default.
  final EdgeInsetsGeometry bodyPadding;

  /// Creates the dialog card without pushing a route.
  ///
  /// [content] is required; [footer] takes precedence over individual
  /// [subAction], [secondaryAction], and [primaryAction] slots.
  const SeedDialog({
    super.key,
    this.header,
    this.title,
    this.description,
    required this.content,
    this.footer,
    this.subAction,
    this.secondaryAction,
    this.primaryAction,
    this.showCloseButton = true,
    double? maxWidth,
    this.size = SeedDialogSize.medium,
    this.maxHeight,
    this.scrollBody = true,
    this.showScrollFog = true,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 24),
  }) : maxWidth = maxWidth ?? (size == SeedDialogSize.large ? 800 : 480),
       _hasCustomMaxWidth = maxWidth != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final mediaQuery = MediaQuery.of(context);
    final double maxHeight = this.maxHeight ?? mediaQuery.size.height * 0.8;

    Widget? effectiveFooter = footer;
    if (effectiveFooter == null &&
        (subAction != null ||
            secondaryAction != null ||
            primaryAction != null)) {
      effectiveFooter = Row(
        children: [
          ?subAction,
          const Spacer(),
          if (secondaryAction != null) ...[
            secondaryAction!,
            if (primaryAction != null) const SizedBox(width: SeedDimension.x2),
          ],
          ?primaryAction,
        ],
      );
    }

    return SafeArea(
      child: Padding(
        padding: mediaQuery.viewInsets,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = math.min(
              constraints.maxWidth,
              mediaQuery.size.width,
            );
            final width = mediaQuery.size.width < 768
                ? math.min(
                    availableWidth * .9,
                    _hasCustomMaxWidth ? maxWidth : double.infinity,
                  )
                : math.min(math.max(0.0, availableWidth - 40), maxWidth);
            return Center(
              child: Semantics(
                scopesRoute: true,
                explicitChildNodes: true,
                role: SemanticsRole.dialog,
                child: Container(
                  width: width,
                  constraints: BoxConstraints(
                    minHeight: math.min(
                      showCloseButton ? 65.0 : 0.0,
                      math.min(maxHeight, constraints.maxHeight),
                    ),
                    maxHeight: math.min(maxHeight, constraints.maxHeight),
                  ),
                  decoration: BoxDecoration(
                    color: colors.bg.layerFloating,
                    borderRadius: SeedBorderRadius.r5,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (header != null ||
                                title != null ||
                                description != null)
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  showCloseButton ? 52 : 24,
                                  16,
                                ),
                                child:
                                    header ??
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (title != null)
                                          Semantics(
                                            namesRoute: true,
                                            header: true,
                                            child: Text(
                                              title!,
                                              style: typography.t8Bold.copyWith(
                                                color: colors.fg.neutral,
                                              ),
                                            ),
                                          ),
                                        if (description != null) ...[
                                          if (title != null)
                                            const SizedBox(
                                              height: SeedDimension.x1_5,
                                            ),
                                          Text(
                                            description!,
                                            style: typography.t5Regular
                                                .copyWith(
                                                  color: colors.fg.neutralMuted,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                              )
                            else if (showCloseButton)
                              SizedBox(
                                height: math.min(
                                  65,
                                  math.min(maxHeight, constraints.maxHeight),
                                ),
                              ),
                            Flexible(
                              child: scrollBody
                                  ? SeedScrollArea(
                                      padding: bodyPadding,
                                      showFog: showScrollFog,
                                      fogOnlyWhenScrollable: true,
                                      focusableWhenScrollable: true,
                                      fogSize: 48,
                                      showScrolledDivider: true,
                                      child: content,
                                    )
                                  : content,
                            ),
                            if (effectiveFooter != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  16,
                                  24,
                                  24,
                                ),
                                child: effectiveFooter,
                              ),
                          ],
                        ),
                        if (showCloseButton)
                          Positioned(
                            // Icon starts at top 28/right 24; the 52px target
                            // extends 15px around the 22px icon, as in React.
                            top: 13,
                            right: 9,
                            child: Tooltip(
                              message: SeedLocalizations.label(
                                context,
                                SeedLabel.close,
                              ),
                              child: SeedPressable(
                                semanticsLabel: SeedLocalizations.label(
                                  context,
                                  SeedLabel.close,
                                ),
                                onTap: () => _closeSeedDialog(
                                  context,
                                  SeedOverlayDismissReason.closeButton,
                                ),
                                builder: (context, pressed) => Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: pressed
                                        ? colors.bg.transparentPressed
                                        : colors.bg.transparent,
                                    borderRadius: SeedBorderRadius.r3,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22,
                                    color: colors.fg.neutralSubtle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
