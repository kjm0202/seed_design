import 'dart:io';
import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'support/seed_test_fonts.dart';

Future<void> captureComponent(
  WidgetTester tester,
  Widget widget,
  String filename, {
  double width = 420,
  double? height,
}) async {
  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    MaterialApp(
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF7F8F9),
        body: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: Colors.white,
              width: width,
              height: height,
              child: widget,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));

  await tester.binding.runAsync(() async {
    final RenderRepaintBoundary boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final file = File('screenshots/flutter/$filename');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(buffer);
  });
}

void main() {
  setUpAll(loadSeedTestFonts);
  testWidgets('Generate component screenshots', (tester) async {
    // 1. Action Button
    await captureComponent(
      tester,
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SeedButton(label: 'Brand Solid', variant: SeedButtonVariant.brandSolid, onPressed: () {}),
          SeedButton(label: 'Neutral Solid', variant: SeedButtonVariant.neutralSolid, onPressed: () {}),
          SeedButton(label: 'Neutral Weak', variant: SeedButtonVariant.neutralWeak, onPressed: () {}),
          SeedButton(label: 'Brand Outline', variant: SeedButtonVariant.brandOutline, onPressed: () {}),
          SeedButton(label: 'Neutral Outline', variant: SeedButtonVariant.neutralOutline, onPressed: () {}),
          SeedButton(label: 'Critical Solid', variant: SeedButtonVariant.criticalSolid, onPressed: () {}),
          SeedButton(label: 'Ghost', variant: SeedButtonVariant.ghost, onPressed: () {}),
        ],
      ),
      'action-button.png',
    );

    // 2. Badge & Notification Badge
    await captureComponent(
      tester,
      Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [
          SeedBadge(label: '브랜드', tone: SeedBadgeTone.brand),
          SeedBadge(label: '중립', tone: SeedBadgeTone.neutral),
          SeedBadge(label: '긍정', tone: SeedBadgeTone.positive),
          SeedBadge(label: '주의', tone: SeedBadgeTone.warning),
          SeedBadge(label: '위험', tone: SeedBadgeTone.critical),
          SeedNotificationBadge(count: 5),
          SeedNotificationBadge(count: 120, maxCount: 99),
        ],
      ),
      'badge.png',
    );

    // 3. Manner Temp
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SeedMannerTemp(temperature: 36.5),
          SizedBox(height: 16),
          SeedMannerTemp(temperature: 42.0),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SeedMannerTempBadge(temperature: 25.0),
              SeedMannerTempBadge(temperature: 36.5),
              SeedMannerTempBadge(temperature: 55.0),
              SeedMannerTempBadge(temperature: 80.0),
            ],
          ),
        ],
      ),
      'manner-temp.png',
    );

    // 4. Chip
    await captureComponent(
      tester,
      Wrap(
        spacing: 8,
        children: [
          const SeedChip(label: '선택됨', selected: true),
          const SeedChip(label: '미선택', selected: false),
          SeedChip(label: '삭제가능', selected: true, onDeleted: () {}),
        ],
      ),
      'chip.png',
    );

    // 5. Callout
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SeedCallout(
            title: '안내 타이틀',
            description: '사용자에게 유용한 팁이나 정보를 전달합니다.',
            tone: SeedCalloutTone.informative,
          ),
          SizedBox(height: 12),
          SeedCallout(
            title: '주의 알림',
            description: '주의가 필요한 항목을 경고합니다.',
            tone: SeedCalloutTone.warning,
          ),
        ],
      ),
      'callout.png',
    );

    // 6. Checkbox, Switch, Radio
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeedCheckbox(value: true, label: '선택된 체크박스', onChanged: (_) {}),
          SeedCheckbox(value: false, label: '미선택 체크박스', onChanged: (_) {}),
          const SizedBox(height: 12),
          SeedSwitch(value: true, label: '스위치 ON (24px)', onChanged: (_) {}),
          SeedSwitch(value: false, label: '스위치 OFF (24px)', onChanged: (_) {}),
          const SizedBox(height: 12),
          SeedRadio<int>(value: 1, groupValue: 1, label: '라디오 옵션 1 (선택)', onChanged: (_) {}),
          SeedRadio<int>(value: 2, groupValue: 1, label: '라디오 옵션 2 (미선택)', onChanged: (_) {}),
        ],
      ),
      'selection.png',
    );

    // 7. Select Box
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SeedSelectBox(
            selected: true,
            title: '택배거래',
            description: '택배로 물품을 안전하게 발송해요',
          ),
          SizedBox(height: 12),
          SeedSelectBox(
            selected: false,
            title: '직접 만나서 거래',
            description: '동네에서 직접 만나 물품을 확인해요',
          ),
        ],
      ),
      'select-box.png',
    );

    // 8. Field & TextInput
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SeedField(
            label: '닉네임',
            required: true,
            helperText: '2~10자의 한글, 영문, 숫자',
            child: SeedTextInput(hintText: '닉네임을 입력하세요'),
          ),
          SizedBox(height: 16),
          SeedField(
            label: '판매 가격',
            required: true,
            errorMessage: '가격을 올바르게 입력해주세요',
            child: SeedTextInput(
              initialValue: '10000',
              hasError: true,
            ),
          ),
        ],
      ),
      'text-input-field.png',
    );

    // 9. Quantity Picker & Slider
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SeedQuantityPicker(value: 3, onChanged: null),
          const SizedBox(height: 20),
          SeedSlider(value: 45, min: 0, max: 100, onChanged: (_) {}),
        ],
      ),
      'quantity-slider.png',
    );

    // 10. Input Button & Select
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SeedInputButton(
            value: '서울시 서초구 반포동',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          const SizedBox(height: 16),
          SeedSelect<String>(
            value: 'it',
            groups: const [
              SeedSelectGroup(
                label: '직군 선택',
                items: [
                  SeedSelectItem(value: 'it', label: '개발 / IT'),
                  SeedSelectItem(value: 'design', label: '디자인'),
                ],
              ),
            ],
          ),
        ],
      ),
      'input-button-select.png',
    );

    // 11. Attachment Input
    await captureComponent(
      tester,
      const SeedAttachmentInput(
        items: [
          SeedAttachmentItem(id: '1', isRepresentative: true),
          SeedAttachmentItem(id: '2'),
        ],
        maxCount: 10,
      ),
      'attachment-input.png',
    );

    // 12. Wheel Picker & Time Picker
    await captureComponent(
      tester,
      const SeedTimePicker(
        initialTime: TimeOfDay(hour: 9, minute: 45),
      ),
      'time-picker.png',
      height: 240,
    );

    // 13. Date Picker
    await captureComponent(
      tester,
      SeedDatePicker(
        initialDate: DateTime(2026, 10, 17),
      ),
      'date-picker.png',
      width: 360,
    );

    // 14. Tabs & Segmented Control
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeedTabs(
            selectedIndex: 0,
            onTabSelected: (_) {},
            items: const [
              SeedTabItem(label: '홈'),
              SeedTabItem(label: '동네생활', showNotificationDot: true),
              SeedTabItem(label: '내 근처'),
            ],
          ),
          const SizedBox(height: 20),
          SeedSegmentedControl<int>(
            selectedValue: 1,
            onValueChanged: (_) {},
            segments: const [
              SeedSegment(value: 0, label: '전체'),
              SeedSegment(value: 1, label: '판매중'),
              SeedSegment(value: 2, label: '거래완료'),
            ],
          ),
        ],
      ),
      'tabs-segmented.png',
    );

    // 15. Pagination & Table Pagination
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeedPagination(
            currentPage: 3,
            totalPages: 10,
            onPageChanged: (_) {},
          ),
          const SizedBox(height: 20),
          SeedTablePagination(
            currentPage: 2,
            totalItems: 320,
            rowsPerPage: 10,
            onPageChanged: (_) {},
            onRowsPerPageChanged: (_) {},
          ),
        ],
      ),
      'pagination.png',
      width: 520,
    );

    // 16. Image Frame & Placeholders
    await captureComponent(
      tester,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          SizedBox(
            width: 100,
            child: SeedImageFrame(
              ratio: SeedImageRatio.square,
              badge: '대표사진',
            ),
          ),
          SeedIdentityPlaceholder(type: SeedIdentityType.person, size: 56),
          SeedIdentityPlaceholder(type: SeedIdentityType.business, size: 56),
          SeedContentPlaceholder(width: 80, height: 80),
        ],
      ),
      'image-frame-placeholders.png',
    );

    // 17. Menu & Menu Sheet
    await captureComponent(
      tester,
      SeedMenu(
        groups: [
          SeedMenuGroupData(
            label: '게시글 작업',
            items: [
              const SeedMenuItemData(
                label: '끌어올리기',
                prefixIcon: Icon(Icons.arrow_upward),
                badge: 'N',
              ),
              const SeedMenuItemData(
                label: '숨기기',
                prefixIcon: Icon(Icons.visibility_off),
              ),
              const SeedMenuItemData(
                label: '삭제하기',
                prefixIcon: Icon(Icons.delete_outline),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
      'menu.png',
    );

    // 18. Bottom Navigation
    await captureComponent(
      tester,
      SeedBottomNavigation(
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          SeedBottomNavigationItem(label: '홈', icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home)),
          SeedBottomNavigationItem(label: '동네생활', icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article)),
          SeedBottomNavigationItem(label: '내 근처', icon: Icon(Icons.place_outlined), activeIcon: Icon(Icons.place)),
          SeedBottomNavigationItem(label: '채팅', icon: Icon(Icons.chat_bubble_outline), notificationCount: 3),
          SeedBottomNavigationItem(label: '나의 당근', icon: Icon(Icons.person_outline), showNotificationDot: true),
        ],
      ),
      'bottom-navigation.png',
      width: 420,
    );

    // 19. Side Navigation
    await captureComponent(
      tester,
      SizedBox(
        height: 280,
        child: SeedSideNavigation(
          header: const Text('당근 비즈니스'),
          groups: const [
            SeedSideNavGroup(
              label: '광고 관리',
              items: [
                SeedSideNavItem(id: '1', label: '캠페인 목록', icon: Icons.campaign),
                SeedSideNavItem(id: '2', label: '성과 보고서', icon: Icons.bar_chart, badge: 'NEW'),
              ],
            ),
          ],
        ),
      ),
      'side-navigation.png',
      width: 260,
      height: 320,
    );

    // 20. Side Panel
    await captureComponent(
      tester,
      SizedBox(
        height: 300,
        child: SeedSidePanel(
          title: '거래 상세 설정',
          description: '거래 장소와 결제 방식을 선택하세요.',
          body: const Text('패널 본문 콘텐츠 영역입니다.'),
          footer: SeedButton(label: '설정 저장', isFullWidth: true, onPressed: () {}),
        ),
      ),
      'side-panel.png',
      width: 380,
      height: 340,
    );

    // 21. Help Bubble & Page Banner
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SeedPageBanner(
            title: '안전 거래 안내',
            description: '타 사이트로 유도하여 결제를 요구하는 경우 사기 위험이 있으니 주의하세요.',
            tone: SeedPageBannerTone.informative,
          ),
          SizedBox(height: 20),
          SeedHelpBubble(
            title: '당근페이 간편 송금',
            description: '계좌번호 없이 채팅방에서 바로 송금할 수 있어요.',
          ),
        ],
      ),
      'banner-help-bubble.png',
    );

    // 22. Result Section & Skeletons
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SeedResultSection(
            title: '검색 결과가 없습니다',
            description: '다른 검색어를 입력하거나 필터를 재설정해보세요.',
          ),
          SizedBox(height: 20),
          Row(
            children: [
              SeedSkeleton.circle(size: 48),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeedSkeleton(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    SeedSkeleton(width: 140, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      'result-skeleton.png',
    );

    // 23. Footer
    await captureComponent(
      tester,
      const SeedFooter(
        brandName: '당근마켓',
        companyInfo: '(주)당근마켓 | 대표: 김재현 | 사업자번호: 375-87-00088',
        policyLinks: [
          SeedFooterLink(label: '이용약관'),
          SeedFooterLink(label: '개인정보처리방침'),
        ],
      ),
      'footer.png',
      width: 440,
    );

    // 24. Floating & Reaction Buttons
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SeedFloatingActionButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
              SeedFloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: '라벨',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SeedContextualFloatingButton(
                icon: const Icon(Icons.add),
                label: '라벨',
                tone: SeedContextualFloatingButtonTone.solid,
                onPressed: () {},
              ),
              SeedContextualFloatingButton(
                icon: const Icon(Icons.arrow_upward),
                label: '맨 위로',
                tone: SeedContextualFloatingButtonTone.layer,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SeedReactionButton(
                isReacted: false,
                count: 12,
                onReactedChanged: (_) {},
              ),
              SeedReactionButton(
                isReacted: true,
                count: 13,
                onReactedChanged: (_) {},
              ),
            ],
          ),
        ],
      ),
      'floating-reaction-buttons.png',
      width: 420,
    );

    // 25. Accordion
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SeedAccordionItem(
            prefix: Icon(Icons.account_circle_outlined, size: 28),
            title: '아코디언 아이템 제목',
            description: '설명을 입력해주세요.',
            initiallyExpanded: false,
            content: SizedBox.shrink(),
          ),
          SeedAccordionItem(
            prefix: Icon(Icons.account_circle_outlined, size: 28),
            title: '아코디언 아이템 제목',
            initiallyExpanded: false,
            content: SizedBox.shrink(),
          ),
          SeedAccordionItem(
            prefix: Icon(Icons.account_circle_outlined, size: 28),
            title: '아코디언 아이템 제목 (펼쳐짐)',
            initiallyExpanded: true,
            content: Text('커스텀 콘텐츠 영역입니다. 상세 내용이 여기에 표시됩니다.'),
          ),
        ],
      ),
      'accordion.png',
      width: 420,
    );

    // 26. Dialog & Alert Dialog
    await captureComponent(
      tester,
      Container(
        color: const Color(0x74000000),
        padding: const EdgeInsets.all(24.0),
        child: SeedDialog(
          title: '타이틀을 작성해주세요',
          description: '디스크립션을 작성해주세요.',
          content: Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF4FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB9DAFF)),
            ),
            child: const Text('Content Area'),
          ),
          subAction: TextButton(
            onPressed: () {},
            child: const Text('보조 액션', style: TextStyle(color: Colors.black87)),
          ),
          secondaryAction: SeedButton(
            label: '라벨',
            variant: SeedButtonVariant.neutralWeak,
            onPressed: () {},
          ),
          primaryAction: SeedButton(
            label: '라벨',
            variant: SeedButtonVariant.neutralSolid,
            onPressed: () {},
          ),
        ),
      ),
      'dialog.png',
      width: 480,
    );

    // 27. Bottom Sheet
    await captureComponent(
      tester,
      Container(
        color: const Color(0x74000000),
        padding: const EdgeInsets.only(top: 40.0),
        child: SeedBottomSheet(
          title: '타이틀을 입력해주세요',
          showCloseButton: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('본문 내용을 입력해주세요', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              Container(
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Content Area'),
              ),
            ],
          ),
          footer: SeedButton(
            label: '라벨',
            isFullWidth: true,
            variant: SeedButtonVariant.neutralSolid,
            onPressed: () {},
          ),
        ),
      ),
      'bottom-sheet.png',
      width: 420,
    );

    // 28. Menu Sheet
    await captureComponent(
      tester,
      Container(
        color: const Color(0x74000000),
        padding: const EdgeInsets.only(top: 40.0),
        child: SeedMenuSheet(
          title: '타이틀을 입력해주세요',
          description: '부가적인 설명이 필요할 때에만 사용해요.',
          groups: [
            SeedMenuGroupData(
              items: const [
                SeedMenuItemData(label: '라벨'),
                SeedMenuItemData(label: '라벨'),
                SeedMenuItemData(label: '라벨'),
              ],
            ),
            SeedMenuGroupData(
              items: const [
                SeedMenuItemData(label: '삭제하기', isDestructive: true),
              ],
            ),
          ],
          cancelLabel: '닫기',
        ),
      ),
      'menu-sheet.png',
      width: 420,
    );

    // 29. Top Navigation
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeedTopNavigation(
            titleText: '타이틀',
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          SeedTopNavigation(
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
            titleText: '타이틀',
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          SeedTopNavigation(
            leading: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SeedAvatar(size: SeedAvatarSize.small),
                SizedBox(width: 8),
                Text('타이틀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
            actions: [
              TextButton(onPressed: () {}, child: const Text('Button', style: TextStyle(color: Colors.black87))),
            ],
          ),
        ],
      ),
      'top-navigation.png',
      width: 440,
    );

    // 30. Progress Circle
    await captureComponent(
      tester,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          SeedProgressCircle(size: 24),
          SeedProgressCircle(size: 36),
          SeedProgressCircle(size: 36, value: 0.35),
          SeedProgressCircle(size: 36, value: 0.75),
          SeedProgressCircle(size: 36, value: 1.0),
        ],
      ),
      'progress-circle.png',
      width: 400,
    );

    // 31. List, Avatar, TagGroup, Divider, ScrollFog
    await captureComponent(
      tester,
      Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  SeedAvatar(size: SeedAvatarSize.small),
                  SeedAvatar(size: SeedAvatarSize.medium),
                  SeedAvatar(size: SeedAvatarSize.large),
                  SeedAvatar(size: SeedAvatarSize.xlarge),
                ],
              ),
              const SizedBox(height: 16),
              SeedTagGroup(
                items: const [
                  SeedTagItem(label: '디지털기기'),
                  SeedTagItem(label: '끌올 1분 전'),
                  SeedTagItem(label: '서초구 반포동', tone: SeedTagTone.brand),
                ],
              ),
              const SizedBox(height: 16),
              SeedListItem(
                prefix: const SeedAvatar(size: SeedAvatarSize.medium),
                titleText: '당근 마스코트',
                detailText: '안녕하세요! 반갑습니다.',
                suffix: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              SeedListItem(
                prefix: const Icon(Icons.storefront_outlined),
                titleText: '동네 상점 알림',
                detailText: '새로운 소식이 도착했습니다.',
                suffix: const SeedBadge(label: 'NEW', tone: SeedBadgeTone.brand),
                onTap: () {},
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SeedScrollFog(placement: SeedScrollFogPlacement.bottom, size: 28),
          ),
        ],
      ),
      'list-avatar-tags.png',
      width: 420,
    );

    // 32. Snackbar
    await captureComponent(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SeedSnackbar(
            message: '게시글이 성공적으로 등록되었습니다.',
          ),
          const SizedBox(height: 12),
          SeedSnackbar(
            message: '장바구니에 상품을 담았습니다.',
            actionLabel: '바로가기',
            onAction: () {},
          ),
        ],
      ),
      'snackbar.png',
      width: 420,
    );
  });
}
