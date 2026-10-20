import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Standalone Snackbar component of SEED Design System.
class SeedSnackbar extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? prefixIcon;

  const SeedSnackbar({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

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
                      child: prefixIcon!,
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
              enableScale: false,
              onTap: onAction,
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
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();

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
