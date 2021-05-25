import 'package:weather_app/model/current_daily_weather.dart';

import 'application_error.dart';
import 'daily.dart';

class WeatherForecastDaily {
  final String? timezone;
  final List<Daily>? daily;
  final CurrentDailyWeather? current;
  ApplicationError? _errorCode;

  WeatherForecastDaily({
    this.daily,
    this.timezone,
    this.current,
  });

  WeatherForecastDaily.fromJson(Map<String, dynamic> json)
      : daily = (json['daily'] as List).map((e) => Daily.fromJson(e)).toList(),
        current = CurrentDailyWeather.fromJson(json['current']),
        timezone = json['timezone'];

  static WeatherForecastDaily withTimezone(
      WeatherForecastDaily weatherForecastDaily, int differentTime) {
    return WeatherForecastDaily(
        daily: weatherForecastDaily.daily!
            .map((e) => Daily.withTimeZone(e, differentTime))
            .toList(),
        current: CurrentDailyWeather.withTimezone(
            weatherForecastDaily.current!, differentTime),
        timezone: weatherForecastDaily.timezone);
  }

  WeatherForecastDaily copyWith(
      {String? timezone, List<Daily>? daily, CurrentDailyWeather? current}) {
    return WeatherForecastDaily(
        timezone: timezone ?? this.timezone,
        current: current ?? this.current,
        daily: daily ?? this.daily);
  }

  static WeatherForecastDaily withErrorCode(ApplicationError errorCode) {
    WeatherForecastDaily response = new WeatherForecastDaily(daily: null);
    response._errorCode = errorCode;
    return response;
  }

  ApplicationError? get errorCode => _errorCode;
}
