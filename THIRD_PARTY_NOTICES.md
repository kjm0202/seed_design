# Third-party sources

## SEED Design System

Reference: https://github.com/daangn/seed-design

Reviewed revision: `d18f14e70f7b73ba84c032717d6413610bce0437` (2026-10-20).

The full YAML token/component snapshot in `test/fixtures/seed_official_reference.json`, gradient stop definitions generated into `lib/src/foundations/gradient/seed_gradient.dart`, reviewed design specification values and manner-temperature boundaries are based on the official source. The upstream project uses Apache License 2.0; a copy is included at `third_party/seed-design/LICENSE`. Manner-temperature boundary logic was adapted to Dart with finite-number validation. Official emote images are not bundled.

The upstream attribution notice is reproduced without changes at `third_party/seed-design/NOTICE`. SEED-derived material remains subject to Apache License 2.0; the package's MIT license applies to its original Flutter-specific implementation. The adapted temperature logic is in `lib/src/components/manner_temp/seed_manner_temp.dart`, which identifies the source and modifications.

### Content Placeholder presets

The twelve vector presets in `lib/src/components/layout/seed_content_placeholder_presets.dart`
are adapted from `packages/react/src/components/ContentPlaceholder/presets.tsx`
at SEED Design revision `14aa12a20fc1ce39044212f531b2127c6787eab0` (React v3.0.1).
The modification converts the SVG path commands and fill rules to Flutter `Path`
commands; `tool/generate_content_placeholder_presets.py` reproduces the conversion
from the vendored reference. These paths remain under Apache License 2.0, with the
license and upstream notice included at `third_party/seed-design/`.

### Image Frame reaction heart

The heart paths in `lib/src/components/layout/seed_image_frame.dart` are adapted
from `packages/react/src/components/ImageFrame/ImageFrame.tsx` at revision
`14aa12a20fc1ce39044212f531b2127c6787eab0`. The SVG geometry and fill rules were
converted to Flutter Canvas paths. Copyright 2025 주식회사 당근마켓;
Apache License 2.0, with the license and notice in `third_party/seed-design/`.

### Identity Placeholder artwork

The person and business paths in `lib/src/components/layout/seed_identity_placeholder.dart`
are adapted from `packages/react/src/components/IdentityPlaceholder/IdentityPlaceholder.tsx`
at revision `14aa12a20fc1ce39044212f531b2127c6787eab0`. SVG commands were
converted to Flutter `Path` commands, preserving the original 640 × 640 geometry.
Copyright 2025 주식회사 당근마켓; Apache License 2.0, with the license and
notice in `third_party/seed-design/`.

## Wanted Sans (tests only)

The unmodified test font is from Wanted Sans v1.0.3, revision `f4f2f8fd93c19f1399cf5a7d17d05bb4b103ac14`:
https://github.com/wanteddev/wanted-sans/tree/f4f2f8fd93c19f1399cf5a7d17d05bb4b103ac14

License: SIL Open Font License 1.1. See `test/assets/fonts/OFL.txt` and `SOURCE.md` in the source checkout. This font is excluded from the published package.

## Material Icons

Rendering tests load the Material Icons font supplied by the Flutter SDK through its normal asset bundle.
