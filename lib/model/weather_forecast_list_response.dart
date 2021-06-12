import 'package:flutter/cupertino.dart';

import '../bloc/setting_bloc.dart';
import '../shared/constant.dart';
import '../utils/utils.dart';

import 'application_error.dart';
import 'city.dart';
import 'weather_forecast_response.dart';

class WeatherForecastListResponse {
  final List<WeatherForecastResponse>? list;
  final City? city;
  ApplicationError? _errorCode;

  WeatherForecastListResponse({this.list, this.city});

  WeatherForecastListResponse.fromJson(Map<String, dynamic> json)
      : list = (json["list"] as List)
            .map((i) => new WeatherForecastResponse.fromJson(i))
            .toList(),
        city = City.fromJson(json["city"]);

  Map<String, dynamic> toJson() => {"list": list, "city": city};

  static WeatherForecastListResponse withErrorCode(ApplicationError errorCode) {
    WeatherForecastListResponse response = new WeatherForecastListResponse();
    response._errorCode = errorCode;
    return response;
  }

  WeatherForecastListResponse copyWith(
      TempEnum tempEnum, WindEnum windEnum, PressureEnum pressureEnum) {
    return WeatherForecastListResponse(
        list: _convertWithData(tempEnum, windEnum, pressureEnum),
        city: this.city);
  }

  WeatherForecastListResponse withTimezone(
      {@required WeatherForecastListResponse? list,
      @required double? differentTime}) {
    return WeatherForecastListResponse(
        list: _convertWithTimezone(list!, differentTime!), city: list.city);
  }

  List<WeatherForecastResponse> _convertWithTimezone(
      WeatherForecastListResponse weatherForecastListResponse,
      double differentTime) {
    List<WeatherForecastResponse> list =
        weatherForecastListResponse.list!.map((e) {
      return e.copyWith(
          dt: (e.dt! + differentTime * oneHourMilli).toInt(),
          wind: e.wind,
          mainWeatherData: e.mainWeatherData);
    }).toList();
    return list;
  }

  List<WeatherForecastResponse> _convertWithData(
      TempEnum tempEnum, WindEnum windEnum, PressureEnum pressureEnum) {
    List<WeatherForecastResponse> list = this.list!.map((e) {
      return e.copyWith(
          dt: e.dt,
          wind:
              e.wind.copyWith(speed: convertWindSpeed(e.wind.speed, windEnum)),
          mainWeatherData: e.mainWeatherData.copyWith(
              pressure:
                  convertPressure(e.mainWeatherData.pressure, pressureEnum),
              temp: convertTemp(e.mainWeatherData.temp, tempEnum),
              feelsLike: convertTemp(e.mainWeatherData.feelsLike, tempEnum),
              tempMax: convertTemp(e.mainWeatherData.tempMax, tempEnum),
              tempMin: convertTemp(e.mainWeatherData.tempMin, tempEnum)));
    }).toList();
    return list;
  }

  ApplicationError? get errorCode => _errorCode;
}
