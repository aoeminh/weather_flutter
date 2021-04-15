import 'package:rxdart/rxdart.dart';
import 'package:weather_app/model/city.dart';
import '../model/coordinates.dart';

import 'base_bloc.dart';

class PageBloc extends BlocBase {
  List<City> _currentCities = [];
  bool isFirstLoad = true;
  BehaviorSubject<int> _currentPage = BehaviorSubject();
  BehaviorSubject<List<City>> _behaviorSubjectCity = BehaviorSubject();

  addNewCity(City city) {
    int index = _currentCities.indexWhere((element) =>
        (city.coordinates.latitude == element.coordinates.latitude &&
            city.coordinates.longitude == element.coordinates.longitude));
    if (index == -1) {
      _currentCities.add(city);
      _behaviorSubjectCity.add(_currentCities);
      jumpToPage(_currentCities.length);
    } else {
      jumpToPage(index);
    }
  }

  /// App depend on [_currentCities] to manage current cites
  /// in first load app, the first city not have name, country
  /// when receive response => remove first city and add new data
  /// set [city] is your city that not deleted
  removeItemWhenFirstLoadApp(City city) {
    if (isFirstLoad) {
      _currentCities.removeWhere((element) => element.name == null);
      _currentCities.add(City(
          coordinates: city.coordinates,
          id: city.id,
          country: city.country,
          name: city.name,
          isHome: true));
      isFirstLoad = false;
    }
  }

  editCurrentCityList(List<City> list) {
    _currentCities = list;
    _behaviorSubjectCity.add(_currentCities);
  }

  deleteCity(City city){
    _currentCities.remove(city);
    _behaviorSubjectCity.add(_currentCities);
  }

  List<City> copyCurrentCityList(List<City> list) {
    return list
        .map((e) => City(
            isHome: e.isHome,
            name: e.name,
            country: e.country,
            id: e.id,
            coordinates:
                Coordinates(e.coordinates.latitude, e.coordinates.longitude)))
        .toList();
  }

  jumpToPage(int index) {
    _currentPage.add(index);
  }

  Stream get pageStream => _behaviorSubjectCity.stream;

  Stream get currentCitiesStream => _behaviorSubjectCity.stream;

  Stream<int> get currentPage => _currentPage.stream;

  List<City> get currentCity => _currentCities;

  @override
  void dispose() {
    _currentPage.close();
    _behaviorSubjectCity.close();
  }
}

final pageBloc = PageBloc();
