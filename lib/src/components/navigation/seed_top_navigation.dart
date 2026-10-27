import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';
import 'seed_top_navigation_button.dart';

enum SeedTopNavigationPlatform { adaptive, cupertino, android }

typedef SeedTopNavigationTone = SeedTopNavigationButtonTone;

/// Top navigation bar component of SEED Design System.
///
/// Implements [PreferredSizeWidget] so it can be passed directly as
/// `appBar: SeedTopNavigation(...)` into Flutter [Scaffold].
class SeedTopNavigation extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final bool showBottomDivider;
  final Color? backgroundColor;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Gradient? backgroundGradient;
  final SeedTopNavigationPlatform platform;
  final SeedTopNavigationButtonTone tone;
  final bool gradient;

  const SeedTopNavigation({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.actions,
    this.centerTitle,
    this.showBottomDivider = false,
    this.backgroundColor,
    this.subtitle,
    this.subtitleWidget,
    this.backgroundGradient,
    this.platform = SeedTopNavigationPlatform.adaptive,
    this.tone = SeedTopNavigationButtonTone.layer,
    this.gradient = false,
  }) : assert(
         title == null || titleText == null,
         'Cannot provide both title and titleText',
       );

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    final cupertino =
        platform == SeedTopNavigationPlatform.cupertino ||
        (platform == SeedTopNavigationPlatform.adaptive &&
            (Theme.of(context).platform == TargetPlatform.iOS ||
                Theme.of(context).platform == TargetPlatform.macOS));
    final bool effectiveCenterTitle = centerTitle ?? cupertino;
    final bool hasSubtitle = subtitle != null || subtitleWidget != null;
    final bool isTransparent = tone == SeedTopNavigationButtonTone.transparent;
    final TextScaler clampedScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && canPop) {
      effectiveLeading = SeedTopNavigationIconButton(
        semanticsLabel: '뒤로',
        tone: tone,
        icon: Icon(
          cupertino
              ? Icons.arrow_back_ios_new_rounded
              : Icons.arrow_back_rounded,
        ),
        onPressed: () => Navigator.maybePop(context),
      );
    }

    final Color titleColor = isTransparent
        ? SeedPalette.staticWhite
        : colors.fg.neutral;
    final Color subtitleColor = isTransparent
        ? SeedPalette.staticWhite
        : colors.fg.neutralMuted;

    final Widget? effectiveTitle = titleText != null
        ? Text(
            titleText!,
            textScaler: clampedScaler,
            style: (hasSubtitle ? typography.t5Bold : typography.t6Bold)
                .copyWith(color: titleColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : title;

    final Gradient? effectiveGradient =
        backgroundGradient ??
        (isTransparent && gradient
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x59000000), Color(0x00000000)],
              )
            : null);

    final Color effectiveBgColor =
        backgroundColor ??
        (isTransparent ? colors.bg.transparent : colors.bg.layerDefault);

    Widget? middleWidget = hasSubtitle
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: effectiveCenterTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              ?effectiveTitle,
              subtitleWidget ??
                  Text(
                    subtitle!,
                    textScaler: clampedScaler,
                    style: typography.t2Regular.copyWith(color: subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ],
          )
        : effectiveTitle;

    if (!effectiveCenterTitle &&
        effectiveLeading == null &&
        middleWidget != null) {
      middleWidget = Padding(
        padding: const EdgeInsets.only(left: SeedDimension.x3),
        child: middleWidget,
      );
    }

    return SeedTopNavigationScope(
      tone: tone,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveGradient == null ? effectiveBgColor : null,
          gradient: effectiveGradient,
        ),
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
                          padding: const EdgeInsets.only(
                            left: SeedDimension.x1_5,
                          ),
                          child: effectiveLeading,
                        )
                      : null,
                  middle: middleWidget,
                  trailing: actions != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...actions!,
                            const SizedBox(width: SeedDimension.x1_5),
                          ],
                        )
                      : null,
                  centerMiddle: effectiveCenterTitle,
                  middleSpacing: effectiveCenterTitle
                      ? SeedDimension.x2
                      : SeedDimension.x1_5,
                ),
              ),
              if (showBottomDivider) const SeedDivider(),
            ],
          ),
        ),
      ),
    );
  }
}
