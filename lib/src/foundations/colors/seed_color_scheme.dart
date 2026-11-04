import 'package:material_ui/material_ui.dart';

import 'seed_palette.dart';

/// Semantic Manner Temp color role pairing background and text.
class SeedMannerTempColor {
  /// Manner-temperature badge background color.
  final Color bg;
  /// Manner-temperature badge foreground text color.
  final Color text;

  /// Creates a badge color pair. [bg] paints the container and [text] paints its label.
  const SeedMannerTempColor({required this.bg, required this.text});

  /// Interpolates background and label colors from [a] to [b] by fraction [t].
  static SeedMannerTempColor lerp(
    SeedMannerTempColor a,
    SeedMannerTempColor b,
    double t,
  ) {
    return SeedMannerTempColor(
      bg: Color.lerp(a.bg, b.bg, t)!,
      text: Color.lerp(a.text, b.text, t)!,
    );
  }
}

/// Foreground color roles defined by SEED Design System.
class SeedFgColors {
  /// Brand foreground for emphasis (fg.brand).
  final Color brand;
  /// High-contrast brand foreground for weak surfaces (fg.brand-contrast).
  final Color brandContrast;
  /// Critical/error foreground (fg.critical).
  final Color critical;
  /// High-contrast critical foreground for weak surfaces (fg.critical-contrast).
  final Color criticalContrast;
  /// Foreground for disabled content (fg.disabled).
  final Color disabled;
  /// Informational foreground (fg.informative).
  final Color informative;
  /// High-contrast informative foreground for weak surfaces (fg.informative-contrast).
  final Color informativeContrast;
  /// Default body-text and icon foreground (fg.neutral).
  final Color neutral;
  /// Neutral foreground on inverse surfaces (fg.neutral-inverted).
  final Color neutralInverted;
  /// Muted secondary neutral foreground (fg.neutral-muted).
  final Color neutralMuted;
  /// Subtle tertiary neutral foreground (fg.neutral-subtle).
  final Color neutralSubtle;
  /// Text and icon foreground placed on the solid brand surface (fg.on-brand-solid).
  final Color onBrandSolid;
  /// Text and icon foreground placed on the solid critical surface (fg.on-critical-solid).
  final Color onCriticalSolid;
  /// Text and icon foreground placed on the solid informative surface (fg.on-informative-solid).
  final Color onInformativeSolid;
  /// Text and icon foreground placed on the solid neutral surface (fg.on-neutral-solid).
  final Color onNeutralSolid;
  /// Text and icon foreground placed on the solid positive surface (fg.on-positive-solid).
  final Color onPositiveSolid;
  /// Text and icon foreground placed on the solid warning surface (fg.on-warning-solid).
  final Color onWarningSolid;
  /// Placeholder foreground for inputs (fg.placeholder).
  final Color placeholder;
  /// Positive/success foreground (fg.positive).
  final Color positive;
  /// High-contrast positive foreground for weak surfaces (fg.positive-contrast).
  final Color positiveContrast;
  /// Warning foreground (fg.warning).
  final Color warning;
  /// High-contrast warning foreground for weak surfaces (fg.warning-contrast).
  final Color warningContrast;

  /// Creates a custom set of foreground semantic color roles; every role is required.
  const SeedFgColors({
    required this.brand,
    required this.brandContrast,
    required this.critical,
    required this.criticalContrast,
    required this.disabled,
    required this.informative,
    required this.informativeContrast,
    required this.neutral,
    required this.neutralInverted,
    required this.neutralMuted,
    required this.neutralSubtle,
    required this.onBrandSolid,
    required this.onCriticalSolid,
    required this.onInformativeSolid,
    required this.onNeutralSolid,
    required this.onPositiveSolid,
    required this.onWarningSolid,
    required this.placeholder,
    required this.positive,
    required this.positiveContrast,
    required this.warning,
    required this.warningContrast,
  });

  /// Creates the light-mode official foreground semantic colors.
  const SeedFgColors.light()
    : brand = SeedPalette.carrot600Light,
      brandContrast = SeedPalette.carrot700Light,
      critical = SeedPalette.red700Light,
      criticalContrast = SeedPalette.red900Light,
      disabled = SeedPalette.gray500Light,
      informative = SeedPalette.blue700Light,
      informativeContrast = SeedPalette.blue900Light,
      neutral = SeedPalette.gray1000Light,
      neutralInverted = SeedPalette.gray00Light,
      neutralMuted = SeedPalette.gray800Light,
      neutralSubtle = SeedPalette.gray700Light,
      onBrandSolid = SeedPalette.staticWhite,
      onCriticalSolid = SeedPalette.staticWhite,
      onInformativeSolid = SeedPalette.staticWhite,
      onNeutralSolid = SeedPalette.gray00Light,
      onPositiveSolid = SeedPalette.staticWhite,
      onWarningSolid = SeedPalette.staticBlackAlpha900,
      placeholder = SeedPalette.gray600Light,
      positive = SeedPalette.green700Light,
      positiveContrast = SeedPalette.green900Light,
      warning = SeedPalette.yellow700Light,
      warningContrast = SeedPalette.yellow900Light;

  /// Creates the dark-mode official foreground semantic colors.
  const SeedFgColors.dark()
    : brand = SeedPalette.carrot700Dark,
      brandContrast = SeedPalette.carrot700Dark,
      critical = SeedPalette.red700Dark,
      criticalContrast = SeedPalette.red900Dark,
      disabled = SeedPalette.gray500Dark,
      informative = SeedPalette.blue700Dark,
      informativeContrast = SeedPalette.blue900Dark,
      neutral = SeedPalette.gray1000Dark,
      neutralInverted = SeedPalette.gray100Dark,
      neutralMuted = SeedPalette.gray800Dark,
      neutralSubtle = SeedPalette.gray700Dark,
      onBrandSolid = SeedPalette.staticWhite,
      onCriticalSolid = SeedPalette.staticWhite,
      onInformativeSolid = SeedPalette.staticWhite,
      onNeutralSolid = SeedPalette.gray100Dark,
      onPositiveSolid = SeedPalette.staticWhite,
      onWarningSolid = SeedPalette.staticBlackAlpha900,
      placeholder = SeedPalette.gray600Dark,
      positive = SeedPalette.green700Dark,
      positiveContrast = SeedPalette.green900Dark,
      warning = SeedPalette.yellow700Dark,
      warningContrast = SeedPalette.yellow900Dark;

  /// Interpolates each foreground role from [a] to [b] at fraction [t].
  static SeedFgColors lerp(SeedFgColors a, SeedFgColors b, double t) {
    return SeedFgColors(
      brand: Color.lerp(a.brand, b.brand, t)!,
      brandContrast: Color.lerp(a.brandContrast, b.brandContrast, t)!,
      critical: Color.lerp(a.critical, b.critical, t)!,
      criticalContrast: Color.lerp(a.criticalContrast, b.criticalContrast, t)!,
      disabled: Color.lerp(a.disabled, b.disabled, t)!,
      informative: Color.lerp(a.informative, b.informative, t)!,
      informativeContrast: Color.lerp(
        a.informativeContrast,
        b.informativeContrast,
        t,
      )!,
      neutral: Color.lerp(a.neutral, b.neutral, t)!,
      neutralInverted: Color.lerp(a.neutralInverted, b.neutralInverted, t)!,
      neutralMuted: Color.lerp(a.neutralMuted, b.neutralMuted, t)!,
      neutralSubtle: Color.lerp(a.neutralSubtle, b.neutralSubtle, t)!,
      onBrandSolid: Color.lerp(a.onBrandSolid, b.onBrandSolid, t)!,
      onCriticalSolid: Color.lerp(a.onCriticalSolid, b.onCriticalSolid, t)!,
      onInformativeSolid: Color.lerp(
        a.onInformativeSolid,
        b.onInformativeSolid,
        t,
      )!,
      onNeutralSolid: Color.lerp(a.onNeutralSolid, b.onNeutralSolid, t)!,
      onPositiveSolid: Color.lerp(a.onPositiveSolid, b.onPositiveSolid, t)!,
      onWarningSolid: Color.lerp(a.onWarningSolid, b.onWarningSolid, t)!,
      placeholder: Color.lerp(a.placeholder, b.placeholder, t)!,
      positive: Color.lerp(a.positive, b.positive, t)!,
      positiveContrast: Color.lerp(a.positiveContrast, b.positiveContrast, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      warningContrast: Color.lerp(a.warningContrast, b.warningContrast, t)!,
    );
  }
}

/// Background color roles defined by SEED Design System.
class SeedBgColors {
  /// High-emphasis brand-emphasis surface fill (bg.brand-solid).
  final Color brandSolid;
  /// Pressed feedback color for the solid brand-emphasis surface (bg.brand-solid-pressed).
  final Color brandSolidPressed;
  /// Low-emphasis brand-emphasis surface fill (bg.brand-weak).
  final Color brandWeak;
  /// Pressed feedback color for the weak brand-emphasis surface (bg.brand-weak-pressed).
  final Color brandWeakPressed;
  /// High-emphasis critical or destructive surface fill (bg.critical-solid).
  final Color criticalSolid;
  /// Pressed feedback color for the solid critical or destructive surface (bg.critical-solid-pressed).
  final Color criticalSolidPressed;
  /// Low-emphasis critical or destructive surface fill (bg.critical-weak).
  final Color criticalWeak;
  /// Pressed feedback color for the weak critical or destructive surface (bg.critical-weak-pressed).
  final Color criticalWeakPressed;
  /// Surface fill for a disabled control (bg.disabled).
  final Color disabled;
  /// High-emphasis informational surface fill (bg.informative-solid).
  final Color informativeSolid;
  /// Pressed feedback color for the solid informational surface (bg.informative-solid-pressed).
  final Color informativeSolidPressed;
  /// Low-emphasis informational surface fill (bg.informative-weak).
  final Color informativeWeak;
  /// Pressed feedback color for the weak informational surface (bg.informative-weak-pressed).
  final Color informativeWeakPressed;
  /// Lowest canvas layer behind screen content (bg.layer-basement).
  final Color layerBasement;
  /// Default content surface above the basement layer (bg.layer-default).
  final Color layerDefault;
  /// Pressed version of the default content surface (bg.layer-default-pressed).
  final Color layerDefaultPressed;
  /// Floating surface used by popovers and modal content (bg.layer-floating).
  final Color layerFloating;
  /// Pressed version of a floating surface (bg.layer-floating-pressed).
  final Color layerFloatingPressed;
  /// Low-emphasis decorative magic surface (bg.magic-weak).
  final Color magicWeak;
  /// Inverse neutral surface (bg.neutral-inverted).
  final Color neutralInverted;
  /// Pressed inverse neutral surface (bg.neutral-inverted-pressed).
  final Color neutralInvertedPressed;
  /// Muted neutral surface (bg.neutral-muted).
  final Color neutralMuted;
  /// High-emphasis neutral surface fill (bg.neutral-solid).
  final Color neutralSolid;
  /// Pressed feedback color for the solid neutral surface (bg.neutral-solid-pressed).
  final Color neutralSolidPressed;
  /// High-emphasis neutral surface fill (bg.neutral-solid-muted).
  final Color neutralSolidMuted;
  /// Pressed feedback color for the solid neutral surface (bg.neutral-solid-muted-pressed).
  final Color neutralSolidMutedPressed;
  /// Subtle neutral surface (bg.neutral-subtle).
  final Color neutralSubtle;
  /// Weak neutral surface fill (bg.neutral-weak).
  final Color neutralWeak;
  /// Translucent weak neutral surface (bg.neutral-weak-alpha).
  final Color neutralWeakAlpha;
  /// Pressed translucent weak neutral surface (bg.neutral-weak-alpha-pressed).
  final Color neutralWeakAlphaPressed;
  /// Pressed weak neutral surface (bg.neutral-weak-pressed).
  final Color neutralWeakPressed;
  /// Scrim covering background content behind an overlay (bg.overlay).
  final Color overlay;
  /// Reduced-opacity background overlay scrim (bg.overlay-muted).
  final Color overlayMuted;
  /// High-emphasis positive or success surface fill (bg.positive-solid).
  final Color positiveSolid;
  /// Pressed feedback color for the solid positive or success surface (bg.positive-solid-pressed).
  final Color positiveSolidPressed;
  /// Low-emphasis positive or success surface fill (bg.positive-weak).
  final Color positiveWeak;
  /// Pressed feedback color for the weak positive or success surface (bg.positive-weak-pressed).
  final Color positiveWeakPressed;
  /// Fully transparent background with no fill (bg.transparent).
  final Color transparent;
  /// Pressed-state transparent surface feedback (bg.transparent-pressed).
  final Color transparentPressed;
  /// Selected-state transparent surface feedback (bg.transparent-selected).
  final Color transparentSelected;
  /// Pressed, selected-state transparent surface feedback (bg.transparent-selected-pressed).
  final Color transparentSelectedPressed;
  /// High-emphasis warning surface fill (bg.warning-solid).
  final Color warningSolid;
  /// Pressed feedback color for the solid warning surface (bg.warning-solid-pressed).
  final Color warningSolidPressed;
  /// Low-emphasis warning surface fill (bg.warning-weak).
  final Color warningWeak;
  /// Pressed feedback color for the weak warning surface (bg.warning-weak-pressed).
  final Color warningWeakPressed;

  /// Creates a custom set of background and overlay semantic color roles.
  const SeedBgColors({
    required this.brandSolid,
    required this.brandSolidPressed,
    required this.brandWeak,
    required this.brandWeakPressed,
    required this.criticalSolid,
    required this.criticalSolidPressed,
    required this.criticalWeak,
    required this.criticalWeakPressed,
    required this.disabled,
    required this.informativeSolid,
    required this.informativeSolidPressed,
    required this.informativeWeak,
    required this.informativeWeakPressed,
    required this.layerBasement,
    required this.layerDefault,
    required this.layerDefaultPressed,
    required this.layerFloating,
    required this.layerFloatingPressed,
    required this.magicWeak,
    required this.neutralInverted,
    required this.neutralInvertedPressed,
    required this.neutralMuted,
    required this.neutralSolid,
    required this.neutralSolidPressed,
    required this.neutralSolidMuted,
    required this.neutralSolidMutedPressed,
    required this.neutralSubtle,
    required this.neutralWeak,
    required this.neutralWeakAlpha,
    required this.neutralWeakAlphaPressed,
    required this.neutralWeakPressed,
    required this.overlay,
    required this.overlayMuted,
    required this.positiveSolid,
    required this.positiveSolidPressed,
    required this.positiveWeak,
    required this.positiveWeakPressed,
    required this.transparent,
    required this.transparentPressed,
    required this.transparentSelected,
    required this.transparentSelectedPressed,
    required this.warningSolid,
    required this.warningSolidPressed,
    required this.warningWeak,
    required this.warningWeakPressed,
  });

  /// Creates the light-mode official surface and background colors.
  const SeedBgColors.light()
    : brandSolid = SeedPalette.carrot600Light,
      brandSolidPressed = SeedPalette.carrot700Light,
      brandWeak = SeedPalette.carrot100Light,
      brandWeakPressed = SeedPalette.carrot200Light,
      criticalSolid = SeedPalette.red700Light,
      criticalSolidPressed = SeedPalette.red800Light,
      criticalWeak = SeedPalette.red100Light,
      criticalWeakPressed = SeedPalette.red200Light,
      disabled = SeedPalette.gray200Light,
      informativeSolid = SeedPalette.blue700Light,
      informativeSolidPressed = SeedPalette.blue800Light,
      informativeWeak = SeedPalette.blue100Light,
      informativeWeakPressed = SeedPalette.blue200Light,
      layerBasement = SeedPalette.gray200Light,
      layerDefault = SeedPalette.gray00Light,
      layerDefaultPressed = SeedPalette.gray100Light,
      layerFloating = SeedPalette.gray00Light,
      layerFloatingPressed = SeedPalette.gray100Light,
      magicWeak = const Color(0xFFF9F2EE),
      neutralInverted = SeedPalette.gray900Light,
      neutralInvertedPressed = SeedPalette.gray800Light,
      neutralMuted = SeedPalette.gray100Light,
      neutralSolid = SeedPalette.gray900Light,
      neutralSolidPressed = SeedPalette.gray800Light,
      neutralSolidMuted = SeedPalette.gray800Light,
      neutralSolidMutedPressed = SeedPalette.gray900Light,
      neutralSubtle = SeedPalette.gray00Light,
      neutralWeak = SeedPalette.gray200Light,
      neutralWeakAlpha = SeedPalette.staticBlackAlpha200,
      neutralWeakAlphaPressed = SeedPalette.staticBlackAlpha300,
      neutralWeakPressed = SeedPalette.gray300Light,
      overlay = SeedPalette.staticBlackAlpha700,
      overlayMuted = SeedPalette.staticBlackAlpha500,
      positiveSolid = SeedPalette.green700Light,
      positiveSolidPressed = SeedPalette.green800Light,
      positiveWeak = SeedPalette.green100Light,
      positiveWeakPressed = SeedPalette.green200Light,
      transparent = const Color(0x00000000),
      transparentPressed = SeedPalette.staticBlackAlpha100,
      transparentSelected = SeedPalette.staticBlackAlpha200,
      transparentSelectedPressed = SeedPalette.staticBlackAlpha300,
      warningSolid = SeedPalette.yellow300Light,
      warningSolidPressed = SeedPalette.yellow400Light,
      warningWeak = SeedPalette.yellow100Light,
      warningWeakPressed = SeedPalette.yellow200Light;

  /// Creates the dark-mode official surface and background colors.
  const SeedBgColors.dark()
    : brandSolid = SeedPalette.carrot700Dark,
      brandSolidPressed = SeedPalette.carrot800Dark,
      brandWeak = SeedPalette.carrot100Dark,
      brandWeakPressed = SeedPalette.carrot200Dark,
      criticalSolid = SeedPalette.red600Dark,
      criticalSolidPressed = SeedPalette.red700Dark,
      criticalWeak = SeedPalette.red100Dark,
      criticalWeakPressed = SeedPalette.red200Dark,
      disabled = SeedPalette.gray300Dark,
      informativeSolid = SeedPalette.blue600Dark,
      informativeSolidPressed = SeedPalette.blue700Dark,
      informativeWeak = SeedPalette.blue100Dark,
      informativeWeakPressed = SeedPalette.blue200Dark,
      layerBasement = SeedPalette.gray00Dark,
      layerDefault = SeedPalette.gray100Dark,
      layerDefaultPressed = SeedPalette.gray300Dark,
      layerFloating = SeedPalette.gray200Dark,
      layerFloatingPressed = SeedPalette.gray300Dark,
      magicWeak = const Color(0xFF201F1F),
      neutralInverted = SeedPalette.gray1000Dark,
      neutralInvertedPressed = SeedPalette.gray800Dark,
      neutralMuted = SeedPalette.gray200Dark,
      neutralSolid = SeedPalette.gray1000Dark,
      neutralSolidPressed = SeedPalette.gray800Dark,
      neutralSolidMuted = SeedPalette.gray400Dark,
      neutralSolidMutedPressed = SeedPalette.gray500Dark,
      neutralSubtle = SeedPalette.gray100Dark,
      neutralWeak = SeedPalette.gray300Dark,
      neutralWeakAlpha = SeedPalette.staticWhiteAlpha200,
      neutralWeakAlphaPressed = SeedPalette.staticWhiteAlpha300,
      neutralWeakPressed = SeedPalette.gray400Dark,
      overlay = SeedPalette.staticBlackAlpha700,
      overlayMuted = SeedPalette.staticBlackAlpha500,
      positiveSolid = SeedPalette.green500Dark,
      positiveSolidPressed = SeedPalette.green600Dark,
      positiveWeak = SeedPalette.green100Dark,
      positiveWeakPressed = SeedPalette.green200Dark,
      transparent = const Color(0x00FFFFFF),
      transparentPressed = SeedPalette.staticWhiteAlpha50,
      transparentSelected = SeedPalette.staticWhiteAlpha100,
      transparentSelectedPressed = SeedPalette.staticWhiteAlpha200,
      warningSolid = SeedPalette.yellow800Dark,
      warningSolidPressed = SeedPalette.yellow900Dark,
      warningWeak = SeedPalette.yellow100Dark,
      warningWeakPressed = SeedPalette.yellow200Dark;

  /// Interpolates each surface and overlay role from [a] to [b] at fraction [t].
  static SeedBgColors lerp(SeedBgColors a, SeedBgColors b, double t) {
    return SeedBgColors(
      brandSolid: Color.lerp(a.brandSolid, b.brandSolid, t)!,
      brandSolidPressed: Color.lerp(
        a.brandSolidPressed,
        b.brandSolidPressed,
        t,
      )!,
      brandWeak: Color.lerp(a.brandWeak, b.brandWeak, t)!,
      brandWeakPressed: Color.lerp(a.brandWeakPressed, b.brandWeakPressed, t)!,
      criticalSolid: Color.lerp(a.criticalSolid, b.criticalSolid, t)!,
      criticalSolidPressed: Color.lerp(
        a.criticalSolidPressed,
        b.criticalSolidPressed,
        t,
      )!,
      criticalWeak: Color.lerp(a.criticalWeak, b.criticalWeak, t)!,
      criticalWeakPressed: Color.lerp(
        a.criticalWeakPressed,
        b.criticalWeakPressed,
        t,
      )!,
      disabled: Color.lerp(a.disabled, b.disabled, t)!,
      informativeSolid: Color.lerp(a.informativeSolid, b.informativeSolid, t)!,
      informativeSolidPressed: Color.lerp(
        a.informativeSolidPressed,
        b.informativeSolidPressed,
        t,
      )!,
      informativeWeak: Color.lerp(a.informativeWeak, b.informativeWeak, t)!,
      informativeWeakPressed: Color.lerp(
        a.informativeWeakPressed,
        b.informativeWeakPressed,
        t,
      )!,
      layerBasement: Color.lerp(a.layerBasement, b.layerBasement, t)!,
      layerDefault: Color.lerp(a.layerDefault, b.layerDefault, t)!,
      layerDefaultPressed: Color.lerp(
        a.layerDefaultPressed,
        b.layerDefaultPressed,
        t,
      )!,
      layerFloating: Color.lerp(a.layerFloating, b.layerFloating, t)!,
      layerFloatingPressed: Color.lerp(
        a.layerFloatingPressed,
        b.layerFloatingPressed,
        t,
      )!,
      magicWeak: Color.lerp(a.magicWeak, b.magicWeak, t)!,
      neutralInverted: Color.lerp(a.neutralInverted, b.neutralInverted, t)!,
      neutralInvertedPressed: Color.lerp(
        a.neutralInvertedPressed,
        b.neutralInvertedPressed,
        t,
      )!,
      neutralMuted: Color.lerp(a.neutralMuted, b.neutralMuted, t)!,
      neutralSolid: Color.lerp(a.neutralSolid, b.neutralSolid, t)!,
      neutralSolidPressed: Color.lerp(
        a.neutralSolidPressed,
        b.neutralSolidPressed,
        t,
      )!,
      neutralSolidMuted: Color.lerp(
        a.neutralSolidMuted,
        b.neutralSolidMuted,
        t,
      )!,
      neutralSolidMutedPressed: Color.lerp(
        a.neutralSolidMutedPressed,
        b.neutralSolidMutedPressed,
        t,
      )!,
      neutralSubtle: Color.lerp(a.neutralSubtle, b.neutralSubtle, t)!,
      neutralWeak: Color.lerp(a.neutralWeak, b.neutralWeak, t)!,
      neutralWeakAlpha: Color.lerp(a.neutralWeakAlpha, b.neutralWeakAlpha, t)!,
      neutralWeakAlphaPressed: Color.lerp(
        a.neutralWeakAlphaPressed,
        b.neutralWeakAlphaPressed,
        t,
      )!,
      neutralWeakPressed: Color.lerp(
        a.neutralWeakPressed,
        b.neutralWeakPressed,
        t,
      )!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      overlayMuted: Color.lerp(a.overlayMuted, b.overlayMuted, t)!,
      positiveSolid: Color.lerp(a.positiveSolid, b.positiveSolid, t)!,
      positiveSolidPressed: Color.lerp(
        a.positiveSolidPressed,
        b.positiveSolidPressed,
        t,
      )!,
      positiveWeak: Color.lerp(a.positiveWeak, b.positiveWeak, t)!,
      positiveWeakPressed: Color.lerp(
        a.positiveWeakPressed,
        b.positiveWeakPressed,
        t,
      )!,
      transparent: Color.lerp(a.transparent, b.transparent, t)!,
      transparentPressed: Color.lerp(
        a.transparentPressed,
        b.transparentPressed,
        t,
      )!,
      transparentSelected: Color.lerp(
        a.transparentSelected,
        b.transparentSelected,
        t,
      )!,
      transparentSelectedPressed: Color.lerp(
        a.transparentSelectedPressed,
        b.transparentSelectedPressed,
        t,
      )!,
      warningSolid: Color.lerp(a.warningSolid, b.warningSolid, t)!,
      warningSolidPressed: Color.lerp(
        a.warningSolidPressed,
        b.warningSolidPressed,
        t,
      )!,
      warningWeak: Color.lerp(a.warningWeak, b.warningWeak, t)!,
      warningWeakPressed: Color.lerp(
        a.warningWeakPressed,
        b.warningWeakPressed,
        t,
      )!,
    );
  }
}

/// Stroke color roles defined by SEED Design System.
class SeedStrokeColors {
  /// Brand solid outline or border color (stroke.brand-solid).
  final Color brandSolid;
  /// Brand weak outline or border color (stroke.brand-weak).
  final Color brandWeak;
  /// Critical solid outline or border color (stroke.critical-solid).
  final Color criticalSolid;
  /// Critical weak outline or border color (stroke.critical-weak).
  final Color criticalWeak;
  /// High-visibility focus outline for keyboard focus (stroke.focus-ring).
  final Color focusRing;
  /// Informative solid outline or border color (stroke.informative-solid).
  final Color informativeSolid;
  /// Informative weak outline or border color (stroke.informative-weak).
  final Color informativeWeak;
  /// High-contrast neutral outline (stroke.neutral-contrast).
  final Color neutralContrast;
  /// Muted neutral stroke for subtle boundaries (stroke.neutral-muted).
  final Color neutralMuted;
  /// Neutral solid outline or border color (stroke.neutral-solid).
  final Color neutralSolid;
  /// Very subtle neutral stroke (stroke.neutral-subtle).
  final Color neutralSubtle;
  /// Low-emphasis neutral border and separator (stroke.neutral-weak).
  final Color neutralWeak;
  /// Positive solid outline or border color (stroke.positive-solid).
  final Color positiveSolid;
  /// Positive weak outline or border color (stroke.positive-weak).
  final Color positiveWeak;
  /// Warning solid outline or border color (stroke.warning-solid).
  final Color warningSolid;
  /// Warning weak outline or border color (stroke.warning-weak).
  final Color warningWeak;

  /// Creates a custom set of semantic border and focus-stroke colors.
  const SeedStrokeColors({
    required this.brandSolid,
    required this.brandWeak,
    required this.criticalSolid,
    required this.criticalWeak,
    required this.focusRing,
    required this.informativeSolid,
    required this.informativeWeak,
    required this.neutralContrast,
    required this.neutralMuted,
    required this.neutralSolid,
    required this.neutralSubtle,
    required this.neutralWeak,
    required this.positiveSolid,
    required this.positiveWeak,
    required this.warningSolid,
    required this.warningWeak,
  });

  /// Creates the light-mode official stroke colors.
  const SeedStrokeColors.light()
    : brandSolid = SeedPalette.carrot700Light,
      brandWeak = SeedPalette.carrot300Light,
      criticalSolid = SeedPalette.red700Light,
      criticalWeak = SeedPalette.red300Light,
      focusRing = SeedPalette.blue600Light,
      informativeSolid = SeedPalette.blue700Light,
      informativeWeak = SeedPalette.blue300Light,
      neutralContrast = SeedPalette.gray1000Light,
      neutralMuted = SeedPalette.staticBlackAlpha300,
      neutralSolid = SeedPalette.gray800Light,
      neutralSubtle = SeedPalette.staticBlackAlpha200,
      neutralWeak = SeedPalette.gray400Light,
      positiveSolid = SeedPalette.green700Light,
      positiveWeak = SeedPalette.green300Light,
      warningSolid = SeedPalette.yellow700Light,
      warningWeak = SeedPalette.yellow300Light;

  /// Creates the dark-mode official stroke colors.
  const SeedStrokeColors.dark()
    : brandSolid = SeedPalette.carrot700Dark,
      brandWeak = SeedPalette.carrot300Dark,
      criticalSolid = SeedPalette.red700Dark,
      criticalWeak = SeedPalette.red300Dark,
      focusRing = SeedPalette.blue600Dark,
      informativeSolid = SeedPalette.blue700Dark,
      informativeWeak = SeedPalette.blue300Dark,
      neutralContrast = SeedPalette.gray1000Dark,
      neutralMuted = SeedPalette.staticWhiteAlpha100,
      neutralSolid = SeedPalette.gray800Dark,
      neutralSubtle = SeedPalette.staticWhiteAlpha50,
      neutralWeak = SeedPalette.gray400Dark,
      positiveSolid = SeedPalette.green700Dark,
      positiveWeak = SeedPalette.green300Dark,
      warningSolid = SeedPalette.yellow700Dark,
      warningWeak = SeedPalette.yellow300Dark;

  /// Interpolates each semantic border color from [a] to [b] at fraction [t].
  static SeedStrokeColors lerp(
    SeedStrokeColors a,
    SeedStrokeColors b,
    double t,
  ) {
    return SeedStrokeColors(
      brandSolid: Color.lerp(a.brandSolid, b.brandSolid, t)!,
      brandWeak: Color.lerp(a.brandWeak, b.brandWeak, t)!,
      criticalSolid: Color.lerp(a.criticalSolid, b.criticalSolid, t)!,
      criticalWeak: Color.lerp(a.criticalWeak, b.criticalWeak, t)!,
      focusRing: Color.lerp(a.focusRing, b.focusRing, t)!,
      informativeSolid: Color.lerp(a.informativeSolid, b.informativeSolid, t)!,
      informativeWeak: Color.lerp(a.informativeWeak, b.informativeWeak, t)!,
      neutralContrast: Color.lerp(a.neutralContrast, b.neutralContrast, t)!,
      neutralMuted: Color.lerp(a.neutralMuted, b.neutralMuted, t)!,
      neutralSolid: Color.lerp(a.neutralSolid, b.neutralSolid, t)!,
      neutralSubtle: Color.lerp(a.neutralSubtle, b.neutralSubtle, t)!,
      neutralWeak: Color.lerp(a.neutralWeak, b.neutralWeak, t)!,
      positiveSolid: Color.lerp(a.positiveSolid, b.positiveSolid, t)!,
      positiveWeak: Color.lerp(a.positiveWeak, b.positiveWeak, t)!,
      warningSolid: Color.lerp(a.warningSolid, b.warningSolid, t)!,
      warningWeak: Color.lerp(a.warningWeak, b.warningWeak, t)!,
    );
  }
}

/// Manner temperature 10-level color tokens.
class SeedMannerTempColors {
  /// Background and text colors for manner-temperature level 1 (on the 1–10 scale).
  final SeedMannerTempColor l1;
  /// Background and text colors for manner-temperature level 2 (on the 1–10 scale).
  final SeedMannerTempColor l2;
  /// Background and text colors for manner-temperature level 3 (on the 1–10 scale).
  final SeedMannerTempColor l3;
  /// Background and text colors for manner-temperature level 4 (on the 1–10 scale).
  final SeedMannerTempColor l4;
  /// Background and text colors for manner-temperature level 5 (on the 1–10 scale).
  final SeedMannerTempColor l5;
  /// Background and text colors for manner-temperature level 6 (on the 1–10 scale).
  final SeedMannerTempColor l6;
  /// Background and text colors for manner-temperature level 7 (on the 1–10 scale).
  final SeedMannerTempColor l7;
  /// Background and text colors for manner-temperature level 8 (on the 1–10 scale).
  final SeedMannerTempColor l8;
  /// Background and text colors for manner-temperature level 9 (on the 1–10 scale).
  final SeedMannerTempColor l9;
  /// Background and text colors for manner-temperature level 10 (on the 1–10 scale).
  final SeedMannerTempColor l10;

  /// Creates a ten-level palette of [SeedMannerTempColor] pairs.
  const SeedMannerTempColors({
    required this.l1,
    required this.l2,
    required this.l3,
    required this.l4,
    required this.l5,
    required this.l6,
    required this.l7,
    required this.l8,
    required this.l9,
    required this.l10,
  });

  /// Creates the light-mode manner-temperature levels from 1 through 10.
  const SeedMannerTempColors.light()
    : l1 = const SeedMannerTempColor(
        bg: Color(0xFFF1F2F3),
        text: Color(0xFF757B85),
      ),
      l2 = const SeedMannerTempColor(
        bg: Color(0xFFF8F4EC),
        text: Color(0xFFAB863F),
      ),
      l3 = const SeedMannerTempColor(
        bg: Color(0xFFFFF5E5),
        text: Color(0xFFE08A00),
      ),
      l4 = const SeedMannerTempColor(
        bg: Color(0xFFFFF3E5),
        text: Color(0xFFF57E00),
      ),
      l5 = const SeedMannerTempColor(
        bg: Color(0xFFFFF1E5),
        text: Color(0xFFFF7300),
      ),
      l6 = const SeedMannerTempColor(
        bg: Color(0xFFFFF0E5),
        text: Color(0xFFFF6600),
      ),
      l7 = const SeedMannerTempColor(
        bg: Color(0xFFFFEFE5),
        text: Color(0xFFFF5100),
      ),
      l8 = const SeedMannerTempColor(
        bg: Color(0xFFFFEEE5),
        text: Color(0xFFFF3300),
      ),
      l9 = const SeedMannerTempColor(
        bg: Color(0xFFFDEDED),
        text: Color(0xFFE82C45),
      ),
      l10 = const SeedMannerTempColor(
        bg: Color(0xFFFFEBEE),
        text: Color(0xFFCB0123),
      );

  /// Creates the dark-mode manner-temperature levels from 1 through 10.
  const SeedMannerTempColors.dark()
    : l1 = const SeedMannerTempColor(
        bg: Color(0xFF292929),
        text: Color(0xFFB8B8B9),
      ),
      l2 = const SeedMannerTempColor(
        bg: Color(0xFF332605),
        text: Color(0xFFF5DB97),
      ),
      l3 = const SeedMannerTempColor(
        bg: Color(0xFF372B01),
        text: Color(0xFFFDDA65),
      ),
      l4 = const SeedMannerTempColor(
        bg: Color(0xFF372301),
        text: Color(0xFFFBBE55),
      ),
      l5 = const SeedMannerTempColor(
        bg: Color(0xFF371F01),
        text: Color(0xFFFAAC4B),
      ),
      l6 = const SeedMannerTempColor(
        bg: Color(0xFF351B03),
        text: Color(0xFFFC9855),
      ),
      l7 = const SeedMannerTempColor(
        bg: Color(0xFF371701),
        text: Color(0xFFF97A25),
      ),
      l8 = const SeedMannerTempColor(
        bg: Color(0xFF380F00),
        text: Color(0xFFFE6A34),
      ),
      l9 = const SeedMannerTempColor(
        bg: Color(0xFF380500),
        text: Color(0xFFFE6A5D),
      ),
      l10 = const SeedMannerTempColor(
        bg: Color(0xFF34040A),
        text: Color(0xFFFB6F82),
      );

  /// Returns the color pair for [level], clamping values below 1 to level 1 and values above 10 to level 10.
  SeedMannerTempColor byLevel(int level) {
    switch (level.clamp(1, 10)) {
      case 1:
        return l1;
      case 2:
        return l2;
      case 3:
        return l3;
      case 4:
        return l4;
      case 5:
        return l5;
      case 6:
        return l6;
      case 7:
        return l7;
      case 8:
        return l8;
      case 9:
        return l9;
      case 10:
      default:
        return l10;
    }
  }

  /// Interpolates all ten manner-temperature color pairs from [a] to [b] at fraction [t].
  static SeedMannerTempColors lerp(
    SeedMannerTempColors a,
    SeedMannerTempColors b,
    double t,
  ) {
    return SeedMannerTempColors(
      l1: SeedMannerTempColor.lerp(a.l1, b.l1, t),
      l2: SeedMannerTempColor.lerp(a.l2, b.l2, t),
      l3: SeedMannerTempColor.lerp(a.l3, b.l3, t),
      l4: SeedMannerTempColor.lerp(a.l4, b.l4, t),
      l5: SeedMannerTempColor.lerp(a.l5, b.l5, t),
      l6: SeedMannerTempColor.lerp(a.l6, b.l6, t),
      l7: SeedMannerTempColor.lerp(a.l7, b.l7, t),
      l8: SeedMannerTempColor.lerp(a.l8, b.l8, t),
      l9: SeedMannerTempColor.lerp(a.l9, b.l9, t),
      l10: SeedMannerTempColor.lerp(a.l10, b.l10, t),
    );
  }
}

/// Complete color scheme of SEED Design System with full semantic roles.
class SeedColorScheme extends ThemeExtension<SeedColorScheme> {
  /// Theme brightness used to select light/dark semantics
  final Brightness brightness;
  /// Foreground text and icon semantic roles
  final SeedFgColors fg;
  /// Background, surface and overlay semantic roles
  final SeedBgColors bg;
  /// Border, separator and focus-ring semantic roles
  final SeedStrokeColors stroke;
  /// Ten-level manner-temperature badge color pairs
  final SeedMannerTempColors mannerTemp;

  /// Creates a complete semantic color scheme, including [brightness], [fg], [bg], [stroke], and
  /// [mannerTemp].
  const SeedColorScheme({
    required this.brightness,
    required this.fg,
    required this.bg,
    required this.stroke,
    required this.mannerTemp,
  });

  /// Creates a light [SeedColorScheme] from the official light semantic palettes.
  const SeedColorScheme.light()
    : brightness = Brightness.light,
      fg = const SeedFgColors.light(),
      bg = const SeedBgColors.light(),
      stroke = const SeedStrokeColors.light(),
      mannerTemp = const SeedMannerTempColors.light();

  /// Creates a dark [SeedColorScheme] from the official dark semantic palettes.
  const SeedColorScheme.dark()
    : brightness = Brightness.dark,
      fg = const SeedFgColors.dark(),
      bg = const SeedBgColors.dark(),
      stroke = const SeedStrokeColors.dark(),
      mannerTemp = const SeedMannerTempColors.dark();

  /// Whether [brightness] is [Brightness.dark].
  bool get isDark => brightness == Brightness.dark;

  /// Returns a color scheme with specified roles replaced and omitted values retained.
  ///
  /// Nullable arguments do not clear roles.
  @override
  SeedColorScheme copyWith({
    Brightness? brightness,
    SeedFgColors? fg,
    SeedBgColors? bg,
    SeedStrokeColors? stroke,
    SeedMannerTempColors? mannerTemp,
  }) {
    return SeedColorScheme(
      brightness: brightness ?? this.brightness,
      fg: fg ?? this.fg,
      bg: bg ?? this.bg,
      stroke: stroke ?? this.stroke,
      mannerTemp: mannerTemp ?? this.mannerTemp,
    );
  }

  /// Interpolates theme semantic colors toward [other] by [t].
  ///
  /// An incompatible/null [other] returns this instance; brightness switches at t = 0.5.
  @override
  SeedColorScheme lerp(ThemeExtension<SeedColorScheme>? other, double t) {
    if (other is! SeedColorScheme) return this;
    return SeedColorScheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      fg: SeedFgColors.lerp(fg, other.fg, t),
      bg: SeedBgColors.lerp(bg, other.bg, t),
      stroke: SeedStrokeColors.lerp(stroke, other.stroke, t),
      mannerTemp: SeedMannerTempColors.lerp(mannerTemp, other.mannerTemp, t),
    );
  }
}
