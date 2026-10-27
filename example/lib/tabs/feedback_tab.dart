import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import '../widgets/section_header.dart';

/// Tab showcasing feedback, status indicators, gauges, reactions, and loading states.
class FeedbackTab extends StatefulWidget {
  const FeedbackTab({super.key});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  static const _mannerTemperatures = [
    12.5,
    30.0,
    36.0,
    36.5,
    37.0,
    40.0,
    45.0,
    55.0,
    65.0,
    80.0,
  ];
  double _mannerTemp = 36.5;
  bool _isLiked = false;
  int _reactionCount = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Manner Temperature',
          subtitle: '슬라이더로 온도를 바꾸며 색상과 표정의 변화를 확인해 보세요.',
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SeedDimension.x4),
          decoration: BoxDecoration(
            color: colors.bg.layerDefault,
            borderRadius: SeedBorderRadius.r3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '매너온도',
                style: typography.t2Regular.copyWith(
                  color: colors.fg.neutralMuted,
                ),
              ),
              const SizedBox(height: SeedDimension.x3),
              Wrap(
                spacing: SeedDimension.x4,
                runSpacing: SeedDimension.x3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SeedMannerTemp(temperature: _mannerTemp, showEmoji: true),
                  SeedMannerTempBadge(temperature: _mannerTemp),
                ],
              ),
              const SizedBox(height: SeedDimension.x4),
              SeedSlider(
                values: [_mannerTemp],
                min: 0,
                max: 99.9,
                step: 0.1,
                fieldLabel: '온도 조절',
                semanticsLabel: '매너온도 조절',
                valueFormatter: (value) => '${value.toStringAsFixed(1)}°C',
                onValuesChange: (values) => setState(
                  () => _mannerTemp = (values.single * 10).round() / 10,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0°C', style: typography.t1Regular),
                  Text('99.9°C', style: typography.t1Regular),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SeedDimension.x2),
        Text(
          '표정은 시스템 이모지로 표시합니다.',
          style: typography.t1Regular.copyWith(color: colors.fg.neutralMuted),
        ),
        const SizedBox(height: SeedDimension.x6),
        const SectionHeader(
          title: 'Manner Temp Badge',
          subtitle: '10단계 대표 온도를 누르면 미리보기에 바로 적용됩니다.',
        ),
        Wrap(
          spacing: SeedDimension.x2,
          runSpacing: SeedDimension.x2,
          children: [
            for (final temperature in _mannerTemperatures)
              SeedPressable(
                selected: _mannerTemp == temperature,
                semanticsLabel: '매너온도 ${temperature.toStringAsFixed(1)}도로 설정',
                focusBorderRadius: SeedBorderRadius.full,
                onTap: () => setState(() => _mannerTemp = temperature),
                builder: (context, isPressed) => Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.all(SeedDimension.x1),
                  decoration: BoxDecoration(
                    color: isPressed
                        ? colors.bg.neutralWeakPressed
                        : colors.bg.layerDefault,
                    borderRadius: SeedBorderRadius.full,
                    border: Border.all(
                      color: _mannerTemp == temperature
                          ? colors.stroke.neutralSolid
                          : colors.stroke.neutralWeak,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: SeedMannerTempBadge(temperature: temperature),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Progress & Skeleton',
          subtitle: '원형 진행률 인디케이터 및 쉬머 스켈레톤 플레이스홀더',
        ),
        Row(
          children: const [
            SeedProgressCircle(size: 24),
            SizedBox(width: SeedDimension.x4),
            SeedProgressCircle(value: 0.7),
            SizedBox(width: SeedDimension.x4),
            Text('70% 완료 인디케이터'),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        const _SkeletonPreview(),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Reaction & Help Bubble',
          subtitle: '반응형 공감 버튼 및 힌트 말풍선',
        ),
        Row(
          children: [
            SeedReactionButton(
              prefixIcon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
              ),
              count: _reactionCount,
              pressed: _isLiked,
              onPressedChange: (val) {
                setState(() {
                  _isLiked = val;
                  _reactionCount += val ? 1 : -1;
                });
              },
            ),
            const SizedBox(width: SeedDimension.x4),
            const Expanded(
              child: SeedHelpBubble(
                title: '관심 목록 알림',
                description: '관심 목록에 등록하면 가격 변동 시 알림을 받아요!',
              ),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Help Bubble Trigger',
          subtitle: '버튼을 눌러 안내를 열고 닫습니다. 모바일에서도 사용할 수 있어요.',
        ),
        SeedHelpBubbleTrigger(
          title: '버튼을 눌러 여는 도움말이에요',
          description: '닫은 뒤에도 버튼을 누르면 다시 확인할 수 있어요.',
          triggerBuilder: (_, open, toggle) => SeedButton(
            label: '도움말 확인',
            variant: SeedButtonVariant.ghost,
            prefixIcon: const Icon(Icons.help_outline),
            onPressed: toggle,
          ),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Help Bubble Tooltip',
          subtitle: '마우스를 올리거나 키보드로 포커스하면 안내가 열립니다.',
        ),
        SeedHelpBubbleTooltip(
          title: '마우스와 키보드 포커스로 열려요',
          child: SeedButton(
            label: '툴팁 확인',
            variant: SeedButtonVariant.ghost,
            prefixIcon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: SeedDimension.x6),
        const SectionHeader(
          title: 'Snackbar',
          subtitle: '안내·성공·오류 메시지입니다. 마우스를 올리거나 누르는 동안 표시 시간이 멈춥니다.',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SeedButton(
              label: '스낵바 메시지',
              variant: SeedButtonVariant.neutralWeak,
              onPressed: () {
                final controller = SeedSnackbarProvider.of(context);
                controller.show(
                  child: SeedSnackbar(
                    message: '키워드 알림이 설정되었습니다.',
                    actionLabel: '설정확인',
                    onAction: controller.close,
                  ),
                );
              },
            ),
            SeedButton(
              label: '성공 안내',
              onPressed: () => SeedSnackbarProvider.of(context).show(
                child: const SeedSnackbar(
                  message: '저장했어요.',
                  variant: SeedSnackbarVariant.positive,
                ),
              ),
            ),
            SeedButton(
              label: '오류 안내',
              variant: SeedButtonVariant.criticalSolid,
              onPressed: () => SeedSnackbarProvider.of(context).show(
                child: const SeedSnackbar(
                  message: '다시 시도해 주세요.',
                  variant: SeedSnackbarVariant.critical,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Result Section',
          subtitle: '데이터 조회 결과 없음 또는 완료 상태 안내',
        ),
        const SeedResultSection(
          // The catalog page already supplies the horizontal screen gutter.
          padding: EdgeInsets.symmetric(vertical: SeedDimension.x4),
          title: '주변에 등록된 매물이 없습니다',
          description: '동네 범위를 넓혀서 검색하거나 키워드 알림을 설정해보세요.',
        ),
      ],
    );
  }
}

class _SkeletonPreview extends StatelessWidget {
  const _SkeletonPreview();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SeedSkeleton.circle(size: 48),
        SizedBox(width: SeedDimension.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeedSkeleton(width: 140, height: 16),
              SizedBox(height: SeedDimension.x2),
              SeedSkeleton(width: double.infinity, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
