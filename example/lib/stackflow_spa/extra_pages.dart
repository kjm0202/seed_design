import 'package:flutter/material.dart';
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';

/// React Stackflow SPA's indirect pages. The host provides the Scaffold/AppBar.
Widget? buildExtraPage(
  String activity,
  BuildContext context, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
  Object? arguments,
}) {
  switch (activity) {
    case 'ActivityDetail':
      return _DetailPage(navigate: navigate, arguments: arguments);
    case 'ActivityCategorySheet':
      return _CategorySheetRoute(arguments: arguments);
    case 'ActivityAppBarSlot':
      return SpaOwnScaffold(
        child: _AppBarSlotPage(navigate: navigate, goBack: goBack),
      );
    case 'ActivityDialog':
      return _DialogPage(navigate: navigate);
    case 'ActivityAppScreenIntersectionObserver':
      return SpaOwnScaffold(child: _IntersectionObserverPage(goBack: goBack));
    case 'ActivityAlertDialogStackflow':
      return _StackflowAlertDialogPage(goBack: goBack);
    case 'ActivityArticlePreventDrag':
      return const _ArticlePreventDragPage();
    default:
      return null;
  }
}

const _gap = SizedBox(height: 16);
const _styles = ['slideFromRightIOS', 'fadeFromBottomAndroid', 'fadeIn'];

Widget _button(
  String text,
  VoidCallback? action, {
  SeedButtonVariant variant = SeedButtonVariant.neutralSolid,
  bool fullWidth = true,
}) => SeedButton(
  label: text,
  onPressed: action,
  variant: variant,
  isFullWidth: fullWidth,
);

void _message(BuildContext context, String message) {
  SeedSnackbarProvider.of(context).show(
    strategy: SeedSnackbarStrategy.immediate,
    child: SeedSnackbar(message: message),
  );
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.navigate, this.arguments});
  final SpaNavigate navigate;
  final Object? arguments;

  @override
  Widget build(BuildContext context) {
    final map = arguments is Map ? arguments! as Map : const {};
    final title = map['title'] is String ? map['title'] as String : 'Detail';
    final body = map['body'] is String ? map['body'] as String : '';
    final current = map['transitionStyle'] is String
        ? map['transitionStyle'] as String
        : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(body, style: const TextStyle(fontSize: 16, height: 1.5)),
        if (current != null) ...[
          const SizedBox(height: 8),
          Text('transitionStyle: $current'),
        ],
        const SizedBox(height: 24),
        for (final style in _styles) ...[
          _button(
            'transitionStyle: $style',
            () => navigate(
              'ActivityTransitionStyle',
              arguments: {'transitionStyle': style},
            ),
            variant: current == style
                ? SeedButtonVariant.neutralWeak
                : SeedButtonVariant.neutralSolid,
          ),
          const SizedBox(height: 8),
        ],
        _gap,
        _button(
          '홈으로',
          () => navigate('ActivityHome'),
          variant: SeedButtonVariant.neutralWeak,
        ),
      ],
    );
  }
}

const _categories = <({String value, String label})>[
  (value: 'electronics', label: '전자기기'),
  (value: 'fashion', label: '패션/의류'),
  (value: 'food', label: '식품/음료'),
  (value: 'home', label: '가구/인테리어'),
  (value: 'sports', label: '스포츠/레저'),
  (value: 'beauty', label: '뷰티/미용'),
  (value: 'books', label: '도서/음반'),
  (value: 'toys', label: '완구/취미'),
  (value: 'pet', label: '반려동물용품'),
  (value: 'baby', label: '유아동'),
  (value: 'digital', label: '디지털/가전'),
  (value: 'car', label: '자동차용품'),
  (value: 'office', label: '문구/오피스'),
  (value: 'health', label: '건강/의료'),
  (value: 'travel', label: '여행/티켓'),
  (value: 'kitchen', label: '주방용품'),
  (value: 'garden', label: '정원/원예'),
  (value: 'music', label: '악기/음향'),
  (value: 'art', label: '미술/공예'),
  (value: 'jewelry', label: '쥬얼리/시계'),
  (value: 'camping', label: '캠핑/아웃도어'),
  (value: 'fishing', label: '낚시용품'),
  (value: 'golf', label: '골프'),
  (value: 'cycling', label: '자전거'),
  (value: 'game', label: '게임/콘솔'),
  (value: 'collectibles', label: '수집품/굿즈'),
  (value: 'handmade', label: '핸드메이드'),
  (value: 'vintage', label: '빈티지/앤틱'),
  (value: 'rental', label: '대여서비스'),
  (value: 'etc', label: '기타'),
];

/// Presents a sheet automatically; returns {value, label} to the caller route.
class _CategorySheetRoute extends StatefulWidget {
  const _CategorySheetRoute({this.arguments});
  final Object? arguments;
  @override
  State<_CategorySheetRoute> createState() => _CategorySheetRouteState();
}

class _CategorySheetRouteState extends State<_CategorySheetRoute> {
  bool opened = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (opened) return;
    opened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _present();
    });
  }

  Future<void> _present() async {
    final args = widget.arguments is Map ? widget.arguments! as Map : const {};
    final initial = args['defaultValue'] is String
        ? args['defaultValue'] as String
        : null;
    final result = await showSeedBottomSheet<Map<String, String>>(
      context: context,
      child: _CategorySheetContent(initial: initial),
    );
    if (mounted) {
      // Finish the activity route with the sheet's result.
      Navigator.of(context).pop<Map<String, String>>(result);
    }
  }

  @override
  Widget build(BuildContext context) => const Center(child: Text('카테고리 선택'));
}

class _CategorySheetContent extends StatefulWidget {
  const _CategorySheetContent({this.initial});
  final String? initial;
  @override
  State<_CategorySheetContent> createState() => _CategorySheetContentState();
}

class _CategorySheetContentState extends State<_CategorySheetContent> {
  late String? selected = _categories.any((c) => c.value == widget.initial)
      ? widget.initial
      : null;

  void _confirm() {
    final value = selected;
    if (value == null) return;
    final label = _categories.firstWhere((item) => item.value == value).label;
    Navigator.of(context)
        .pop<Map<String, String>>({'value': value, 'label': label});
  }

  @override
  Widget build(BuildContext context) => SeedBottomSheet(
    title: '카테고리 선택',
    showHandle: true,
    maxHeight: MediaQuery.sizeOf(context).height * .85,
    contentPadding: EdgeInsets.zero,
    content: SizedBox(
      height: 400,
      child: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return SeedRadioListItem<String>(
            title: category.label,
            value: category.value,
            groupValue: selected,
            onChanged: (next) => setState(() => selected = next),
            showDivider: index < _categories.length - 1,
          );
        },
      ),
    ),
    footer: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SeedButton(
        label: '완료',
        onPressed: selected == null ? null : _confirm,
        enabled: selected != null,
        size: SeedButtonSize.large,
        variant: SeedButtonVariant.neutralSolid,
        isFullWidth: true,
      ),
    ),
  );
}

class _AppBarSlotPage extends StatelessWidget {
  const _AppBarSlotPage({required this.navigate, required this.goBack});
  final SpaNavigate navigate;
  final VoidCallback goBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.seedColor.bg.layerDefault,
    appBar: SeedTopNavigation(
      leading: SeedTopNavigationIconButton(
        icon: const Icon(Icons.chevron_left),
        semanticsLabel: '뒤로',
        onPressed: goBack,
      ),
      centerTitle: false,
      title: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: context.seedColor.bg.neutralWeak,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '검색어를 입력하세요',
          style: context.seedTypography.t4Regular.copyWith(
            color: context.seedColor.fg.neutralMuted,
          ),
        ),
      ),
      actions: [
        for (var i = 0; i < 2; i++)
          SeedTopNavigationIconButton(
            semanticsLabel: '알림 $i',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => _message(context, '알림 $i'),
          ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'AppBar.Slot은 커스텀 요소에 stackflow 트랜지션 애니메이션을 적용합니다. 이 페이지에서 뒤로 swipe하면 검색바가 IconButton과 동일하게 fade 트랜지션됩니다.',
        ),
        _gap,
        _button('이 액티비티 다시 열기', () => navigate('ActivityAppBarSlot')),
      ],
    ),
  );
}

class _DialogPage extends StatefulWidget {
  const _DialogPage({required this.navigate});
  final SpaNavigate navigate;
  @override
  State<_DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<_DialogPage> {
  bool overflow = true;

  Future<void> _openDialog() => showSeedDialog<void>(
    context: context,
    child: SeedDialog(
      size: SeedDialogSize.medium,
      title: '스크롤 테스트',
      description: 'body가 오버플로일 때만 하단 fade와 padding-bottom이 적용됩니다',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 1; i <= (overflow ? 16 : 1); i++) ...[
            Text(
              '$i. 본문이 길어지면 Body 영역만 스크롤됩니다. '
              '오버플로 상태에서만 하단이 서서히 사라지는 마스크와 '
              'padding-bottom이 적용되고, 스크롤하면 헤더 아래에 구분선이 나타납니다.',
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
      footer: Builder(
        builder: (dialogContext) => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _button(
              '취소',
              () => Navigator.of(dialogContext).pop(),
              fullWidth: false,
              variant: SeedButtonVariant.neutralWeak,
            ),
            const SizedBox(width: 8),
            _button(
              '확인',
              () => Navigator.of(dialogContext).pop(),
              fullWidth: false,
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      SeedSwitch(
        label: '긴 본문 (오버플로)',
        size: SeedSwitchSize.size16,
        checked: overflow,
        onCheckedChange: (next) => setState(() => overflow = next),
      ),
      const SizedBox(height: 20),
      _button('다이얼로그 열기', _openDialog),
      _gap,
      _button(
        '홈으로',
        () => widget.navigate('ActivityHome'),
        variant: SeedButtonVariant.ghost,
      ),
    ],
  );
}

class _IntersectionObserverPage extends StatefulWidget {
  const _IntersectionObserverPage({required this.goBack});
  final VoidCallback goBack;
  @override
  State<_IntersectionObserverPage> createState() =>
      _IntersectionObserverPageState();
}

class _IntersectionObserverPageState extends State<_IntersectionObserverPage> {
  final ScrollController scroll = ScrollController();
  bool whiteVisible = true;

  @override
  void initState() {
    super.initState();
    scroll.addListener(_updateTone);
  }

  void _updateTone() {
    if (!scroll.hasClients) return;
    final visible = scroll.offset < 400;
    if (visible != whiteVisible) setState(() => whiteVisible = visible);
  }

  @override
  void dispose() {
    scroll.removeListener(_updateTone);
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.seedColor.bg.layerDefault,
    extendBodyBehindAppBar: true,
    appBar: SeedTopNavigation(
      titleText: 'Preview',
      platform: SeedTopNavigationPlatform.cupertino,
      tone: whiteVisible
          ? SeedTopNavigationTone.transparent
          : SeedTopNavigationTone.layer,
      gradient: whiteVisible,
      leading: SeedTopNavigationIconButton(
        semanticsLabel: 'Close',
        icon: const Icon(Icons.close),
        onPressed: widget.goBack,
      ),
      actions: [
        SeedTopNavigationIconButton(
          semanticsLabel: 'Notification',
          icon: const Icon(Icons.notifications),
          onPressed: () => _message(context, 'Notification'),
        ),
      ],
    ),
    body: ListView(
      controller: scroll,
      padding: EdgeInsets.zero,
      children: const [
        SizedBox(
          height: 400,
          child: ColoredBox(
            color: Colors.white,
            child: Center(
              child: Text('하얀 이미지', style: TextStyle(color: Colors.black87)),
            ),
          ),
        ),
        SizedBox(
          height: 1000,
          child: ColoredBox(
            color: SeedPalette.gray800Light,
            child: Center(
              child: Text('컨텐츠 영역', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    ),
  );
}

class _StackflowAlertDialogPage extends StatefulWidget {
  const _StackflowAlertDialogPage({required this.goBack});
  final VoidCallback goBack;
  @override
  State<_StackflowAlertDialogPage> createState() =>
      _StackflowAlertDialogPageState();
}

class _StackflowAlertDialogPageState extends State<_StackflowAlertDialogPage> {
  bool shown = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (shown) return;
    shown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showAlert();
    });
  }

  Future<void> _showAlert() async {
    await showSeedAlertDialog(
      context: context,
      title: '제목',
      description: 'Stackflow',
      confirmText: '확인',
      cancelText: null,
      barrierDismissible: false,
    );
    if (mounted) widget.goBack();
  }

  @override
  Widget build(BuildContext context) => const Center(child: Text('Stackflow'));
}

class _ArticlePreventDragPage extends StatelessWidget {
  const _ArticlePreventDragPage();

  @override
  Widget build(BuildContext context) => SeedTabsView(
    items: const [
      SeedTabItem(label: 'Tab 1', value: '1'),
      SeedTabItem(label: 'Tab 2', value: '2'),
    ],
    carousel: true,
    swipeable: true,
    fill: true,
    children: [
      ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const SeedPageBanner(
            prefixIcon: Icon(Icons.error),
            description: '상위 요소에 user-select: none; 스타일 적용됨',
            tone: SeedPageBannerTone.warning,
            variant: SeedPageBannerVariant.solid,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              // Consume horizontal drags within Article, while allowing text
              // selection; the rest of the page can switch tabs by swiping.
              onHorizontalDragStart: (_) {},
              onHorizontalDragUpdate: (_) {},
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Article',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                  ),
                  SizedBox(height: 12),
                  SelectableText(
                    '이 요소는 Article 내부에 있으므로 텍스트 선택이 가능합니다. '
                    '이 Article은 Tabs 제스처를 호출하지 않도록 설정되어 있습니다. '
                    '여기를 왼쪽으로 스와이프하면 탭이 전환되는 대신 텍스트가 선택됩니다.',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Article 외부',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                ),
                SizedBox(height: 12),
                Text(
                  '이 요소는 Article 외부에 있으므로 텍스트 선택이 불가능합니다. '
                  '이 요소는 탭 스와이프를 호출할 수 있습니다. '
                  '여기를 왼쪽으로 스와이프해보세요.',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
      const Padding(padding: EdgeInsets.all(16), child: Text('안녕하세요!')),
    ],
  );
}
