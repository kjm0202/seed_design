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

/// Shows a standard SEED dialog, with independent outside/Escape policies.
Future<T?> showSeedDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  bool closeOnEscape = true,
  ValueChanged<SeedOverlayDismissReason>? onDismissed,
}) {
  final route = _SeedDialogRoute<T>(
    context: context,
    child: child,
    dismissible: barrierDismissible,
    closeOnEscape: closeOnEscape,
  );
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push<T>(route).whenComplete(() => onDismissed?.call(route.reason));
}

class _SeedDialogRoute<T> extends DialogRoute<T> {
  _SeedDialogRoute({
    required super.context,
    required Widget child,
    required bool dismissible,
    required bool closeOnEscape,
  }) : reduceMotion = MediaQuery.disableAnimationsOf(context),
       super(
         barrierDismissible: dismissible,
         barrierColor: context.seedColor.bg.overlay,
         themes: InheritedTheme.capture(
           from: context,
           to: Navigator.of(context, rootNavigator: true).context,
         ),
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
           child: Focus(autofocus: true, child: child),
         ),
       );
  final bool reduceMotion;
  SeedOverlayDismissReason reason = SeedOverlayDismissReason.programmatic;
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
    color: animation!.drive(
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

/// Shows a standard SEED Alert Dialog.
Future<bool?> showSeedAlertDialog({
  required BuildContext context,
  required String title,
  String? description,
  String confirmText = '확인',
  String? cancelText = '취소',
  bool isCritical = false,
  bool barrierDismissible = false,
  bool closeOnEscape = true,
}) {
  return showSeedDialog<bool>(
    context: context,
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

/// Alert Dialog component of SEED Design System.
class SeedAlertDialog extends StatelessWidget {
  final String title;
  final String? description;
  final String confirmText;
  final String? cancelText;
  final bool isCritical;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? header, body, footer;

  const SeedAlertDialog({
    super.key,
    required this.title,
    this.description,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.isCritical = false,
    this.onConfirm,
    this.onCancel,
    this.header,
    this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

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
              boxShadow: shadows.s3,
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
                              label: cancelText!,
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

enum SeedDialogSize { medium, large }

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

/// Dialog component of SEED Design System with Header, Content, and Footer.
class SeedDialog extends StatelessWidget {
  final Widget? header;
  final String? title;
  final String? description;
  final Widget content;
  final Widget? footer;
  final Widget? subAction;
  final Widget? secondaryAction;
  final Widget? primaryAction;
  final bool showCloseButton;
  final double maxWidth;
  final bool _hasCustomMaxWidth;
  final SeedDialogSize size;
  final double? maxHeight;
  final bool scrollBody, showScrollFog;
  final EdgeInsetsGeometry bodyPadding;

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
    final shadows = context.seedShadows;
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
                    boxShadow: shadows.s3,
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
                              message: '닫기',
                              child: SeedPressable(
                                semanticsLabel: '닫기',
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
                                    shape: BoxShape.circle,
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
