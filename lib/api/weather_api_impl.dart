import 'package:dio/dio.dart';
import 'package:weather_app/model/application_error.dart';
import 'weather_api.dart';
import '../model/weather_forecast_list_response.dart';
import '../model/weather_response.dart';

class WeatherApiImpl extends WeatherApi {
  final Dio _dio = Dio();
  final String _baseUrl = 'api.openweathermap.org';
  final String _apiPath = "/data/2.5";
  final String _apiWeatherEndpoint = "/weather";
  final String _apiWeatherForecastEndpoint = "/forecast";
  static final String apiKey = "2b557cc4c291a6293e22bc44e49231d8";

  @override
  Future<WeatherResponse> fetchWeather(
      double lat, double lon, String units) async {
    Uri uri = _buildUri(lat, lon, _apiWeatherEndpoint, units);
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      return WeatherResponse.fromJson(response.data);
    } else {
      return WeatherResponse.withErrorCode(ApplicationError.apiError);
    }
  }

  @override
  Future<WeatherForecastListResponse> fetchWeatherForecast(
      double lat, double lon, String units) async {
    Uri uri = _buildUri(lat, lon, _apiWeatherForecastEndpoint, units);
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      print('Success: ${response.data}');
      return WeatherForecastListResponse.fromJson(response.data);
    } else {
      return WeatherForecastListResponse.withErrorCode(
          ApplicationError.apiError);
    }
  }

  _buildUri(double lat, double lon, String endpoint, String unit) {
    return Uri(
        scheme: 'https',
        host: _baseUrl,
        path: '$_apiPath$endpoint',
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'apiKey': apiKey,
          'units': unit
        });
  }
}