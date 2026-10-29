# Stackflow SPA 예제

[영문 문서](README.md)

기본 예제는 공식 SEED Design의 `examples/stackflow-spa`를 Flutter로 옮긴 앱입니다. `ActivityHome`에서 컴포넌트별 화면으로 이동하며, `/demo/home`에서 게시글 목록·카테고리 필터·상세 데모를 볼 수 있습니다. 밝은 테마와 어두운 테마는 시스템 설정을 따릅니다.

[웹 쇼케이스 열기](https://kjm0202.github.io/seed_design/)

Flutter 3.47.0 이상, Dart 3.13.0 이상에서 실행할 수 있습니다.

## 실행

저장소 루트에서 실행합니다.

```sh
cd example
flutter pub get
flutter run
```

브라우저에서는 `flutter run -d chrome`을 사용합니다. 모든 플랫폼과 웹 쇼케이스가 같은 기본 진입점을 사용합니다.

Flutter의 `Navigator`로 이름 기반 경로, push/replace/pop, 네이티브 뒤로 가기를 처리합니다. DOM/CSS 전용 동작과 일부 전환 효과는 Flutter에 맞게 대응합니다. 의도적인 웹 버그 재현, 성능 진단, E2E 전용 화면은 지원 대상 탐색에서 제외합니다.

## 소스 위치

| 파일 | 내용 |
| --- | --- |
| [main.dart](lib/main.dart) | 기본 앱 진입점 |
| [stackflow_spa.dart](lib/stackflow_spa/stackflow_spa.dart) | 테마, 경로 처리, 시작 화면 |
| [spa_catalog.dart](lib/stackflow_spa/spa_catalog.dart) | 시작 화면의 섹션과 화면 링크 |
| [spa_paths.dart](lib/stackflow_spa/spa_paths.dart) | 화면 이름과 경로 |
| [forms_pages.dart](lib/stackflow_spa/forms_pages.dart) | 입력·선택 화면 |
| [display_pages.dart](lib/stackflow_spa/display_pages.dart) | 버튼·배지·표시 컴포넌트 |
| [navigation_pages.dart](lib/stackflow_spa/navigation_pages.dart) | 탐색·레이아웃 화면 |
| [overlay_pages.dart](lib/stackflow_spa/overlay_pages.dart) | 대화상자·시트·오버레이 |
| [screen_pages.dart](lib/stackflow_spa/screen_pages.dart) | 앱 화면·전환 효과 |
| [extra_pages.dart](lib/stackflow_spa/extra_pages.dart) | 추가 컴포넌트 화면 |
| [demo_pages.dart](lib/stackflow_spa/demo_pages.dart) | 게시글 목록·필터·상세 |

## 테스트

예제 폴더에서 실행합니다.

```sh
flutter test
# 실행 중인 iOS/Android 시뮬레이터에서 검증:
flutter test integration_test/stackflow_spa_navigation_test.dart -d <device-id>
```

위젯 테스트는 기본 진입점, 지원 대상 경로, 컴포넌트 변형, 게시글 목록·필터·상세 동작을 검증합니다.

## 웹 배포

`master`에서 예제나 라이브러리가 바뀌면 [GitHub Pages 배포 작업](../.github/workflows/showcase.yml)이 이 앱을 빌드하고 게시합니다. 저장소의 Actions 탭에서 직접 실행할 수도 있습니다.

같은 사이트를 로컬에서 빌드하려면 예제 폴더에서 실행합니다.

```sh
flutter build web --release --base-href /seed_design/
```
