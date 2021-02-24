import 'application_error.dart';
import 'daily.dart';

class WeatherForecast7Day {
  List<Daily> daily;
  ApplicationError _errorCode;

  WeatherForecast7Day({this.daily});

  WeatherForecast7Day.fromJson(Map<String, dynamic> json) {
    if (json['daily'] != null) {
      daily = new List<Daily>();
      json['daily'].forEach((v) {
        daily.add(new Daily.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.daily != null) {
      data['daily'] = this.daily.map((v) => v.toJson()).toList();
    }
    return data;
  }

  static WeatherForecast7Day withErrorCode(ApplicationError errorCode) {
    WeatherForecast7Day response = new WeatherForecast7Day(daily: null);
    response._errorCode = errorCode;
    return response;
  }

  ApplicationError get errorCode => _errorCode;
}
