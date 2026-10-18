import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
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
  double width = 380.0,
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
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 250),
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
        curve: Curves.easeOutCubic,
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
    this.width = 380.0,
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
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.bg.layerDefault,
        boxShadow: shadows.s3,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SeedDimension.x5,
                vertical: SeedDimension.x4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: typography.t7Bold.copyWith(
                            color: colors.fg.neutral,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: SeedDimension.x1),
                          Text(
                            description!,
                            style: typography.t4Regular.copyWith(
                              color: colors.fg.neutralSubtle,
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
                padding: const EdgeInsets.all(SeedDimension.x5),
                child: body,
              ),
            ),

            // Footer
            if (footer != null) ...[
              const SeedDivider(),
              Padding(
                padding: const EdgeInsets.all(SeedDimension.x4),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
