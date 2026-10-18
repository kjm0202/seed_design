import 'dart:ui';

/// Raw color palette defined in SEED Design System.
///
/// Contains absolute color scales across all hues and alpha channels.
class SeedPalette {
  const SeedPalette._();

  // Gray Palette (Light)
  static const Color gray00Light = Color(0xFFFFFFFF);
  static const Color gray100Light = Color(0xFFF7F8F9);
  static const Color gray200Light = Color(0xFFF3F4F5);
  static const Color gray300Light = Color(0xFFEEEFF1);
  static const Color gray400Light = Color(0xFFDCDEE3);
  static const Color gray500Light = Color(0xFFD1D3D8);
  static const Color gray600Light = Color(0xFFB0B3BA);
  static const Color gray700Light = Color(0xFF868B94);
  static const Color gray800Light = Color(0xFF555D6D);
  static const Color gray900Light = Color(0xFF2A3038);
  static const Color gray1000Light = Color(0xFF1A1C20);

  // Gray Palette (Dark)
  static const Color gray00Dark = Color(0xFF000000);
  static const Color gray100Dark = Color(0xFF16171B);
  static const Color gray200Dark = Color(0xFF1D2025);
  static const Color gray300Dark = Color(0xFF2B2E35);
  static const Color gray400Dark = Color(0xFF393D46);
  static const Color gray500Dark = Color(0xFF5B606A);
  static const Color gray600Dark = Color(0xFF868B94);
  static const Color gray700Dark = Color(0xFFB0B3BA);
  static const Color gray800Dark = Color(0xFFDCDEE3);
  static const Color gray900Dark = Color(0xFFE9EAEC);
  static const Color gray1000Dark = Color(0xFFF3F4F5);

  // Carrot (Brand) Palette (Light)
  static const Color carrot100Light = Color(0xFFFFF2EC);
  static const Color carrot200Light = Color(0xFFFFE8DB);
  static const Color carrot300Light = Color(0xFFFFD5C0);
  static const Color carrot400Light = Color(0xFFFFB999);
  static const Color carrot500Light = Color(0xFFFF9364);
  static const Color carrot600Light = Color(0xFFFF6600);
  static const Color carrot700Light = Color(0xFFE14D00);
  static const Color carrot800Light = Color(0xFFB93901);
  static const Color carrot900Light = Color(0xFF862B00);
  static const Color carrot1000Light = Color(0xFF471601);

  // Carrot (Brand) Palette (Dark)
  static const Color carrot100Dark = Color(0xFF31241F);
  static const Color carrot200Dark = Color(0xFF4B291C);
  static const Color carrot300Dark = Color(0xFF6B311C);
  static const Color carrot400Dark = Color(0xFF923600);
  static const Color carrot500Dark = Color(0xFFBD4201);
  static const Color carrot600Dark = Color(0xFFE65200);
  static const Color carrot700Dark = Color(0xFFFF6600);
  static const Color carrot800Dark = Color(0xFFFF9E65);
  static const Color carrot900Dark = Color(0xFFEECEBC);
  static const Color carrot1000Dark = Color(0xFFF4EEEA);

  // Blue Palette (Light)
  static const Color blue100Light = Color(0xFFEFF6FF);
  static const Color blue200Light = Color(0xFFE2EDFC);
  static const Color blue300Light = Color(0xFFCBDFFA);
  static const Color blue400Light = Color(0xFFAACEFD);
  static const Color blue500Light = Color(0xFF85B8FD);
  static const Color blue600Light = Color(0xFF5E98FE);
  static const Color blue700Light = Color(0xFF217CF9);
  static const Color blue800Light = Color(0xFF135FCD);
  static const Color blue900Light = Color(0xFF0B4596);
  static const Color blue1000Light = Color(0xFF032451);

  // Blue Palette (Dark)
  static const Color blue100Dark = Color(0xFF202742);
  static const Color blue200Dark = Color(0xFF1E3352);
  static const Color blue300Dark = Color(0xFF1A4275);
  static const Color blue400Dark = Color(0xFF0F559E);
  static const Color blue500Dark = Color(0xFF1964D8);
  static const Color blue600Dark = Color(0xFF1E82EB);
  static const Color blue700Dark = Color(0xFF41A2F9);
  static const Color blue800Dark = Color(0xFF83BCF9);
  static const Color blue900Dark = Color(0xFFB9D7FB);
  static const Color blue1000Dark = Color(0xFFE5F0FE);

  // Red Palette (Light)
  static const Color red100Light = Color(0xFFFDF0F0);
  static const Color red200Light = Color(0xFFFDE7E7);
  static const Color red300Light = Color(0xFFFED4D2);
  static const Color red400Light = Color(0xFFFEB7B3);
  static const Color red500Light = Color(0xFFFE928D);
  static const Color red600Light = Color(0xFFFC6A66);
  static const Color red700Light = Color(0xFFFA342C);
  static const Color red800Light = Color(0xFFCA1D13);
  static const Color red900Light = Color(0xFF921708);
  static const Color red1000Light = Color(0xFF4A1209);

  // Red Palette (Dark)
  static const Color red100Dark = Color(0xFF322323);
  static const Color red200Dark = Color(0xFF4F2624);
  static const Color red300Dark = Color(0xFF742826);
  static const Color red400Dark = Color(0xFFA12621);
  static const Color red500Dark = Color(0xFFCA2319);
  static const Color red600Dark = Color(0xFFF73526);
  static const Color red700Dark = Color(0xFFFF6E60);
  static const Color red800Dark = Color(0xFFFFA299);
  static const Color red900Dark = Color(0xFFF8C5C3);
  static const Color red1000Dark = Color(0xFFFDF2F2);

  // Green Palette (Light)
  static const Color green100Light = Color(0xFFEDFAF6);
  static const Color green200Light = Color(0xFFD9F6E9);
  static const Color green300Light = Color(0xFFB9E9D2);
  static const Color green400Light = Color(0xFF7DDCB3);
  static const Color green500Light = Color(0xFF42C593);
  static const Color green600Light = Color(0xFF10AB7D);
  static const Color green700Light = Color(0xFF079171);
  static const Color green800Light = Color(0xFF00745F);
  static const Color green900Light = Color(0xFF075445);
  static const Color green1000Light = Color(0xFF0A2B24);

  // Green Palette (Dark)
  static const Color green100Dark = Color(0xFF202926);
  static const Color green200Dark = Color(0xFF20362E);
  static const Color green300Dark = Color(0xFF20493B);
  static const Color green400Dark = Color(0xFF19604C);
  static const Color green500Dark = Color(0xFF117956);
  static const Color green600Dark = Color(0xFF1B946D);
  static const Color green700Dark = Color(0xFF22B27F);
  static const Color green800Dark = Color(0xFF35CE9A);
  static const Color green900Dark = Color(0xFF93E5C0);
  static const Color green1000Dark = Color(0xFFD4F6EF);

  // Yellow Palette (Light)
  static const Color yellow100Light = Color(0xFFFFF7DE);
  static const Color yellow200Light = Color(0xFFFDEFB9);
  static const Color yellow300Light = Color(0xFFFBDC65);
  static const Color yellow400Light = Color(0xFFE9C647);
  static const Color yellow500Light = Color(0xFFD4AB28);
  static const Color yellow600Light = Color(0xFFC49725);
  static const Color yellow700Light = Color(0xFF9B7821);
  static const Color yellow800Light = Color(0xFF755B22);
  static const Color yellow900Light = Color(0xFF4F3E1F);
  static const Color yellow1000Light = Color(0xFF2C2512);

  // Yellow Palette (Dark)
  static const Color yellow100Dark = Color(0xFF302819);
  static const Color yellow200Dark = Color(0xFF413218);
  static const Color yellow300Dark = Color(0xFF543E15);
  static const Color yellow400Dark = Color(0xFF714E15);
  static const Color yellow500Dark = Color(0xFF91601B);
  static const Color yellow600Dark = Color(0xFFB6720D);
  static const Color yellow700Dark = Color(0xFFCA901C);
  static const Color yellow800Dark = Color(0xFFDAB156);
  static const Color yellow900Dark = Color(0xFFE5D49B);
  static const yellow1000Dark = Color(0xFFF7F0CD);

  // Purple Palette (Light)
  static const Color purple100Light = Color(0xFFF5F3FE);
  static const Color purple200Light = Color(0xFFEFEAFE);
  static const Color purple300Light = Color(0xFFE1D8FF);
  static const Color purple400Light = Color(0xFFD0C0FF);
  static const Color purple500Light = Color(0xFFB8A1FF);
  static const Color purple600Light = Color(0xFF9F84FB);
  static const Color purple700Light = Color(0xFF8969EA);
  static const Color purple800Light = Color(0xFF6D50CB);
  static const Color purple900Light = Color(0xFF50379B);
  static const Color purple1000Light = Color(0xFF29175D);

  // Purple Palette (Dark)
  static const Color purple100Dark = Color(0xFF28213B);
  static const Color purple200Dark = Color(0xFF3B2873);
  static const Color purple300Dark = Color(0xFF443081);
  static const Color purple400Dark = Color(0xFF5A3BB1);
  static const Color purple500Dark = Color(0xFF764FD9);
  static const Color purple600Dark = Color(0xFF8E6BEE);
  static const Color purple700Dark = Color(0xFFA78DF0);
  static const Color purple800Dark = Color(0xFFBEADF2);
  static const Color purple900Dark = Color(0xFFD9CEFA);
  static const Color purple1000Dark = Color(0xFFF0EDFC);

  // Static Colors & Alpha Tokens
  static const Color staticBlack = Color(0xFF000000);
  static const Color staticBlackAlpha100 = Color(0x07000000);
  static const Color staticBlackAlpha200 = Color(0x0C000000);
  static const Color staticBlackAlpha300 = Color(0x10000000);
  static const Color staticBlackAlpha400 = Color(0x21000000);
  static const Color staticBlackAlpha500 = Color(0x2C000000);
  static const Color staticBlackAlpha600 = Color(0x4C000000);
  static const Color staticBlackAlpha700 = Color(0x74000000);
  static const Color staticBlackAlpha800 = Color(0xA2000000);
  static const Color staticBlackAlpha900 = Color(0xD0000000);
  static const Color staticBlackAlpha1000 = Color(0xE3000000);

  static const Color staticWhite = Color(0xFFFFFFFF);
  static const Color staticWhiteAlpha50 = Color(0x0DFFFFFF);
  static const Color staticWhiteAlpha100 = Color(0x17FFFFFF);
  static const Color staticWhiteAlpha200 = Color(0x20FFFFFF);
  static const Color staticWhiteAlpha300 = Color(0x2EFFFFFF);
  static const Color staticWhiteAlpha400 = Color(0x3DFFFFFF);
  static const Color staticWhiteAlpha500 = Color(0x60FFFFFF);
  static const Color staticWhiteAlpha600 = Color(0x8BFFFFFF);
  static const Color staticWhiteAlpha700 = Color(0xB3FFFFFF);
  static const Color staticWhiteAlpha800 = Color(0xDEFFFFFF);
  static const Color staticWhiteAlpha900 = Color(0xEAFFFFFF);
  static const Color staticWhiteAlpha1000 = Color(0xF4FFFFFF);
}
