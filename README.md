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
  seed_design: ^0.1.1
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

You can also apply the styles to a single screen:

```dart
const SeedMaterialBridge(child: ExistingScreen());
```

Existing apps also need to use `material_ui`. `SeedMaterialBridge` does not convert types from the old Material package.

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

Give icon-only buttons a `semanticsLabel` so screen readers can describe their action. If you pass a `TextEditingController` or `FocusNode` to an input, you are responsible for disposing of it.

See the [example code](example/lib/tabs) for other components.

## Manner temperature

```dart
const SeedMannerTempBadge(temperature: 36.5);

SeedMannerTemp(
  temperature: 36.5,
  emoteBuilder: (context, level) => Image.asset('assets/manner-$level.png'),
);
```

The badge shows only the temperature by default. Emote images are not included; supply your own through `emoteBuilder`. Set `showEmoji: true` to use system emoji, or `showProgress: true` to show the gauge.

## Run the example

```sh
cd example
flutter pub get
flutter run
```

## Tests

```sh
flutter analyze
flutter test
cd example
flutter test
```

## License

The original Flutter implementation is licensed under [MIT](LICENSE). Portions adapted from SEED Design are subject to [Apache License 2.0](third_party/seed-design/LICENSE), with the [upstream notice](third_party/seed-design/NOTICE) included. See [third-party notices](THIRD_PARTY_NOTICES.md) for details and test font credits.

## Disclaimer

This package and its developer are not affiliated with (주)당근마켓 (Karrot Corp.). SEED Design, Karrot, Danggn, and all related trademarks and copyrights belong to (주)당근마켓 (Karrot Corp.).
