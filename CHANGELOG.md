## 1.0.0

### English

#### Breaking changes

- **Public API:** Add official React callback names; retain legacy aliases as deprecated APIs with replacement hints.
- **Select:** Use list-valued `value/defaultValue/onValueChange` for single and multiple selection.
- **Time Picker:** Default to 00:00 and five-minute steps; allow only 1/5/10/15/30-minute steps.
- **Text Input / Text Field:** Disallow controllers combined with values or defaults.
- **Attachments:** Default to one entry and disallow controllers combined with entries or defaults.
- **Menu:** Report item selection as `SeedOverlayDismissReason.itemClick` instead of `action`; update consumers that inspect dismissal reasons.
- **Snackbar:** Default controllers and providers to `SeedSnackbarStrategy.immediate`; specify `queued` to retain queueing. Restart the full timeout after hover/focus pause ends.
- **Tooltip:** Default opening delay to 200ms instead of 500ms and `keepOpenOnContentHover` to false. Set explicit values to retain the previous behavior; closing delay remains 100ms.
- **Bottom Sheet:** For `showSeedBottomSheet` with snap points, default to a 90% viewport content cap and fade the backdrop from the last snap index. Review existing fractional snap layouts; direct `SeedSnappingBottomSheet` use retains its full-height default.
- **Side Panel:** Apply the default 80% safe-width cap on desktop as well as mobile; use `maxWidth` to specify an explicit cap.

#### Bug fixes

- **State management:** Initialize defaults once and respect parent-controlled edits, empty selections, and form resets.
- **Accessibility:** Bridge semantic focus and activation to actual keyboard focus; handle repeated arrow keys and skip disabled choices.
- **Themes:** Honor explicit font overrides with supplied SEED themes.
- **Material controls:** Match selected-state colors to Seed brand colors.
- **Material migration:** Correct form-field and Tooltip replacement guidance.
- **Linear Progress Indicator:** Preserve numeric progress and semantics during migration.
- **Accordion:** Expose a heading containing a separate named button; fix single-item expansion and full-width pressed cards.
- **Attachments:** Fix single-entry batches, preview overflow, filename extensions, and disabled-state actions.
- **Attachment dropzone:** Keep dashed borders visible outside dragging.
- **Avatar:** Fix badge geometry, 20px badge visibility, fallback clipping, and loading/error placeholders.
- **Alert Dialog:** Fix responsive actions and overflow; make backdrop dismissal opt-in.
- **Badge:** Match default variants to React.
- **Bottom Sheet:** Preserve snap indices, controller synchronization, minimum-height resizing, and dismissal settings; re-resolve pixel snaps on viewport resize without interrupting handle drags.
- **Button:** Match default variants to React and preserve variant-specific loading backgrounds when interaction is disabled.
- **Callout:** Fix link/icon defaults, multiline alignment, magic-icon colors, and the 40px close target.
- **Checkbox:** Match the default brand tone to React.
- **Chip:** Match the default solid variant to React.
- **Content Placeholder:** Render the twelve official illustrations with correct clipping and sizing.
- **Date Picker:** Fix initial continuous-calendar freezes and restore month/year wheel navigation.
- **Dialog:** Fix exit scale, headerless close-button space, and short-body spacing/fades.
- **FAB:** Fix content width and Contextual Floating Button defaults; require icon-only labels.
- **Field:** Focus inputs when their labels are activated.
- **Footer:** Prevent narrow-layout overflow.
- **Help Bubble:** Fit content height and preserve the 38px close target.
- **Image Frame:** Correct defaults and overlay insets.
- **Input Button:** Correct clear-button availability.
- **List:** Preserve pressed-state layout and divider suppression.
- **Manner Badge:** Exclude decorative emoji from screen readers.
- **Menu:** Fix small styling, keyboard search/wrapping, accessibility roles, and callback-free selection.
- **Menu Sheet:** Match handle-swipe dismissal, preserve non-dismissible sheets, and use the correct swipeable/non-swipeable header spacing.
- **Notification Badge:** Correct placement in Bottom Navigation and Tabs.
- **Overlays:** Fix nested outside-click boundaries, topmost Escape handling, initial content focus, Tab/Shift+Tab traversal, and trigger focus restoration. Preserve controlled dismissal reasons and default Popover focus-out policy to `closeOnInteractOutside`.
- **Pagination:** Correct compact page ranges.
- **Progress Circle:** Announce `loading...` for indeterminate progress without supplying a false percentage; honor explicit semantics overrides.
- **Pull to refresh:** Preserve scroll ownership, rebase retreating gestures, rearm held contacts after re-enabling or loading, block interrupted multitouch gestures, and settle rejected refreshes safely. Match touch-slop delivery and ready callbacks on each move above the threshold.
- **Radio:** Restore interaction feedback and pointer selection.
- **Reaction Button:** Keep touch targets independent of icon size.
- **Segmented Control:** Correct selected disabled colors.
- **Select:** Keep controlled popups open when dismissal is rejected, while reporting Tab dismissal requests as `focusOut`. Focus the selected or first enabled option and keep readonly triggers focusable without allowing edits.
- **Side Navigation:** Fix parent actions, active-child expansion, and collapsed-submenu access.
- **Side Panel:** Correct desktop widths.
- **Snackbar:** Preserve explicit queued FIFO order, helper prefix icons, and provider lifecycle across route changes.
- **Switch:** Keep row touch targets independent of switch graphics, controlled switches enabled without callbacks, and disabled checked brand tracks in the brand color.
- **Table Pagination:** Separate the range selector from the total count and use medium-sized selectors.
- **Tabs:** Fix value precedence, large-label sizing, carousel height, and intermediate-page selection. Reveal selected line/chip tabs in LTR and RTL layouts, support mouse carousel drags, and honor lazy-mount and unmount policies.
- **Tag:** Prevent overflow with enlarged text, measure actual rendered content, and retain accessible labels when truncating.
- **Text Input / Text Field:** Synchronize external controllers with form validation.
- **Tooltip:** Match Help Bubble placement and transitions; keep descriptive content out of keyboard and accessibility focus traversal.
- **Wheel Picker:** Commit after scrolling settles and honor Small/custom row heights. Expose one adjustable semantic control per column, retain focus across controlled value/option changes, and preserve rapid repeated-key targets and readonly focus boundaries.
- **Examples:** Correct Manner Temp and attachment demos, remove duplicate controls, and preserve category/tab state and nested modal parents.
- **Packaging:** Update bundled example font/image attribution and exclude development documents from the published package.

#### Features

- **Examples:** Replace the custom component catalog with a Flutter clone of Karrot's official SEED Design React Stackflow SPA example. Include component, form, and screen activity routes, an article/filter/detail demo, synchronized browser URLs, Back, Forward, and modal-step history, and browser-native list alerts with a native Flutter fallback. Replace legacy catalog tests with SPA route and interaction coverage.
- **Accordion:** Add groups, accessible headings, and content fading.
- **Attachments:** Add `SeedAttachmentController`, progress/retry controls, independent `invalid` state, `showRequiredIndicator`, and configurable `representativeLabel` text.
- **Badge:** Add accessible actions and fixed icon slots.
- **Bottom Navigation:** Add disabled items and screen-reader notification values.
- **Bottom Sheet:** Add snap points, handle-tap cycling, keyboard positioning options `fixed/repositionInputs`, and content-height controls `snapContentHeightFraction/contentHeightFraction`.
- **Callout:** Add controlled visibility and self-dismissal.
- **Checkbox:** Add `checked/defaultChecked/onCheckedChange`.
- **Chip:** Add checked-state APIs and radio groups.
- **Date Picker:** Add typed `.range/.multiple` constructors, `selectionMode/visibleRange`, layouts, and constraints.
- **FAB:** Add transitions.
- **Image Frame:** Add pressed-state APIs, accessible heart toggles, nine-position overlays, and image callbacks.
- **Input Button:** Add responsive sizes.
- **List:** Add accessibility semantics, `SeedListItem.linkUrl`, and `SeedListLinkItem` with a URI and consumer-managed navigation callback.
- **Menu:** Add responsive sizes.
- **Menu Sheet:** Add selection, dismissal, per-group `groupLabelAlignments`, and `swipeable/handleDragDismissible` options.
- **Notification Badge:** Add sizes, accessibility labels, and icon/text positioning.
- **Overlays:** Add controlled triggers, placement, focus, dismissal, separate Alert/Sheet Escape policies, and Flutter-specific `contentFocusable` control for anchored content.
- **Pagination:** Add `page`.
- **Pull to refresh:** Add pull-to-refresh support.
- **Reaction Button:** Add `pressed/defaultPressed/onPressedChange`.
- **SelectBox:** Add checked-state APIs and radio-group `onValueChange`.
- **Side Navigation:** Add collapsed-state APIs and item `onOpenChange`.
- **Side Panel:** Add responsive layouts and a `semanticsLabel` override for visually hidden titles.
- **Slider:** Add `values/defaultValues/onValuesChange/onValuesCommit`.
- **Snackbar:** Add queue strategies and pause support.
- **Switch:** Add checked-state APIs and single-target rows.
- **Table Pagination:** Add combined page and page-size state.
- **Tabs:** Add string values, carousels, and configurable `chipListPadding` on tabs and tab views.
- **Text Field:** Add structured fields and grapheme-aware callbacks.
- **Tooltip:** Add bool-only `onOpenChange` and configurable delays.
- **Wheel Picker:** Add value defaults, change details, index callbacks, looping, item taps, and disabled states.

### 한국어

#### 브레이킹 체인지

- **Public API:** 공식 React 콜백 이름을 추가하고, 기존 별칭은 대체 API 안내와 함께 사용 중단 예정 API로 유지합니다.
- **Select:** 단일·다중 선택 모두 리스트형 `value/defaultValue/onValueChange`를 사용합니다.
- **Time Picker:** 기본 시간을 00:00, 기본 시간 간격을 5분으로 설정합니다. 분 간격은 1/5/10/15/30분만 허용합니다.
- **Text Input / Text Field:** 컨트롤러를 값 또는 기본값과 함께 지정할 수 없도록 합니다.
- **Attachments:** 기본 첨부 개수를 1개로 설정하고, 컨트롤러를 첨부 항목 또는 기본 항목과 함께 지정할 수 없도록 합니다.
- **Menu:** 항목 선택 시 닫힘 사유로 `action` 대신 `SeedOverlayDismissReason.itemClick`을 전달합니다. 닫힘 사유를 검사하는 코드는 이에 맞게 수정해야 합니다.
- **Snackbar:** 컨트롤러와 Provider의 기본 전략을 `SeedSnackbarStrategy.immediate`로 설정합니다. 대기열 동작을 유지하려면 `queued`를 명시하세요. 호버·포커스로 인한 일시 정지가 끝나면 전체 표시 시간을 다시 시작합니다.
- **Tooltip:** 기본 열기 지연을 500ms에서 200ms로, `keepOpenOnContentHover`를 false로 변경합니다. 이전 동작을 유지하려면 값을 명시하세요. 닫기 지연은 100ms로 유지합니다.
- **Bottom Sheet:** 스냅 지점을 지정한 `showSeedBottomSheet`는 기본 콘텐츠 높이를 뷰포트의 90%로 제한하고, 마지막 스냅 인덱스부터 배경을 페이드합니다. 비율형 스냅 지점을 사용하던 레이아웃은 확인이 필요합니다. `SeedSnappingBottomSheet`를 직접 사용하는 경우에는 전체 높이를 기준으로 하는 기존 기본값을 유지합니다.
- **Side Panel:** 모바일뿐 아니라 데스크톱에도 안전 영역 너비의 80%라는 기본 상한을 적용합니다. 상한을 직접 지정하려면 `maxWidth`를 사용하세요.

#### 버그 수정

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

#### 기능 추가

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

### English

- Fix Menu Sheet width and safe-area alignment on wide screens.
- Align Side Panel layout and scrolling with official specifications; change the
  default width from 480px to 720px.
- Refine confirmation dialog, bottom sheet, and detail panel examples.
- Center numbered pagination in the catalog.

### 한국어

- 넓은 화면에서 Menu Sheet의 너비와 안전 영역 정렬을 수정합니다.
- Side Panel의 레이아웃과 스크롤을 공식 사양에 맞추고, 기본 너비를 480px에서 720px로 변경합니다.
- 확인 대화상자, 하단 시트, 상세 패널 예제를 개선합니다.
- 카탈로그에서 숫자형 페이지네이션을 가운데 정렬합니다.

## 0.2.0

### English

- Add gradient tokens, `articleNote`, reaction button labels, input/picker size
  options, and vertical select box layouts.
- Align component dimensions, typography, colors, and interaction states with
  official SEED specifications, including changes to default sizes and styles.
- Improve Bottom Sheet layout, keyboard handling, and header customization.
  Show the close button and hide the handle by default.
- Fix narrow-screen pagination and segmented controls, add Result Section padding
  overrides, and align Alert Dialog text to the direction start.
- Show focus rings for keyboard interaction and hide them after pointer clicks.

### 한국어

- 그라데이션 토큰, `articleNote`, 반응 버튼 라벨, 입력·선택기 크기 옵션, 세로형 SelectBox 레이아웃을 추가합니다.
- 컴포넌트의 치수, 타이포그래피, 색상, 상호작용 상태를 공식 SEED 사양에 맞춥니다. 기본 크기와 스타일 변경을 포함합니다.
- Bottom Sheet의 레이아웃, 키보드 처리, 헤더 사용자 지정을 개선합니다. 기본적으로 닫기 버튼을 표시하고 핸들을 숨깁니다.
- 좁은 화면의 페이지네이션과 Segmented Control을 수정하고, Result Section의 안쪽 여백 재정의 옵션을 추가하며, Alert Dialog 텍스트를 읽기 방향의 시작점에 정렬합니다.
- 키보드로 조작할 때 포커스 링을 표시하고 포인터 클릭 뒤에는 숨깁니다.

## 0.1.1

### English

* Add a Flutter Web showcase hosted on GitHub Pages, with automatic deployment.
* Link the showcase from the English and Korean READMEs.

### 한국어

- 자동 배포를 지원하는 Flutter Web 쇼케이스를 GitHub Pages에 추가합니다.
- 영문·한국어 README에 쇼케이스 링크를 추가합니다.

## 0.1.0

### English

* Initial Release
* Support Flutter 3.47.0 and later with Dart 3.13.0 and later; align package and example SDK requirements.

### 한국어

- 최초 릴리스입니다.
- Flutter 3.47.0 이상과 Dart 3.13.0 이상을 지원하고, 패키지와 예제의 SDK 요구 사항을 맞춥니다.
