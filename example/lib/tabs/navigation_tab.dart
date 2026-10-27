import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import '../widgets/section_header.dart';

/// Tab showcasing tabs, segmented control, pagination, avatars, image frames, and side navigation.
class NavigationTab extends StatefulWidget {
  const NavigationTab({super.key});

  @override
  State<NavigationTab> createState() => _NavigationTabState();
}

class _NavigationTabState extends State<NavigationTab> {
  int _selectedTopTab = 0;
  int _selectedChipTab = 0;
  String _selectedSegment = 'all';
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _tablePage = 1;
  bool _unknownTotal = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Tabs',
          subtitle: '탭 선택·가로 스와이프로 콘텐츠를 전환합니다.',
        ),
        SeedTabsView(
          key: const ValueKey('line-tabs-content'),
          fill: true,
          carousel: true,
          dynamicHeight: true,
          height: 80,
          selectedIndex: _selectedTopTab,
          variant: SeedTabsVariant.line,
          items: const [
            SeedTabItem(label: '홈'),
            SeedTabItem(label: '동네생활', showNotificationDot: true),
            SeedTabItem(label: '내 근처'),
            SeedTabItem(label: '채팅'),
          ],
          onTabSelected: (index) => setState(() => _selectedTopTab = index),
          children: const [
            SizedBox(height: 80, child: Center(child: Text('홈 콘텐츠'))),
            SizedBox(height: 160, child: Center(child: Text('동네생활 콘텐츠'))),
            SizedBox(height: 100, child: Center(child: Text('내 근처 콘텐츠'))),
            SizedBox(height: 80, child: Center(child: Text('채팅 콘텐츠'))),
          ],
        ),
        const SizedBox(height: SeedDimension.x3),
        SeedChipTabsView(
          carousel: true,
          height: 80,
          selectedIndex: _selectedChipTab,
          variant: SeedTabsVariant.chipSolid,
          items: const [
            SeedTabItem(label: '추천순'),
            SeedTabItem(label: '최신순'),
            SeedTabItem(label: '인기순'),
            SeedTabItem(label: '가격낮은순'),
          ],
          onTabSelected: (index) => setState(() => _selectedChipTab = index),
          children: const [
            Center(child: Text('추천 상품')),
            Center(child: Text('최신 등록 상품')),
            Center(child: Text('인기 상품')),
            Center(child: Text('낮은 가격 상품')),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Segmented Control',
          subtitle: '플로팅 알약 인디케이터와 그림자 효과가 적용된 상호 배타적 선택 제어기',
        ),
        SeedSegmentedControl<String>(
          selectedValue: _selectedSegment,
          segments: const [
            SeedSegment(value: 'all', label: '전체보기'),
            SeedSegment(value: 'selling', label: '판매중', notificationCount: 4),
            SeedSegment(value: 'completed', label: '거래완료'),
          ],
          onValueChanged: (val) => setState(() => _selectedSegment = val),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Pagination & Table Controls',
          subtitle: '페이지네이션 및 데이터 테이블 컨트롤',
        ),
        Center(
          child: SeedPagination(
            currentPage: _currentPage,
            totalPages: 10,
            onPageChanged: (p) => setState(() => _currentPage = p),
          ),
        ),
        const SizedBox(height: SeedDimension.x4),
        Wrap(
          spacing: SeedDimension.x3,
          runSpacing: SeedDimension.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _unknownTotal ? '표시할 전체 건수를 모릅니다' : '전체 320개 중에서 보기',
              style: context.seedTypography.t3Medium.copyWith(
                color: context.seedColor.fg.neutralSubtle,
              ),
            ),
            SeedSwitch(
              value: _unknownTotal,
              label: '전체 건수 숨기기',
              onChanged: (v) => setState(() => _unknownTotal = v),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x2),
        SeedTablePagination(
          currentPage: _tablePage,
          totalItems: _unknownTotal ? null : 320,
          hasPreviousPage: _unknownTotal ? _tablePage > 1 : null,
          hasNextPage: _unknownTotal ? true : null,
          rowsPerPage: _rowsPerPage,
          onPageChanged: (p) => setState(() => _tablePage = p),
          onRowsPerPageChanged: (r) => setState(() {
            _rowsPerPage = r;
            _tablePage = 1;
          }),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Top Navigation',
          subtitle: '모임 설정 화면의 뒤로 가기, 공유, 완료 동작',
        ),
        ClipRRect(
          borderRadius: SeedBorderRadius.r2,
          child: SeedTopNavigation(
            titleText: '모임 설정',
            leading: SeedTopNavigationIconButton(
              icon: const Icon(Icons.arrow_back),
              semanticsLabel: '모임 설정에서 뒤로 가기',
              onPressed: () =>
                  showSeedSnackbar(context: context, message: '모임 목록으로 돌아갑니다'),
            ),
            actions: [
              SeedTopNavigationIconButton(
                icon: const Icon(Icons.share_outlined),
                semanticsLabel: '모임 공유하기',
                onPressed: () => showSeedSnackbar(
                  context: context,
                  message: '모임 링크를 공유할 수 있어요',
                ),
              ),
              SeedTopNavigationTextButton(
                text: '완료',
                onPressed: () =>
                    showSeedSnackbar(context: context, message: '모임 설정을 저장했어요'),
              ),
            ],
          ),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Avatar & Avatar Stack',
          subtitle: '개인·가게 프로필과 모임에 함께하는 이웃',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SeedAvatar(
              size: SeedAvatarSize.small,
              placeholder: Icon(Icons.person, size: 16),
            ),
            SizedBox(width: SeedDimension.x3),
            SeedAvatar(
              size: SeedAvatarSize.medium,
              placeholder: Icon(Icons.person, size: 20),
            ),
            SizedBox(width: SeedDimension.x3),
            SeedAvatar(
              size: SeedAvatarSize.large,
              placeholder: Icon(Icons.storefront, size: 28),
              badge: SeedNotificationBadge.dot(),
            ),
            SizedBox(width: SeedDimension.x3),
            SeedAvatar(
              size: SeedAvatarSize.xlarge,
              placeholder: Icon(Icons.business, size: 36),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(SeedDimension.x3),
            decoration: BoxDecoration(
              color: context.seedColor.bg.layerDefault,
              borderRadius: SeedBorderRadius.r2,
              border: Border.all(color: context.seedColor.stroke.neutralWeak),
            ),
            child: Row(
              children: [
                const SeedAvatarStack(
                  size: SeedAvatarSize.medium,
                  maxVisible: 3,
                  children: [
                    SeedAvatar(placeholder: Text('김')),
                    SeedAvatar(placeholder: Text('이')),
                    SeedAvatar(placeholder: Text('박')),
                    SeedAvatar(placeholder: Text('최')),
                    SeedAvatar(placeholder: Text('정')),
                  ],
                ),
                const SizedBox(width: SeedDimension.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('주말 러닝 모임', style: context.seedTypography.t4Bold),
                      Text(
                        '참여 이웃 5명',
                        style: context.seedTypography.t3Regular.copyWith(
                          color: context.seedColor.fg.neutralSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SeedDimension.x4),
        Row(
          children: const [
            SeedIdentityPlaceholder(type: SeedIdentityType.person, size: 56),
            SizedBox(width: SeedDimension.x3),
            SeedIdentityPlaceholder(type: SeedIdentityType.business, size: 56),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Image Frame & Content Placeholders',
          subtitle: '정규 1:1 이미지 프레임 및 공식 도메인별 대체 시각 요소(ContentPlaceholder)',
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            children: [
              Expanded(
                child: SeedImageFrame(
                  ratio: SeedImageRatio.square,
                  badge: '대표사진',
                  overlay: Container(
                    alignment: Alignment.center,
                    child: const Text('1:1 Frame'),
                  ),
                ),
              ),
              const SizedBox(width: SeedDimension.x3),
              const Expanded(
                child: SizedBox(
                  height: 120,
                  child: SeedContentPlaceholder(
                    type: SeedContentPlaceholderType.buySell,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SeedDimension.x3),
        Text(
          '공식 도메인 프리셋 (Rootage ${SeedContentPlaceholderType.values.length}종):',
          style: context.seedTypography.t3Medium.copyWith(
            color: context.seedColor.fg.neutralSubtle,
          ),
        ),
        const SizedBox(height: SeedDimension.x2),
        Wrap(
          spacing: SeedDimension.x2,
          runSpacing: SeedDimension.x2,
          children: [
            for (final type in SeedContentPlaceholderType.values)
              SizedBox(
                width: 72,
                child: Column(
                  children: [
                    SizedBox(
                      height: 72,
                      child: SeedContentPlaceholder(type: type),
                    ),
                    const SizedBox(height: SeedDimension.x1),
                    Text(
                      switch (type) {
                        SeedContentPlaceholderType.defaultType => '기본',
                        SeedContentPlaceholderType.buySell => '중고거래',
                        SeedContentPlaceholderType.car => '자동차',
                        SeedContentPlaceholderType.commerce => '커머스',
                        SeedContentPlaceholderType.coupon => '쿠폰',
                        SeedContentPlaceholderType.food => '음식',
                        SeedContentPlaceholderType.group => '모임',
                        SeedContentPlaceholderType.image => '이미지',
                        SeedContentPlaceholderType.jobs => '구인구직',
                        SeedContentPlaceholderType.business => '비즈니스',
                        SeedContentPlaceholderType.post => '게시글',
                        SeedContentPlaceholderType.realty => '부동산',
                      },
                      style: context.seedTypography.t2Regular,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Side Navigation',
          subtitle: '데스크탑/태블릿용 사이드 내비게이션',
        ),
        SizedBox(
          height: 240,
          child: SeedSideNavigation(
            header: const Text('당근 비즈니스'),
            groups: const [
              SeedSideNavGroup(
                label: '광고 관리',
                items: [
                  SeedSideNavItem(
                    id: 'camp',
                    label: '캠페인 목록',
                    icon: Icons.campaign,
                  ),
                  SeedSideNavItem(
                    id: 'rep',
                    label: '보고서',
                    icon: Icons.bar_chart,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Footer',
          subtitle: '페이지 하단 운영 정책 및 프로젝트 정보 링크',
        ),
        const SeedFooter(
          brandName: 'SEED',
          companyInfo: 'Flutter UI 라이브러리 · Apache-2.0',
          copyright: '© ven0m.kr',
          policyLinks: [
            SeedFooterLink(label: '서비스 이용약관'),
            SeedFooterLink(label: '개인정보 처리방침'),
            SeedFooterLink(label: '오픈소스 라이선스'),
          ],
        ),
      ],
    );
  }
}
