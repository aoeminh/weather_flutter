import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/city.dart';

class CityBloc extends BlocBase {
  List<City> _cities;

  getListCity()async{
    String cityStr = await rootBundle.loadString("assets/city/cities.json");

    List<dynamic> list = jsonDecode(cityStr);
    _cities = list.map((e) => City.fromJson(e)).toList();
    print('_cities ${_cities.length}');
  }


  @override
  void dispose() {
  }
 List<City> get cities  => _cities;
}

final cityBloc = CityBloc();