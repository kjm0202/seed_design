import 'package:intl/intl.dart' show DateFormat, Intl;
import 'package:material_ui/material_ui.dart';

/// Resolves the requested picker locale to a name supported by Intl.
String resolveSeedPickerLocale(BuildContext context, Locale? locale) {
  const fallback = 'en_US';
  final requested = (locale ?? Localizations.maybeLocaleOf(context))
      ?.toString();
  if (requested == null) return fallback;
  return Intl.verifiedLocale(
    requested,
    DateFormat.localeExists,
    onFailure: (_) => fallback,
  )!;
}
