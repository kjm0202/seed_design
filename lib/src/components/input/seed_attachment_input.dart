import '../../localization/seed_localizations.dart';

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';
import '../button/seed_button.dart';
import '../layout/seed_safe_area_x.dart';
import 'seed_reorderable_sliver.dart';

/// Status of an individual attachment item.
enum SeedAttachmentStatus {
  /// Attachment is pending external processing.
  pending,

  /// Attachment has completed its display processing.
  completed,

  /// Success status retained for application compatibility.
  success,

  /// Attachment is currently loading.
  loading,

  /// Attachment is being uploaded by the application.
  uploading,

  /// Attachment has failed and may expose retry.
  error;

  /// True for [loading] or [uploading] status.
  bool get isLoading => this == loading || this == uploading;
}

/// Type of an individual attachment item as defined by SEED Design.
/// Use [image] for image thumbnails and [file] for generic file tiles.
enum SeedAttachmentType {
  /// Image preview tile.
  image,

  /// Generic file preview tile.
  file,
}

// The fixed-width file tile is part of the shared attachment layout contract.
// Keep the sliver's horizontal extent estimate in sync with its actual tile.
const double _attachmentFileTileWidth = 160.0;

/// A model describing an attachment item.
class SeedAttachmentItem {
  /// Creates an immutable attachment presentation record.
  /// [id] is its stable identity. [name], [sizeText], [thumbnailUrl] and
  /// [imageProvider] are external display values. [type] defaults to image
  /// and [status] to completed. [progress] is app-supplied upload progress.
  /// [isRepresentative], [readOnly], [enabled], [isDragging] and
  /// [removeEnabled] configure item badges and interaction.
  const SeedAttachmentItem({
    required this.id,
    this.name,
    this.sizeText,
    this.type = SeedAttachmentType.image,
    this.imageProvider,
    this.status = SeedAttachmentStatus.completed,
    this.isRepresentative = false,
    this.thumbnailUrl,
    this.progress,
    this.readOnly = false,
    this.enabled = true,
    this.isDragging = false,
    this.removeEnabled = true,
  });

  /// Stable identifier used by controller updates and list keys.
  final String id;

  /// Displayed attachment file name.
  final String? name;

  /// Application-formatted file size; this model does not format bytes.
  final String? sizeText;

  /// Which preview tile variant to render.
  final SeedAttachmentType type;

  /// Flutter preview image; preferred over [thumbnailUrl].
  final ImageProvider? imageProvider;

  /// Current app-reported item status (default completed).
  final SeedAttachmentStatus status;

  /// Whether this thumbnail carries the representative badge.
  final bool isRepresentative;

  /// Remote preview URL used when [imageProvider] is absent.
  final String? thumbnailUrl;

  /// Optional application-supplied upload progress.
  final double? progress;

  /// Item flags for read-only, enabled, dragging and removal permission.
  /// Defaults: false, true, false and true, respectively.
  final bool readOnly, enabled, isDragging, removeEnabled;

  /// Returns [imageProvider], a [NetworkImage] for [thumbnailUrl], or null.
  ImageProvider? get effectiveImageProvider =>
      imageProvider ??
      (thumbnailUrl == null ? null : NetworkImage(thumbnailUrl!));

  /// Copies display values and status while preserving the original ID/type.
  /// Null arguments keep existing values; [clearProgress] explicitly clears
  /// [progress] instead of retaining its previous value.
  SeedAttachmentItem copyWith({
    String? name,
    String? sizeText,
    ImageProvider? imageProvider,
    String? thumbnailUrl,
    SeedAttachmentStatus? status,
    double? progress,
    bool clearProgress = false,
    bool? readOnly,
    bool? enabled,
    bool? isDragging,
    bool? removeEnabled,
    bool? isRepresentative,
  }) => SeedAttachmentItem(
    id: id,
    name: name ?? this.name,
    sizeText: sizeText ?? this.sizeText,
    type: type,
    imageProvider: imageProvider ?? this.imageProvider,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    status: status ?? this.status,
    progress: clearProgress ? null : progress ?? this.progress,
    readOnly: readOnly ?? this.readOnly,
    enabled: enabled ?? this.enabled,
    isDragging: isDragging ?? this.isDragging,
    removeEnabled: removeEnabled ?? this.removeEnabled,
    isRepresentative: isRepresentative ?? this.isRepresentative,
  );
}

/// A 120px dropzone component for file/attachment upload adhering to SEED Design.
class SeedAttachmentDropzone extends StatelessWidget {
  /// Select-files button callback; the dropzone surface itself is not clickable.
  final VoidCallback? onTap;
  final String? _label;

  /// Custom hint or legacy Korean fallback label.
  String get label => _label ?? '또는 여기로 드래그해서 업로드';

  /// Icon for the internal select-files button.
  final Widget? icon;

  /// Externally supplied drag-over state for border styling.
  final bool isDraggingOver;

  /// Whether the select-files button is enabled (default true).
  final bool enabled;

  /// Shows a dropzone area with a select-files button.
  /// [onTap] requests a picker from the application; this widget handles
  /// neither native drop events nor uploading. [label] overrides localized
  /// helper text, [icon] replaces the button icon, [isDraggingOver] controls
  /// highlight styling and [enabled] defaults to true.
  const SeedAttachmentDropzone({
    super.key,
    this.onTap,
    String? label,
    this.icon,
    this.isDraggingOver = false,
    this.enabled = true,
    // Preserve the public named parameter and getter.
    // ignore: prefer_initializing_formals
  }) : _label = label;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = isDraggingOver
        ? colors.stroke.neutralSolid
        : (colors.isDark ? SeedPalette.gray500Dark : SeedPalette.gray500Light);

    // Official AttachmentInput.DropzoneLabel is a plain div that never
    // receives data-disabled, so only the select-files button reflects
    // [enabled]; the helper keeps fg.neutralSubtle.
    final Color labelColor = colors.fg.neutralSubtle;

    // The official Dropzone is a plain drop target; only its ActionButton
    // opens the chooser, so the area itself is neither a tab stop nor a button.
    // The official dropzone is a block-level flex item of the attachment
    // root column, so it spans the available width rather than its content.
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        foregroundPainter: _SeedDropzoneBorder(strokeColor, isDraggingOver),
        child: Container(
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          // The React recipe is 120px at its default text scale. Keep that
          // minimum without clipping the button + helper label when Flutter
          // accessibility text scaling makes them taller.
          constraints: const BoxConstraints(minHeight: 120.0),
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
          decoration: BoxDecoration(
            color: colors.bg.transparent,
            borderRadius: SeedBorderRadius.r3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SeedButton(
                label: SeedLocalizations.label(context, SeedLabel.selectFiles),
                variant: SeedButtonVariant.neutralWeak,
                size: SeedButtonSize.small,
                prefixIcon: icon ?? const Icon(Icons.file_upload_outlined),
                onPressed: enabled ? onTap : null,
              ),
              const SizedBox(height: SeedDimension.x2),
              Text(
                _label ?? SeedLocalizations.label(context, SeedLabel.dropFiles),
                style: typography.t4Medium.copyWith(color: labelColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeedDropzoneBorder extends CustomPainter {
  const _SeedDropzoneBorder(this.color, this.solid);
  final Color color;
  final bool solid;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        SeedBorderRadius.r3.toRRect((Offset.zero & size).deflate(0.5)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (solid) {
      canvas.drawPath(outline, paint);
    } else {
      for (final metric in outline.computeMetrics()) {
        for (double offset = 0; offset < metric.length; offset += 8) {
          canvas.drawPath(
            metric.extractPath(offset, math.min(offset + 4, metric.length)),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SeedDropzoneBorder oldDelegate) =>
      oldDelegate.color != color || oldDelegate.solid != solid;
}

/// A SEED Design Attachment Input component for media (photos/videos) or files.
///
/// Displays a trigger box with count and an optional horizontal row of preview items.
class SeedAttachmentInput extends StatelessWidget {
  /// Displays supplied [items] as a horizontal attachment preview list.
  /// [maxCount] defaults to 1; [enabled] and [readOnly] control the add trigger
  /// and item actions. [onAdd], [onRemove] and [onRetry] notify the caller without
  /// mutating its item list. [onReorder] enables item dragging with Flutter index
  /// semantics. [itemSize] defaults to 80 logical pixels. [triggerIcon] overrides
  /// the default camera glyph; [showTrigger] hides the add tile for dropzones.
  /// [representativeLabel] defaults to '대표'. [scrollPadding] is Flutter-only
  /// internal scrollport padding and defaults to [EdgeInsets.zero].
  /// [extendSafeAreaX] bleeds the list under the horizontal safe-area insets.
  const SeedAttachmentInput({
    super.key,
    required this.items,
    this.maxCount = 1,
    this.onAdd,
    this.onRemove,
    this.onRetry,
    this.itemSize = 80.0,
    String? representativeLabel,
    this.triggerIcon,
    this.showTrigger = true,
    this.readOnly = false,
    this.onReorder,
    this.scrollPadding = EdgeInsets.zero,
    this.enabled = true,
    this.extendSafeAreaX = false,
    // Preserve the public named parameter and getter.
    // ignore: prefer_initializing_formals
  }) : _representativeLabel = representativeLabel;

  /// The list of currently attached items.
  final List<SeedAttachmentItem> items;

  /// Maximum allowed number of attachments.
  final int maxCount;

  /// Callback when user taps the trigger box to add a new attachment.
  final VoidCallback? onAdd;

  /// Callback when user removes an attachment.
  final ValueChanged<SeedAttachmentItem>? onRemove;

  /// Callback when user taps retry on a failed item.
  final ValueChanged<SeedAttachmentItem>? onRetry;

  /// Size (width and height) of thumbnail squares.
  final double itemSize;

  /// Label for representative thumbnail (e.g. '대표').
  final String? _representativeLabel;

  /// Representative image badge text (default '대표').
  String get representativeLabel => _representativeLabel ?? '대표';

  /// Flutter composition option for React's separate image/general TriggerIcon.
  /// Omitted values keep the existing camera trigger.
  final Widget? triggerIcon;

  /// Whether to include the tile trigger beside previews (false for dropzones).
  final bool showTrigger;

  /// Whether the attachment list blocks add, remove and retry actions.
  final bool readOnly;

  /// Reorder handler; null disables dragging.
  /// The destination index follows ReorderableListView's before-removal convention.
  final ReorderCallback? onReorder;

  /// Inset applied *inside* the attachment scrollport (both reorderable and
  /// ordinary). The default remains zero for existing consumers.
  ///
  /// React's --seed-attachment-input-extend-x enlarges the viewport while
  /// the scrollable container retains padding-inline. Use this when a parent
  /// has extended the input's width, rather than padding the list's parent,
  /// which would shorten the drag/scroll viewport.
  final EdgeInsets scrollPadding;

  /// Whether the attachment input is enabled.
  final bool enabled;

  /// Extends the attachment list edge to edge under the horizontal safe-area
  /// insets, like React `AttachmentInput` `extendSafeAreaX` (React 3.1.0+).
  /// Defaults to false, which keeps the existing layout.
  ///
  /// Place the input inside the safe area as usual. When true, the input
  /// widens by the device's physical left and right insets, so the list
  /// scrolls and drags across the full width, and the scrollport padding
  /// grows by the same insets on top of [scrollPadding], so the trigger and
  /// first preview start inside the safe area. A focused item, including one
  /// moved with the keyboard, stops at the inset boundary rather than under
  /// it (React's `scroll-padding`, without an extra item margin). The insets
  /// are the largest of the view padding and the ambient [MediaQuery]
  /// padding and view padding, also when an ancestor [SafeArea] has consumed
  /// them.
  ///
  /// Pointer input that starts in the inset strips reaches the list only
  /// when the ancestors also cover those strips; Flutter hit testing stops at
  /// each ancestor's bounds.
  final bool extendSafeAreaX;

  @override
  Widget build(BuildContext context) {
    final insets = SeedSafeAreaX.resolve(context, extendSafeAreaX);
    // The bleed and the focus reveals stay at zero insets when the flag is
    // false, so toggling it keeps the list's scroll offset, keyboard focus
    // and a provisional keyboard reorder.
    return SeedSafeAreaXBleed(
      insets: insets,
      child: _RemoveButtonHitScope(child: _buildList(context, insets)),
    );
  }

  Widget _buildList(BuildContext context, SeedSafeAreaX insets) {
    // React adds the safe-area insets to the container's padding-inline.
    final listPadding = extendSafeAreaX
        ? scrollPadding + insets.padding
        : scrollPadding;
    Widget revealing(Widget child) =>
        SeedSafeAreaXFocusReveal(insets: insets, child: child);
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final canAdd = enabled && !readOnly && items.length < maxCount;
    final countPainter = TextPainter(
      text: TextSpan(
        text: '${items.length}/$maxCount',
        style: DefaultTextStyle.of(context).style.merge(typography.t2Regular),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: 1,
    )..layout();
    final triggerWidth = math.max(itemSize, countPainter.width + 16);
    final triggerHeight = math.max(itemSize, 24 + 4 + countPainter.height + 16);
    countPainter.dispose();

    final trigger = SeedPressable(
      enabled: canAdd,
      // Official Trigger aria-label; the count is visual only.
      semanticsLabel: SeedLocalizations.label(context, SeedLabel.selectFiles),
      onTap: canAdd ? onAdd : null,
      builder: (context, isPressed) {
        return Container(
          width: triggerWidth,
          height: triggerHeight,
          decoration: BoxDecoration(
            color: isPressed
                ? colors.bg.transparentPressed
                : colors.bg.transparent,
            borderRadius: SeedBorderRadius.r3,
            border: Border.all(
              color: canAdd
                  ? colors.stroke.neutralWeak
                  : colors.stroke.neutralMuted,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  size: 24,
                  color: canAdd ? colors.fg.neutralSubtle : colors.fg.disabled,
                ),
                child: triggerIcon ?? const Icon(Icons.camera_alt_outlined),
              ),
              const SizedBox(height: 4),
              Text.rich(
                maxLines: 1,
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${items.length}',
                      style: typography.t2Regular.copyWith(
                        color: canAdd ? colors.fg.neutral : colors.fg.disabled,
                      ),
                    ),
                    TextSpan(
                      text: '/$maxCount',
                      style: typography.t2Regular.copyWith(
                        color: canAdd
                            ? colors.fg.neutralSubtle
                            : colors.fg.disabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    Widget preview(SeedAttachmentItem item) => Opacity(
      opacity: readOnly || item.readOnly || item.isDragging || !item.enabled
          ? 0.5
          : 1,
      child: item.type == SeedAttachmentType.file
          ? _buildFileItem(context, item, colors, typography)
          : _buildImageItem(context, item, colors, typography),
    );
    if (!showTrigger && items.isEmpty) return const SizedBox.shrink();
    // Flutter attaches reorder semantics to every child of its reorderable
    // list, even when a particular child cannot start a drag. If no child can
    // move, use the ordinary list so it does not advertise unusable actions.
    final hasMovableItems =
        items.isEmpty || items.any((item) => item.enabled && !item.readOnly);
    if (onReorder != null && enabled && !readOnly && hasMovableItems) {
      return SizedBox(
        height: math.max(
          showTrigger ? triggerHeight : 0,
          items.any((item) => item.type == SeedAttachmentType.file)
              ? _fileHeight(context, typography)
              : itemSize,
        ),
        child: _AttachmentReorderList(
          items: items,
          padding: listPadding,
          revealInsets: insets,
          header: showTrigger ? trigger : null,
          headerWidth: showTrigger ? triggerWidth : 0,
          itemSize: itemSize,
          canReorder: (item) =>
              enabled && !readOnly && item.enabled && !item.readOnly,
          onReorder: onReorder!,
          itemBuilder: (context, item, index) => Padding(
            // CSS itemGroup gap is between siblings only. With no trigger
            // (dropzone), the first preview starts at the scrollPadding.
            padding: EdgeInsetsDirectional.only(
              start: showTrigger || index > 0 ? 8 : 0,
            ),
            child: preview(item),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: listPadding,
      // The remove button overhangs the item's corner.
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTrigger) revealing(trigger),
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: showTrigger || index > 0 ? 8 : 0,
              ),
              child: revealing(preview(items[index])),
            ),
        ],
      ),
    );
  }

  Widget _buildFileItem(
    BuildContext context,
    SeedAttachmentItem item,
    SeedColorScheme colors,
    SeedTypography typography,
  ) {
    return SizedBox(
      width: _attachmentFileTileWidth,
      height: _fileHeight(context, typography),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bg.transparent,
          borderRadius: SeedBorderRadius.r3,
          border: Border.all(color: colors.stroke.neutralWeak, width: 1),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            if (item.status.isLoading)
              Center(
                child: Semantics(
                  label: SeedLocalizations.label(
                    context,
                    SeedLabel.uploadingFile,
                  ),
                  child: SeedProgressCircle(size: 24, value: item.progress),
                ),
              )
            else if (item.status == SeedAttachmentStatus.error)
              _buildRetryAction(context, item, colors, typography)
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SeedDimension.x4,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: SeedDimension.x12,
                      height: SeedDimension.x12,
                      decoration: BoxDecoration(
                        color: colors.bg.neutralWeak,
                        borderRadius: SeedBorderRadius.r2,
                      ),
                      child: Icon(
                        Icons.insert_drive_file_outlined,
                        size: SeedDimension.x6,
                        color: colors.fg.neutralSubtle,
                      ),
                    ),
                    const SizedBox(width: SeedDimension.x2_5),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.name != null)
                            _SeedAttachmentFileName(
                              name: item.name!,
                              style: typography.t2Medium.copyWith(
                                color: colors.fg.neutral,
                              ),
                            ),
                          if (item.sizeText != null)
                            Text(
                              item.sizeText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.t1Regular.copyWith(
                                color: colors.fg.neutralSubtle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (!readOnly &&
                item.enabled &&
                !item.readOnly &&
                item.removeEnabled &&
                !item.isDragging &&
                onRemove != null)
              Positioned(
                top: -SeedDimension.x1,
                right: -SeedDimension.x1,
                child: _buildRemoveButton(context, item, colors),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryAction(
    BuildContext context,
    SeedAttachmentItem item,
    SeedColorScheme colors,
    SeedTypography typography, {
    bool image = false,
  }) {
    final canRetry =
        enabled &&
        !readOnly &&
        item.enabled &&
        !item.readOnly &&
        onRetry != null;
    final color = image ? const Color(0xFFFFFFFF) : colors.fg.neutralSubtle;
    return Tooltip(
      message: SeedLocalizations.label(context, SeedLabel.retryUpload),
      child: SeedPressable(
        enabled: canRetry,
        semanticsLabel: SeedLocalizations.label(context, SeedLabel.retryUpload),
        onTap: canRetry ? () => onRetry!(item) : null,
        focusBorderRadius: SeedBorderRadius.r3,
        builder: (context, isPressed) => ColoredBox(
          color: isPressed
              ? colors.bg.transparentPressed
              : colors.bg.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 24, color: color),
                const SizedBox(height: SeedDimension.x1),
                Text(
                  SeedLocalizations.label(context, SeedLabel.retry),
                  style: typography.t2Medium.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(
    BuildContext context,
    SeedAttachmentItem item,
    SeedColorScheme colors,
    SeedTypography typography,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Thumbnail square container
        ClipPath(
          clipper: _showsRemove(item) ? const _RemoveButtonNotch() : null,
          child: Container(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              color: colors.bg.neutralWeak,
              borderRadius: SeedBorderRadius.r3,
              border: Border.all(
                color: colors.stroke.neutralSubtle,
                width: 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.effectiveImageProvider != null
                ? Image(
                    image: item.effectiveImageProvider!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: colors.fg.neutralSubtle,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                      color: colors.fg.neutralSubtle,
                      size: 24,
                    ),
                  ),
          ),
        ),

        // Representative badge at bottom
        if (item.isRepresentative)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: SeedDimension.x6,
              padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.bg.overlay,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(SeedRadius.r3),
                  bottomRight: Radius.circular(SeedRadius.r3),
                ),
              ),
              child: Text(
                _representativeLabel ??
                    SeedLocalizations.label(context, SeedLabel.representative),
                textAlign: TextAlign.center,
                style: typography.t2Medium.copyWith(
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),

        // Loading overlay
        if (item.status.isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.bg.overlay,
                borderRadius: SeedBorderRadius.r3,
              ),
              child: Center(
                child: SeedProgressCircle(
                  size: 24,
                  value: item.progress,
                  tone: SeedProgressCircleTone.staticWhite,
                ),
              ),
            ),
          ),

        // Error overlay with retry
        if (item.status == SeedAttachmentStatus.error)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.bg.overlay,
                borderRadius: SeedBorderRadius.r3,
              ),
              child: _buildRetryAction(
                context,
                item,
                colors,
                typography,
                image: true,
              ),
            ),
          ),

        // Delete button in top right
        if (!readOnly &&
            item.enabled &&
            !item.readOnly &&
            item.removeEnabled &&
            !item.isDragging &&
            onRemove != null)
          Positioned(
            top: -SeedDimension.x1,
            right: -SeedDimension.x1,
            child: _buildRemoveButton(context, item, colors),
          ),
      ],
    );
  }

  double _fileHeight(BuildContext context, SeedTypography typography) {
    double height(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: DefaultTextStyle.of(context).style.merge(style),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.maybeLocaleOf(context),
      )..layout();
      final result = painter.height;
      painter.dispose();
      return result;
    }

    return math.max(
      80,
      height('Ag\nAg', typography.t2Medium) +
          height('Ag', typography.t1Regular) +
          16,
    );
  }

  bool _showsRemove(SeedAttachmentItem item) =>
      !readOnly &&
      item.enabled &&
      !item.readOnly &&
      item.removeEnabled &&
      !item.isDragging &&
      onRemove != null;

  Widget _buildRemoveButton(
    BuildContext context,
    SeedAttachmentItem item,
    SeedColorScheme colors,
  ) {
    return _RemoveButtonHitTarget(
      child: SeedPressable(
        semanticsLabel: SeedLocalizations.label(context, SeedLabel.deleteFile),
        enableScale: true,
        onTap: () => onRemove?.call(item),
        builder: (context, isPressed) {
          return Container(
            width: SeedDimension.x5,
            height: SeedDimension.x5,
            decoration: BoxDecoration(
              color: isPressed
                  ? colors.bg.layerDefaultPressed
                  : colors.bg.layerDefault,
              shape: BoxShape.circle,
              border: Border.all(color: colors.stroke.neutralWeak, width: 1.0),
            ),
            child: Center(
              child: Icon(
                Icons.close_rounded,
                size: SeedDimension.x2_5,
                color: colors.fg.neutral,
              ),
            ),
          );
        },
      ),
    );
  }
}

// The reorderable strip. It mirrors Material's ReorderableListView layout
// (header sliver followed by the reorderable sliver, same padding split) on
// top of the package's copy of the Flutter reorderable sliver, which can
// leave the move accessibility actions off items that cannot be reordered.
//
// A keyboard reorder is provisional: the moving item is shown at its target
// position, as in the upstream sortable example, and the consumer's callback
// runs once when Space commits it. Escape or losing focus restores the order.
class _AttachmentReorderList extends StatefulWidget {
  const _AttachmentReorderList({
    required this.items,
    required this.padding,
    required this.revealInsets,
    required this.header,
    required this.headerWidth,
    required this.itemSize,
    required this.canReorder,
    required this.onReorder,
    required this.itemBuilder,
  });

  final List<SeedAttachmentItem> items;
  final EdgeInsets padding;
  // extendSafeAreaX: keeps revealed items inside these insets. Zero when the
  // flag is false; the reveal wrappers stay so the item trees do not change.
  final SeedSafeAreaX revealInsets;
  final Widget? header;
  final double headerWidth;
  final double itemSize;
  final bool Function(SeedAttachmentItem item) canReorder;
  final ReorderCallback onReorder;
  final Widget Function(
    BuildContext context,
    SeedAttachmentItem item,
    int displayIndex,
  )
  itemBuilder;

  @override
  State<_AttachmentReorderList> createState() => _AttachmentReorderListState();
}

class _AttachmentReorderListState extends State<_AttachmentReorderList> {
  // Keyboard move in progress: the item's index in widget.items and the
  // position it is provisionally shown at.
  int? _from;
  int? _target;
  String? _movingId;

  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasHeader => widget.header != null;

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  // The header sliver takes the start padding and the list sliver the end
  // padding. SliverPadding resolves physical insets along the axis
  // direction, so in RTL the start padding is the right one.
  EdgeInsets get _listPadding => !_hasHeader
      ? widget.padding
      : _rtl
      ? widget.padding.copyWith(right: 0)
      : widget.padding.copyWith(left: 0);

  EdgeInsets get _headerPadding => _rtl
      ? widget.padding.copyWith(left: 0)
      : widget.padding.copyWith(right: 0);

  // Reveal the new position in the same layout as the provisional order.
  // Animating to a far position can leave the moved item outside the sliver's
  // cache for a frame, unmounting its keyboard focus before it can be dropped.
  void _reveal(int display) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    var leading = _rtl ? widget.padding.right : widget.padding.left;
    if (_hasHeader) leading += widget.headerWidth;
    for (var i = 0; i < display; i++) {
      leading += _extent(i);
    }
    final trailing = leading + _extent(display);
    // React's container scroll-padding equals the safe-area insets under
    // extendSafeAreaX, so the item stops at the inset boundary.
    final insets = widget.revealInsets;
    final direction = Directionality.of(context);
    final before = insets.start(direction), after = insets.end(direction);
    var target = position.pixels;
    if (leading - before < position.pixels) {
      target = leading - before;
    } else if (trailing + after >
        position.pixels + position.viewportDimension) {
      target = trailing + after - position.viewportDimension;
    }
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < 0.5) return;
    position.jumpTo(target);
  }

  @override
  void didUpdateWidget(_AttachmentReorderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final from = _from;
    // The consumer changed the list under a provisional move.
    if (from != null &&
        (from >= widget.items.length ||
            _target! >= widget.items.length ||
            widget.items[from].id != _movingId ||
            !widget.canReorder(widget.items[from]))) {
      _from = _target = _movingId = null;
    }
  }

  // Index in widget.items of the item shown at a display position.
  int _actual(int display) {
    final from = _from, target = _target;
    if (from == null || target == null || from == target) return display;
    if (display == target) return from;
    if (from < target) {
      return display >= from && display < target ? display + 1 : display;
    }
    return display > target && display <= from ? display - 1 : display;
  }

  // File and image tiles have known horizontal extents even when filenames
  // wrap or text scaling changes their height. Providing the actual extent
  // prevents the lazily-built sliver from underestimating maxScrollExtent
  // after dynamic add/remove and during edge auto-scrolling.
  double _extent(int display) =>
      (widget.items[_actual(display)].type == SeedAttachmentType.file
          ? _attachmentFileTileWidth
          : widget.itemSize) +
      (_hasHeader || display > 0 ? 8.0 : 0.0);

  void _announce(SeedLabel key, SeedAttachmentItem item, int index) {
    final message = SeedLocalizations.label(context, key)
        .replaceAll('{name}', item.name ?? '${index + 1}')
        .replaceAll('{position}', '${index + 1}');
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  void _start(int index) {
    final item = widget.items[index];
    setState(() {
      _from = _target = index;
      _movingId = item.id;
    });
    _announce(SeedLabel.reorderStarted, item, index);
  }

  void _move(int delta) {
    final target = _target;
    if (target == null) return;
    final next = (target + delta).clamp(0, widget.items.length - 1);
    if (next == target) return;
    setState(() => _target = next);
    _reveal(next);
  }

  void _cancel({bool announce = true}) {
    final from = _from;
    if (from == null) return;
    setState(() => _from = _target = _movingId = null);
    _reveal(from);
    if (announce) _announce(SeedLabel.reorderCanceled, widget.items[from], from);
  }

  void _commit() {
    final from = _from, target = _target;
    if (from == null || target == null) return;
    setState(() => _from = _target = _movingId = null);
    // As in the official sortable example, finishing announces the resulting
    // position even when it equals the starting one.
    _announce(SeedLabel.reorderDropped, widget.items[from], target);
    if (target != from) {
      widget.onReorder(from, target > from ? target + 1 : target);
    }
  }

  // Same decoration as Material's ReorderableListView default.
  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Material(
        elevation: Curves.easeInOut.transform(animation.value) * 6,
        child: child,
      ),
      child: child,
    );
  }

  Widget _buildItem(BuildContext context, int display) {
    final actual = _actual(display);
    final item = widget.items[actual];
    // The value key by item id is how consumers and tests locate an entry.
    final child = KeyedSubtree(
      key: ValueKey(item.id),
      child: widget.itemBuilder(context, item, display),
    );
    Widget revealing(Widget child) => SeedSafeAreaXFocusReveal(
      insets: widget.revealInsets,
      // The item box also holds the gap before it.
      startGap: _hasHeader || display > 0 ? 8.0 : 0.0,
      child: child,
    );
    return KeyedSubtree(
      // A global key keeps the item's state, including keyboard focus, when
      // a reorder moves it to another index.
      key: _AttachmentItemGlobalKey(ValueKey(item.id), this),
      child: revealing(
        widget.canReorder(item)
            ? SeedReorderableDelayedDragStartListener(
                index: display,
                child: _AttachmentKeyboardReorder(
                  position: display,
                  count: widget.items.length,
                  moving: _from == actual,
                  // Keys can arrive before the next build, so the handler
                  // reads the live state instead of the built flag.
                  isMoving: () => _movingId == item.id,
                  onStart: () => _start(actual),
                  onMove: _move,
                  onCommit: _commit,
                  onCancel: _cancel,
                  child: child,
                ),
              )
            : child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      clipBehavior: Clip.none,
      slivers: [
        if (_hasHeader)
          SliverPadding(
            padding: _headerPadding,
            sliver: SliverToBoxAdapter(child: widget.header),
          ),
        SliverPadding(
          padding: _listPadding,
          sliver: SeedSliverReorderableList(
            itemCount: widget.items.length,
            itemExtentBuilder: (index, _) => _extent(index),
            itemBuilder: _buildItem,
            canReorderItem: (index) =>
                widget.canReorder(widget.items[_actual(index)]),
            proxyDecorator: _proxyDecorator,
            // A pointer drag or an accessibility move action replaces any
            // provisional keyboard move.
            onReorderStart: (_) => _cancel(announce: false),
            onReorderItem: (from, to) {
              _cancel(announce: false);
              if (widget.canReorder(widget.items[from])) {
                widget.onReorder(from, to > from ? to + 1 : to);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _AttachmentItemGlobalKey extends GlobalObjectKey {
  const _AttachmentItemGlobalKey(this.subKey, this.state) : super(subKey);

  final Key subKey;
  final State state;

  @override
  bool operator ==(Object other) =>
      other is _AttachmentItemGlobalKey &&
      other.subKey == subKey &&
      other.state == state;

  @override
  int get hashCode => Object.hash(subKey, state);
}

// The keyboard reorder handle of one movable item: Space picks the item up
// and drops it, the arrow keys move it and Escape cancels.
class _AttachmentKeyboardReorder extends StatefulWidget {
  const _AttachmentKeyboardReorder({
    required this.position,
    required this.count,
    required this.moving,
    required this.isMoving,
    required this.onStart,
    required this.onMove,
    required this.onCommit,
    required this.onCancel,
    required this.child,
  });

  final int position;
  final int count;
  final bool moving;
  final bool Function() isMoving;
  final VoidCallback onStart;
  final ValueChanged<int> onMove;
  final VoidCallback onCommit;
  final VoidCallback onCancel;
  final Widget child;

  @override
  State<_AttachmentKeyboardReorder> createState() =>
      _AttachmentKeyboardReorderState();
}

class _AttachmentKeyboardReorderState
    extends State<_AttachmentKeyboardReorder> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!node.hasPrimaryFocus ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.space && event is KeyDownEvent) {
      widget.isMoving() ? widget.onCommit() : widget.onStart();
      return KeyEventResult.handled;
    }
    if (!widget.isMoving()) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onCancel();
      return KeyEventResult.handled;
    }
    final isRight = event.logicalKey == LogicalKeyboardKey.arrowRight;
    final isLeft = event.logicalKey == LogicalKeyboardKey.arrowLeft;
    if (!isRight && !isLeft) return KeyEventResult.ignored;
    final forward =
        isRight == (Directionality.of(context) == TextDirection.ltr);
    widget.onMove(forward ? 1 : -1);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.moving
        ? SeedLocalizations.label(
            context,
            SeedLabel.reorderMovingHint,
          ).replaceAll('{position}', '${widget.position + 1}')
        : SeedLocalizations.label(context, SeedLabel.reorderStartHint);
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      onFocusChange: (focused) {
        if (!focused && widget.isMoving()) widget.onCancel();
        setState(() {});
      },
      child: Semantics(
        hint: hint,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: _focusNode.hasPrimaryFocus
                ? Border.all(
                    color: context.seedColor.stroke.focusRing,
                    width: 2,
                  )
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              widget.child,
              if (widget.moving)
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  child: ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.seedColor.bg.neutralSolid,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${widget.position + 1} / ${widget.count}',
                          style: TextStyle(
                            color: context.seedColor.fg.onNeutralSolid,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets a remove button's overhang receive pointers. React positions the
/// button 4px past the item's top-right corner, and the browser hit tests that
/// overhang because the item does not clip it. Flutter stops at the item's
/// bounds, so this list-level scope routes those points to the button.
class _RemoveButtonHitScope extends SingleChildRenderObjectWidget {
  const _RemoveButtonHitScope({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderRemoveButtonHitScope();
}

class _RenderRemoveButtonHitScope extends RenderProxyBox {
  final Set<_RenderRemoveButtonHitTarget> _targets = {};

  Offset? _toLocal(RenderBox box, Offset position) {
    final inverse = Matrix4.tryInvert(box.getTransformTo(this));
    return inverse == null
        ? null
        : MatrixUtils.transformPoint(inverse, position);
  }

  // Whether the ordinary hit test reaches [target] through every ancestor box.
  bool _reachable(_RenderRemoveButtonHitTarget target, Offset position) {
    for (
      var node = target.parent;
      node != null && node != this;
      node = node.parent
    ) {
      if (node is! RenderBox || !node.hasSize) continue;
      final local = _toLocal(node, position);
      if (local == null || !node.size.contains(local)) return false;
    }
    return true;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final overhang = Rect.fromLTRB(
      0,
      -SeedDimension.x1,
      size.width + SeedDimension.x1,
      size.height,
    );
    if (overhang.contains(position)) {
      for (final target in _targets) {
        if (!target.hasSize) continue;
        final local = _toLocal(target, position);
        if (local == null ||
            !target.size.contains(local) ||
            _reachable(target, position)) {
          continue;
        }
        final hit = result.addWithPaintTransform(
          transform: target.getTransformTo(this),
          position: position,
          hitTest: (result, local) => target.hitTest(result, position: local),
        );
        if (hit) {
          result.add(BoxHitTestEntry(this, position));
          return true;
        }
      }
    }
    return super.hitTest(result, position: position);
  }
}

class _RemoveButtonHitTarget extends SingleChildRenderObjectWidget {
  const _RemoveButtonHitTarget({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderRemoveButtonHitTarget();
}

class _RenderRemoveButtonHitTarget extends RenderProxyBox {
  _RenderRemoveButtonHitScope? _scope;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    var node = parent;
    while (node != null && node is! _RenderRemoveButtonHitScope) {
      node = node.parent;
    }
    _scope = node as _RenderRemoveButtonHitScope?;
    _scope?._targets.add(this);
  }

  @override
  void detach() {
    _scope?._targets.remove(this);
    _scope = null;
    super.detach();
  }
}

/// The official removeButtonMask: a 24px hole, 6px past the top-right corner,
/// so the gap around the button shows whatever lies behind the item.
class _RemoveButtonNotch extends CustomClipper<Path> {
  const _RemoveButtonNotch();

  @override
  Path getClip(Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect(Offset.zero & size),
    Path()..addOval(
      Rect.fromCircle(center: Offset(size.width + 6 - 12, -6 + 12), radius: 12),
    ),
  );

  @override
  bool shouldReclip(_RemoveButtonNotch oldClipper) => false;
}

/// Fits two lines while keeping the extension visible and the full spoken name.
class _SeedAttachmentFileName extends StatelessWidget {
  const _SeedAttachmentFileName({required this.name, required this.style});
  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final painter = TextPainter(
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.maybeLocaleOf(context),
        maxLines: 2,
      );
      final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);
      bool fits(String text) {
        painter.text = TextSpan(text: text, style: effectiveStyle);
        painter.layout(maxWidth: constraints.maxWidth);
        return !painter.didExceedMaxLines;
      }

      var display = name;
      if (!fits(name)) {
        final graphemes = name.characters.toList();
        final dot = graphemes.lastIndexOf('.');
        final extensionLength = dot > 0 ? graphemes.length - dot : 0;
        String shortened(int count) {
          final suffix = math.min(extensionLength, count);
          return '${graphemes.take(count - suffix).join()}…${graphemes.skip(graphemes.length - suffix).join()}';
        }

        var low = 0;
        var high = graphemes.length - 1;
        while (low < high) {
          final mid = (low + high + 1) ~/ 2;
          if (fits(shortened(mid))) {
            low = mid;
          } else {
            high = mid - 1;
          }
        }
        display = shortened(low);
      }
      painter.dispose();
      return Text(
        display,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        semanticsLabel: name,
      );
    },
  );
}
