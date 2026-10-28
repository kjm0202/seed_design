import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show BoxParentData, RenderShiftedBox;
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';
import 'spa_routes.dart';

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

Widget _caption(String value) => Builder(
  builder: (context) => Text(
    value,
    style: TextStyle(fontSize: 13, color: context.seedColor.fg.neutralMuted),
  ),
);

Widget _heading(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

void _snack(BuildContext context, String message) {
  SeedSnackbarProvider.of(context).show(
    strategy: SeedSnackbarStrategy.immediate,
    child: SeedSnackbar(message: message),
  );
}

Widget _appBarIconStrip(BuildContext context, String side, int count) {
  if (count == 0) return const SizedBox.shrink();
  return SizedBox(
    height: 48,
    width: count * 48.0,
    child: Row(
      children: List.generate(
        count,
        (i) => IconButton(
          tooltip: '$side notification ${i + 1}',
          icon: const Icon(Icons.notifications_none),
          onPressed: () => _snack(context, '$side ${i + 1}'),
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
      centerTitle: false,
      leading: _appBarIconStrip(context, 'Left', left),
      actions: [_appBarIconStrip(context, 'Right', right)],
    ),
    body: _scrollPage([
      _action(
        'ActivityTransparentBar',
        () => widget.navigate('ActivityTransparentBar'),
      ),
      _gap,
      _action('‹  Back', widget.goBack, variant: SeedButtonVariant.neutralWeak),
      _gap,
      _action(
        '⌂  ActivityHome',
        () => widget.navigate('ActivityHome'),
        variant: SeedButtonVariant.neutralWeak,
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.seedColor.bg.layerDefault,
    extendBodyBehindAppBar: layerOffsetTop != 'appBar',
    appBar: SeedTopNavigation(
      titleText: '펭귄',
      centerTitle: false,
      tone: SeedTopNavigationTone.transparent,
      gradient: gradient,
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
    body: _scrollPage(
      [
        _penguinPanel(gradient),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 368),
                child: SeedSegmentedControl<String>(
                  segments: const [
                    SeedSegment(value: 'none', label: 'none'),
                    SeedSegment(value: 'safeArea', label: 'safeArea'),
                    SeedSegment(value: 'appBar', label: 'appBar'),
                  ],
                  value: layerOffsetTop,
                  onValueChange: (next) =>
                      setState(() => layerOffsetTop = next),
                ),
              ),
              _gap,
              SeedSwitch(
                label: 'gradient',
                size: SeedSwitchSize.size24,
                tone: SeedControlTone.neutral,
                checked: gradient,
                onCheckedChange: (next) => setState(() => gradient = next),
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
                _action(
                  'ActivityTransitionStyle ($style)',
                  full: false,
                  () => widget.navigate(
                    'ActivityTransitionStyle',
                    arguments: {'transitionStyle': style},
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
      ],
      padding: EdgeInsets.only(
        top: layerOffsetTop == 'safeArea'
            ? MediaQuery.paddingOf(context).top
            : 0,
        bottom: 24,
      ),
    ),
  );
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

  Widget section(String title, String description, Widget body) => Padding(
    padding: const EdgeInsets.only(bottom: 30),
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
            children: [_heading(title), _caption(description)],
          ),
        ),
        const SizedBox(height: 12),
        body,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            section(
              '이미지',
              'bleedX에 safeArea를 주면 좌우 inset까지 채워요.',
              _penguinPanel(true),
            ),
            section(
              '가로 스크롤',
              '스크롤 영역은 화면 끝까지 넓히고 내용은 safe area 경계에서 시작해요.',
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
              '스크롤 영역에 gutter와 safe area inset을 합산해 padding을 적용해요.',
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
              '배경은 화면 끝까지, 글자는 safe area 안쪽에 있어요.',
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
                children: List.generate(
                  6,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      '아래 하단 바가 콘텐츠 위에 고정되는지 확인하기 위한 문단이에요. '
                      '하단 바는 배경을 화면 끝까지 채우고, 버튼은 safe area 안쪽에 둬요.',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 12),
          child: _action(
            '확인',
            () => _snack(context, '확인'),
            variant: SeedButtonVariant.brandSolid,
          ),
        ),
      ),
    ],
  );
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
      const Text('입력 화면을 한 장 더 열고 글을 입력한 뒤, 왼쪽 가장자리에서 천천히 오른쪽으로 밀어보세요.'),
      const SizedBox(height: 20),
      _action(
        '입력 화면 한 장 더 열기',
        () => widget.navigate('ActivitySwipeBackKeyboard'),
      ),
      const SizedBox(height: 20),
      const Text('검색어'),
      const SizedBox(height: 8),
      TextField(
        focusNode: _focusNode,
        decoration: const InputDecoration(
          hintText: '여기를 눌러 키보드를 여세요',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        '입력 포커스: ${_focused ? '있음' : '없음'}',
        semanticsLabel: '입력 포커스: ${_focused ? '있음' : '없음'}',
      ),
      const SizedBox(height: 20),
      const Text(
        '정상 동작: 가장자리를 터치하면 입력 포커스가 해제되고 키보드가 내려가기 시작합니다. '
        '화면을 조금 밀었다가 되돌려 취소해도 키보드는 다시 열리지 않습니다.',
      ),
      _gap,
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

  @override
  Widget build(BuildContext context) {
    final args = widget.arguments;
    final style = args is Map ? args['transitionStyle']?.toString() : null;
    final route = ModalRoute.of(context);
    return _scrollPage([
      if (route is SpaCupertinoRoute)
        ValueListenableBuilder<String>(
          valueListenable: route.swipeEvent,
          builder: (_, message, _) => Text(message),
        ),

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
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 16),
      const Center(
        child: Text(
          'Prevent Swipe Back',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      _gap,
      Center(
        child: SizedBox(
          width: 180,
          child: SeedSegmentedControl<bool>(
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
    ]);
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
    child: _scrollPage([
      const Text(_lorem),
    ], padding: const EdgeInsets.symmetric(horizontal: _gutter, vertical: 12)),
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
        child: selectedTab == 0
            ? SeedPullToRefresh(
                onReady: () {},
                onRefresh: _refreshAfterDelay,
                child: _scrollPage([const Text(_lorem)]),
              )
            : _scrollPage([const Text('PTR is not available in this tab.')]),
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
          : Theme.of(context).colorScheme.surfaceContainerHighest,
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
    child: _scrollPage([
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Article',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14),
            SelectableText(
              '이 요소는 Article 내부에 있으므로 텍스트 선택이 가능합니다. '
              '이 Article은 PTR 제스처를 호출하지 않도록 설정되어 있습니다. '
              '여기를 아래로 끌어 당기면 PTR이 작동하는 대신 텍스트가 선택됩니다.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
      const Divider(),
      const SizedBox(height: 32),
      _heading('Article 외부'),
      const Text(
        '이 요소는 Article 외부에 있으므로 텍스트 선택이 불가능합니다. '
        '이 요소는 PTR을 호출할 수 있습니다. 여기를 아래로 끌어 당겨보세요.',
      ),
    ]),
  );
}

/// These cases parallel the CSS margin and responsive-value cases in React.
/// They use measured Flutter paddings and alignment on the available width.
class _MarginPlaygroundPage extends StatelessWidget {
  const _MarginPlaygroundPage();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final width = size.maxWidth;
      final md = width >= 768;
      final sm = width >= 640;
      final lg = width >= 1024;
      final cases = <Widget>[
        _marginSection('Shorthand cascade', [
          _marginCase(
            "m='x4' — all four sides",
            'm="x4"',
            padding: const EdgeInsets.all(16),
          ),
          _marginCase(
            "mx='x6' · my='x2'",
            'mx="x6" · my="x2"',
            description: 'horizontal vs vertical shorthands',
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          _marginCase(
            "m='x4' + mt='x8' (specific override)",
            'm="x4" · mt="x8"',
            description:
                'marginTop overrides the shorthand only for the top edge.',
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          ),
          _marginCase(
            "m='x6' + mx='x2' + mr='x10' (three-level cascade)",
            'm=x6 · mx=x2 · mr=x10',
            description:
                'margin → marginX → marginRight, each level overrides.',
            padding: const EdgeInsets.fromLTRB(8, 24, 40, 24),
          ),
        ]),
        _marginSection('Value types', [
          _marginCase(
            "Dimension token: mt='spacingY.componentDefault'",
            'mt="spacingY.componentDefault"',
            padding: const EdgeInsets.only(top: 12),
          ),
          _marginCase(
            "Raw CSS string: mx='24px'",
            'mx="24px"',
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
            padding: EdgeInsets.symmetric(horizontal: md ? 32 : 8),
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
            padding: md
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
            padding: EdgeInsets.symmetric(
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
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ]),
      ];
      return _scrollPage(cases, padding: const EdgeInsets.all(16));
    },
  );
}

Widget _marginSection(String title, List<Widget> children) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [_heading(title), ...children, const SizedBox(height: 24)],
);

Widget _marginCase(
  String label,
  String boxLabel, {
  String? description,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  Alignment align = Alignment.centerLeft,
  double minHeight = 0,
  double offsetY = 0,
}) => Container(
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: const Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      if (description != null) ...[_gap, _caption(description)],
      const SizedBox(height: 8),
      Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3B5),
          border: Border.all(color: const Color(0xFFB08D00)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: padding,
          child: Align(
            alignment: align,
            heightFactor: minHeight > 0 ? null : 1,
            child: _VerticalMargin(
              top: offsetY,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2273D4),
                  borderRadius: BorderRadius.circular(4),
                ),
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
    ],
  ),
);

class _FontMultiplierLayoutPage extends StatefulWidget {
  const _FontMultiplierLayoutPage();

  @override
  State<_FontMultiplierLayoutPage> createState() =>
      _FontMultiplierLayoutPageState();
}

class _FontMultiplierLayoutPageState extends State<_FontMultiplierLayoutPage> {
  @override
  Widget build(BuildContext context) {
    final multiplier = MediaQuery.textScalerOf(context).scale(1.0);
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
      const SizedBox(height: 18),
      _heading('현재 폰트 배율'),
      Text('$multiplier'),
      Text('scale: $scale'),
      _caption('Flutter에서는 MediaQuery.textScaler를 통해 시스템 배율을 읽습니다.'),
      const SizedBox(height: 24),
      _heading('Grid 열 개수 조정 예시'),
      _caption('폰트 배율이 클수록 열 개수가 줄어듭니다.'),
      const SizedBox(height: 8),
      GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          mainAxisExtent: MediaQuery.textScalerOf(context).scale(23) + 32,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, i) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF238B54),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '아이템 ${i + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      const SizedBox(height: 20),
      _action('새로고침', () => setState(() {})),
    ]);
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
        tone: transparent
            ? SeedTopNavigationTone.transparent
            : SeedTopNavigationTone.layer,
        leading: SeedTopNavigationIconButton(
          icon: const Icon(Icons.close),
          semanticsLabel: 'Close',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
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
          style: transparent ? const TextStyle(color: Colors.white) : null,
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
          onPressed: () => _snack(context, 'Notification'),
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
                : const Icon(Icons.error, size: 40, color: Colors.red),
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
