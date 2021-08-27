import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/setting_bloc.dart';
import 'package:weather_app/model/covid_summary_response.dart';
import '../model/air_pollution_response.dart';
import '../model/air_response.dart';
import '../model/weather_forcast_daily.dart';
import '../model/weather_forecast_list_response.dart';

import '../model/application_error.dart';
import '../model/weather_response.dart';
import 'app_bloc.dart';
import 'base_bloc.dart';

typedef OnTest = Function(bool test);

class ApiServiceBloc extends BlocBase {
  BehaviorSubject<WeatherState> _weatherBehaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _forecastBehaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _behaviorSubjectForDailyDay = BehaviorSubject();
  BehaviorSubject<WeatherState> _behaviorSubjectAirPollution =
      BehaviorSubject();
  BehaviorSubject<WeatherState> _behaviorSubjectCovid = BehaviorSubject();

  fetchWeather(double? lat, double? lon, {String units = 'metric'}) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        // screen not visible
        if (!_weatherBehaviorSubject.isClosed) {
          WeatherResponse weatherResponse =
              await weatherRepository.fetchWeather(lat, lon, units,
                  lang: settingBloc.languageEnum.languageCode);
          if (weatherResponse.errorCode != null) {
            _weatherBehaviorSubject
                .add(WeatherStateError(weatherResponse.errorCode));
          } else {
            if (!_weatherBehaviorSubject.isClosed)
              _weatherBehaviorSubject.add(WeatherStateSuccess(weatherResponse));
          }
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  fetchWeatherForecastResponse(double? lat, double? lon,
      {String units = 'metric'}) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        // screen not visible
        if (!_forecastBehaviorSubject.isClosed) {
          WeatherForecastListResponse weatherForecastListResponse =
              await weatherRepository.fetchWeatherForecast(lat, lon, units,
                  lang: settingBloc.languageEnum.languageCode);
          if (weatherForecastListResponse.errorCode != null) {
            _forecastBehaviorSubject
                .add(WeatherStateError(weatherForecastListResponse.errorCode));
          } else {
            if (!_forecastBehaviorSubject.isClosed)
              _forecastBehaviorSubject.add(
                  WeatherForecastStateSuccess(weatherForecastListResponse));
          }
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  fetchWeatherForecast7Day(double? lat, double? lon, String exclude,
      {String units = 'metric'}) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        // screen not visible
        if (!_behaviorSubjectForDailyDay.isClosed) {
          WeatherForecastDaily weatherForecast7Day = await weatherRepository
              .fetchWeatherForecast7Day(lat, lon, units, exclude,
                  lang: settingBloc.languageEnum.languageCode);
          if (weatherForecast7Day.errorCode != null) {
            _behaviorSubjectForDailyDay
                .add(WeatherStateError(weatherForecast7Day.errorCode));
          } else {
            if (!_behaviorSubjectForDailyDay.isClosed)
              _behaviorSubjectForDailyDay
                  .add(WeatherForecastDailyStateSuccess(weatherForecast7Day));
          }
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  fetchAirPollution(double? lat, double? lon) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        // screen not visible
        if (!_behaviorSubjectAirPollution.isClosed) {
          AirPollutionResponse airPollutionResponse =
              await weatherRepository.fetchAirPollution(lat, lon);
          if (airPollutionResponse.errorCode != null) {
            _behaviorSubjectAirPollution
                .addError(WeatherStateError(airPollutionResponse.errorCode));
          } else {
            if (!_behaviorSubjectAirPollution.isClosed)
              _behaviorSubjectAirPollution
                  .add(AirPollutionStateSuccess(airPollutionResponse));
          }
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  getAirPollution(double? lat, double? lon) async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        // screen not visible
        if (!_behaviorSubjectAirPollution.isClosed) {
          AirResponse airResponse =
              await weatherRepository.getAirPollution(lat, lon);
          if (airResponse.errorCode != null) {
            _behaviorSubjectAirPollution
                .addError(WeatherStateError(airResponse.errorCode));
          } else {
            if (!_behaviorSubjectAirPollution.isClosed)
              _behaviorSubjectAirPollution.add(AirStateSuccess(airResponse));
          }
        }
      } else {
        appBloc.addError(ApplicationError.connectionError);
      }
    });
  }

  getCovid19Summary() async {
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        // screen not visible
        if (!_behaviorSubjectCovid.isClosed) {
          CovidSummaryResponse covidSummaryResponse =
              await weatherRepository.getCovid19Summary();
          if (covidSummaryResponse.errorCode != null) {
            _behaviorSubjectCovid
                .addError(WeatherStateError(covidSummaryResponse.errorCode));
          } else {
            if (!_behaviorSubjectCovid.isClosed)
              _behaviorSubjectCovid
                  .add(CovidStateSuccess(covidSummaryResponse));
          }
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
    _behaviorSubjectAirPollution.close();
    _behaviorSubjectCovid.close();
  }

  Stream get weatherForecastStream => _forecastBehaviorSubject.stream;

  Stream get weatherForecastDailyStream => _behaviorSubjectForDailyDay.stream;

  Stream get weatherStream => _weatherBehaviorSubject.stream;

  Stream<WeatherState> get airPollutionStream =>
      _behaviorSubjectAirPollution.stream;

  Stream<WeatherState> get covidStream => _behaviorSubjectCovid.stream;
}
