import 'package:flutter/cupertino.dart';

/// Route controls act on Flutter's real interactive back transition.
class SpaCupertinoRoute<T> extends CupertinoPageRoute<T> {
  SpaCupertinoRoute({required super.builder, super.settings});
  bool preventSwipeBack = false;
  final ValueNotifier<String> swipeEvent = ValueNotifier('');
  bool swiping = false;
  @override
  bool get popGestureEnabled => !preventSwipeBack && super.popGestureEnabled;
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
