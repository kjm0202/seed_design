import 'dart:math' as math;

import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart'
    show
        Drag,
        DragEndDetails,
        DragStartDetails,
        DragUpdateDetails,
        PointerScrollEvent;
import 'package:flutter/rendering.dart' show RenderAbstractViewport;

import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'display_pages.dart';
import 'extra_pages.dart';
import 'forms_pages.dart';
import 'navigation_pages.dart';
import 'overlay_pages.dart';
import 'screen_pages.dart';
import 'spa_catalog.dart';
import 'spa_paths.dart';
import 'spa_types.dart';
import 'spa_routes.dart';
import 'spa_material_theme.dart';
import 'spa_history.dart';
import 'demo_pages.dart';
import 'plugin_basic_browser_stub.dart'
    if (dart.library.js_interop) 'plugin_basic_browser_web.dart'
    as plugin_basic_browser;

bool _pluginBasicUiCupertino(
  BuildContext context, {
  String? debugBrowserUserAgentOverride,
}) {
  // Native: stub returns null and Theme.platform remains authoritative.
  // Web: the same UA heuristic as official stackflow/theme.ts controls this
  // route's *plugin* AppBar. Do not let Flutter's engine platform override it.
  final browserUserAgent =
      debugBrowserUserAgentOverride ??
      plugin_basic_browser.readBrowserUserAgent();
  if (browserUserAgent != null) {
    return RegExp(
      r'iphone|ipad|ipod',
      caseSensitive: false,
    ).hasMatch(browserUserAgent);
  }
  // Native Flutter has no browser UA; retain the existing adaptive platform.
  return Theme.of(context).platform == TargetPlatform.iOS;
}

// The React SPA styles body with bg.layerDefault (global.css). Restrict this
// fallback to the example; the library's public scaffold default is unchanged.
ThemeData _spaTheme(SeedThemeData seed) {
  final theme = seed.toThemeData();
  return theme.copyWith(
    scaffoldBackgroundColor: seed.colorScheme.bg.layerDefault,
    // React's unstyled 16px Wanted Sans body text uses a 20px line box in
    // Chromium ("normal"); the 19px Flutter approximation shortened a
    // two-line PopoverBody by 2px. Keep the correction in the SPA fixture.
    textTheme: theme.textTheme.copyWith(
      bodyMedium: theme.textTheme.bodyLarge?.copyWith(
        height: 20 / 16,
        color: seed.colorScheme.isDark ? Colors.white : Colors.black,
      ),
    ),
  );
}

// React screens without AppBarLeft, whose root titles stay at the page gutter.
const _activitiesWithoutAppBarLeft = {
  'ActivityAlertDialogStep',
  'ActivityBottomSheetStep',
  'ActivityMenuSheetStep',
  'ActivityArticlePreventDrag',
  'ActivityArticlePreventPull',
  'ActivityPullToRefreshPreventPull',
  'ActivityPullToRefreshPreview',
  'ActivityPullToRefreshTabs',
  'ActivityResultSectionCtaProgressCircle',
};

// React screens that show no Home action in their AppBar.
const _activitiesWithoutHomeAction = {
  'ActivityForm',
  'ActivityArticlePreventDrag',
  'ActivityArticlePreventPull',
  'ActivityBottomSheetWithAlertDialogStep',
  'ActivityE2ETextareaAutoresizeScroll',
  'ActivityFontMultiplierLayout',
  'ActivityPagination',
  'ActivityPullToRefreshPreventPull',
  'ActivityPullToRefreshPreview',
  'ActivityPullToRefreshTabs',
  'ActivityResultSection',
  'ActivityResultSectionCtaProgressCircle',
  'ActivitySafeAreaBleed',
  'ActivitySelect',
  'ActivitySwipeBackKeyboard',
  'ActivityTypographyScale',
};

/// Standalone example of the React Stackflow SPA, using Flutter's Navigator
/// to support named routes, push/replace/pop and the native back gesture.
class StackflowSpaApp extends StatefulWidget {
  const StackflowSpaApp({
    super.key,
    this.onBrowserBack,
    this.debugBrowserUserAgentOverride,
  });

  /// Test hook for the SPA browser-back command; production web uses the
  /// conditional history bridge and native Flutter uses route replacement.
  final VoidCallback? onBrowserBack;

  /// Example-only test seam: model a browser userAgent independently from
  /// Flutter's engine platform in widget tests without launching Chrome.
  /// Production routes read the real UA and never set this parameter.
  final String? debugBrowserUserAgentOverride;

  @override
  State<StackflowSpaApp> createState() => _StackflowSpaAppState();
}

class _StackflowSpaAppState extends State<StackflowSpaApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);
  SeedSnackbarController _snackbarController = SeedSnackbarController(
    strategy: SeedSnackbarStrategy.immediate,
  );
  late final _history = SpaHistoryDelegate(
    onGenerateRoute: _generateRoute,
    onBrowserBack: widget.onBrowserBack,
    onExternalUrlNavigation: _resetExternalSnackbar,
  );

  void _resetExternalSnackbar() {
    if (!mounted) return;
    final oldController = _snackbarController;
    // Replacing just the controller leaves the actual Navigator/Activity
    // tree mounted while discarding an old paused/hovered toast and queue.
    setState(() {
      _snackbarController = SeedSnackbarController(
        strategy: SeedSnackbarStrategy.immediate,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode.value = mode);
  }

  @override
  void dispose() {
    _history.dispose();
    _snackbarController.dispose();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SEED Design Stackflow SPA',
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerDelegate: _history,
      routeInformationParser: const SpaHistoryParser(),
      debugShowCheckedModeBanner: false,
      theme: _spaTheme(SeedThemeData.light(fontFamily: 'WantedSans')),
      darkTheme: _spaTheme(SeedThemeData.dark(fontFamily: 'WantedSans')),
      themeMode: _themeMode.value,
      builder: (context, child) => flutter_material.Localizations.override(
        context: context,
        delegates: const [
          flutter_localizations.GlobalMaterialLocalizations.delegate,
        ],
        child: flutter_material.Theme(
          data: spaMaterialTheme(Theme.of(context)),
          child: flutter_material.Material(
            type: flutter_material.MaterialType.transparency,
            child: SeedSnackbarProvider(
              controller: _snackbarController,
              strategy: SeedSnackbarStrategy.immediate,
              // Root modal Activities have no page beneath their backdrop.
              child: ColoredBox(
                color: context.seedColor.bg.layerDefault,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final routeUri = Uri.tryParse(settings.name ?? '/');
    final rawPath = routeUri?.path ?? '/';
    final requested = rawPath.length > 1 && rawPath.endsWith('/')
        ? rawPath.substring(0, rawPath.length - 1)
        : rawPath;
    final activity = spaPathActivities[requested] ?? 'ActivityNotFound';
    final Object? arguments = switch (activity) {
      'ActivityDemoArticleDetail' when settings.arguments == null =>
        int.tryParse(routeUri?.queryParameters['articleId'] ?? ''),
      'ActivityTransitionStyle' when settings.arguments == null =>
        routeUri?.queryParameters['transitionStyle'] != null
            ? <String, String>{
                'transitionStyle':
                    routeUri!.queryParameters['transitionStyle']!,
              }
            : null,
      _ => settings.arguments,
    };
    final page = _SpaActivityPage(
      activity: activity,
      arguments: arguments,
      themeMode: _themeMode,
      onThemeModeChanged: _setThemeMode,
      browserUserAgentOverride: widget.debugBrowserUserAgentOverride,
    );
    if (spaModalActivities.contains(activity)) {
      // The activity only hosts an independently animated sheet/dialog. An
      // opaque page beneath that modal would hide every retained parent layer.
      return PageRouteBuilder<Object?>(
        settings: settings,
        opaque: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => page,
      );
    }
    final platform = Theme.of(context).platform;
    // React's theme.ts: cupertino on iPhone/iPad, android everywhere else.
    final Object? requestedStyle =
        (arguments is Map ? arguments['transitionStyle'] : null) ??
        (platform == TargetPlatform.iOS
            ? 'slideFromRightIOS'
            : 'fadeFromBottomAndroid');
    if (requestedStyle == 'slideFromRightIOS') {
      return SpaCupertinoRoute<Object?>(
        settings: settings,
        builder: (_) => page,
      );
    }
    if (requestedStyle is String) {
      return PageRouteBuilder<Object?>(
        settings: settings,
        transitionDuration: Duration(
          milliseconds: platform == TargetPlatform.iOS ? 350 : 300,
        ),
        reverseTransitionDuration: Duration(
          milliseconds: platform == TargetPlatform.iOS ? 350 : 300,
        ),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return switch (requestedStyle) {
            'fadeIn' => FadeTransition(opacity: curved, child: child),
            'fadeFromBottomAndroid' => SpaActivityDim(
              animation: animation,
              gradient: true,
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              ),
            ),
            _ => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          };
        },
      );
    }
    return MaterialPageRoute<Object?>(settings: settings, builder: (_) => page);
  }
}

class _SpaActivityPage extends StatelessWidget {
  const _SpaActivityPage({
    required this.activity,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.browserUserAgentOverride,
    this.arguments,
  });

  final String activity;
  final Object? arguments;
  final ValueListenable<ThemeMode> themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final String? browserUserAgentOverride;

  @override
  Widget build(BuildContext context) {
    void navigate(String target, {Object? arguments}) {
      final route = spaActivityPaths[target];
      if (route == null) return;
      if (target == 'ActivitySideNavigation') {
        // React ActivityHome replaces the current Activity for this entry.
        Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
      } else {
        Navigator.of(context).pushNamed(route, arguments: arguments);
      }
    }

    void goHome() {
      Navigator.of(context).pushNamed('/');
    }

    void goBack() => Navigator.of(context).maybePop();

    if (activity == 'ActivityHome') {
      return _SpaHomePage(
        navigate: navigate,
        themeMode: themeMode,
        onThemeModeChanged: onThemeModeChanged,
        depth: Navigator.of(context).widget.observers
            .whereType<SpaGestureObserver>()
            .first
            .activityIndex,
      );
    }

    if (activity == 'ActivityDemoHome') {
      return SpaDemoHomePage(navigate: navigate);
    }

    if (activity == 'ActivityDemoArticleDetail') {
      return SpaArticleDetailPage(
        articleId: arguments is int ? arguments as int : null,
        goBack: goBack,
      );
    }

    if (activity == 'ActivityNotFound') {
      return Scaffold(
        backgroundColor: context.seedColor.bg.layerDefault,
        appBar: SeedTopNavigation(
          title: spaHasEmptyAppBarLeft(context)
              ? spaRootTitle(context, 'Error')
              : null,
          titleText: spaHasEmptyAppBarLeft(context) ? null : 'Error',
          actions: [
            SeedTopNavigationIconButton(
              icon: const Icon(Icons.home_outlined),
              semanticsLabel: 'Home',
              onPressed: goHome,
            ),
          ],
        ),
        body: const Align(
          alignment: AlignmentDirectional.topStart,
          child: Text('404 Not Found'),
        ),
      );
    }

    final Widget? body =
        buildFormsPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildNavigationPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildOverlayPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildDisplayPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildScreenPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildExtraPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        );

    if (body is SpaOwnScaffold) return body;
    if (activity == 'ActivitySideNavigation') {
      return Scaffold(
        backgroundColor: context.seedColor.bg.layerDefault,
        body: body,
      );
    }

    final titleString = activity == 'ActivityDetail' && arguments is Map
        ? ((arguments as Map)['title'] as String? ?? '')
        : activity == 'ActivityDetail'
        ? ''
        : activity == 'ActivityTransitionStyle'
        ? (arguments is Map
                  ? (arguments as Map)['transitionStyle'] as String?
                  : null) ??
              'Transition Styles'
        : activity == 'ActivityMannerTempLevel'
        ? 'MannerTempLevel'
        : activity == 'ActivityPluginBasicUI'
        ? 'Random Long Title Hello World'
        : activity == 'ActivityAvatarStack'
        ? 'Avatar'
        : activity == 'ActivityTimePicker'
        ? 'TimePicker'
        : activity == 'ActivityTabsAutoHeightLazy'
        ? 'Tabs AutoHeight + LazyMount'
        : activity == 'ActivityChipTabsScrollFog'
        ? 'ChipTabs ScrollFog + LazyMount'
        : activity == 'ActivityAlertDialogActivity' ||
              activity == 'ActivityBottomSheetActivity'
        ? 'Activity'
        : activity == 'ActivitySidePanelActivity'
        ? 'Side Panel Activity'
        : activity == 'ActivityForm'
        ? 'Form Components'
        : activity == 'ActivityPartialDarkMode'
        ? 'Partial Dark Mode'
        : spaActivityTitle(activity);
    final centered = activity == 'ActivitySwipeBackKeyboard';
    final insetTitle =
        !centered &&
        !_activitiesWithoutAppBarLeft.contains(activity) &&
        spaHasEmptyAppBarLeft(context);
    // @stackflow/plugin-basic-ui has its own light surface in every mode.
    final lightSurface = activity == 'ActivityPluginBasicUI';
    final bar = SeedTopNavigation(
      title: insetTitle
          ? spaRootTitle(
              context,
              titleString,
              color: lightSurface
                  ? SeedThemeData.light().colorScheme.fg.neutral
                  : null,
            )
          : null,
      titleText: insetTitle ? null : titleString,
      centerTitle: centered ? true : null,
      actions: [
        if (activity == 'ActivityPartialDarkMode')
          for (var i = 0; i < 2; i++)
            SeedTopNavigationIconButton(
              icon: const Icon(Icons.notifications_none),
              semanticsLabel: 'Notification ${i + 1}',
              onPressed: () {},
            ),
        if (!_activitiesWithoutHomeAction.contains(activity))
          SeedTopNavigationIconButton(
            icon: const Icon(Icons.home_outlined),
            // Official AppBarIconButton aria-label: "Home" everywhere except
            // ActivityScaleFeedback.tsx, which uses "홈".
            semanticsLabel: activity == 'ActivityScaleFeedback' ? '홈' : 'Home',
            onPressed: goHome,
          ),
      ],
    );
    // The official basicUIPlugin({theme}) uses an independent AppBar recipe:
    // 2.75rem/44px on iOS, 3.5rem/56px on Android. SeedTopNavigation is a
    // distinct SEED AppBar recipe with a fixed 56px public contract, so only
    // this plugin activity uses a route-local 44px toolbar on iOS.
    final pluginCupertino =
        lightSurface &&
        _pluginBasicUiCupertino(
          context,
          debugBrowserUserAgentOverride: browserUserAgentOverride,
        );
    final PreferredSizeWidget effectiveBar = pluginCupertino
        ? flutter_material.AppBar(
            toolbarHeight: 44,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF212124),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Random Long Title Hello World',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212124),
              ),
            ),
            // basicUIPlugin's renderBackButton() returns null for isRoot.
            leading: ModalRoute.of(context)?.isFirst == false
                ? flutter_material.IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: goBack,
                  )
                : null,
            actions: [
              flutter_material.IconButton(
                tooltip: 'Home',
                icon: const Icon(Icons.home_rounded),
                onPressed: goHome,
              ),
            ],
          )
        : bar;
    final actualBody =
        body ??
        SeedResultSection(
          asset: const Icon(Icons.search_off_rounded, size: 44),
          title: '구현되지 않은 예제입니다.',
          description: '해당 Activity의 Flutter 화면이 아직 구현되지 않았습니다.',
          primaryActionLabel: '홈으로',
          onPrimaryAction: goHome,
        );
    // Stackflow renders the app bar after the content, so Tab reaches it last.
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Scaffold(
        backgroundColor: lightSurface ? Colors.white : null,
        appBar: PreferredSize(
          preferredSize: effectiveBar.preferredSize,
          child: FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: FocusTraversalGroup(
              child: lightSurface && !pluginCupertino
                  ? SeedTheme(
                      data: SeedThemeData.light(
                        fontFamily: context.seedTypography.t5Regular.fontFamily,
                      ),
                      child: effectiveBar,
                    )
                  : effectiveBar,
            ),
          ),
        ),
        body: FocusTraversalOrder(
          order: const NumericFocusOrder(1),
          child: FocusTraversalGroup(
            child: flutter_material.Material(
              type: flutter_material.MaterialType.transparency,
              child:
                  (activity == 'ActivitySafeAreaBleed' ||
                      activity == 'ActivityTransparentBar')
                  // These two recipes intentionally render a full-bleed
                  // background and apply their own inset to foreground text.
                  ? actualBody
                  : SafeArea(
                      left: true,
                      right: true,
                      top: false,
                      bottom: false,
                      child: actualBody,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaHomePage extends StatefulWidget {
  const _SpaHomePage({
    required this.navigate,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.depth,
  });

  final SpaNavigate navigate;
  final ValueListenable<ThemeMode> themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int depth;

  @override
  State<_SpaHomePage> createState() => _SpaHomePageState();
}

// The CSS grid stretches each cell to the tallest card in its row. Wrap does
// not, so geometry is grouped into rows before emulating per-cell CSS sticky.
class _SpaSectionBounds {
  const _SpaSectionBounds({
    required this.index,
    required this.top,
    required this.bottom,
    required this.left,
    required this.width,
    required this.titleTop,
    required this.titleHeight,
  });
  final int index;
  final double top;
  final double bottom;
  final double left;
  final double width;
  final double titleTop;
  final double titleHeight;
}

class _SpaPinnedHeading {
  const _SpaPinnedHeading(this.index, this.left, this.width, this.top);
  final int index;
  final double left;
  final double width;
  final double top;
}

// React ActivityHome.tsx:599-622 attaches a rounded-top mask to each sticky
// title. Only the two outside corner wedges are opaque; the center stays
// transparent so the scrolled card content is not covered by a 14px strip.
class _SpaStickyCornerWedgesPainter extends CustomPainter {
  const _SpaStickyCornerWedgesPainter(this.background);
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(SeedDimension.x3_5, size.width / 2);
    if (radius <= 0) return;
    final paint = Paint()..color = background;
    final left = Path()
      ..moveTo(0, 0)
      ..lineTo(radius, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        -math.pi / 2,
        -math.pi / 2,
        false,
      )
      ..close();
    final right = Path()
      ..moveTo(size.width - radius, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, radius)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(size.width - radius, radius),
          radius: radius,
        ),
        0,
        -math.pi / 2,
        false,
      )
      ..close();
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant _SpaStickyCornerWedgesPainter oldDelegate) =>
      oldDelegate.background != background;
}

class _SpaHomePageState extends State<_SpaHomePage> {
  final ScrollController _scroll = ScrollController();
  final ScrollController _chipScroll = ScrollController();
  Drag? _pinnedHeadingDrag;
  final GlobalKey _viewportKey = GlobalKey();
  final GlobalKey _chipRowKey = GlobalKey();
  final List<GlobalKey> _chipKeys = List.generate(
    spaSections.length,
    (_) => GlobalKey(),
  );
  final List<GlobalKey> _sectionKeys = List.generate(
    spaSections.length,
    (_) => GlobalKey(),
  );
  final List<GlobalKey> _titleKeys = List.generate(
    spaSections.length,
    (_) => GlobalKey(),
  );
  int _selectedSection = 0;
  bool _isJumping = false;
  bool _layoutMeasureQueued = false;
  double _stripHeight = 52;
  // CSS Grid's default align-items:stretch makes every cell in a row as tall
  // as its tallest sibling. Wrap computes row height but does not stretch its
  // children; preserve each section's natural height for sticky measurement
  // and give the cell an independently measured row minimum height.
  List<double> _gridRowMinHeights = const [];
  List<_SpaPinnedHeading> _pinnedHeadings = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateSelectedSection();
    });
    // Offset listeners run before layout, when sections report old positions.
    _scroll.addListener(
      () => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateSelectedSection();
      }),
    );
  }

  @override
  void dispose() {
    _pinnedHeadingDrag?.cancel();
    _scroll.dispose();
    _chipScroll.dispose();
    super.dispose();
  }

  // A descendant may change its intrinsic size without rebuilding Home (for
  // example when an async font or the inherited text scaler relayouts a chip
  // or section). React observes the strip with ResizeObserver; Flutter's
  // equivalent must listen to *layout notifications*, not only build/scroll.
  void _scheduleLayoutMeasure() {
    if (!mounted || _layoutMeasureQueued) return;
    _layoutMeasureQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _layoutMeasureQueued = false;
      if (mounted) _updateSelectedSection();
    });
    // SizeChangedLayoutNotifier dispatches at the end of a frame. Ensure its
    // follow-up measurement receives a frame even with no parent rebuild.
    WidgetsBinding.instance.scheduleFrame();
  }

  void _revealChip(int index) {
    if (!_chipScroll.hasClients) return;
    final render = _chipKeys[index].currentContext?.findRenderObject();
    if (render == null || !render.attached) return;
    final viewport = RenderAbstractViewport.of(render);
    final left = viewport.getOffsetToReveal(render, 0).offset;
    final right = viewport.getOffsetToReveal(render, 1).offset;
    final position = _chipScroll.position;
    final target = position.pixels < right
        ? right
        : position.pixels > left
        ? left
        : position.pixels;
    if ((target - position.pixels).abs() < 1) return;
    _chipScroll.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
    );
  }

  // React renders each sticky HStack *inside* AppScreenContent. A tap on the
  // heading must not activate a list item scrolling underneath it, but a
  // gesture starting on that same heading must still scroll the page. Share
  // ScrollPosition's drag/ballistic physics instead of implementing an offset
  // or velocity approximation for the overlaid Flutter heading.
  void _startPinnedHeadingDrag(DragStartDetails details) {
    if (!_scroll.hasClients) return;
    _pinnedHeadingDrag?.cancel();
    _pinnedHeadingDrag = _scroll.position.drag(details, () {
      _pinnedHeadingDrag = null;
    });
  }

  void _updatePinnedHeadingDrag(DragUpdateDetails details) =>
      _pinnedHeadingDrag?.update(details);

  void _endPinnedHeadingDrag(DragEndDetails details) {
    final drag = _pinnedHeadingDrag;
    _pinnedHeadingDrag = null;
    drag?.end(details);
  }

  void _cancelPinnedHeadingDrag() {
    final drag = _pinnedHeadingDrag;
    _pinnedHeadingDrag = null;
    drag?.cancel();
  }

  void _updateSelectedSection() {
    final rowRender = _chipRowKey.currentContext?.findRenderObject();
    if (rowRender is RenderBox && rowRender.attached) {
      // A horizontal viewport doesn't constrain its child on the main axis.
      // Observe the intrinsic row height rather than the clipped sliver.
      final measured = math.max(52.0, rowRender.size.height + 16);
      if ((_stripHeight - measured).abs() > 0.5) {
        setState(() => _stripHeight = measured);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateSelectedSection();
        });
        return;
      }
    }

    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.attached) return;
    final origin = viewport.localToGlobal(Offset.zero);
    final rows = <List<_SpaSectionBounds>>[];
    for (var i = 0; i < _sectionKeys.length; i++) {
      final render = _sectionKeys[i].currentContext?.findRenderObject();
      final title = _titleKeys[i].currentContext?.findRenderObject();
      if (render is! RenderBox ||
          !render.attached ||
          title is! RenderBox ||
          !title.attached) {
        continue;
      }
      final sectionOffset = render.localToGlobal(Offset.zero) - origin;
      final titleOffset = title.localToGlobal(Offset.zero) - origin;
      final section = _SpaSectionBounds(
        index: i,
        top: sectionOffset.dy,
        bottom: sectionOffset.dy + render.size.height,
        left: sectionOffset.dx,
        width: render.size.width,
        titleTop: titleOffset.dy,
        titleHeight: title.size.height,
      );
      if (rows.isEmpty || (rows.last.first.top - section.top).abs() > 1) {
        rows.add([section]);
      } else {
        rows.last.add(section);
      }
    }

    final measuredRowHeights = <double>[
      for (final row in rows)
        row.map((section) => section.bottom - section.top).reduce(math.max),
    ];
    final rowHeightsChanged =
        measuredRowHeights.length != _gridRowMinHeights.length ||
        List.generate(measuredRowHeights.length, (i) => i).any(
          (i) =>
              i >= _gridRowMinHeights.length ||
              (measuredRowHeights[i] - _gridRowMinHeights[i]).abs() > 0.5,
        );

    final headings = <_SpaPinnedHeading>[];
    var selected = _selectedSection;
    var latestRowTop = double.negativeInfinity;
    final stickyTop = _stripHeight + 8;
    // IntersectionObserver(rootMargin: "0px 0px -80% 0px") in React:
    // only sections intersecting the scrollport's first 20% participate.
    final observationBottom = viewport.size.height * 0.2;
    for (final row in rows) {
      final rowTop = row.first.top;
      final rowBottom = row.map((section) => section.bottom).reduce(math.max);
      if (!_isJumping &&
          rowTop < observationBottom &&
          rowBottom > 0 &&
          rowTop > latestRowTop) {
        selected = row.first.index; // First column in latest visible row.
        latestRowTop = rowTop;
      }
      if (rowTop > stickyTop || rowBottom <= 0) continue;
      for (final section in row) {
        if (section.titleTop >= stickyTop - 0.5) continue;
        final pinnedTop = math.min(stickyTop, rowBottom - section.titleHeight);
        if (pinnedTop + section.titleHeight <= _stripHeight) continue;
        headings.add(
          _SpaPinnedHeading(
            section.index,
            section.left,
            section.width,
            pinnedTop,
          ),
        );
      }
    }

    final sameHeadings =
        _pinnedHeadings.length == headings.length &&
        List.generate(headings.length, (i) => i).every((i) {
          final before = _pinnedHeadings[i];
          final after = headings[i];
          return before.index == after.index &&
              (before.left - after.left).abs() < 0.5 &&
              (before.width - after.width).abs() < 0.5 &&
              (before.top - after.top).abs() < 0.5;
        });
    final selectionChanged = !_isJumping && selected != _selectedSection;
    if ((!sameHeadings || selectionChanged || rowHeightsChanged) && mounted) {
      setState(() {
        if (rowHeightsChanged) _gridRowMinHeights = measuredRowHeights;
        if (!_isJumping) _selectedSection = selected;
        _pinnedHeadings = headings;
      });
      if (selectionChanged) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _revealChip(selected);
        });
      }
    }
  }

  Future<void> _jumpTo(int index) async {
    final render = _sectionKeys[index].currentContext?.findRenderObject();
    if (render is! RenderBox || !_scroll.hasClients) return;
    setState(() {
      _isJumping = true;
      _selectedSection = index;
    });
    _revealChip(index);
    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.attached) return;
    final top = render.localToGlobal(Offset.zero).dy;
    final viewportTop = viewport.localToGlobal(Offset.zero).dy;
    final offset = (_scroll.offset + top - viewportTop - _stripHeight - 8)
        .clamp(0.0, _scroll.position.maxScrollExtent);
    await _scroll.animateTo(
      offset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
    if (mounted) {
      setState(() => _isJumping = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateSelectedSection();
      });
    }
  }

  void _handleEntry(SpaEntry entry) {
    if (entry.activity == 'HomeAlertDialogStep') {
      showSeedDialog(
        context: context,
        child: SeedAlertDialog(
          title: '제목',
          description:
              'Lorem ipsum dolor sit amet consectetur adipisicing elit.',
          footer: Builder(
            builder: (dialogContext) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeedButton(
                  label: '확인',
                  isFullWidth: true,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                const SizedBox(height: 8),
                SeedButton(
                  label: 'ActivityChipButton',
                  isFullWidth: true,
                  variant: SeedButtonVariant.neutralSolid,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    widget.navigate('ActivityChipButton');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else if (entry.activity.startsWith('Snackbar')) {
      if (entry.activity == 'SnackbarWorkaround') {
        final controller = SeedSnackbarProvider.of(context);
        controller.close();
        Future<void>.delayed(Duration.zero, () {
          if (mounted) {
            controller.show(
              child: const SeedSnackbar(message: 'Workaround Snackbar'),
            );
          }
        });
        return;
      }
      final variant = switch (entry.activity) {
        'SnackbarPositive' => SeedSnackbarVariant.positive,
        'SnackbarCritical' => SeedSnackbarVariant.critical,
        _ => SeedSnackbarVariant.neutral,
      };
      final queued = entry.activity == 'SnackbarQueued';
      SeedSnackbarProvider.of(context).show(
        strategy: queued
            ? SeedSnackbarStrategy.queued
            : SeedSnackbarStrategy.immediate,
        child: SeedSnackbar(
          message: queued ? 'Queued Snackbar' : 'Disco Party!',
          actionLabel: queued ? null : 'Dance',
          onAction: queued ? null : () {},
          variant: variant,
        ),
      );
    } else {
      widget.navigate(entry.activity, arguments: entry.arguments);
    }
  }

  Widget _buildSection(SpaSection section, int index) {
    final colors = context.seedColor;
    return Column(
      key: _sectionKeys[index],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          key: _titleKeys[index],
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Row(
            children: [
              Icon(section.icon, size: 20, color: colors.fg.neutralSubtle),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  section.title,
                  style: context.seedTypography.t5Medium,
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: colors.bg.layerDefault,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < section.entries.length; i++)
                    if (section.entries[i].activity == 'HomeListMenu')
                      MenuAnchor(
                        menuChildren: [
                          SeedMenu(
                            groups: [
                              SeedMenuGroupData(
                                items: [
                                  SeedMenuItemData(
                                    label: '추가',
                                    prefixIcon: const Icon(Icons.add),
                                    onTap: () {},
                                  ),
                                  SeedMenuItemData(
                                    label: '수정',
                                    prefixIcon: const Icon(Icons.edit),
                                    onTap: () {},
                                  ),
                                  SeedMenuItemData(
                                    label: '삭제',
                                    prefixIcon: const Icon(Icons.delete),
                                    isDestructive: true,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        builder: (context, controller, _) => SeedListItem(
                          titleText: section.entries[i].title,
                          showDivider: false,
                          onTap: () => controller.isOpen
                              ? controller.close()
                              : controller.open(),
                        ),
                      )
                    else
                      SeedListItem(
                        titleText: section.entries[i].activity == 'ActivityHome'
                            ? '홈 다시 push (깊이: ${widget.depth})'
                            : section.entries[i].title,
                        detailText:
                            section.entries[i].activity.startsWith(
                                  'Snackbar',
                                ) ||
                                section.entries[i].activity == 'ActivityHome' ||
                                section.entries[i].activity ==
                                    'HomeAlertDialogStep'
                            ? null
                            : section.entries[i].activity,
                        showDivider: false,
                        onTap: () => _handleEntry(section.entries[i]),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pinnedHeading(_SpaPinnedHeading heading, SeedColorScheme colors) {
    final section = spaSections[heading.index];
    return Positioned(
      left: heading.left,
      top: heading.top - _stripHeight - 8,
      width: heading.width,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent && _scroll.hasClients) {
            _scroll.position.pointerScroll(event.scrollDelta.dy);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // The React title is inert; the tap recognizer only shields the
          // card beneath it and must not advertise a fake accessibility action.
          excludeFromSemantics: true,
          onTap: () {},
          onVerticalDragStart: _startPinnedHeadingDrag,
          onVerticalDragUpdate: _updatePinnedHeadingDrag,
          onVerticalDragEnd: _endPinnedHeadingDrag,
          onVerticalDragCancel: _cancelPinnedHeadingDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColoredBox(
                // Preserve the existing public test hook for the single-column title.
                key: _pinnedHeadings.length == 1
                    ? const ValueKey('spa-pinned-section-title')
                    : null,
                color: colors.bg.layerBasement,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Extend the sticky heading background through HEADER_GAP.
                    const SizedBox(height: 8),
                    Padding(
                      key: ValueKey(
                        'spa-pinned-section-title-${heading.index}',
                      ),
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                      child: Row(
                        children: [
                          Icon(
                            section.icon,
                            size: 20,
                            color: colors.fg.neutralSubtle,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              section.title,
                              style: context.seedTypography.t5Medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: heading.width,
                height: SeedDimension.x3_5,
                child: CustomPaint(
                  key: ValueKey('spa-pinned-cap-${heading.index}'),
                  painter: _SpaStickyCornerWedgesPainter(
                    colors.bg.layerBasement,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    // The CSS AppScreen layer applies safe-area left/right before its grid.
    final horizontalSafe = MediaQuery.paddingOf(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final width = viewportWidth - horizontalSafe.left - horizontalSafe.right;
    // CSS media-query breakpoints use the viewport width, not the width
    // remaining after the app-screen layer's horizontal safe-area padding.
    final columns = viewportWidth >= 1440
        ? 4
        : viewportWidth >= 1280
        ? 3
        : viewportWidth >= 768
        ? 2
        : 1;
    final available = width - 32 - (columns - 1) * 20;
    final cardWidth = available / columns;
    // A media-query text-scale or viewport change may relayout the chip row
    // without emitting a scroll event. Re-measure after that layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateSelectedSection();
    });

    return Scaffold(
      backgroundColor: colors.bg.layerBasement,
      appBar: SeedTopNavigation(
        titleText: 'Home',
        backgroundColor: colors.bg.layerBasement,
        leading: !spaIsRootRoute(context)
            ? SeedTopNavigationIconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                semanticsLabel: '뒤로',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: widget.themeMode,
            builder: (context, selectedMode, _) => SeedMenuTrigger(
              align: SeedOverlayAlign.end,
              triggerBuilder: (context, open, toggle) =>
                  SeedTopNavigationIconButton(
                    icon: Icon(switch (selectedMode) {
                      ThemeMode.system => Icons.brightness_auto_outlined,
                      ThemeMode.light => Icons.light_mode_outlined,
                      ThemeMode.dark => Icons.dark_mode_outlined,
                    }),
                    semanticsLabel: switch (selectedMode) {
                      ThemeMode.system => '테마 설정: 자동',
                      ThemeMode.light => '테마 설정: 라이트',
                      ThemeMode.dark => '테마 설정: 다크',
                    },
                    onPressed: toggle,
                  ),
              builder: (context) => SeedMenu(
                groups: [
                  SeedMenuGroupData(
                    items: [
                      for (final (mode, label, icon) in [
                        (
                          ThemeMode.system,
                          '자동',
                          Icons.brightness_auto_outlined,
                        ),
                        (ThemeMode.light, '라이트', Icons.light_mode_outlined),
                        (ThemeMode.dark, '다크', Icons.dark_mode_outlined),
                      ])
                        SeedMenuItemData(
                          label: label,
                          prefixIcon: Icon(icon),
                          suffixIcon: selectedMode == mode
                              ? const Icon(Icons.check_rounded)
                              : null,
                          onTap: () => widget.onThemeModeChanged(mode),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SeedTopNavigationIconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            semanticsLabel: '알림',
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        left: true,
        right: true,
        top: false,
        bottom: false,
        child: Stack(
          key: _viewportKey,
          children: [
            SeedPullToRefresh(
              onRefresh: () async =>
                  Future<void>.delayed(const Duration(milliseconds: 1000)),
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SpaChipBarDelegate(
                      background: colors.bg.layerBasement,
                      index: _selectedSection,
                      onSelect: _jumpTo,
                      scrollController: _chipScroll,
                      chipKeys: _chipKeys,
                      chipRowKey: _chipRowKey,
                      extent: _stripHeight,
                      onRowResized: _scheduleLayoutMeasure,
                    ),
                  ),
                  SliverPadding(
                    // ActivityHome Grid pb="x4" + AppScreen
                    // layerOffsetBottom="safeArea". Neither is a 24px
                    // fixed gutter: the additional area follows the device.
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (var i = 0; i < spaSections.length; i++)
                            SizedBox(
                              width: cardWidth,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      i ~/ columns < _gridRowMinHeights.length
                                      ? _gridRowMinHeights[i ~/ columns]
                                      : 0,
                                ),
                                // The cell stretches to its CSS grid row's
                                // height without capping its natural content.
                                // Its section can freely grow or shrink when
                                // text scales or intrinsic labels change.
                                child:
                                    flutter_material.NotificationListener<
                                      flutter_material.SizeChangedLayoutNotification
                                    >(
                                      onNotification: (_) {
                                        _scheduleLayoutMeasure();
                                        return false;
                                      },
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child:
                                            flutter_material.SizeChangedLayoutNotifier(
                                              child: _buildSection(
                                                spaSections[i],
                                                i,
                                              ),
                                            ),
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_pinnedHeadings.isNotEmpty)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(top: _stripHeight),
                  child: ClipRect(
                    child: Stack(
                      children: [
                        for (final heading in _pinnedHeadings)
                          _pinnedHeading(heading, colors),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpaChipBarDelegate extends SliverPersistentHeaderDelegate {
  _SpaChipBarDelegate({
    required this.background,
    required this.index,
    required this.onSelect,
    required this.scrollController,
    required this.chipKeys,
    required this.chipRowKey,
    required this.extent,
    required this.onRowResized,
  });
  final Color background;
  final int index;
  final ValueChanged<int> onSelect;
  final ScrollController scrollController;
  final List<GlobalKey> chipKeys;
  final GlobalKey chipRowKey;
  final double extent;
  final VoidCallback onRowResized;

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: background,
      child:
          flutter_material.NotificationListener<
            flutter_material.SizeChangedLayoutNotification
          >(
            onNotification: (_) {
              onRowResized();
              return false;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: flutter_material.SizeChangedLayoutNotifier(
                child: Row(
                  key: chipRowKey,
                  children: [
                    for (var i = 0; i < spaSections.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      SeedChip(
                        key: chipKeys[i],
                        label: spaSections[i].title,
                        checked: index == i,
                        onCheckedChange: (_) => onSelect(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  bool shouldRebuild(covariant _SpaChipBarDelegate old) =>
      old.background != background ||
      old.index != index ||
      old.onSelect != onSelect ||
      old.scrollController != scrollController ||
      old.chipKeys != chipKeys ||
      old.chipRowKey != chipRowKey ||
      old.extent != extent;
}
