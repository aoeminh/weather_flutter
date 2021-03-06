import 'package:weather_app/utils/utils.dart';

import '../bloc/setting_bloc.dart';

import 'application_error.dart';
import 'system.dart';
import 'wind.dart';

import 'clouds.dart';
import 'coordinates.dart';
import 'main_weather_data.dart';
import 'overall_weather_data.dart';
import '../shared/constant.dart';

class WeatherResponse {
  final int? dt;
  final Coordinates? cord;
  final List<Weather>? overallWeatherData;
  final MainWeatherData? mainWeatherData;
  final Wind? wind;
  final Clouds? clouds;
  final System? system;
  final int? id;
  final String? name;
  final int? cod;
  final String? station;
  ApplicationError? _errorCode;

  WeatherResponse(
      {this.dt,
      this.cord,
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
      : dt = json["dt"] * 1000,
        cord = Coordinates.fromJson(json["coord"]),
        system = System.fromJson(json["sys"]),
        overallWeatherData =
            (json["weather"] as List).map((i) => Weather.fromJson(i)).toList(),
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

  WeatherResponse.formatWithTimezone(
      WeatherResponse weatherResponse, double differentTime)
      : dt = (weatherResponse.dt! + differentTime * oneHourMilli).toInt(),
        cord = weatherResponse.cord,
        overallWeatherData = weatherResponse.overallWeatherData,
        mainWeatherData = weatherResponse.mainWeatherData,
        wind = weatherResponse.wind,
        clouds = weatherResponse.clouds,
        system = System.withTimezone(weatherResponse.system!, differentTime),
        id = weatherResponse.id,
        name = weatherResponse.name,
        cod = weatherResponse.cod,
        station = weatherResponse.station;

  WeatherResponse copyWithSettingData(
      TempEnum tempEnum, WindEnum windEnum, PressureEnum pressureEnum) {
    return WeatherResponse(
      dt: this.dt,
      cord: this.cord,
      overallWeatherData: this.overallWeatherData,
      mainWeatherData: this.mainWeatherData!.copyWith(
          pressure: convertPressure(
              this.mainWeatherData!.pressure, settingBloc.pressureEnum),
          temp: convertTemp(this.mainWeatherData!.temp, settingBloc.tempEnum),
          tempMin:
              convertTemp(this.mainWeatherData!.tempMin, settingBloc.tempEnum),
          tempMax:
              convertTemp(this.mainWeatherData!.tempMax, settingBloc.tempEnum),
          feelsLike: convertTemp(
              this.mainWeatherData!.feelsLike, settingBloc.tempEnum)),
      wind: this.wind!.copyWith(
          speed: convertWindSpeed(this.wind!.speed, settingBloc.windEnum)),
      clouds: this.clouds,
      system: this.system,
      id: this.id,
      name: this.name,
      cod: this.cod,
      station: station ?? this.station,
    );
  }

  static WeatherResponse withErrorCode(ApplicationError errorCode) {
    WeatherResponse response = new WeatherResponse();
    response._errorCode = errorCode;
    return response;
  }

  ApplicationError? get errorCode => _errorCode;
}
