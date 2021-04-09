import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/city_bloc.dart';

import 'base_bloc.dart';

class PageBloc extends BlocBase {
  List<Position> _positions = [];
  List<String> _citiesName= [];
  BehaviorSubject<List<Position>> _behaviorPosition = BehaviorSubject();
  BehaviorSubject<int> currentPage = BehaviorSubject();
  BehaviorSubject<List<String>> _citiesBehavior = BehaviorSubject();

  addPage(double lat, double lon) {
    int index = _positions.indexWhere(
        (element) => (element.latitude == lat && element.longitude == lon));
    if(index == -1){
      _positions.add(Position(latitude: lat, longitude: lon));
      _behaviorPosition.add(_positions);
      currentPage.add(_positions.length);
    }else{
      jumpToPage(index);
    }
  }

  addCityName(String cityName){
    int index = _citiesName.indexWhere((element) => (element == cityName));
    if(index == -1){
      _citiesName.add(cityName);
      _citiesBehavior.add(_citiesName);
    }
  }

  jumpToPage(int index){
    currentPage.add(index);
  }

  Stream get pageStream => _behaviorPosition.stream;
  Stream get citiesStream => _citiesBehavior.stream;

  @override
  void dispose() {
    _behaviorPosition.close();
    currentPage.close();
    _citiesBehavior.close();
  }
}

final pageBloc = PageBloc();
