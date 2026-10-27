import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../foundations/feedback/seed_touch_target.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import 'seed_content_placeholder.dart';

/// Predefined aspect ratios for [SeedImageFrame].
enum SeedImageRatio {
  square(1.0),
  standard(4.0 / 3.0),
  wide(16.0 / 9.0);

  const SeedImageRatio(this.aspectRatio);
  final double aspectRatio;
}

/// A SEED Design Image Frame component.
///
/// Features:
/// - Predefined or custom aspect ratios
/// - Consistent rounded corners
/// - Built-in fallback placeholder if image is null or fails to load
/// - Overlay support (representative badge, number badge, close button)
class SeedImageFrame extends StatelessWidget {
  const SeedImageFrame({
    super.key,
    this.imageProvider,
    this.onLoad,
    this.onError,
    this.semanticLabel,
    this.ratio = SeedImageRatio.standard,
    this.customRatio,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.badge,
    this.onRemove,
    this.overlay,
    this.fallback,
    this.loading,
    this.stroke = false,
    this.topLeading,
    this.topTrailing,
    this.bottomLeading,
    this.bottomTrailing,
  });

  /// The image provider to load.
  final ImageProvider? imageProvider;

  /// Called once when the current provider produces its first image frame.
  final VoidCallback? onLoad;

  /// Called once if the current provider fails to load.
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final String? semanticLabel;

  /// Aspect ratio preset (square 1:1, standard 4:3, wide 16:9).
  final SeedImageRatio ratio;

  /// Optional custom aspect ratio override.
  final double? customRatio;

  /// How the image should be inscribed into the frame.
  final BoxFit fit;

  /// Custom border radius. Defaults to [SeedBorderRadius.r2].
  final BorderRadius? borderRadius;

  /// An optional badge label displayed at the bottom of the image frame.
  final String? badge;

  /// An optional callback when the close/remove button is pressed.
  final VoidCallback? onRemove;

  /// An optional overlay widget placed on top of the image.
  final Widget? overlay;

  /// Fallback widget when image is absent. Defaults to [SeedContentPlaceholder].
  final Widget? fallback;
  final Widget? loading, topLeading, topTrailing, bottomLeading, bottomTrailing;
  final bool stroke;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final effectiveRadius = borderRadius ?? SeedBorderRadius.r2;
    final effectiveRatio = customRatio ?? ratio.aspectRatio;

    return AspectRatio(
      aspectRatio: effectiveRatio,
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or Fallback
            if (imageProvider != null)
              _SeedFrameImage(
                provider: imageProvider!,
                fit: fit,
                loading: loading,
                fallback: fallback,
                semanticLabel: semanticLabel,
                onLoad: onLoad,
                onError: onError,
              )
            else
              fallback ?? const SeedContentPlaceholder(),

            ?overlay,
            if (stroke)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: effectiveRadius,
                    border: Border.all(color: colors.stroke.neutralSubtle),
                  ),
                ),
              ),
            if (topLeading != null)
              PositionedDirectional(start: 6, top: 6, child: topLeading!),
            if (topTrailing != null)
              PositionedDirectional(end: 6, top: 6, child: topTrailing!),
            if (bottomLeading != null)
              PositionedDirectional(start: 6, bottom: 6, child: bottomLeading!),
            if (bottomTrailing != null)
              PositionedDirectional(end: 6, bottom: 6, child: bottomTrailing!),

            // Bottom badge
            if (badge != null && badge!.isNotEmpty)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SeedPalette.staticBlackAlpha800,
                    borderRadius: SeedBorderRadius.full,
                  ),
                  child: Text(
                    badge!,
                    textAlign: TextAlign.center,
                    style: typography.t1Medium.copyWith(
                      color: SeedPalette.staticWhite,
                    ),
                  ),
                ),
              ),

            // Top-right remove button
            if (onRemove != null)
              Positioned(
                top: SeedDimension.x1,
                right: SeedDimension.x1,
                child: SeedPressable(
                  semanticsLabel: '이미지 삭제',
                  enableScale: false,
                  onTap: onRemove,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.bg.neutralInverted.withValues(
                            alpha: 0.6,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: SeedPalette.staticWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeedFrameImage extends StatefulWidget {
  const _SeedFrameImage({
    required this.provider,
    required this.fit,
    this.loading,
    this.fallback,
    this.semanticLabel,
    this.onLoad,
    this.onError,
  });
  final ImageProvider provider;
  final BoxFit fit;
  final Widget? loading, fallback;
  final String? semanticLabel;
  final VoidCallback? onLoad;
  final void Function(Object, StackTrace?)? onError;

  @override
  State<_SeedFrameImage> createState() => _SeedFrameImageState();
}

class _SeedFrameImageState extends State<_SeedFrameImage> {
  bool _loaded = false, _failed = false;
  int _generation = 0;

  @override
  void didUpdateWidget(_SeedFrameImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _loaded = _failed = false;
      _generation++;
    }
  }

  void _notify(VoidCallback callback) {
    final generation = _generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) callback();
    });
  }

  @override
  Widget build(BuildContext context) => Image(
    image: widget.provider,
    fit: widget.fit,
    semanticLabel: widget.semanticLabel,
    frameBuilder: (context, child, frame, synchronous) {
      if (frame != null && !_loaded) {
        _loaded = true;
        _notify(() => widget.onLoad?.call());
      }
      return child;
    },
    loadingBuilder: widget.loading == null
        ? null
        : (context, child, progress) =>
              progress == null ? child : widget.loading!,
    errorBuilder: (context, error, stackTrace) {
      if (!_failed) {
        _failed = true;
        _notify(() => widget.onError?.call(error, stackTrace));
      }
      return widget.fallback ?? const SeedContentPlaceholder();
    },
  );
}

/// An overlay slot with nine placements and independent inward offsets.
/// Use inside [SeedImageFrame.overlay], or compose multiple floaters in a Stack.
class SeedImageFrameFloater extends StatelessWidget {
  const SeedImageFrameFloater({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.topEnd,
    this.offsetX = 6,
    this.offsetY = 6,
  });
  final Widget child;
  final AlignmentGeometry alignment;
  final double offsetX, offsetY;

  @override
  Widget build(BuildContext context) {
    final resolved = alignment.resolve(Directionality.of(context));
    return Align(
      alignment: resolved,
      child: Transform.translate(
        offset: Offset(
          resolved.x == 0 ? offsetX : -resolved.x * offsetX,
          resolved.y == 0 ? offsetY : -resolved.y * offsetY,
        ),
        child: child,
      ),
    );
  }
}

/// A heart toggle with controlled or local state and accessible pressed feedback.
class SeedImageFrameReactionButton extends StatefulWidget {
  const SeedImageFrameReactionButton({
    super.key,
    bool? pressed,
    @Deprecated('Use pressed instead.') bool? selected,
    bool? defaultPressed,
    @Deprecated('Use defaultPressed instead.') bool? defaultSelected,
    ValueChanged<bool>? onPressedChange,
    @Deprecated('Use onPressedChange instead.') ValueChanged<bool>? onChanged,
    this.enabled = true,
    this.semanticsLabel = '좋아요',
  }) : selected = pressed ?? selected,
       defaultSelected = defaultPressed ?? defaultSelected ?? false,
       onChanged = onPressedChange ?? onChanged,
       assert(pressed == null || selected == null),
       assert(defaultPressed == null || defaultSelected == null),
       assert(onPressedChange == null || onChanged == null);
  @Deprecated('Use pressed instead.')
  final bool? selected;
  bool? get pressed => selected;
  @Deprecated('Use defaultPressed instead.')
  final bool defaultSelected;
  bool get defaultPressed => defaultSelected;
  @Deprecated('Use onPressedChange instead.')
  final ValueChanged<bool>? onChanged;
  ValueChanged<bool>? get onPressedChange => onChanged;
  final bool enabled;
  final String semanticsLabel;

  @override
  State<SeedImageFrameReactionButton> createState() =>
      _SeedImageFrameReactionButtonState();
}

class _SeedImageFrameReactionButtonState
    extends State<SeedImageFrameReactionButton> {
  late bool _selected = widget.defaultSelected;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected ?? _selected;
    return SeedTouchTarget(
      visualSize: const Size(24, 24),
      targetSize: const Size(40, 40),
      child: SeedPressable(
        enabled: widget.enabled,
        selected: selected,
        semanticsLabel: widget.semanticsLabel,
        focusBorderRadius: SeedBorderRadius.r1,
        onTap: () {
          if (widget.selected == null) setState(() => _selected = !selected);
          widget.onChanged?.call(!selected);
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _SeedHeartPainter(selected),
            ),
          ),
        ),
      ),
    );
  }
}

// Heart geometry adapted from daangn/seed-design ImageFrame.tsx, revision
// 14aa12a20fc1ce39044212f531b2127c6787eab0.
// Copyright 2025 주식회사 당근마켓. Apache-2.0; see
// third_party/seed-design/LICENSE and NOTICE. Converted SVG paths to Canvas.
class _SeedHeartPainter extends CustomPainter {
  const _SeedHeartPainter(this.selected);
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    canvas.translate(-8, -9);
    final fill = _fillPath();
    if (selected) {
      canvas.drawPath(
        fill,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(7, 8.5),
            const Offset(26.0974, 10.5391),
            const [Color(0xFFFF9A56), Color(0xFFFF6600)],
          ),
      );
    } else {
      canvas.drawShadow(fill, const Color(0x26000000), 2, false);
      canvas.drawPath(fill, Paint()..color = const Color(0x4C000000));
      canvas.drawPath(_outlinePath(), Paint()..color = SeedPalette.staticWhite);
    }
  }

  @override
  bool shouldRepaint(_SeedHeartPainter oldDelegate) =>
      selected != oldDelegate.selected;

  Path _fillPath() => Path()
    ..moveTo(15.5452, 10)
    ..cubicTo(11.7873, 10, 9.25, 12.9484, 9.25, 16.6267)
    ..cubicTo(9.25, 19.8754, 11.1219, 22.0952, 13.1877, 23.969)
    ..cubicTo(13.7807, 24.5069, 14.4438, 25.0617, 15.095, 25.6066)
    ..cubicTo(15.5434, 25.9817, 15.9862, 26.3522, 16.3967, 26.7093)
    ..cubicTo(17.4501, 27.6257, 18.4191, 28.557, 19.1995, 29.5994)
    ..cubicTo(19.3886, 29.8518, 19.6856, 30.0003, 20.001, 30)
    ..cubicTo(20.3163, 29.9997, 20.6131, 29.8507, 20.8016, 29.5979)
    ..cubicTo(21.5785, 28.5562, 22.5453, 27.6253, 23.598, 26.7091)
    ..cubicTo(24.0105, 26.35, 24.4568, 25.9766, 24.9089, 25.5984)
    ..cubicTo(25.5573, 25.0559, 26.2176, 24.5035, 26.807, 23.9693)
    ..cubicTo(28.8739, 22.096, 30.75, 19.8761, 30.75, 16.6267)
    ..cubicTo(30.75, 12.9484, 28.2127, 10, 24.4548, 10)
    ..cubicTo(22.6365, 10, 21.1002, 11.0545, 20, 12.4906)
    ..cubicTo(18.8998, 11.0545, 17.3635, 10, 15.5452, 10)
    ..close();

  Path _outlinePath() => Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(15.5452, 12)
    ..cubicTo(13.0342, 12, 11.25, 13.905, 11.25, 16.6267)
    ..cubicTo(11.25, 18.9912, 12.5659, 20.7048, 14.5314, 22.4876)
    ..cubicTo(15.1157, 23.0176, 15.7038, 23.5087, 16.3148, 24.019)
    ..cubicTo(16.7646, 24.3946, 17.2269, 24.7807, 17.7093, 25.2003)
    ..cubicTo(18.4947, 25.8835, 19.2814, 26.6141, 19.9988, 27.4215)
    ..cubicTo(20.7144, 26.614, 21.5001, 25.8836, 22.2849, 25.2005)
    ..cubicTo(22.7714, 24.7771, 23.2368, 24.3885, 23.6895, 24.0105)
    ..cubicTo(24.2967, 23.5035, 24.8813, 23.0154, 25.4639, 22.4874)
    ..cubicTo(27.4317, 20.704, 28.75, 18.9906, 28.75, 16.6267)
    ..cubicTo(28.75, 13.905, 26.9658, 12, 24.4548, 12)
    ..cubicTo(23.069, 12, 21.747, 12.8325, 20.8919, 14.5189)
    ..cubicTo(20.7215, 14.8549, 20.3768, 15.0667, 20, 15.0667)
    ..cubicTo(19.6233, 15.0667, 19.2785, 14.8549, 19.1081, 14.5189)
    ..cubicTo(18.2531, 12.8325, 16.931, 12, 15.5452, 12)
    ..close()
    ..moveTo(9.25, 16.6267)
    ..cubicTo(9.25, 12.9484, 11.7873, 10, 15.5452, 10)
    ..cubicTo(17.3146, 10, 18.8683, 10.8364, 20, 12.2306)
    ..cubicTo(21.1317, 10.8364, 22.6854, 10, 24.4548, 10)
    ..cubicTo(28.2127, 10, 30.75, 12.9484, 30.75, 16.6267)
    ..cubicTo(30.75, 19.8761, 28.8739, 22.096, 26.807, 23.9693)
    ..cubicTo(26.2176, 24.5035, 25.5573, 25.0559, 24.9089, 25.5984)
    ..cubicTo(24.4568, 25.9766, 24.0105, 26.35, 23.598, 26.7091)
    ..cubicTo(22.5453, 27.6253, 21.5785, 28.5562, 20.8016, 29.5979)
    ..cubicTo(20.6131, 29.8507, 20.3163, 29.9997, 20.001, 30)
    ..cubicTo(19.6856, 30.0003, 19.3886, 29.8518, 19.1995, 29.5994)
    ..cubicTo(18.4191, 28.557, 17.4501, 27.6257, 16.3967, 26.7093)
    ..cubicTo(15.9862, 26.3522, 15.5434, 25.9817, 15.095, 25.6066)
    ..cubicTo(14.4438, 25.0617, 13.7807, 24.5069, 13.1877, 23.969)
    ..cubicTo(11.1219, 22.0952, 9.25, 19.8754, 9.25, 16.6267)
    ..close();
}
