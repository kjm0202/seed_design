import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';

/// Shows a slide-over SEED Side Panel from the right or left edge.
Future<T?> showSeedSidePanel<T>({
  required BuildContext context,
  required String title,
  String? description,
  required Widget body,
  Widget? footer,
  bool fromRight = true,
  double width = 480.0,
  bool barrierDismissible = true,
}) {
  final capturedThemes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: true).context,
  );
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: context.seedColor.bg.overlay,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return capturedThemes.wrap(
        Align(
          alignment: fromRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Material(
            type: MaterialType.transparency,
            child: SeedSidePanel(
              title: title,
              description: description,
              body: body,
              footer: footer,
              width: width,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: SeedCurves.enterExpressive,
        reverseCurve: SeedCurves.exitExpressive,
      );
      final offset = fromRight ? const Offset(1, 0) : const Offset(-1, 0);
      return SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

/// A SEED Design Side Panel component for desktop/tablet slide-over drawers.
class SeedSidePanel extends StatelessWidget {
  const SeedSidePanel({
    super.key,
    required this.title,
    this.description,
    required this.body,
    this.footer,
    this.onClose,
    this.width = 480.0,
  });

  /// Panel title.
  final String title;

  /// Optional sub-description.
  final String? description;

  /// Main content widget.
  final Widget body;

  /// Optional footer with actions.
  final Widget? footer;

  /// Callback when close button is pressed.
  final VoidCallback? onClose;

  /// Width of the panel.
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    return Container(
      width: width,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
      ),
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.bg.layerFloating,
        boxShadow: shadows.s3,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                  if (onClose != null)
                    IconButton(
                      icon: Icon(Icons.close, color: colors.fg.neutralSubtle),
                      onPressed: onClose,
                      splashRadius: 20,
                    ),
                ],
              ),
            ),

            const SeedDivider(),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: body,
              ),
            ),

            // Footer
            if (footer != null) ...[
              const SeedDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
