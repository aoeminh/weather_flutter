import 'application_error.dart';
import 'daily.dart';

class WeatherForecastDaily {
  List<Daily> daily;
  ApplicationError _errorCode;

  WeatherForecastDaily({this.daily});

  WeatherForecastDaily.fromJson(Map<String, dynamic> json) {
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

  static WeatherForecastDaily withErrorCode(ApplicationError errorCode) {
    WeatherForecastDaily response = new WeatherForecastDaily(daily: null);
    response._errorCode = errorCode;
    return response;
  }

  ApplicationError get errorCode => _errorCode;
}
