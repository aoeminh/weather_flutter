import 'package:dio/dio.dart';
import 'package:weather_app/model/air_pollution_response.dart';
import 'package:weather_app/model/air_response.dart';
import 'package:weather_app/model/application_error.dart';
import 'package:weather_app/model/covid_summary_response.dart';
import 'package:weather_app/model/weather_forcast_daily.dart';

import '../model/weather_forecast_list_response.dart';
import '../model/weather_response.dart';
import 'weather_api.dart';

class WeatherApiImpl extends WeatherApi {
  final Dio _dio = Dio();
  final String _baseUrl = 'api.openweathermap.org';
  final String _apiPath = "/data/2.5";
  final String _apiWeatherEndpoint = "/weather";
  final String _apiWeatherForecastEndpoint = "/forecast";
  final String _apiWeatherForecast7Day = "/onecall";
  final String _apiAirPollution = "/air_pollution";
  static final String apiKey = "980fd15d8985bd9e265eac0593d3c9bd";
  static final String waqiToken = "d05a139b30a73bc0f711d6a36be3522498e01c95";
  String airAQI =
      'https://api.waqi.info/feed/geo:40.78788;-74.014313/?token=d05a139b30a73bc0f711d6a36be3522498e01c95';

  String covid19ApiSummary = 'https://api.covid19api.com/summary';

  @override
  Future<WeatherResponse> fetchWeather(double? lat, double? lon, String units,
      {String lang = 'en'}) async {
    Uri uri = _buildUri(lat, lon, _apiWeatherEndpoint, unit: units, lang: lang);
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      return WeatherResponse.fromJson(response.data);
    } else {
      return WeatherResponse.withErrorCode(ApplicationError.apiError);
    }
  }

  @override
  Future<WeatherForecastListResponse> fetchWeatherForecast(
      double? lat, double? lon, String units,
      {String lang = 'en'}) async {
    Uri uri = _buildUri(lat, lon, _apiWeatherForecastEndpoint,
        unit: units, lang: lang);
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      return WeatherForecastListResponse.fromJson(response.data);
    } else {
      return WeatherForecastListResponse.withErrorCode(
          ApplicationError.apiError);
    }
  }

  @override
  Future<WeatherForecastDaily> fetchWeatherForecast7Day(
      double? lat, double? lon, String units, String exclude,
      {String lang = 'en'}) async {
    Uri uri = _buildUri(lat, lon, _apiWeatherForecast7Day,
        unit: units, exclude: exclude, lang: lang);
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      return WeatherForecastDaily.fromJson(response.data);
    } else {
      return WeatherForecastDaily.withErrorCode(ApplicationError.apiError);
    }
  }

  @override
  Future<AirPollutionResponse> fetchAirPollution(
      double? lat, double? lon) async {
    Uri uri = _buildUri(lat, lon, _apiAirPollution);
    Response response = await _dio.get(uri.toString());
    if (response.statusCode == 200) {
      return AirPollutionResponse.fromJson(response.data);
    } else {
      return AirPollutionResponse.withErrorCode(ApplicationError.apiError);
    }
  }

  @override
  Future<AirResponse> getAirPollution(double? lat, double? lon) async {
    Uri uri = _buildUriForAirPollution(lat, lon);
    Response response = await _dio.get(uri.toString());
    print(response.data);
    if (response.statusCode == 200) {
      return AirResponse.fromJson(response.data);
    } else {
      return AirResponse.withErrorCode(ApplicationError.apiError);
    }
  }

  @override
  Future<CovidSummaryResponse> getCovid19Summary() async {
    Uri uri = _buildCovid19Summary();
    Response response = await _dio.get(uri.toString());
    print(response.data);
    if (response.statusCode == 200) {
      print('getCovid ${response.data}');
      return CovidSummaryResponse.fromJson(response.data);
    } else {
      return CovidSummaryResponse.withErrorCode(ApplicationError.apiError);
    }
  }

  _buildUri(double? lat, double? lon, String endpoint,
      {String? unit, String? exclude, String? lang}) {
    Map<String, dynamic> param = {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'apiKey': apiKey,
      'units': unit,
      'lang': convertSpecialLanguageCode(lang ?? '')
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

  _buildUriForAirPollution(double? lat, double? lon) {
    Map<String, dynamic> params = {'token': waqiToken};
    return Uri(
        scheme: 'https',
        host: 'api.waqi.info',
        path: '/feed/geo:$lat;$lon/',
        queryParameters: params);
  }

  _buildCovid19Summary() {
    return Uri(
        scheme: 'https',
        host: 'api.covid19api.com',
        path: '/summary',);
  }

  String convertSpecialLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return 'kr';
      default:
        return languageCode;
    }
  }
}
