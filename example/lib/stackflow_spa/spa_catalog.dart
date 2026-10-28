import 'package:flutter/material.dart';

class SpaEntry {
  const SpaEntry(this.title, this.activity, {this.arguments});

  final String title;
  final String activity;
  final Object? arguments;
}

class SpaSection {
  const SpaSection(this.title, this.icon, this.entries);

  final String title;
  final IconData icon;
  final List<SpaEntry> entries;
}

/// The twelve sections of React's ActivityHome, excluding its bug reproducers.
const spaSections = <SpaSection>[
  SpaSection('AppScreen', Icons.layers_outlined, [
    SpaEntry('App Bar 슬롯과 긴 제목', 'ActivityLayerBar'),
    SpaEntry('투명 App Bar', 'ActivityTransparentBar'),
    SpaEntry('좌우 safe area와 bleed', 'ActivitySafeAreaBleed'),
    SpaEntry('@stackflow/plugin-basic-ui', 'ActivityPluginBasicUI'),
    SpaEntry('스와이프백 키보드', 'ActivitySwipeBackKeyboard'),
    SpaEntry('홈 다시 push', 'ActivityHome'),
    SpaEntry(
      '전환: slideFromRightIOS',
      'ActivityTransitionStyle',
      arguments: {'transitionStyle': 'slideFromRightIOS'},
    ),
    SpaEntry(
      '전환: fadeFromBottomAndroid',
      'ActivityTransitionStyle',
      arguments: {'transitionStyle': 'fadeFromBottomAndroid'},
    ),
    SpaEntry(
      '전환: fadeIn',
      'ActivityTransitionStyle',
      arguments: {'transitionStyle': 'fadeIn'},
    ),
  ]),
  SpaSection('Drawer', Icons.vertical_align_bottom_rounded, [
    SpaEntry('Bottom Sheet', 'ActivityBottomSheet'),
    SpaEntry('Bottom Sheet modal 토글', 'ActivityBottomSheetModalTest'),
    SpaEntry('Text Field만 있는 Bottom Sheet', 'ActivityBottomSheetTextField'),
    SpaEntry(
      'Bottom Sheet snapPoints와 입력 포커스',
      'ActivityBottomSheetInputFocus',
    ),
    SpaEntry(
      'Bottom Sheet Keyboard Playground',
      'ActivityBottomSheetKeyboardPlayground',
    ),
    SpaEntry(
      'Bottom Sheet 위 Alert Dialog (step)',
      'ActivityBottomSheetWithAlertDialogStep',
    ),
    SpaEntry(
      'Bottom Sheet 위 Alert Dialog (activity)',
      'ActivityNestedBottomSheet',
    ),
    SpaEntry('Menu Sheet', 'ActivityMenuSheet'),
    SpaEntry('Swipeable Menu Sheet', 'ActivitySwipeableMenuSheet'),
    SpaEntry('Side Panel', 'ActivitySidePanel'),
    SpaEntry('Responsive Side Panel', 'ActivityResponsiveSidePanel'),
  ]),
  SpaSection('Dialog', Icons.web_asset_outlined, [
    SpaEntry('Alert Dialog (step)', 'HomeAlertDialogStep'),
    SpaEntry('Alert Dialog (activity)', 'ActivityAlertDialog'),
    SpaEntry('Responsive Dialog', 'ActivityResponsiveDialog'),
  ]),
  SpaSection('Menu & Popover', Icons.menu_open, [
    SpaEntry('Menu', 'ActivityMenu'),
    SpaEntry('List Button Item으로 여는 Menu', 'HomeListMenu'),
    SpaEntry('Help Bubble', 'ActivityHelpBubble'),
    SpaEntry('Popover', 'ActivityPopover'),
  ]),
  SpaSection('Pull to Refresh', Icons.refresh, [
    SpaEntry('기본', 'ActivityPullToRefreshPreview'),
    SpaEntry('Tabs와 조합', 'ActivityPullToRefreshTabs'),
    SpaEntry('preventPull', 'ActivityPullToRefreshPreventPull'),
    SpaEntry('Article 텍스트 선택 중 당김 차단', 'ActivityArticlePreventPull'),
  ]),
  SpaSection('Navigation', Icons.explore_outlined, [
    SpaEntry('Tabs', 'ActivityTabs'),
    SpaEntry('Animated Tabs', 'ActivityAnimatedTabs'),
    SpaEntry('Swipeable Tabs', 'ActivitySwipeableTabs'),
    SpaEntry('Tabs autoHeight와 지연 로딩', 'ActivityTabsAutoHeightLazy'),
    SpaEntry('Chip Tabs와 Scroll Fog', 'ActivityChipTabsScrollFog'),
    SpaEntry('Pagination', 'ActivityPagination'),
    SpaEntry('Side Navigation', 'ActivitySideNavigation'),
  ]),
  SpaSection('List', Icons.list_alt_rounded, [
    SpaEntry('List Item', 'ActivityListItem'),
    SpaEntry('List Image Frame', 'ActivityListImageFrame'),
    SpaEntry('List Button Item', 'ActivityListButtonItem'),
    SpaEntry('List Link Item', 'ActivityListLinkItem'),
    SpaEntry('List Switch Item', 'ActivityListSwitchItem'),
    SpaEntry('List Check Item', 'ActivityListCheckItem'),
    SpaEntry('List Radio Item', 'ActivityListRadioItem'),
  ]),
  SpaSection('Form', Icons.edit_note_outlined, [
    SpaEntry('Switch', 'ActivitySwitch'),
    SpaEntry('Checkbox', 'ActivityCheckbox'),
    SpaEntry('Quantity Picker', 'ActivityQuantityPicker'),
    SpaEntry('Radio Group', 'ActivityRadioGroup'),
    SpaEntry('Segmented Control', 'ActivitySegmentedControl'),
    SpaEntry('Select', 'ActivitySelect'),
    SpaEntry('Time Picker', 'ActivityTimePicker'),
    SpaEntry('Wheel Picker', 'ActivityWheelPicker'),
    SpaEntry('Attachment Field', 'ActivityAttachmentField'),
    SpaEntry('Attachment Display Field', 'ActivityAttachmentDisplayField'),
    SpaEntry('여러 필드 조합', 'ActivityForm'),
  ]),
  SpaSection('Button & Chip', Icons.touch_app_outlined, [
    SpaEntry('Action Button', 'ActivityActionButton'),
    SpaEntry('Toggle Button', 'ActivityToggleButton'),
    SpaEntry('Reaction Button', 'ActivityReactionButton'),
    SpaEntry('Chip Button', 'ActivityChipButton'),
    SpaEntry('Chip Toggle', 'ActivityChipToggle'),
  ]),
  SpaSection('Content Display', Icons.image_outlined, [
    SpaEntry('Avatar', 'ActivityAvatar'),
    SpaEntry('Avatar Stack', 'ActivityAvatarStack'),
    SpaEntry('Badge', 'ActivityBadge'),
    SpaEntry('Tag Group', 'ActivityTagGroup'),
    SpaEntry('Manner Temp Badge', 'ActivityMannerTempLevel'),
    SpaEntry('Accordion', 'ActivityAccordion'),
    SpaEntry('Result Section', 'ActivityResultSection'),
  ]),
  SpaSection('Snackbar', Icons.message_outlined, [
    SpaEntry('기본', 'SnackbarDefault'),
    SpaEntry('positive', 'SnackbarPositive'),
    SpaEntry('critical', 'SnackbarCritical'),
    SpaEntry('queued', 'SnackbarQueued'),
    SpaEntry('dismiss 후 setTimeout 우회', 'SnackbarWorkaround'),
  ]),
  SpaSection('Foundation', Icons.palette_outlined, [
    SpaEntry('Box margin prop', 'ActivityMarginPlayground'),
    SpaEntry('폰트 배율 레이아웃', 'ActivityFontMultiplierLayout'),
    SpaEntry('타이포그래피 스케일', 'ActivityTypographyScale'),
    SpaEntry('Scale Feedback', 'ActivityScaleFeedback'),
    SpaEntry('부분 다크 모드', 'ActivityPartialDarkMode'),
  ]),
];

String spaActivityTitle(String activity) {
  const titles = {
    'ActivityPullToRefreshPreview': 'Pull To Refresh',
    'ActivityPullToRefreshTabs': 'Pull To Refresh',
    'ActivityPullToRefreshPreventPull': 'Pull To Refresh',
    'ActivityArticlePreventPull': 'Pull To Refresh',
    'ActivityArticlePreventDrag': 'Tabs',
    'ActivityAppScreenPreview': 'Preview',
    'ActivityAppScreenTransparent': 'Preview',
    'ActivityResultSectionCtaProgressCircle': '환불 요청',
    'ActivityBottomSheetActivity': 'Activity',
    'ActivityMenuSheetActivity': 'Activity',
    'ActivitySidePanelActivity': 'Side Panel Activity',
  };
  if (titles.containsKey(activity)) return titles[activity]!;
  if (activity == 'ActivityHome') return 'Home';
  if (activity == 'ActivityDemoHome') return 'Demo';
  if (activity == 'ActivityDemoArticleDetail') return '';
  for (final section in spaSections) {
    for (final entry in section.entries) {
      if (entry.activity == activity) return entry.title;
    }
  }
  return activity.replaceFirst(RegExp(r'^Activity'), '');
}
