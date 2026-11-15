/// SEED Design의 디자인 토큰과 UI 컴포넌트를 Flutter에서 사용하는 공개 라이브러리.
///
/// 당근의 [SEED Design](https://seed-design.io/)을 기반으로 한 **비공식 Flutter
/// 포트**다. 공식 React 컴포넌트의 개념과 상태 API를 가능한 한 유지하면서,
/// Flutter의 위젯 트리, 포커스, `Form`, `Navigator` 및 컨트롤러 모델에 맞춰
/// 구현한다. 공식 구현과 Flutter 확장은 각 클래스 및 멤버 문서를 참고한다.
///
/// 이 파일은 애플리케이션에서 지원하는 단일 공개 진입점이다.
///
/// ```dart
/// import 'package:material_ui/material_ui.dart';
/// import 'package:seed_design/seed_design.dart';
///
/// MaterialApp(
///   theme: SeedThemeData.light().toThemeData(),
///   darkTheme: SeedThemeData.dark().toThemeData(),
///   home: Scaffold(
///     body: Center(
///       child: SeedButton(
///         label: '확인',
///         onPressed: () {},
///       ),
///     ),
///   ),
/// );
/// ```
///
/// `material_ui`의 Material 위젯을 사용한다. 기존 Material 테마에 SEED 토큰을
/// 추가하려면 [SeedMaterialBridge] 또는 [SeedThemeData]를 참고한다.
///
/// ## API 구성
///
/// - **디자인 토큰과 테마:** [SeedPalette], [SeedColorScheme], [SeedTypography],
///   [SeedThemeData], [SeedTheme], [SeedThemeContextExtension].
/// - **입력과 선택:** [SeedTextInput], [SeedTextField], [SeedSelect],
///   [SeedDatePicker], [SeedCheckbox], [SeedSwitch].
/// - **탐색과 오버레이:** [SeedTabsView], [SeedPagination],
///   [SeedTopNavigation], [SeedPopoverTrigger], [SeedDialog].
/// - **레이아웃과 피드백:** [SeedGrid], [SeedScrollArea],
///   [SeedSnackbarProvider], [SeedHelpBubble].
///
/// ## 상태 소유권
///
/// React와 마찬가지로 값이 전달된 컴포넌트는 대체로 부모가 상태를 소유한다.
/// `value`/`checked`/`open`은 현재 상태를 제공하고, `onValueChange`/
/// `onCheckedChange`/`onOpenChange`는 사용자 변경을 **제안**한다.
/// `defaultValue`/`defaultChecked`/`defaultOpen`은 내부 상태를 시작할 때 한 번
/// 사용한다. 다만 정확한 prop 이름, null 의미 및 콜백 타입은 컴포넌트마다
/// 다르므로 해당 API 문서를 확인한다. Flutter의 컨트롤러, 포커스 객체와
/// deprecated 호환 별칭도 별도로 설명한다.
///
/// ## 공식 자료
///
/// - [SEED Design React v3](https://v3.seed-design.io/react)
/// - [SEED Design 공식 소스](https://github.com/daangn/seed-design)
/// - [Dart API 문서 작성 지침](https://dart.dev/effective-dart/documentation)
///
/// 이 패키지의 API 참조는 공개 라이브러리를 대상으로 `dart doc .`으로 생성한다.
library;

// Foundations - Colors
export 'src/foundations/colors/seed_palette.dart';
export 'src/foundations/colors/seed_color_scheme.dart';

// Foundations - Gradients
export 'src/foundations/gradient/seed_gradient.dart';

// Foundations - Typography
export 'src/foundations/typography/seed_typography.dart';

// Foundations - Dimensions & Spacing
export 'src/foundations/dimensions/seed_dimension.dart';

// Foundations - Breakpoints
export 'src/foundations/breakpoint/seed_breakpoint.dart';

// Foundations - Radius
export 'src/foundations/radius/seed_radius.dart';

// Foundations - Motion
export 'src/foundations/motion/seed_motion.dart';

// Foundations - Elevation
export 'src/foundations/elevation/seed_shadow.dart';

// Foundations - Feedback
export 'src/foundations/feedback/seed_scale_feedback.dart'
    hide seedLastInputWasPointer;
export 'src/foundations/feedback/seed_control.dart';

// Localization
export 'src/localization/seed_localizations.dart';

// Theme
export 'src/theme/seed_theme_data.dart';
export 'src/theme/seed_theme.dart';

// Migration & Architecture Bridge
export 'src/migration/seed_migration.dart';

// Components - Button
export 'src/components/button/seed_button.dart';
export 'src/components/button/seed_floating_action_button.dart';
export 'src/components/button/seed_reaction_button.dart';
export 'src/components/button/seed_contextual_floating_button.dart';
export 'src/components/button/seed_toggle_button.dart';
export 'src/components/button/seed_text_button.dart';

// Components - Badge
export 'src/components/badge/seed_badge.dart';
export 'src/components/badge/seed_notification_badge.dart';

// Components - Banner
export 'src/components/banner/seed_page_banner.dart';

// Components - Manner Temp
export 'src/components/manner_temp/seed_manner_temp.dart';

// Components - Chip
export 'src/components/chip/seed_chip.dart';

// Components - Callout
export 'src/components/callout/seed_callout.dart';

// Components - Disclosure
export 'src/components/disclosure/seed_accordion.dart';
export 'src/components/disclosure/seed_collapsible.dart';

// Components - Selection
export 'src/components/selection/seed_checkbox.dart';
export 'src/components/selection/seed_radio.dart';
export 'src/components/selection/seed_switch.dart';
export 'src/components/selection/seed_select_box.dart';
export 'src/components/selection/seed_select_box_group.dart';

// Components - Input
export 'src/components/input/seed_text_input.dart';
export 'src/components/input/seed_search_input.dart';
export 'src/components/input/seed_segmented_text_input.dart';
export 'src/components/input/seed_text_field.dart';
export 'src/components/input/seed_field.dart';
export 'src/components/input/seed_quantity_picker.dart';
export 'src/components/input/seed_slider.dart';
export 'src/components/input/seed_input_button.dart';
export 'src/components/input/seed_wheel_picker.dart';
export 'src/components/input/seed_time_picker.dart';
export 'src/components/input/seed_date_picker.dart';
export 'src/components/input/seed_attachment_input.dart';
export 'src/components/input/seed_attachment_field.dart';
export 'src/components/input/seed_select.dart';
export 'src/components/input/seed_select_form_field.dart';

// Components - Navigation
export 'src/components/navigation/seed_tabs.dart';
export 'src/components/navigation/seed_tab_bar.dart';
export 'src/components/navigation/seed_tabs_view.dart';
export 'src/components/navigation/seed_top_navigation.dart';
export 'src/components/navigation/seed_top_navigation_button.dart';
export 'src/components/navigation/seed_bottom_navigation.dart';
export 'src/components/navigation/seed_segmented_control.dart';
export 'src/components/navigation/seed_pagination.dart';
export 'src/components/navigation/seed_table_pagination.dart';
export 'src/components/navigation/seed_side_navigation.dart';
export 'src/components/navigation/seed_navigation_menu.dart';

// Components - Layout
export 'src/components/layout/seed_divider.dart';
export 'src/components/layout/seed_avatar.dart';
export 'src/components/avatar/seed_avatar_stack.dart';
export 'src/components/layout/seed_result_section.dart';
export 'src/components/layout/seed_scroll_fog.dart';
export 'src/components/layout/seed_scroll_area.dart';
export 'src/components/layout/seed_tag_group.dart';
export 'src/components/layout/seed_image_frame.dart';
export 'src/components/layout/seed_content_placeholder.dart';
export 'src/components/layout/seed_identity_placeholder.dart';
export 'src/components/layout/seed_footer.dart';
export 'src/components/layout/seed_consistent_width.dart';
export 'src/components/layout/seed_middle_truncate.dart';

// Components - List
export 'src/components/list/seed_list.dart';

// Components - Overlay
export 'src/components/overlay/seed_anchored_overlay.dart';
export 'src/components/overlay/seed_modal_trigger.dart';
export 'src/components/overlay/seed_dialog.dart';
export 'src/components/overlay/seed_bottom_sheet.dart';
export 'src/components/overlay/seed_menu.dart';
export 'src/components/overlay/seed_menu_sheet.dart';
export 'src/components/overlay/seed_side_panel.dart';
export 'src/components/popover/seed_popover.dart';

// Components - Feedback
export 'src/components/feedback/seed_progress_circle.dart';
export 'src/components/feedback/seed_loading_indicator.dart';
export 'src/components/feedback/seed_skeleton.dart';
export 'src/components/feedback/seed_snackbar.dart';
export 'src/components/feedback/seed_help_bubble.dart'
    hide SeedTooltipDelayGroupLink;

export 'src/components/feedback/seed_pull_to_refresh.dart';
export 'src/components/layout/seed_layout.dart';

export 'src/components/layout/seed_grid.dart';
