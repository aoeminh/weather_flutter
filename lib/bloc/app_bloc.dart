import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import '../model/application_error.dart';
import '../model/city.dart';
import '../model/coordinates.dart';
import '../utils/share_preferences.dart';
import 'base_bloc.dart';

class AppBloc extends BlocBase {
  List<City>? _cities;
  List<City>? _suggestCities;
  BehaviorSubject<ApplicationError> _errorBehavior = BehaviorSubject();

  addError(ApplicationError error) {
    _errorBehavior.add(error);
  }

  Future<City> determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    var position = await Geolocator.getCurrentPosition();
    return City(
        coordinates: Coordinates(position.longitude, position.latitude));
    // add the first city
  }

  getListCity() async {
    String cityStr = await rootBundle.loadString("assets/city/cities.json");

    List<dynamic> list = jsonDecode(cityStr);
    _cities = list.map((e) => City.fromAssetJson(e)).toList();
  }

  getListSuggestCity() async {
    String cityStr =
        await rootBundle.loadString("assets/city/suggest_city.json");

    List<dynamic> list = jsonDecode(cityStr);
    _suggestCities = list.map((e) => City.fromJson(e)).toList();
  }

  List<City> decodeListCity(String cities) {
    return (jsonDecode(cities) as List<dynamic>)
        .map((e) => City.fromJson(e))
        .toList();
  }

  saveListCity(List<City> cities) async {
    await Preferences.saveListCity(cities);
  }

  Future<List<City>> getListCityFromCache() async {
    return Preferences.getListCityFromCache();
  }

  Stream<ApplicationError> get errorStream => _errorBehavior.stream;

  List<City>? get cities => _cities;

  List<City>? get suggestCities => _suggestCities;

  @override
  void dispose() {
    _errorBehavior.close();
  }
}

final appBloc = AppBloc();
