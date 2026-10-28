import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';

/// The navigation, tab, and list examples from stackflow-spa.
Widget? buildNavigationPage(
  String activity,
  BuildContext context, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
  Object? arguments,
}) {
  const names = {
    'ActivityTabs',
    'ActivityAnimatedTabs',
    'ActivitySwipeableTabs',
    'ActivityTabsAutoHeightLazy',
    'ActivityChipTabsScrollFog',
    'ActivityPagination',
    'ActivitySideNavigation',
    'ActivityListItem',
    'ActivityListImageFrame',
    'ActivityListButtonItem',
    'ActivityListLinkItem',
    'ActivityListSwitchItem',
    'ActivityListCheckItem',
    'ActivityListRadioItem',
  };
  if (!names.contains(activity)) return null;
  return _NavigationPage(
    key: ValueKey(activity),
    activity: activity,
    navigate: navigate,
  );
}

class _NavigationPage extends StatefulWidget {
  const _NavigationPage({
    super.key,
    required this.activity,
    required this.navigate,
  });
  final String activity;
  final SpaNavigate navigate;

  @override
  State<_NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<_NavigationPage> {
  int _page = 5;
  SeedTablePaginationValue _table = const SeedTablePaginationValue(
    page: 3,
    pageSize: 25,
  );
  SeedTablePaginationValue _unknown = const SeedTablePaginationValue(
    page: 2,
    pageSize: 10,
  );
  String _navSelection = '홈';
  bool _collapsed = false;
  SeedSideNavTone _navTone = SeedSideNavTone.neutral;
  String _density = 'medium';
  int _simpleTab = 0;
  bool _tabTwoLoaded = false;
  Timer? _tabTwoTimer;
  int _swipeTab = 0;
  final PageController _swipePages = PageController();
  String _radioSelection = 'prefix-title-unchecked-suffix-none';
  final Map<String, bool> _checks = {};

  @override
  void initState() {
    super.initState();
    if (widget.activity == 'ActivitySideNavigation') _restoreCollapsed();
    if (widget.activity == 'ActivityTabs') {
      _tabTwoTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) setState(() => _tabTwoLoaded = true);
      });
    }
  }

  Future<void> _restoreCollapsed() async {
    final collapsed =
        await SharedPreferencesAsync().getBool('sidebar-collapsed') ?? false;
    if (mounted) setState(() => _collapsed = collapsed);
  }

  void _setCollapsed(bool value) {
    setState(() => _collapsed = value);
    unawaited(SharedPreferencesAsync().setBool('sidebar-collapsed', value));
  }

  @override
  void dispose() {
    _tabTwoTimer?.cancel();
    _swipePages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.activity) {
      case 'ActivityTabs':
        return _tabs();
      case 'ActivityAnimatedTabs':
      case 'ActivitySwipeableTabs':
      case 'ActivityTabsAutoHeightLazy':
      case 'ActivityChipTabsScrollFog':
        return _carouselTabs();
      case 'ActivityPagination':
        return _pagination();
      case 'ActivitySideNavigation':
        return _sideNavigation();
      case 'ActivityListImageFrame':
        return _imageCases();
      default:
        return _variantList();
    }
  }

  Widget _tabs() {
    const labels = [
      'Tab 1',
      'Tab 2',
      'Tab 3',
      'Tab 4',
      'Tab 1231235',
      'Tab 12312312361',
      'Tab 7123123123123',
    ];
    return CustomScrollView(
      key: ValueKey('tab-scroll-$_simpleTab'),
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Sticky Tablist'),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabsDelegate(
            background: context.seedColor.bg.layerDefault,
            child: SeedTabs(
              items: [
                for (var i = 0; i < labels.length; i++)
                  SeedTabItem(label: labels[i], value: '${i + 1}'),
              ],
              selectedIndex: _simpleTab,
              onTabSelected: (index) => setState(() => _simpleTab = index),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _simpleTab == 1
              ? (_tabTwoLoaded
                    ? _panel('Tab 2 content', height: 102)
                    : const Text('Loading...'))
              : _panel(
                  'Tab ${_simpleTab + 1} content',
                  height: _simpleTab == 0 ? 1000 : 102,
                ),
        ),
      ],
    );
  }

  Widget _carouselTabs() {
    final chip = widget.activity == 'ActivityChipTabsScrollFog';
    final swipe = widget.activity == 'ActivitySwipeableTabs';
    final animated = widget.activity == 'ActivityAnimatedTabs';
    if (swipe) {
      return Column(
        children: [
          SeedTabs(
            items: const [
              SeedTabItem(label: 'Tab 1', value: '1'),
              SeedTabItem(label: 'Disabled', value: 'x', enabled: false),
              SeedTabItem(
                label: 'Tab 2',
                value: '2',
                showNotificationDot: true,
              ),
            ],
            selectedIndex: _swipeTab == 0 ? 0 : 2,
            fill: true,
            onTabSelected: (index) {
              if (index == 1) return;
              _swipePages.animateToPage(
                index == 0 ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _swipePages,
              onPageChanged: (index) => setState(() => _swipeTab = index),
              children: [
                _feedList(withDialog: true),
                _feedList(withDialog: false),
              ],
            ),
          ),
        ],
      );
    }
    if (animated) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SeedTabs(
              items: const [
                SeedTabItem(label: 'Tab 1', value: '1'),
                SeedTabItem(label: 'Disabled', value: 'x', enabled: false),
                SeedTabItem(
                  label: 'Tab 2',
                  value: '2',
                  showNotificationDot: true,
                ),
              ],
              fill: true,
              selectedIndex: _swipeTab == 0 ? 0 : 2,
              onTabSelected: (index) {
                if (index != 1) setState(() => _swipeTab = index == 0 ? 0 : 1);
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: _swipeTab == 0
                  ? _panel('Tab 1 content', height: 1000)
                  : _panel('Tab 2 content', height: 92),
            ),
          ],
        ),
      );
    }
    final items = chip
        ? <SeedTabItem>[
            const SeedTabItem(label: 'Immediate', value: '1'),
            const SeedTabItem(label: 'Async', value: '2'),
            const SeedTabItem(label: 'Immediate 2', value: '3'),
            const SeedTabItem(label: 'Suspense', value: '4'),
            const SeedTabItem(label: 'Immediate 3', value: '5'),
            for (var n = 6; n <= 10; n++)
              SeedTabItem(label: '라벨$n', value: '$n'),
          ]
        : const <SeedTabItem>[
            SeedTabItem(label: 'Immediate', value: '1'),
            SeedTabItem(label: 'Async', value: '2'),
            SeedTabItem(label: 'Immediate 2', value: '3'),
            SeedTabItem(label: 'Suspense', value: '4'),
            SeedTabItem(label: 'Immediate 3', value: '5'),
          ];
    final children = <Widget>[
      _panel(
        'Tab 1: Immediate (100px)',
        height: 132,
        color: context.seedColor.bg.informativeSolid,
        foreground: context.seedColor.fg.informativeContrast,
      ),
      const _DelayedPanel(
        key: ValueKey('async-2'),
        delay: Duration(seconds: 1),
        height: 500,
        label: 'Tab 2: Async loaded (500px, 1s delay)',
      ),
      _panel(
        'Tab 3: Immediate (200px)',
        height: 200,
        color: context.seedColor.bg.positiveSolid,
        foreground: context.seedColor.fg.positiveContrast,
      ),
      const _DelayedPanel(
        key: ValueKey('lazy-4'),
        delay: Duration(milliseconds: 1500),
        height: 400,
        label: 'Lazy loaded content (400px tall, 1500ms delay)',
        loadingLabel: 'Suspense loading...',
      ),
      _panel(
        'Tab 5: Immediate (150px)',
        height: 150,
        color: context.seedColor.bg.warningSolid,
        foreground: context.seedColor.fg.warningContrast,
      ),
      if (chip)
        for (var n = 6; n <= 10; n++)
          _panel('Tab $n: Immediate (120px)', height: 120),
    ];
    final explanation = chip
        ? 'Check 1 (DES-1532): tab 2/4 content loads after a delay and the carousel height follows.\n'
              'Check 2 (DES-1889): the chip strip scrolls horizontally on WKWebView/Safari.'
        : 'Bug: Tab 2/4 content loads after delay but carousel height stays fixed.';
    final tabs = SeedTabsView(
      items: items,
      defaultValue: '1',
      variant: chip ? SeedTabsVariant.chipSolid : SeedTabsVariant.line,
      showScrollFog: chip,
      fill: !chip,
      carousel: true,
      swipeable: true,
      dynamicHeight: true,
      lazyMount: true,
      children: children,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              explanation,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          tabs,
        ],
      ),
    );
  }

  Widget _panel(
    String label, {
    required double height,
    Color? color,
    Color? foreground,
  }) => Container(
    height: height,
    alignment: Alignment.topLeft,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Text(label, style: TextStyle(color: foreground)),
  );

  Widget _feedList({required bool withDialog}) {
    final feed = ListView(
      children: [
        if (withDialog) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                SizedBox(
                  width: 1000,
                  child: Text(
                    'Scrolling Area',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          SeedListItem(
            titleText: 'AlertDialog (step)',
            onTap: _showFeedDialog,
            suffix: const Icon(Icons.chevron_right),
          ),
        ],
        for (var i = 0; i < 10; i++)
          SeedListItem(
            titleText: '독서 습관 만들기',
            detail: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('하루 10페이지부터 시작하자. 취침 전 20분 독서는 수면의 질도 높여주는 일석이조 습관이다.'),
                SizedBox(height: 8),
                Text('라이프스타일 ⸱ 서초2동'),
              ],
            ),
            onTap: () {},
            showDivider: false,
          ),
      ],
    );
    return withDialog
        ? SeedPullToRefresh(
            onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
            child: feed,
          )
        : feed;
  }

  void _showFeedDialog() {
    showSeedDialog<void>(
      context: context,
      child: SeedAlertDialog(
        title: '제목',
        description: 'Lorem ipsum dolor sit amet consectetur adipisicing elit.',
        footer: Builder(
          builder: (dialogContext) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SeedButton(
                label: '확인',
                onPressed: () => Navigator.pop(dialogContext),
              ),
              const SizedBox(height: 8),
              SeedButton(
                label: 'ActivityChipButton',
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
  }

  Widget _pagination() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Pagination',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 12),
      Center(
        child: SeedPagination(
          totalPages: 10,
          page: _page,
          onPageChanged: (page) => setState(() => _page = page),
          semanticsLabel: '게시글 페이지',
        ),
      ),
      const SizedBox(height: 12),
      Text('현재 페이지: $_page'),
      const SizedBox(height: 32),
      const Text(
        'Table Pagination',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 640,
          child: SeedTablePagination(
            totalItems: 237,
            value: _table,
            onValueChange: (next, _) => setState(() => _table = next),
            semanticsLabel: '상품 표 페이지',
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text('${_table.page}페이지 · 페이지당 ${_table.pageSize}개'),
      const SizedBox(height: 32),
      const Text(
        'Unknown Total',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 640,
          child: SeedTablePagination(
            value: _unknown,
            onValueChange: (next, _) => setState(() => _unknown = next),
            hasPreviousPage: _unknown.page > 1,
            hasNextPage: _unknown.page < 5,
            currentPageItemCount: _unknown.page == 5 ? 7 : _unknown.pageSize,
            semanticsLabel: '전체 개수를 알 수 없는 상품 표 페이지',
          ),
        ),
      ),
    ],
  );

  SeedSideNavItem _navItem(
    String label,
    IconData icon, {
    bool disabled = false,
    List<String>? children,
    bool defaultOpen = false,
  }) => SeedSideNavItem(
    id: label,
    label: label,
    icon: icon,
    disabled: disabled,
    defaultOpen: defaultOpen,
    onTap: () => setState(() => _navSelection = label),
    subItems: children
        ?.map(
          (sub) => SeedSideNavSubItem(
            id: sub,
            label: sub,
            enabled: sub != '전환 추적 관리',
            onTap: () => setState(() => _navSelection = sub),
          ),
        )
        .toList(),
  );

  Widget _sideNavigation() {
    final groups = [
      SeedSideNavGroup(
        label: '광고',
        items: [
          _navItem('홈', Icons.home),
          _navItem(
            '광고 관리',
            Icons.campaign,
            defaultOpen: true,
            children: ['디스플레이 광고 관리', '검색 광고 관리'],
          ),
          _navItem('광고 만들기', Icons.add_circle),
          _navItem('보고서', Icons.description),
          _navItem(
            '광고 도구',
            Icons.handyman,
            defaultOpen: true,
            children: ['카탈로그 관리', '전환 추적 관리', '맞춤 타겟 관리', '리드폼 관리', '대량 관리'],
          ),
        ],
      ),
      SeedSideNavGroup(
        label: '결제',
        items: [
          _navItem('광고캐시', Icons.paid, children: ['광고캐시 관리', '세금계산서']),
          _navItem('변경내역', Icons.receipt_long, disabled: true),
        ],
      ),
      SeedSideNavGroup(
        label: '계정',
        items: [
          _navItem(
            '설정',
            Icons.settings,
            children: ['광고계정 관리', '심사서류 관리', '운영자 관리', '광고 대행사 관리', '내 알림 관리'],
          ),
        ],
      ),
      SeedSideNavGroup(
        label: '성과 분석',
        items: [
          _navItem('대시보드', Icons.bar_chart),
          _navItem(
            '성과 리포트',
            Icons.star,
            children: ['일간 리포트', '주간 리포트', '월간 리포트', '맞춤 기간 리포트'],
          ),
          _navItem('목표 관리', Icons.flag),
          _navItem('저장된 필터', Icons.bookmark),
        ],
      ),
      SeedSideNavGroup(
        label: '비즈니스',
        items: [
          _navItem('비즈프로필 관리', Icons.store),
          _navItem(
            '쿠폰',
            Icons.local_offer,
            children: ['쿠폰 만들기', '발급 내역', '사용 내역'],
          ),
          _navItem('프로모션', Icons.card_giftcard),
        ],
      ),
      SeedSideNavGroup(
        label: '고객 관리',
        items: [
          _navItem(
            '타겟 고객',
            Icons.person,
            children: ['고객 세그먼트', '리타겟팅 목록', '유사 타겟'],
          ),
          _navItem('고객 인사이트', Icons.people),
          _navItem('알림 발송', Icons.notifications),
        ],
      ),
      SeedSideNavGroup(
        label: '기타',
        items: [
          _navItem('활동 로그', Icons.history),
          _navItem('권한 관리', Icons.lock),
        ],
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Row(
            children: [
              SeedSideNavigation(
                groups: groups,
                selectedId: _navSelection,
                collapsed: _collapsed,
                onCollapsedChange: _setCollapsed,
                showCollapseButton: true,
                tone: _navTone,
                width: 240,
                footer: IconButton(
                  tooltip: '알림',
                  icon: const Icon(Icons.notifications),
                  onPressed: () => setState(() => _navSelection = '알림'),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _density == 'low'
                        ? 720
                        : _density == 'medium'
                        ? (constraints.maxWidth >= 1280 ? 1040 : 720)
                        : double.infinity,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text('Side Navigation Tone'),
                        SeedSelectBoxGroup(
                          columns:
                              constraints.maxWidth - (_collapsed ? 56 : 240) <
                                  400
                              ? 1
                              : 2,
                          value: _navTone.name,
                          onValueChange: (value) {
                            if (value is String) {
                              setState(
                                () => _navTone = SeedSideNavTone.values.byName(
                                  value,
                                ),
                              );
                            }
                          },
                          children: [
                            for (final tone in SeedSideNavTone.values)
                              SeedSelectBox(
                                title: tone.name,
                                value: tone.name,
                                control: SeedSelectBoxControl.radiomark,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Layout Density'),
                        SeedSelectBoxGroup(
                          columns:
                              constraints.maxWidth - (_collapsed ? 56 : 240) <
                                  400
                              ? 1
                              : 3,
                          value: _density,
                          onValueChange: (value) {
                            if (value is String) {
                              setState(() => _density = value);
                            }
                          },
                          children: [
                            for (final density in ['low', 'medium', 'high'])
                              SeedSelectBox(
                                title: density,
                                value: density,
                                control: SeedSelectBoxControl.radiomark,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageCases() {
    const cases = <(String, String, double, double, double?)>[
      ('ratio=1, width=96', 'src 320x180', 96, 1, null),
      ('ratio=4/3, width=120', 'src 180x320', 120, 4 / 3, null),
      ('ratio=16/9, width=160', 'src 240x240', 160, 16 / 9, null),
      ('ratio=4/3, width=160, height=120', 'src 320x180', 160, 4 / 3, 120),
      ('ratio=1, width=120, height=80', 'src 320x180', 120, 1, 80),
      ('ratio=3/4, width=120', 'src 180x320', 120, 3 / 4, null),
    ];
    return SeedPullToRefresh(
      onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
      child: ListView.builder(
        itemCount: cases.length,
        itemBuilder: (context, index) {
          final (title, detail, width, ratio, height) = cases[index];
          return SeedListItem(
            titleText: title,
            detailText: detail,
            showDivider: index < cases.length - 1,
            prefix: SizedBox(
              width: width,
              height: height ?? width / ratio,
              child: SeedImageFrame(
                customRatio: ratio,
                stroke: true,
                semanticLabel: title,
                imageProvider: const NetworkImage(
                  'https://avatars.githubusercontent.com/u/54893898?v=4',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<_ListCase> _variants() {
    final activity = widget.activity;
    final choice =
        activity == 'ActivityListSwitchItem' ||
        activity == 'ActivityListCheckItem' ||
        activity == 'ActivityListRadioItem';
    final isSwitch = activity == 'ActivityListSwitchItem';
    final isRadio = activity == 'ActivityListRadioItem';
    final isButton = activity == 'ActivityListButtonItem';
    final contents = <String>[
      'title',
      'title-detail',
      if (!isSwitch) 'title-highlighted',
      if (!isSwitch) 'title-detail-highlighted',
      if (isButton) 'title-detail-disabled',
      if (isButton) 'title-detail-highlighted-disabled',
    ];
    final states = isSwitch
        ? <String>[
            'unchecked',
            'checked',
            'disabled',
            'disabled-checked',
            'neutral-unchecked',
            'neutral-checked',
            'neutral-disabled',
            'neutral-disabled-checked',
          ]
        : isRadio
        ? <String>['unchecked', 'disabled']
        : <String>[
            'unchecked',
            'checked',
            'disabled',
            'disabled-checked',
            'ghost-unchecked',
            'ghost-checked',
            'ghost-disabled',
            'ghost-disabled-checked',
          ];
    final result = <_ListCase>[];
    if (!choice) {
      for (final prefix in ['none', 'icon', 'avatar']) {
        for (final content in contents) {
          for (final suffix in [
            'none',
            'icon-info',
            'icon-chevron',
            'buttons',
          ]) {
            result.add(
              _ListCase(
                '$prefix-$content-$suffix',
                content,
                prefix: prefix,
                suffix: suffix,
                disabled: content.contains('disabled'),
              ),
            );
          }
        }
      }
    } else {
      for (final position in ['prefix', 'suffix']) {
        for (final content in contents) {
          for (final state in states) {
            final sideVariants = position == 'prefix'
                ? ['none', 'icon-info', 'icon-chevron']
                : ['none', 'icon', 'avatar'];
            for (final side in sideVariants) {
              result.add(
                _ListCase(
                  '$position-$content-$state-${position == 'prefix' ? 'suffix' : 'prefix'}-$side',
                  content,
                  prefix: position == 'suffix' ? side : 'none',
                  suffix: position == 'prefix' ? side : 'none',
                  position: position,
                  state: state,
                  disabled: state.contains('disabled'),
                ),
              );
            }
          }
        }
      }
    }
    return result;
  }

  Widget _variantList() {
    final entries = _variants();
    return SeedPullToRefresh(
      onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) =>
            _variantItem(entries[index], index == entries.length - 1),
      ),
    );
  }

  Widget _variantItem(_ListCase entry, bool isLast) {
    final activity = widget.activity;
    final check = activity == 'ActivityListCheckItem';
    final radio = activity == 'ActivityListRadioItem';
    final toggle = activity == 'ActivityListSwitchItem';
    final button = activity == 'ActivityListButtonItem';
    final link = activity == 'ActivityListLinkItem';
    final selectable = check || radio || toggle;
    final value = _checks.putIfAbsent(
      entry.key,
      () => entry.state == 'checked' || entry.state.endsWith('-checked'),
    );
    final marked = radio ? _radioSelection == entry.key : value;
    final tone = entry.state.startsWith('neutral')
        ? SeedControlTone.neutral
        : SeedControlTone.brand;
    final mark = radio
        ? IgnorePointer(
            child: SeedRadio<String>(
              value: entry.key,
              groupValue: _radioSelection,
              onChanged: (_) {},
              enabled: !entry.disabled,
              size: SeedRadioSize.large,
            ),
          )
        : check
        ? SeedCheckmark(
            value: value,
            shape: entry.state.startsWith('ghost')
                ? SeedCheckboxShape.ghost
                : SeedCheckboxShape.square,
            size: SeedCheckboxSize.large,
            enabled: !entry.disabled,
          )
        : toggle
        ? SeedSwitchMark(
            checked: value,
            tone: tone,
            enabled: !entry.disabled,
            interactive: false,
          )
        : null;
    final prefix = selectable && entry.position == 'prefix'
        ? mark
        : _prefix(entry.prefix);
    final suffix = selectable && entry.position == 'suffix'
        ? mark
        : _suffix(entry.suffix);
    String? detail;
    if (entry.content.contains('detail')) {
      detail = selectable
          ? (radio ? '추가 설명이 포함된 라디오입니다' : '추가 설명이 포함된 체크박스입니다')
          : 'lorem ipsum dolor sit amet';
      if (entry.content == 'title-detail-highlighted') {
        detail = 'lorem ipsum dolor sit amet';
      }
    }
    return SeedListItem(
      key: ValueKey(entry.key),
      titleText: entry.key,
      detailText: detail,
      prefix: prefix,
      suffix: suffix,
      highlighted: entry.content.contains('highlighted'),
      enabled: !entry.disabled,
      checked: (check || radio) ? marked : null,
      toggled: toggle ? marked : null,
      showDivider: !isLast,
      onTap: selectable
          ? () => setState(() {
              if (radio) {
                _radioSelection = entry.key;
              } else {
                _checks[entry.key] = !value;
              }
            })
          : button
          ? () => _showListDialog()
          : link
          ? () => _showLinkDestination()
          : null,
    );
  }

  Widget? _prefix(String variant) => switch (variant) {
    'icon' => const Icon(Icons.account_circle_outlined),
    'avatar' => const SeedAvatar(
      image: NetworkImage(
        'https://avatars.githubusercontent.com/u/54893898?v=4',
      ),
      placeholder: SeedIdentityPlaceholder(),
      size: SeedAvatarSize.size48,
    ),
    _ => null,
  };

  Widget? _suffix(String variant) => switch (variant) {
    'icon-info' => const Icon(Icons.info_outline),
    'icon-chevron' => const Icon(Icons.chevron_right),
    'buttons' => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SeedButton(
          size: SeedButtonSize.xsmall,
          label: '라벨',
          variant: SeedButtonVariant.neutralWeak,
          onPressed: () => _message('Button clicked'),
        ),
        SeedButton(
          size: SeedButtonSize.xsmall,
          label: '라벨',
          variant: SeedButtonVariant.neutralWeak,
          onPressed: () => _message('Button clicked'),
        ),
      ],
    ),
    _ => null,
  };

  void _showListDialog() => showSeedAlertDialog(
    context: context,
    title: 'consectetur',
    description: 'Veniam qui nulla minim sit ad Lorem fugiat consequat ad consequat velit ullamco proident id.',
    confirmText: '닫기',
    cancelText: null,
  );

  Future<void> _showLinkDestination() async {
    final opened = await launchUrl(
      Uri.parse('https://example.com'),
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!opened && mounted) _message('링크를 열지 못했습니다.');
  }

  void _message(String value) =>
      SeedSnackbarProvider.of(context)
          .show(child: SeedSnackbar(message: value));
}

class _ListCase {
  const _ListCase(
    this.key,
    this.content, {
    this.prefix = 'none',
    this.suffix = 'none',
    this.position = '',
    this.state = '',
    this.disabled = false,
  });
  final String key;
  final String content;
  final String prefix;
  final String suffix;
  final String position;
  final String state;
  final bool disabled;
}

class _DelayedPanel extends StatefulWidget {
  const _DelayedPanel({
    super.key,
    required this.delay,
    required this.label,
    required this.height,
    this.loadingLabel = 'Loading...',
  });
  final Duration delay;
  final String label;
  final String loadingLabel;
  final double height;

  @override
  State<_DelayedPanel> createState() => _DelayedPanelState();
}

class _DelayedPanelState extends State<_DelayedPanel> {
  Timer? _timer;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _loaded
      ? Container(
          height: widget.height,
          padding: const EdgeInsets.all(16),
          color: context.seedColor.bg.criticalSolid,
          child: Text(
            widget.label,
            style: TextStyle(color: context.seedColor.fg.criticalContrast),
          ),
        )
      : Padding(
          padding: const EdgeInsets.all(16),
          child: Text(widget.loadingLabel),
        );
}

class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabsDelegate({required this.child, required this.background});
  final Widget child;
  final Color background;
  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(color: background, child: child);
  @override
  bool shouldRebuild(_StickyTabsDelegate oldDelegate) => true;
}
