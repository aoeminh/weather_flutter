import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/weather_response.dart';
import 'package:weather_app/repository/weather_repository.dart';

class WeatherBloc extends BlocBase{


  BehaviorSubject<WeatherState> _behaviorSubject = BehaviorSubject();


  fetchWeather(double lat, double lon, {String units = 'metric'})async{
    _behaviorSubject.add(WeatherStateLoading());

    WeatherResponse weatherResponse= await weatherRepository.fetchWeather(lat, lon, units);
    print('fetchWeather ${weatherResponse.errorCode }');
    if(weatherResponse.errorCode !=null){
      _behaviorSubject.add(WeatherStateError(weatherResponse.errorCode));
    }else{
      _behaviorSubject.add(WeatherStateSuccess(weatherResponse));
    }

  }


  @override
  void dispose() {
    _behaviorSubject.close();

  }

  Stream get weatherStream => _behaviorSubject.stream;
}