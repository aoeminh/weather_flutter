import 'overall_weather_data.dart';
import 'package:weather_app/shared/constant.dart';

class CurrentDailyWeather {
  int? dt;
  int? sunrise;
  int? sunset;
  double? temp;
  double? feelsLike;
  int? pressure;
  int? humidity;
  double? dewPoint;
  double? uvi;
  int? clouds;
  double? visibility;
  double? windSpeed;
  int? windDeg;
  List<Weather>? weather;

  CurrentDailyWeather(
      {this.dt,
      this.sunrise,
      this.sunset,
      this.temp,
      this.feelsLike,
      this.pressure,
      this.humidity,
      this.dewPoint,
      this.uvi,
      this.clouds,
      this.visibility,
      this.windSpeed,
      this.windDeg,
      this.weather});

  CurrentDailyWeather.fromJson(Map<String, dynamic> json) {
    dt = json['dt'] * 1000;
    sunrise = json['sunrise'] * 1000;
    sunset = json['sunset'] * 1000;
    temp = json['temp'].toDouble();
    feelsLike = json['feels_like'].toDouble();
    pressure = json['pressure'];
    humidity = json['humidity'];
    dewPoint = json['dew_point'].toDouble();
    uvi = json['uvi'].toDouble();
    clouds = json['clouds'];
    visibility = json['visibility'].toDouble() /1000;
    windSpeed = json['wind_speed'].toDouble();
    windDeg = json['wind_deg'];
    if (json['weather'] != null) {
      weather = <Weather>[];
      json['weather'].forEach((v) {
        weather!.add(new Weather.fromJson(v));
      });
    }
  }

  static CurrentDailyWeather withTimezone(
      CurrentDailyWeather currentDailyWeather, double differentTime) {
    return CurrentDailyWeather(
        windSpeed: currentDailyWeather.windSpeed,
        windDeg: currentDailyWeather.windDeg,
        weather: currentDailyWeather.weather,
        uvi: currentDailyWeather.uvi,
        temp: currentDailyWeather.temp,
        sunset: (currentDailyWeather.sunset! + differentTime * oneHourMilli).toInt(),
        sunrise: (currentDailyWeather.sunrise! + differentTime * oneHourMilli).toInt(),
        pressure: currentDailyWeather.pressure,
        humidity: currentDailyWeather.humidity,
        feelsLike: currentDailyWeather.feelsLike,
        dewPoint: currentDailyWeather.dewPoint,
        clouds: currentDailyWeather.clouds,
        dt: (currentDailyWeather.dt! + differentTime * oneHourMilli).toInt(),
        visibility: currentDailyWeather.visibility);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dt'] = this.dt;
    data['sunrise'] = this.sunrise;
    data['sunset'] = this.sunset;
    data['temp'] = this.temp;
    data['feels_like'] = this.feelsLike;
    data['pressure'] = this.pressure;
    data['humidity'] = this.humidity;
    data['dew_point'] = this.dewPoint;
    data['uvi'] = this.uvi;
    data['clouds'] = this.clouds;
    data['visibility'] = this.visibility;
    data['wind_speed'] = this.windSpeed;
    data['wind_deg'] = this.windDeg;
    if (this.weather != null) {
      data['weather'] = this.weather!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  CurrentDailyWeather copyWith(
      {int? dt,
      int? sunrise,
      int? sunset,
      double? temp,
      double? feelsLike,
      int? pressure,
      int? humidity,
      double? dewPoint,
      double? uvi,
      int? clouds,
      double? visibility,
      double? windSpeed,
      int? windDeg,
      List<Weather>? weather}) {
    return CurrentDailyWeather(
        windDeg: windDeg ?? this.windDeg,
        weather: weather ?? this.weather,
        uvi: uvi ?? this.uvi,
        temp: temp ?? this.temp,
        sunset: sunset ?? this.sunset,
        sunrise: sunrise ?? this.sunrise,
        pressure: pressure ?? this.pressure,
        humidity: humidity ?? this.humidity,
        feelsLike: feelsLike ?? this.feelsLike,
        dewPoint: dewPoint ?? this.dewPoint,
        clouds: clouds ?? this.clouds,
        dt: dt ?? this.dt,
        visibility: visibility ?? this.visibility);
  }
}
