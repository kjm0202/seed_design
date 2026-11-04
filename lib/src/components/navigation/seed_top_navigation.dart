import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';
import 'seed_top_navigation_button.dart';

enum SeedTopNavigationPlatform {
  adaptive,
  cupertino,
  android,
}

typedef SeedTopNavigationTone = SeedTopNavigationButtonTone;

/// Top navigation bar component of SEED Design System.
///
/// Implements [PreferredSizeWidget] so it can be passed directly as
/// `appBar: SeedTopNavigation(...)` into Flutter [Scaffold].
class SeedTopNavigation extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;

  final Widget? slot;
  final String? titleText;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final TextScaler? titleTextScaler;
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
    this.slot,
    this.titleText,
    this.leading,
    this.actions,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.titleTextScaler,
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
       ),
       assert(
         slot == null ||
             (title == null &&
                 titleText == null &&
                 subtitle == null &&
                 subtitleWidget == null),
         'Cannot provide slot with title, titleText, subtitle or subtitleWidget',
       );

  @override
  Size get preferredSize =>
      Size.fromHeight(56.0 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    final cupertino =
        platform == SeedTopNavigationPlatform.cupertino ||
        (platform == SeedTopNavigationPlatform.adaptive &&
            Theme.of(context).platform == TargetPlatform.iOS);
    final bool effectiveCenterTitle = centerTitle ?? cupertino;
    final bool hasSubtitle = subtitle != null || subtitleWidget != null;
    final bool isTransparent = tone == SeedTopNavigationButtonTone.transparent;
    final TextScaler clampedScaler =
        titleTextScaler ?? MediaQuery.textScalerOf(context);
    final scaffold = Scaffold.maybeOf(context);

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null &&
        automaticallyImplyLeading &&
        scaffold?.hasDrawer == true) {
      effectiveLeading = const DrawerButton();
    } else if (effectiveLeading == null &&
        automaticallyImplyLeading &&
        canPop) {
      effectiveLeading = SeedTopNavigationIconButton(
        semanticsLabel: SeedLocalizations.label(context, SeedLabel.back),
        tone: tone,
        // The official AppBarBackButton is a chevron on every theme.
        icon: const Icon(Icons.chevron_left_rounded),
        onPressed: () => Navigator.maybePop(context),
      );
    }

    final effectiveActions =
        actions ??
        (automaticallyImplyLeading && scaffold?.hasEndDrawer == true
            ? const <Widget>[EndDrawerButton()]
            : null);

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
                height: 56.0 - (showBottomDivider ? 1.0 : 0.0),
                child: slot != null
                    ? _SeedAppBarSlotLayout(
                        slot: slot!,
                        leading: effectiveLeading,
                        actions: effectiveActions,
                      )
                    : NavigationToolbar(
                        leading: effectiveLeading != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  left: SeedDimension.x1_5,
                                ),
                                child: effectiveLeading,
                              )
                            : null,
                        middle: middleWidget,
                        trailing: effectiveActions != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...effectiveActions,
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
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}

class _SeedAppBarSlotLayout extends StatelessWidget {
  const _SeedAppBarSlotLayout({
    required this.slot,
    required this.leading,
    required this.actions,
  });

  final Widget slot;
  final Widget? leading;
  final List<Widget>? actions;
  static const double _buttonExtent = 44;
  static const double _iconExtent = 24;
  static const double _edgeOverlap = (_buttonExtent - _iconExtent) / 2;

  @override
  Widget build(BuildContext context) {
    final actionItems = actions ?? const <Widget>[];
    final leadingIsIcon =
        leading == null || leading is SeedTopNavigationIconButton;
    final actionsAreIcons = actionItems.every(
      (child) => child is SeedTopNavigationIconButton,
    );
    if (leadingIsIcon && actionsAreIcons) {
      final leadingFlexWidth = leading == null ? 0.0 : _iconExtent;
      final actionsFlexWidth = actionItems.isEmpty
          ? 0.0
          : _buttonExtent * actionItems.length - 2 * _edgeOverlap;

      // Root covers the ENTIRE AppBar for hit testing. Icons use physical
      // 44px touch targets and overlap the growing slot by 10px at each end.
      return SizedBox.expand(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            PositionedDirectional(
              start: SeedDimension.x4 + leadingFlexWidth,
              end: SeedDimension.x4 + actionsFlexWidth,
              top: 0,
              bottom: 0,
              child: slot,
            ),
            if (leading != null)
              PositionedDirectional(
                start: SeedDimension.x4 - _edgeOverlap,
                top: 0,
                bottom: 0,
                child: Center(child: leading),
              ),
            if (actionItems.isNotEmpty)
              PositionedDirectional(
                end: SeedDimension.x4 - _edgeOverlap,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actionItems,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Arbitrary non-icon widgets use their natural size; there is no official
    // AppBarIconButton negative margin to apply to those widgets.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
      child: Row(
        children: [
          ?leading,
          Expanded(child: slot),
          if (actionItems.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: actionItems),
        ],
      ),
    );
  }
}
