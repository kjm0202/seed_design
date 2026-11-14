import 'package:flutter/foundation.dart' show mapEquals;
import 'package:material_ui/material_ui.dart';

/// Built-in SEED copy that can be overridden for any application locale.
enum SeedLabel {
  /// Close action and tooltip
  close,
  /// Back navigation action
  back,
  /// Confirmation action
  confirm,
  /// Cancel action
  cancel,
  /// Clear entered text
  clearInput,
  /// Clear selected choices
  clearSelection,
  /// Required field indicator
  requiredInput,
  /// Placeholder for an unselected option
  selectPlaceholder,
  /// File picker action
  selectFiles,
  /// Drag-and-drop upload hint
  dropFiles,
  /// Cover or representative attachment indicator
  representative,
  /// File upload progress announcement
  uploadingFile,
  /// Retry a failed upload
  retryUpload,
  /// Retry a failed action
  retry,
  /// Remove an attachment
  deleteFile,
  /// Delete an image
  deleteImage,
  /// Like action
  like,
  /// Interest reaction action
  interest,
  /// Decrease a quantity
  decreaseQuantity,
  /// Increase a quantity
  increaseQuantity,
  /// Remove a quantity item
  removeItem,
  /// Expand a section
  expand,
  /// Collapse a section
  collapse,
  /// Open the side navigation
  openSideNavigation,
  /// Close the side navigation
  closeSideNavigation,
  /// Pagination navigation landmark
  pagination,
  /// Navigate to the previous page
  previousPage,
  /// Navigate to the next page
  nextPage,
  /// Pagination controls for a table
  tablePagination,
  /// Per-page row count heading
  rowsPerPage,
  /// Displayed row range in pagination
  range,
  /// Suffix following the per-page quantity
  rowsPerPageSuffix,
  /// Unread-notification count; template retains {count}
  unreadNotifications,
  /// Announcement that a new notification arrived
  newNotification,
  /// Character-limit validation; template retains {max}
  maxLengthExceeded,
  /// Page accessibility label; template retains {page}
  pageNumber,
  /// Pagination total count; template retains {total}
  paginationTotal,
  /// Optional field indicator.
  optionalInput,
  /// Delete a chip; template retains {label}.
  deleteChip,
  /// Singular unread notification; template retains {count}.
  unreadNotification,
  /// Hint on a reorderable item before a keyboard reorder starts
  reorderStartHint,
  /// Hint while a keyboard reorder is in progress; `{position}` is one-based
  reorderMovingHint,
  /// Announcement when reordering `{name}` starts
  reorderStarted,
  /// Announcement when reordering `{name}` is canceled
  reorderCanceled,
  /// Announcement when `{name}` is dropped at one-based `{position}`
  reorderDropped,
}

/// Optional, captured localization overrides for SEED widgets.
///
/// Common labels use the app's MaterialLocalizations. SEED-specific copy has
/// Korean and English defaults. Supply [labels] for other translations.
/// Scoped overrides follow dialogs and bottom sheets through theme capture.
class SeedLocalizations extends StatelessWidget {
  /// Installs [labels] as locale-sensitive copy overrides for [child].
  ///
  /// Missing keys inherit enclosing overrides before using built-in defaults.
  const SeedLocalizations({
    super.key,
    required this.labels,
    required this.child,
  });

  /// Per-key labels overriding enclosing labels or built-in translations.
  final Map<SeedLabel, String> labels;

  /// Widget subtree that receives these labels.
  final Widget child;

  static Map<SeedLabel, String>? _overridesOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SeedLocalizationScope>()
      ?.labels;

  /// Resolves [key] from scoped overrides, Korean defaults for ko locale,
  /// MaterialLocalizations when supported, or English fallback.
  ///
  /// Returned templates still require caller interpolation.
  static String label(BuildContext context, SeedLabel key) =>
      _overridesOf(context)?[key] ?? _defaultLabel(context, key);

  static String _defaultLabel(BuildContext context, SeedLabel key) {
    final korean = Localizations.maybeLocaleOf(context)?.languageCode == 'ko';
    if (korean) return _korean[key]!;
    final material = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    if (material != null) {
      final translated = switch (key) {
        SeedLabel.close => material.closeButtonTooltip,
        SeedLabel.back => material.backButtonTooltip,
        SeedLabel.confirm => material.okButtonLabel,
        SeedLabel.cancel => material.cancelButtonLabel,
        SeedLabel.clearInput => material.clearButtonTooltip,
        SeedLabel.previousPage => material.previousPageTooltip,
        SeedLabel.nextPage => material.nextPageTooltip,
        SeedLabel.rowsPerPage => material.rowsPerPageTitle,
        _ => null,
      };
      if (translated != null) return translated;
    }
    return _english[key]!;
  }

  /// Formats an unread count. A singular override takes precedence for one
  /// notification. The existing plural override can also cover that case.
  static String unreadNotifications(BuildContext context, int count) {
    final overrides = _overridesOf(context);
    final key = count == 1
        ? SeedLabel.unreadNotification
        : SeedLabel.unreadNotifications;
    final template =
        overrides?[key] ??
        overrides?[SeedLabel.unreadNotifications] ??
        _defaultLabel(context, key);
    return template.replaceAll('{count}', '$count');
  }

  @override
  Widget build(BuildContext context) => _SeedLocalizationScope(
    labels: {...?_overridesOf(context), ...labels},
    child: child,
  );

  static const _english = <SeedLabel, String>{
    SeedLabel.pageNumber: 'Page {page}',
    SeedLabel.paginationTotal: '/ {total}',
    SeedLabel.close: 'Close',
    SeedLabel.back: 'Back',
    SeedLabel.confirm: 'OK',
    SeedLabel.cancel: 'Cancel',
    SeedLabel.clearInput: 'Clear text',
    SeedLabel.clearSelection: 'Clear selection',
    SeedLabel.requiredInput: 'Required',
    SeedLabel.selectPlaceholder: 'Select an option',
    SeedLabel.selectFiles: 'Choose files',
    SeedLabel.dropFiles: 'Or drag files here to upload',
    SeedLabel.representative: 'Cover',
    SeedLabel.uploadingFile: 'Uploading attachment',
    SeedLabel.retryUpload: 'Retry',
    SeedLabel.retry: 'Retry',
    SeedLabel.deleteFile: 'Remove file',
    SeedLabel.deleteImage: 'Delete image',
    SeedLabel.like: 'Like',
    SeedLabel.interest: 'Interested',
    SeedLabel.decreaseQuantity: 'Decrease quantity',
    SeedLabel.increaseQuantity: 'Increase quantity',
    SeedLabel.removeItem: 'Remove item',
    SeedLabel.expand: 'Expand',
    SeedLabel.collapse: 'Collapse',
    SeedLabel.openSideNavigation: 'Open sidebar',
    SeedLabel.closeSideNavigation: 'Close sidebar',
    SeedLabel.pagination: 'Pagination',
    SeedLabel.previousPage: 'Previous page',
    SeedLabel.nextPage: 'Next page',
    SeedLabel.tablePagination: 'Table pagination',
    SeedLabel.rowsPerPage: 'Rows per page',
    SeedLabel.range: 'Displayed range',
    SeedLabel.rowsPerPageSuffix: 'per page',
    SeedLabel.unreadNotifications: '{count} unread notifications',
    SeedLabel.newNotification: 'New notification',
    SeedLabel.maxLengthExceeded: 'Use at most {max} characters',
    SeedLabel.optionalInput: '(optional)',
    SeedLabel.deleteChip: 'Delete {label}',
    SeedLabel.unreadNotification: '{count} unread notification',
    SeedLabel.reorderStartHint: 'Press Space to reorder',
    SeedLabel.reorderMovingHint:
        'Position {position}. Use arrow keys, Space to finish, Escape to cancel',
    SeedLabel.reorderStarted: 'Started reordering {name}.',
    SeedLabel.reorderCanceled: 'Canceled reordering {name}.',
    SeedLabel.reorderDropped: 'Moved {name} to position {position}.',
  };
  static const _korean = <SeedLabel, String>{
    SeedLabel.pageNumber: '{page}페이지',
    SeedLabel.paginationTotal: '/ 총 {total}개',
    SeedLabel.close: '닫기',
    SeedLabel.back: '뒤로',
    SeedLabel.confirm: '확인',
    SeedLabel.cancel: '취소',
    SeedLabel.clearInput: '입력 내용 지우기',
    SeedLabel.clearSelection: '선택 내용 지우기',
    SeedLabel.requiredInput: '필수 입력',
    SeedLabel.selectPlaceholder: '선택해주세요',
    SeedLabel.selectFiles: '파일 선택',
    SeedLabel.dropFiles: '또는 여기로 드래그해서 업로드',
    SeedLabel.representative: '대표',
    SeedLabel.uploadingFile: '첨부 파일 업로드 중',
    SeedLabel.retryUpload: '재시도',
    SeedLabel.retry: '재시도',
    SeedLabel.deleteFile: '파일 제거',
    SeedLabel.deleteImage: '이미지 삭제',
    SeedLabel.like: '좋아요',
    SeedLabel.interest: '관심',
    SeedLabel.decreaseQuantity: '수량 줄이기',
    SeedLabel.increaseQuantity: '수량 늘리기',
    SeedLabel.removeItem: '상품 삭제',
    SeedLabel.expand: '펼치기',
    SeedLabel.collapse: '접기',
    SeedLabel.openSideNavigation: '사이드바 열기',
    SeedLabel.closeSideNavigation: '사이드바 닫기',
    SeedLabel.pagination: '페이지 탐색',
    SeedLabel.previousPage: '이전 페이지',
    SeedLabel.nextPage: '다음 페이지',
    SeedLabel.tablePagination: '표 페이지 탐색',
    SeedLabel.rowsPerPage: '페이지당 표시 개수',
    SeedLabel.range: '표시 범위',
    SeedLabel.rowsPerPageSuffix: '씩 보기',
    SeedLabel.unreadNotifications: '읽지 않은 알림 {count}개',
    SeedLabel.newNotification: '새 알림 있음',
    SeedLabel.maxLengthExceeded: '최대 {max}자까지 입력할 수 있습니다',
    SeedLabel.optionalInput: '(선택)',
    SeedLabel.deleteChip: '{label} 삭제',
    SeedLabel.unreadNotification: '읽지 않은 알림 {count}개',
    SeedLabel.reorderStartHint: '스페이스를 눌러 순서 변경',
    SeedLabel.reorderMovingHint:
        '{position}번째 위치. 방향키로 이동, 스페이스로 완료, Escape로 취소',
    SeedLabel.reorderStarted: '{name} 항목 순서 변경을 시작했어요.',
    SeedLabel.reorderCanceled: '{name} 항목 순서 변경을 취소했어요.',
    SeedLabel.reorderDropped: '{name} 항목을 {position}번째에 놓았어요.',
  };
}

// Flutter captures only the nearest theme of a given type. Store the merged
// labels here so a route retains overrides from every enclosing scope.
class _SeedLocalizationScope extends InheritedTheme {
  const _SeedLocalizationScope({required this.labels, required super.child});

  final Map<SeedLabel, String> labels;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SeedLocalizations(labels: labels, child: child);

  @override
  bool updateShouldNotify(_SeedLocalizationScope oldWidget) =>
      !mapEquals(oldWidget.labels, labels);
}
