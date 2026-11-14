## Unreleased

### 브레이킹 체인지

#### 소스 호환성

- **List 행**의 `showDivider`는 `SeedListItem`, `SeedListLinkItem`, `SeedCheckListItem`, `SeedRadioListItem`, `SeedSwitchListItem`에서 `bool?`로 노출됩니다. null이면 `SeedList.showDividers`를 따르고, 단독 행에서는 false가 됩니다. 이 속성을 읽는 코드는 null을 처리하고, 필요하면 부모 목록의 설정을 사용하세요.
- **위젯 타입**이 `SeedToggleButton`(`StatelessWidget` → `StatefulWidget`)과 `SeedResponsivePair`(`StatelessWidget` → `MultiChildRenderObjectWidget`)에서 바뀌었습니다. 이 위젯을 담거나 반환하기만 하는 변수와 반환 타입에는 `Widget`을 사용하세요. `SeedAspectRatio`는 이제 `AspectRatio`를 상속하지 않고 내부에서 사용합니다. 상속받던 `aspectRatio` getter 대신 `ratio`를 사용하고, 해당 타입이 필요한 곳에는 Flutter의 `AspectRatio`를 직접 사용하세요.
- **`SeedInputButtonSize`**에 `large`가 추가됩니다. 모든 case를 나열한 switch에는 `large` case를 추가하세요. `small`은 `medium`과 같은 40px 크기를 가진 별도의 사용 중단 예정 enum 값으로 남습니다.
- **`SeedBgColors`**를 생성자로 직접 호출하는 코드는 `neutralSolidMuted`와 `neutralSolidMutedPressed`를 지정해야 합니다.
- **선택기 필드**가 두 곳에서 nullable이 됩니다. 수량 선택기의 초기값은 `picker.defaultValue ?? picker.min`으로 읽은 뒤 범위에 맞춰 보정하세요. 실제 정렬은 `SeedSliderMarker.resolveAlign(min, max)`로 확인하세요. 마커 정렬을 생략하면 최솟값에서는 시작, 최댓값에서는 끝, 그 외에는 가운데로 정해집니다.
- **`SeedDatePickerLayout`**에 `twoWeeks`가 추가됩니다. 이 enum을 빠짐없이 다루는 switch에 `twoWeeks` case를 추가하세요.

#### 기본값과 동작

- **버튼과 필드.** `SeedButton.textColor`는 `enabled: true`인 ghost 버튼에만, `fontWeight`는 ghost 버튼에만 적용됩니다. 기존 52px `medium` 크기가 필요하면 `SeedInputButtonSize.large`를 사용하세요. 새 `medium`은 40px이고 기본값은 `large`(52px)로 유지됩니다. 지우기 버튼을 유지하려면 `SeedTextInput`이나 `SeedTextField`에 `clearable: true`를 지정하세요.
- **폼 검증과 초기화.** `SeedTextField`의 서버 오류와 글자 수 제한 위반이 `FormState.validate()`에 반영됩니다. 폼을 다시 제출할 수 있게 되면 서버 오류를 지우세요. 제어되지 않는 `SeedRadioGroup`과 `SeedQuantityPicker`는 더 이상 상위 폼에 등록되지 않습니다. 검증, 저장, 초기화를 폼이 맡아야 한다면 `SeedFormField`로 감싸세요.
- **List와 선택 컨트롤.** 구분선은 기본적으로 숨겨집니다. 유지하려면 목록에 `showDividers: true`를, 행에 `showDivider: true`를 지정하세요. 단독 Checkbox, Radio, Switch는 공식 시각 크기와 44px 터치 영역을 사용하고, 라벨이 있는 행은 공식 최소 높이를 사용합니다. 이 컨트롤과 체크·라디오·스위치 목록 행은 Space로 토글하며, Enter로는 토글되지 않습니다.
- **레이아웃.** `SeedFloat.offset` 기본값이 사방 16px에서 0으로 바뀝니다. `SeedResponsive.largeBreakpoint`는 1024에서 1280으로 바뀝니다. 이전 레이아웃을 유지하려면 이전 값을 명시하세요. 이전 저작권 문구를 표시하려면 `SeedFooter.copyright`를 직접 지정하세요. Grid 자동 배치는 희소 배치를 사용합니다. `rows`만 지정하면 행 방향 흐름은 열 하나를 사용합니다. 이전 배치에 의존하던 레이아웃에는 열이나 명시적인 `row`·`column` 위치를 지정하세요.
- **선택기 로케일.** DatePicker와 TimePicker는 `locale`을 생략하면 앱의 로케일을 따르고, 사용할 수 있는 로케일이 없으면 영어(`en_US`)로 표시합니다. 다른 언어를 사용하는 앱에서 한국어 형식을 유지하려면 `locale: const Locale('ko', 'KR')`를 지정하세요. 공개 `locale` 속성은 이제 null일 수 있습니다.
- **첨부와 선택기.** 이전의 첨부 한도 10개를 유지하려면 `SeedAttachmentInput`에 `maxCount: 10`을 전달하세요. 기본값은 이제 1입니다. 수량을 생략하면 `min`에서 시작합니다. 이전 초기값을 유지하려면 `defaultValue: 1`을 전달하세요. 선택기의 범위가 적용됩니다. 현재 선택된 날짜를 다시 선택해도 `onValueChange`가 호출되지 않습니다. TimePicker는 분이 정확히 중간일 때 올림하므로, 10분 간격에서 10:05는 10:10이 됩니다.
- **Select.** 기본 팝업은 앵커 오버레이와 8px 메뉴 간격을 사용합니다. 간격 0을 유지하려면 `menuOffset: Offset.zero`를 지정하세요. 기본값이 아닌 `menuAlignment`는 계속 `MenuAnchor`를 사용합니다. 기본 팝업을 `MenuAnchor` 구현으로 찾는 위젯 테스트는 수정해야 합니다.
- **다중 선택 Select의 값 표시.** `SeedSelect(multiple: true)` 트리거는 삭제 가능한 칩 대신 React의 `SelectValue`처럼 선택된 라벨을 `, `로 이어 붙여 표시합니다. 텍스트를 바꾸려면 `formatValue`를, 칩이나 다른 사용자 지정 콘텐츠를 표시하려면 `valueBuilder`를 사용하세요.
- **Menu 포커스.** Tab은 닫기를 요청하고 포커스를 메뉴 밖으로 옮깁니다. 메뉴에서 Shift+Tab을 누르면 메뉴를 연 채로 트리거로 돌아갈 수 있습니다. 키보드 핸들러와 테스트에서 이 포커스 전환을 고려하세요.
- **Material Snackbar.** `showSeedSnackbar`는 액션을 선택했을 때 `hide` 대신 `SnackBarClosedReason.action`을 전달합니다. 이전 사유로 분기하는 `ScaffoldFeatureController.closed` 소비자는 수정해야 합니다. 액션 라벨과 콜백이 모두 있는 스낵바는 기본적으로 사라지지 않습니다. 시간 제한을 유지하려면 `persist: false`를 전달하세요.
- **SEED Snackbar 컨트롤러.** 현재 항목이 퇴장한 뒤 다음 항목이 등장합니다. `SeedSnackbarController.show`의 `removeDelay` 기본값은 200ms이며, 현재 항목의 `onClose`는 제거된 뒤에 호출됩니다. 제거 시점에 의존하는 로직은 이 콜백으로 옮기세요.
- **내비게이션.** `SeedTabs.fill`의 기본값은 true입니다. 탭의 고유 너비를 유지하려면 `fill: false`를 전달하세요. 적응형 `SeedTopNavigation`은 iOS에서만 제목을 가운데 정렬하고, 기본 뒤로 가기 동작에 쉐브론 아이콘을 사용합니다. 이전 모습이 필요하면 `centerTitle`을 지정하거나 `leading`을 제공하세요. 이제 바가 Drawer와 EndDrawer 동작을 자동으로 추론할 수 있습니다. 버튼을 직접 제어하려면 `leading`과 `actions`를 명시하고, 추론을 끄려면 `automaticallyImplyLeading: false`를 지정하세요. 문자열 제목과 부제목은 계속 주변 텍스트 배율을 1.0–1.2로 제한합니다. 다른 배율을 쓰려면 `titleTextScaler`를 전달하세요.
- **SEED 3.3.0 색상.** `bg.neutralWeakAlpha`와 pressed 색이 `gray-alpha-200/300`을, `stroke.neutralWeak`가 반투명 `gray-alpha-400`을 사용합니다. `neutralOutline`·`brandOutline` 버튼, neutral outline Badge, outline Chip, ReactionButton, 비활성 square Checkbox의 외곽선이 `stroke.neutralMuted`에서 `stroke.neutralWeak`로 바뀝니다. 이 색을 불투명 값으로 비교하는 테스트를 수정하세요.
- **Tabs reveal.** 선택한 탭이 스크롤 가장자리 16px 안에 있으면 16px 여백이 남도록 스크롤합니다. ChipTabs의 reveal 상자는 8px 간격을 포함하지 않습니다.
- **상단 내비게이션 텍스트 버튼.** 라벨이 시스템 글자 배율을 1.0~1.2 범위에서 따르고, 버튼이 느슨한 제약의 슬롯을 채우지 않고 라벨 크기에 맞춰집니다.
- **첨부 순서 변경.** 이동할 수 없는 항목(비활성·읽기 전용)은 이동 접근성 액션을 노출하지 않습니다. 키보드 순서 변경은 항목을 임시 위치에 보여 주고 시작·취소·놓기를 안내합니다. 목록은 더 이상 Material `ReorderableListView`가 아니므로, 그 타입으로 목록을 찾는 테스트를 수정하세요. RTL에서 트리거가 있으면 시작 쪽 padding이 트리거 앞에 놓입니다.
- **접힌 사이드 내비게이션.** flyout이 `SeedNavigationMenu` 기반 disclosure가 됩니다. hover는 200ms 뒤 열리고 100ms 뒤 닫히며, hover와 마우스 클릭은 포커스를 옮기지 않고, `onTap`이 없는 하위 항목도 활성 상태를 유지합니다. 선택된 하위 항목의 배경 강조는 없어집니다.
- **DatePicker.** continuous가 아닌 레이아웃에서 표시 구간이 바뀌면 새 날짜 줄이 20px 밀려 들어오며 나타납니다. 동작 줄이기 설정에서는 페이드만 적용합니다.
- **DatePicker 범위.** `firstDate`, `lastDate`, `monthRange`, `yearRange` 중 여러 개를 지정하면 하나를 우선하지 않고 모두가 허용하는 가장 좁은 범위를 사용합니다. multiple 모드에서 날짜를 해제할 때도 `constraints`를 통과해야 합니다. `seedMaxSelectionCount`는 해제를 항상 허용합니다.
- **사이드 패널 스와이프.** `SeedSidePanel`을 스와이프해 닫으면 `outside` 대신 `SeedOverlayDismissReason.drag`를 전달합니다. 이전 사유로 분기하는 핸들러를 수정하세요.
- **Slider 값 라벨.** 기본 라벨은 소수 값을 소수점 한 자리로 반올림하지 않고 그대로 표시하므로, 0.25가 더 이상 0.3으로 표시되지 않습니다. 고정된 형식이 필요하면 `valueFormatter`를 사용하세요.
- **HelpBubble 포커스.** `SeedHelpBubbleTrigger`는 포커스가 콘텐츠를 벗어나면 닫힙니다. 열린 상태를 유지하려면 `closeOnInteractOutside: false`를 지정하세요.

### 추가 및 사용 중단 예정 API

- `SeedLocalizations`로 로케일을 따르고 재정의할 수 있는 라벨을 `SeedLabel` 키로 추가합니다. 생략한 라벨은 로케일을 따르고, 명시한 문자열이 우선합니다.
- Material 브리지에 선택형 `preserveComponentThemes`를 추가합니다. 기본값은 false입니다. 활성화하면 지정한 Material 컴포넌트 테마 필드가 우선하고 SEED가 나머지 필드를 채웁니다.
- 검증, 저장, 초기화, 복원을 지원하는 `SeedSelectFormField`와 Material `TabController`·`TabBarView`와 연동하는 `SeedTabBar`를 추가합니다. 영어·한국어 마이그레이션 가이드도 추가합니다.
- 리딩과 트레일링 액션 사이를 채우는 사용자 지정 콘텐츠용 `SeedTopNavigation.slot`을 추가합니다. 제목·부제목 입력과 별도로 사용하세요. 내비게이션 바에 `bottom`, `titleTextScaler`, `automaticallyImplyLeading`을, `SeedFloatingActionButton`에 선택적인 Hero 태그와 툴팁을 추가합니다.
- 텍스트 입력의 자동 완성, IME, 편집, 복원 옵션을 추가합니다. `SeedFormField`에 `forceErrorText`와 `restorationId`를, `SeedInputButton`에 `showDefaultSuffix`와 `contentScale`을, `SeedFieldButton`에 칩과 일반 텍스트 중 표시 방식을 고르는 `showValueChips`를 추가합니다.
- Field, TextInput, InputButton, Select, QuantityPicker에 `invalid`를 추가하고, 해당하는 `isInvalid`, `hasError`, `isError` 입력은 사용 중단 예정으로 표시합니다. Field에 `description`을, TextInput에 `placeholder`를 추가하며, `helperText`와 `hintText`는 호환 입력으로 유지합니다.
- ToggleButton에 `pressed`, `defaultPressed`, `onPressedChange`를, ContextualFloatingButton·Checkbox·Checkmark에 `variant`를 추가합니다. 기존 `selected`와 `onSelectedChanged`, `tone`, `shape` 입력은 사용 중단 예정 별칭으로 계속 사용할 수 있습니다.
- Checkbox, Radio, Switch에 `invalid`와 `required`를 추가합니다. TextField, FieldButton, Select, Slider, RadioGroup에 `labelWeight`를, Field에 `indicatorText`를, TextField·첨부 필드·Slider에 `indicator`를 추가합니다. RadioGroup과 Slider에 `showRequiredIndicator`를, Fieldset에 `required`를, 첨부 필드에 `labelWeight`를, RadioListItem에 `tone`을, Slider에 `jumpMultiplier`를 추가합니다.
- 일반 목록과 순서 변경 가능한 목록의 스크롤 콘텐츠용 `SeedAttachmentInput.scrollPadding`을 추가합니다. 기본값은 `EdgeInsets.zero`입니다. 링크 의미 정보를 위한 `SeedFooterLink.uri`도 추가합니다.
- 화살표를 포함해 컨트롤 7개 또는 9개를 표시하는 `SeedPagination.visibleItemCount`를 추가합니다. `maxVisibleSlots`는 계속 페이지 슬롯 수를 의미합니다. `SeedTablePagination.rangeLabel`, CSS 방식의 Grid `colSpan`과 1부터 시작하는 시작·끝 선, `SeedGridItem.full`을 통한 전체 너비 배치를 추가합니다. 밀도 프리셋을 가진 `SeedLayoutContent`와 `SeedScrollFogMask`를 추가합니다. `SeedAspectRatio.ratio`를 생략할 수 있으며 기본값은 4/3입니다.
- HelpBubbleTrigger와 AnchoredOverlay에 순서를 지정하는 `flipFallbackSides`를, AnchoredOverlay에 `fitMinExtent`와 `tabExitsContent`를 추가합니다. ScrollArea에 `focusableWhenScrollable`을, BottomSheet에 `onClosePressed`를 추가합니다. Dialog와 시트 도우미 함수가 라우트 빌더와 Navigator, 라우트, 포커스 옵션을 받습니다. Bottom Sheet는 제약 조건 재정의를 지원합니다. `showSeedSnackbar.onVisible`을 추가합니다.
- SegmentedControl, Select, InputButton, SelectBoxGroup, ChipRadioGroup, Menu, Popover에 `semanticsLabel`을 추가합니다. `SeedPressable`에 컨트롤 포커스 링과 포커스·링크 의미 정보를 사용자 지정하는 옵션을 추가합니다. `activateOnEnter: false`로 Space로만 활성화하고, `unfocusOnDisabledTap`으로 비활성 선택 행을 포인터로 탭하면 네이티브 컨트롤처럼 포커스된 입력을 해제합니다.
- 토큰과 공식 참조 fixture를 SEED React/CSS 3.3.0에 맞춥니다.
- `onSubmit`, `blurOnSubmit`, 입력 포커스를 유지하는 지우기 버튼을 갖춘 `SeedSearchInput`을 추가합니다.
- 칸, 구분자, 마스킹 점, 붙여넣기·자동완성 분배를 지원하는 `SeedSegmentedTextInput`과 `SeedSegmentedTextInputFormField`를 추가합니다.
- `SeedNavigationMenu`와 root, trigger, content, group, item 위젯을 추가합니다.
- 두 주를 표시하고 2주씩 이동하는 `SeedDatePickerLayout.twoWeeks`를 추가합니다.
- `SeedConsistentWidth`, `SeedLoadingIndicator`, `SeedStaticTextScope`와 42개의 `tNStatic{Regular,Medium,Bold}` 텍스트 스타일, `SeedFontSize`·`SeedLineHeight`의 `t1Static`–`t14Static` 토큰을 추가합니다.
- Tabs, TabBar, TabsView, ChipTabsView, PageBanner, AttachmentInput, 첨부 필드에 `extendSafeAreaX`를 추가합니다.
- `SeedAccordionItem`에 `titleWidget`, `descriptionWidget`, `suffixIcon`을, `SeedFieldset`에 `errorMessage`와 `errorIcon`을 추가합니다.
- Callout에 `showCloseButton`을, ContextualFloatingButton·ReactionButton·ToggleButton에 `disableOnLoading`을, Field·TextField·FieldButton에 `showRequiredIndicator`를, TextField에 `hideCharacterCount`를, Fieldset에 `labelBold`를, Radio에 `rowBuilder`를 추가합니다.
- 옵션이 아직 로드되지 않은 선택값까지 표시 문구로 만들 수 있도록 `SeedSelectSelectedItem`을 받는 `SeedSelect.formatSelectedValue`를 추가하며, `SeedSelectFormField`에서도 사용할 수 있습니다. 표시 문구와 검색어를 따로 지정하는 `SeedSelectItem`의 `textValue`와 `typeaheadLabel`, 명시적인 라디오 그룹을 만드는 `SeedSelectBoxGroup.radio`를 추가합니다.
- `showSeedBottomSheet`에 `dragDismissible`을, `SeedSidePanelTrigger`에 `closeOnInteractOutside`와 `closeOnEscape`를, `SeedSnackbarController.show`에 표시되기 전에 제거된 항목을 알리는 `onDiscard`를 추가합니다.
- `SeedPressable`에 `semanticsReadOnly`와 `semanticsValidationResult`를, `SeedInteractionState`에 `focusVisible`과 `surfaceSize`를 추가합니다.
- 밝은·어두운 테마의 `SeedPalette.grayAlpha100Light`–`grayAlpha1000Dark` 색과 `SeedColorScheme.banner`(`SeedBannerColors`)를 추가합니다.

### 수정 및 접근성

- 검색 제출 콜백이 요청한 포커스를 보존합니다. 키보드로 가려진 분할 입력 칸에 들어갈 때 커서를 끝에 두고, `fill` 칸의 안내 문구에는 할당된 칸 너비를 사용합니다.
- `SeedSegmentedTextInput`의 각 칸이 그룹 테두리 안에서 앱 테마의 Material 입력 외곽선을 그리지 않도록 합니다. Android가 첫 프레임에 0 크기 화면을 전달해도 예제 홈 그리드가 정상적으로 빌드되도록 합니다.
- `SeedTopNavigation.slot`에서 텍스트 버튼도 아이콘 버튼처럼 10px 패딩이 바 가장자리와 슬롯 쪽으로 겹치게 배치되어, 라벨이 바의 16px 여백에 맞춰집니다. Android 레이아웃에서는 앞쪽 버튼과 슬롯 사이에 16px 간격도 둡니다.
- 첨부 dropzone의 드래그 안내 문구는 필드가 가득 차거나 비활성일 때도 `fg.neutralSubtle` 색을 유지합니다. 흐려지는 것은 파일 선택 버튼뿐입니다.
- 2주 달력에서 이동 가능한 첫 주와 마지막 주까지 탐색할 수 있습니다. 레이아웃이나 주 시작 요일이 바뀌면 이전 전환을 끝냅니다.
- 제어되는 탐색 메뉴를 다시 열 때 다른 곳의 포커스를 유지하고, 재삽입된 사이드바 항목은 초기 상태로 시작합니다. 사이드바 너비 전환이 끝난 뒤 플라이아웃과 툴팁을 활성화합니다.
- 포인터가 떠나 닫힌 탐색 메뉴와 접힌 사이드바 플라이아웃을 다시 호버하면 다시 열립니다. React처럼 키보드로 연 플라이아웃만 포커스가 벗어날 때 닫히고, 포커스가 다른 곳에 있을 때 연 Popover는 곧바로 닫히지 않습니다.
- `SafeArea` 안에서도 뷰의 가로 inset 변경을 반영합니다. 첨부를 키보드로 재정렬할 때 양쪽 inset을 지키고, 임시 이동 목표가 사라지면 이동을 취소합니다.
- 방향키를 빠르게 눌러 첨부 항목을 화면 밖 위치로 옮겨도 포커스가 유지되어 Space로 순서를 확정할 수 있습니다.
- 라벨과 항목이 바뀌어도 Switch, Tabs, WheelPicker의 선택을 유지합니다. 수량 범위 변경을 반영하고 두 달 달력은 한 달씩 이동합니다.
- Fieldset 비활성을 버튼, 텍스트 입력, 입력 버튼에 적용하며, 중첩된 Fieldset에서도 적용됩니다. 칩 삭제와 태그 액션을 접근성 트리에 노출합니다.
- 위·아래 키로 메뉴를 열 수 있습니다. 래퍼에서도 시트의 닫기·핸들 콜백을 전달합니다. Snackbar 컨트롤러를 바꿔도 가려지는 요소를 피합니다.
- 부분 테마 재정의를 유지합니다. Grid는 끝선만 지정한 배치와 전체 너비 우선순위를 반영합니다.

- Field의 선택 표시와 Chip 삭제 안내를 현지화합니다. 읽지 않은 알림이 한 개일 때 단수 문구를 쓰고, 중첩 범위와 대화상자에서 바깥 번역 설정을 이어받습니다.
- 닫을 수 있는 라우트에서 바깥을 탭하면 가장 위에 있는 Select, Menu, Popover가 닫힙니다. 움직이는 앵커를 추적하고, Accordion이 접힌 뒤에도 중첩 메뉴의 키보드 포커스와 Escape 처리를 복원합니다. 메뉴는 콘텐츠가 들어갈 수 있으면 요청한 방향을 유지하고, 긴 메뉴는 대체 방향을 시도하기 전에 크기를 먼저 줄입니다. 포인터나 접근성 활성화 뒤 첫 화살표 키는 Menu에서는 알맞은 활성 항목을, Select에서는 선택된 옵션이 있으면 그 옵션을 대상으로 합니다.
- 일반 텍스트 Popover는 `minWidth`와 `maxWidth` 안에서 크기가 정해지고, 넘칠 때만 스크롤 페이드 영역을 확보합니다. 사용자 지정 콘텐츠는 최대 너비 레이아웃을 유지하고, 좁은 푸터에서도 액션 라벨을 읽을 수 있습니다. 스크롤되는 Dialog 본문은 키보드 포커스와 화살표 키 스크롤을 받습니다. Dialog 루트의 불필요한 Tab 정지점과 Dialog·AlertDialog의 그림자를 제거합니다.
- BottomSheet와 MenuSheet의 드래그 닫기를 React 기준인 높이의 25% 또는 0.4px/ms에 맞추고, 드래그 중 배경을 페이드합니다. MenuSheet 항목은 최소 52px 높이를 유지하고, 스냅하는 BottomSheet의 푸터는 콘텐츠 바로 옆에 둡니다.
- HelpBubble 콘텐츠에 화살표를 제외한 영역을 가진 dialog 이름을 부여합니다. 의미 정보 테스트에서는 `SeedHelpBubble` 안의 dialog 노드를 찾을 수 있습니다. FieldButton과 Select는 필드 이름과 표시된 값을, 라디오 그룹은 이름이 있는 라디오 그룹을, 라벨이 있는 단일 Slider는 하나의 슬라이더 노드를 노출합니다. 목록 링크는 단일 링크 노드를 노출합니다. 필드 라벨 탭, 시트 핸들, 첨부 드롭존은 이름 없는 버튼 노드를 만들지 않습니다. MenuSheet는 보이는 취소 버튼을 숨겨도 접근 가능한 닫기 동작을 유지하고, ReactionButton은 라벨을 접근성 이름으로 사용합니다. 사이드바 토글과 첨부 제거·재시도 동작의 현지화 기본값이 갱신됩니다.
- 선택 마크는 줄바꿈된 라벨의 첫 줄에 두고, 늘어난 Switch 라벨은 뒤쪽 가장자리에 둡니다. RadioListItem은 행 안에서 큰 마크를 사용합니다. Fieldset 설명은 컨트롤 아래에 두고 중간 굵기의 필드 라벨 타이포그래피를 사용합니다. 포커스 링은 컨트롤 마크 주위에 그리고, List 행과 Accordion 트리거에서는 안쪽에 그립니다. `SeedToggleButton`의 포커스 링은 완전한 pill 반경으로 그립니다.
- 테두리 때문에 입력, 수량, 반응, outline Chip, SelectBox의 콘텐츠가 밀리지 않도록 합니다. Field 필수 표시를 정렬하고 기본 오류 아이콘을 표시합니다. PageBanner 아이콘을 첫 줄에 맞추고 액션이 있어도 40px 최소 높이를 유지합니다. 텍스트에 붙는 배지는 줄의 위쪽에, 첨부 제거 버튼은 항목에 걸치는 위치에 맞춥니다. Chip 아이콘 간격을 유지하고 ListHeader와 Popover 닫기 버튼의 구조를 맞춥니다.
- 첨부 드롭존이 필드 너비 전체를 차지하고, `SeedAttachmentController.updateStatus`가 이전 진행률을 지웁니다. 내부에서 만든 텍스트 컨트롤러를 Flutter의 편집 생명주기로 복원합니다. Material Snackbar 액션 콜백이 중복 호출되지 않도록 합니다.
- `SeedResponsivePair`의 자식이 공간을 똑같이 나눠 갖고, 넘치면 전체 너비로 역순 배치됩니다. 줄바꿈되는 `SeedFlex`에 정렬을 적용하고, Footer 국가 선택기를 내비게이션 영역으로 옮기며, `SeedButton(bleed: true)`에 가로 방향 레이아웃 bleed를 사용합니다.
- Select 옵션 스타일과 전환 효과를 맞추고, 타입어헤드와 순환 화살표 이동을 추가하며, 단일 선택에 `formatValue`를 적용하고, 오래된 포인터 상태를 지웁니다. 눌림 피드백은 InputButton 루트가 아닌 Select 콘텐츠를 확대합니다. FieldButton은 기본 쉐브론을 표시하지 않습니다.
- Slider를 26px 트랙 레이아웃과 20px 썸, 범위 안에 머무는 단일 값 말풍선으로 맞추고, 단계가 있는 범위에서 Material 점을 표시하지 않습니다. 단계 정밀도를 유지하고 `allowedValues`를 따라 이동하며 Home, End, PageUp, PageDown, Shift+화살표를 지원합니다. 고정·유연 열이 섞인 WheelPicker를 수정하고, TimePicker 열은 고정 비율 대신 React의 `max-content`처럼 가장 넓은 값에 맞춥니다. WheelPicker에 마우스 드래그와 PageUp/PageDown 지원을 추가하고 수정된 스크롤 페이드 마스크를 사용합니다.
- Pagination과 TablePagination이 Material 조상 없이 렌더링됩니다. 표 선택기는 40px로 값 크기에 맞추고, `51-75`처럼 간결한 범위 라벨을 사용합니다. 접힌 SideNavigation의 상태와 현재 항목 표시를 유지합니다. 플라이아웃은 최소 너비 240px과, 툴팁이 덮지 않는 그룹 제목을 갖습니다. 항목 라벨은 한 줄로 줄이고, 눌림 표면을 안쪽으로 들이며, 헤더와 푸터 구분선을 제거합니다. 탭을 화살표 키로 이동할 때 페이지 스크롤 위치를 유지합니다.
- 나머지 시각 피드백을 React에 맞춥니다. Accordion 호버 표면, 평면 스타일의 WheelPicker, 잉크 효과가 없는 DatePicker·Menu·Footer·SideNavigation 컨트롤이 포함됩니다. `SeedScrollFog`의 불투명도와 마스크 방향을 바로잡습니다. 당겨서 새로고침 콘텐츠의 텍스트 선택을 유지합니다.
- 실행 중에 `extendSafeAreaX`를 바꿔도 콘텐츠를 다시 마운트하지 않습니다. TabsView는 선택된 캐러셀 페이지와 페이지 상태를, Tabs와 ChipTabsView는 탭 목록의 스크롤 위치를, AttachmentInput은 스크롤 위치·키보드 포커스·진행 중인 키보드 재정렬을, PageBanner는 콘텐츠 상태를 유지합니다.
- `immediate` 방식의 `SeedSnackbarController.show`는 React처럼 대기 중인 항목을 모두 대체하고, 대체된 각 항목을 `onClose`와 `onDiscard`로 알립니다. `SeedSnackbarAvoidOverlap`은 영역의 크기뿐 아니라 위치도 추적하며, 스낵바는 등록된 영역과 겹칠 때만 위로 이동합니다.
- Accordion 콘텐츠가 완전히 접히면 그 안의 포커스를 해제하므로, 숨겨진 컨트롤이 Enter나 Space로 활성화되지 않습니다. 당겨서 새로고침은 명시적인 `ScrollController`나 `primary: false`를 사용할 때도 화면에 다 들어가는 콘텐츠에서 당기기를 받습니다.
- `allowedValues`가 있는 범위 Slider는 React처럼 `minStepsBetweenThumbs`를 적용하지 않습니다. 연속 Slider는 키보드와 접근성 증감을 `step` 단위로 이동합니다.
- Tab은 항상 Menu를 닫고 트리거 다음 정지점으로 포커스를 옮기며, 순회를 건너뛰는 트리거나 자체 `FocusScope`의 마지막에 있는 트리거에서도 마찬가지입니다. 닫힌 Menu 트리거에서 위쪽 화살표를 누르면 마지막 활성 항목에서 메뉴가 열립니다. Menu와 Popover 트리거는 펼침 상태를 노출하고, Menu와 Select의 옵션 그룹은 이름이 있는 그룹으로 노출됩니다.
- Popover는 실제로 렌더링된 제목과 설명에서 접근성 이름과 설명을 가져오므로, 사용자 지정 `title`이나 `description` 위젯이 대신 표시되면 `titleText`와 `descriptionText`는 적용되지 않습니다. `semanticsLabel`은 계속 우선합니다.
- `rows`를 지정한 열 방향 Grid에서 `row`만 지정한 항목은 그 행에 머뭅니다. 제어하는 부모가 선택을 거부하거나 늦춰도 Tabs는 키보드 포커스가 있는 탭을 화면에 보여 줍니다.
- 첨부 제거 버튼이 항목 밖으로 걸친 부분을 탭해도 버튼이 눌립니다. 순서 변경 가능한 첨부 목록은 키보드 재정렬을 지원합니다. Space로 포커스된 항목을 집고, 방향키로 옮기고, Space로 놓으며, Escape로 취소합니다. 첨부 필드는 `onRetry`를 지정했을 때만 재시도 동작을 표시합니다.
- `SeedTooltipDelayGroup` 안의 툴팁은 같은 그룹의 다른 툴팁이 열려 있으면 지연 없이 열립니다. 자체 `openDelay`나 `closeDelay`를 지정한 툴팁은 그룹 값 대신 그 값을 사용합니다.
- 반응형 모달 트리거는 레이아웃이 768px 경계를 넘나들어도 본문 상태를 유지합니다. Bottom Sheet 형태에서도 Dialog의 최대 높이와 본문 padding, 사이드 패널의 사용자 지정 제목·설명 위젯, 닫기 버튼, 본문 padding을 유지합니다.
- TabsView는 탭의 순서가 바뀌거나 탭이 추가·제거되어도 지연 마운트된 페이지와 측정된 높이를 탭 값에 따라 유지합니다. Accordion은 항목 포커스를 값에 따라 유지하고, SideNavigation은 새로 추가된 항목에만 `defaultOpen`을 적용하며, 접힌 플라이아웃은 하위 항목 배지를 표시하고, `SeedSegment.invalid`는 접근성 트리에 노출됩니다.
- WheelPicker는 열이 비활성이나 읽기 전용이 되거나 옵션이 바뀌면 확정된 선택으로 돌아가고, 동작 줄이기 설정에서는 애니메이션 없이 이동합니다.
- 이미 선택된 Radio를 다시 활성화해도 변경을 알리지 않습니다. indeterminate SelectBox의 체크 표시는 대시로 표시됩니다. ScrollArea는 `fogOnlyWhenScrollable`과 관계없이 콘텐츠가 넘치기 시작하거나 멈출 때 `focusableWhenScrollable` 상태를 갱신합니다.
- 눌림 피드백은 측정된 pressable 표면 크기를 기준으로 확대·축소되며, 동작 줄이기 설정에서는 애니메이션 없이 적용됩니다.

### 예제와 웹

- App Bar 텍스트 버튼 데모와 검색 바 홈 진입점을 추가합니다. 검색 바는 본문을 누르면 키보드를 닫고 루트 화면에서는 닫기 결과를 화면에 표시합니다.
- 안전 영역 데모에 실시간 inset 값, 스와이프 탭과 내용 너비 탭, magic 배너, 첨부 목록과 Dropzone, Image Frame 장식을 추가합니다. 첨부 데모에 키보드 재정렬 방법을 안내합니다.
- 검색 입력, 분할 번호 입력, 탐색 메뉴, 2주 달력, 고정 텍스트 너비, 로딩, 고정 배율 타이포그래피, 가로 안전 영역, Accordion 및 Fieldset 슬롯 데모를 추가합니다. 카드번호·주민등록번호·검색 바는 쇼케이스 조합으로 제공합니다.
- Stackflow 쇼케이스의 플랫폼 전환, 반응형 레이아웃, 브라우저 글꼴 배율, 컴포넌트 데모를 맞춥니다. 새 Activity를 분리하면서도 Activity별 Step 히스토리를 유지하고, 푸시된 모달의 부모 화면을 유지하며, 시트의 초안 컨트롤러를 닫히는 동안에도 살려 둡니다.
- `/e2e/textarea-autoresize-scroll`에 textarea 자동 크기 조절과 스크롤 데모를 추가합니다.
- 쇼케이스 경로가 직접 열리고 새로고침 후에도 유지되도록 경로 URL과 GitHub Pages `404.html` 앱 셸을 사용합니다.

## 1.0.0

### 브레이킹 체인지

- **Select:** 단일·다중 선택 모두 리스트형 `value/defaultValue/onValueChange`를 사용합니다.
- **Time Picker:** 기본 시간을 00:00, 기본 시간 간격을 5분으로 설정합니다. 분 간격은 1/5/10/15/30분만 허용합니다.
- **Text Input / Text Field:** 컨트롤러를 값 또는 기본값과 함께 지정할 수 없도록 합니다.
- **Attachments:** 기본 첨부 개수를 1개로 설정하고, 컨트롤러를 첨부 항목 또는 기본 항목과 함께 지정할 수 없도록 합니다.
- **Menu:** 항목 선택 시 닫힘 사유로 `action` 대신 `SeedOverlayDismissReason.itemClick`을 전달합니다. 닫힘 사유를 검사하는 코드는 이에 맞게 수정해야 합니다.
- **Snackbar:** 컨트롤러와 Provider의 기본 전략을 `SeedSnackbarStrategy.immediate`로 설정합니다. 대기열 동작을 유지하려면 `queued`를 명시하세요. 호버·포커스로 인한 일시 정지가 끝나면 전체 표시 시간을 다시 시작합니다.
- **Tooltip:** 기본 열기 지연을 500ms에서 200ms로, `keepOpenOnContentHover`를 false로 변경합니다. 이전 동작을 유지하려면 값을 명시하세요. 닫기 지연은 100ms로 유지합니다.
- **Bottom Sheet:** 스냅 지점을 지정한 `showSeedBottomSheet`는 기본 콘텐츠 높이를 뷰포트의 90%로 제한하고, 마지막 스냅 인덱스부터 배경을 페이드합니다. 비율형 스냅 지점을 사용하던 레이아웃은 확인이 필요합니다. `SeedSnappingBottomSheet`를 직접 사용하는 경우에는 전체 높이를 기준으로 하는 기존 기본값을 유지합니다.
- **Side Panel:** 모바일뿐 아니라 데스크톱에도 안전 영역 너비의 80%라는 기본 상한을 적용합니다. 상한을 직접 지정하려면 `maxWidth`를 사용하세요.

### 버그 수정

- **State management:** 기본값은 한 번만 초기화하고, 부모가 제어하는 편집 결과, 빈 선택, 폼 초기화를 존중합니다.
- **Accessibility:** 접근성 포커스와 활성화 동작을 실제 키보드 포커스에 연결합니다. 방향키 반복 입력을 처리하고 비활성 선택지를 건너뜁니다.
- **Themes:** SEED 테마를 전달한 경우에도 명시적으로 지정한 글꼴을 적용합니다.
- **Material controls:** 선택 상태의 색상을 Seed 브랜드 색상에 맞춥니다.
- **Material migration:** 폼 필드와 Tooltip의 대체 방법 안내를 수정합니다.
- **Linear Progress Indicator:** 마이그레이션 시 수치형 진행률과 접근성 의미 정보를 유지합니다.
- **Accordion:** 독립적으로 이름이 부여된 버튼을 제목 안에 노출합니다. 단일 항목 펼침 동작과 전체 너비 카드의 눌림 상태를 수정합니다.
- **Attachments:** 한 항목만 허용할 때의 일괄 추가, 미리보기 넘침, 파일 확장자, 비활성 상태의 액션을 수정합니다.
- **Attachment dropzone:** 드래그 중이 아닐 때도 점선 테두리를 표시합니다.
- **Avatar:** 배지 형태, 20px 크기의 배지 표시 여부, 대체 콘텐츠 클리핑, 로딩·오류 시 플레이스홀더를 수정합니다.
- **Alert Dialog:** 반응형 액션과 콘텐츠 넘침을 수정합니다. 배경을 눌러 닫는 동작은 명시적으로 활성화해야 합니다.
- **Badge:** 기본 스타일 변형을 React에 맞춥니다.
- **Bottom Sheet:** 스냅 인덱스, 컨트롤러 동기화, 최소 높이에 따른 크기 조정, 닫기 설정을 유지합니다. 핸들 드래그를 방해하지 않으면서 뷰포트 크기가 바뀌면 픽셀형 스냅 지점을 다시 계산합니다.
- **Button:** 기본 스타일 변형을 React에 맞추고, 상호작용이 비활성화되어도 각 스타일의 로딩 배경을 유지합니다.
- **Callout:** 링크·아이콘 기본값, 여러 줄 정렬, magic 아이콘 색상, 40px 닫기 터치 영역을 수정합니다.
- **Checkbox:** 기본 브랜드 톤을 React에 맞춥니다.
- **Chip:** 기본 solid 스타일을 React에 맞춥니다.
- **Content Placeholder:** 공식 일러스트 12개를 올바른 클리핑과 크기로 렌더링합니다.
- **Date Picker:** 연속형 달력의 초기 멈춤 현상을 수정하고 월·연도 휠 탐색을 복원합니다.
- **Dialog:** 닫힘 애니메이션의 배율, 헤더가 없을 때 닫기 버튼에 필요한 공간, 본문이 짧을 때의 간격과 페이드 효과를 수정합니다.
- **FAB:** 콘텐츠 너비와 Contextual Floating Button 기본값을 수정합니다. 아이콘만 있는 버튼에는 라벨을 필수로 지정하도록 합니다.
- **Field:** 라벨을 활성화하면 입력에 포커스를 옮깁니다.
- **Footer:** 좁은 레이아웃에서 콘텐츠가 넘치지 않도록 합니다.
- **Help Bubble:** 콘텐츠 높이에 맞추고 38px 닫기 터치 영역을 유지합니다.
- **Image Frame:** 기본값과 오버레이 안쪽 여백을 수정합니다.
- **Input Button:** 지우기 버튼을 사용할 수 있는 조건을 수정합니다.
- **List:** 눌림 상태에서도 레이아웃과 구분선 숨김 설정을 유지합니다.
- **Manner Badge:** 장식용 이모지를 스크린 리더에서 제외합니다.
- **Menu:** 작은 크기의 스타일, 키보드 검색·순환 이동, 접근성 역할, 콜백 없는 항목의 선택 동작을 수정합니다.
- **Menu Sheet:** 핸들을 스와이프해 닫는 동작을 맞추고, 닫기가 금지된 시트를 유지하며, 스와이프 가능 여부에 따라 올바른 헤더 간격을 적용합니다.
- **Notification Badge:** Bottom Navigation과 Tabs에서 배지 위치를 수정합니다.
- **Overlays:** 중첩된 팝업의 외부 클릭 경계, 최상위 팝업의 Escape 처리, 콘텐츠 초기 포커스, Tab/Shift+Tab 이동, 트리거 포커스 복원을 수정합니다. 부모가 제어하는 상태에서도 닫힘 사유를 유지하고, Popover의 기본 포커스 이탈 정책이 `closeOnInteractOutside`를 따르도록 합니다.
- **Pagination:** 축약 표시할 때의 페이지 범위를 수정합니다.
- **Progress Circle:** 진행률이 정해지지 않은 상태에서는 잘못된 백분율 대신 `loading...`을 알립니다. 명시적으로 지정한 접근성 값은 그대로 적용합니다.
- **Pull to refresh:** 스크롤을 처리하는 영역을 유지하고, 손가락이 시작점 위로 돌아가면 당김 기준점을 갱신하며, 다시 활성화되거나 로딩이 끝난 뒤에도 누르고 있는 손가락으로 새로 당길 수 있게 합니다. 멀티터치로 중단된 제스처는 차단하고 실패한 새로고침도 안전하게 종료합니다. 터치가 드래그로 인식되는 이동 임계값을 맞추고, 새로고침 임계값을 넘는 각 이동마다 준비 콜백을 호출합니다.
- **Radio:** 상호작용 피드백과 포인터 선택을 복원합니다.
- **Reaction Button:** 터치 영역을 아이콘 크기와 독립적으로 유지합니다.
- **Segmented Control:** 선택된 비활성 항목의 색상을 수정합니다.
- **Select:** 부모가 닫기 요청을 거절하면 제어 중인 팝업을 열린 상태로 유지하되, Tab에 의한 닫기 요청은 `focusOut`으로 전달합니다. 선택된 옵션 또는 첫 번째 활성 옵션에 포커스를 옮기고, 읽기 전용 트리거는 편집을 허용하지 않으면서 포커스를 받을 수 있게 합니다.
- **Side Navigation:** 부모 항목의 액션, 활성 자식 항목의 펼침 동작, 접힌 하위 메뉴 접근을 수정합니다.
- **Side Panel:** 데스크톱 너비를 수정합니다.
- **Snackbar:** 명시적인 queued 전략의 선입선출 순서, 도우미 함수의 앞쪽 아이콘, 경로 전환 시 Provider 생명주기를 유지합니다.
- **Switch:** 행의 터치 영역을 스위치 그래픽과 독립적으로 유지합니다. 부모가 값을 제어하는 스위치는 콜백이 없어도 활성 상태를 유지하고, 브랜드 톤의 체크된 트랙은 비활성 상태에서도 브랜드 색상을 유지합니다.
- **Table Pagination:** 범위 선택기와 전체 개수를 분리하고 중간 크기의 선택기를 사용합니다.
- **Tabs:** 값의 우선순위, 큰 라벨의 크기, 캐러셀 높이, 전환 중 중간 페이지가 선택되는 문제를 수정합니다. LTR·RTL 레이아웃에서 선택된 Line·Chip 탭이 보이도록 스크롤하고, 마우스 캐러셀 드래그와 지연 마운트·마운트 해제 정책을 지원합니다.
- **Tag:** 글자가 커져도 넘치지 않도록 하고, 실제 렌더링된 콘텐츠를 측정하며, 잘라 표시할 때도 접근성 라벨을 유지합니다.
- **Text Input / Text Field:** 외부 컨트롤러와 폼 검증을 동기화합니다.
- **Tooltip:** Help Bubble의 배치와 전환 효과에 맞춥니다. 설명용 콘텐츠를 키보드·접근성 포커스 이동 대상에서 제외합니다.
- **Wheel Picker:** 스크롤이 멈춘 뒤 선택을 확정하고 Small 크기·사용자 지정 행 높이를 적용합니다. 열마다 값을 조절할 수 있는 접근성 컨트롤 하나를 노출하고, 부모가 값·옵션을 바꿔도 포커스를 유지하며, 빠른 키 반복 입력의 목표 위치와 읽기 전용 상태의 포커스 경계를 유지합니다.
- **Examples:** Manner Temp와 첨부 데모를 수정하고 중복 컨트롤을 제거하며, 카테고리·탭 상태와 중첩 모달의 부모 화면을 유지합니다.
- **Packaging:** 예제에 포함된 글꼴·이미지의 출처 표기를 갱신하고 배포 패키지에서 개발용 문서를 제외합니다.

### 기능 추가

- **Public API:** 공식 React 콜백 이름을 추가하고, 기존 별칭은 대체 API 안내와 함께 사용 중단 예정 API로 유지합니다.
- **Examples:** 자체 구성한 컴포넌트 카탈로그를 당근 공식 SEED Design React의 Stackflow SPA 예제를 재현한 Flutter 앱으로 전면 교체합니다. 컴포넌트·폼·화면 Activity 경로, 게시글·필터·상세 데모, 브라우저 URL·뒤로 가기·앞으로 가기·모달 Step 히스토리 동기화, 브라우저 기본 알림창을 사용하는 목록 예제와 네이티브 Flutter 대체 동작을 포함합니다. 기존 카탈로그 테스트를 SPA 경로·상호작용 테스트로 교체합니다.
- **Accordion:** 그룹, 접근성을 지원하는 제목, 콘텐츠 페이드 효과를 추가합니다.
- **Attachments:** `SeedAttachmentController`, 진행률·재시도 컨트롤, 독립적인 `invalid` 상태, `showRequiredIndicator`, 대표 배지 문구를 설정하는 `representativeLabel`을 추가합니다.
- **Badge:** 접근성을 지원하는 액션과 크기가 고정된 아이콘 슬롯을 추가합니다.
- **Bottom Navigation:** 비활성 항목과 스크린 리더용 알림 값을 추가합니다.
- **Bottom Sheet:** 스냅 지점, 핸들 탭으로 스냅 지점을 순환하는 동작, 키보드에 따른 위치 조정 옵션 `fixed/repositionInputs`, 콘텐츠 높이 설정 `snapContentHeightFraction/contentHeightFraction`을 추가합니다.
- **Callout:** 부모가 표시 여부를 제어하는 기능과 자체 닫기 동작을 추가합니다.
- **Checkbox:** `checked/defaultChecked/onCheckedChange`를 추가합니다.
- **Chip:** 체크 상태 API와 라디오 그룹을 추가합니다.
- **Date Picker:** 타입이 지정된 `.range/.multiple` 생성자, `selectionMode/visibleRange`, 레이아웃과 제약 조건을 추가합니다.
- **FAB:** 전환 효과를 추가합니다.
- **Image Frame:** 눌림 상태 API, 접근성을 지원하는 하트 토글, 9개 위치에 배치할 수 있는 오버레이, 이미지 콜백을 추가합니다.
- **Input Button:** 반응형 크기를 추가합니다.
- **List:** 접근성 의미 정보, `SeedListItem.linkUrl`, URI와 앱에서 탐색을 처리하는 콜백을 갖춘 `SeedListLinkItem`을 추가합니다.
- **Menu:** 반응형 크기를 추가합니다.
- **Menu Sheet:** 선택·닫기 옵션, 그룹별 정렬을 지정하는 `groupLabelAlignments`, `swipeable/handleDragDismissible` 옵션을 추가합니다.
- **Notification Badge:** 크기, 접근성 라벨, 아이콘·텍스트 배치 기능을 추가합니다.
- **Overlays:** 부모가 열림 상태를 제어하는 트리거, 위치·포커스·닫기 설정, Alert와 Sheet 각각의 Escape 정책, 앵커에 연결된 콘텐츠의 포커스를 제어하는 Flutter 전용 `contentFocusable`을 추가합니다.
- **Pagination:** `page`를 추가합니다.
- **Pull to refresh:** 당겨서 새로고침 기능을 추가합니다.
- **Reaction Button:** `pressed/defaultPressed/onPressedChange`를 추가합니다.
- **SelectBox:** 체크 상태 API와 라디오 그룹의 `onValueChange`를 추가합니다.
- **Side Navigation:** 접힘 상태 API와 항목별 `onOpenChange`를 추가합니다.
- **Side Panel:** 반응형 레이아웃과 제목을 시각적으로 숨긴 경우 접근성 이름을 지정하는 `semanticsLabel`을 추가합니다.
- **Slider:** `values/defaultValues/onValuesChange/onValuesCommit`을 추가합니다.
- **Snackbar:** 대기열 전략과 일시 정지 기능을 추가합니다.
- **Switch:** 체크 상태 API와 행 전체가 하나의 조작 대상인 구성을 추가합니다.
- **Table Pagination:** 페이지와 페이지 크기를 함께 관리하는 상태를 추가합니다.
- **Tabs:** 문자열 값, 캐러셀, 탭과 탭 뷰의 여백을 설정하는 `chipListPadding`을 추가합니다.
- **Text Field:** 구조화된 필드와 사용자 인식 문자 단위를 처리하는 콜백을 추가합니다.
- **Tooltip:** bool만 전달하는 `onOpenChange`와 지연 시간 설정을 추가합니다.
- **Wheel Picker:** 값의 기본값, 변경 상세 정보, 인덱스 콜백, 순환, 항목 탭, 비활성 상태를 추가합니다.

## 0.3.0

- 넓은 화면에서 Menu Sheet의 너비와 안전 영역 정렬을 수정합니다.
- Side Panel의 레이아웃과 스크롤을 공식 사양에 맞추고, 기본 너비를 480px에서 720px로 변경합니다.
- 확인 대화상자, 하단 시트, 상세 패널 예제를 개선합니다.
- 카탈로그에서 숫자형 페이지네이션을 가운데 정렬합니다.

## 0.2.0

- 그라데이션 토큰, `articleNote`, 반응 버튼 라벨, 입력·선택기 크기 옵션, 세로형 SelectBox 레이아웃을 추가합니다.
- 컴포넌트의 치수, 타이포그래피, 색상, 상호작용 상태를 공식 SEED 사양에 맞춥니다. 기본 크기와 스타일 변경을 포함합니다.
- Bottom Sheet의 레이아웃, 키보드 처리, 헤더 사용자 지정을 개선합니다. 기본적으로 닫기 버튼을 표시하고 핸들을 숨깁니다.
- 좁은 화면의 페이지네이션과 Segmented Control을 수정하고, Result Section의 안쪽 여백 재정의 옵션을 추가하며, Alert Dialog 텍스트를 읽기 방향의 시작점에 정렬합니다.
- 키보드로 조작할 때 포커스 링을 표시하고 포인터 클릭 뒤에는 숨깁니다.

## 0.1.1

- 자동 배포를 지원하는 Flutter Web 쇼케이스를 GitHub Pages에 추가합니다.
- 영문·한국어 README에 쇼케이스 링크를 추가합니다.

## 0.1.0

- 최초 릴리스입니다.
- Flutter 3.47.0 이상과 Dart 3.13.0 이상을 지원하고, 패키지와 예제의 SDK 요구 사항을 맞춥니다.
