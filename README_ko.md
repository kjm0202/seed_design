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
  seed_design: ^2.1.0
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

## Material 앱에서 점진적으로 이전하기

기존 `MaterialApp`, `Scaffold`, Router와 필요한 Material 위젯을 유지하면서 테마부터 적용하세요. 기존 버튼 padding·모양, 입력 padding 같은 component theme 설정을 보존하려면 아래 옵션을 사용합니다. 앱이 지정한 필드는 그대로 유지되고 지정하지 않은 필드만 SEED 값으로 채워지므로, dialog의 `insetPadding`만 바꾼 경우에도 SEED dialog 모양과 색상은 유지됩니다. 기본값은 SEED component theme으로 교체하는 `false`입니다.

```dart
final light = existingLightTheme.withSeedDesign(preserveComponentThemes: true);
final dark = existingDarkTheme.withSeedDesign(preserveComponentThemes: true);
// 화면 단위에서도 동일한 옵션을 사용할 수 있습니다.
SeedMaterialBridge(preserveComponentThemes: true, child: ExistingScreen());
```

Material component theme은 Material 위젯에 적용됩니다. SEED 위젯은 SEED 토큰과 각 위젯의 props로 조정합니다.

| 기존 위젯/동작 | 이전 방법 |
| --- | --- |
| `TextField` | `SeedTextInput`: controller, `hintText`, `onSubmitted` 유지 |
| `TextFormField` | `SeedTextField`: `defaultValue`, `placeholder`, validator/onSaved/onReset, `onFieldSubmitted` |
| `DropdownButtonFormField` | `SeedSelectFormField`: 검증·저장·reset을 지원하며 단일 선택도 리스트 값을 사용 |
| `TabBar` + `TabBarView` | `SeedTabBar` + 기존 `TabBarView`: controller 또는 `DefaultTabController`로 양방향 연결 |
| `AppBar` | `SeedTopNavigation`: Drawer/뒤로가기 자동 연결, `bottom: SeedTabBar(...)` 지원 |
| `SnackBar` | `showSeedSnackbar`: 액션 종료 사유는 `action`, 액션이 있으면 기본 유지. 시간 제한이 필요하면 `persist: false` |
| `FloatingActionButton` | `SeedFloatingActionButton`: 기존 `heroTag`, `tooltip`을 명시적으로 전달 |
| 고급 Material 기능 | 기존 Material 위젯을 SEED 테마 아래 유지하고 필요한 부분부터 교체 |

폼에는 `SeedTextField`와 `SeedSelectFormField`를 사용하세요. 예를 들어 기존 `Form`의 자식으로 다음 필드를 배치할 수 있습니다.

```dart
SeedTextField(
  label: '이메일',
  autofillHints: const [AutofillHints.email],
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.done,
  validator: (value) => value?.contains('@') == true ? null : '이메일 확인',
  onFieldSubmitted: (_) => submit(),
  onSaved: (value) => saveEmail(value),
);

SeedSelectFormField<String>(
  label: '연락 방법',
  groups: const [SeedSelectGroup(items: [
    SeedSelectItem(value: 'chat', label: '채팅'),
    SeedSelectItem(value: 'email', label: '이메일'),
  ])],
  validator: (values) => values == null || values.isEmpty ? '선택해 주세요' : null,
  onSaved: (values) => saveContact(values),
);
```

`SeedTextField.errorMessage`와 `forceErrorText`는 `Form.validate()`를 실패시키며, 둘 다 지정하면 `forceErrorText`가 우선합니다. `maxGraphemeCount` 초과도 검증에 반영되지만 원문은 유지합니다. 입력 자체를 제한하려면 `enforceMaxLength: true`를 지정하세요. `required`는 표시·접근성 정보이므로 필수 검증은 validator로 작성합니다. `SeedSelect` 자체는 폼에 등록되지 않으므로 폼에서는 전용 `SeedSelectFormField`를 사용하세요.

폼에 등록되는 위젯은 `SeedTextField`, `SeedSelectFormField`, `SeedFormField`뿐이며, 다른 SEED 입력은 `Form.reset()`·`save()`의 영향을 받지 않습니다. 다른 입력을 검증·저장·초기화하려면 Material `Checkbox`를 `FormField`로 감싸듯이 `SeedFormField`로 감싸세요.

```dart
SeedFormField<bool>(
  initialValue: false,
  validator: (agreed) => agreed == true ? null : '약관에 동의해 주세요',
  onSaved: (agreed) => saveConsent(agreed),
  builder: (field) => SeedCheckbox(
    label: '약관 동의',
    checked: field.value ?? false,
    onCheckedChange: field.didChange,
  ),
);
```

입력은 autofill, IME 액션, 편집 완료, 자동 수정·대문자화, 외부 탭, undo, context menu 등의 Flutter 옵션을 전달합니다. `restorationId`와 앱의 `restorationScopeId`를 지정하면 내부 텍스트 컨트롤러가 복원됩니다. 외부 컨트롤러의 저장·복원·해제는 앱이 담당합니다.

Dialog/BottomSheet helper는 `child` 또는 `builder` 중 하나를 받으며 `useRootNavigator`, `routeSettings`, `requestFocus`를 지원합니다. BottomSheet의 `constraints`로 기본 최대 폭 480을 변경할 수 있습니다. 일반 provider가 필요한 경우 해당 Navigator 위에 provider를 설치하세요. 테마와 SEED 문구 override는 자동 캡처되지만 일반 provider를 복제하지는 않습니다.

기본 문구는 앱 locale을 따릅니다. 한국어·영어 SEED 문구와 Material 공통 번역을 제공하고, 다른 번역은 다음처럼 지정할 수 있습니다. 명시한 위젯 문구가 우선합니다. 중첩된 `SeedLocalizations`는 생략한 문구를 바깥 설정에서 이어받으며, 대화상자에도 이 설정이 전달됩니다.

```dart
SeedLocalizations(
  labels: const {SeedLabel.clearInput: 'Effacer', SeedLabel.selectPlaceholder: 'Choisir'},
  child: MyScreen(),
);
```

DatePicker와 TimePicker는 기본으로 앱의 로케일을 따릅니다. 다른 언어를 사용하는 앱에서 한국어 형식을 유지하려면 `locale: const Locale('ko', 'KR')`를 지정하세요.

Switch/Checkbox의 콜백을 null로 만드는 것과 SEED의 비활성화는 다릅니다. 권한·로딩에 따라 잠그려면 `enabled: false`를 명시하세요. SEED Slider는 기본 0~100, step 1입니다. 기존 연속 0~1 Slider 동작이 필요하면 Material Slider를 유지하고, SEED로 교체할 때는 범위·step/divisions를 명시하세요. 이 기본값은 공식 SEED 계약을 유지합니다.

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

## Dart API 문서

공개한 모든 타입·생성자·속성·콜백·메서드에 Dartdoc 주석을 작성했습니다.
기본값, 상태 소유권, Flutter 전용 기능과 호환 별칭도 설명합니다.
소스 저장소에서 HTML API 문서를 생성하고 확인하려면 다음 명령을 사용합니다.

```sh
dart analyze lib
dart doc --validate-links .
```

출력 위치는 `doc/api/`입니다. 검색과 탐색 기능은 HTTP 서버로 해당 폴더를
제공해야 동작합니다. 생성물은 Git에 추가되지 않습니다.

## 테스트

소스 저장소를 내려받은 뒤 테스트를 실행합니다.

```sh
flutter analyze
flutter test
cd example
flutter test
```

## 라이선스

이 패키지의 자체 구현에는 [MIT 라이선스](https://github.com/kjm0202/seed_design/blob/master/LICENSE)가 적용됩니다. SEED Design에서 가져오거나 수정한 부분에는 [Apache License 2.0](https://github.com/kjm0202/seed_design/blob/master/third_party/seed-design/LICENSE)이 적용되며, [원본 고지](https://github.com/kjm0202/seed_design/blob/master/third_party/seed-design/NOTICE)를 함께 제공합니다. 자세한 내용과 테스트용 글꼴의 출처는 [외부 자료 출처](https://github.com/kjm0202/seed_design/blob/master/THIRD_PARTY_NOTICES.md)에서 확인할 수 있습니다.

## 고지

이 패키지 및 개발자는 (주)당근마켓과 일체의 관련이나 제휴 관계가 없으며, SEED Design, Karrot, 당근마켓 등은 (주)당근마켓의 상표 또는 저작물입니다.
