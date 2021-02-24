import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/weather_forecast_7_day.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';

class WeatherForecastBloc extends BlocBase {
  BehaviorSubject<WeatherState> _behaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _behaviorSubjectFor7Day = BehaviorSubject();

  fetchWeatherForecastResponse(double lat, double lon,
      {String units = 'metric'}) async {
    _behaviorSubject.add(WeatherStateLoading());

    WeatherForecastListResponse weatherForecastListResponse =
        await weatherRepository.fetchWeatherForecast(lat, lon, units);
    if (weatherForecastListResponse.errorCode != null) {
      _behaviorSubject
          .add(WeatherStateError(weatherForecastListResponse.errorCode));
    } else {
      _behaviorSubject
          .add(WeatherForecastStateSuccess(weatherForecastListResponse));
    }
  }

  fetchWeatherForecast7Day(double lat, double lon, String exclude,
      {String units = 'metric'}) async {
    WeatherForecast7Day weatherForecast7Day = await weatherRepository
        .fetchWeatherForecast7Day(lat, lon, units, exclude);
    if (weatherForecast7Day.errorCode != null) {
      _behaviorSubjectFor7Day
          .add(WeatherStateError(weatherForecast7Day.errorCode));
    } else {
      _behaviorSubjectFor7Day
          .add(WeatherForecast7DayStateSuccess(weatherForecast7Day));
    }
  }

  @override
  void dispose() {
    _behaviorSubject.close();
    _behaviorSubjectFor7Day.close();
  }

  Stream get weatherForecastStream => _behaviorSubject.stream;
}
