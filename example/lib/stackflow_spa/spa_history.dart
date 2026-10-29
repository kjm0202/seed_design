import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'spa_routes.dart';
import 'spa_history_browser_stub.dart'
    if (dart.library.js_interop) 'spa_history_browser_web.dart'
    as browser;

/// Browser entries describe activities, excluding their unnamed sheet/dialog routes.
class SpaHistory {
  const SpaHistory(
    this.activities, {
    this.fromExternalUrl = false,
    this.sessionId,
    this.localActivityIds = const [],
  });
  final List<RouteSettings> activities;
  final String? sessionId;
  final List<int?> localActivityIds;

  /// A platform URL visit without serialized SPA activity history. Unlike
  /// Stackflow's own PUSH/Back/Forward, this is a fresh address-navigation
  /// lifecycle, so page-global transient UI must not retain prior state.
  final bool fromExternalUrl;
}

String _normalizedActivityPath(Uri? uri) {
  final path = uri?.path ?? '/';
  return path.length > 1 && path.endsWith('/')
      ? path.substring(0, path.length - 1)
      : path;
}

String _stepRouteName(String name, Map<String, String> values) {
  final uri = Uri.parse(name);
  if (values.isEmpty) return uri.path;
  return uri.replace(queryParameters: values).toString();
}

String _activityStackSignature(Iterable<RouteSettings> activities) =>
    jsonEncode([
      for (final activity in activities)
        {'name': activity.name, 'arguments': activity.arguments},
    ]);

class SpaHistoryParser extends RouteInformationParser<SpaHistory> {
  const SpaHistoryParser();

  static RouteSettings _routeFromUri(Uri uri) {
    // React's article route serializes the required Stackflow activity param
    // in the query string. Preserve all other queries (including step URLs).
    if (uri.path == '/demo/article-detail' ||
        uri.path == '/demo/article-detail/') {
      return RouteSettings(
        name: '/demo/article-detail',
        arguments: int.tryParse(uri.queryParameters['articleId'] ?? ''),
      );
    }
    if (uri.path == '/transition-style' || uri.path == '/transition-style/') {
      final style = uri.queryParameters['transitionStyle'];
      return RouteSettings(
        name: '/transition-style',
        arguments: style == null ? null : {'transitionStyle': style},
      );
    }
    return RouteSettings(name: uri.toString());
  }

  static Uri _uriForRoute(RouteSettings route) {
    final uri = Uri.parse(route.name ?? '/');
    if (uri.path == '/demo/article-detail' ||
        uri.path == '/demo/article-detail/') {
      final id = route.arguments is int
          ? route.arguments as int
          : int.tryParse(uri.queryParameters['articleId'] ?? '');
      if (id != null) {
        return uri.replace(
          path: '/demo/article-detail/',
          queryParameters: {...uri.queryParameters, 'articleId': '$id'},
        );
      }
    }
    if (uri.path == '/transition-style' || uri.path == '/transition-style/') {
      final args = route.arguments;
      final style = args is Map ? args['transitionStyle'] : null;
      if (style is String) {
        return uri.replace(
          path: '/transition-style/',
          queryParameters: {...uri.queryParameters, 'transitionStyle': style},
        );
      }
    }
    return uri;
  }

  @override
  Future<SpaHistory> parseRouteInformation(RouteInformation routeInformation) {
    final state = routeInformation.state;
    if (state is Map && state['seedActivities'] is List) {
      final entries = (state['seedActivities'] as List)
          .whereType<Map>()
          .where((entry) => entry['name'] is String)
          .map(
            (entry) => RouteSettings(
              name: entry['name'] as String,
              arguments: entry['arguments'],
            ),
          )
          .toList();
      if (entries.isNotEmpty &&
          _uriForRoute(entries.last).toString() ==
              routeInformation.uri.toString()) {
        final rawIds = state['seedLocalActivityIds'];
        return SynchronousFuture(
          SpaHistory(
            entries,
            sessionId: state['seedSessionId'] is String
                ? state['seedSessionId'] as String
                : null,
            localActivityIds: rawIds is List && rawIds.length == entries.length
                ? rawIds.map((id) => id is int ? id : null).toList()
                : const [],
          ),
        );
      }
    }
    return SynchronousFuture(
      // React history-sync starts with the URL's matching Activity as its
      // first (root) entry, unless the route defines its own defaultHistory.
      // These SPA routes have no defaultHistory entries.
      SpaHistory([_routeFromUri(routeInformation.uri)], fromExternalUrl: true),
    );
  }

  @override
  RouteInformation restoreRouteInformation(SpaHistory configuration) =>
      RouteInformation(
        uri: _uriForRoute(configuration.activities.last),
        state: {
          'seedActivities': [
            for (final activity in configuration.activities)
              {'name': activity.name, 'arguments': activity.arguments},
          ],
          if (configuration.sessionId != null) ...{
            'seedSessionId': configuration.sessionId,
            'seedLocalActivityIds': configuration.localActivityIds,
          },
        },
      );
}

/// Retains the imperative Navigator and native transitions while Router owns
/// browser URL/history updates, including restoration on Back and Forward.
class SpaHistoryDelegate extends RouterDelegate<SpaHistory>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<SpaHistory> {
  SpaHistoryDelegate({
    required this.onGenerateRoute,
    VoidCallback? onBrowserBack,
    this.onExternalUrlNavigation,
  }) : _onBrowserBack =
           onBrowserBack ??
           (browser.supportsBrowserBack ? browser.goBack : null) {
    _observer = _HistoryObserver(
      _changed,
      onPushed: _observedPush,
      onPopped: _observedPop,
    );
  }

  final RouteFactory onGenerateRoute;
  final VoidCallback? _onBrowserBack;
  final VoidCallback? onExternalUrlNavigation;
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _gestures = SpaGestureObserver();
  final ValueNotifier<int> _stepRevision = ValueNotifier<int>(0);
  late final _HistoryObserver _observer;
  SpaHistory _initial = const SpaHistory([RouteSettings(name: '/')]);
  Route<dynamic>? _stepRoute;
  Map<String, String>? _stepValues;
  // Only a Step explicitly pushed since this SPA started is known to have a
  // previous base entry in *this browser tab's* history. Never navigate off-
  // app merely because a direct URL initially contains ?key=open.
  final Set<Route<dynamic>> _locallyPushedSteps = {};
  // A live Route is trusted only after a local PUSH or restoration of a
  // matching, session-owned browser entry.
  final Set<Route<dynamic>> _locallyPushedActivities = {};
  // IDs survive route reconstruction on browser Forward, but are accepted only
  // for PUSHes observed by this delegate in this live browser session.
  final String _sessionId =
      '${DateTime.now().microsecondsSinceEpoch}-${math.Random.secure().nextInt(1 << 30)}';
  int _nextLocalActivityId = 0;
  final Map<Route<dynamic>, int> _localActivityIds = {};
  final Set<int> _knownLocalActivityIds = {};
  final Map<int, String> _localActivityStacks = {};
  final List<int?> _restoredActivityIds = [];
  // Initial and browser-restored Navigator routes are not fresh browser pushes.
  int _restorePushesToIgnore = 0;
  Route<dynamic>? _lastPublishedRoute;
  bool _restoring = false;
  bool _pending = false;
  bool _replacePending = false;
  bool _sameUriActivityPushPending = false;
  bool _disposed = false;

  void _observedPush(Route<dynamic> route, Route<dynamic>? previous) {
    if (_restorePushesToIgnore > 0) {
      _restorePushesToIgnore--;
      final id = _restoredActivityIds.removeAt(0);
      if (id != null && _knownLocalActivityIds.contains(id)) {
        _localActivityIds[route] = id;
        _locallyPushedActivities.add(route);
        _lastPublishedRoute = route;
      }
      return;
    }
    if (_restoring || previous == null || route.settings.name == null) return;
    _locallyPushedActivities.add(route);
    final id = _nextLocalActivityId++;
    _localActivityIds[route] = id;
    _knownLocalActivityIds.add(id);
    _localActivityStacks[id] = _activityStackSignature(
      _observer.routes
          .where((candidate) => candidate.settings.name != null)
          .map((candidate) => candidate.settings),
    );
    // Flutter's default Router report *replaces* browser history when the
    // pathname is unchanged. An actual same-Activity PUSH must append a new
    // entry just like Stackflow historySyncPlugin.onPushed does, retaining the
    // distinct serialized Activity stack for browser Back/Forward.
    if (previous.settings.name == route.settings.name) {
      _sameUriActivityPushPending = true;
    }
  }

  bool _observedPop(Route<dynamic> route, Route<dynamic>? previous) {
    final local = _locallyPushedActivities.remove(route);
    _localActivityIds.remove(route);
    final canBrowserBack =
        local &&
        _onBrowserBack != null &&
        !_restoring &&
        !_pending &&
        identical(_lastPublishedRoute, route) &&
        route.settings.name != null &&
        previous?.settings.name != null &&
        !(identical(_stepRoute, route) &&
            _stepValues != null &&
            _stepValues!.isNotEmpty);
    _locallyPushedSteps.remove(route);
    if (canBrowserBack) {
      // A session-local, foreground Activity PUSH has a proven predecessor.
      // React's historySyncPlugin.onBeforePop queues history.back(), leaving the
      // child available for Forward; Router replacement would destroy it.
      _lastPublishedRoute = null;
      _onBrowserBack();
      return true;
    }
    return false;
  }

  /// Access the SPA Step bridge from any descendant Activity or modal.
  /// The inherited notifier rebuilds consumers when browser navigation
  /// changes step query parameters without replacing their Activity.
  static SpaHistoryDelegate of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_SpaStepScope>();
    assert(scope != null, 'SpaHistoryDelegate requires StackflowSpaApp');
    return scope!.history;
  }

  /// Standalone component previews can render example pages without a SPA
  /// Router; their overlay fallback must remain available in that case.
  static SpaHistoryDelegate? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SpaStepScope>()?.history;

  Route<dynamic>? get _activeNamedRoute {
    for (final route in _observer.routes.reversed) {
      if (route.settings.name != null) return route;
    }
    return null;
  }

  Map<String, String> _valuesFor(Route<dynamic> route) {
    if (identical(_stepRoute, route) && _stepValues != null) {
      return _stepValues!;
    }
    return Uri.tryParse(route.settings.name ?? '/')?.queryParameters ?? {};
  }

  bool isStepOpen(String key) {
    final route = _activeNamedRoute;
    return route != null && _valuesFor(route)[key] == 'open';
  }

  void pushStep(String key, {String value = 'open'}) {
    final route = _activeNamedRoute;
    if (route == null) return;
    final next = {..._valuesFor(route), key: value};
    if (mapEquals(next, _valuesFor(route))) return;
    _stepRoute = route;
    _stepValues = next;
    _locallyPushedSteps.add(route);
    _stepRevision.value++;
    _changed();
  }

  void popStep(String key) {
    final route = _activeNamedRoute;
    if (route == null || !_valuesFor(route).containsKey(key)) return;
    if (_onBrowserBack != null && _locallyPushedSteps.contains(route)) {
      // Official historySyncPlugin.onBeforeStepPop calls history.back(),
      // rather than replacing the current entry, so browser Forward can
      // reopen this Step. setNewRoutePath handles the resulting popstate.
      _onBrowserBack();
      return;
    }
    // Direct-entry Step or native Flutter: no established in-app browser
    // predecessor exists; replacing the current URL is safer than leaving
    // the SPA. This is a documented deviation from the React browser plugin.
    final next = {..._valuesFor(route)}..remove(key);
    _stepRoute = route;
    _stepValues = next;
    _stepRevision.value++;
    _changed(replace: true);
  }

  @override
  SpaHistory get currentConfiguration {
    final routes = _observer.routes
        .where((route) => route.settings.name != null)
        .toList();
    final activities = [
      for (final route in routes)
        if (identical(route, routes.last) &&
            identical(route, _stepRoute) &&
            _stepValues != null)
          RouteSettings(
            name: _stepRouteName(route.settings.name!, _stepValues!),
            arguments: route.settings.arguments,
          )
        else
          route.settings,
    ];
    return activities.isEmpty
        ? _initial
        : SpaHistory(
            activities,
            sessionId: _sessionId,
            localActivityIds: [
              for (final route in routes) _localActivityIds[route],
            ],
          );
  }

  void _changed({bool replace = false}) {
    if (_restoring || _disposed) return;
    if (_pending) {
      // A push and a pop in one frame must retain the new push entry.
      if (!replace) _replacePending = false;
      return;
    }
    _pending = true;
    _replacePending = replace;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      if (_disposed) return;
      _lastPublishedRoute = _activeNamedRoute;
      final sameUriPush = _sameUriActivityPushPending && !_replacePending;
      _sameUriActivityPushPending = false;
      if (_replacePending && navigatorKey.currentContext != null) {
        // A popped/replaced activity changes the foreground URL without
        // appending a new browser history entry that would reopen the child.
        Router.neglect(navigatorKey.currentContext!, notifyListeners);
      } else if (sameUriPush && navigatorKey.currentContext != null) {
        // Router.navigate explicitly emits replace:false even for equal URI;
        // ordinary notifyListeners would send replace:true for this case.
        Router.navigate(navigatorKey.currentContext!, notifyListeners);
      } else {
        notifyListeners();
      }
    });
  }

  @override
  Future<void> setNewRoutePath(SpaHistory configuration) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _initial = configuration;
      return;
    }
    if (configuration.fromExternalUrl) {
      // React's full-document /form/ → / → /form/ address navigation
      // remounts the root SnackbarProvider. Flutter hash navigation keeps
      // the Dart app alive, so reset only this incoming *unserialized* visit.
      // Session-local pushes and genuine serialized browser Back/Forward
      // retain their current provider and are never reset here.
      onExternalUrlNavigation?.call();
    }
    // Retained route identities keep their provenance. Recreated routes must
    // additionally match a session-owned PUSH ID and its entire saved stack;
    // direct URLs and foreign or altered browser states remain untrusted.
    // Steps follow their own rule until the restored Activity loses its Step.
    final restoredActivity = configuration.activities.last;
    final restoredPath = _normalizedActivityPath(
      Uri.tryParse(restoredActivity.name ?? '/'),
    );
    final restoredHasStep =
        Uri.tryParse(restoredActivity.name ?? '/')
            ?.queryParameters
            .isNotEmpty ==
        true;
    _locallyPushedSteps.removeWhere(
      (route) =>
          configuration.fromExternalUrl ||
          !restoredHasStep ||
          _normalizedActivityPath(Uri.tryParse(route.settings.name ?? '/')) !=
              restoredPath,
    );
    _sameUriActivityPushPending = false;
    _lastPublishedRoute = null;
    final named = _observer.routes
        .where((route) => route.settings.name != null)
        .toList();
    var common = 0;
    var stepChanged = false;
    while (common < named.length && common < configuration.activities.length) {
      final before = named[common].settings;
      final after = configuration.activities[common];
      final sameArgs =
          jsonEncode(before.arguments) == jsonEncode(after.arguments);
      final beforeUri = Uri.tryParse(before.name ?? '/');
      final afterUri = Uri.tryParse(after.name ?? '/');
      final effectiveName =
          identical(named[common], _stepRoute) && _stepValues != null
          ? _stepRouteName(before.name!, _stepValues!)
          : before.name;
      if (sameArgs &&
          _normalizedActivityPath(beforeUri) ==
              _normalizedActivityPath(afterUri) &&
          common == configuration.activities.length - 1 &&
          effectiveName != after.name) {
        // A changed query with the same Activity/params is a Step transition.
        // Keep its StatefulWidget alive across browser Back and Forward.
        _stepRoute = named[common];
        _stepValues = Map<String, String>.of(afterUri!.queryParameters);
        stepChanged = true;
      } else if (before.name != after.name || !sameArgs) {
        break;
      }
      common++;
    }
    final retained = named.take(common).toSet();
    _locallyPushedActivities.removeWhere(
      (route) => configuration.fromExternalUrl || !retained.contains(route),
    );
    _localActivityIds.removeWhere(
      (route, _) => configuration.fromExternalUrl || !retained.contains(route),
    );
    int? restoredId(int index) {
      if (configuration.fromExternalUrl ||
          configuration.sessionId != _sessionId ||
          index >= configuration.localActivityIds.length) {
        return null;
      }
      final id = configuration.localActivityIds[index];
      if (id == null || !_knownLocalActivityIds.contains(id)) return null;
      final signature = _activityStackSignature(
        configuration.activities.take(index + 1),
      );
      return _localActivityStacks[id] == signature ? id : null;
    }

    void markRestoredPush(int index) {
      _restorePushesToIgnore++;
      _restoredActivityIds.add(restoredId(index));
    }

    _restoring = true;
    try {
      // Remove only the changed activity suffix and its modal routes. Unnamed
      // routes belonging to retained parent activities remain on the stack.
      final removed = common < named.length
          ? _observer.routes.sublist(_observer.routes.indexOf(named[common]))
          : <Route<dynamic>>[];
      // Keep a route present even when the browser replaces a direct-entry root.
      if (common == 0) {
        final first = configuration.activities.first;
        markRestoredPush(0);
        navigator.pushNamed(first.name!, arguments: first.arguments);
        common = 1;
      }
      // Remove the Activity and give its widget tree time to unmount before
      // completing any modal future that belongs to the removed Activity.
      // CategorySheet's showSeedBottomSheet continuation calls Navigator.pop
      // while mounted; completing that modal in the same frame as a browser
      // Back can otherwise pop the retained Form as well.
      final modalRoutes = <Route<dynamic>>[];
      for (final route in removed) {
        _locallyPushedSteps.remove(route);
        if (route.settings.name == null) {
          modalRoutes.add(route);
        } else {
          navigator.removeRoute(route);
        }
      }
      if (modalRoutes.isNotEmpty) {
        await WidgetsBinding.instance.endOfFrame;
        for (final route in modalRoutes.reversed) {
          navigator.removeRoute(route);
        }
      }
      for (
        var index = common;
        index < configuration.activities.length;
        index++
      ) {
        final activity = configuration.activities[index];
        markRestoredPush(index);
        navigator.pushNamed(activity.name!, arguments: activity.arguments);
      }
    } finally {
      _restoring = false;
    }
    // Popstate has already positioned the browser on this Activity's entry.
    // Retained or verified session-owned routes can later use browser Back.
    final restored = _activeNamedRoute;
    if (restored != null && _locallyPushedActivities.contains(restored)) {
      _lastPublishedRoute = restored;
    }
    if (stepChanged) _stepRevision.value++;
  }

  @override
  Widget build(BuildContext context) => _SpaStepScope(
    history: this,
    notifier: _stepRevision,
    child: Navigator(
      key: navigatorKey,
      observers: [_gestures, _observer],
      onGenerateRoute: onGenerateRoute,
      onGenerateInitialRoutes: (_, _) {
        final initial = [
          for (final activity in _initial.activities)
            onGenerateRoute(activity)!,
        ];
        _restorePushesToIgnore += initial.length;
        _restoredActivityIds.addAll(List<int?>.filled(initial.length, null));
        return initial;
      },
    ),
  );

  @override
  void dispose() {
    _disposed = true;
    _locallyPushedSteps.clear();
    _locallyPushedActivities.clear();
    _localActivityIds.clear();
    _knownLocalActivityIds.clear();
    _localActivityStacks.clear();
    _restoredActivityIds.clear();
    _stepRevision.dispose();
    super.dispose();
  }
}

class _SpaStepScope extends InheritedNotifier<ValueNotifier<int>> {
  const _SpaStepScope({
    required this.history,
    required super.notifier,
    required super.child,
  });

  final SpaHistoryDelegate history;
}

class _HistoryObserver extends NavigatorObserver {
  _HistoryObserver(
    this.changed, {
    required this.onPushed,
    required this.onPopped,
  });
  final void Function({bool replace}) changed;
  final void Function(Route<dynamic>, Route<dynamic>?) onPushed;
  final bool Function(Route<dynamic>, Route<dynamic>?) onPopped;
  final routes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.add(route);
    onPushed(route, previousRoute);
    // A modal sheet/dialog has no Activity URL of its own. Publishing its
    // Navigator push can accidentally replace a pending Activity history PUSH.
    if (route.settings.name != null) changed();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
    // CategorySheet closes its unnamed bottom sheet immediately before the
    // named CategorySheet Activity pops. Publishing this intermediate modal
    // pop sets `_pending` and prevents the Activity's native history.back(),
    // silently discarding the browser Forward entry.
    if (route.settings.name == null) return;
    // A parent modal Activity keeps its unnamed sheet route mounted while a
    // child Activity is above it. That modal is Navigator's previousRoute,
    // but browser history belongs to the nearest named Activity underneath.
    // Keep the existing local-PUSH/provenance guards in onPopped intact.
    Route<dynamic>? previousActivity;
    for (final candidate in routes.reversed) {
      if (candidate.settings.name != null) {
        previousActivity = candidate;
        break;
      }
    }
    if (!onPopped(route, previousActivity)) changed(replace: true);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
    if (route.settings.name != null) changed(replace: true);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = routes.indexOf(oldRoute!);
    if (index >= 0 && newRoute != null) routes[index] = newRoute;
    if (oldRoute.settings.name != null || newRoute?.settings.name != null) {
      changed(replace: true);
    }
  }
}
