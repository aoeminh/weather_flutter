import 'package:weather_app/model/weather_response.dart';

abstract class WeatherApi{
  Future<WeatherResponse> fetchWeather(double lat, double lon);
  Future<WeatherResponse> fetchWeatherForecast(double lat, double lon);

}