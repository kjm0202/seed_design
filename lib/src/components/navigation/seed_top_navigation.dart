import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';

/// Top navigation bar component of SEED Design System.
///
/// Implements [PreferredSizeWidget] so it can be passed directly as
/// `appBar: SeedTopNavigation(...)` into Flutter [Scaffold].
class SeedTopNavigation extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBottomDivider;
  final Color? backgroundColor;

  const SeedTopNavigation({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.showBottomDivider = true,
    this.backgroundColor,
  }) : assert(title == null || titleText == null, 'Cannot provide both title and titleText');

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && canPop) {
      effectiveLeading = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20.0),
        color: colors.fg.neutral,
        onPressed: () => Navigator.maybePop(context),
      );
    }

    final Widget? effectiveTitle = titleText != null
        ? Text(
            titleText!,
            style: typography.t6Bold.copyWith(color: colors.fg.neutral),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : title;

    return Container(
      color: backgroundColor ?? colors.bg.layerDefault,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: preferredSize.height - (showBottomDivider ? 1.0 : 0.0),
              child: NavigationToolbar(
                leading: effectiveLeading != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: SeedDimension.x2),
                        child: effectiveLeading,
                      )
                    : null,
                middle: effectiveTitle,
                trailing: actions != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...actions!,
                          const SizedBox(width: SeedDimension.x2),
                        ],
                      )
                    : null,
                centerMiddle: centerTitle,
              ),
            ),
            if (showBottomDivider) const SeedDivider(),
          ],
        ),
      ),
    );
  }
}
