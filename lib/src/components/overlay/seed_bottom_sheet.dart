import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Shows a standard SEED Bottom Sheet.
Future<T?> showSeedBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    barrierColor: const Color(0x74000000), // bg.overlay
    builder: (context) => child,
  );
}

/// Bottom Sheet container component of SEED Design System.
class SeedBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? header;
  final Widget content;
  final Widget? footer;
  final bool showHandle;
  final bool showCloseButton;

  const SeedBottomSheet({
    super.key,
    this.title,
    this.header,
    required this.content,
    this.footer,
    this.showHandle = true,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
      // Paint the surface on Material so child ink effects remain visible.
      child: Material(
        color: colors.bg.layerFloating,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SeedRadius.r5),
          topRight: Radius.circular(SeedRadius.r5),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHandle)
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: SeedDimension.x2_5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.stroke.neutralWeak,
                      borderRadius: SeedBorderRadius.full,
                    ),
                  ),
                ),
              if (header != null)
                header!
              else if (title != null || showCloseButton)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SeedDimension.x4,
                    SeedDimension.x2,
                    SeedDimension.x2,
                    SeedDimension.x2,
                  ),
                  child: Row(
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: typography.t6Bold.copyWith(
                              color: colors.fg.neutral,
                            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: SeedDimension.x4,
                    vertical: SeedDimension.x2,
                  ),
                  child: content,
                ),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.all(SeedDimension.x4),
                  child: footer!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
