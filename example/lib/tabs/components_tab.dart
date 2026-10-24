import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import '../widgets/section_header.dart';

/// Tab showcasing buttons, FABs, badges, chips, tag groups, lists, selection controls, and accordions.
class ComponentsTab extends StatefulWidget {
  const ComponentsTab({super.key});

  @override
  State<ComponentsTab> createState() => _ComponentsTabState();
}

class _ComponentsTabState extends State<ComponentsTab> {
  bool _loadingButton = false;
  bool _toggleBrandVal = true;
  bool _toggleNeutralVal = false;
  int _selectedChipIndex = 0;
  bool _checkboxVal = true;
  bool _switchVal = true;
  String _radioVal = 'opt1';
  bool _selectBoxVal = true;
  bool _selectBoxVal2 = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'SeedButton Variants',
          subtitle: '7가지 버튼 베리언트와 물리 피드백 스케일 인터랙션',
        ),
        Wrap(
          spacing: SeedDimension.x2,
          runSpacing: SeedDimension.x2,
          children: [
            SeedButton(
              label: 'Brand Solid',
              variant: SeedButtonVariant.brandSolid,
              onPressed: () {},
            ),
            SeedButton(
              label: 'Neutral Solid',
              variant: SeedButtonVariant.neutralSolid,
              onPressed: () {},
            ),
            SeedButton(
              label: 'Brand Outline',
              variant: SeedButtonVariant.brandOutline,
              onPressed: () {},
            ),
            SeedButton(
              label: 'Neutral Outline',
              variant: SeedButtonVariant.neutralOutline,
              onPressed: () {},
            ),
            SeedButton(
              label: 'Neutral Weak',
              variant: SeedButtonVariant.neutralWeak,
              onPressed: () {},
            ),
            SeedButton(
              label: 'Ghost',
              variant: SeedButtonVariant.ghost,
              onPressed: () {},
            ),
            SeedButton(
              label: 'Critical',
              variant: SeedButtonVariant.criticalSolid,
              onPressed: () {},
            ),
            SeedButton(
              label: _loadingButton ? '로딩중...' : '로딩 시뮬레이션',
              loading: _loadingButton,
              variant: SeedButtonVariant.brandSolid,
              onPressed: () async {
                setState(() => _loadingButton = true);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) setState(() => _loadingButton = false);
              },
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        Wrap(
          spacing: SeedDimension.x2,
          runSpacing: SeedDimension.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SeedButton(
              label: 'Ghost (Custom Color & Weight)',
              variant: SeedButtonVariant.ghost,
              textColor: context.seedColor.fg.brand,
              fontWeight: FontWeight.w700,
              bleed: true,
              prefixIcon: const Icon(Icons.bolt),
              onPressed: () {},
            ),
            SeedTextButton(
              label: '독립 Text Button',
              prefixIcon: const Icon(Icons.arrow_forward),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Toggle Buttons (New)',
          subtitle: '상태를 켜고 끄는 토글 전용 버튼 (brandSolid / neutralWeak)',
        ),
        Wrap(
          spacing: SeedDimension.x3,
          runSpacing: SeedDimension.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SeedToggleButton(
              label: _toggleBrandVal ? '알림 켜짐' : '알림 꺼짐',
              prefixIcon: Icon(_toggleBrandVal ? Icons.notifications_active : Icons.notifications_off),
              variant: SeedToggleButtonVariant.brandSolid,
              size: SeedToggleButtonSize.small,
              selected: _toggleBrandVal,
              onSelectedChanged: (val) => setState(() => _toggleBrandVal = val),
            ),
            SeedToggleButton(
              label: _toggleNeutralVal ? '북마크됨' : '북마크',
              prefixIcon: Icon(_toggleNeutralVal ? Icons.bookmark : Icons.bookmark_border),
              variant: SeedToggleButtonVariant.neutralWeak,
              size: SeedToggleButtonSize.small,
              selected: _toggleNeutralVal,
              onSelectedChanged: (val) => setState(() => _toggleNeutralVal = val),
            ),
            SeedToggleButton(
              label: 'xsmall 크기',
              size: SeedToggleButtonSize.xsmall,
              selected: _toggleBrandVal,
              onSelectedChanged: (val) => setState(() => _toggleBrandVal = val),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Floating Action Buttons',
          subtitle: '원형 및 확장형(아이콘+텍스트) 플로팅 액션 버튼',
        ),
        Wrap(
          spacing: SeedDimension.x3,
          runSpacing: SeedDimension.x3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SeedFloatingActionButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
            SeedFloatingActionButton(
              icon: const Icon(Icons.chat_bubble_outline),
              isBrand: false,
              onPressed: () {},
            ),
            SeedFloatingActionButton.extended(
              icon: const Icon(Icons.edit_outlined),
              label: '글쓰기',
              onPressed: () {},
            ),
            SeedFloatingActionButton.extended(
              icon: const Icon(Icons.near_me_outlined),
              label: '내 근처 보기',
              isBrand: false,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        SeedPressable(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SeedDimension.x4,
              vertical: SeedDimension.x3,
            ),
            decoration: BoxDecoration(
              color: context.seedColor.bg.layerFloating,
              borderRadius: SeedBorderRadius.r3,
              border: Border.all(color: context.seedColor.stroke.neutralWeak),
            ),
            child: Row(
              children: const [
                Icon(Icons.touch_app_outlined),
                SizedBox(width: SeedDimension.x2),
                Expanded(
                  child: Text('SeedPressable: 임의의 커스텀 카드에 당근 물리 스케일 피드백 부여'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Badges & Chips',
          subtitle: '상태 표시 배지와 선택 칩 (전 사이즈 Stadium Pill 둥글기 적용)',
        ),
        Wrap(
          spacing: SeedDimension.x2,
          runSpacing: SeedDimension.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SeedBadge(label: '거래중', tone: SeedBadgeTone.brand),
            const SeedBadge(label: '예약중', tone: SeedBadgeTone.warning),
            const SeedBadge(label: '판매완료', tone: SeedBadgeTone.neutral),
            const SeedBadge(
              label: '추천매물',
              tone: SeedBadgeTone.positive,
              prefix: Icon(Icons.thumb_up, size: 12),
              action: Icon(Icons.info_outline, size: 12),
            ),
            const SeedBadge(label: '인기매물', tone: SeedBadgeTone.critical),
            const SeedNotificationBadge(count: 7),
            const SeedNotificationBadge(count: 120, maxCount: 99),
          ],
        ),
        const SizedBox(height: SeedDimension.x3),
        Wrap(
          spacing: SeedDimension.x2,
          children: List.generate(4, (index) {
            final labels = ['전체', '디지털기기', '생활가전', '가구/인테리어'];
            return SeedChip(
              label: labels[index],
              selected: _selectedChipIndex == index,
              onSelected: (_) => setState(() => _selectedChipIndex = index),
            );
          }),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Tag Group',
          subtitle: '중간 구분점(·)으로 연결되는 메타데이터 태그 목록',
        ),
        const SeedTagGroup(
          items: [
            SeedTagItem(label: '서울 강남구 역삼동', tone: SeedTagTone.brand, bold: true),
            SeedTagItem(label: '2분 전', tone: SeedTagTone.neutralSubtle),
            SeedTagItem(label: '끌올 1회', tone: SeedTagTone.neutral),
            SeedTagItem(label: '조회 42', tone: SeedTagTone.neutralSubtle),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Selection Controls',
          subtitle: '체크박스, 스위치, 라디오 버튼 및 카드형 셀렉트 박스',
        ),
        Row(
          children: [
            SeedCheckbox(
              value: _checkboxVal,
              label: '알림 동의',
              onChanged: (v) => setState(() => _checkboxVal = v ?? false),
            ),
            const SizedBox(width: SeedDimension.x4),
            SeedSwitch(
              value: _switchVal,
              label: '채팅 알림',
              onChanged: (v) => setState(() => _switchVal = v),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x2),
        Row(
          children: [
            SeedRadio<String>(
              value: 'opt1',
              groupValue: _radioVal,
              label: '일반거래',
              onChanged: (v) => setState(() => _radioVal = v!),
            ),
            const SizedBox(width: SeedDimension.x4),
            SeedRadio<String>(
              value: 'opt2',
              groupValue: _radioVal,
              label: '안전결제',
              onChanged: (v) => setState(() => _radioVal = v!),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x3),
        SeedSelectBoxGroup(
          children: [
            SeedSelectBox(
              selected: _selectBoxVal,
              title: '택배거래 지원',
              description: '택배로 물품을 안전하게 발송해요',
              control: SeedSelectBoxControl.checkmark,
              onSelected: (val) => setState(() => _selectBoxVal = val),
            ),
            SeedSelectBox(
              selected: _selectBoxVal2,
              title: '직거래 희망',
              description: '만나서 직접 물건을 확인하고 거래해요',
              control: SeedSelectBoxControl.checkmark,
              onSelected: (val) => setState(() => _selectBoxVal2 = val),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'List & List Items',
          subtitle: '아이콘, 타이틀, 서브타이틀, 액션 접미사가 포함된 표준 리스트 컴포넌트',
        ),
        SeedList(
          children: [
            SeedListItem(
              prefix: const Icon(Icons.notifications_active_outlined),
              titleText: '키워드 알림 설정',
              detailText: '등록한 키워드의 새로운 중고 물품이 올라오면 알려드려요',
              suffix: const Icon(Icons.chevron_right, size: 20),
              onTap: () {},
            ),
            SeedListItem(
              prefix: const Icon(Icons.location_on_outlined),
              titleText: '동네 인증하기',
              detailText: '현재 위치: 서울시 강남구 역삼1동 (인증 완료)',
              suffix: const SeedBadge(label: '인증됨', tone: SeedBadgeTone.positive),
              onTap: () {},
            ),
            SeedListItem(
              prefix: const Icon(Icons.lock_outline),
              titleText: '당근페이 안심결제 보안 설정',
              detailText: '생체 인증 및 결제 비밀번호 재설정',
              suffix: const Icon(Icons.chevron_right, size: 20),
              showDivider: false,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x3),
        const SeedDivider(thickness: 1.0),
        const SizedBox(height: SeedDimension.x3),

        const SectionHeader(
          title: 'Banner, Callout & Accordion',
          subtitle: '상단 전체 너비 안내 배너, 인라인 콜아웃 및 점진적 세부정보 공개',
        ),
        const SeedPageBanner(
          title: '동네 인증 갱신 안내',
          description: '원활한 이웃 간 중고거래를 위해 30일마다 동네 인증을 갱신해주세요.',
          tone: SeedPageBannerTone.informative,
        ),
        const SizedBox(height: SeedDimension.x3),
        const SeedCallout(
          title: '안전한 직거래 수칙',
          description: '당근페이를 사용하시면 사기 피해를 방지하고 송금 수수료 없이 안전하게 거래할 수 있습니다.',
          tone: SeedCalloutTone.informative,
        ),
        const SizedBox(height: SeedDimension.x3),
        const SeedAccordionItem(
          prefix: Icon(Icons.help_outline, size: 22),
          title: '자주 묻는 질문: 당근 매너온도는 어떻게 계산되나요?',
          description: '매너온도 산출 기준 안내',
          content: Text(
            '매너온도는 기본 36.5도에서 시작하며 거래 후 받은 긍정적인 평가와 매너 칭찬이 많을수록 온도가 올라가고, 비매너 평가나 신고를 받으면 온도가 내려갑니다.',
          ),
        ),
      ],
    );
  }
}
