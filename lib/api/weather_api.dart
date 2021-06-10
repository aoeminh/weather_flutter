import 'package:weather_app/model/air_response.dart';

import '../model/air_pollution_response.dart';
import '../model/weather_forcast_daily.dart';
import '../model/weather_forecast_list_response.dart';
import '../model/weather_response.dart';

abstract class WeatherApi {
  Future<WeatherResponse> fetchWeather(double? lat, double? lon, String units,
      {String lang = 'en'});

  Future<WeatherForecastListResponse> fetchWeatherForecast(
      double? lat, double? lon, String units,
      {String lang = 'en'});

  Future<WeatherForecastDaily> fetchWeatherForecast7Day(
      double? lat, double? lon, String units, String exclude,
      {String lang = 'en'});

  Future<AirPollutionResponse> fetchAirPollution(
      double? lat, double? lon); //current not
  // use
  Future<AirResponse> getAirPollution(
      double? lat, double? lon); //current not use
}
