import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/model/daily.dart';
import 'package:weather_app/model/weather_forcast_daily.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';
import 'package:weather_app/model/weather_forecast_response.dart';
import 'package:weather_app/shared/constant.dart';
import 'package:weather_app/utils/utils.dart';
import 'base_bloc.dart';
import 'app_bloc.dart';
import '../model/application_error.dart';
import '../model/weather_response.dart';
import 'setting_bloc.dart';
typedef OnTest = Function(bool test);

class ApiServiceBloc extends BlocBase {
  BehaviorSubject<WeatherState> _weatherBehaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _forecastBehaviorSubject = BehaviorSubject();
  BehaviorSubject<WeatherState> _behaviorSubjectForDailyDay = BehaviorSubject();
  BehaviorSubject<OnTest> behaviorSubjectCity1 = BehaviorSubject();

  fetchWeather(double? lat, double? lon, {String units = 'metric'}) async {
    behaviorSubjectCity1.add((test) => {

      print('test $test')
    });
    checkNetWork().then((isNetWorkAvailable) async {
      if (isNetWorkAvailable) {
        WeatherResponse weatherResponse =
            await weatherRepository.fetchWeather(lat, lon, units,lang: Get.deviceLocale!.languageCode);
        if (!_weatherBehaviorSubject.isClosed) {
          if (weatherResponse.errorCode != null) {
            _weatherBehaviorSubject
                .add(WeatherStateError(weatherResponse.errorCode));
          } else {
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
        WeatherForecastListResponse weatherForecastListResponse =
            await weatherRepository.fetchWeatherForecast(lat, lon, units,lang: Get.deviceLocale!.languageCode);
        if (!_forecastBehaviorSubject.isClosed) {
          if (weatherForecastListResponse.errorCode != null) {
            _forecastBehaviorSubject
                .add(WeatherStateError(weatherForecastListResponse.errorCode));
          } else {
            _forecastBehaviorSubject
                .add(WeatherForecastStateSuccess(weatherForecastListResponse));
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
        WeatherForecastDaily weatherForecast7Day = await weatherRepository
            .fetchWeatherForecast7Day(lat, lon, units, exclude,lang: Get.deviceLocale!.languageCode);
        if (!_behaviorSubjectForDailyDay.isClosed) {
          if (weatherForecast7Day.errorCode != null) {
            _behaviorSubjectForDailyDay
                .add(WeatherStateError(weatherForecast7Day.errorCode));
          } else {
            _behaviorSubjectForDailyDay
                .add(WeatherForecastDailyStateSuccess(weatherForecast7Day));
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
  }

  Stream get weatherForecastStream => _forecastBehaviorSubject.stream;

  Stream get weatherForecastDailyStream => _behaviorSubjectForDailyDay.stream;

  Stream get weatherStream => _weatherBehaviorSubject.stream;
}
