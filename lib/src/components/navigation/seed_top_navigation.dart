import 'dart:math' as math;

import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';
import 'seed_top_navigation_button.dart';

/// Selects how [SeedTopNavigation] aligns its title by default.
enum SeedTopNavigationPlatform {
  /// Centers titles on iOS and left-aligns them on other platforms.
  adaptive,

  /// Uses centered iOS-style title alignment regardless of host platform.
  cupertino,

  /// Uses left-aligned Android-style titles regardless of host platform.
  android,
}

/// Compatibility name for [SeedTopNavigationButtonTone].
typedef SeedTopNavigationTone = SeedTopNavigationButtonTone;

/// Top navigation bar component of SEED Design System.
///
/// Implements [PreferredSizeWidget] so it can be passed directly as
/// `appBar: SeedTopNavigation(...)` into Flutter [Scaffold].
class SeedTopNavigation extends StatelessWidget implements PreferredSizeWidget {
  /// Custom title widget, mutually exclusive with [titleText] and [slot].
  final Widget? title;

  /// A custom, growing AppBar.Slot between the leading and trailing areas.
  /// Unlike [title], [slot] uses the official Stackflow AppBar flex geometry
  /// rather than the centered-title NavigationToolbar geometry.
  final Widget? slot;

  /// Text title rendered in SEED typography; mutually exclusive with [title].
  final String? titleText;

  /// Leading action; overrides automatic drawer and back actions.
  final Widget? leading;

  /// Trailing actions; null permits an automatic end-drawer action.
  final List<Widget>? actions;

  /// Title alignment override; null follows the selected [platform].
  final bool? centerTitle;

  /// Infers a drawer, back, or end-drawer button when possible; defaults true.
  final bool automaticallyImplyLeading;

  /// Additional preferred-size widget placed below the 56-pixel bar.
  final PreferredSizeWidget? bottom;

  /// Text-scaling override for [titleText] and [subtitle]. By default the
  /// ambient scaler is clamped to 1.0-1.2, as React's app bar CSS clamps the
  /// title and subtitle font sizes so they fit the fixed bar height.
  final TextScaler? titleTextScaler;

  /// Draws a bottom divider inside the 56-pixel bar; defaults false.
  final bool showBottomDivider;

  /// Explicit bar background color, used when no gradient takes priority.
  final Color? backgroundColor;

  /// Optional text subtitle, mutually exclusive with [slot].
  final String? subtitle;

  /// Custom subtitle content, used before [subtitle] when both are supplied.
  final Widget? subtitleWidget;

  /// Explicit background gradient, overriding the optional tone gradient.
  final Gradient? backgroundGradient;

  /// Adaptive title-layout policy; defaults to [SeedTopNavigationPlatform.adaptive].
  final SeedTopNavigationPlatform platform;

  /// Surface/foreground tone inherited by top-navigation buttons.
  final SeedTopNavigationButtonTone tone;

  /// Enables the built-in fade gradient in transparent tone; defaults false.
  final bool gradient;

  /// Constructs a SEED top navigation bar suitable for `Scaffold.appBar`.
  ///
  /// [title] and [titleText] cannot be provided together. [slot] implements
  /// the React Stackflow `AppBar.Slot` flex region and cannot be combined with
  /// either title or [subtitle]/[subtitleWidget]. [leading] and [actions] take
  /// precedence over automatically inferred actions. [bottom] contributes to
  /// [preferredSize]; [showBottomDivider] adds a visible hairline divider.
  /// [platform], [centerTitle], and [titleTextScaler] control title layout;
  /// [tone], [backgroundColor], [backgroundGradient], and [gradient] control
  /// the bar's background and action colors. An optional `key` preserves
  /// Flutter widget identity.
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
  /// Bar height (56 logical pixels) plus the optional [bottom] height.
  Size get preferredSize =>
      Size.fromHeight(56.0 + (bottom?.preferredSize.height ?? 0));

  @override
  /// Builds the bar using the inherited theme and current Navigator state.
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
        titleTextScaler ??
        MediaQuery.textScalerOf(context)
            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);
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
                        android: !cupertino,
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

/// React Stackflow `AppBar` geometry around a custom `AppBar.Slot`.
///
/// The bar has 16px root padding. `.seed-app-bar__iconButton` and
/// `.seed-app-bar__textButton` get `margin-left/right: -10px` as the first or
/// last child of the left/right areas (icon: `(44 - 24) / -2`; text button:
/// `x1_5 - x4`), so their padded boxes overhang the padding and the slot. The
/// android theme adds `.seed-app-bar__left { padding-right: 16px }`. Other
/// widgets get no margin, like arbitrary DOM children.
///
/// The layout covers the whole bar so the overhanging parts of the 44px
/// buttons stay hit-testable; an OverflowBox inside a narrow Row would paint
/// them correctly but drop pointer hits on the overhang. Buttons are painted
/// (and hit-tested) above the slot.
class _SeedAppBarSlotLayout extends StatelessWidget {
  const _SeedAppBarSlotLayout({
    required this.slot,
    required this.leading,
    required this.actions,
    required this.android,
  });

  final Widget slot;
  final Widget? leading;
  final List<Widget>? actions;
  final bool android;

  static double _edgeMargin(Widget child) =>
      child is SeedTopNavigationIconButton ||
          child is SeedTopNavigationTextButton
      ? SeedDimension.x2_5
      : 0;

  @override
  Widget build(BuildContext context) {
    final actionItems = actions ?? const <Widget>[];
    return CustomMultiChildLayout(
      delegate: _SeedAppBarSlotDelegate(
        textDirection: Directionality.of(context),
        leadingMargin: leading == null ? 0 : _edgeMargin(leading!),
        leadingPaddingEnd: leading != null && android ? SeedDimension.x4 : 0,
        actionsStartMargin: actionItems.isEmpty
            ? 0
            : _edgeMargin(actionItems.first),
        actionsEndMargin: actionItems.isEmpty
            ? 0
            : _edgeMargin(actionItems.last),
      ),
      children: [
        LayoutId(id: _SeedAppBarSlotPart.slot, child: slot),
        if (leading != null)
          LayoutId(id: _SeedAppBarSlotPart.leading, child: leading!),
        if (actionItems.isNotEmpty)
          LayoutId(
            id: _SeedAppBarSlotPart.actions,
            child: Row(mainAxisSize: MainAxisSize.min, children: actionItems),
          ),
      ],
    );
  }
}

enum _SeedAppBarSlotPart { leading, slot, actions }

class _SeedAppBarSlotDelegate extends MultiChildLayoutDelegate {
  _SeedAppBarSlotDelegate({
    required this.textDirection,
    required this.leadingMargin,
    required this.leadingPaddingEnd,
    required this.actionsStartMargin,
    required this.actionsEndMargin,
  });

  final TextDirection textDirection;

  /// Negative CSS margin on both sides of the single leading child.
  final double leadingMargin;
  final double leadingPaddingEnd;
  final double actionsStartMargin;
  final double actionsEndMargin;

  static const double _padding = SeedDimension.x4;

  @override
  void performLayout(Size size) {
    final contentWidth = math.max(0.0, size.width - 2 * _padding);
    final height = size.height;
    double startExtent = 0;
    double endExtent = 0;

    // Positions are measured from the start edge, then mirrored for RTL.
    void place(Object id, double start, Size child, {bool center = true}) {
      final x = textDirection == TextDirection.ltr
          ? start
          : size.width - start - child.width;
      positionChild(id, Offset(x, center ? (height - child.height) / 2 : 0));
    }

    if (hasChild(_SeedAppBarSlotPart.leading)) {
      final child = layoutChild(
        _SeedAppBarSlotPart.leading,
        BoxConstraints.loose(Size(contentWidth + 2 * leadingMargin, height)),
      );
      startExtent = math.max(
        0.0,
        child.width - 2 * leadingMargin + leadingPaddingEnd,
      );
      place(_SeedAppBarSlotPart.leading, _padding - leadingMargin, child);
    }
    if (hasChild(_SeedAppBarSlotPart.actions)) {
      final child = layoutChild(
        _SeedAppBarSlotPart.actions,
        BoxConstraints.loose(
          Size(
            math.max(
              0.0,
              contentWidth -
                  startExtent +
                  actionsStartMargin +
                  actionsEndMargin,
            ),
            height,
          ),
        ),
      );
      endExtent = math.max(
        0.0,
        child.width - actionsStartMargin - actionsEndMargin,
      );
      place(
        _SeedAppBarSlotPart.actions,
        size.width - _padding + actionsEndMargin - child.width,
        child,
      );
    }
    final slotWidth = math.max(0.0, contentWidth - startExtent - endExtent);
    final slot = layoutChild(
      _SeedAppBarSlotPart.slot,
      BoxConstraints.tightFor(width: slotWidth, height: height),
    );
    place(
      _SeedAppBarSlotPart.slot,
      _padding + startExtent,
      slot,
      center: false,
    );
  }

  @override
  bool shouldRelayout(_SeedAppBarSlotDelegate oldDelegate) =>
      textDirection != oldDelegate.textDirection ||
      leadingMargin != oldDelegate.leadingMargin ||
      leadingPaddingEnd != oldDelegate.leadingPaddingEnd ||
      actionsStartMargin != oldDelegate.actionsStartMargin ||
      actionsEndMargin != oldDelegate.actionsEndMargin;
}
