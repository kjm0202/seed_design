# SEED Design for Flutter

[한국어](README_ko.md)

An unofficial Flutter port of Karrot(also known as Danggn in Korea)’s [SEED Design](https://seed-design.io/).

[Try the web showcase](https://kjm0202.github.io/seed_design/) in your browser.

## Requirements

- Flutter 3.47.0 or later
- Dart 3.13.0 or later
- `material_ui` 1.7.0 or later

Tested on Flutter 3.47.0 and 3.47.7.

## Installation

Add these dependencies to your app’s `pubspec.yaml`.

```yaml
dependencies:
  flutter:
    sdk: flutter
  material_ui: ^1.7.0
  seed_design: ^1.0.0
```

```sh
flutter pub get
```

This package uses the separate Material package, `material_ui`. Your app should use these imports instead of `package:flutter/material.dart`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
```

## Themes

Register the light and dark themes on your app. This example follows the device’s appearance setting and uses English for built-in Material labels.

```dart
MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  darkTheme: SeedThemeData.dark().toThemeData(),
  themeMode: ThemeMode.system,
  locale: const Locale('en'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [Locale('en')],
  home: const HomeScreen(),
);
```

Access colors and text styles through the build context:

```dart
final colors = context.seedColor;
final typography = context.seedTypography;

Text(
  'Neighborhood news',
  style: typography.screenTitle.copyWith(color: colors.fg.neutral),
);
```

Wrap part of your app in `SeedTheme` to give it a different theme.

```dart
SeedTheme(data: SeedThemeData.dark(), child: const PreviewScreen());
```

To apply SEED styles to an existing theme, use `withSeedDesign()`. It keeps the existing font unless you supply `fontFamily`.

```dart
final theme = existingTheme.withSeedDesign();
final customFontTheme = existingTheme.withSeedDesign(fontFamily: 'MyFont');
```

An explicit `fontFamily` also overrides the typography of a supplied `seedTheme`,
while retaining its fallback fonts. A supplied `seedTheme` controls brightness;
the `brightness` argument is used when creating a default SEED theme.

You can also apply the styles to a single screen:

```dart
const SeedMaterialBridge(child: ExistingScreen());
```

Existing apps also need to use `material_ui`. `SeedMaterialBridge` does not convert types from the old Material package.

`withSeedDesign()` and `SeedMaterialBridge` apply themes; replace widgets and
adapt their arguments manually using `SeedMigration.componentMapping`:

| Material widget | Migration |
| --- | --- |
| `TextField` | `SeedTextInput`; preserve the controller or use `defaultValue` |
| `TextFormField` | `SeedTextField`; retain `validator`, `onSaved` and `Form.reset()` |
| `Tooltip` | `SeedHelpBubbleTooltip(title: message, child: child)` for hover and focus behavior |
| `LinearProgressIndicator` | Keep the Material widget under the SEED theme, retaining `value` and semantics |

`SeedField` provides field layout around an input. `SeedHelpBubble` is a bubble
card. `SeedSkeleton` is a loading placeholder. These have different behavior
from the form field, tooltip and numeric progress widgets above.

The themed Material Checkbox, Switch and Radio use the same brand selection
colors as the default Seed controls, including contrasting checked marks.

## Buttons and inputs

```dart
SeedButton(
  label: 'Chat',
  variant: SeedButtonVariant.brandSolid,
  onPressed: () {},
);

SeedButton.iconOnly(
  icon: const Icon(Icons.add),
  semanticsLabel: 'Create a post',
  onPressed: () {},
);

SeedField(
  label: 'Price',
  required: true,
  child: SeedTextInput(
    hintText: 'Enter a price',
    keyboardType: TextInputType.number,
    onChanged: (value) {},
  ),
);
```

Buttons fit their content by default. Set `isFullWidth: true` to fill the parent’s width. Use `onPressed: null` or `enabled: false` to disable a button. Setting `loading: true` shows a loading indicator and prevents activation.

Buttons default to `brandSolid`; badges default to `solid`. Use an explicit variant to retain another appearance. Set `disableOnLoading: false` when a loading button must remain actionable. `SeedBadgeAction` adds keyboard activation and button semantics to a badge’s `action` slot; provide its `semanticsLabel` and `onPressed`.

`showSeedAlertDialog` requires an explicit action by default. Set `barrierDismissible: true` to allow dismissal by tapping the backdrop. Its default actions are stacked vertically and long content scrolls.

Give icon-only buttons a `semanticsLabel` so screen readers can describe their action. If you pass a `TextEditingController` or `FocusNode` to an input, you are responsible for disposing of it.

Use the official React prop names for each component. Select uses list-valued `value/defaultValue/onValueChange` for single and multiple selection. Non-null values are parent-controlled; use `controlled: true` to control an empty selection. Default values initialize local state once. Supply either a text/attachment controller or values and defaults.

See the [example code](example/lib/stackflow_spa) for other components.

## Stateful UI and React feature counterparts

Use `SeedDatePicker` for single/range/multiple selection and month/two-month/week/continuous layouts; continuous calendars require `height`, `minHeight` or `maxHeight`. `SeedDatePickerController` navigates and focuses dates without selecting them.

`SeedSelect(multiple: true)`, `SeedSlider.range`, `SeedTextField`, `SeedFieldButton`, `SeedAccordion`, `SeedTabsView` and `SeedChipTabsView` provide their corresponding state and content behavior. Overlay trigger widgets provide controlled opening, placement, focus and dismissal policies. The Stackflow SPA example groups component demos into activity routes and includes an article browsing demo.

Attachments are UI-only. Supply entries and update progress/status through `SeedAttachmentDisplayField` or `SeedAttachmentController`; handle actual selection and uploading in your app. This package does not select, receive, validate or upload files.

`SeedAttachmentDisplayField` defaults to one entry, matching React; set `maxEntries: 10` for multiple attachments. `enabled: false` blocks adding, retrying and reordering, while allowing removal of existing entries. Use `readOnly: true` to prevent removal as well; per-entry restrictions still apply.


## Run the example

The example runs the Flutter port of SEED Design’s Stackflow SPA, with a component activity catalog and article/filter/detail demo.

```sh
cd example
flutter pub get
flutter run
```

## Tests

Run the test suites from a source checkout:

```sh
flutter analyze
flutter test
cd example
flutter test
# Run against a booted iOS Simulator or Android Emulator:
flutter test integration_test/stackflow_spa_navigation_test.dart -d <device-id>
```

## License

The original Flutter implementation is licensed under [MIT](LICENSE). Portions adapted from SEED Design are subject to [Apache License 2.0](third_party/seed-design/LICENSE), with the [upstream notice](third_party/seed-design/NOTICE) included. See [third-party notices](THIRD_PARTY_NOTICES.md) for details and test font credits.

## Disclaimer

This package and its developer are not affiliated with (주)당근마켓 (Karrot Corp.). SEED Design, Karrot, Danggn, and all related trademarks and copyrights belong to (주)당근마켓 (Karrot Corp.).
