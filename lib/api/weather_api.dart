import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_response.dart';

abstract class WeatherApi{
  Future<WeatherResponse> fetchWeather(double? lat, double? lon,String units);
  Future<WeatherForecastListResponse> fetchWeatherForecast(double? lat, double? lon,String units);
  Future<WeatherForecastDaily> fetchWeatherForecast7Day(double? lat, double? lon,String units,String exclude);

}