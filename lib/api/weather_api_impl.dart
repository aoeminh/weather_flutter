import 'package:weather_app/api/weather_api.dart';
import 'package:weather_app/model/weather_response.dart';

class WeatherApiImpl extends WeatherApi{


  @override
  Future<WeatherResponse> fetchWeather(double lat, double lon) {
    // TODO: implement fetchWeather
    throw UnimplementedError();
  }

  @override
  Future<WeatherResponse> fetchWeatherForecast(double lat, double lon) {
    // TODO: implement fetchWeatherForecast
    throw UnimplementedError();
  }

}