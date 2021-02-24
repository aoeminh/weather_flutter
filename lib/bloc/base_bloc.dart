import 'package:weather_app/model/application_error.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import '../model/weather_forecast_list_response.dart';

import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/repository/weather_repository.dart';

abstract class BlocBase {
  final WeatherRepository weatherRepository = WeatherRepository();

  void dispose();
}

abstract class WeatherState {}

class WeatherStateSuccess extends WeatherState {
  final WeatherResponse weatherResponse;

  WeatherStateSuccess(this.weatherResponse);
}

class WeatherStateError extends WeatherState {
  final ApplicationError error;

  WeatherStateError(this.error);
}

class WeatherStateLoading extends WeatherState {}

class WeatherForecastStateSuccess extends WeatherState {
  final WeatherForecastListResponse weatherResponse;

  WeatherForecastStateSuccess(this.weatherResponse);
}

class WeatherForecast7DayStateSuccess extends WeatherState {
  final WeatherForecast7Day weatherResponse;

  WeatherForecast7DayStateSuccess(this.weatherResponse);
}
