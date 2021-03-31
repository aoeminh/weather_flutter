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
  bool _isOnNotify = true;
  WeatherResponse _weatherResponse;

  BehaviorSubject<bool> _notificationSubject = BehaviorSubject();

  onOffNotification(bool isOn, WeatherResponse weatherResponse) {
    _isOnNotify = isOn;
    _weatherResponse = weatherResponse;
    _notificationSubject.add(_isOnNotify);
  }

  @override
  void dispose() {
    _notificationSubject.close();
  }

  bool get isOnNotification => _isOnNotify;

  WeatherResponse get weatherResponse => _weatherResponse;

  Stream get notificationStream => _notificationSubject.stream;
}

final settingBloc = SettingBloc();
