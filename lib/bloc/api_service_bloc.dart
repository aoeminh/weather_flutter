import 'package:rxdart/rxdart.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'base_bloc.dart';
import 'app_bloc.dart';
import '../model/application_error.dart';
import '../model/weather_response.dart';

class ApiServiceBloc extends BlocBase {
  BehaviorSubject<WeatherState> _weatherBehaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _forecastBehaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _behaviorSubjectForDailyDay = BehaviorSubject();

  fetchWeather(double lat, double lon, {String units = 'metric'}) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        // print('isNetWorkAvailable');
        _weatherBehaviorSubject.add(WeatherStateLoading());
        WeatherResponse weatherResponse =
            await weatherRepository.fetchWeather(lat, lon, units);
        if (weatherResponse.errorCode != null) {
          _weatherBehaviorSubject
              .add(WeatherStateError(weatherResponse.errorCode));
        } else {
          _weatherBehaviorSubject.add(WeatherStateSuccess(weatherResponse));
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  fetchWeatherForecastResponse(double lat, double lon,
      {String units = 'metric'}) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        _forecastBehaviorSubject.add(WeatherStateLoading());

        WeatherForecastListResponse weatherForecastListResponse =
            await weatherRepository.fetchWeatherForecast(lat, lon, units);
        if (weatherForecastListResponse.errorCode != null) {
          _forecastBehaviorSubject
              .add(WeatherStateError(weatherForecastListResponse.errorCode));
        } else {
          print('fetchWeatherForecastResponse');
          _forecastBehaviorSubject
              .add(WeatherForecastStateSuccess(weatherForecastListResponse));
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  fetchWeatherForecast7Day(double lat, double lon, String exclude,
      {String units = 'metric'}) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        _behaviorSubjectForDailyDay.add(WeatherStateLoading());
        WeatherForecastDaily weatherForecast7Day = await weatherRepository
            .fetchWeatherForecast7Day(lat, lon, units, exclude);
        if (weatherForecast7Day.errorCode != null) {
          _behaviorSubjectForDailyDay
              .add(WeatherStateError(weatherForecast7Day.errorCode));
        } else {
          print('fetchWeatherForecast7Day');
          _behaviorSubjectForDailyDay
              .add(WeatherForecastDailyStateSuccess(weatherForecast7Day));
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  @override
  void dispose() {
    _weatherBehaviorSubject.close();
    _forecastBehaviorSubject.close();
    _behaviorSubjectForDailyDay.close();
  }

  Stream get weatherForecastStream => _forecastBehaviorSubject.stream;

  Stream get weatherForecastDailyStream => _behaviorSubjectForDailyDay.stream;

  Stream get weatherStream => _weatherBehaviorSubject.stream;
}
