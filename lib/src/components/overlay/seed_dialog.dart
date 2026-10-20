import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../button/seed_button.dart';

/// Shows a standard SEED dialog.
Future<T?> showSeedDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: context.seedColor.bg.overlay,
    builder: (context) => child,
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
  bool barrierDismissible = true,
}) {
  return showSeedDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
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

  const SeedAlertDialog({
    super.key,
    required this.title,
    this.description,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.isCritical = false,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    return Center(
      child: Container(
        width: 272.0,
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        padding: const EdgeInsets.all(SeedDimension.x5),
        decoration: BoxDecoration(
          color: colors.bg.layerFloating,
          borderRadius: SeedBorderRadius.r5,
          boxShadow: shadows.s3,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: typography.t7Bold.copyWith(color: colors.fg.neutral),
                textAlign: TextAlign.start,
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
              const SizedBox(height: SeedDimension.x4),
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: SeedButton(
                        label: cancelText!,
                        variant: SeedButtonVariant.neutralWeak,
                        onPressed: () {
                          if (onCancel != null) {
                            onCancel!();
                          } else {
                            Navigator.of(context).pop(false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: SeedDimension.x2),
                  ],
                  Expanded(
                    child: SeedButton(
                      label: confirmText,
                      variant: isCritical
                          ? SeedButtonVariant.criticalSolid
                          : SeedButtonVariant.brandSolid,
                      onPressed: () {
                        if (onConfirm != null) {
                          onConfirm!();
                        } else {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    this.maxWidth = 480.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;
    final mediaQuery = MediaQuery.of(context);
    final double maxHeight = mediaQuery.size.height * 0.8;

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

    return Center(
      child: Container(
        width: mediaQuery.size.width * 0.9,
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colors.bg.layerFloating,
          borderRadius: SeedBorderRadius.r5,
          boxShadow: shadows.s3,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null)
                header!
              else if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title!,
                              style: typography.t8Bold.copyWith(
                                color: colors.fg.neutral,
                              ),
                            ),
                            if (description != null) ...[
                              const SizedBox(height: SeedDimension.x1_5),
                              Text(
                                description!,
                                style: typography.t5Regular.copyWith(
                                  color: colors.fg.neutralMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (showCloseButton)
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: colors.fg.neutralSubtle,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                    ],
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  child: content,
                ),
              ),
              if (effectiveFooter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: effectiveFooter,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
