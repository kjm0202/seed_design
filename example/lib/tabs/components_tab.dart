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
          title: 'Action Button',
          subtitle: '한 번의 행동을 실행하는 버튼입니다. 용도에 따라 강조 수준을 선택하세요.',
        ),
        _ButtonExamples(
          children: [
            for (final (label, variant, description) in [
              (
                'Brand Solid',
                SeedButtonVariant.brandSolid,
                '등록·구매 등 가장 중요한 행동',
              ),
              (
                'Neutral Solid',
                SeedButtonVariant.neutralSolid,
                '확인·완료 등 일반적인 주요 행동',
              ),
              (
                'Brand Outline',
                SeedButtonVariant.brandOutline,
                '브랜드 색으로 강조하는 보조 행동',
              ),
              (
                'Neutral Outline',
                SeedButtonVariant.neutralOutline,
                '테두리로 구분하는 보조 행동',
              ),
              ('Neutral Weak', SeedButtonVariant.neutralWeak, '낮은 강조도의 보조 행동'),
              ('Ghost', SeedButtonVariant.ghost, '배경 없이 가볍게 제공하는 행동'),
              (
                'Critical',
                SeedButtonVariant.criticalSolid,
                '삭제·차단 등 주의가 필요한 행동',
              ),
            ])
              _ButtonExample(
                description: description,
                child: SeedButton(
                  label: label,
                  variant: variant,
                  onPressed: () => showSeedSnackbar(
                    context: context,
                    message: '$label 버튼을 눌렀어요',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        _ButtonExamples(
          children: [
            _ButtonExample(
              description: '로딩 상태 · 처리 중에는 중복 실행을 막아요',
              child: SeedButton(
                label: _loadingButton ? '로딩중...' : '로딩 시뮬레이션',
                loading: _loadingButton,
                variant: SeedButtonVariant.brandSolid,
                onPressed: () async {
                  setState(() => _loadingButton = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _loadingButton = false);
                },
              ),
            ),
            _ButtonExample(
              description: '커스텀 구성 · Ghost에 아이콘과 색상 적용',
              child: SeedButton(
                label: '자세히 보기',
                variant: SeedButtonVariant.ghost,
                textColor: context.seedColor.fg.brand,
                fontWeight: FontWeight.w700,
                bleed: true,
                prefixIcon: const Icon(Icons.bolt),
                onPressed: () =>
                    showSeedSnackbar(context: context, message: '상세 안내를 열었어요'),
              ),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),
        const SectionHeader(
          title: 'Text Button',
          subtitle: '도움말·이용 안내처럼 낮은 강조도의 보조 행동에 사용하는 텍스트 버튼입니다.',
        ),
        SeedTextButton(
          label: '이용 안내',
          prefixIcon: const Icon(Icons.help_outline),
          onPressed: () =>
              showSeedSnackbar(context: context, message: '이용 안내를 확인했어요'),
        ),
        const SizedBox(height: SeedDimension.x6),
        const SectionHeader(
          title: 'Toggle Button',
          subtitle: '누를 때마다 선택 상태가 바뀌는 버튼입니다. 각 버튼을 눌러 켜짐·꺼짐을 비교하세요.',
        ),
        _ButtonExamples(
          children: [
            _ButtonExample(
              description: 'brandSolid · small\n키워드 알림의 활성화 상태',
              child: SeedToggleButton(
                label: _toggleBrandVal ? '키워드 알림 켜짐' : '키워드 알림 꺼짐',
                prefixIcon: Icon(
                  _toggleBrandVal
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                ),
                variant: SeedToggleButtonVariant.brandSolid,
                size: SeedToggleButtonSize.small,
                selected: _toggleBrandVal,
                onSelectedChanged: (val) =>
                    setState(() => _toggleBrandVal = val),
              ),
            ),
            _ButtonExample(
              description: 'neutralWeak · small\n관심 목록에 저장한 상태',
              child: SeedToggleButton(
                label: _toggleNeutralVal ? '관심 목록에 저장됨' : '관심 목록에 저장',
                prefixIcon: Icon(
                  _toggleNeutralVal ? Icons.bookmark : Icons.bookmark_border,
                ),
                variant: SeedToggleButtonVariant.neutralWeak,
                size: SeedToggleButtonSize.small,
                selected: _toggleNeutralVal,
                onSelectedChanged: (val) =>
                    setState(() => _toggleNeutralVal = val),
              ),
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
        const SizedBox(height: SeedDimension.x6),
        const SectionHeader(
          title: 'SeedPressable',
          subtitle: '커스텀 콘텐츠에 누름·포커스·스케일 피드백을 적용합니다.',
        ),
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
                Expanded(child: Text('카드를 눌러 스케일 피드백을 확인하세요.')),
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
            SeedTagItem(
              label: '서울 강남구 역삼동',
              tone: SeedTagTone.brand,
              bold: true,
            ),
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
        Wrap(
          spacing: SeedDimension.x4,
          runSpacing: SeedDimension.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SeedCheckbox(
              value: _checkboxVal,
              label: '알림 동의',
              onChanged: (v) => setState(() => _checkboxVal = v ?? false),
            ),
            SeedSwitch(
              value: _switchVal,
              label: '채팅 알림',
              onChanged: (v) => setState(() => _switchVal = v),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x2),
        Wrap(
          spacing: SeedDimension.x4,
          runSpacing: SeedDimension.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SeedRadio<String>(
              value: 'opt1',
              groupValue: _radioVal,
              label: '일반거래',
              onChanged: (v) => setState(() => _radioVal = v!),
            ),
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
              suffix: const SeedBadge(
                label: '인증됨',
                tone: SeedBadgeTone.positive,
              ),
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

/// Consistent specimen columns that collapse when enlarged text needs more room.
class _ButtonExamples extends StatelessWidget {
  const _ButtonExamples({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns = (constraints.maxWidth / (160 * scale)).floor().clamp(
        1,
        3,
      );
      final width =
          (constraints.maxWidth - (columns - 1) * SeedDimension.x3) / columns;
      return Wrap(
        spacing: SeedDimension.x3,
        runSpacing: SeedDimension.x4,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _ButtonExample extends StatelessWidget {
  const _ButtonExample({required this.description, required this.child});

  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      child,
      const SizedBox(height: SeedDimension.x1_5),
      Text(
        description,
        style: context.seedTypography.t2Regular.copyWith(
          color: context.seedColor.fg.neutralMuted,
        ),
      ),
    ],
  );
}
