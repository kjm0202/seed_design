import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show BoxParentData, RenderShiftedBox;
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';
import 'spa_routes.dart';
import 'font_multiplier_browser_stub.dart'
    if (dart.library.js_interop) 'font_multiplier_browser_web.dart'
    as font_browser;

double? _webRootFontMultiplier() {
  if (!kIsWeb) return null;
  final attribute = font_browser.readRootFontMultiplier();
  return attribute == null ? null : double.tryParse(attribute);
}

/// Body implementations of the React stackflow-spa screen and layout demos.
/// The hosting SPA owns the activity's Scaffold and top navigation bar.
Widget? buildScreenPage(
  String activity,
  BuildContext context, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
  Object? arguments,
}) {
  switch (activity) {
    case 'ActivityLayerBar':
      return SpaOwnScaffold(
        child: _LayerBarPage(navigate: navigate, goBack: goBack),
      );
    case 'ActivityTransparentBar':
      return SpaOwnScaffold(child: _TransparentBarPage(navigate: navigate));
    case 'ActivitySafeAreaBleed':
      return const _SafeAreaBleedPage();
    case 'ActivityPluginBasicUI':
      return _PluginBasicUiPage(navigate: navigate);
    case 'ActivitySwipeBackKeyboard':
      return _SwipeBackKeyboardPage(navigate: navigate, goBack: goBack);
    case 'ActivityTransitionStyle':
      return _TransitionStylePage(navigate: navigate, arguments: arguments);
    case 'ActivityPullToRefreshPreview':
      return const _PullToRefreshPreviewPage();
    case 'ActivityPullToRefreshTabs':
      return const _PullToRefreshTabsPage();
    case 'ActivityPullToRefreshPreventPull':
      return const _PullToRefreshPreventPullPage();
    case 'ActivityArticlePreventPull':
      return const _ArticlePreventPullPage();
    case 'ActivityMarginPlayground':
      return const _MarginPlaygroundPage();
    case 'ActivityFontMultiplierLayout':
      return const _FontMultiplierLayoutPage();
    case 'ActivityAppScreenPreview':
      return const SpaOwnScaffold(child: _AppScreenPreviewPage());
    case 'ActivityAppScreenTransparent':
      return const SpaOwnScaffold(child: _AppScreenTransparentPage());
    case 'ActivityAppScreenAppBarCustomization':
      return const SpaOwnScaffold(child: _AppScreenAppBarCustomizationPage());
    case 'ActivityResultSectionCtaProgressCircle':
      return const _ResultSectionCtaProgressCirclePage();
    default:
      return null;
  }
}

const _gutter = 16.0;
const _gap = SizedBox(height: 12);
const _lorem =
    'Lorem ipsum dolor sit amet consectetur adipisicing elit. '
    'Numquam autem deserunt reprehenderit ducimus sunt. Quod laudantium '
    'excepturi tempora fuga repellendus accusantium nam maiores? Quas '
    'debitis, neque ullam eligendi minus sit?';
const _transitionStyles = [
  'slideFromRightIOS',
  'fadeFromBottomAndroid',
  'fadeIn',
];

Widget _scrollPage(List<Widget> children, {EdgeInsetsGeometry? padding}) =>
    ListView(
      padding: padding ?? const EdgeInsets.all(_gutter),
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );

/// The official pull-to-refresh content has only the side gutter.
Widget _ptrScroll(List<Widget> children) => _scrollPage(
  children,
  padding: const EdgeInsets.symmetric(horizontal: _gutter),
);

Widget _caption(String value) => Builder(
  builder: (context) => Text(
    value,
    style: TextStyle(fontSize: 13, color: context.seedColor.fg.neutralMuted),
  ),
);

Widget _action(
  String title,
  VoidCallback action, {
  SeedButtonVariant variant = SeedButtonVariant.neutralSolid,
  bool full = true,
}) => SeedButton(
  label: title,
  onPressed: action,
  variant: variant,
  isFullWidth: full,
);

Widget _appBarIconStrip(String side, int count) {
  if (count == 0) return const SizedBox.shrink();
  return SizedBox(
    height: 48,
    width: count * 44.0,
    child: Row(
      children: List.generate(
        count,
        (i) => Tooltip(
          message: '$side notification ${i + 1}',
          child: SeedTopNavigationIconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ),
      ),
    ),
  );
}

class _LayerBarPage extends StatefulWidget {
  const _LayerBarPage({required this.navigate, required this.goBack});
  final SpaNavigate navigate;
  final VoidCallback goBack;

  @override
  State<_LayerBarPage> createState() => _LayerBarPageState();
}

class _LayerBarPageState extends State<_LayerBarPage> {
  int left = 1;
  int right = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.seedColor.bg.layerDefault,
    appBar: SeedTopNavigation(
      titleText: 'Random Long Title Hello World Commodo occaecat laboris voluptate aute magna.',
      subtitle: 'Subtitle Ut voluptate in sint sunt adipisicing ex adipisicing magna ad fugiat excepteur commodo voluptate.',
      // Match the SPA's platform-specific AppBar alignment: iOS centers the
      // title, while Android and desktop keep it beside the leading actions.
      centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      leading: _appBarIconStrip('Left', left),
      actions: [_appBarIconStrip('Right', right)],
    ),
    body: _scrollPage([
      _action(
        'ActivityTransparentBar',
        () => widget.navigate('ActivityTransparentBar'),
      ),
      _gap,
      // Official buttons use PrefixIcon, not glyphs in the accessible name.
      SeedButton(
        label: 'Back',
        prefixIcon: const Icon(Icons.chevron_left_rounded),
        onPressed: widget.goBack,
        variant: SeedButtonVariant.neutralWeak,
        isFullWidth: true,
      ),
      _gap,
      SeedButton(
        label: 'ActivityHome',
        prefixIcon: const Icon(Icons.home_outlined),
        onPressed: () => widget.navigate('ActivityHome'),
        variant: SeedButtonVariant.neutralWeak,
        isFullWidth: true,
      ),
      _gap,
      Row(
        children: [
          Expanded(
            child: _action(
              'Append Left',
              () => setState(() => left++),
              variant: SeedButtonVariant.neutralWeak,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _action(
              'Append Right',
              () => setState(() => right++),
              variant: SeedButtonVariant.neutralWeak,
            ),
          ),
        ],
      ),
      _gap,
      Row(
        children: [
          Expanded(
            child: _action(
              'Remove Left',
              () => setState(() => left = left > 0 ? left - 1 : 0),
              variant: SeedButtonVariant.neutralWeak,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _action(
              'Remove Right',
              () => setState(() => right = right > 0 ? right - 1 : 0),
              variant: SeedButtonVariant.neutralWeak,
            ),
          ),
        ],
      ),
    ], padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
  );
}

class _TransparentBarPage extends StatefulWidget {
  const _TransparentBarPage({required this.navigate});
  final SpaNavigate navigate;

  @override
  State<_TransparentBarPage> createState() => _TransparentBarPageState();
}

class _TransparentBarPageState extends State<_TransparentBarPage> {
  String layerOffsetTop = 'none';
  bool gradient = true;
  // Scroll offset, capped above the largest layer top padding; only that
  // range moves the sticky gradient pseudo-element.
  double _stickyScroll = 0;
  static const double _stickyScrollCap = 200;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final contentInsetTop = switch (layerOffsetTop) {
      'safeArea' => safeTop,
      'appBar' => safeTop + 56,
      _ => 0.0,
    };
    // CSS AppScreen pseudo element: sticky (top 0) after the layer's top
    // padding, 66px + 400px + safeArea.top tall, translated up by 400px plus
    // that padding. Unscrolled, its visible tail always spans 66px +
    // safeArea.top from the top; scrolling past the padding (sticky) exposes
    // less of it, down to 66px + safeArea.top - padding.
    final fullFadeExtent = 66.0 + safeTop;
    final gradientExtent =
        fullFadeExtent - _stickyScroll.clamp(0.0, contentInsetTop);
    // The CSS gradient passes #00000059 at y=400 and reaches clear at the
    // pseudo-element's end (y=466+safeTop). Moving that element upwards
    // exposes only its remaining tail, including its reduced initial alpha.
    final gradientStartAlpha =
        (0x59 * (gradientExtent / fullFadeExtent).clamp(0.0, 1.0)).round();
    return Scaffold(
      backgroundColor: context.seedColor.bg.layerDefault,
      // React keeps the layer full-height and changes its inner top padding.
      extendBodyBehindAppBar: true,
      appBar: SeedTopNavigation(
        title: spaHasEmptyAppBarLeft(context)
            ? spaRootTitle(context, '펭귄', color: Colors.white)
            : null,
        titleText: spaHasEmptyAppBarLeft(context) ? null : '펭귄',
        // ActivityTransparentBar's AppScreen sets no theme, so it follows the
        // app-wide platform layout like the other SPA screens.
        tone: SeedTopNavigationTone.transparent,
        // The React gradient belongs to AppScreen.Layer, not AppBar itself.
        gradient: false,
        actions: [
          for (var i = 0; i < 2; i++)
            SeedTopNavigationIconButton(
              semanticsLabel: 'Notification ${i + 1}',
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          SeedTopNavigationIconButton(
            icon: const Icon(Icons.home_outlined),
            semanticsLabel: 'Home',
            onPressed: () => widget.navigate('ActivityHome'),
          ),
        ],
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              if (notification.depth == 0) {
                final next = notification.metrics.pixels.clamp(
                  0.0,
                  _stickyScrollCap,
                );
                if (next != _stickyScroll) {
                  setState(() => _stickyScroll = next);
                }
              }
              return false;
            },
            child: _scrollPage([
              _penguinPanel(gradient),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 368),
                      child: SeedSegmentedControl<String>(
                        semanticsLabel: 'Layer Offset Top',
                        segments: const [
                          SeedSegment(
                            value: 'none',
                            child: Text('none', softWrap: false, maxLines: 1),
                          ),
                          // Keep this English token on one line, as in React. The
                          // child supplies its accessible text while the default
                          // empty label avoids pre-measuring a wrapped two-line row.
                          SeedSegment(
                            value: 'safeArea',
                            child: Text(
                              'safeArea',
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                          SeedSegment(
                            value: 'appBar',
                            child: Text('appBar', softWrap: false, maxLines: 1),
                          ),
                        ],
                        value: layerOffsetTop,
                        onValueChange: (next) =>
                            setState(() => layerOffsetTop = next),
                      ),
                    ),
                    _gap,
                    SizedBox(
                      height: 24,
                      child: OverflowBox(
                        minHeight: 44,
                        maxHeight: 44,
                        alignment: Alignment.center,
                        child: SeedSwitch(
                          label: 'gradient',
                          size: SeedSwitchSize.size24,
                          tone: SeedControlTone.neutral,
                          checked: gradient,
                          onCheckedChange: (next) =>
                              setState(() => gradient = next),
                        ),
                      ),
                    ),
                    _gap,
                    _action(
                      'ActivityLayerBar',
                      () => widget.navigate('ActivityLayerBar'),
                      full: false,
                    ),
                    _gap,
                    _action(
                      'ActivityPluginBasicUI',
                      () => widget.navigate('ActivityPluginBasicUI'),
                      full: false,
                    ),
                    for (final style in _transitionStyles) ...[
                      _gap,
                      SizedBox(
                        height: 40,
                        child: OverflowBox(
                          maxWidth: MediaQuery.sizeOf(context).width,
                          alignment: Alignment.center,
                          child: _action(
                            'ActivityTransitionStyle ($style)',
                            full: false,
                            () => widget.navigate(
                              'ActivityTransitionStyle',
                              arguments: {'transitionStyle': style},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              for (var i = 0; i < 3; i++) ...[
                const SizedBox(height: 16),
                _penguinPanel(gradient),
              ],
            ], padding: EdgeInsets.only(top: contentInsetTop, bottom: 24)),
          ),
          if (gradient && gradientExtent > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                key: const ValueKey('transparent-bar-scroll-gradient'),
                child: SizedBox(
                  height: gradientExtent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(gradientStartAlpha, 0, 0, 0),
                          const Color(0x00000000),
                        ],
                      ),
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

Widget _penguinPanel(bool gradient) => AspectRatio(
  aspectRatio: 800 / 600,
  child: Image.asset('assets/peng.jpeg', fit: BoxFit.cover),
);

const _categories = [
  '전체',
  '디지털기기',
  '생활가전',
  '가구/인테리어',
  '생활/주방',
  '유아동',
  '여성의류',
  '남성패션/잡화',
  '뷰티/미용',
];

class _SafeAreaBleedPage extends StatefulWidget {
  const _SafeAreaBleedPage();

  @override
  State<_SafeAreaBleedPage> createState() => _SafeAreaBleedPageState();
}

class _SafeAreaBleedPageState extends State<_SafeAreaBleedPage> {
  String category = _categories.first;
  final GlobalKey _footerKey = GlobalKey();
  double _footerExtent = 0;

  void _measureFooter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final render = _footerKey.currentContext?.findRenderObject();
      if (render is! RenderBox || !render.hasSize) return;
      final next = render.size.height;
      if ((next - _footerExtent).abs() > 0.5) {
        setState(() => _footerExtent = next);
      }
    });
  }

  Widget section(String title, String description, Widget body) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _gutter + MediaQuery.paddingOf(context).left,
            right: _gutter + MediaQuery.paddingOf(context).right,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.seedTypography.t5Bold),
              const SizedBox(height: 4),
              _caption(description),
            ],
          ),
        ),
        const SizedBox(height: 12),
        body,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    _measureFooter();
    return Stack(
      children: [
        // The official footer is the final in-flow child of a full-height
        // scroll layer with CSS position:sticky; bottom:0. Keep its measured
        // height in the scroll extent while painting the sticky copy below.
        ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            section(
              '이미지',
              'bleedX에 safeArea를 주면 좌우 inset까지 채워요.',
              _penguinPanel(true),
            ),
            section(
              '가로 스크롤',
              '스크롤 영역은 bleedX로 화면 끝까지 넓히고, pl과 pr의 safeArea로 내용을 safe area 경계에서 시작해요. gutter는 안쪽 요소가 가져요.',
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: _gutter + MediaQuery.paddingOf(context).left,
                  right: _gutter + MediaQuery.paddingOf(context).right,
                ),
                child: Row(
                  children: [
                    for (var i = 1; i <= 10; i++) ...[
                      Container(
                        height: 80,
                        width: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$i',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (i < 10) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            section(
              'Chip Tabs',
              '스크롤 영역이 gutter를 padding으로 직접 가지면, gutter와 inset을 더한 값을 padding으로 줘요.',
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.paddingOf(context).left,
                  right: MediaQuery.paddingOf(context).right,
                ),
                child: SeedTabs(
                  variant: SeedTabsVariant.chipSolid,
                  items: [
                    for (final item in _categories)
                      SeedTabItem(label: item, value: item),
                  ],
                  selectedIndex: _categories.indexOf(category),
                  onTabSelected: (index) =>
                      setState(() => category = _categories[index]),
                ),
              ),
            ),
            section(
              '배경 띠',
              '배경은 bleedX로 화면 끝까지 채우고, 내용은 pl과 pr의 safeArea와 gutter 안쪽에 둬요.',
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  _gutter + MediaQuery.paddingOf(context).left,
                  _gutter,
                  _gutter + MediaQuery.paddingOf(context).right,
                  _gutter,
                ),
                color: context.seedColor.bg.brandWeak,
                child: Text(
                  '배경은 화면 끝까지, 글자는 safe area 안쪽에 있어요.',
                  style: context.seedTypography.t4Medium.copyWith(
                    color: context.seedColor.fg.brand,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: _gutter + MediaQuery.paddingOf(context).left,
                right: _gutter + MediaQuery.paddingOf(context).right,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    const Text(
                      '아래 하단 바가 콘텐츠 위에 고정되는지 확인하기 위한 문단이에요. '
                      '하단 바는 배경을 화면 끝까지 채우고, 버튼은 safe area 안쪽에 둬요.',
                    ),
                    if (i != 5) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(height: _footerExtent),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: KeyedSubtree(
            key: _footerKey,
            child: ColoredBox(
              color: context.seedColor.bg.layerDefault,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 12),
                  child: _action(
                    '확인',
                    () {},
                    variant: SeedButtonVariant.brandSolid,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PluginBasicUiPage extends StatelessWidget {
  const _PluginBasicUiPage({required this.navigate});
  final SpaNavigate navigate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(_gutter),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _action(
          'ActivityTransparentBar',
          () => navigate('ActivityTransparentBar'),
        ),
      ],
    ),
  );
}

class _SwipeBackKeyboardPage extends StatefulWidget {
  const _SwipeBackKeyboardPage({required this.navigate, required this.goBack});
  final SpaNavigate navigate;
  final VoidCallback goBack;

  @override
  State<_SwipeBackKeyboardPage> createState() => _SwipeBackKeyboardPageState();
}

class _SwipeBackKeyboardPageState extends State<_SwipeBackKeyboardPage> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _edgeGesture = false;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onHorizontalDragStart: (details) {
      _edgeGesture = details.localPosition.dx < 36;
      _dragDistance = 0;
      if (_edgeGesture) _focusNode.unfocus();
    },
    onHorizontalDragUpdate: (details) {
      if (_edgeGesture) _dragDistance += details.delta.dx;
    },
    onHorizontalDragEnd: (_) {
      if (_edgeGesture && _dragDistance > 90) widget.goBack();
      _edgeGesture = false;
    },
    child: _scrollPage([
      const SizedBox(height: 16),
      const Text('입력 화면을 한 장 더 열고 글을 입력한 뒤, 왼쪽 가장자리에서 천천히 오른쪽으로 밀어보세요.'),
      const SizedBox(height: 36),
      _action(
        '입력 화면 한 장 더 열기',
        () => widget.navigate('ActivitySwipeBackKeyboard'),
        variant: SeedButtonVariant.brandSolid,
      ),
      const SizedBox(height: 20),
      const Text('검색어'),
      const SizedBox(height: 8),
      Semantics(
        // React's input has aria-label="검색어" in addition to its
        // placeholder. The preceding Text alone is not an input label.
        label: '검색어',
        child: TextField(
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: '여기를 눌러 키보드를 여세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF868B94)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF868B94)),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ),
      const SizedBox(height: 36),
      Text(
        '입력 포커스: ${_focused ? '있음' : '없음'}',
        semanticsLabel: '입력 포커스: ${_focused ? '있음' : '없음'}',
      ),
      const SizedBox(height: 52),
      const Text(
        '정상 동작: 가장자리를 터치하면 입력 포커스가 해제되고 키보드가 내려가기 시작합니다. '
        '화면을 조금 밀었다가 되돌려 취소해도 키보드는 다시 열리지 않습니다.',
      ),
      const SizedBox(height: 52),
      const Text(
        '실제 키보드와 커서 잔상은 iPhone의 Safari 또는 앱 웹뷰에서 확인하세요. '
        '데스크톱에서는 모바일 터치 에뮬레이션으로 포커스 상태를 확인할 수 있습니다.',
      ),
    ], padding: const EdgeInsets.all(20)),
  );
}

class _TransitionStylePage extends StatefulWidget {
  const _TransitionStylePage({required this.navigate, this.arguments});
  final SpaNavigate navigate;
  final Object? arguments;

  @override
  State<_TransitionStylePage> createState() => _TransitionStylePageState();
}

class _TransitionStylePageState extends State<_TransitionStylePage> {
  bool preventSwipeBack = false;
  SpaCupertinoRoute<dynamic>? _gestureRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context);
    final next = current is SpaCupertinoRoute ? current : null;
    if (identical(next, _gestureRoute)) return;
    _gestureRoute?.swipeEvent.removeListener(_showSwipeFeedback);
    _gestureRoute = next;
    _gestureRoute?.swipeEvent.addListener(_showSwipeFeedback);
  }

  void _showSwipeFeedback() {
    if (!mounted) return;
    final message = _gestureRoute?.swipeEvent.value;
    if (message == null || message.isEmpty) return;
    SeedSnackbarProvider.of(context).show(
      strategy: SeedSnackbarStrategy.immediate,
      duration: const Duration(milliseconds: 500),
      child: SeedSnackbar(message: message),
    );
  }

  @override
  void dispose() {
    _gestureRoute?.swipeEvent.removeListener(_showSwipeFeedback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.arguments;
    final style = args is Map ? args['transitionStyle']?.toString() : null;
    final route = ModalRoute.of(context);
    return _scrollPage([
      for (final transitionStyle in _transitionStyles) ...[
        _action(
          transitionStyle,
          () => widget.navigate(
            'ActivityTransitionStyle',
            arguments: {'transitionStyle': transitionStyle},
          ),
          variant: transitionStyle == style
              ? SeedButtonVariant.neutralWeak
              : SeedButtonVariant.neutralSolid,
        ),
        if (transitionStyle != _transitionStyles.last)
          const SizedBox(height: 8),
      ],
      const SizedBox(height: 16),
      Center(
        child: Text('Prevent Swipe Back', style: context.seedTypography.t3Bold),
      ),
      _gap,
      Center(
        child: SizedBox(
          width: 180,
          child: SeedSegmentedControl<bool>(
            semanticsLabel: 'Prevent Swipe Back',
            segments: const [
              SeedSegment(value: false, label: 'false'),
              SeedSegment(value: true, label: 'true'),
            ],
            value: preventSwipeBack,
            onValueChange: (next) {
              setState(() => preventSwipeBack = next);
              if (route is SpaCupertinoRoute) route.preventSwipeBack = next;
            },
          ),
        ),
      ),
    ], padding: const EdgeInsets.symmetric(horizontal: _gutter, vertical: 12));
  }
}

Future<void> _refreshAfterDelay() =>
    Future<void>.delayed(const Duration(seconds: 1));

class _PullToRefreshPreviewPage extends StatelessWidget {
  const _PullToRefreshPreviewPage();

  @override
  Widget build(BuildContext context) => SeedPullToRefresh(
    onReady: () {},
    onRefresh: _refreshAfterDelay,
    child: _ptrScroll([const Text(_lorem)]),
  );
}

class _PullToRefreshTabsPage extends StatefulWidget {
  const _PullToRefreshTabsPage();

  @override
  State<_PullToRefreshTabsPage> createState() => _PullToRefreshTabsPageState();
}

class _PullToRefreshTabsPageState extends State<_PullToRefreshTabsPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SeedTabs(
        items: const [
          SeedTabItem(label: 'Tab 1', value: '1'),
          SeedTabItem(label: 'Tab 2', value: '2'),
        ],
        selectedIndex: selectedTab,
        onTabSelected: (next) => setState(() => selectedTab = next),
        fill: true,
      ),
      Expanded(
        // React TabsContent keeps an inactive panel mounted. Removing Tab 1
        // destroys an in-flight PTR gesture/state before pointer-up.
        child: IndexedStack(
          index: selectedTab,
          children: [
            SeedPullToRefresh(
              onReady: () {},
              onRefresh: _refreshAfterDelay,
              child: _ptrScroll([const Text(_lorem)]),
            ),
            _ptrScroll([const Text('PTR is not available in this tab.')]),
          ],
        ),
      ),
    ],
  );
}

Widget _pullArea(BuildContext context, bool preventsPull) {
  final area = Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: preventsPull
          ? context.seedColor.bg.criticalWeak
          : context.seedColor.bg.neutralWeak,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      preventsPull
          ? '이 영역은 당겨서 새로고침이 불가능합니다. Aliquip ad amet eu dolore id enim '
                'excepteur laboris officia anim in. Irure irure nulla sit eiusmod aliqua '
                'sint excepteur amet laboris.'
          : '이 영역은 당겨서 새로고침이 가능합니다. Amet in laborum proident fugiat '
                'mollit quis aute mollit esse nostrud. Excepteur ea proident ipsum duis. '
                'Nulla Lorem pariatur exercitation velit anim.',
      style: TextStyle(
        color: preventsPull
            ? context.seedColor.fg.criticalContrast
            : context.seedColor.fg.neutral,
      ),
    ),
  );
  return preventsPull ? SeedPullToRefreshPreventPull(child: area) : area;
}

class _PullToRefreshPreventPullPage extends StatelessWidget {
  const _PullToRefreshPreventPullPage();

  @override
  Widget build(BuildContext context) => SeedPullToRefresh(
    onReady: () {},
    onRefresh: _refreshAfterDelay,
    child: _ptrScroll([
      _pullArea(context, false),
      const SizedBox(height: 16),
      _pullArea(context, true),
      const SizedBox(height: 16),
      _pullArea(context, false),
      const SizedBox(height: 16),
      _pullArea(context, true),
    ]),
  );
}

class _ArticlePreventPullPage extends StatelessWidget {
  const _ArticlePreventPullPage();

  @override
  Widget build(BuildContext context) => SeedPullToRefresh(
    onReady: () {},
    onRefresh: _refreshAfterDelay,
    child: _scrollPage([
      const SeedPageBanner(
        description: '상위 요소에 `user-select: none;` 스타일 적용됨',
        prefixIcon: Icon(Icons.error),
        tone: SeedPageBannerTone.warning,
        variant: SeedPageBannerVariant.solid,
      ),
      const SizedBox(height: 32),
      SeedPullToRefreshPreventPull(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Article', style: context.seedTypography.t6Bold),
              const SizedBox(height: 12),
              SelectableText(
                '이 요소는 Article 내부에 있으므로 텍스트 선택이 가능합니다. '
                '이 Article은 PTR 제스처를 호출하지 않도록 설정되어 있습니다. '
                '여기를 아래로 끌어 당기면 PTR이 작동하는 대신 텍스트가 선택됩니다.',
                style: context.seedTypography.articleBody,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 32),
      const SeedDivider(),
      const SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: _gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Article 외부', style: context.seedTypography.t6Bold),
            const SizedBox(height: 12),
            Text(
              '이 요소는 Article 외부에 있으므로 텍스트 선택이 불가능합니다. '
              '이 요소는 PTR을 호출할 수 있습니다. 여기를 아래로 끌어 당겨보세요.',
              style: context.seedTypography.articleBody,
            ),
          ],
        ),
      ),
    ], padding: EdgeInsets.zero),
  );
}

/// The yellow case inset is fixed at x3 (12px), while each blue DemoBox has
/// its own independent margin, just as in the React margin playground.
class _MarginPlaygroundPage extends StatelessWidget {
  const _MarginPlaygroundPage();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final width = size.maxWidth;
      final md = width >= 768;
      // Official packages/css/breakpoints/index.mjs: sm=480, md=768, lg=1280.
      final sm = width >= 480;
      final lg = width >= 1280;
      final cases = <Widget>[
        _marginSection('Shorthand cascade', [
          _marginCase(
            "m='x4' — all four sides",
            'm="x4"',
            margin: const EdgeInsets.all(16),
          ),
          _marginCase(
            "mx='x6' · my='x2'",
            'mx="x6" · my="x2"',
            description: 'horizontal vs vertical shorthands',
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          _marginCase(
            "m='x4' + mt='x8' (specific override)",
            'm="x4" · mt="x8"',
            description:
                'marginTop overrides the shorthand only for the top edge.',
            margin: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          ),
          _marginCase(
            "m='x6' + mx='x2' + mr='x10' (three-level cascade)",
            'm=x6 · mx=x2 · mr=x10',
            description:
                'margin → marginX → marginRight, each level overrides.',
            margin: const EdgeInsets.fromLTRB(8, 24, 40, 24),
          ),
        ]),
        _marginSection('Value types', [
          _marginCase(
            "Dimension token: mt='spacingY.componentDefault'",
            'mt="spacingY.componentDefault"',
            margin: const EdgeInsets.only(top: 12),
          ),
          _marginCase(
            "Raw CSS string: mx='24px'",
            'mx="24px"',
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
          _marginCase('Zero: m={0}', 'm={0}'),
          _marginCase(
            "Negative: mt='-8px'",
            'mt="-8px"',
            description: 'margin supports negative values.',
            offsetY: -8,
          ),
        ]),
        _marginSection('auto — static centering / push', [
          _marginCase(
            "mx='auto' — horizontal centering",
            'mx="auto"',
            description: 'Centered at every viewport.',
            align: Alignment.center,
          ),
          _marginCase(
            "ml='auto' — push to right",
            'ml="auto"',
            align: Alignment.centerRight,
          ),
          _marginCase("mr='auto' — push to left (explicit)", 'mr="auto"'),
          _marginCase(
            "my='auto' inside a tall flex parent",
            'my="auto"',
            description: 'Vertical centering via flex + auto.',
            align: Alignment.center,
            minHeight: 200,
          ),
        ]),
        _marginSection('Responsive values', [
          _marginCase(
            "mx={{ base: 'x2', md: 'x8' }}",
            'base: x2 · md: x8',
            description: 'Tighter on mobile, roomier on desktop.',
            margin: EdgeInsets.symmetric(horizontal: md ? 32 : 8),
          ),
          _marginCase(
            "mx={{ base: 'auto', md: 0 }}",
            'base: auto · md: 0',
            description: 'Centered on mobile, flush left from md up.',
            align: md ? Alignment.centerLeft : Alignment.center,
          ),
          _marginCase(
            "mx={{ base: 0, md: 'auto' }}",
            'base: 0 · md: auto',
            description: 'Flush left on mobile, centered from md up.',
            align: md ? Alignment.center : Alignment.centerLeft,
          ),
          _marginCase(
            "mx={{ base: 'auto', md: '16px' }}",
            'base: auto · md: 16px',
            description: 'Auto and a dimension mixed across breakpoints.',
            align: md ? Alignment.centerLeft : Alignment.center,
            margin: md
                ? const EdgeInsets.symmetric(horizontal: 16)
                : EdgeInsets.zero,
          ),
          _marginCase(
            "ml={{ base: 'auto', md: 0 }} — asymmetric",
            'base: ml=auto · md: ml=0',
            description: 'Only left margin responds; right stays at 0.',
            align: md ? Alignment.centerLeft : Alignment.centerRight,
          ),
          _marginCase(
            "mx={{ base: 0, sm: '8px', md: 'auto', lg: '16px' }}",
            'base:0 · sm:8 · md:auto · lg:16',
            description:
                'Four values across four breakpoints, auto in the middle.',
            align: md && !lg ? Alignment.center : Alignment.centerLeft,
            margin: EdgeInsets.symmetric(
              horizontal: lg
                  ? 16
                  : sm && !md
                  ? 8
                  : 0,
            ),
          ),
        ]),
        _marginSection('Baseline', [
          _marginCase(
            'No margin/bleed (default)',
            'default',
            description: 'Regression check.',
          ),
          _marginCase(
            'bleed only (existing behavior)',
            'bleedX="x4"',
            description: 'bleedX still works unchanged.',
            bleedX: true,
          ),
        ]),
      ];
      return _scrollPage(cases, padding: const EdgeInsets.all(16));
    },
  );
}

Color _palette(BuildContext context, Color light, Color dark) =>
    context.seedColor.isDark ? dark : light;

Widget _marginSection(String title, List<Widget> children) => Builder(
  builder: (context) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _palette(
                context,
                SeedPalette.gray900Light,
                SeedPalette.gray900Dark,
              ),
            ),
          ),
        ),
        ...children,
      ],
    ),
  ),
);

/// The official Case asks for palette.gray50, which the palette does not have,
/// so its panel paints nothing.
Widget _marginCase(
  String label,
  String boxLabel, {
  String? description,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  Alignment align = Alignment.centerLeft,
  double minHeight = 0,
  double offsetY = 0,
  bool bleedX = false,
}) => Builder(
  builder: (context) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _palette(
              context,
              SeedPalette.gray800Light,
              SeedPalette.gray800Dark,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (description != null) ...[
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: _palette(
                context,
                SeedPalette.gray600Light,
                SeedPalette.gray600Dark,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            color: _palette(
              context,
              SeedPalette.yellow100Light,
              SeedPalette.yellow100Dark,
            ),
            border: Border.all(
              color: _palette(
                context,
                SeedPalette.yellow700Light,
                SeedPalette.yellow700Dark,
              ),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Padding(
              padding: margin,
              child: Align(
                alignment: align,
                heightFactor: minHeight > 0 ? null : 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: bleedX ? 20 : 0),
                  child: _VerticalMargin(
                    top: offsetY,
                    child: Transform.translate(
                      offset: Offset(bleedX ? -16 : 0, 0),
                      child: Container(
                        // React DemoBox has width:200px on its *content box*;
                        // p=x3 is outside that width (no border-box sizing).
                        // Let the blue background wrap the 200px content
                        // plus 12px padding on each side, rather than forcing
                        // the entire painted box to only 200px.
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _palette(
                            context,
                            SeedPalette.blue600Light,
                            SeedPalette.blue600Dark,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SizedBox(
                          width: 200,
                          child: Text(
                            boxLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

class _FontMultiplierLayoutPage extends StatefulWidget {
  const _FontMultiplierLayoutPage();

  @override
  State<_FontMultiplierLayoutPage> createState() =>
      _FontMultiplierLayoutPageState();
}

/// The React SEED web bundler reads `font:-apple-system-body` and applies
/// 0.9412 on iOS (including desktop browsers, which use its iOS fallback).
/// With the regular 16px Chrome font the bundled dataset is rounded to 0.94.
/// Flutter native keeps the actual system text scale, including accessibility
/// multipliers; only the default unscaled Web value uses this CSS baseline.
double seedFontMultiplierForLayout(
  double platformScale, {
  required bool isWeb,
  required TargetPlatform platform,
}) {
  if (!isWeb || platform == TargetPlatform.android || platformScale != 1.0) {
    return platformScale;
  }
  return double.parse(
    (platformScale * 0.9412).clamp(0.8, 1.35).toStringAsFixed(2),
  );
}

class _FontMultiplierLayoutPageState extends State<_FontMultiplierLayoutPage> {
  void _refresh() {
    if (kIsWeb) {
      // Unlike setState, this reloads the HTML + Flutter bootstrap so any
      // root font multiplier is read again on the newly loaded document.
      font_browser.reloadDocument();
      return;
    }
    // Native has no browser document or bundler root attribute. Flutter
    // already observes OS text-scale changes via MediaQuery; re-evaluate
    // the current value and explain the platform-specific behavior.
    setState(() {});
    SeedSnackbarProvider.of(context)
        .show(child: const SeedSnackbar(message: '앱에서는 글꼴 배율 변경이 자동으로 반영됩니다.'));
  }

  @override
  Widget build(BuildContext context) {
    final multiplier =
        _webRootFontMultiplier() ??
        seedFontMultiplierForLayout(
          MediaQuery.textScalerOf(context).scale(1.0),
          isWeb: kIsWeb,
          platform: defaultTargetPlatform,
        );
    final scale = multiplier >= 1.35
        ? 'large'
        : multiplier >= 1.15
        ? 'medium'
        : multiplier >= 1
        ? 'base'
        : 'small';
    final columns = switch (scale) {
      'large' => 2,
      'medium' => 3,
      'base' => 4,
      _ => 5,
    };
    return _scrollPage([
      const SeedCallout(
        title: '폰트 배율 기반 레이아웃',
        description:
            'SEED 번들러 플러그인의 fontScaling: true 옵션을 설정하면, '
            '페이지 최초 로드 시 root element의 data-seed-font-multiplier 속성에 '
            '사용자의 폰트 스케일링 배율이 저장됩니다. 이 값을 읽어 '
            '레이아웃을 배율에 맞게 조정할 수 있습니다.',
        tone: SeedCalloutTone.informative,
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('현재 폰트 배율', style: context.seedTypography.t5Bold),
            const SizedBox(height: 8),
            Text(
              '$multiplier',
              style: context.seedTypography.t4Medium.copyWith(
                color: context.seedColor.fg.neutralMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'scale: $scale',
              style: context.seedTypography.t4Medium.copyWith(
                color: context.seedColor.fg.neutralMuted,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Grid 열 개수 조정 예시', style: context.seedTypography.t5Bold),
            const SizedBox(height: 8),
            Text(
              '폰트 배율이 클수록 열 개수가 줄어듭니다.',
              style: context.seedTypography.t4Medium.copyWith(
                color: context.seedColor.fg.neutralSubtle,
              ),
            ),
            const SizedBox(height: 8),
            // CSS grid rows stretch to their tallest cell.
            for (var row = 0; row * columns < 8; row++) ...[
              if (row > 0) const SizedBox(height: 6),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var col = 0; col < columns; col++) ...[
                      if (col > 0) const SizedBox(width: 6),
                      Expanded(
                        child: row * columns + col < 8
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.seedColor.bg.positiveSolid,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '아이템 ${row * columns + col + 1}',
                                  textAlign: TextAlign.center,
                                  style: context.seedTypography.t4Medium
                                      .copyWith(color: Colors.white),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      _action('새로고침', _refresh),
    ], padding: const EdgeInsets.symmetric(horizontal: _gutter));
  }
}

class _AppScreenPreviewPage extends StatelessWidget {
  const _AppScreenPreviewPage();

  @override
  Widget build(BuildContext context) => _previewScreen(context);
}

class _AppScreenTransparentPage extends StatelessWidget {
  const _AppScreenTransparentPage();

  @override
  Widget build(BuildContext context) =>
      _previewScreen(context, transparent: true);
}

Widget _previewScreen(BuildContext context, {bool transparent = false}) =>
    Scaffold(
      backgroundColor: transparent
          ? (context.seedColor.isDark
                ? SeedPalette.gray800Dark
                : SeedPalette.gray800Light)
          : context.seedColor.bg.layerDefault,
      extendBodyBehindAppBar: transparent,
      appBar: SeedTopNavigation(
        titleText: 'Preview',
        platform: SeedTopNavigationPlatform.cupertino,
        gradient: transparent,
        tone: transparent
            ? SeedTopNavigationTone.transparent
            : SeedTopNavigationTone.layer,
        leading: (ModalRoute.of(context)?.isFirst ?? true)
            ? SeedTopNavigationIconButton(
                icon: const Icon(Icons.close),
                // Transparent passes aria-label="Close"; Preview keeps the
                // AppBarCloseButton default "닫기".
                semanticsLabel: transparent ? 'Close' : '닫기',
                // Official AppBarCloseButton is root-only; its default click
                // handler does not navigate (app-bar.tsx:99-127).
                onPressed: () {},
              )
            : const SizedBox.shrink(),
        actions: [
          SeedTopNavigationIconButton(
            icon: const Icon(Icons.notifications),
            semanticsLabel: 'Notification',
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Preview',
          style: transparent
              ? TextStyle(color: context.seedColor.fg.onNeutralSolid)
              : null,
        ),
      ),
    );

class _AppScreenAppBarCustomizationPage extends StatelessWidget {
  const _AppScreenAppBarCustomizationPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.seedColor.bg.layerDefault,
    appBar: SeedTopNavigation(
      centerTitle: false,
      platform: SeedTopNavigationPlatform.android,
      leading: const SizedBox.shrink(),
      backgroundColor: context.seedColor.isDark
          ? SeedPalette.blue200Dark
          : SeedPalette.blue200Light,
      titleText: 'Preview',
      subtitle: 'This is a nice preview.',
      actions: [
        SeedTopNavigationIconButton(
          semanticsLabel: 'Notification',
          icon: Icon(
            Icons.notifications,
            color: context.seedColor.isDark
                ? SeedPalette.blue500Dark
                : SeedPalette.blue500Light,
          ),
          onPressed: () {},
        ),
      ],
    ),
    body: const Center(child: Text('Preview')),
  );
}

class _ResultSectionCtaProgressCirclePage extends StatefulWidget {
  const _ResultSectionCtaProgressCirclePage();

  @override
  State<_ResultSectionCtaProgressCirclePage> createState() =>
      _ResultSectionCtaProgressCirclePageState();
}

class _ResultSectionCtaProgressCirclePageState
    extends State<_ResultSectionCtaProgressCirclePage> {
  bool inProgress = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRefund();
  }

  void _startRefund() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => inProgress = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: SeedResultSection(
          asset: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: inProgress
                ? const SeedProgressCircle(size: 40)
                : Icon(
                    Icons.error,
                    size: 40,
                    color: context.seedColor.fg.critical,
                  ),
          ),
          title: inProgress ? '환불을 요청하고 있어요' : '다시 시도해주세요',
          description: inProgress ? '잠시만 기다려주세요' : '환불 요청에 실패했어요',
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 8),
          child: SeedButton(
            label: '다시 시도',
            size: SeedButtonSize.large,
            variant: SeedButtonVariant.neutralSolid,
            isFullWidth: true,
            loading: inProgress,
            enabled: !inProgress,
            onPressed: () {
              setState(() => inProgress = true);
              _startRefund();
            },
          ),
        ),
      ),
    ],
  );
}

/// Margin participates in layout rather than only translating the painted box.
class _VerticalMargin extends SingleChildRenderObjectWidget {
  const _VerticalMargin({required this.top, required super.child});
  final double top;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderVerticalMargin(top);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderVerticalMargin renderObject,
  ) => renderObject.top = top;
}

class _RenderVerticalMargin extends RenderShiftedBox {
  _RenderVerticalMargin(this._top) : super(null);
  double _top;
  set top(double value) {
    if (_top == value) return;
    _top = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    child!.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(
      Size(
        child!.size.width,
        (child!.size.height + _top).clamp(0.0, double.infinity),
      ),
    );
    (child!.parentData! as BoxParentData).offset = Offset(0, _top);
  }
}
