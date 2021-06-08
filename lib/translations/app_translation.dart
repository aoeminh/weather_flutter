import 'dart:ui';

import 'package:get/get.dart';

import 'en_US/en_us_translation.dart';
import 'german_DE/de_translation.dart';
import 'indian_IN/indian_IN.dart';
import 'romania_RO/romania_RO.dart';
import 'russian/ru_translation.dart';

class AppTranslation extends Translations {
  static final languageCodes = [
    'en',
    'ru',
    'de',
    'ro',
    'in'
  ];
  static final locales = [
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('ru', 'RU'),
    Locale('ro', 'RO'),
    Locale('hi', 'IN'),
  ];

  static final Locale? locale = _getLocale();

  static Locale? _getLocale() {
    final languageCode = Get.deviceLocale!.languageCode;
    for (int i = 0; i < locales.length; i++) {
      if (languageCode == locales[i].languageCode) return locales[i];
    }
    return Locale('en', 'US');
  }

  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys =>
      {'en': en, 'de': de, 'ru': ru, 'ro': ro, 'hi': indian};
}
