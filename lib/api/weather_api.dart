import 'package:weather_app/model/weather_forcast_daily.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_response.dart';

abstract class WeatherApi{
  Future<WeatherResponse> fetchWeather(double? lat, double? lon,String units,
      {String lang = 'en'});
  Future<WeatherForecastListResponse> fetchWeatherForecast(double? lat, double? lon,String units,
      {String lang = 'en'});
  Future<WeatherForecastDaily> fetchWeatherForecast7Day(double? lat, double? lon,String units,String exclude,
      {String lang = 'en'});

}