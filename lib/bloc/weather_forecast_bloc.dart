import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';

class WeatherForecastBloc extends BlocBase {
  BehaviorSubject<WeatherState> _behaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _behaviorSubjectForDailyDay = BehaviorSubject();

  fetchWeatherForecastResponse(double lat, double lon,
      {String units = 'metric'}) async {
    _behaviorSubject.add(WeatherStateLoading());

    WeatherForecastListResponse weatherForecastListResponse =
        await weatherRepository.fetchWeatherForecast(lat, lon, units);
    if (weatherForecastListResponse.errorCode != null) {
      _behaviorSubject
          .add(WeatherStateError(weatherForecastListResponse.errorCode));
    } else {
      print('fetchWeatherForecastResponse');
      _behaviorSubject
          .add(WeatherForecastStateSuccess(weatherForecastListResponse));
    }
  }

  fetchWeatherForecast7Day(double lat, double lon, String exclude,
      {String units = 'metric'}) async {
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
  }

  @override
  void dispose() {
    _behaviorSubject.close();
    _behaviorSubjectForDailyDay.close();
  }

  Stream get weatherForecastStream => _behaviorSubject.stream;

  Stream get weatherForecastDailyStream => _behaviorSubjectForDailyDay.stream;
}
