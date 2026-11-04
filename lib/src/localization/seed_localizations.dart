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
}

/// Optional, captured localization overrides for SEED widgets.
///
/// Common labels use the app's MaterialLocalizations. SEED-specific copy has
/// Korean and English defaults; supply [labels] for other translations. This is
/// an InheritedTheme so scoped overrides follow dialogs and bottom sheets.
class SeedLocalizations extends InheritedTheme {
  /// Installs [labels] as locale-sensitive copy overrides for [child].
  ///
  /// Missing keys fall back to MaterialLocalizations, Korean, or English text; an inherited override is
  /// captured across routes.
  const SeedLocalizations({
    super.key,
    required this.labels,
    required super.child,
  });
  /// Per-key labels overriding built-in translations. Missing keys use locale-derived fallbacks.
  final Map<SeedLabel, String> labels;

  /// Resolves [key] from the closest [SeedLocalizations] overrides, Korean defaults for ko locale,
  /// MaterialLocalizations when supported, or English fallback.
  ///
  /// Returned templates with {count}/{page}/{total}/{max} still require caller interpolation.
  static String label(BuildContext context, SeedLabel key) {
    final overrides = context
        .dependOnInheritedWidgetOfExactType<SeedLocalizations>();
    final override = overrides?.labels[key];
    if (override != null) return override;
    final material = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final korean = Localizations.maybeLocaleOf(context)?.languageCode == 'ko';
    if (korean) return _korean[key]!;
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

  /// Captures this override across a new inherited theme boundary, merging enclosing labels with local
  /// keys taking precedence.
  @override
  Widget wrap(BuildContext context, Widget child) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<SeedLocalizations>();
    return SeedLocalizations(
      labels: {...?inherited?.labels, ...labels},
      child: child,
    );
  }

  /// Invalidates dependents when the map instance [labels] changes.
  @override
  bool updateShouldNotify(SeedLocalizations oldWidget) =>
      oldWidget.labels != labels;

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
  };
}
