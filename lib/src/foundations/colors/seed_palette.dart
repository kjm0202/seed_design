import 'dart:ui';

/// Raw color palette defined in SEED Design System.
///
/// Contains absolute color scales across all hues and alpha channels.
class SeedPalette {
  const SeedPalette._();

  // Gray Palette (Light)
  /// Light-mode gray palette, scale step 00 (Color(0xFFFFFFFF)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray00Light = Color(0xFFFFFFFF);
  /// Light-mode gray palette, scale step 100 (Color(0xFFF7F8F9)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray100Light = Color(0xFFF7F8F9);
  /// Light-mode gray palette, scale step 200 (Color(0xFFF3F4F5)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray200Light = Color(0xFFF3F4F5);
  /// Light-mode gray palette, scale step 300 (Color(0xFFEEEFF1)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray300Light = Color(0xFFEEEFF1);
  /// Light-mode gray palette, scale step 400 (Color(0xFFDCDEE3)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray400Light = Color(0xFFDCDEE3);
  /// Light-mode gray palette, scale step 500 (Color(0xFFD1D3D8)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray500Light = Color(0xFFD1D3D8);
  /// Light-mode gray palette, scale step 600 (Color(0xFFB0B3BA)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray600Light = Color(0xFFB0B3BA);
  /// Light-mode gray palette, scale step 700 (Color(0xFF868B94)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray700Light = Color(0xFF868B94);
  /// Light-mode gray palette, scale step 800 (Color(0xFF555D6D)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray800Light = Color(0xFF555D6D);
  /// Light-mode gray palette, scale step 900 (Color(0xFF2A3038)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray900Light = Color(0xFF2A3038);
  /// Light-mode gray palette, scale step 1000 (Color(0xFF1A1C20)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray1000Light = Color(0xFF1A1C20);

  // Gray Palette (Dark)
  /// Dark-mode gray palette, scale step 00 (Color(0xFF000000)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray00Dark = Color(0xFF000000);
  /// Dark-mode gray palette, scale step 100 (Color(0xFF16171B)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray100Dark = Color(0xFF16171B);
  /// Dark-mode gray palette, scale step 200 (Color(0xFF1D2025)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray200Dark = Color(0xFF1D2025);
  /// Dark-mode gray palette, scale step 300 (Color(0xFF2B2E35)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray300Dark = Color(0xFF2B2E35);
  /// Dark-mode gray palette, scale step 400 (Color(0xFF393D46)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray400Dark = Color(0xFF393D46);
  /// Dark-mode gray palette, scale step 500 (Color(0xFF5B606A)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray500Dark = Color(0xFF5B606A);
  /// Dark-mode gray palette, scale step 600 (Color(0xFF868B94)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray600Dark = Color(0xFF868B94);
  /// Dark-mode gray palette, scale step 700 (Color(0xFFB0B3BA)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray700Dark = Color(0xFFB0B3BA);
  /// Dark-mode gray palette, scale step 800 (Color(0xFFDCDEE3)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray800Dark = Color(0xFFDCDEE3);
  /// Dark-mode gray palette, scale step 900 (Color(0xFFE9EAEC)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray900Dark = Color(0xFFE9EAEC);
  /// Dark-mode gray palette, scale step 1000 (Color(0xFFF3F4F5)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color gray1000Dark = Color(0xFFF3F4F5);

  /// Light-mode gray alpha palette, scale step 100.
  static const Color grayAlpha100Light = Color(0x08002040);

  /// Light-mode gray alpha palette, scale step 200.
  static const Color grayAlpha200Light = Color(0x0D14273B);

  /// Light-mode gray alpha palette, scale step 300.
  static const Color grayAlpha300Light = Color(0x11000F2D);

  /// Light-mode gray alpha palette, scale step 400.
  static const Color grayAlpha400Light = Color(0x23000F33);

  /// Light-mode gray alpha palette, scale step 500.
  static const Color grayAlpha500Light = Color(0x2F05102B);

  /// Light-mode gray alpha palette, scale step 600.
  static const Color grayAlpha600Light = Color(0x4F000A20);

  /// Light-mode gray alpha palette, scale step 700.
  static const Color grayAlpha700Light = Color(0x79000B1E);

  /// Light-mode gray alpha palette, scale step 800.
  static const Color grayAlpha800Light = Color(0xAB010D25);

  /// Light-mode gray alpha palette, scale step 900.
  static const Color grayAlpha900Light = Color(0xD5000711);

  /// Light-mode gray alpha palette, scale step 1000.
  static const Color grayAlpha1000Light = Color(0xE5000207);

  /// Dark-mode gray alpha palette, scale step 100.
  static const Color grayAlpha100Dark = Color(0x1BD0D9FF);

  /// Dark-mode gray alpha palette, scale step 200.
  static const Color grayAlpha200Dark = Color(0x25C8DDFF);

  /// Dark-mode gray alpha palette, scale step 300.
  static const Color grayAlpha300Dark = Color(0x35CFDDFF);

  /// Dark-mode gray alpha palette, scale step 400.
  static const Color grayAlpha400Dark = Color(0x46D0DEFF);

  /// Dark-mode gray alpha palette, scale step 500.
  static const Color grayAlpha500Dark = Color(0x6ADBE7FF);

  /// Dark-mode gray alpha palette, scale step 600.
  static const Color grayAlpha600Dark = Color(0x94E7EFFF);

  /// Dark-mode gray alpha palette, scale step 700.
  static const Color grayAlpha700Dark = Color(0xBAF1F5FF);

  /// Dark-mode gray alpha palette, scale step 800.
  static const Color grayAlpha800Dark = Color(0xE3F7F9FF);

  /// Dark-mode gray alpha palette, scale step 900.
  static const Color grayAlpha900Dark = Color(0xECFCFDFF);

  /// Dark-mode gray alpha palette, scale step 1000.
  static const Color grayAlpha1000Dark = Color(0xF5FDFEFF);
  // Carrot (Brand) Palette (Light)
  /// Light-mode carrot palette, scale step 100 (Color(0xFFFFF2EC)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot100Light = Color(0xFFFFF2EC);
  /// Light-mode carrot palette, scale step 200 (Color(0xFFFFE8DB)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot200Light = Color(0xFFFFE8DB);
  /// Light-mode carrot palette, scale step 300 (Color(0xFFFFD5C0)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot300Light = Color(0xFFFFD5C0);
  /// Light-mode carrot palette, scale step 400 (Color(0xFFFFB999)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot400Light = Color(0xFFFFB999);
  /// Light-mode carrot palette, scale step 500 (Color(0xFFFF9364)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot500Light = Color(0xFFFF9364);
  /// Light-mode carrot palette, scale step 600 (Color(0xFFFF6600)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot600Light = Color(0xFFFF6600);
  /// Light-mode carrot palette, scale step 700 (Color(0xFFE14D00)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot700Light = Color(0xFFE14D00);
  /// Light-mode carrot palette, scale step 800 (Color(0xFFB93901)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot800Light = Color(0xFFB93901);
  /// Light-mode carrot palette, scale step 900 (Color(0xFF862B00)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot900Light = Color(0xFF862B00);
  /// Light-mode carrot palette, scale step 1000 (Color(0xFF471601)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot1000Light = Color(0xFF471601);

  // Carrot (Brand) Palette (Dark)
  /// Dark-mode carrot palette, scale step 100 (Color(0xFF31241F)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot100Dark = Color(0xFF31241F);
  /// Dark-mode carrot palette, scale step 200 (Color(0xFF4B291C)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot200Dark = Color(0xFF4B291C);
  /// Dark-mode carrot palette, scale step 300 (Color(0xFF6B311C)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot300Dark = Color(0xFF6B311C);
  /// Dark-mode carrot palette, scale step 400 (Color(0xFF923600)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot400Dark = Color(0xFF923600);
  /// Dark-mode carrot palette, scale step 500 (Color(0xFFBD4201)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot500Dark = Color(0xFFBD4201);
  /// Dark-mode carrot palette, scale step 600 (Color(0xFFE65200)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot600Dark = Color(0xFFE65200);
  /// Dark-mode carrot palette, scale step 700 (Color(0xFFFF6600)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot700Dark = Color(0xFFFF6600);
  /// Dark-mode carrot palette, scale step 800 (Color(0xFFFF9E65)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot800Dark = Color(0xFFFF9E65);
  /// Dark-mode carrot palette, scale step 900 (Color(0xFFEECEBC)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot900Dark = Color(0xFFEECEBC);
  /// Dark-mode carrot palette, scale step 1000 (Color(0xFFF4EEEA)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color carrot1000Dark = Color(0xFFF4EEEA);

  // Blue Palette (Light)
  /// Light-mode blue palette, scale step 100 (Color(0xFFEFF6FF)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue100Light = Color(0xFFEFF6FF);
  /// Light-mode blue palette, scale step 200 (Color(0xFFE2EDFC)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue200Light = Color(0xFFE2EDFC);
  /// Light-mode blue palette, scale step 300 (Color(0xFFCBDFFA)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue300Light = Color(0xFFCBDFFA);
  /// Light-mode blue palette, scale step 400 (Color(0xFFAACEFD)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue400Light = Color(0xFFAACEFD);
  /// Light-mode blue palette, scale step 500 (Color(0xFF85B8FD)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue500Light = Color(0xFF85B8FD);
  /// Light-mode blue palette, scale step 600 (Color(0xFF5E98FE)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue600Light = Color(0xFF5E98FE);
  /// Light-mode blue palette, scale step 700 (Color(0xFF217CF9)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue700Light = Color(0xFF217CF9);
  /// Light-mode blue palette, scale step 800 (Color(0xFF135FCD)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue800Light = Color(0xFF135FCD);
  /// Light-mode blue palette, scale step 900 (Color(0xFF0B4596)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue900Light = Color(0xFF0B4596);
  /// Light-mode blue palette, scale step 1000 (Color(0xFF032451)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue1000Light = Color(0xFF032451);

  // Blue Palette (Dark)
  /// Dark-mode blue palette, scale step 100 (Color(0xFF202742)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue100Dark = Color(0xFF202742);
  /// Dark-mode blue palette, scale step 200 (Color(0xFF1E3352)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue200Dark = Color(0xFF1E3352);
  /// Dark-mode blue palette, scale step 300 (Color(0xFF1A4275)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue300Dark = Color(0xFF1A4275);
  /// Dark-mode blue palette, scale step 400 (Color(0xFF0F559E)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue400Dark = Color(0xFF0F559E);
  /// Dark-mode blue palette, scale step 500 (Color(0xFF1964D8)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue500Dark = Color(0xFF1964D8);
  /// Dark-mode blue palette, scale step 600 (Color(0xFF1E82EB)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue600Dark = Color(0xFF1E82EB);
  /// Dark-mode blue palette, scale step 700 (Color(0xFF41A2F9)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue700Dark = Color(0xFF41A2F9);
  /// Dark-mode blue palette, scale step 800 (Color(0xFF83BCF9)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue800Dark = Color(0xFF83BCF9);
  /// Dark-mode blue palette, scale step 900 (Color(0xFFB9D7FB)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue900Dark = Color(0xFFB9D7FB);
  /// Dark-mode blue palette, scale step 1000 (Color(0xFFE5F0FE)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color blue1000Dark = Color(0xFFE5F0FE);

  // Red Palette (Light)
  /// Light-mode red palette, scale step 100 (Color(0xFFFDF0F0)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red100Light = Color(0xFFFDF0F0);
  /// Light-mode red palette, scale step 200 (Color(0xFFFDE7E7)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red200Light = Color(0xFFFDE7E7);
  /// Light-mode red palette, scale step 300 (Color(0xFFFED4D2)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red300Light = Color(0xFFFED4D2);
  /// Light-mode red palette, scale step 400 (Color(0xFFFEB7B3)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red400Light = Color(0xFFFEB7B3);
  /// Light-mode red palette, scale step 500 (Color(0xFFFE928D)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red500Light = Color(0xFFFE928D);
  /// Light-mode red palette, scale step 600 (Color(0xFFFC6A66)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red600Light = Color(0xFFFC6A66);
  /// Light-mode red palette, scale step 700 (Color(0xFFFA342C)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red700Light = Color(0xFFFA342C);
  /// Light-mode red palette, scale step 800 (Color(0xFFCA1D13)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red800Light = Color(0xFFCA1D13);
  /// Light-mode red palette, scale step 900 (Color(0xFF921708)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red900Light = Color(0xFF921708);
  /// Light-mode red palette, scale step 1000 (Color(0xFF4A1209)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red1000Light = Color(0xFF4A1209);

  // Red Palette (Dark)
  /// Dark-mode red palette, scale step 100 (Color(0xFF322323)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red100Dark = Color(0xFF322323);
  /// Dark-mode red palette, scale step 200 (Color(0xFF4F2624)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red200Dark = Color(0xFF4F2624);
  /// Dark-mode red palette, scale step 300 (Color(0xFF742826)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red300Dark = Color(0xFF742826);
  /// Dark-mode red palette, scale step 400 (Color(0xFFA12621)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red400Dark = Color(0xFFA12621);
  /// Dark-mode red palette, scale step 500 (Color(0xFFCA2319)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red500Dark = Color(0xFFCA2319);
  /// Dark-mode red palette, scale step 600 (Color(0xFFF73526)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red600Dark = Color(0xFFF73526);
  /// Dark-mode red palette, scale step 700 (Color(0xFFFF6E60)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red700Dark = Color(0xFFFF6E60);
  /// Dark-mode red palette, scale step 800 (Color(0xFFFFA299)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red800Dark = Color(0xFFFFA299);
  /// Dark-mode red palette, scale step 900 (Color(0xFFF8C5C3)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red900Dark = Color(0xFFF8C5C3);
  /// Dark-mode red palette, scale step 1000 (Color(0xFFFDF2F2)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color red1000Dark = Color(0xFFFDF2F2);

  // Green Palette (Light)
  /// Light-mode green palette, scale step 100 (Color(0xFFEDFAF6)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green100Light = Color(0xFFEDFAF6);
  /// Light-mode green palette, scale step 200 (Color(0xFFD9F6E9)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green200Light = Color(0xFFD9F6E9);
  /// Light-mode green palette, scale step 300 (Color(0xFFB9E9D2)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green300Light = Color(0xFFB9E9D2);
  /// Light-mode green palette, scale step 400 (Color(0xFF7DDCB3)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green400Light = Color(0xFF7DDCB3);
  /// Light-mode green palette, scale step 500 (Color(0xFF42C593)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green500Light = Color(0xFF42C593);
  /// Light-mode green palette, scale step 600 (Color(0xFF10AB7D)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green600Light = Color(0xFF10AB7D);
  /// Light-mode green palette, scale step 700 (Color(0xFF079171)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green700Light = Color(0xFF079171);
  /// Light-mode green palette, scale step 800 (Color(0xFF00745F)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green800Light = Color(0xFF00745F);
  /// Light-mode green palette, scale step 900 (Color(0xFF075445)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green900Light = Color(0xFF075445);
  /// Light-mode green palette, scale step 1000 (Color(0xFF0A2B24)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green1000Light = Color(0xFF0A2B24);

  // Green Palette (Dark)
  /// Dark-mode green palette, scale step 100 (Color(0xFF202926)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green100Dark = Color(0xFF202926);
  /// Dark-mode green palette, scale step 200 (Color(0xFF20362E)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green200Dark = Color(0xFF20362E);
  /// Dark-mode green palette, scale step 300 (Color(0xFF20493B)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green300Dark = Color(0xFF20493B);
  /// Dark-mode green palette, scale step 400 (Color(0xFF19604C)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green400Dark = Color(0xFF19604C);
  /// Dark-mode green palette, scale step 500 (Color(0xFF117956)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green500Dark = Color(0xFF117956);
  /// Dark-mode green palette, scale step 600 (Color(0xFF1B946D)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green600Dark = Color(0xFF1B946D);
  /// Dark-mode green palette, scale step 700 (Color(0xFF22B27F)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green700Dark = Color(0xFF22B27F);
  /// Dark-mode green palette, scale step 800 (Color(0xFF35CE9A)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green800Dark = Color(0xFF35CE9A);
  /// Dark-mode green palette, scale step 900 (Color(0xFF93E5C0)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green900Dark = Color(0xFF93E5C0);
  /// Dark-mode green palette, scale step 1000 (Color(0xFFD4F6EF)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color green1000Dark = Color(0xFFD4F6EF);

  // Yellow Palette (Light)
  /// Light-mode yellow palette, scale step 100 (Color(0xFFFFF7DE)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow100Light = Color(0xFFFFF7DE);
  /// Light-mode yellow palette, scale step 200 (Color(0xFFFDEFB9)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow200Light = Color(0xFFFDEFB9);
  /// Light-mode yellow palette, scale step 300 (Color(0xFFFBDC65)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow300Light = Color(0xFFFBDC65);
  /// Light-mode yellow palette, scale step 400 (Color(0xFFE9C647)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow400Light = Color(0xFFE9C647);
  /// Light-mode yellow palette, scale step 500 (Color(0xFFD4AB28)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow500Light = Color(0xFFD4AB28);
  /// Light-mode yellow palette, scale step 600 (Color(0xFFC49725)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow600Light = Color(0xFFC49725);
  /// Light-mode yellow palette, scale step 700 (Color(0xFF9B7821)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow700Light = Color(0xFF9B7821);
  /// Light-mode yellow palette, scale step 800 (Color(0xFF755B22)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow800Light = Color(0xFF755B22);
  /// Light-mode yellow palette, scale step 900 (Color(0xFF4F3E1F)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow900Light = Color(0xFF4F3E1F);
  /// Light-mode yellow palette, scale step 1000 (Color(0xFF2C2512)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow1000Light = Color(0xFF2C2512);

  // Yellow Palette (Dark)
  /// Dark-mode yellow palette, scale step 100 (Color(0xFF302819)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow100Dark = Color(0xFF302819);
  /// Dark-mode yellow palette, scale step 200 (Color(0xFF413218)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow200Dark = Color(0xFF413218);
  /// Dark-mode yellow palette, scale step 300 (Color(0xFF543E15)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow300Dark = Color(0xFF543E15);
  /// Dark-mode yellow palette, scale step 400 (Color(0xFF714E15)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow400Dark = Color(0xFF714E15);
  /// Dark-mode yellow palette, scale step 500 (Color(0xFF91601B)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow500Dark = Color(0xFF91601B);
  /// Dark-mode yellow palette, scale step 600 (Color(0xFFB6720D)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow600Dark = Color(0xFFB6720D);
  /// Dark-mode yellow palette, scale step 700 (Color(0xFFCA901C)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow700Dark = Color(0xFFCA901C);
  /// Dark-mode yellow palette, scale step 800 (Color(0xFFDAB156)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow800Dark = Color(0xFFDAB156);
  /// Dark-mode yellow palette, scale step 900 (Color(0xFFE5D49B)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color yellow900Dark = Color(0xFFE5D49B);
  /// Dark-mode yellow palette, scale step 1000 (Color(0xFFF7F0CD)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const yellow1000Dark = Color(0xFFF7F0CD);

  // Purple Palette (Light)
  /// Light-mode purple palette, scale step 100 (Color(0xFFF5F3FE)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple100Light = Color(0xFFF5F3FE);
  /// Light-mode purple palette, scale step 200 (Color(0xFFEFEAFE)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple200Light = Color(0xFFEFEAFE);
  /// Light-mode purple palette, scale step 300 (Color(0xFFE1D8FF)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple300Light = Color(0xFFE1D8FF);
  /// Light-mode purple palette, scale step 400 (Color(0xFFD0C0FF)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple400Light = Color(0xFFD0C0FF);
  /// Light-mode purple palette, scale step 500 (Color(0xFFB8A1FF)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple500Light = Color(0xFFB8A1FF);
  /// Light-mode purple palette, scale step 600 (Color(0xFF9F84FB)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple600Light = Color(0xFF9F84FB);
  /// Light-mode purple palette, scale step 700 (Color(0xFF8969EA)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple700Light = Color(0xFF8969EA);
  /// Light-mode purple palette, scale step 800 (Color(0xFF6D50CB)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple800Light = Color(0xFF6D50CB);
  /// Light-mode purple palette, scale step 900 (Color(0xFF50379B)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple900Light = Color(0xFF50379B);
  /// Light-mode purple palette, scale step 1000 (Color(0xFF29175D)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple1000Light = Color(0xFF29175D);

  // Purple Palette (Dark)
  /// Dark-mode purple palette, scale step 100 (Color(0xFF28213B)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple100Dark = Color(0xFF28213B);
  /// Dark-mode purple palette, scale step 200 (Color(0xFF3B2873)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple200Dark = Color(0xFF3B2873);
  /// Dark-mode purple palette, scale step 300 (Color(0xFF443081)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple300Dark = Color(0xFF443081);
  /// Dark-mode purple palette, scale step 400 (Color(0xFF5A3BB1)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple400Dark = Color(0xFF5A3BB1);
  /// Dark-mode purple palette, scale step 500 (Color(0xFF764FD9)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple500Dark = Color(0xFF764FD9);
  /// Dark-mode purple palette, scale step 600 (Color(0xFF8E6BEE)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple600Dark = Color(0xFF8E6BEE);
  /// Dark-mode purple palette, scale step 700 (Color(0xFFA78DF0)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple700Dark = Color(0xFFA78DF0);
  /// Dark-mode purple palette, scale step 800 (Color(0xFFBEADF2)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple800Dark = Color(0xFFBEADF2);
  /// Dark-mode purple palette, scale step 900 (Color(0xFFD9CEFA)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple900Dark = Color(0xFFD9CEFA);
  /// Dark-mode purple palette, scale step 1000 (Color(0xFFF0EDFC)).
  ///
  /// A raw scale token; use semantic colors for UI roles.
  static const Color purple1000Dark = Color(0xFFF0EDFC);

  // Static Colors & Alpha Tokens
  /// Theme-independent opaque black palette color (Color(0xFF000000)).
  static const Color staticBlack = Color(0xFF000000);
  /// Theme-independent black overlay color, alpha scale 100 (Color(0x07000000)).
  static const Color staticBlackAlpha100 = Color(0x07000000);
  /// Theme-independent black overlay color, alpha scale 200 (Color(0x0C000000)).
  static const Color staticBlackAlpha200 = Color(0x0C000000);
  /// Theme-independent black overlay color, alpha scale 300 (Color(0x10000000)).
  static const Color staticBlackAlpha300 = Color(0x10000000);
  /// Theme-independent black overlay color, alpha scale 400 (Color(0x21000000)).
  static const Color staticBlackAlpha400 = Color(0x21000000);
  /// Theme-independent black overlay color, alpha scale 500 (Color(0x2C000000)).
  static const Color staticBlackAlpha500 = Color(0x2C000000);
  /// Theme-independent black overlay color, alpha scale 600 (Color(0x4C000000)).
  static const Color staticBlackAlpha600 = Color(0x4C000000);
  /// Theme-independent black overlay color, alpha scale 700 (Color(0x74000000)).
  static const Color staticBlackAlpha700 = Color(0x74000000);
  /// Theme-independent black overlay color, alpha scale 800 (Color(0xA2000000)).
  static const Color staticBlackAlpha800 = Color(0xA2000000);
  /// Theme-independent black overlay color, alpha scale 900 (Color(0xD0000000)).
  static const Color staticBlackAlpha900 = Color(0xD0000000);
  /// Theme-independent black overlay color, alpha scale 1000 (Color(0xE3000000)).
  static const Color staticBlackAlpha1000 = Color(0xE3000000);

  /// Theme-independent opaque white palette color (Color(0xFFFFFFFF)).
  static const Color staticWhite = Color(0xFFFFFFFF);
  /// Theme-independent white overlay color, alpha scale 50 (Color(0x0DFFFFFF)).
  static const Color staticWhiteAlpha50 = Color(0x0DFFFFFF);
  /// Theme-independent white overlay color, alpha scale 100 (Color(0x17FFFFFF)).
  static const Color staticWhiteAlpha100 = Color(0x17FFFFFF);
  /// Theme-independent white overlay color, alpha scale 200 (Color(0x20FFFFFF)).
  static const Color staticWhiteAlpha200 = Color(0x20FFFFFF);
  /// Theme-independent white overlay color, alpha scale 300 (Color(0x2EFFFFFF)).
  static const Color staticWhiteAlpha300 = Color(0x2EFFFFFF);
  /// Theme-independent white overlay color, alpha scale 400 (Color(0x3DFFFFFF)).
  static const Color staticWhiteAlpha400 = Color(0x3DFFFFFF);
  /// Theme-independent white overlay color, alpha scale 500 (Color(0x60FFFFFF)).
  static const Color staticWhiteAlpha500 = Color(0x60FFFFFF);
  /// Theme-independent white overlay color, alpha scale 600 (Color(0x8BFFFFFF)).
  static const Color staticWhiteAlpha600 = Color(0x8BFFFFFF);
  /// Theme-independent white overlay color, alpha scale 700 (Color(0xB3FFFFFF)).
  static const Color staticWhiteAlpha700 = Color(0xB3FFFFFF);
  /// Theme-independent white overlay color, alpha scale 800 (Color(0xDEFFFFFF)).
  static const Color staticWhiteAlpha800 = Color(0xDEFFFFFF);
  /// Theme-independent white overlay color, alpha scale 900 (Color(0xEAFFFFFF)).
  static const Color staticWhiteAlpha900 = Color(0xEAFFFFFF);
  /// Theme-independent white overlay color, alpha scale 1000 (Color(0xF4FFFFFF)).
  static const Color staticWhiteAlpha1000 = Color(0xF4FFFFFF);
}
