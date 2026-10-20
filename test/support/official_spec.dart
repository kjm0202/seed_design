import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';

final officialSeed = jsonDecode(
  File('test/fixtures/seed_official_reference.json').readAsStringSync(),
) as Map<String, dynamic>;

dynamic resolveOfficial(dynamic value, {bool dark = false}) {
  if (value is String && value.startsWith(r'$')) {
    final modes = officialSeed['tokens'][value] as Map<String, dynamic>;
    return resolveOfficial(
      modes[dark ? 'theme-dark' : 'theme-light'] ?? modes['default'],
      dark: dark,
    );
  }
  if (value is String) {
    if (value.endsWith('rem')) {
      return double.parse(value.substring(0, value.length - 3)) * 16;
    }
    if (value.endsWith('px')) {
      return double.parse(value.substring(0, value.length - 2));
    }
    if (value.endsWith('ms')) {
      return double.parse(value.substring(0, value.length - 2));
    }
    if (value.endsWith('s')) {
      return double.parse(value.substring(0, value.length - 1)) * 1000;
    }
  }
  return value;
}

dynamic officialProp(
  String component,
  String variant,
  String slot,
  String property, {
  String state = 'enabled',
  bool dark = false,
}) => resolveOfficial(
  officialSeed['components'][component][variant][state][slot][property],
  dark: dark,
);

Color officialColor(String value, {bool dark = false}) {
  final hex = (resolveOfficial(value, dark: dark) as String).substring(1);
  return Color(
    int.parse(
      hex.length == 6 ? 'ff$hex' : '${hex.substring(6)}${hex.substring(0, 6)}',
      radix: 16,
    ),
  );
}
