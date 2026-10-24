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
        const SectionHeader(title: 'Tabs', subtitle: 'Line 및 Chip 스타일 탭 바'),
        SeedTabs(
          selectedIndex: _selectedTopTab,
          variant: SeedTabsVariant.line,
          items: const [
            SeedTabItem(label: '홈'),
            SeedTabItem(label: '동네생활', notificationCount: 3),
            SeedTabItem(label: '내 근처', showNotificationDot: true),
            SeedTabItem(label: '채팅', notificationCount: 12),
          ],
          onTabSelected: (index) => setState(() => _selectedTopTab = index),
        ),
        const SizedBox(height: SeedDimension.x3),
        SeedTabs(
          selectedIndex: _selectedChipTab,
          variant: SeedTabsVariant.chipSolid,
          items: const [
            SeedTabItem(label: '추천순'),
            SeedTabItem(label: '최신순'),
            SeedTabItem(label: '인기순'),
            SeedTabItem(label: '가격낮은순'),
          ],
          onTabSelected: (index) => setState(() => _selectedChipTab = index),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _unknownTotal ? '모드: 미확인 총량 (Unknown Total)' : '모드: 고정 총량 (320개)',
              style: context.seedTypography.t3Medium.copyWith(color: context.seedColor.fg.neutralSubtle),
            ),
            SeedSwitch(
              value: _unknownTotal,
              label: 'Unknown Total',
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
          title: 'Top Navigation Buttons (New)',
          subtitle: '44px 터치 타겟과 자체 스케일 피드백이 규격화된 상단 바 전용 버튼',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2, vertical: SeedDimension.x1),
          decoration: BoxDecoration(
            color: context.seedColor.bg.layerDefault,
            borderRadius: SeedBorderRadius.r2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SeedTopNavigationIconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {},
                  ),
                  const SizedBox(width: SeedDimension.x2),
                  Text('상단 바 미리보기', style: context.seedTypography.t5Bold),
                ],
              ),
              Row(
                children: [
                  SeedTopNavigationIconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                  SeedTopNavigationTextButton(
                    text: '완료',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Avatar & Avatar Stack (New)',
          subtitle: '10가지 규격(20..108px) 아바타 및 음수 간격 중첩 스택(AvatarStack)',
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
            ),
            SizedBox(width: SeedDimension.x3),
            SeedAvatar(
              size: SeedAvatarSize.xlarge,
              placeholder: Icon(Icons.business, size: 36),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        Text(
          '중첩 아바타 스택 (AvatarStack):',
          style: context.seedTypography.t3Medium.copyWith(color: context.seedColor.fg.neutralSubtle),
        ),
        const SizedBox(height: SeedDimension.x2),
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
        Row(
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
        const SizedBox(height: SeedDimension.x3),
        Text(
          '공식 도메인 프리셋 (Rootage 12종):',
          style: context.seedTypography.t3Medium.copyWith(color: context.seedColor.fg.neutralSubtle),
        ),
        const SizedBox(height: SeedDimension.x2),
        Wrap(
          spacing: SeedDimension.x2,
          runSpacing: SeedDimension.x2,
          children: const [
            SizedBox(
              width: 72,
              height: 72,
              child: SeedContentPlaceholder(type: SeedContentPlaceholderType.car),
            ),
            SizedBox(
              width: 72,
              height: 72,
              child: SeedContentPlaceholder(type: SeedContentPlaceholderType.food),
            ),
            SizedBox(
              width: 72,
              height: 72,
              child: SeedContentPlaceholder(type: SeedContentPlaceholderType.commerce),
            ),
            SizedBox(
              width: 72,
              height: 72,
              child: SeedContentPlaceholder(type: SeedContentPlaceholderType.jobs),
            ),
            SizedBox(
              width: 72,
              height: 72,
              child: SeedContentPlaceholder(type: SeedContentPlaceholderType.realty),
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
          brandName: 'SEED Design System',
          companyInfo: 'Flutter Design System Library | Open Source Apache-2.0',
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
