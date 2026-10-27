import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import 'seed_progress_circle.dart';

/// Native scroll coordination, with SEED's progress indicator and ready callback.
class SeedPullToRefresh extends StatefulWidget {
  const SeedPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onReady,
    this.enabled = true,
    this.preventPull = false,
    this.displacement = 40,
    this.edgeOffset = 0,
    this.notificationPredicate,
  });
  final Widget child;
  final Future<void> Function() onRefresh;
  final VoidCallback? onReady;
  final bool enabled, preventPull;
  final double displacement, edgeOffset;
  final ScrollNotificationPredicate? notificationPredicate;
  @override
  State<SeedPullToRefresh> createState() => _SeedPullToRefreshState();
}

class _SeedPullToRefreshState extends State<SeedPullToRefresh> {
  RefreshIndicatorStatus? _status;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      RefreshIndicator.noSpinner(
        onRefresh: widget.onRefresh,
        onStatusChange: (status) {
          if (status == RefreshIndicatorStatus.armed && _status != status) {
            widget.onReady?.call();
          }
          setState(() => _status = status);
        },
        notificationPredicate: (notification) =>
            widget.enabled &&
            !widget.preventPull &&
            (widget.notificationPredicate?.call(notification) ??
                notification.depth == 0),
        child: widget.child,
      ),
      if (_status != null &&
          _status != RefreshIndicatorStatus.done &&
          _status != RefreshIndicatorStatus.canceled)
        Positioned(
          top: widget.edgeOffset + widget.displacement / 2,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Material(
                color: context.seedColor.bg.layerFloating,
                shape: const CircleBorder(),
                elevation: 2,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: SeedProgressCircle(),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
