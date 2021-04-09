import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/shared/strings.dart';

enum TempEnum { C, F }
enum WindEnum { kmh, ms }
enum PressureEnum { mBar, bar, mmHg }
enum VisibilityEnum { km, mile }
enum TimeEnum { twelve, twentyFour }
enum DateEnum { dd, mm, yy }
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

  TempEnum setValue(String value) {
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
      default:
        return kmh;
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
      default:
        return mBar;
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
}

extension DateExtenstion on DateEnum {
  String get value {
    switch (this) {
      case DateEnum.dd:
        return ddMMYY;
      case DateEnum.mm:
        return mmDDYY;
      case DateEnum.yy:
        return yyMMDD;
      default:
        return ddMMYY;
    }
  }
}

class SettingBloc extends BlocBase {
  bool _isOnNotify = false;
  WeatherResponse _weatherResponse;
  TempEnum _tempEnum = TempEnum.C;

  BehaviorSubject<bool> _notificationSubject = BehaviorSubject();
  BehaviorSubject<SettingEnum> _settingBehavior = BehaviorSubject();

  onOffNotification(bool isOn, WeatherResponse weatherResponse) {
    _isOnNotify = isOn;
    _weatherResponse = weatherResponse;
    _notificationSubject.add(_isOnNotify);
  }

  changeSetting(String value,SettingEnum settingEnum) {
    switch (settingEnum){
      case SettingEnum.TempEnum:
        _tempEnum = _tempEnum.setValue(value);
        break;
      case SettingEnum.WindEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.PressureEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.VisibilityEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.TimeEnum:
        // TODO: Handle this case.
        break;
      case SettingEnum.DateEnum:
        // TODO: Handle this case.
        break;
    }
    _settingBehavior.add(settingEnum);
  }

  @override
  void dispose() {
    _notificationSubject.close();
    _settingBehavior.close();
  }

  TempEnum get tempEnum => _tempEnum;

  bool get isOnNotification => _isOnNotify;

  WeatherResponse get weatherResponse => _weatherResponse;

  Stream get notificationStream => _notificationSubject.stream;

  Stream get settingStream => _settingBehavior.stream;
}

final settingBloc = SettingBloc();
