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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Tabs',
          subtitle: 'Line 및 Chip 스타일 탭 바',
        ),
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
        SeedPagination(
          currentPage: _currentPage,
          totalPages: 10,
          onPageChanged: (p) => setState(() => _currentPage = p),
        ),
        const SizedBox(height: SeedDimension.x4),
        SeedTablePagination(
          currentPage: _currentPage,
          totalItems: 320,
          rowsPerPage: _rowsPerPage,
          onPageChanged: (p) => setState(() => _currentPage = p),
          onRowsPerPageChanged: (r) => setState(() => _rowsPerPage = r),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Avatar & Identity',
          subtitle: '4가지 규격(32, 40, 56, 72px) 아바타 및 사용자/비즈니스 플레이스홀더',
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
        Row(
          children: const [
            SeedIdentityPlaceholder(
              type: SeedIdentityType.person,
              size: 56,
            ),
            SizedBox(width: SeedDimension.x3),
            SeedIdentityPlaceholder(
              type: SeedIdentityType.business,
              size: 56,
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Image Frame & Content Placeholders',
          subtitle: '정규 1:1 비율 이미지 프레임 및 미디어 콘텐츠 로딩 대체 영역',
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
                  icon: Icon(Icons.broken_image_outlined, size: 36),
                ),
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
                  SeedSideNavItem(id: 'camp', label: '캠페인 목록', icon: Icons.campaign),
                  SeedSideNavItem(id: 'rep', label: '보고서', icon: Icons.bar_chart),
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
