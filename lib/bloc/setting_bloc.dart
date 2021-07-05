import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/translations/app_translation.dart';

import '../model/weather_response.dart';
import '../shared/strings.dart';
import '../ui/screen/weather_screen.dart';
import '../utils/share_preferences.dart';
import 'base_bloc.dart';

enum TempEnum { C, F }
enum WindEnum { kmh, mph, ms }
enum PressureEnum { mBar, bar, psi, inHg, mmHg }
enum VisibilityEnum { km, mile }
enum TimeEnum { twelve, twentyFour }
enum DateEnum { ddMMyyyyy, mmddyyyyy, yyyymmdd }
enum LanguageEnum {
  en,
  ru,
  de,
  ro,
  ind,
  it,
  fr,
  ja,
  ko,
  es,
  ua,
  vi,
  pl,
  az,
  tr
}
enum SettingEnum {
  TempEnum,
  WindEnum,
  PressureEnum,
  VisibilityEnum,
  TimeEnum,
  DateEnum,
  Language
}

extension TempExtenstion on TempEnum {
  String get value {
    switch (this) {
      case TempEnum.C:
        return '$degreeC';
      case TempEnum.F:
        return '$degreeF';
      default:
        return '$degreeC';
    }
  }

  TempEnum setValue(String? value) {
    switch (value) {
      case degreeC:
        return TempEnum.C;
      case degreeF:
        return TempEnum.F;
      default:
        return TempEnum.C;
    }
  }
}

extension WindExtenstion on WindEnum {
  String get value {
    switch (this) {
      case WindEnum.kmh:
        return kmh;
      case WindEnum.ms:
        return ms;
      case WindEnum.mph:
        return mph;
      default:
        return kmh;
    }
  }

  WindEnum setValue(String? value) {
    switch (value) {
      case kmh:
        return WindEnum.kmh;
      case mph:
        return WindEnum.mph;
      case ms:
        return WindEnum.ms;
      default:
        return WindEnum.kmh;
    }
  }
}

extension PressureExtenstion on PressureEnum {
  String get value {
    switch (this) {
      case PressureEnum.mBar:
        return mBar;
      case PressureEnum.bar:
        return bar;
      case PressureEnum.mmHg:
        return mmHg;
      case PressureEnum.psi:
        return psi;
      case PressureEnum.inHg:
        return inHg;
      default:
        return mBar;
    }
  }

  PressureEnum setValue(String? value) {
    switch (value) {
      case mBar:
        return PressureEnum.mBar;
      case bar:
        return PressureEnum.bar;
      case mmHg:
        return PressureEnum.mmHg;
      case psi:
        return PressureEnum.psi;
      case inHg:
        return PressureEnum.inHg;
      default:
        return PressureEnum.mBar;
    }
  }
}

extension VisibilityExtenstion on VisibilityEnum {
  String get value {
    switch (this) {
      case VisibilityEnum.km:
        return km;
      case VisibilityEnum.mile:
        return mile;
      default:
        return km;
    }
  }

  VisibilityEnum setValue(String? value) {
    switch (value) {
      case km:
        return VisibilityEnum.km;
      case mile:
        return VisibilityEnum.mile;
      default:
        return VisibilityEnum.km;
    }
  }
}

extension TimeExtenstion on TimeEnum {
  String get value {
    switch (this) {
      case TimeEnum.twelve:
        return twelveClock;
      case TimeEnum.twentyFour:
        return twentyFourClock;
      default:
        return twentyFourClock;
    }
  }

  TimeEnum setValue(String? value) {
    switch (value) {
      case twelveClock:
        return TimeEnum.twelve;
      case twentyFourClock:
        return TimeEnum.twentyFour;
      default:
        return TimeEnum.twelve;
    }
  }
}

extension DateExtenstion on DateEnum {
  String get value {
    switch (this) {
      case DateEnum.ddMMyyyyy:
        return ddMMYY;
      case DateEnum.mmddyyyyy:
        return mmDDYY;
      case DateEnum.yyyymmdd:
        return yyMMDD;
      default:
        return ddMMYY;
    }
  }

  DateEnum setValue(String? value) {
    switch (value) {
      case ddMMYY:
        return DateEnum.ddMMyyyyy;
      case mmDDYY:
        return DateEnum.mmddyyyyy;
      case yyMMDD:
        return DateEnum.yyyymmdd;
      default:
        return DateEnum.ddMMyyyyy;
    }
  }
}

extension LanguageExtention on LanguageEnum {
  String get value {
    switch (this) {
      case LanguageEnum.en:
        return 'en'.tr;
      case LanguageEnum.ru:
        return 'ru'.tr;
      case LanguageEnum.de:
        return 'de'.tr;
      case LanguageEnum.ro:
        return 'ro'.tr;
      case LanguageEnum.ind:
        return 'hi'.tr;
      case LanguageEnum.it:
        return 'it'.tr;
      case LanguageEnum.fr:
        return 'fr'.tr;
      case LanguageEnum.ja:
        return 'ja'.tr;
      case LanguageEnum.ko:
        return 'ko'.tr;
      case LanguageEnum.es:
        return 'es'.tr;
      case LanguageEnum.ua:
        return 'ua'.tr;
      case LanguageEnum.vi:
        return 'vi'.tr;
      case LanguageEnum.pl:
        return 'pl'.tr;
      case LanguageEnum.az:
        return 'az'.tr;
      case LanguageEnum.tr:
        return 'tr'.tr;
      default:
        return 'en'.tr;
    }
  }

  String get languageCode {
    switch (this) {
      case LanguageEnum.en:
        return 'en';
      case LanguageEnum.ru:
        return 'ru';
      case LanguageEnum.de:
        return 'de';
      case LanguageEnum.ro:
        return 'ro';
      case LanguageEnum.ind:
        return 'hi';
      case LanguageEnum.it:
        return 'it';
      case LanguageEnum.fr:
        return 'fr';
      case LanguageEnum.ja:
        return 'ja';
      case LanguageEnum.ko:
        return 'ko';
      case LanguageEnum.es:
        return 'es';
      case LanguageEnum.ua:
        return 'ua';
      case LanguageEnum.vi:
        return 'vi';
      case LanguageEnum.pl:
        return 'pl';
      case LanguageEnum.az:
        return 'az';
      case LanguageEnum.tr:
        return 'tr';
      default:
        return 'en';
    }
  }

  LanguageEnum setValue(String value) {
    switch (value) {
      case 'en':
        return LanguageEnum.en;
      case 'ru':
        return LanguageEnum.ru;
      case 'de':
        return LanguageEnum.de;
      case 'ro':
        return LanguageEnum.ro;
      case 'hi':
        return LanguageEnum.ind;
      case 'it':
        return LanguageEnum.it;
      case 'fr':
        return LanguageEnum.fr;
      case 'ja':
        return LanguageEnum.ja;
      case 'ko':
        return LanguageEnum.ko;
      case 'es':
        return LanguageEnum.es;
      case 'ua':
        return LanguageEnum.ua;
      case 'vi':
        return LanguageEnum.vi;
      case 'pl':
        return LanguageEnum.pl;
      case 'az':
        return LanguageEnum.az;
      case 'tr':
        return LanguageEnum.tr;
      default:
        return LanguageEnum.en;
    }
  }
}

class SettingBloc extends BlocBase {
  bool _isOnNotify = false;
  WeatherResponse? _weatherResponse;
  WeatherData? _weatherData;
  TempEnum _tempEnum = TempEnum.C;
  WindEnum _windEnum = WindEnum.kmh;
  PressureEnum _pressureEnum = PressureEnum.mBar;
  VisibilityEnum _visibilityEnum = VisibilityEnum.km;
  TimeEnum _timeEnum = TimeEnum.twentyFour;
  DateEnum _dateEnum = DateEnum.mmddyyyyy;
  LanguageEnum _languageEnum = LanguageEnum.en;

  BehaviorSubject<bool> _notificationSubject = BehaviorSubject();
  PublishSubject<SettingEnum> _settingBehavior = PublishSubject();

  onOffNotification(bool isOn, WeatherResponse? weatherResponse) {
    _isOnNotify = isOn;
    _weatherResponse = weatherResponse;
    _notificationSubject.add(_isOnNotify);
  }

  changeSetting(
    String? value,
    SettingEnum settingEnum,
  ) {
    switch (settingEnum) {
      case SettingEnum.TempEnum:
        _tempEnum = _tempEnum.setValue(value);
        break;
      case SettingEnum.WindEnum:
        _windEnum = _windEnum.setValue(value);
        break;
      case SettingEnum.PressureEnum:
        _pressureEnum = _pressureEnum.setValue(value);
        break;
      case SettingEnum.VisibilityEnum:
        _visibilityEnum = _visibilityEnum.setValue(value);
        break;
      case SettingEnum.TimeEnum:
        _timeEnum = _timeEnum.setValue(value);
        break;
      case SettingEnum.DateEnum:
        _dateEnum = _dateEnum.setValue(value);
        break;
      case SettingEnum.Language:
        break;
    }
    _settingBehavior.add(settingEnum);
  }

  changeLanguageSetting(LanguageEnum? value) {
    _languageEnum = value!;
    updateLocale(value.languageCode);
    _settingBehavior.add(SettingEnum.Language);
  }

  saveSetting() async {
    await Preferences.saveTempSetting(_tempEnum.value);
    await Preferences.saveWindSetting(_windEnum.value);
    await Preferences.savePressureSetting(_pressureEnum.value);
    await Preferences.saveVisibilitySetting(_visibilityEnum.value);
    await Preferences.saveDateSetting(_dateEnum.value);
    await Preferences.saveTimeSetting(_timeEnum.value);
    await Preferences.saveLanguageSetting(_languageEnum.languageCode);
  }

  getSetting() async {
    _tempEnum = _tempEnum.setValue(await Preferences.getTempSetting());
    _windEnum = _windEnum.setValue(await Preferences.getWindSetting());
    _pressureEnum =
        _pressureEnum.setValue(await Preferences.getPressureSetting());
    _dateEnum = _dateEnum.setValue(await Preferences.getDateSetting());
    _timeEnum = _timeEnum.setValue(await Preferences.getTimeSetting());
    _visibilityEnum =
        _visibilityEnum.setValue(await Preferences.getVisibilitySetting());
    String languageCode = await Preferences.getLanguageSetting()?? Get.deviceLocale!.languageCode;
    _languageEnum = _languageEnum.setValue(languageCode);
    changeLanguageSetting(_languageEnum);
  }

  updateLocale(String languageCode) {
    AppTranslation.locales.forEach((element) {
      if (element.languageCode == languageCode) {
        Get.updateLocale(element);
      }
    });
  }

  @override
  void dispose() {
    _notificationSubject.close();
    _settingBehavior.close();
  }

  TempEnum get tempEnum => _tempEnum;

  WindEnum get windEnum => _windEnum;

  PressureEnum get pressureEnum => _pressureEnum;

  VisibilityEnum get visibilityEnum => _visibilityEnum;

  TimeEnum get timeEnum => _timeEnum;

  DateEnum get dateEnum => _dateEnum;

  LanguageEnum get languageEnum => _languageEnum;

  bool get isOnNotification => _isOnNotify;

  WeatherResponse? get weatherResponse => _weatherResponse;

  WeatherData? get weatherData => _weatherData;

  Stream get notificationStream => _notificationSubject.stream;

  Stream get settingStream => _settingBehavior.stream;
}

final settingBloc = SettingBloc();
