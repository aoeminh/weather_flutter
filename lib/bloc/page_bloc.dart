import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/city_bloc.dart';
import 'package:weather_app/model/city.dart';

import 'base_bloc.dart';

class PageBloc extends BlocBase {
  List<String> _citiesName = [];
  List<City> _currentCities = [];
  bool isFirstLoad = true;
  BehaviorSubject<List<Position>> _behaviorPosition = BehaviorSubject();
  BehaviorSubject<int> currentPage = BehaviorSubject();
  BehaviorSubject<List<String>> _citiesBehavior = BehaviorSubject();
  BehaviorSubject<List<City>> _behaviorSubjectCity = BehaviorSubject();

  addNewCity(City city) {
    int index = _currentCities.indexWhere((element) =>
        (city.coordinates.latitude == element.coordinates.latitude &&
            city.coordinates.longitude == element.coordinates.longitude));
    if (index == -1) {
      _currentCities.add(city);
      _behaviorSubjectCity.add(_currentCities);
      currentPage.add(_currentCities.length);
    } else {
      jumpToPage(index);
    }
  }

  /// App depend on _currentCities to manage current cites
  /// in first load app, the first city not have name, country
  /// when receive response => remove first city and add new data
  removeItemWhenFirstLoadApp(City city) {
    if (isFirstLoad) {
      _currentCities.removeWhere((element) => element.name == null);
      _currentCities.add(city);
      isFirstLoad = false;
    }
  }

  addCityName(String cityName) {
    int index = _citiesName.indexWhere((element) => (element == cityName));
    if (index == -1) {
      _citiesName.add(cityName);
      _citiesBehavior.add(_citiesName);
    }
  }

  jumpToPage(int index) {
    currentPage.add(index);
  }

  Stream get pageStream => _behaviorSubjectCity.stream;

  Stream get citiesStream => _citiesBehavior.stream;

  Stream get currentCitiesStream => _behaviorSubjectCity.stream;

  List<City> get currentCity => _currentCities;

  @override
  void dispose() {
    _behaviorPosition.close();
    currentPage.close();
    _citiesBehavior.close();
    _behaviorSubjectCity.close();
  }
}

final pageBloc = PageBloc();
