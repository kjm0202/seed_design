# seed_design

Flutter 포트의 사용자 API와 동작은 공식 SEED Design React를 우선한다.

- 컴포넌트의 prop 이름·타입·기본값을 바꾸기 전에 공식 소스를 확인한다.
  근거와 Dart 대응은 `doc/REACT_API_REFERENCE.md`, 유지할 계약은 `doc/PUBLIC_API_CONTRACT.md`에 기록한다.
- 현재 비교 기준은 공식 React/CSS 3.3.0(태그 `@seed-design/react@3.3.0`, 커밋 `5c98c886e`)이다.
  로컬 참고 소스는 `doc/react_package_3.3.0/packages/react`와 `doc/react_package_3.3.0/packages/react-headless` 아래에 있다.
  토큰과 레시피는 같은 폴더의 `packages/rootage`·`packages/qvism-preset`, 공식 조합 예제는 `docs/registry/react`를 본다.
- `doc/react_package`는 3.0.1 사본이다. 과거 버전과의 비교와 `tool/generate_content_placeholder_presets.py`의 입력으로만 쓰고,
  현재 API의 근거로 삼지 않는다.
- 참고 폴더가 없거나 최신 여부가 중요하면 공식 GitHub 저장소와 seed-design.io 문서를 확인한다.
  기준 버전을 올릴 때는 이 문서의 버전·경로 표기도 함께 고친다.
- `defaultValue`, `defaultValues`, `defaultChecked`, `defaultEntries`를 일반 취향으로 통일하지 않는다.
  `onValueChange`, `onValuesChange`, `onOpenChange` 등도 해당 공식 컴포넌트를 기준으로 선택한다.
- Dart 타입·Flutter 생명주기로 인해 달라지는 부분과 기존 호환 별칭은 공식 API와 구분한다.
- API 변경은 소비자 관점의 위젯 테스트로 검증하고 `flutter analyze`, 라이브러리·예제 테스트를 실행한다.

- 작업용 보고서·감사·API 근거·계약 Markdown은 `doc/`에만 보관하고 Git에 추가하지 않는다.
  README·변경 이력·라이선스/출처·프로젝트 지침만 추적하며, 작업 문서를 `git add -f`로 강제 추가하지 않는다.
