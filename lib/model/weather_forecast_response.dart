

import 'rain.dart';
import 'wind.dart';

import 'clouds.dart';
import 'main_weather_data.dart';
import 'overall_weather_data.dart';
import '../utils/types_helper.dart';


class WeatherForecastResponse {
  final MainWeatherData mainWeatherData;
  final List<Weather> overallWeatherData;
  final Clouds clouds;
  final Wind wind;
  final DateTime dateTime;
  final Rain rain;
  final Rain snow;
  final double visibility;
  final double pop;

  WeatherForecastResponse(this.mainWeatherData, this.overallWeatherData,
      this.clouds, this.wind, this.dateTime, this.rain, this.snow, this.visibility, this.pop);

  WeatherForecastResponse.fromJson(Map<String, dynamic> json)
      : overallWeatherData = (json["weather"] as List)
            .map((i) => Weather.fromJson(i))
            .toList(),
        mainWeatherData = MainWeatherData.fromJson(json["main"]),
        wind = Wind.fromJson(json["wind"]),
        clouds = Clouds.fromJson(json["clouds"]),
        dateTime = DateTime.parse(json["dt_txt"]),
        rain = _getRain(json["rain"]),
        visibility = TypesHelper.toDouble(json["visibility"]),
        pop = TypesHelper.toDouble(json["pop"]),
        snow = _getRain(json["snow"]);




  static Rain _getRain(dynamic json) {
    if (json == null) {
      return Rain(0);
    } else {
      return Rain.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() => {
        "weather": overallWeatherData,
        "main": mainWeatherData,
        "clouds": clouds.toJson(),
        "wind": wind.toJson(),
        "dt_txt": dateTime.toIso8601String(),
        "rain": rain.toJson(),
        "snow": snow.toJson()
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
