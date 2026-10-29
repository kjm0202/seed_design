# seed_design

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
  seed_design: ^1.0.0
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

버튼의 기본 variant는 `brandSolid`, 배지는 `solid`입니다. 다른 외형을 유지하려면 variant를 명시하세요. 로딩 중에도 동작해야 하는 버튼에는 `disableOnLoading: false`를 지정하세요. 배지의 `action`에 `SeedBadgeAction`을 넣고 `semanticsLabel`과 `onPressed`를 지정하면 키보드 조작과 버튼 의미론을 제공합니다.

`showSeedAlertDialog`는 기본적으로 명시적인 액션으로 닫습니다. 배경 탭으로 닫으려면 `barrierDismissible: true`를 지정하세요. 기본 액션은 세로로 배치되며 긴 내용은 스크롤됩니다.

아이콘만 있는 버튼에는 화면 읽기 프로그램이 용도를 안내할 수 있도록 `semanticsLabel`을 넣어주세요. 입력창에 직접 전달한 `TextEditingController`와 `FocusNode`는 사용한 쪽에서 해제해야 합니다.

API 이름은 각 컴포넌트의 공식 React prop을 기준으로 합니다. Select는 단일·다중 선택 모두 리스트형 `value/defaultValue/onValueChange`를 사용합니다. non-null 값은 부모가 관리하며, 빈 선택도 부모가 관리하려면 `controlled: true`를 지정합니다. default 값은 내부 상태를 한 번 초기화합니다. 텍스트·첨부 입력에는 컨트롤러 또는 값과 초깃값 중 한 방식만 전달합니다.

다른 컴포넌트의 사용법은 [예제 코드](example/lib/stackflow_spa)에서 확인할 수 있습니다.

## 상태·콘텐츠를 포함한 UI

`SeedDatePicker`는 단일·범위·다중 선택과 월·두 달·주·연속 보기를 지원합니다. 연속 보기에는 `height`, `minHeight`, `maxHeight` 중 하나가 필요합니다. `SeedDatePickerController`로 선택을 바꾸지 않고 날짜 이동·포커스를 제어할 수 있습니다.

`SeedSelect(multiple: true)`, `SeedSlider.range`, `SeedTextField`, `SeedFieldButton`, `SeedAccordion`, `SeedTabsView`, `SeedChipTabsView`로 상태와 콘텐츠를 함께 구성할 수 있습니다. 오버레이 trigger는 개폐 상태·배치·포커스·닫기 정책을 제공합니다. Stackflow SPA 예제에서 컴포넌트별 화면과 게시글 탐색 데모를 확인할 수 있습니다.

첨부는 UI만 제공합니다. `SeedAttachmentDisplayField`/`SeedAttachmentController`에 외부 항목과 진행률·상태를 전달하세요. 실제 파일 선택·OS drop·파일 검사·업로드는 앱이 담당하며 이 패키지는 수행하지 않습니다.

`SeedAttachmentDisplayField`는 공식처럼 기본 최대 1개이며, 여러 항목이 필요하면 `maxEntries: 10`을 지정합니다. `enabled: false`는 추가·재시도·재정렬을 막되 기존 항목의 삭제는 허용합니다. 삭제도 막으려면 `readOnly: true`를 지정하세요. 개별 항목의 제한은 계속 적용됩니다.


## 예제 실행

공식 SEED Design의 Stackflow SPA를 Flutter로 옮긴 예제입니다. 컴포넌트별 화면과 게시글 목록·필터·상세 데모를 제공합니다.

```sh
cd example
flutter pub get
flutter run
```

## 테스트

소스 저장소를 내려받은 뒤 테스트를 실행합니다.

```sh
flutter analyze
flutter test
cd example
flutter test
# 실행 중인 iOS/Android 시뮬레이터에서 검증:
flutter test integration_test/stackflow_spa_navigation_test.dart -d <device-id>
```

## 라이선스

이 패키지의 자체 구현에는 [MIT 라이선스](LICENSE)가 적용됩니다. SEED Design에서 가져오거나 수정한 부분에는 [Apache License 2.0](third_party/seed-design/LICENSE)이 적용되며, [원본 고지](third_party/seed-design/NOTICE)를 함께 제공합니다. 자세한 내용과 테스트용 글꼴의 출처는 [외부 자료 출처](THIRD_PARTY_NOTICES.md)에서 확인할 수 있습니다.

## 고지

이 패키지 및 개발자는 (주)당근마켓과 일체의 관련이나 제휴 관계가 없으며, SEED Design, Karrot, 당근마켓 등은 (주)당근마켓의 상표 또는 저작물입니다.
