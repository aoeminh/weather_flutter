import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_app/bloc/base_bloc.dart';
import 'package:weather_app/model/city.dart';
import 'package:weather_app/model/coordinates.dart';

class PositionBloc extends BlocBase {


  @override
  void dispose() {}
}

final positionBloc = PositionBloc();
