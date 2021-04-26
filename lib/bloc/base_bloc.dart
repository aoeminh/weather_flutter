import 'package:weather_app/model/application_error.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import '../model/weather_forecast_list_response.dart';

import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/repository/weather_repository.dart';
import 'package:connectivity/connectivity.dart';

abstract class BlocBase {
  final WeatherRepository weatherRepository = WeatherRepository();

  Future<bool> checkNetWork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    return (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi);
  }

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

class WeatherForecastDailyStateSuccess extends WeatherState {
  final WeatherForecastDaily weatherResponse;

  WeatherForecastDailyStateSuccess(this.weatherResponse);
}
