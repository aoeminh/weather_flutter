import 'package:rxdart/rxdart.dart';

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
enum SettingEnum {
  TempEnum,
  WindEnum,
  PressureEnum,
  VisibilityEnum,
  TimeEnum,
  DateEnum
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
        break;
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
        break;
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

  BehaviorSubject<bool> _notificationSubject = BehaviorSubject();
  PublishSubject<SettingEnum> _settingBehavior = PublishSubject();

  onOffNotification(bool isOn, WeatherResponse? weatherResponse) {
    _isOnNotify = isOn;
    _weatherResponse = weatherResponse;
    _notificationSubject.add(_isOnNotify);
  }

  changeSetting(String? value, SettingEnum settingEnum) {
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
    }
    _settingBehavior.add(settingEnum);
  }

  saveSetting()async {
    await Preferences.saveTempSetting(_tempEnum.value);
    await Preferences.saveWindSetting(_windEnum.value);
    await Preferences.savePressureSetting(_pressureEnum.value);
    await Preferences.saveVisibilitySetting(_visibilityEnum.value);
    await Preferences.saveDateSetting(_dateEnum.value);
    await Preferences.saveTimeSetting(_timeEnum.value);
  }

  getSetting() async {
    _tempEnum = _tempEnum.setValue(await Preferences.getTempSetting());
    _windEnum = _windEnum.setValue(await Preferences.getWindSetting());
    _pressureEnum =
        _pressureEnum.setValue(await Preferences.getPressureSetting());
    _windEnum = _windEnum.setValue(await Preferences.getWindSetting());
    _dateEnum = _dateEnum.setValue(await Preferences.getDateSetting());
    _timeEnum = _timeEnum.setValue(await Preferences.getTimeSetting());
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

  bool get isOnNotification => _isOnNotify;

  WeatherResponse? get weatherResponse => _weatherResponse;

  WeatherData? get weatherData => _weatherData;

  Stream get notificationStream => _notificationSubject.stream;

  Stream get settingStream => _settingBehavior.stream;
}

final settingBloc = SettingBloc();
