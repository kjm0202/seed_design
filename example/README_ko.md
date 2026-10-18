# 예제 앱

[영문 문서](README.md)

버튼, 입력창, 메뉴 등 패키지에 포함된 컴포넌트를 직접 써볼 수 있습니다. 오른쪽 위 버튼으로 밝은 테마와 어두운 테마를 전환할 수 있습니다.

[웹 쇼케이스 열기](https://kjm0202.github.io/seed_design/)

Flutter 3.47.0 이상, Dart 3.13.0 이상에서 실행할 수 있습니다.

## 실행

저장소의 루트 폴더에서 실행합니다.

```sh
cd example
flutter pub get
flutter run
```

## 소스 위치

| 파일 | 내용 |
| --- | --- |
| [main.dart](lib/main.dart) | 앱 실행, 테마 전환, 탭 이동 |
| [components_tab.dart](lib/tabs/components_tab.dart) | 버튼, 배지, 칩, 목록, 선택 컨트롤 |
| [feedback_tab.dart](lib/tabs/feedback_tab.dart) | 매너온도, 진행률, 스켈레톤, 말풍선 |
| [inputs_tab.dart](lib/tabs/inputs_tab.dart) | 입력창, 수량 조절, 날짜·시간 선택 |
| [navigation_tab.dart](lib/tabs/navigation_tab.dart) | 페이지 이동, 표, 이미지, 탐색 메뉴 |
| [overlays_tab.dart](lib/tabs/overlays_tab.dart) | 대화상자, 하단 시트, 사이드 패널, 알림 |
| [seed_menu_example.dart](lib/widgets/seed_menu_example.dart) | 더보기 버튼으로 여는 드롭다운 메뉴 |

## 테스트

예제 폴더에서 실행합니다.

```sh
flutter test
```

## 웹 배포

`master`에서 예제나 라이브러리가 바뀌면 [GitHub Pages 배포 작업](../.github/workflows/showcase.yml)이 쇼케이스를 다시 빌드하고 게시합니다. 저장소의 Actions 탭에서 직접 실행할 수도 있습니다.

같은 사이트를 로컬에서 빌드하려면 예제 폴더에서 실행합니다.

```sh
flutter build web --release --base-href /seed_design/
```
