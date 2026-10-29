import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';

/// Mirrors `examples/stackflow-spa/src/demo-data.ts`.
class SpaArticle {
  const SpaArticle(
    this.id,
    this.title,
    this.content,
    this.author,
    this.categoryId,
    this.createdAt, {
    this.isPopular = false,
  });

  final int id;
  final String title;
  final String content;
  final String author;
  final String categoryId;
  final String createdAt;
  final bool isPopular;
}

const spaCategories = <String, String>{
  'travel': '여행',
  'food': '음식',
  'lifestyle': '라이프스타일',
};

const spaArticles = <SpaArticle>[
  SpaArticle(
    1,
    '산토리니의 일몰',
    '에게해의 푸른 바다와 하얀 건물들 사이로 지는 석양이 만드는 황홍빛 풍경. 산토리니에서 가장 로맨틱한 순간을 만날 수 있다.',
    'mollit',
    'travel',
    '2023-02-15T09:30:00Z',
  ),
  SpaArticle(
    2,
    '교토의 대나무 숲',
    '아라시야마의 대나무 숲길을 걸으며 느끼는 고요함. 바람에 흔들리는 대나무 소리가 마음을 평온하게 만든다.',
    'sunt',
    'travel',
    '2023-05-22T14:15:00Z',
    isPopular: true,
  ),
  SpaArticle(
    3,
    '알프스 하이킹 가이드',
    '스위스 알프스의 초보자용 트레킹 코스. 그린델발트에서 시작하여 아이거 북벽을 감상하며 2시간 코스로 즐길 수 있다.',
    'ullamco',
    'travel',
    '2023-10-15T12:10:00Z',
  ),
  SpaArticle(
    4,
    '홈메이드 파스타의 비밀',
    '신선한 면과 소스만 있다면 레스토랑 급 파스타를 만들 수 있다. 올리브오일과 마늘의 양이 맛을 결정한다.',
    'dolore',
    'food',
    '2023-03-30T16:20:00Z',
  ),
  SpaArticle(
    5,
    '제철 딸기 고르는 법',
    '봄철 딸기는 꼭지가 선명한 초록색이어야 한다. 윤기 나는 빨간색과 은은한 향기가 좋은 딸기의 조건.',
    'aliqua',
    'food',
    '2023-06-18T10:05:00Z',
  ),
  SpaArticle(
    6,
    '커피 브루잉 팁',
    '물 온도 92도, 분쇄도는 중간, 추출 시간 3분이 기본. 원두 양은 물 200ml당 15g이 황금비율이다.',
    'consectetur',
    'food',
    '2023-09-25T13:40:00Z',
  ),
  SpaArticle(
    7,
    '미니멀 홈 데코',
    '불필요한 소품은 과감히 정리하고, 화이트 톤의 기본 가구만으로 깔끔한 공간을 연출할 수 있다.',
    'adipisicing',
    'lifestyle',
    '2023-04-12T15:55:00Z',
    isPopular: true,
  ),
  SpaArticle(
    8,
    '아침 루틴의 힘',
    '하루를 5분 일찍 시작하는 것부터. 따뜻한 물 한잔과 스트레칭으로 활기찬 아침을 맞이하자.',
    'elit',
    'lifestyle',
    '2023-07-28T08:25:00Z',
    isPopular: true,
  ),
  SpaArticle(
    9,
    '실내 공기 정화 식물',
    '스투키, 스파티필름, 산세베리아는 관리가 쉽고 공기정화 능력이 뛰어난 대표적인 실내식물이다.',
    'exercitation',
    'lifestyle',
    '2023-08-07T11:45:00Z',
  ),
  SpaArticle(
    10,
    '독서 습관 만들기',
    '하루 10페이지부터 시작하자. 취침 전 20분 독서는 수면의 질도 높여주는 일석이조 습관이다.',
    'magna',
    'lifestyle',
    '2023-12-03T17:35:00Z',
    isPopular: true,
  ),
];

String _articleDate(String date) {
  final d = DateTime.parse(date).toLocal();
  return '${d.month}월 ${d.day}일';
}

/// `/demo/home` in the React project.
class SpaDemoHomePage extends StatefulWidget {
  const SpaDemoHomePage({super.key, required this.navigate});

  final SpaNavigate navigate;

  @override
  State<SpaDemoHomePage> createState() => _SpaDemoHomePageState();
}

class _SpaDemoHomePageState extends State<SpaDemoHomePage> {
  int _tabIndex = 0;
  Set<String> _categories = {};
  final Set<String> _categoryDraft = {};

  Future<void> _openCategorySheet() async {
    // React FilterBottomSheet owns `selectedOptions` separately from the
    // committed filter and retains it across the immediate Escape/reopen
    // sequence. This draft belongs to the Demo Home page, not a modal route.
    final selection = _categoryDraft;
    await showSeedBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (sheetContext, update) => SeedBottomSheet(
          title: '카테고리',
          showHandle: true,
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in spaCategories.entries)
                  SeedChip(
                    label: option.value,
                    checked: selection.contains(option.key),
                    variant: SeedChipVariant.outlineStrong,
                    onCheckedChange: (checked) => update(() {
                      if (checked) {
                        selection.add(option.key);
                      } else {
                        selection.remove(option.key);
                      }
                    }),
                  ),
              ],
            ),
          ),
          footer: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SeedButton(
              label: '완료',
              variant: SeedButtonVariant.neutralSolid,
              size: SeedButtonSize.large,
              isFullWidth: true,
              onPressed: () {
                setState(() => _categories = {...selection});
                Navigator.of(sheetContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _recommendations() {
    final articles =
        spaArticles
            .where(
              (a) => _categories.isEmpty || _categories.contains(a.categoryId),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SeedChip(
                  label: _categories.isEmpty
                      ? '카테고리'
                      : _categories.map((id) => spaCategories[id]).join(', '),
                  suffix: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                  ),
                  onPressed: _openCategorySheet,
                ),
                for (final filter in ['동네', '작성자', '작성 시간']) ...[
                  const SizedBox(width: 8),
                  SeedChip(
                    label: filter,
                    suffix: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    // ActivityDemoHome uses a SnackbarProvider adapter. A
                    // ScaffoldMessenger snackbar is layered below the SPA's
                    // active Navigator route, so its action cannot be tapped.
                    onPressed: () => SeedSnackbarProvider.of(context).show(
                      child: SeedSnackbar(
                        message: '카테고리로만 필터링할 수 있어요',
                        variant: SeedSnackbarVariant.critical,
                        actionLabel: '확인',
                        onAction: () {},
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < articles.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _articleItem(articles[i]),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _articleItem(SpaArticle article) {
    final typography = context.seedTypography;
    final colors = context.seedColor;
    return InkWell(
      onTap: () =>
          widget.navigate('ActivityDemoArticleDetail', arguments: article.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SeedAvatar(size: SeedAvatarSize.size20),
                const SizedBox(width: 6),
                Text(article.author, style: typography.t4Medium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              article.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.t5Bold,
            ),
            const SizedBox(height: 4),
            Text(
              article.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.t4Regular.copyWith(
                color: colors.fg.neutralMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (article.isPopular)
                  const SeedBadge(
                    label: '인기',
                    variant: SeedBadgeVariant.outline,
                    tone: SeedBadgeTone.brand,
                  ),
                SeedTagGroup(
                  size: SeedTagGroupSize.t4,
                  items: [
                    SeedTagItem(label: spaCategories[article.categoryId]!),
                    const SeedTagItem(label: '서초2동'),
                    SeedTagItem(label: _articleDate(article.createdAt)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.seedColor.bg.layerDefault,
      // React AppBarMain has neither a Back action nor a centered title.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ColoredBox(
          color: context.seedColor.bg.layerDefault,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Demo', style: context.seedTypography.t6Bold),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SeedTabsView(
        selectedIndex: _tabIndex,
        items: const [
          SeedTabItem(label: '추천'),
          SeedTabItem(label: '구독'),
        ],
        onTabSelected: (tab) => setState(() => _tabIndex = tab),
        carousel: true,
        dynamicHeight: false,
        children: [
          SingleChildScrollView(child: _recommendations()),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: UnconstrainedBox(
                constrainedAxis: Axis.horizontal,
                alignment: Alignment.topCenter,
                child: SeedResultSection(
                  asset: const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Icon(Icons.article_rounded, size: 40),
                  ),
                  title: '구독한 글이 없습니다.',
                  description: '추천 글을 확인해보세요.',
                  primaryActionLabel: '추천 글 보기',
                  onPrimaryAction: () => setState(() => _tabIndex = 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `/demo/article-detail`: hero artwork, article metadata and comment form.
class SpaArticleDetailPage extends StatefulWidget {
  const SpaArticleDetailPage({
    super.key,
    required this.articleId,
    required this.goBack,
  });

  final int? articleId;
  final VoidCallback goBack;

  @override
  State<SpaArticleDetailPage> createState() => _SpaArticleDetailPageState();
}

class _SpaArticleDetailPageState extends State<SpaArticleDetailPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _comment = TextEditingController();
  String _sort = 'popular';
  bool _isHeroVisible = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final visible = _scroll.offset < MediaQuery.sizeOf(context).width;
      if (visible != _isHeroVisible && mounted) {
        setState(() => _isHeroVisible = visible);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = spaArticles
        .where((a) => a.id == widget.articleId)
        .firstOrNull;
    // The React activity renders no article when the required ID is missing.
    if (article == null) return const SizedBox.shrink();
    final typography = context.seedTypography;
    final colors = context.seedColor;
    return Scaffold(
      backgroundColor: colors.bg.layerDefault,
      extendBodyBehindAppBar: true,
      appBar: SeedTopNavigation(
        tone: _isHeroVisible
            ? SeedTopNavigationButtonTone.transparent
            : SeedTopNavigationButtonTone.layer,
        backgroundColor: _isHeroVisible
            ? Colors.transparent
            : colors.bg.layerDefault,
        gradient: _isHeroVisible,
        leading: SeedTopNavigationIconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          semanticsLabel: '뒤로',
          onPressed: widget.goBack,
        ),
        actions: [
          SeedTopNavigationIconButton(
            icon: const Icon(Icons.close_rounded),
            semanticsLabel: '닫기',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: ListView(
        controller: _scroll,
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              'assets/peng.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SeedSkeleton(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.isPopular) ...[
                  const SeedBadge(
                    label: '인기',
                    tone: SeedBadgeTone.brand,
                    variant: SeedBadgeVariant.outline,
                    size: SeedBadgeSize.large,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(article.title, style: typography.t7Bold),
                const SizedBox(height: 8),
                Text(
                  article.content,
                  style: typography.articleBody.copyWith(
                    color: colors.fg.neutralMuted,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SeedAvatar(size: SeedAvatarSize.size20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(article.author, style: typography.t4Medium),
                    ),
                    SeedTagGroup(
                      items: [
                        SeedTagItem(label: spaCategories[article.categoryId]!),
                        SeedTagItem(label: _articleDate(article.createdAt)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SeedCallout(
                  prefixIcon: Icon(Icons.info_rounded),
                  description: '따뜻한 댓글을 남겨주세요.',
                ),
                const SizedBox(height: 18),
                SeedSegmentedControl<String>(
                  value: _sort,
                  segments: const [
                    SeedSegment(value: 'popular', label: '인기'),
                    SeedSegment(value: 'latest', label: '최근'),
                  ],
                  onValueChange: (v) => setState(() => _sort = v),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SeedResultSection(
                    size: SeedResultSectionSize.medium,
                    title: '댓글 없음',
                    description: '댓글이 없습니다.',
                  ),
                ),
                SeedTextField.textarea(
                  controller: _comment,
                  label: '댓글',
                  placeholder: '저는…',
                  maxGraphemeCount: 200,
                ),
                const SizedBox(height: 12),
                SeedButton(
                  label: '게시',
                  variant: SeedButtonVariant.neutralSolid,
                  size: SeedButtonSize.large,
                  isFullWidth: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
