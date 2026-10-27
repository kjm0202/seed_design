import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/main.dart';
import 'package:seed_design_example/tabs/components_tab.dart';
import 'package:seed_design_example/tabs/feedback_tab.dart';
import 'package:seed_design_example/tabs/inputs_tab.dart';
import 'package:seed_design_example/tabs/navigation_tab.dart';
import 'package:seed_design_example/tabs/overlays_tab.dart';

import '../../test/support/seed_test_fonts.dart';

const _outputDir = '../screenshots/all-components-audit';
const _captureKey = ValueKey<String>('audit-capture-root');

void _assertNoOverflow(WidgetTester tester) {
  final exception = tester.takeException();
  if (exception != null) {
    if (exception is FlutterError) {
      // ignore: avoid_print
      print(exception.toStringDeep());
    }
    fail('$exception');
  }
}

void _setViewport(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
}

Future<void> _settle(WidgetTester tester, [int iterations = 10]) async {
  for (var i = 0; i < iterations; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _mount(WidgetTester tester) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: SeedDesignCatalogApp(key: UniqueKey()),
    ),
  );
  await _settle(tester);
  _assertNoOverflow(tester);
}

Future<void> _show(WidgetTester tester, Finder target) async {
  expect(target, findsWidgets);
  await tester.ensureVisible(target.first);
  await _settle(tester);
  _assertNoOverflow(tester);
}

Future<void> _snapshot(WidgetTester tester, String name) async {
  await tester.pump();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('Screenshot encoding failed: $name');
      final file = File('$_outputDir/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

void main() {
  setUpAll(() async {
    await loadSeedTestFonts(fontDirectory: '../test/assets/fonts');
    final bytes = await File('../test/assets/fonts/WantedSansVariable.ttf')
        .readAsBytes();
    for (final family in ['Pretendard', 'Roboto']) {
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  });

  group('Tab 1: Components Tab Visual Audit', () {
    testWidgets('captures all component sections and interactive states', (tester) async {
      _setViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _mount(tester);
      expect(find.byType(ComponentsTab), findsOneWidget);

      // 1. Action Buttons
      await _snapshot(tester, '01_components_action_buttons');

      // 2. Text Button & Toggle Button
      await _show(tester, find.text('Text Button'));
      await _snapshot(tester, '02_components_text_and_toggle_buttons');

      // Toggle interaction
      await tester.tap(find.text('키워드 알림 켜짐'));
      await tester.tap(find.text('관심 목록에 저장'));
      await _settle(tester);
      await _snapshot(tester, '03_components_toggle_buttons_interacted');

      // 3. Floating Action Buttons & Pressable
      await _show(tester, find.text('Floating Action Buttons'));
      await _snapshot(tester, '04_components_fabs_and_pressable');

      // 4. Badges & Chips
      await _show(tester, find.text('Badges & Chips'));
      await _snapshot(tester, '05_components_badges_and_chips');

      // Chip interaction
      await tester.tap(find.text('생활가전'));
      await _settle(tester);
      await _snapshot(tester, '06_components_chips_interacted');

      // 5. Tag Group & Selection Controls
      await _show(tester, find.text('Tag Group'));
      await _snapshot(tester, '07_components_tag_group_and_selection');

      // Selection controls interaction
      await tester.tap(find.text('직거래 희망'));
      await tester.tap(find.text('안전결제'));
      await _settle(tester);
      await _snapshot(tester, '08_components_selection_controls_interacted');

      // 6. List & List Items & Divider
      await _show(tester, find.text('List & List Items'));
      await _snapshot(tester, '09_components_list_items');

      // 7. Banner, Callout & Accordion (collapsed)
      await _show(tester, find.text('Banner, Callout & Accordion'));
      await _snapshot(tester, '10_components_banner_callout_accordion_collapsed');

      // Accordion expand
      await tester.tap(find.byType(SeedAccordionItem));
      await _settle(tester);
      await _snapshot(tester, '11_components_accordion_expanded');
    });
  });

  group('Tab 2: Feedback Tab Visual Audit', () {
    testWidgets('captures manner temp, progress, reactions, snackbars, and results', (tester) async {
      _setViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _mount(tester);
      await tester.tap(find.text('피드백 & 상태'));
      await _settle(tester);
      expect(find.byType(FeedbackTab), findsOneWidget);

      // 1. Manner Temperature initial
      await _snapshot(tester, '12_feedback_manner_temp_initial');

      // Manner Temperature Badge tap to 80°C
      await _show(tester, find.text('Manner Temp Badge'));
      await tester.tap(find.bySemanticsLabel('매너온도 80.0도로 설정'));
      await _settle(tester);
      await _show(tester, find.text('Manner Temperature'));
      await _snapshot(tester, '13_feedback_manner_temp_high');

      // Manner Temperature Badge tap to 12.5°C
      await tester.tap(find.bySemanticsLabel('매너온도 12.5도로 설정'));
      await _settle(tester);
      await _snapshot(tester, '14_feedback_manner_temp_low');

      // Manner Temp Badges grid
      await _show(tester, find.text('Manner Temp Badge'));
      await _snapshot(tester, '15_feedback_manner_temp_badges_grid');

      // 2. Progress & Skeleton
      await _show(tester, find.text('Progress & Skeleton'));
      await _snapshot(tester, '16_feedback_progress_and_skeleton');

      // 3. Reaction & Help Bubble
      await _show(tester, find.text('Reaction & Help Bubble'));
      await _snapshot(tester, '17_feedback_reaction_help_bubble');

      // Tap reaction button
      await tester.tap(find.byType(SeedReactionButton));
      await _settle(tester);
      await _snapshot(tester, '18_feedback_reaction_reacted');

      // 4. Help Bubble Trigger
      await _show(tester, find.text('Help Bubble Trigger'));
      await tester.tap(find.text('도움말 확인'));
      await _settle(tester);
      await _snapshot(tester, '19_feedback_help_bubble_trigger_open');

      // 5. Help Bubble Tooltip
      await _show(tester, find.text('Help Bubble Tooltip'));
      await _snapshot(tester, '20_feedback_help_bubble_tooltip');

      // 6. Snackbars
      await _show(tester, find.text('Snackbar'));
      // Neutral Snackbar
      await tester.tap(find.text('스낵바 메시지'));
      await _settle(tester, 6);
      await _snapshot(tester, '21_feedback_snackbar_default');

      // Positive Snackbar
      await tester.tap(find.text('성공 안내'));
      await _settle(tester, 6);
      await _snapshot(tester, '22_feedback_snackbar_positive');

      // Critical Snackbar
      await tester.tap(find.text('오류 안내'));
      await _settle(tester, 6);
      await _snapshot(tester, '23_feedback_snackbar_critical');

      // 7. Result Section
      await _show(tester, find.text('Result Section'));
      await _snapshot(tester, '24_feedback_result_section');
    });
  });

  group('Tab 3: Inputs Tab Visual Audit', () {
    testWidgets('captures forms, pickers, calendar, attachments, wheel, time and fog', (tester) async {
      _setViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _mount(tester);
      await tester.tap(find.text('입력 & 피커'));
      await _settle(tester);
      expect(find.byType(InputsTab), findsOneWidget);

      // 1. Form Controls & Quantity Picker & Slider
      await _snapshot(tester, '25_inputs_form_controls');

      // Quantity picker interaction
      final incBtn = find.descendant(
        of: find.byType(SeedQuantityPicker),
        matching: find.byIcon(Icons.add),
      );
      if (incBtn.evaluate().isNotEmpty) {
        await tester.tap(incBtn);
        await _settle(tester);
      }

      // Range slider & auto resize
      await _show(tester, find.text('범위 선택'));
      await _snapshot(tester, '26_inputs_range_slider_and_autoresize');

      // 2. Select & Input Button
      await _show(tester, find.text('Select & Input Button'));
      await _snapshot(tester, '27_inputs_select_and_input_button');

      // 3. Attachment Input & Dropzone
      await _show(tester, find.text('Attachment Input & Dropzone'));
      await _snapshot(tester, '28_inputs_attachment_example');

      // 4. Date Picker (Calendar)
      await _show(tester, find.text('Date Picker'));
      await _snapshot(tester, '29_inputs_calendar_month_view');

      // Switch calendar layout to week
      final layoutSelect = find.byKey(const ValueKey('calendar-layout'));
      if (layoutSelect.evaluate().isNotEmpty) {
        await tester.tap(layoutSelect);
        await _settle(tester);
        await _snapshot(tester, '30_inputs_calendar_layout_dropdown');
        if (find.text('주간 보기').evaluate().isNotEmpty) {
          await tester.tap(find.text('주간 보기').last);
          await _settle(tester);
          await _snapshot(tester, '31_inputs_calendar_week_view');
        }
      }

      // 5. Wheel Picker & Time Picker
      await _show(tester, find.text('Wheel Picker & Time Picker'));
      await _snapshot(tester, '32_inputs_wheel_and_time_picker');

      // 6. Scroll Fog
      await _show(tester, find.text('Scroll Fog'));
      await _snapshot(tester, '33_inputs_scroll_fog_start');
      final horizontalList = find.byWidgetPredicate(
        (widget) => widget is ListView && widget.scrollDirection == Axis.horizontal,
      );
      if (horizontalList.evaluate().isNotEmpty) {
        final scroll = tester.state<ScrollableState>(
          find.descendant(of: horizontalList, matching: find.byType(Scrollable)),
        );
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await _settle(tester);
        await _snapshot(tester, '34_inputs_scroll_fog_end');
      }
    });
  });

  group('Tab 4: Navigation Tab Visual Audit', () {
    testWidgets('captures tabs, segmented, pagination, avatars, placeholders, side nav, footer', (tester) async {
      _setViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _mount(tester);
      await tester.tap(find.text('탐색 & 레이아웃'));
      await _settle(tester);
      expect(find.byType(NavigationTab), findsOneWidget);

      // 1. Line Tabs & Chip Tabs
      await _snapshot(tester, '35_navigation_tabs_initial');

      // Switch line tab to '동네생활'
      await tester.tap(find.text('동네생활'));
      await _settle(tester);
      await _snapshot(tester, '36_navigation_line_tab_neighborhood');

      // Switch chip tab to '가격낮은순'
      await tester.tap(find.text('가격낮은순'));
      await _settle(tester);
      await _snapshot(tester, '37_navigation_chip_tab_price');

      // 2. Segmented Control
      await _show(tester, find.text('Segmented Control'));
      await _snapshot(tester, '38_navigation_segmented_control_initial');
      await tester.tap(find.text('판매중'));
      await _settle(tester);
      await _snapshot(tester, '39_navigation_segmented_control_selling');

      // 3. Pagination & Table Controls
      await _show(tester, find.text('Pagination & Table Controls'));
      await _snapshot(tester, '40_navigation_pagination_and_table');

      // Change page
      final page5 = find.descendant(
        of: find.byType(SeedPagination),
        matching: find.text('5'),
      );
      if (page5.evaluate().isNotEmpty) {
        await tester.tap(page5);
        await _settle(tester);
        await _snapshot(tester, '41_navigation_pagination_page_5');
      }

      // 4. Top Navigation
      await _show(tester, find.text('Top Navigation'));
      await _snapshot(tester, '42_navigation_top_navigation_bar');

      // 5. Avatar & Avatar Stack
      await _show(tester, find.text('Avatar & Avatar Stack'));
      await _snapshot(tester, '43_navigation_avatars_and_stack');

      // 6. Image Frame & Content Placeholders
      await _show(tester, find.text('Image Frame & Content Placeholders'));
      await _snapshot(tester, '44_navigation_image_frame_and_placeholders');

      // 7. Side Navigation
      await _show(tester, find.text('Side Navigation'));
      await _snapshot(tester, '45_navigation_side_navigation');

      // 8. Footer
      await _show(tester, find.text('Footer'));
      await _snapshot(tester, '46_navigation_footer');
    });
  });

  group('Tab 5: Overlays Tab Visual Audit', () {
    testWidgets('captures dialogs, popovers, bottom sheets, menus, and side panels', (tester) async {
      _setViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _mount(tester);
      await tester.tap(find.text('오버레이'));
      await _settle(tester);
      expect(find.byType(OverlaysTab), findsOneWidget);

      // 1. Overlays overview
      await _snapshot(tester, '47_overlays_tab_overview');

      // 2. Confirm Alert Dialog
      await tester.tap(find.text('기본 확인 알림창'));
      await _settle(tester);
      await _snapshot(tester, '48_overlays_dialog_confirm');
      await tester.tap(find.text('취소'));
      await _settle(tester);

      // 3. Critical Alert Dialog
      await tester.tap(find.text('위험 경고 알림창'));
      await _settle(tester);
      await _snapshot(tester, '49_overlays_dialog_critical');
      await tester.tap(find.text('취소'));
      await _settle(tester);

      // 4. Custom Dialog
      await tester.tap(find.text('커스텀 대화상자'));
      await _settle(tester);
      await _snapshot(tester, '50_overlays_dialog_custom');
      await tester.tap(find.text('거래 시작하기'));
      await _settle(tester);

      // 5. Popover
      await _show(tester, find.text('Popover'));
      await tester.tap(find.text('키워드 알림이란?'));
      await _settle(tester);
      await _snapshot(tester, '51_overlays_popover_open');
      await tester.tap(find.text('확인'));
      await _settle(tester);

      // 6. Bottom Sheet
      await _show(tester, find.text('Bottom Sheet & Side Panel'));
      await tester.tap(find.text('바텀 시트 열기'));
      await _settle(tester);
      await _snapshot(tester, '52_overlays_bottom_sheet_open');
      await tester.tap(find.text('최신순'));
      await _settle(tester);

      // 7. Snap Sheet
      await tester.tap(find.text('스냅 시트 열기'));
      await _settle(tester);
      await _snapshot(tester, '53_overlays_snap_sheet_open');
      await tester.tapAt(const Offset(20, 50));
      await _settle(tester);

      // 8. Menu Sheet
      await tester.tap(find.text('메뉴 시트 열기'));
      await _settle(tester);
      await _snapshot(tester, '54_overlays_menu_sheet_open');
      await tester.tapAt(const Offset(20, 50));
      await _settle(tester);

      // 9. Side Panel
      await tester.tap(find.text('사이드 패널 슬라이드'));
      await _settle(tester);
      await _snapshot(tester, '55_overlays_side_panel_open');
      await tester.tap(find.text('확인 완료'));
      await _settle(tester);

      // 10. SeedMenu
      await _show(tester, find.text('SeedMenu Component'));
      final moreButton = find.byIcon(Icons.more_vert);
      if (moreButton.evaluate().isNotEmpty) {
        await tester.tap(moreButton.first);
        await _settle(tester);
        await _snapshot(tester, '56_overlays_seed_menu_open');
        await tester.tapAt(const Offset(20, 50));
        await _settle(tester);
      }
    });
  });

  group('Dark Mode Full Visual Audit', () {
    testWidgets('captures all tabs in dark theme', (tester) async {
      _setViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _mount(tester);
      // Toggle to dark mode
      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await _settle(tester);

      // Dark Tab 1: Components
      await _snapshot(tester, '57_dark_components_action_buttons');
      await _show(tester, find.text('Badges & Chips'));
      await _snapshot(tester, '58_dark_components_badges_and_chips');
      await _show(tester, find.text('Banner, Callout & Accordion'));
      await _snapshot(tester, '59_dark_components_banner_and_callout');

      // Dark Tab 2: Feedback
      await tester.tap(find.text('피드백 & 상태'));
      await _settle(tester);
      await _snapshot(tester, '60_dark_feedback_manner_temp');
      await _show(tester, find.text('Snackbar'));
      await tester.tap(find.text('스낵바 메시지'));
      await _settle(tester, 6);
      await _snapshot(tester, '61_dark_feedback_snackbar');

      // Dark Tab 3: Inputs
      await tester.tap(find.text('입력 & 피커'));
      await _settle(tester);
      await _snapshot(tester, '62_dark_inputs_form_controls');
      await _show(tester, find.text('Date Picker'));
      await _snapshot(tester, '63_dark_inputs_calendar');
      await _show(tester, find.text('Wheel Picker & Time Picker'));
      await _snapshot(tester, '64_dark_inputs_wheel_and_time');

      // Dark Tab 4: Navigation
      await tester.tap(find.text('탐색 & 레이아웃'));
      await _settle(tester);
      await _snapshot(tester, '65_dark_navigation_tabs');
      await _show(tester, find.text('Avatar & Avatar Stack'));
      await _snapshot(tester, '66_dark_navigation_avatars');

      // Dark Tab 5: Overlays
      await tester.tap(find.text('오버레이'));
      await _settle(tester);
      await tester.tap(find.text('기본 확인 알림창'));
      await _settle(tester);
      await _snapshot(tester, '67_dark_overlays_dialog');
      await tester.tap(find.text('취소'));
      await _settle(tester);

      await tester.tap(find.text('바텀 시트 열기'));
      await _settle(tester);
      await _snapshot(tester, '68_dark_overlays_bottom_sheet');
      await tester.tap(find.text('최신순'));
      await _settle(tester);
    });
  });
}
