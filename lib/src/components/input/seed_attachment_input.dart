import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Status of an individual attachment item.
enum SeedAttachmentStatus { completed, loading, error }

/// A model describing an attachment item.
class SeedAttachmentItem {
  const SeedAttachmentItem({
    required this.id,
    this.name,
    this.imageProvider,
    this.status = SeedAttachmentStatus.completed,
    this.isRepresentative = false,
  });

  final String id;
  final String? name;
  final ImageProvider? imageProvider;
  final SeedAttachmentStatus status;
  final bool isRepresentative;
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
    this.itemSize = 72.0,
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
                      ? colors.bg.layerDefaultPressed
                      : colors.bg.layerDefault,
                  borderRadius: SeedBorderRadius.r2,
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
                    const SizedBox(height: 2),
                    Text(
                      '${items.length}/$maxCount',
                      style: typography.t1Regular.copyWith(
                        color: items.isNotEmpty && canAdd
                            ? colors.fg.brand
                            : colors.fg.neutralMuted,
                        fontWeight: items.isNotEmpty
                            ? FontWeight.bold
                            : FontWeight.normal,
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
              child: _buildPreviewItem(context, item, colors, typography),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(
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
            borderRadius: SeedBorderRadius.r2,
            border: Border.all(
              color: item.status == SeedAttachmentStatus.error
                  ? colors.stroke.criticalSolid
                  : colors.stroke.neutralMuted.withValues(alpha: 0.4),
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
                    size: 28,
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
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: colors.bg.neutralInverted.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Text(
                representativeLabel,
                textAlign: TextAlign.center,
                style: typography.t1Bold.copyWith(
                  color: colors.fg.neutralInverted,
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
                borderRadius: SeedBorderRadius.r2,
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
                borderRadius: SeedBorderRadius.r2,
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: colors.fg.neutralInverted,
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
            top: 2,
            right: 2,
            child: SeedPressable(
              semanticsLabel: '첨부 파일 삭제',
              enableScale: false,
              onTap: () => onRemove?.call(item),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.bg.neutralInverted.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: colors.fg.neutralInverted,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
