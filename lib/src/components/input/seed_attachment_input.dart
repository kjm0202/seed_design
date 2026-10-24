import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Status of an individual attachment item.
enum SeedAttachmentStatus { completed, loading, error }

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
  });

  final String id;
  final String? name;
  final String? sizeText;
  final SeedAttachmentType type;
  final ImageProvider? imageProvider;
  final SeedAttachmentStatus status;
  final bool isRepresentative;
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
    this.label = '파일을 드래그하거나 클릭하여 업로드',
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
      builder: (context, isPressed) => Container(
        height: 120.0,
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
        decoration: BoxDecoration(
          color: isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
          borderRadius: SeedBorderRadius.r3,
          border: Border.all(
            color: strokeColor,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon ??
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 28.0,
                    color: labelColor,
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
    );
  }
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

  /// Whether the attachment input is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final canAdd = enabled && items.length < maxCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trigger button
          SeedPressable(
            enabled: canAdd,
            onTap: canAdd ? onAdd : null,
            builder: (context, isPressed) {
              return Container(
                width: itemSize,
                height: itemSize,
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
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 24,
                      color: canAdd
                          ? colors.fg.neutralSubtle
                          : colors.fg.disabled,
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${items.length}',
                            style: typography.t2Regular.copyWith(
                              color: canAdd
                                  ? colors.fg.neutral
                                  : colors.fg.disabled,
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
          ),

          // Previews
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(left: SeedDimension.x2),
              child: item.type == SeedAttachmentType.file
                  ? _buildFileItem(context, item, colors, typography)
                  : _buildImageItem(context, item, colors, typography),
            );
          }),
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
    return Container(
      width: 160.0,
      height: 80.0,
      padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
      decoration: BoxDecoration(
        color: colors.bg.transparent,
        borderRadius: SeedBorderRadius.r3,
        border: Border.all(color: colors.stroke.neutralWeak, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  Text(
                    item.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.t2Medium.copyWith(color: colors.fg.neutral),
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
          if (enabled && onRemove != null)
            SeedPressable(
              semanticsLabel: '파일 삭제',
              onTap: () => onRemove?.call(item),
              child: Icon(
                Icons.close_rounded,
                size: 16.0,
                color: colors.fg.neutralSubtle,
              ),
            ),
        ],
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
            border: Border.all(
              color: item.status == SeedAttachmentStatus.error
                  ? colors.stroke.criticalSolid
                  : colors.stroke.neutralSubtle,
              width: 1.0,
            ),
            image: item.imageProvider != null
                ? DecorationImage(image: item.imageProvider!, fit: BoxFit.cover)
                : null,
          ),
          child: item.imageProvider == null
              ? Center(
                  child: Icon(
                    Icons.insert_drive_file_outlined,
                    color: colors.fg.neutralSubtle,
                    size: 24,
                  ),
                )
              : null,
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
        if (item.status == SeedAttachmentStatus.loading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.bg.layerDefault.withValues(alpha: 0.6),
                borderRadius: SeedBorderRadius.r3,
              ),
              child: const Center(child: SeedProgressCircle(size: 24)),
            ),
          ),

        // Error overlay with retry
        if (item.status == SeedAttachmentStatus.error)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.bg.neutralInverted.withValues(alpha: 0.5),
                borderRadius: SeedBorderRadius.r3,
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFFFFFFFF),
                    size: 24,
                  ),
                  onPressed: () => onRetry?.call(item),
                ),
              ),
            ),
          ),

        // Delete button in top right
        if (enabled && onRemove != null)
          Positioned(
            top: SeedDimension.x1,
            right: SeedDimension.x1,
            child: SeedPressable(
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
                    border: Border.all(
                      color: colors.stroke.neutralWeak,
                      width: 1.0,
                    ),
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
          ),
      ],
    );
  }
}
