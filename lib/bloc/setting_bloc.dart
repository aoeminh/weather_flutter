import 'package:rxdart/rxdart.dart';
import '../model/daily.dart';
import '../model/weather_forecast_response.dart';
import '../utils/utils.dart';
import 'base_bloc.dart';
import '../model/weather_forecast_7_day.dart';
import '../model/weather_forecast_list_response.dart';
import '../model/weather_response.dart';
import '../shared/strings.dart';
import '../ui/screen/weather_screen.dart';

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
  WeatherData _weatherData;
  TempEnum _tempEnum = TempEnum.C;

  BehaviorSubject<bool> _notificationSubject = BehaviorSubject();
  BehaviorSubject<SettingEnum> _settingBehavior = BehaviorSubject();

  onOffNotification(bool isOn, WeatherResponse weatherResponse) {
    _isOnNotify = isOn;
    _weatherResponse = weatherResponse;
    _notificationSubject.add(_isOnNotify);
  }

  changeSetting(String value, SettingEnum settingEnum) {
    switch (settingEnum) {
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
    convertDataWithUnit();
    _settingBehavior.add(settingEnum);
  }

  setWeatherData(WeatherData weatherData) {
    _weatherData = weatherData;
    convertDataWithUnit();
  }

  convertDataWithUnit() {
    WeatherResponse weatherResponse = _weatherData.weatherResponse;
    WeatherForecastListResponse weatherForecastListResponse =
        _weatherData.weatherForecastListResponse;
    WeatherForecastDaily weatherForecastDaily =
        _weatherData.weatherForecastDaily;
    _weatherData = _weatherData.copyWith(
        weatherResponse: weatherResponse.copyWith(
            mainWeatherData: weatherResponse.mainWeatherData.copyWith(
                temp:
                    convertTemp(weatherResponse.mainWeatherData.temp, tempEnum),
                tempMin: convertTemp(
                    weatherResponse.mainWeatherData.tempMin, tempEnum),
                tempMax: convertTemp(
                    weatherResponse.mainWeatherData.tempMax, tempEnum),
                feelsLike: convertTemp(
                    weatherResponse.mainWeatherData.feelsLike, tempEnum))),
        weatherForecastListResponse: weatherForecastListResponse.copyWith(
            list: _convertForecastListResponse(weatherForecastListResponse)),
        weatherForecastDaily: weatherForecastDaily.copyWith(
            daily: _convertListDaily(weatherForecastDaily.daily),
            current: weatherForecastDaily.current.copyWith(
                feelsLike: convertTemp(
                    weatherForecastDaily.current.feelsLike, tempEnum),
                temp:
                    convertTemp(weatherForecastDaily.current.temp, tempEnum))));
  }

  List<WeatherForecastResponse> _convertForecastListResponse(
      WeatherForecastListResponse weatherForecastListResponse) {
    List<WeatherForecastResponse> list =
        weatherForecastListResponse.list.map((e) {
      print('${convertTemp(e.mainWeatherData.temp, settingBloc.tempEnum)}');
      return e.copyWith(
          mainWeatherData: e.mainWeatherData.copyWith(
              temp: convertTemp(e.mainWeatherData.temp, settingBloc.tempEnum),
              feelsLike: convertTemp(
                  e.mainWeatherData.feelsLike, settingBloc.tempEnum),
              tempMax:
                  convertTemp(e.mainWeatherData.tempMax, settingBloc.tempEnum),
              tempMin: convertTemp(
                  e.mainWeatherData.tempMin, settingBloc.tempEnum)));
    }).toList();
    return list;
  }

  _convertListDaily(List<Daily> dailies) {
    return dailies
        .map((e) => e.copyWith(
            dewPoint: convertTemp(e.temp.day, tempEnum),
            temp: e.temp.copyWith(
                day: convertTemp(e.temp.day, tempEnum),
                eve: convertTemp(e.temp.eve, tempEnum),
                max: convertTemp(e.temp.max, tempEnum),
                min: convertTemp(e.temp.min, tempEnum),
                morn: convertTemp(e.temp.morn, tempEnum),
                night: convertTemp(e.temp.night, tempEnum)),
            feelsLike: e.feelsLike.copyWith(
                day: convertTemp(e.temp.day, tempEnum),
                eve: convertTemp(e.feelsLike.eve, tempEnum),
                morn: convertTemp(e.feelsLike.morn, tempEnum),
                night: convertTemp(e.feelsLike.night, tempEnum))))
        .toList();
  }

  @override
  void dispose() {
    _notificationSubject.close();
    _settingBehavior.close();
  }

  TempEnum get tempEnum => _tempEnum;

  bool get isOnNotification => _isOnNotify;

  WeatherResponse get weatherResponse => _weatherResponse;

  WeatherData get weatherData => _weatherData;

  Stream get notificationStream => _notificationSubject.stream;

  Stream get settingStream => _settingBehavior.stream;
}

final settingBloc = SettingBloc();
