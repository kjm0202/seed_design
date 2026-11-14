import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Theme, TargetPlatform;
import 'package:seed_design/seed_design.dart';

/// The official AppScreen dim: the whole page for the iOS slide, a 160px top
/// gradient for the Android fade. Like `seed-app-screen__dim`, it belongs to
/// the entering Activity and sits under its layer, so it only shows while that
/// layer animates in. Modal Activities have no AppScreen and therefore no dim.
class SpaActivityDim extends StatelessWidget {
  const SpaActivityDim({
    super.key,
    required this.animation,
    required this.child,
    this.gradient = false,
  });
  final Animation<double> animation;
  final bool gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final overlay = context.seedColor.bg.overlay;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: gradient ? null : 0,
          height: gradient ? 160 : null,
          child: IgnorePointer(
            child: FadeTransition(
              opacity: animation,
              child: DecoratedBox(
                decoration: gradient
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [overlay, overlay.withValues(alpha: 0)],
                        ),
                      )
                    : BoxDecoration(color: overlay),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// React's android AppBar keeps an empty left slot when a directly entered
/// Activity has no Back button, which moves its title 14px.
/// Whether the page's own route is the stack root. Unlike
/// `Navigator.canPop()`, this stays false for the root page while another
/// Activity or overlay is pushed above it (e.g. during a push transition).
bool spaIsRootRoute(BuildContext context) =>
    !(ModalRoute.of(context)?.canPop ?? Navigator.of(context).canPop());

bool spaHasEmptyAppBarLeft(BuildContext context) =>
    spaIsRootRoute(context) && Theme.of(context).platform != TargetPlatform.iOS;

Widget spaRootTitle(BuildContext context, String title, {Color? color}) =>
    Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.seedTypography.t6Bold.copyWith(
          color: color ?? context.seedColor.fg.neutral,
        ),
      ),
    );

/// Route controls act on Flutter's real interactive back transition.
class SpaCupertinoRoute<T> extends CupertinoPageRoute<T> {
  SpaCupertinoRoute({required super.builder, super.settings});
  bool preventSwipeBack = false;
  final ValueNotifier<String> swipeEvent = ValueNotifier('');
  bool swiping = false;
  @override
  bool get popGestureEnabled => !preventSwipeBack && super.popGestureEnabled;
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => SpaActivityDim(
    animation: animation,
    child: super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    ),
  );
  @override
  void dispose() {
    swipeEvent.dispose();
    super.dispose();
  }
}

class SpaGestureObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routes = [];
  int get activityIndex => _routes.whereType<PageRoute<dynamic>>().length - 1;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.add(route);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.remove(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = _routes.indexOf(oldRoute!);
    if (index >= 0 && newRoute != null) _routes[index] = newRoute;
  }

  SpaCupertinoRoute<dynamic>? _swiping;
  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    if (route is SpaCupertinoRoute) {
      _swiping = route;
      route.swiping = true;
      route.swipeEvent.value = 'Started swiping';
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    if (route == _swiping) {
      _swiping!.swipeEvent.value = 'Swiped: true';
    }
  }

  @override
  void didStopUserGesture() {
    final route = _swiping;
    if (route != null) {
      if (route.swipeEvent.value != 'Swiped: true') {
        route.swipeEvent.value = 'Swiped: false';
      }
      route.swiping = false;
    }
    _swiping = null;
  }
}
