import 'package:dio/dio.dart';
import 'package:weather_app/model/application_error.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'weather_api.dart';
import '../model/weather_forecast_list_response.dart';
import '../model/weather_response.dart';

class WeatherApiImpl extends WeatherApi {
  final Dio _dio = Dio();
  final String _baseUrl = 'api.openweathermap.org';
  final String _apiPath = "/data/2.5";
  final String _apiWeatherEndpoint = "/weather";
  final String _apiWeatherForecastEndpoint = "/forecast";
  final String _apiWeatherForecast7Day = "/onecall";
  static final String apiKey = "980fd15d8985bd9e265eac0593d3c9bd";

  @override
  Future<WeatherResponse> fetchWeather(
      double lat, double lon, String units) async {
    Uri uri = _buildUri(lat, lon, _apiWeatherEndpoint, units);
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      print('fetchWeather Success: ${response.data}');
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
      print('fetchWeatherForecast Success: ${response.data}');
      return WeatherForecastListResponse.fromJson(response.data);
    } else {
      return WeatherForecastListResponse.withErrorCode(
          ApplicationError.apiError);
    }
  }

  @override
  Future<WeatherForecastDaily> fetchWeatherForecast7Day(
      double lat, double lon, String units, String exclude) async {
    Uri uri =
        _buildUri(lat, lon, _apiWeatherForecast7Day, units, exclude: exclude);
    print('uri $uri');
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      print('fetchWeatherForecast7Day Success: ${response.data}');
      return WeatherForecastDaily.fromJson(response.data);
    } else {
      return WeatherForecastDaily.withErrorCode(ApplicationError.apiError);
    }
  }

  _buildUri(double lat, double lon, String endpoint, String unit,
      {String exclude}) {
    Map<String, dynamic> param = {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'apiKey': apiKey,
      'units': unit
    };

    // add param to 7 day api
    if (exclude != null) {
      param['exclude'] = exclude;
    }
    return Uri(
        scheme: 'https',
        host: _baseUrl,
        path: '$_apiPath$endpoint',
        queryParameters: param);
  }
}
