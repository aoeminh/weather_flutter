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
      {List<WeatherForecastResponse>? list, City? city}) {
    return WeatherForecastListResponse(
        list: list ?? this.list, city: city ?? this.city);
  }

  WeatherForecastListResponse formatWithTimezone(
      {List<WeatherForecastResponse>? list, City? city}) {
    return WeatherForecastListResponse(
        list: list ?? this.list, city: city ?? this.city);
  }


  ApplicationError? get errorCode => _errorCode;
}
