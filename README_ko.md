# 시드 디자인 플러터

[영문 문서](README.md)

당근의 [시드 디자인](https://seed-design.io/)을 플러터로 옮긴 비공식 패키지입니다.

[웹 쇼케이스](https://kjm0202.github.io/seed_design/)에서 컴포넌트를 직접 써볼 수 있습니다.

## 개발 환경

- Flutter >= 3.47.0
- Dart >= 3.13.0
- `material_ui` >= 1.7.0

Flutter SDK 3.47.7에서 개발 및 테스트되었습니다.

## 설치

앱의 `pubspec.yaml`에 의존성을 추가합니다.

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

이 패키지는 별도로 분리된 머티리얼 패키지인 `material_ui`를 사용합니다. 앱에서도 `package:flutter/material.dart` 대신 아래 구문으로 가져와야 합니다.

```dart
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
```

## 테마 설정

앱에 밝은 테마와 어두운 테마를 등록합니다. 아래 예제는 기기의 화면 모드에 따라 테마를 바꾸고, 기본 머티리얼 문구를 한국어로 표시합니다.

```dart
MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  darkTheme: SeedThemeData.dark().toThemeData(),
  themeMode: ThemeMode.system,
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [Locale('ko')],
  home: const HomeScreen(),
);
```

색상과 글꼴 스타일은 다음처럼 꺼내 쓸 수 있습니다.

```dart
final colors = context.seedColor;
final typography = context.seedTypography;

Text(
  '동네 소식',
  style: typography.screenTitle.copyWith(color: colors.fg.neutral),
);
```

일부 화면만 다른 테마로 보여주려면 `SeedTheme`로 감싸면 됩니다.

```dart
SeedTheme(data: SeedThemeData.dark(), child: const PreviewScreen());
```

기존 앱의 테마에 적용할 때는 `withSeedDesign()`을 사용합니다. 기존 글꼴을 유지하며, `fontFamily`를 지정하면 해당 글꼴로 바뀝니다.

```dart
final theme = existingTheme.withSeedDesign();
final customFontTheme = existingTheme.withSeedDesign(fontFamily: 'MyFont');
```

화면 단위로 적용할 수도 있습니다.

```dart
const SeedMaterialBridge(child: ExistingScreen());
```

기존 앱도 `material_ui`를 사용해야 합니다. `SeedMaterialBridge`가 예전 머티리얼 타입을 변환해 주지는 않습니다.

## 버튼과 입력창

```dart
SeedButton(
  label: '채팅하기',
  variant: SeedButtonVariant.brandSolid,
  onPressed: () {},
);

SeedButton.iconOnly(
  icon: const Icon(Icons.add),
  semanticsLabel: '새 글 작성',
  onPressed: () {},
);

SeedField(
  label: '판매 가격',
  required: true,
  child: SeedTextInput(
    hintText: '가격을 입력해 주세요',
    keyboardType: TextInputType.number,
    onChanged: (value) {},
  ),
);
```

버튼은 내용에 맞춰 너비가 정해집니다. 부모의 너비를 채우려면 `isFullWidth: true`를 지정하세요. `onPressed: null`이나 `enabled: false`로 비활성화할 수 있고, `loading: true`이면 로딩 표시와 함께 클릭이 막힙니다.

아이콘만 있는 버튼에는 화면 읽기 프로그램이 용도를 안내할 수 있도록 `semanticsLabel`을 넣어주세요. 입력창에 직접 전달한 `TextEditingController`와 `FocusNode`는 사용한 쪽에서 해제해야 합니다.

다른 컴포넌트의 사용법은 [예제 코드](example/lib/tabs)에서 확인할 수 있습니다.

## 매너온도

```dart
const SeedMannerTempBadge(temperature: 36.5);

SeedMannerTemp(
  temperature: 36.5,
  emoteBuilder: (context, level) => Image.asset('assets/manner-$level.png'),
);
```

기본 배지는 온도만 표시합니다. 표정 이미지는 포함되어 있지 않으므로 `emoteBuilder`로 직접 넣어주세요. 시스템 이모지는 `showEmoji: true`, 게이지는 `showProgress: true`로 켤 수 있습니다.

## 예제 실행

```sh
cd example
flutter pub get
flutter run
```

## 테스트

```sh
flutter analyze
flutter test
cd example
flutter test
```

## 라이선스

이 패키지의 자체 구현에는 [MIT 라이선스](LICENSE)가 적용됩니다. SEED Design에서 가져오거나 수정한 부분에는 [Apache License 2.0](third_party/seed-design/LICENSE)이 적용되며, [원본 고지](third_party/seed-design/NOTICE)를 함께 제공합니다. 자세한 내용과 테스트용 글꼴의 출처는 [외부 자료 출처](THIRD_PARTY_NOTICES.md)에서 확인할 수 있습니다.

## 고지

이 패키지 및 개발자는 (주)당근마켓과 일체의 관련이나 제휴 관계가 없으며, SEED Design, Karrot, 당근마켓 등은 (주)당근마켓의 상표 또는 저작물입니다.
