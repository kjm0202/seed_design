# Third-party sources

## SEED Design System

Reference: https://github.com/daangn/seed-design

Reviewed revision: `0684acaa7012a68d9858c971c51db46b680978dd` (2026-10-18).

The reviewed design specification values and manner-temperature boundaries are based on the official source. The upstream project uses Apache License 2.0; a copy is included at `third_party/seed-design/LICENSE`. Manner-temperature boundary logic was adapted to Dart with finite-number validation. Official emote images are not bundled.

The upstream attribution notice is reproduced without changes at `third_party/seed-design/NOTICE`. SEED-derived material remains subject to Apache License 2.0; the package's MIT license applies to its original Flutter-specific implementation. The adapted temperature logic is in `lib/src/components/manner_temp/seed_manner_temp.dart`, which identifies the source and modifications.

## Noto Sans KR (tests only)

The test font is from Google Fonts, revision `b38c5c93af322c45f633e17ac440ec1e6c94d489`:
https://github.com/google/fonts/tree/b38c5c93af322c45f633e17ac440ec1e6c94d489/ofl/notosanskr

License: SIL Open Font License 1.1. See `test/assets/fonts/OFL.txt` and `SOURCE.md` in the source checkout. This font is excluded from the published package.

## Material Icons

Rendering tests load the Material Icons font supplied by the Flutter SDK through its normal asset bundle.
