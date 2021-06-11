import 'dart:ui';

import 'package:get/get.dart';

import 'austraylia_AU/polish_PL.dart';
import 'en_US/en_us_translation.dart';
import 'france_FR/france_FR.dart';
import 'german_DE/de_translation.dart';
import 'indian_IN/indian_IN.dart';
import 'italy_IT/italy_IT.dart';
import 'japan_JP/japan_JP.dart';
import 'korean_KO/korean_KO.dart';
import 'romania_RO/romania_RO.dart';
import 'russian/ru_translation.dart';
import 'spanish_US/spanish_US.dart';
import 'ukraina_UA/ukraina_UA.dart';
import 'vietnam_VI/vietnam_vi.dart';

class AppTranslation extends Translations {
  static final languageCodes = [
    'en',
    'ru',
    'de',
    'ro',
    'in',
    'it',
    'fr',
    'ja',
    'ko',
    'es',
    'ua',
    'vi',
    'pl'
  ];
  static final locales = [
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('ru', 'RU'),
    Locale('ro', 'RO'),
    Locale('hi', 'IN'),
    Locale('it', 'IT'),
    Locale('fr', 'FR'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
    Locale('es', 'ES'),
    Locale('ua', 'UA'),
    Locale('vi', 'VN'),
    Locale('pl', 'PL'),
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
  Map<String, Map<String, String>> get keys => {
        'en': en,
        'de': de,
        'ru': ru,
        'ro': ro,
        'hi': indian,
        'it': it,
        'fr': fr,
        'ja': ja,
        'ko': ko,
        'es': es_us,
        'ua': ua,
        'vi': vi,
        'pl': pl
      };
}
