import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/model/timezone.dart';

class CityBloc extends BlocBase {
  List<City> _cities;
  List<Timezone> _timezones;



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



  @override
  void dispose() {

  }

  List<City> get cities => _cities;

  List<Timezone> get timezones => _timezones;

}

final cityBloc = CityBloc();
