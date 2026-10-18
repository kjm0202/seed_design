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
    final shadows = context.seedShadows;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SeedDimension.x4,
        vertical: SeedDimension.x3,
      ),
      decoration: BoxDecoration(
        color: colors.bg.neutralInverted,
        borderRadius: SeedBorderRadius.r3,
        boxShadow: shadows.s2,
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: SeedDimension.x2),
          ],
          Expanded(
            child: Text(
              message,
              style: typography.t3Regular.copyWith(
                color: colors.fg.neutralInverted,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: SeedDimension.x3),
            SeedPressable(
              semanticsLabel: actionLabel,
              enableScale: false,
              onTap: onAction,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Center(
                  child: Text(
                    actionLabel!,
                    style: typography.t3Bold.copyWith(color: colors.fg.brand),
                  ),
                ),
              ),
            ),
          ],
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
      margin: const EdgeInsets.all(SeedDimension.x4),
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
