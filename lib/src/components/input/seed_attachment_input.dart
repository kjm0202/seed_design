import 'dart:math' as math;

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

/// Status of an individual attachment item.
enum SeedAttachmentStatus {
  pending,
  completed,
  success,
  loading,
  uploading,
  error;

  bool get isLoading => this == loading || this == uploading;
}

/// Type of an individual attachment item as defined by SEED Design.
enum SeedAttachmentType { image, file }

/// A model describing an attachment item.
class SeedAttachmentItem {
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

  final String id;
  final String? name;
  final String? sizeText;
  final SeedAttachmentType type;
  final ImageProvider? imageProvider;
  final SeedAttachmentStatus status;
  final bool isRepresentative;
  final String? thumbnailUrl;
  final double? progress;
  final bool readOnly, enabled, isDragging, removeEnabled;
  ImageProvider? get effectiveImageProvider =>
      imageProvider ??
      (thumbnailUrl == null ? null : NetworkImage(thumbnailUrl!));
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
  final VoidCallback? onTap;
  final String label;
  final Widget? icon;
  final bool isDraggingOver;
  final bool enabled;

  const SeedAttachmentDropzone({
    super.key,
    this.onTap,
    this.label = '또는 여기로 드래그해서 업로드',
    this.icon,
    this.isDraggingOver = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = isDraggingOver
        ? colors.stroke.neutralSolid
        : (colors.isDark ? SeedPalette.gray500Dark : SeedPalette.gray500Light);

    final Color labelColor = !enabled
        ? colors.fg.disabled
        : colors.fg.neutralSubtle;

    return SeedPressable(
      enabled: enabled && onTap != null,
      onTap: onTap,
      focusBorderRadius: SeedBorderRadius.r3,
      builder: (context, isPressed) => CustomPaint(
        foregroundPainter: _SeedDropzoneBorder(strokeColor, isDraggingOver),
        child: Container(
          height: 120.0,
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
          decoration: BoxDecoration(
            color: isPressed
                ? colors.bg.transparentPressed
                : colors.bg.transparent,
            borderRadius: SeedBorderRadius.r3,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeedButton(
                  label: '파일 선택',
                  variant: SeedButtonVariant.neutralWeak,
                  size: SeedButtonSize.small,
                  prefixIcon: icon ?? const Icon(Icons.file_upload_outlined),
                  onPressed: enabled ? onTap : null,
                ),
                const SizedBox(height: SeedDimension.x2),
                Text(
                  label,
                  style: typography.t4Medium.copyWith(color: labelColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
  const SeedAttachmentInput({
    super.key,
    required this.items,
    this.maxCount = 10,
    this.onAdd,
    this.onRemove,
    this.onRetry,
    this.itemSize = 80.0,
    this.representativeLabel = '대표',
    this.triggerIcon,
    this.showTrigger = true,
    this.readOnly = false,
    this.onReorder,
    this.enabled = true,
  });

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
  final String representativeLabel;

  /// Flutter composition option for React's separate image/general TriggerIcon.
  /// Omitted values keep the existing camera trigger.
  final Widget? triggerIcon;

  /// Whether to include the tile trigger beside previews (false for dropzones).
  final bool showTrigger;
  final bool readOnly;
  final ReorderCallback? onReorder;

  /// Whether the attachment input is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
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
    if (onReorder != null) {
      return SizedBox(
        height: math.max(
          showTrigger ? triggerHeight : 0,
          items.any((item) => item.type == SeedAttachmentType.file)
              ? _fileHeight(context, typography)
              : itemSize,
        ),
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          header: showTrigger ? trigger : null,
          itemCount: items.length,
          onReorderItem: (from, to) {
            if (enabled && !readOnly) onReorder!(from, to > from ? to + 1 : to);
          },
          itemBuilder: (context, index) {
            final item = items[index];
            final child = Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: preview(item),
            );
            return KeyedSubtree(
              key: ValueKey(item.id),
              child: enabled && !readOnly && item.enabled && !item.readOnly
                  ? ReorderableDelayedDragStartListener(
                      index: index,
                      child: child,
                    )
                  : child,
            );
          },
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTrigger) trigger,
          for (final item in items)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: preview(item),
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
      width: 160.0,
      height: _fileHeight(context, typography),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bg.transparent,
          borderRadius: SeedBorderRadius.r3,
          border: Border.all(color: colors.stroke.neutralWeak, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.status.isLoading)
              Center(
                child: Semantics(
                  label: '첨부 파일 업로드 중',
                  child: SeedProgressCircle(size: 24, value: item.progress),
                ),
              )
            else if (item.status == SeedAttachmentStatus.error)
              _buildRetryAction(item, colors, typography)
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
                top: SeedDimension.x1,
                right: SeedDimension.x1,
                child: _buildRemoveButton(item, colors),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryAction(
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
      message: '첨부 파일 업로드 재시도',
      child: SeedPressable(
        enabled: canRetry,
        semanticsLabel: '첨부 파일 업로드 재시도',
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
                Text('재시도', style: typography.t2Medium.copyWith(color: color)),
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
      children: [
        // Thumbnail square container
        Container(
          width: itemSize,
          height: itemSize,
          decoration: BoxDecoration(
            color: colors.bg.neutralWeak,
            borderRadius: SeedBorderRadius.r3,
            border: Border.all(color: colors.stroke.neutralSubtle, width: 1.0),
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
                representativeLabel,
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
              child: _buildRetryAction(item, colors, typography, image: true),
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
            top: SeedDimension.x1,
            right: SeedDimension.x1,
            child: _buildRemoveButton(item, colors),
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

  Widget _buildRemoveButton(SeedAttachmentItem item, SeedColorScheme colors) {
    return SeedPressable(
      semanticsLabel: '첨부 파일 삭제',
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
    );
  }
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
