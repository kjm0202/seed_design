import 'package:material_ui/material_ui.dart';

import 'seed_progress_circle.dart';

/// Overlays a progress indicator on custom content while it is loading,
/// like React `LoadingIndicator` (React 3.0+).
///
/// React renders the indicator absolutely positioned over a copy of the
/// children with `opacity: 0`, so the element keeps the size of its content,
/// and buttons use it for their pending state. This widget does the same:
///
/// * The layout size is always the size of [child]. The indicator is
///   positioned over it and does not change that size, even when it is larger
///   than the content (it then overflows without being clipped).
/// * While [loading], [child] is not painted and is removed from the
///   semantics tree, so assistive technology announces only the indicator.
///   [child] stays mounted and keeps its state, size and animations.
/// * Whether hidden content still receives pointer and focus input is a
///   separate choice, [disableOnLoading], named after
///   `SeedButton.disableOnLoading`.
///
/// The built-in SEED buttons keep their own equivalent overlay, tuned to each
/// button's size and colors; use this widget for custom pressable content.
///
/// ```dart
/// SeedLoadingIndicator(
///   loading: saving,
///   child: const Text('저장'),
/// )
/// ```
class SeedLoadingIndicator extends StatelessWidget {
  /// Creates a loading overlay around [child].
  ///
  /// [loading] shows [indicator] and hides [child]. [indicator] defaults to
  /// a 24px neutral [SeedProgressCircle] whose spoken label is
  /// [semanticsLabel]. [disableOnLoading] (default true) blocks pointer and
  /// focus input to [child] while loading. [alignment] positions the
  /// indicator over the content and defaults to the center.
  const SeedLoadingIndicator({
    super.key,
    required this.loading,
    required this.child,
    this.indicator,
    this.disableOnLoading = true,
    this.alignment = Alignment.center,
    this.semanticsLabel,
  });

  /// Whether the content is pending. React renders `LoadingIndicator` only
  /// while loading; Flutter keeps the widget and toggles this flag so the
  /// content's state survives the transition.
  final bool loading;

  /// The content that defines the layout size.
  final Widget child;

  /// Widget shown over the content while [loading]; null uses a 24px
  /// [SeedProgressCircle]. React's registry default is a ProgressCircle that
  /// inherits size and color from the surrounding button; pass an indicator
  /// sized and colored for the content when it is not a 24px neutral one.
  final Widget? indicator;

  /// Blocks pointer and focus input to the hidden [child] while [loading]
  /// when true (the default). The indicator itself never takes input.
  ///
  /// This affects only [child]'s subtree. A surrounding pressable that owns
  /// the action decides separately whether it accepts taps while loading.
  final bool disableOnLoading;

  /// Position of the indicator within the content's box.
  final AlignmentGeometry alignment;

  /// Spoken label for the default indicator; ignored with a custom
  /// [indicator]. Its value announces the loading state either way, unless
  /// the custom indicator provides no semantics.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // The content keeps the constraints it would get without the overlay.
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        Visibility(
          visible: !loading,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          maintainInteractivity: !disableOnLoading,
          maintainFocusability: !disableOnLoading,
          child: child,
        ),
        if (loading)
          Positioned.fill(
            child: IgnorePointer(
              child: OverflowBox(
                minWidth: 0,
                minHeight: 0,
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                alignment: alignment,
                child:
                    indicator ??
                    SeedProgressCircle(
                      size: 24,
                      semanticsLabel: semanticsLabel,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
