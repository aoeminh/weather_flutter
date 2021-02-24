
import 'application_error.dart';
import 'system.dart';
import 'wind.dart';

import 'clouds.dart';
import 'coordinates.dart';
import 'main_weather_data.dart';
import 'overall_weather_data.dart';

class WeatherResponse {
  final Coordinates cord;
  final List<Weather> overallWeatherData;
  final MainWeatherData mainWeatherData;
  final Wind wind;
  final Clouds clouds;
  final System system;
  final int id;
  final String name;
  final int cod;
  final String station;
  ApplicationError _errorCode;

  WeatherResponse(
      {this.cord,
      this.overallWeatherData,
      this.mainWeatherData,
      this.wind,
      this.clouds,
      this.system,
      this.id,
      this.name,
      this.cod,
      this.station});

  WeatherResponse.fromJson(Map<String, dynamic> json)
      : cord = Coordinates.fromJson(json["coord"]),
        system = System.fromJson(json["sys"]),
        overallWeatherData = (json["weather"] as List)
            .map((i) => Weather.fromJson(i))
            .toList(),
        mainWeatherData = MainWeatherData.fromJson(json["main"]),
        wind = Wind.fromJson(json["wind"]),
        clouds = Clouds.fromJson(json["clouds"]),
        id = json["id"],
        name = json["name"],
        cod = json["cod"],
        station = json["station"];

  Map<String, dynamic> toJson() => {
        "coord": cord,
        "sys": system,
        "weather": overallWeatherData,
        "main": mainWeatherData,
        "wind": wind,
        "clouds": clouds,
        "id": id,
        "name": name,
        "cod": cod,
        "station": station,
      };

  static WeatherResponse withErrorCode(ApplicationError errorCode) {
    WeatherResponse response = new WeatherResponse();
    response._errorCode = errorCode;
    return response;
  }

  ApplicationError get errorCode => _errorCode;
}
