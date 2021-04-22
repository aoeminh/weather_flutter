import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import '../model/coordinates.dart';
import 'base_bloc.dart';
import '../model/application_error.dart';
import '../model/city.dart';
import '../model/timezone.dart';

class AppBloc extends BlocBase {
  List<City> _cities;
  List<Timezone> _timezones;
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
        coordinates: Coordinates(position.latitude, position.longitude));
    // add the first city
  }

  getListCity() async {
    String cityStr = await rootBundle.loadString("assets/city/cities.json");

    List<dynamic> list = jsonDecode(cityStr);
    _cities = list.map((e) => City.fromJson(e)).toList();
  }

  getListTimezone() async {
    String timezoneStr =
        await rootBundle.loadString("assets/city/timezone.json");
    List<dynamic> list = jsonDecode(timezoneStr);
    _timezones = list.map((e) => Timezone.fromJson(e)).toList();
  }

  Stream<ApplicationError> get errorStream => _errorBehavior.stream;

  List<City> get cities => _cities;

  List<Timezone> get timezones => _timezones;

  @override
  void dispose() {
    _errorBehavior.close();
  }
}

final appBloc = AppBloc();
