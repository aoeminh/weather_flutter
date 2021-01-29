import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/weather_forecast_list_response.dart';

class WeatherForecastBloc extends BlocBase{

  BehaviorSubject<WeatherState> _behaviorSubject = BehaviorSubject();

  fetchWeatherForecastResponse(double lat, double lon,{String units = 'metric'})async{
    _behaviorSubject.add(WeatherStateLoading());

    WeatherForecastListResponse weatherForecastListResponse = await weatherRepository.fetchWeatherForecast(lat, lon, units);
    if(weatherForecastListResponse.errorCode !=null){
      _behaviorSubject.add(WeatherStateError(weatherForecastListResponse.errorCode));
    }else{
      _behaviorSubject.add(WeatherForecastStateSuccess(weatherForecastListResponse));
    }

  }


  @override
  void dispose() {
    _behaviorSubject.close();
  }

  Stream get weatherForecastStream => _behaviorSubject.stream;

}