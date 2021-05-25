import 'package:weather_app/utils/types_helper.dart';

import 'temp.dart';

import 'feels_like.dart';
import 'overall_weather_data.dart';
import 'package:weather_app/shared/constant.dart';

class Daily {
  final int? dt;
  final int? sunrise;
  final int? sunset;
  final Temp? temp;
  final FeelsLike? feelsLike;
  final double? pressure;
  final int? humidity;
  final double? dewPoint;
  final double? windSpeed;
  final int? windDeg;
  final List<Weather>? weather;
  final int? clouds;
  final double? pop;
  final double? uvi;

  Daily(
      {this.dt,
      this.sunrise,
      this.sunset,
      this.temp,
      this.feelsLike,
      this.pressure,
      this.humidity,
      this.dewPoint,
      this.windSpeed,
      this.windDeg,
      this.weather,
      this.clouds,
      this.pop,
      this.uvi});

  Daily.fromJson(Map<String, dynamic> json)
      : dt = json['dt'] * 1000,
        sunrise = json['sunrise'] * 1000,
        sunset = json['sunset'] * 1000,
        temp = json['temp'] != null ? new Temp.fromJson(json['temp']) : null,
        feelsLike = json['feels_like'] != null
            ? new FeelsLike.fromJson(json['feels_like'])
            : null,
        pressure = json['pressure'].toDouble(),
        humidity = json['humidity'],
        dewPoint = json['dew_point'].toDouble(),
        windSpeed = json['wind_speed'].toDouble(),
        windDeg = json['wind_deg'],
        weather =
            (json['weather'] as List).map((e) => Weather.fromJson(e)).toList(),
        clouds = json['clouds'],
        pop = TypesHelper.toDouble(json['pop']) * 100,
        uvi = TypesHelper.toDouble(json['uvi']);

  static Daily withTimeZone(Daily daily, int differentTime) {
    return Daily(
        dt: daily.dt! + differentTime * oneHourMilli,
        clouds: daily.clouds,
        dewPoint: daily.dewPoint,
        feelsLike: daily.feelsLike,
        humidity: daily.humidity,
        pop: daily.pop,
        pressure: daily.pressure,
        sunrise: daily.sunrise! + differentTime * oneHourMilli,
        sunset: daily.sunset! + differentTime * oneHourMilli,
        temp: daily.temp,
        uvi: daily.uvi,
        weather: daily.weather,
        windDeg: daily.windDeg,
        windSpeed: daily.windSpeed);
  }

  Daily copyWith(
      {int? dt,
      int? sunrise,
      int? sunset,
      Temp? temp,
      FeelsLike? feelsLike,
      double? pressure,
      int? humidity,
      double? dewPoint,
      double? windSpeed,
      int? windDeg,
      List<Weather>? weather,
      int? clouds,
      double? pop,
      double? uvi}) {
    return Daily(
        dt: dt ?? this.dt,
        clouds: clouds ?? this.clouds,
        dewPoint: dewPoint ?? this.dewPoint,
        feelsLike: feelsLike ?? this.feelsLike,
        humidity: humidity ?? this.humidity,
        pop: pop ?? this.pop,
        pressure: pressure ?? this.pressure,
        sunrise: sunrise ?? this.sunrise,
        sunset: sunset ?? this.sunset,
        temp: temp ?? this.temp,
        uvi: uvi ?? this.uvi,
        weather: weather ?? this.weather,
        windDeg: windDeg ?? this.windDeg,
        windSpeed: windSpeed ?? this.windSpeed);
  }
}
