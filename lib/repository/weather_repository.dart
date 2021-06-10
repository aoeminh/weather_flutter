import '../api/weather_api.dart';
import '../api/weather_api_impl.dart';
import '../model/air_pollution_response.dart';
import '../model/air_response.dart';
import '../model/weather_forcast_daily.dart';
import '../model/weather_forecast_list_response.dart';
import '../model/weather_response.dart';

class WeatherRepository {
  final WeatherApi _weatherApi = WeatherApiImpl();

  Future<WeatherResponse> fetchWeather(double? lat, double? lon, String units,
          {String lang = 'en'}) =>
      _weatherApi.fetchWeather(lat, lon, units, lang: lang);

  Future<WeatherForecastListResponse> fetchWeatherForecast(
          double? lat, double? lon, String units,
          {String lang = 'en'}) =>
      _weatherApi.fetchWeatherForecast(lat, lon, units, lang: lang);

  Future<WeatherForecastDaily> fetchWeatherForecast7Day(
          double? lat, double? lon, String units, String exclude,
          {String lang = 'en'}) =>
      _weatherApi.fetchWeatherForecast7Day(lat, lon, units, exclude,
          lang: lang);

  Future<AirPollutionResponse> fetchAirPollution(double? lat, double? lon) =>
      _weatherApi.fetchAirPollution(lat, lon);

  Future<AirResponse> getAirPollution(double? lat, double? lon) =>
      _weatherApi.getAirPollution(lat, lon);
}
