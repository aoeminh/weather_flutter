import 'package:weather_app/api/weather_api.dart';
import 'package:weather_app/api/weather_api_impl.dart';
import 'package:weather_app/model/weather_forcast_daily.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_response.dart';

class WeatherRepository {
  final WeatherApi _weatherApi = WeatherApiImpl();

  Future<WeatherResponse> fetchWeather(double? lat, double? lon, String units) {
    return _weatherApi.fetchWeather(lat, lon, units);
  }

  Future<WeatherForecastListResponse> fetchWeatherForecast(
      double? lat, double? lon, String units) {
    return _weatherApi.fetchWeatherForecast(lat, lon, units);
  }

  Future<WeatherForecastDaily> fetchWeatherForecast7Day(
      double? lat, double? lon, String units,String exclude) {
    return _weatherApi.fetchWeatherForecast7Day(lat, lon, units,exclude);
  }

}
