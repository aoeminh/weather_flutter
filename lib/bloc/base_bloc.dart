import '../model/air_pollution_response.dart';
import '../model/air_response.dart';
import '../model/application_error.dart';
import '../model/weather_forcast_daily.dart';
import '../model/weather_forecast_list_response.dart';

import '../model/weather_response.dart';
import '../repository/weather_repository.dart';
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
  final ApplicationError? error;

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

class AirPollutionStateSuccess extends WeatherState {
  final AirPollutionResponse airPollutionResponse;

  AirPollutionStateSuccess(this.airPollutionResponse);
}

class AirStateSuccess extends WeatherState {
  final AirResponse airResponse;

  AirStateSuccess(this.airResponse);
}
