import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as seed_material;
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_paths.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

// These routes exercise intentional browser/Stackflow bugs, E2E behaviors, or
// legacy IACVT styling; they are not part of the supported Flutter SPA tour.
const _excludedActivities = <String>{
  'ActivityPopTest',
  'ActivityAnimateFalseTest',
  'ActivityCodegenTest',
  'ActivityPerfCheck',
  'ActivityE2EImageBehavior',
  'ActivityE2ETextareaAutoresizeScroll',
  'ActivityIacvtLeak',
  'ActivityIacvtSidePanel',
  'ActivityIacvtOverlay',
  'ActivityIacvtMargin',
  'ActivityIacvtExperiment',
  'ActivityMixedVersionTest',
  'ActivityNotFound',
};

Object? _argumentsFor(String activity) => switch (activity) {
  'ActivityDetail' => <String, Object>{
    'title': 'Route smoke test',
    'body': 'Opened through Navigator.pushNamed.',
  },
  'ActivityDemoArticleDetail' => 1,
  'ActivityTransitionStyle' => <String, String>{
    'transitionStyle': 'slideFromRightIOS',
  },
  _ => null,
};

void main() {
  final routes = spaActivityPaths.entries
      .where((entry) => !_excludedActivities.contains(entry.key))
      .toList(growable: false);

  test('route names and paths are unique; exclusions are explicit', () {
    expect(spaActivityPaths.keys.toSet(), containsAll(_excludedActivities));
    expect(
      spaActivityPaths.values.toSet().length,
      spaActivityPaths.length,
      reason: 'Each supported activity must have a unique browser path.',
    );
    expect(routes, isNotEmpty);
    expect(routes.length, spaActivityPaths.length - _excludedActivities.length);
  });

  const brightness = Brightness.light;
  for (final route in routes) {
    testWidgets(
      '${route.key} opens ${route.value} without errors or 404 ($brightness)',
      (tester) async {
        // Size the app like a phone. Avoid pumpAndSettle: some demo activities
        // intentionally animate, schedule delayed work, or open modal routes.
        tester.view.physicalSize = const Size(440, 960);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pump();

        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pushNamed(route.value, arguments: _argumentsFor(route.key));

        // A fixed, short window runs the route transition and its post-frame
        // overlay opener without waiting for demo timers or looping animations.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: '${route.key} (${route.value}) threw while building.',
        );
        expect(
          find.text('페이지를 찾지 못했습니다.', skipOffstage: false),
          findsNothing,
          reason: '${route.key} (${route.value}) fell through to the 404 page.',
        );
        expect(
          find.byType(SeedTopNavigation, skipOffstage: false),
          findsWidgets,
          reason:
              '${route.key} (${route.value}) did not create the SPA app bar.',
        );
        for (final element
            in find.byType(SeedTopNavigation, skipOffstage: false).evaluate()) {
          expect(
            Theme.of(element).brightness,
            brightness,
            reason: '${route.key} lost the stock Flutter theme.',
          );
          expect(
            seed_material.Theme.of(element).brightness,
            brightness,
            reason: '${route.key} lost the SEED theme.',
          );
          expect(
            Theme.of(element).colorScheme.surface,
            seed_material.Theme.of(element).colorScheme.surface,
            reason: '${route.key} has mismatched surface colors.',
          );
        }

        // Release route-owned controllers and timers before the next activity.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${route.key} (${route.value}) failed during disposal.',
        );
      },
    );
  }
}
