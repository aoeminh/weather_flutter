import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/model/current_daily_weather.dart';
import 'package:weather_app/utils/utils.dart';

import 'application_error.dart';
import 'daily.dart';

class WeatherForecastDaily {
  final String? timezone;
  final double? timezoneOffset;
  final List<Daily>? daily;
  final CurrentDailyWeather? current;
  ApplicationError? _errorCode;

  WeatherForecastDaily(
      {this.daily, this.timezone, this.current, this.timezoneOffset});

  WeatherForecastDaily.fromJson(Map<String, dynamic> json)
      : daily = (json['daily'] as List).map((e) => Daily.fromJson(e)).toList(),
        current = CurrentDailyWeather.fromJson(json['current']),
        timezone = json['timezone'],
        timezoneOffset = json['timezone_offset']*1000.toDouble();

  static WeatherForecastDaily withTimezone(
      WeatherForecastDaily weatherForecastDaily, double differentTime) {
    return WeatherForecastDaily(
        daily: weatherForecastDaily.daily!
            .map((e) => Daily.withTimeZone(e, differentTime))
            .toList(),
        current: CurrentDailyWeather.withTimezone(
            weatherForecastDaily.current!, differentTime),
        timezone: weatherForecastDaily.timezone);
  }

  WeatherForecastDaily copyWith(
      TempEnum tempEnum,
      VisibilityEnum visibilityEnum,
      WindEnum windEnum,
      PressureEnum pressureEnum) {
    return WeatherForecastDaily(
        timezone: timezone ?? this.timezone,
        daily: _convertListDaily(
            this.daily!, tempEnum, visibilityEnum, windEnum, pressureEnum),
        current: this.current!.copyWith(
            visibility: convertVisibility(
                this.current!.visibility, settingBloc.visibilityEnum),
            feelsLike:
                convertTemp(this.current!.feelsLike, settingBloc.tempEnum),
            temp: convertTemp(this.current!.temp, settingBloc.tempEnum)));
  }

  _convertListDaily(
      List<Daily> dailies,
      TempEnum tempEnum,
      VisibilityEnum visibilityEnum,
      WindEnum windEnum,
      PressureEnum pressureEnum) {
    return dailies
        .map((e) => e.copyWith(
            windSpeed: convertWindSpeed(e.windSpeed, windEnum),
            dewPoint: convertTemp(e.temp!.day, tempEnum),
            pressure: convertPressure(e.pressure, pressureEnum),
            temp: e.temp!.copyWith(
                day: convertTemp(e.temp!.day, tempEnum),
                eve: convertTemp(e.temp!.eve, tempEnum),
                max: convertTemp(e.temp!.max, tempEnum),
                min: convertTemp(e.temp!.min, tempEnum),
                morn: convertTemp(e.temp!.morn, tempEnum),
                night: convertTemp(e.temp!.night, tempEnum)),
            feelsLike: e.feelsLike!.copyWith(
                day: convertTemp(e.temp!.day, tempEnum),
                eve: convertTemp(e.feelsLike!.eve, tempEnum),
                morn: convertTemp(e.feelsLike!.morn, tempEnum),
                night: convertTemp(e.feelsLike!.night, tempEnum))))
        .toList();
  }

  static WeatherForecastDaily withErrorCode(ApplicationError errorCode) {
    WeatherForecastDaily response = new WeatherForecastDaily(daily: null);
    response._errorCode = errorCode;
    return response;
  }

  ApplicationError? get errorCode => _errorCode;
}
