import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import '../widgets/section_header.dart';
import '../widgets/seed_menu_example.dart';
import '../widgets/side_panel_details.dart';

/// Tab showcasing dialogs, alert dialogs, bottom sheets, menu sheets, side panels, snackbars, and migration bridge.
class OverlaysTab extends StatelessWidget {
  const OverlaysTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Dialogs & Alerts',
          subtitle: '중요 확인, 위험 작업 경고, 커스텀 모달 대화상자',
        ),
        Wrap(
          spacing: SeedDimension.x3,
          runSpacing: SeedDimension.x3,
          children: [
            SeedButton(
              label: '기본 확인 알림창',
              variant: SeedButtonVariant.neutralSolid,
              onPressed: () {
                showSeedAlertDialog(
                  context: context,
                  title: '알림 설정을 저장할까요?',
                  description: '설정하신 키워드에 대한 푸시 알림이 즉시 활성화됩니다.',
                  confirmText: '저장하기',
                  cancelText: '취소',
                );
              },
            ),
            SeedButton(
              label: '위험 경고 알림창',
              variant: SeedButtonVariant.criticalSolid,
              onPressed: () {
                showSeedAlertDialog(
                  context: context,
                  title: '채팅방을 나가시겠습니까?',
                  description: '채팅방을 나가면 대화 내용이 모두 삭제되며 복구할 수 없습니다.',
                  confirmText: '나가기',
                  cancelText: '취소',
                  isCritical: true,
                );
              },
            ),
            SeedButton(
              label: '커스텀 대화상자',
              variant: SeedButtonVariant.brandOutline,
              onPressed: () {
                showSeedDialog(
                  context: context,
                  child: SeedDialog(
                    title: '동네 인증 완료',
                    content: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('현재 위치가 인증되었습니다. 이제 이웃들과 따뜻한 거래를 시작해보세요!'),
                    ),
                    footer: SeedButton(
                      label: '거래 시작하기',
                      isFullWidth: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: '키워드 알림 안내',
          subtitle: '필요할 때 안내를 열어보고 닫을 수 있어요',
        ),
        Wrap(
          spacing: SeedDimension.x3,
          runSpacing: SeedDimension.x3,
          children: [
            Builder(
              builder: (btnContext) => SeedButton(
                label: '키워드 알림이란?',
                variant: SeedButtonVariant.neutralWeak,
                prefixIcon: const Icon(Icons.info_outline),
                onPressed: () {
                  final renderBox = btnContext.findRenderObject() as RenderBox?;
                  final rect = renderBox != null
                      ? (renderBox.localToGlobal(Offset.zero) & renderBox.size)
                      : Rect.zero;
                  showSeedPopover(
                    context: btnContext,
                    anchorRect: rect,
                    builder: (popContext) => SeedPopover(
                      minWidth: 0,
                      maxWidth: math.min(
                        480,
                        MediaQuery.sizeOf(popContext).width - 32,
                      ),
                      titleText: '키워드 알림',
                      descriptionText: '찾고 있는 물건을 놓치지 마세요',
                      body: const Text(
                        '원하는 물품 이름을 등록하면 새로운 판매 글을 알려드려요.\n예: 맥북, 캠핑 의자',
                      ),
                      footer: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SeedButton(
                            label: '확인',
                            size: SeedButtonSize.small,
                            onPressed: () => Navigator.pop(popContext),
                          ),
                        ],
                      ),
                      onClose: () => Navigator.pop(popContext),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Bottom Sheet & Side Panel',
          subtitle: '하단 시트, 메뉴 시트, 슬라이드 사이드 패널',
        ),
        Wrap(
          spacing: SeedDimension.x3,
          runSpacing: SeedDimension.x3,
          children: [
            SeedButton(
              label: '바텀 시트 열기',
              variant: SeedButtonVariant.brandSolid,
              onPressed: () {
                showSeedBottomSheet(
                  context: context,
                  child: SeedBottomSheet(
                    title: '정렬 옵션 선택',
                    showHandle: true,
                    contentPadding: EdgeInsets.zero,
                    content: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SeedListItem(
                            titleText: '최신순',
                            prefix: const Icon(Icons.access_time, size: 22),
                            showDivider: false,
                            onTap: () => Navigator.pop(context),
                          ),
                          SeedListItem(
                            titleText: '정확도순',
                            prefix: const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 22,
                            ),
                            showDivider: false,
                            onTap: () => Navigator.pop(context),
                          ),
                          SeedListItem(
                            titleText: '가격 낮은순',
                            prefix: const Icon(Icons.arrow_downward, size: 22),
                            showDivider: false,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SeedButton(
              label: '메뉴 시트 열기',
              variant: SeedButtonVariant.neutralSolid,
              onPressed: () {
                showSeedMenuSheet(
                  context: context,
                  title: '게시글 추가 옵션',
                  groups: [
                    SeedMenuGroupData(
                      items: [
                        SeedMenuItemData(
                          label: '끌어올리기',
                          prefixIcon: const Icon(Icons.arrow_upward),
                          onTap: () => showSeedSnackbar(
                            context: context,
                            message: '끌어올렸습니다.',
                          ),
                        ),
                        SeedMenuItemData(
                          label: '숨기기',
                          prefixIcon: const Icon(Icons.visibility_off),
                        ),
                        SeedMenuItemData(
                          label: '삭제하기',
                          prefixIcon: const Icon(Icons.delete_outline),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SeedButton(
              label: '사이드 패널 슬라이드',
              variant: SeedButtonVariant.neutralWeak,
              onPressed: () {
                showSeedSidePanel(
                  context: context,
                  title: '상세 정보 패널',
                  description: '상품 정보와 거래 조건을 한눈에 확인하세요.',
                  body: const SidePanelDetails(),
                  footer: SeedButton(
                    label: '확인 완료',
                    isFullWidth: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                );
              },
            ),
            SeedButton(
              label: '스낵바 메시지',
              variant: SeedButtonVariant.brandOutline,
              onPressed: () {
                showSeedSnackbar(
                  context: context,
                  message: '키워드 알림이 설정되었습니다.',
                  actionLabel: '설정확인',
                );
              },
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'SeedMenu Component',
          subtitle: '더보기 버튼을 누르면 열리는 앵커 메뉴 드롭다운',
        ),
        const SeedMenuExample(),
      ],
    );
  }
}
